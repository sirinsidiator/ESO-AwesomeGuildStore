local AGS = AwesomeGuildStore

local logger = AGS.internal.logger
local gettext = AGS.internal.gettext

local ItemDatabase = AGS.class.ItemDatabase
local RegisterForEvent = AGS.internal.RegisterForEvent
local IsAtGuildKiosk = AGS.internal.IsAtGuildKiosk
local ShowGuildDetails = AGS.internal.ShowGuildDetails

local KIOSK_OPTION_INDEX = AGS.internal.KIOSK_OPTION_INDEX
local FOOTER_MIN_ALPHA = 0.6
local FOOTER_MAX_ALPHA = 1
local FOOTER_FADE_DURATION = 300

local TradingHouseWrapper = ZO_Object:Subclass()
AGS.class.TradingHouseWrapper = TradingHouseWrapper

function TradingHouseWrapper:New(...)
    local wrapper = ZO_Object.New(self)
    wrapper:Initialize(...)
    return wrapper
end

function TradingHouseWrapper:Initialize(saveData)
    self.saveData = saveData
    local tradingHouse = TRADING_HOUSE
    self.tradingHouse = tradingHouse
    self.search = TRADING_HOUSE_SEARCH

    self.loadingOverlay = AGS.class.LoadingOverlay:New("AwesomeGuildStoreLoadingOverlay")
    self.loadingIndicator = AGS.class.LoadingIcon:New("AwesomeGuildStoreLoadingIndicator")
    self.loadingIndicator:SetParent(tradingHouse.control)
    self.loadingIndicator:ClearAnchors()
    self.loadingIndicator:SetAnchor(BOTTOMLEFT, tradingHouse.control, BOTTOMLEFT, 15, 20)
    local itemDatabase = ItemDatabase:New(self)
    self.itemDatabase = itemDatabase
    self.itemNameMatcher = AGS.class.ItemNameMatcher:New()
    local activityManager = AGS.class.ActivityManager:New(self, self.loadingIndicator, self.loadingOverlay)
    self.activityManager = activityManager
    local searchManager = AGS.class.SearchManager:New(self, saveData.searchManager)
    saveData.searchManager = searchManager:GetSaveData()
    self.searchManager = searchManager
    local searchTab = AGS.class.SearchTabWrapper:New(saveData)
    self.searchTab = searchTab
    local sellTab = AGS.class.SellTabWrapper:New(saveData)
    self.sellTab = sellTab
    local listingTab = AGS.class.ListingTabWrapper:New(saveData)
    self.listingTab = listingTab

    self.modeToTab =
        {
            [ZO_TRADING_HOUSE_MODE_BROWSE] = searchTab,
            [ZO_TRADING_HOUSE_MODE_SELL] = sellTab,
            [ZO_TRADING_HOUSE_MODE_LISTINGS] = listingTab,
        }

    local CollectGuildKiosk = AGS.internal.CollectGuildKiosk
    if(CollectGuildKiosk) then
        RegisterForEvent(EVENT_TRADING_HOUSE_STATUS_RECEIVED, function()
            zo_callLater(CollectGuildKiosk, 0) -- need to wait a frame, otherwise the guild info is incorrect
        end)
    end

    SecurePostHook(tradingHouse, "RunInitialSetup", function()
        logger:Debug("Before Initial Setup")
        AGS.internal:FireCallbacks(AGS.callback.BEFORE_INITIAL_SETUP, self)

        for mode, tab in next, self.modeToTab do
            tab:RunInitialSetup(self)
        end

        if(not saveData.minimizeChatOnOpen) then
            TRADING_HOUSE_SCENE:RemoveFragment(MINIMIZE_CHAT_FRAGMENT)
        end

        self:InitializeFooter()

        self.activityWindow = AGS.class.ActivityWindow:New(self)
        self.statusLine = AGS.class.StatusLine:New(self)

        TRADING_HOUSE_SCENE:AddFragment(self.activityWindow)
        TRADING_HOUSE_SCENE:AddFragment(self.statusLine)

        self.activityManager:SetActivityWindow(self.activityWindow)
        self.activityManager:SetStatusLine(self.statusLine)

        self:InitializeGuildSelector()
        self:InitializeKeybindStripWrapper()
        self:InitializeStoreTabAutoSwitch()
        logger:Debug("After Initial Setup")
        AGS.internal:FireCallbacks(AGS.callback.AFTER_INITIAL_SETUP, self)
    end)

    -- we hook into this function in order to disable the ingame search features
    ZO_PreHook(self.search, "AssociateWithSearchFeatures", function(self)
        self.features = {}
        return true
    end)

    -- TODO this is only needed until we have implemented the history feature
    ZO_PreHook(self.search, "GenerateSearchTableShortDescription", function(self)
        return true
    end)

    local currentTab
    self:Wrap("HandleTabSwitch", function(originalHandleTabSwitch, tradingHouse, tabData)
        local oldTab = currentTab
        if currentTab then
            currentTab:OnClose(self)
        end
        originalHandleTabSwitch(tradingHouse, tabData)
        currentTab = self.modeToTab[tabData.descriptor]
        if currentTab then
            currentTab:OnOpen(self)
        end
        AGS.internal:FireCallbacks(AGS.callback.STORE_TAB_CHANGED, oldTab, currentTab)
    end)

    self:Wrap("UpdateFragments", function(originalUpdateFragments, tradingHouse)
        -- TODO: remove once we have our own history feature
        originalUpdateFragments(tradingHouse)
        SCENE_MANAGER:RemoveFragment(TRADING_HOUSE_SEARCH_HISTORY_KEYBOARD_FRAGMENT)

        if TRADING_HOUSE_SCENE:IsShowing() and tradingHouse:IsInSellMode() then
            sellTab:UpdateFragments()
        end
    end)

    self.previewHelper = AGS.class.ItemPreviewHelper:New(itemDatabase)

    RegisterForEvent(EVENT_CLOSE_TRADING_HOUSE, function()
        self:HideLoadingIndicator()
        self:HideLoadingOverlay()
        if currentTab then
            currentTab:OnClose(self)
        end
        if GetNumGuilds() > 0 then
            tradingHouse:ClearPendingPost()
        end
    end)

    local INTERACT_WINDOW_SHOWN = "Shown"
    INTERACT_WINDOW:RegisterCallback(INTERACT_WINDOW_SHOWN, function()
        -- TODO: find a way to prevent the long wait time that happens sometimes
        -- ResetChatter, IsInteractionPending, EndPendingInteraction
        -- TODO: prevent user from selecting the guild store option again when it is already pending
        if(IsShiftKeyDown() or not saveData.skipGuildKioskDialog) then return end
        if(IsAtGuildKiosk()) then
            logger:Verbose("SelectChatterOption")
            SelectChatterOption(KIOSK_OPTION_INDEX)
        end
    end)
