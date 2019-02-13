local AGS = AwesomeGuildStore

local logger = AGS.internal.logger

local RegisterForEvent = AwesomeGuildStore.RegisterForEvent
local ItemDatabase = AwesomeGuildStore.ItemDatabase

local TradingHouseWrapper = ZO_Object:Subclass()
AwesomeGuildStore.TradingHouseWrapper = TradingHouseWrapper

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

    self.loadingOverlay = AwesomeGuildStore.LoadingOverlay:New("AwesomeGuildStoreLoadingOverlay")
    self.loadingIndicator = AwesomeGuildStore.LoadingIcon:New("AwesomeGuildStoreLoadingIndicator")
    self.loadingIndicator:SetParent(tradingHouse.control)
    self.loadingIndicator:ClearAnchors()
    self.loadingIndicator:SetAnchor(BOTTOMLEFT, tradingHouse.control, BOTTOMLEFT, 15, 20)
    local itemDatabase = ItemDatabase:New(self)
    self.itemDatabase = itemDatabase
    local searchTab = AwesomeGuildStore.SearchTabWrapper:New(saveData)
    self.searchTab = searchTab
    local sellTab = AwesomeGuildStore.SellTabWrapper:New(saveData)
    self.sellTab = sellTab
    local listingTab = AwesomeGuildStore.ListingTabWrapper:New(saveData)
    self.listingTab = listingTab
    local activityManager = AwesomeGuildStore.ActivityManager:New(self, self.loadingIndicator, self.loadingOverlay)
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
    local CollectGuildKiosk = AwesomeGuildStore.CollectGuildKiosk
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

        AwesomeGuildStore:FireBeforeInitialSetupCallbacks(self)
        for mode, tab in next, self.modeToTab do
            tab:RunInitialSetup(self)
        end

        if(not saveData.minimizeChatOnOpen) then
            TRADING_HOUSE_SCENE:RemoveFragment(MINIMIZE_CHAT_FRAGMENT)
        end

        self:InitializeGuildSelector()
        self:InitializeKeybindStripWrapper()
        AwesomeGuildStore:FireAfterInitialSetupCallbacks(self)

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
        AGS:FireCallbacks("StoreTabChanged", oldTab, currentTab)
    end)

    RegisterForEvent(EVENT_CLOSE_TRADING_HOUSE, function()
        if(not ranInitialSetup) then return end
        self:HideLoadingIndicator()
        self:HideLoadingOverlay()
        if currentTab then
            currentTab:OnClose(self)
        end
        tradingHouse:ClearPendingPost()
        if(saveData.resetFiltersOnExit) then
            tradingHouse:ResetAllSearchData()
        end
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
    self.guildSelection = AwesomeGuildStore.class.GuildSelection:New(self)
    self.guildSelector = AwesomeGuildStore.GuildSelector:New(self)
end

function TradingHouseWrapper:InitializeKeybindStripWrapper()
    self.keybindStrip = AwesomeGuildStore.KeybindStripWrapper:New(self)
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
