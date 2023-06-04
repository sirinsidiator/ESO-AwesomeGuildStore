local AGS = AwesomeGuildStore

local logger = AGS.internal.logger
local gettext = AGS.internal.gettext

local ItemDatabase = AGS.class.ItemDatabase
local RegisterForEvent = AGS.internal.RegisterForEvent
local ShowGuildDetails = AGS.internal.ShowGuildDetails
local TradingHouseStatus = AGS.internal.TradingHouseStatus

local FOOTER_MIN_ALPHA = 0.6
local FOOTER_MAX_ALPHA = 1
local FOOTER_FADE_DURATION = 300
local GUILD_INFO_SCENE_NAME = AGS.internal.GUILD_INFO_SCENE_NAME

local TradingHouseWrapper = ZO_InitializingObject:Subclass()
AGS.class.TradingHouseWrapper = TradingHouseWrapper

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
    local interactionHelper = AGS.class.InteractionHelper:New(self, saveData)
    self.interactionHelper = interactionHelper
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

    -- no need to have the game process this. we handle it ourselves
    EVENT_MANAGER:UnregisterForEvent(ZO_TRADING_HOUSE_SYSTEM_NAME, EVENT_OPEN_TRADING_HOUSE)
    EVENT_MANAGER:UnregisterForEvent(ZO_TRADING_HOUSE_SYSTEM_NAME, EVENT_CLOSE_TRADING_HOUSE)
    ZO_TRADING_HOUSE_INTERACTION.OnInteractSwitch = nil

    -- we need to re-add it in order to ensure that BACKPACK_TRADING_HOUSE_LAYOUT_FRAGMENT is processed first
    -- otherwise the sell tab has trouble with filtering the bank inventory correctly
    TRADING_HOUSE_SCENE:RemoveFragment(TRADING_HOUSE_FRAGMENT)
    TRADING_HOUSE_SCENE:AddFragment(TRADING_HOUSE_FRAGMENT)

    self.ignoreModeChanges = false
    self:PreHook("OpenTradingHouse", function()
        self.ignoreModeChanges = true
    end)

    TRADING_HOUSE_FRAGMENT:RegisterCallback("StateChange", function(oldState, newState)
        if self:IsGuildInfoSceneTransition() then return end

        if newState == SCENE_SHOWING then
            tradingHouse:OpenTradingHouse()
        elseif newState == SCENE_HIDDEN then
            tradingHouse:CloseTradingHouse()
        end
    end)

    AGS:RegisterCallback(AGS.callback.TRADING_HOUSE_STATUS_CHANGED, function(newStatus, oldStatus)
        if newStatus == TradingHouseStatus.CONNECTED then
            self:ConnectTradingHouse()
        end
    end)

    SecurePostHook(tradingHouse, "RunInitialSetup", function()
        if self.initialized then return end

        logger:Debug("Before Initial Setup")
        AGS.internal:FireCallbacks(AGS.callback.BEFORE_INITIAL_SETUP, self)

        ZO_PreHook(tradingHouse.menuBar.m_object, "SelectDescriptor", function(_, descriptor, skipAnimation, reselectIfSelected)
            if self.ignoreModeChanges then return true end
        end)

        for mode, tab in next, self.modeToTab do
            tab:RunInitialSetup(self)
        end

        if not saveData.minimizeChatOnOpen then
            TRADING_HOUSE_SCENE:RemoveFragment(MINIMIZE_CHAT_FRAGMENT)
        end

        self:InitializeFooter()
        self:InitializeStatusDisplay()
        self:InitializeGuildSelector()
        self:InitializeKeybindStripWrapper()
        activityManager:SetReady()
        self.initialized = true
        logger:Debug("After Initial Setup")
        AGS.internal:FireCallbacks(AGS.callback.AFTER_INITIAL_SETUP, self)
    end)

    SecurePostHook(tradingHouse, "OpenTradingHouse", function()
        self:OpenTradingHouse()
    end)

    SecurePostHook(tradingHouse, "CloseTradingHouse", function()
        self:CloseTradingHouse()
    end)

    -- we hook into this function in order to disable the ingame search features
    ZO_PreHook(self.search, "AssociateWithSearchFeatures", function(self)
        self.features = {}
        return true
    end)

    -- disable for better startup performance
    self:PreHook("InitializeSearchTerms", function(self)
        return true
    end)

    -- TODO this is only needed until we have implemented the history feature
    ZO_PreHook(self.search, "GenerateSearchTableShortDescription", function(self)
        return true
    end)

    self:Wrap("HandleTabSwitch", function(originalHandleTabSwitch, tradingHouse, tabData)
        local oldTab = self.currentTab
        if self.currentTab then
            self.currentTab:OnClose(self)
        end
        originalHandleTabSwitch(tradingHouse, tabData)
        self.currentTab = self.modeToTab[tabData.descriptor]
        if self.currentTab then
            self.currentTab:OnOpen(self)
        end
        AGS.internal:FireCallbacks(AGS.callback.STORE_TAB_CHANGED, oldTab, self.currentTab)
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
        self:DisconnectTradingHouse()
    end)

    self:InitializeGuildInfoScene()
