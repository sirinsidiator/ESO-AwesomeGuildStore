local AGS = AwesomeGuildStore

local logger = AGS.internal.logger
local gettext = AGS.internal.gettext

local RegisterForEvent = AGS.internal.RegisterForEvent
local ItemDatabase = AGS.class.ItemDatabase

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
    local searchTab = AGS.class.SearchTabWrapper:New(saveData)
    self.searchTab = searchTab
    local sellTab = AGS.class.SellTabWrapper:New(saveData)
    self.sellTab = sellTab
    local listingTab = AGS.class.ListingTabWrapper:New(saveData)
    self.listingTab = listingTab
    local activityManager = AGS.class.ActivityManager:New(self, self.loadingIndicator, self.loadingOverlay)
    self.activityManager = activityManager

    self.modeToTab =
        {
            [ZO_TRADING_HOUSE_MODE_BROWSE] = searchTab,
            [ZO_TRADING_HOUSE_MODE_SELL] = sellTab,
            [ZO_TRADING_HOUSE_MODE_LISTINGS] = listingTab,
        }

    -- we cannot wrap TRADING_HOUSE.OpenTradingHouse or RunInitialSetup as it would taint the call stack down the line
    -- e.g. when using inventory items or withdrawing from the bank
    -- instead we use the EVENT_OPEN_TRADING_HOUSE and hook into the first method after RunInitialSetup is called
    local CollectGuildKiosk = AGS.internal.CollectGuildKiosk
    RegisterForEvent(EVENT_OPEN_TRADING_HOUSE, function()
        self:ResetSalesCategoryFilter()
        if(CollectGuildKiosk) then
            CollectGuildKiosk()
        end
    end)

    local ranInitialSetup = false
    -- SetCurrentMode is the first method called after RunInitialSetup
    self:PreHook("SetCurrentMode", function()
        if(ranInitialSetup) then return end

        AGS.internal:FireCallbacks(AGS.callback.BEFORE_INITIAL_SETUP, self)
        for mode, tab in next, self.modeToTab do
            tab:RunInitialSetup(self)
        end

        if(not saveData.minimizeChatOnOpen) then
            TRADING_HOUSE_SCENE:RemoveFragment(MINIMIZE_CHAT_FRAGMENT)
        end

        self:InitializeGuildSelector()
        self:InitializeKeybindStripWrapper()
        self:InitializeFooter()
        AGS.internal:FireCallbacks(AGS.callback.AFTER_INITIAL_SETUP, self)

        ranInitialSetup = true
    end)

    local currentTab = searchTab
    self:Wrap("HandleTabSwitch", function(originalHandleTabSwitch, tradingHouse, tabData)
        if(not ranInitialSetup) then return end
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
    end)

    function ITEM_PREVIEW_KEYBOARD:PreviewTradingHouseSearchResultAsFurniture(tradingHouseIndex)
        local item = itemDatabase:TryGetItemDataInCurrentGuildByUniqueId(tradingHouseIndex)
        if(item and item.originalSlotIndex) then
            tradingHouseIndex = item.originalSlotIndex
        end
        self:SharedPreviewSetup(ZO_ITEM_PREVIEW_TRADING_HOUSE_SEARCH_RESULT_AS_FURNITURE, tradingHouseIndex)
    end

    RegisterForEvent(EVENT_CLOSE_TRADING_HOUSE, function()
        if(not ranInitialSetup) then return end
        self:HideLoadingIndicator()
        self:HideLoadingOverlay()
        if currentTab then
            currentTab:OnClose(self)
        end
        tradingHouse:ClearPendingPost()
    end)

    local KIOSK_OPTION_INDEX = 1
    local INTERACT_WINDOW_SHOWN = "Shown"
    INTERACT_WINDOW:RegisterCallback(INTERACT_WINDOW_SHOWN, function()
        -- TODO: find a way to prevent the long wait time that happens sometimes
        -- ResetChatter, IsInteractionPending, EndPendingInteraction
        -- TODO: prevent user from selecting the guild store option again when it is already pending
        if(IsShiftKeyDown() or not saveData.skipGuildKioskDialog) then return end
        local _, optionType = GetChatterOption(KIOSK_OPTION_INDEX)
        if(optionType == CHATTER_START_TRADINGHOUSE) then
            logger:Debug(string.format("SelectChatterOption"))
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
    labelControl:SetText(gettext("AwesomeGuildStore - Version: <<1>>", versionLabel))
end

function TradingHouseWrapper:ResetSalesCategoryFilter()
    self.sellTab:ResetSalesCategoryFilter()
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
    self.searchTab.searchManager:RegisterFilter(filter)
end

function TradingHouseWrapper:AttachFilter(filter)
    self.searchTab:AttachFilter(filter)
end

function TradingHouseWrapper:DetachFilter(filter)
    self.searchTab:DetachFilter(filter)
end

function TradingHouseWrapper:AttachButton(button)
    self.searchTab:AttachButton(button)
end

function TradingHouseWrapper:DetachButton(button)
    self.searchTab:DetachButton(button)
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
    local guildName
    if(guildId > 0) then
        guildName = GetGuildName(guildId)
    else
        guildName = select(2, GetCurrentTradingHouseGuildDetails())
    end
    return guildName
end

function TradingHouseWrapper:DoSearch() -- TODO
    return self.searchTab.searchManager:DoSearch()
end