end

function TradingHouseWrapper:RegisterTabWrapper(mode, tab)
    assert(self.modeToTab[mode] == nil)
    self.modeToTab[mode] = tab
end

function TradingHouseWrapper:InitializeGuildSelector()
    self.guildSelection = AGS.class.GuildSelection:New(self)
    self.guildSelector = AGS.class.GuildSelector:New(self)

    local function GoBack()
        SCENE_MANAGER:HideCurrentScene()
    end

    local title = self.tradingHouse.control:GetNamedChild("Title")
    local label = title:GetNamedChild("Label")
    label:SetWidth(0) -- let the guild name length determine the width
    label:SetDimensionConstraints(0, 0, 500, 0)
    local button = AGS.class.SimpleIconButton:New("$(parent)AGSGuildInfoButton", title)
    button:SetAnchor(LEFT, label, RIGHT, 20, 0)
    button:SetSize(48)
    button:SetTextureTemplate("EsoUI/Art/SkillsAdvisor/advisor_tabIcon_tutorial_%s.dds")
    -- TRANSLATORS: tooltip text for the open guild info button in the guild store
    button:SetTooltipText(gettext("Open Guild Info"))
    button:SetClickHandler(MOUSE_BUTTON_INDEX_LEFT, function()
        local guildId = GetSelectedTradingHouseGuildId()
        ShowGuildDetails(guildId, GoBack)
    end)