end

function TradingHouseWrapper:OnBeforeOpenTradingHouse()
    if not self.activityManager:IsReturningFromBank() then
        if IsInGamepadPreferredMode() then
            self.wasInGamepadMode = true
            self:SetGamepadModeEnabled(false)
        end

        self.activityManager:OnConnectTradingHouse()
        SCENE_MANAGER:Show(TRADING_HOUSE_SCENE:GetName())
    end
end

function TradingHouseWrapper:SetGamepadModeEnabled(enable)
    local accessibilityModeEnabled = GetSetting_Bool(SETTING_TYPE_ACCESSIBILITY, ACCESSIBILITY_SETTING_ACCESSIBILITY_MODE)
    if not accessibilityModeEnabled and IsGamepadUISupported() and IsKeyboardUISupported() then
        local mode = enable and INPUT_PREFERRED_MODE_ALWAYS_GAMEPAD or INPUT_PREFERRED_MODE_ALWAYS_KEYBOARD
        SetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_INPUT_PREFERRED_MODE, mode)
    end
end

function TradingHouseWrapper:OpenTradingHouse()
    logger:Debug("OpenTradingHouse")
    self.ignoreModeChanges = false
    if self.interactionHelper:IsBankAvailable() then
        -- change to the configured tab when at a banker
        ZO_MenuBar_SelectDescriptor(self.tradingHouse.menuBar, self.saveData.preferredBankerStoreTab)
    else
        ZO_MenuBar_SelectDescriptor(self.tradingHouse.menuBar, ZO_TRADING_HOUSE_MODE_BROWSE)
    end
end

function TradingHouseWrapper:CloseTradingHouse()
    logger:Debug("CloseTradingHouse")
    self:DisconnectTradingHouse()
    self:HideLoadingIndicator()
    self:HideLoadingOverlay()
    if self.currentTab then
        self.currentTab:OnClose(self)
        self.currentTab = nil
    end
    self.itemDatabase:ClearItemViewCache()
    self.interactionHelper:EndInteraction()

    if self.wasInGamepadMode then
        self.wasInGamepadMode = nil
        self:SetGamepadModeEnabled(true)
    end
end

function TradingHouseWrapper:ConnectTradingHouse()
    logger:Debug("ConnectTradingHouse")
    if self.guildSelection then
        self.guildSelection:OnConnectTradingHouse()
    end
    if AGS.internal.CollectGuildKiosk then
        AGS.internal.CollectGuildKiosk()
    end
end

function TradingHouseWrapper:DisconnectTradingHouse()
    if not self:IsConnected() then return end
    logger:Debug("DisconnectTradingHouse")
    self.interactionHelper:SetStatus(TradingHouseStatus.DISCONNECTING)
    if GetNumGuilds() > 0 then
        self.tradingHouse:ClearPendingPost()
    end
    self.activityManager:OnDisconnectTradingHouse()
    self.interactionHelper:SetStatus(TradingHouseStatus.DISCONNECTED)