end

function TradingHouseWrapper:InitializeKeybindStripWrapper()
    self.keybindStrip = AGS.class.KeybindStripWrapper:New(self)
end

function TradingHouseWrapper:InitializeStoreTabAutoSwitch()
    local tradingHouse = self.tradingHouse
    RegisterForEvent(EVENT_TRADING_HOUSE_STATUS_RECEIVED, function()
        -- change to the configured tab when at a banker
        if(not IsAtGuildKiosk()) then
            ZO_MenuBar_SelectDescriptor(tradingHouse.menuBar, self.saveData.preferredBankerStoreTab)
        end
    end)
end

function TradingHouseWrapper:InitializeFooter()
    local parent = self.tradingHouse.control
    local footer = CreateControlFromVirtual("AwesomeGuildStoreFooter", parent, "AwesomeGuildStoreFooterTemplate")
    footer:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT, -20, 32)
    self.footer = footer

    local versionLabel = AGS.info.fullVersion
    local labelControl = footer:GetNamedChild("Version")
    -- TRANSLATORS: Footer text for the store interface. Place holders are for the version string and to make the Donate text clickable and colored
    labelControl:SetText(gettext("AwesomeGuildStore - Version: <<1>> - <<2>>Donate<<3>>", versionLabel, "|cFFD700|H0|h", "|h|r"))
    labelControl:SetHandler("OnLinkMouseUp", AwesomeGuildStore.internal.Donate)

    local animation = ZO_AlphaAnimation:New(labelControl)
    animation:SetMinMaxAlpha(FOOTER_MIN_ALPHA, FOOTER_MAX_ALPHA)
    labelControl:SetHandler("OnMouseEnter", function() animation:FadeIn(0, FOOTER_FADE_DURATION) end)
    labelControl:SetHandler("OnMouseExit", function() animation:FadeOut(0, FOOTER_FADE_DURATION) end)
    labelControl:SetAlpha(FOOTER_MIN_ALPHA)
end

function TradingHouseWrapper:SetLoadingOverlayParent(parent)
    self.loadingOverlay:SetParent(parent)
end

function TradingHouseWrapper:ShowLoadingOverlay()
    self.loadingOverlay:Show()
end

function TradingHouseWrapper:HideLoadingOverlay()
    self.loadingOverlay:Hide()
end

function TradingHouseWrapper:ShowLoadingIndicator()
    self.loadingIndicator:Show()
end

function TradingHouseWrapper:HideLoadingIndicator()
    self.loadingIndicator:Hide()
end

function TradingHouseWrapper:RegisterFilter(filter)
    self.searchManager:RegisterFilter(filter)
end

function TradingHouseWrapper:PreHook(methodName, call)
    ZO_PreHook(self.tradingHouse, methodName, call)
end

function TradingHouseWrapper:Wrap(methodName, call)
    local tradingHouse = self.tradingHouse
    local originalFunction = tradingHouse[methodName]
    if((originalFunction ~= nil) and (type(originalFunction) == "function")) then
        tradingHouse[methodName] = function(...)
            return call(originalFunction, ...)
        end
    end
end

function TradingHouseWrapper:GetTradingGuildName(guildId)
    local guildName = GetGuildName(guildId)
    if(guildName == "") then -- TODO find a better way
        guildName = select(2, GetCurrentTradingHouseGuildDetails())
    end
    return guildName
end

function TradingHouseWrapper:DoSearch() -- TODO
    return self.searchManager:DoSearch()
end