end

function TradingHouseWrapper:IsConnected()
    return self.interactionHelper:IsConnected()
end

function TradingHouseWrapper:RegisterTabWrapper(mode, tab)
    assert(self.modeToTab[mode] == nil)
    self.modeToTab[mode] = tab
end

function TradingHouseWrapper:InitializeStatusDisplay()
    self.activityWindow = AGS.class.ActivityWindow:New(self)
    self.statusLine = AGS.class.StatusLine:New(self)

    TRADING_HOUSE_SCENE:AddFragment(self.activityWindow)
    TRADING_HOUSE_SCENE:AddFragment(self.statusLine)

    self.activityManager:SetActivityWindow(self.activityWindow)
    self.activityManager:SetStatusLine(self.statusLine)
end

function TradingHouseWrapper:InitializeGuildSelector()
    self.guildSelection = AGS.class.GuildSelection:New(self)
    self.guildSelector = AGS.class.GuildSelector:New(self)

    local function GoBack()
        SCENE_MANAGER:PopScenes(1)
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
        if guildId then
            GUILD_BROWSER_GUILD_INFO_KEYBOARD.closeCallback = GoBack
            GUILD_BROWSER_GUILD_INFO_KEYBOARD:SetGuildToShow(guildId)
            SCENE_MANAGER:Push(GUILD_INFO_SCENE_NAME)
        end
    end)
end

function TradingHouseWrapper:InitializeGuildInfoScene()
    local guildInfoScene = ZO_Scene:New(GUILD_INFO_SCENE_NAME, SCENE_MANAGER)
    guildInfoScene:RegisterCallback("StateChange", function(oldState, state)
        if state == SCENE_SHOWING then
            GUILD_BROWSER_GUILD_INFO_KEYBOARD:RefreshInfoPanel()
        elseif state == SCENE_HIDDEN then
            GUILD_BROWSER_GUILD_INFO_KEYBOARD:OnInfoSceneHidden()
        end
    end)

    guildInfoScene:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
    guildInfoScene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
    guildInfoScene:AddFragmentGroup(FRAGMENT_GROUP.PLAYER_PROGRESS_BAR_KEYBOARD_CURRENT)
    guildInfoScene:AddFragment(RIGHT_BG_FRAGMENT)
    guildInfoScene:AddFragment(TREE_UNDERLAY_FRAGMENT)
    guildInfoScene:AddFragment(TITLE_FRAGMENT)
    guildInfoScene:AddFragment(GUILD_LINK_TITLE_FRAGMENT)
    guildInfoScene:AddFragment(DISPLAY_NAME_FRAGMENT)
    guildInfoScene:AddFragment(KEYBOARD_GUILD_BROWSER_GUILD_INFO_FRAGMENT)
    guildInfoScene:AddFragment(FRAME_EMOTE_FRAGMENT_SOCIAL)
    self.guildInfoScene = guildInfoScene
end

function TradingHouseWrapper:IsGuildInfoSceneTransition()
    if SCENE_MANAGER:IsShowingNext(GUILD_INFO_SCENE_NAME) then
        return true
    elseif SCENE_MANAGER:GetPreviousSceneName() == GUILD_INFO_SCENE_NAME and not SCENE_MANAGER:GetNextScene() then
        return true
    end
    return false
end

function TradingHouseWrapper:InitializeKeybindStripWrapper()
    self.keybindStrip = AGS.class.KeybindStripWrapper:New(self)
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
    if originalFunction ~= nil and type(originalFunction) == "function" then
        tradingHouse[methodName] = function(...)
            return call(originalFunction, ...)
        end
    end
end

function TradingHouseWrapper:GetTradingGuildName(guildId)
    local guildName = GetGuildName(guildId)
    if guildName == "" then -- TODO find a better way
        guildName = select(2, GetCurrentTradingHouseGuildDetails())
    end
    return guildName
end

function TradingHouseWrapper:DoSearch() -- TODO
    return self.searchManager:DoSearch()
end
