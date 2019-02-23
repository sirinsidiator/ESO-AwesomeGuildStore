local AGS = AwesomeGuildStore

local logger = AGS.internal.logger
local gettext = AGS.internal.gettext

local ActivityManager = ZO_Object:Subclass()
AwesomeGuildStore.ActivityManager = ActivityManager

local RegisterForEvent = AwesomeGuildStore.RegisterForEvent
local ActivityBase = AwesomeGuildStore.class.ActivityBase
local RequestSearchActivity = AwesomeGuildStore.class.RequestSearchActivity
local RequestNewestActivity = AwesomeGuildStore.class.RequestNewestActivity
local RequestListingsActivity = AwesomeGuildStore.class.RequestListingsActivity
local PurchaseItemActivity = AwesomeGuildStore.class.PurchaseItemActivity
local PostItemActivity = AwesomeGuildStore.class.PostItemActivity
local CancelItemActivity = AwesomeGuildStore.class.CancelItemActivity
local FetchGuildItemsActivity = AwesomeGuildStore.class.FetchGuildItemsActivity
local ActivityPanel = AwesomeGuildStore.class.ActivityPanel

local ByPriority = ActivityBase.ByPriority

local WATCHDOG_NAME = "AwesomeGuildStore_ActivityManager"
local WATCHDOG_INTERVAL = 5000

local QSTATE_QUEUED = 1
local QSTATE_CURRENT = 2
local QSTATE_REMOVED = 3
local QSTATE_CLEARED = 4

function ActivityManager:New(...)
    local selector = ZO_Object.New(self)
    selector:Initialize(...)
    return selector
end

function ActivityManager:Initialize(tradingHouseWrapper, loadingIndicator, loadingOverlay)
    self.counterFailure = 0 -- TODO remove
    self.counterSuccess = 0
    self.counterOther = 0

    self.queue = {}
    self.lookup = {}
    self.tradingHouseWrapper = tradingHouseWrapper
    self.tradingHouse = tradingHouseWrapper.tradingHouse

    RegisterForEvent(EVENT_TRADING_HOUSE_AWAITING_RESPONSE, function(_, responseType) -- TODO prehook?
        logger:Debug(string.format("cooldown on awaiting response: %d", GetTradingHouseCooldownRemaining())) -- TODO cleanup
        if(self.currentActivity) then
            self.currentActivity:OnAwaitingResponse(responseType, self.panel) -- TODO do we need to pass the panel here? can we pass it to the activity when we create it?
        end
    end)

    RegisterForEvent(EVENT_TRADING_HOUSE_OPERATION_TIME_OUT, function(_, responseType) -- TODO prehook?
        logger:Debug(string.format("cooldown on timeout: %d", GetTradingHouseCooldownRemaining())) -- TODO cleanup
        if(self.currentActivity) then
            self.currentActivity:OnTimeout(responseType, self.panel) -- TODO panel
        end
    end)

    RegisterForEvent(EVENT_TRADING_HOUSE_ERROR, function(_, errorCode) -- TODO prehook?
        logger:Debug(string.format("cooldown on error: %d", GetTradingHouseCooldownRemaining()))
        -- TODO: this is used for input errors. need to test
        if(self.currentActivity) then
            local responseType = self.currentActivity.expectedResponseType
            self.currentActivity:OnResponse(responseType, errorCode, self.panel) -- TODO panel
        end
    end)

    -- need to prehook this in order to update the itemdatabase before anything else happens
    tradingHouseWrapper:PreHook("OnResponseReceived", function(_, responseType, result)
        logger:Debug(string.format("cooldown on response: %d", GetTradingHouseCooldownRemaining()))
        if(self.currentActivity) then
            self.currentActivity:OnResponse(responseType, result, self.panel) -- TODO panel
        end
    end)

    RegisterForEvent(EVENT_TRADING_HOUSE_SEARCH_COOLDOWN_UPDATE, function(_, cooldown)
        -- TODO prehook?
        if(cooldown == 0) then
            self.panel:HideLoading()
            self.panel:Refresh()
            self:ExecuteNext()
        end
    end)

    RegisterForEvent(EVENT_TRADING_HOUSE_STATUS_RECEIVED, function(_) -- TODO prehook?
        logger:Debug(string.format("cooldown on status received: %d", GetTradingHouseCooldownRemaining()))
        -- TODO: queue is ready to do work
        self:StartWatchdog()
        self.panel:Refresh()
    end)

    RegisterForEvent(EVENT_CLOSE_TRADING_HOUSE, function(_) -- TODO prehook?
        if(self.currentActivity) then
            self:RemoveCurrentActivity()
    end
    self:ClearQueue()
    self:StopWatchdog()
    self.panel:Refresh()
    end)

    RegisterForEvent(EVENT_TRADING_HOUSE_CONFIRM_ITEM_PURCHASE, function(_, index)
        if(self.currentActivity) then
            self.currentActivity:OnPendingPurchaseChanged()
        end
    end)

    self.executeNext = function()
        self:ExecuteNext()
    end

    -- TODO find a proper place for this
    self.panel = ActivityPanel:New(self)
    TRADING_HOUSE_SCENE:AddFragment(self.panel)

    -- TODO handle this inside each tab?
    AGS:RegisterCallback(AGS.callback.STORE_TAB_CHANGED, function(oldTab, newTab)
        if(oldTab == tradingHouseWrapper.searchTab) then
            self:CancelSearch()
        elseif(oldTab == tradingHouseWrapper.listingTab) then
            self:RemoveActivitiesByType(ActivityBase.ACTIVITY_TYPE_REQUEST_LISTINGS)
        end

        if(newTab == tradingHouseWrapper.listingTab) then
            local guildId = GetCurrentTradingHouseGuildDetails()
            self:RequestListings(guildId)
        end
    end)

    -- TODO handle this inside each tab?
    AGS:RegisterCallback(AGS.callback.GUILD_SELECTION_CHANGED, function(guildData)
        self:CancelSearch()

        if(self.tradingHouse:IsInListingsMode()) then
            self:RequestListings(guildData.guildId)
        end
    end)
end

function ActivityManager:StartWatchdog()
    EVENT_MANAGER:RegisterForUpdate(WATCHDOG_NAME, WATCHDOG_INTERVAL, self.executeNext)
end

function ActivityManager:StopWatchdog()
    EVENT_MANAGER:UnregisterForUpdate(WATCHDOG_NAME, WATCHDOG_INTERVAL)
end

function ActivityManager:QueueActivity(activity)
    local queue, lookup = self.queue, self.lookup
    local key = activity:GetKey()
    if(lookup[key]) then return false end
    queue[#queue + 1] = activity
    lookup[key] = activity
    zo_callLater(self.executeNext, 0)

    self.panel:Refresh()

    return true
end

function ActivityManager:ClearQueue()
    for _, activity in pairs(self.queue) do
        activity:OnRemove()
        self.panel:AddActivity(activity)
    end
    self.panel:Refresh()

    ZO_ClearTable(self.lookup)
    ZO_ClearTable(self.queue)
end

function ActivityManager:RemoveCurrentActivity()
    if(self.currentActivity) then
        self.currentActivity:OnRemove()
        self.panel:AddActivity(self.currentActivity)
        self.lookup[self.currentActivity:GetKey()] = nil
        local oldActivity = self.currentActivity
        self.currentActivity = nil
        AGS:FireCallbacks(AGS.callback.CURRENT_ACTIVITY_CHANGED, nil, oldActivity)
        self.panel:Refresh()
    end
end

function ActivityManager:RemoveActivitiesByType(activityType)
    local queue = self.queue
    for i = #queue, 1, -1 do
        local activity = queue[i]
        if(activity:GetType() == activityType) then
            table.remove(queue, i)
            self.lookup[activity:GetKey()] = nil
            activity:OnRemove()
            self.panel:AddActivity(activity)
        end
    end
    self.panel:Refresh()
end

function ActivityManager:RemoveActivityByKey(key)
    local queue = self.queue
    for i = #queue, 1, -1 do
        local activity = queue[i]
        if(activity:GetKey() == key) then
            table.remove(queue, i)
            self.lookup[key] = nil
            activity:OnRemove()
            self.panel:AddActivity(activity)
        end
    end
    self.panel:Refresh()
end

function ActivityManager:GetActivity(key)
    return self.lookup[key]
end

function ActivityManager:GetActivitiesByType(activityType)
    local activities = {}
    local queue = self.queue
    for i = 1, #queue do
        local activity = queue[i]
        if(activity:GetType() == activityType) then
            activities[#activities + 1] = queue[i]
        end
    end
    return activities
end

function ActivityManager:GetCurrentActivity()
    return self.currentActivity
end

function ActivityManager:ExecuteNext()
    if(self.currentActivity or not self.tradingHouseWrapper.search:IsAtTradingHouse()) then return false end

    local queue = self.queue

    -- let each activity determine if it can be executed right now and then sort by canExecute, priority and guildId
    for i = 1, #queue do
        queue[i]:Update()
    end
    table.sort(queue, ByPriority)

    local activity = queue[1]
    if(activity and activity:CanExecute()) then
        table.remove(queue, 1)

        self.currentActivity = activity
        AGS:FireCallbacks(AGS.callback.CURRENT_ACTIVITY_CHANGED, activity)
        self.panel:SetStatusText("Execute next activity") -- TODO
        self.panel:ShowLoading()

        activity:DoExecute(self.panel):Then(function(activity)
            self:OnSuccess(activity)
        end, function(activity)
            self:OnFailure(activity)
        end)
        return true
    end

    self.panel:Refresh()

    return false
end

function ActivityManager:OnSuccess(activity)
    self.panel:HideLoading()
    self:RemoveCurrentActivity()
    self:ExecuteNext()
end

function ActivityManager:OnFailure(activity)
    if(type(activity) == "string") then
        logger:Error(activity)
        return
    end
    -- TODO we should log real activity information too

    local message = activity:GetErrorMessage()
    ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, message)
    self.panel:SetStatusText(message)

    self.panel:HideLoading()
    self:RemoveCurrentActivity()
    self:ExecuteNext()
end

function ActivityManager:CanQueue(key)
    return not self.lookup[key]
end

function ActivityManager:RequestSearchResults(guildId, ignoreResultCount)
    -- TODO: should we use filter state too?
    local key = RequestSearchActivity.CreateKey(guildId)
    if(not (self:CanQueue(key) and self.tradingHouseWrapper.searchTab.isOpen)) then return end

    local AUTO_SEARCH_RESULT_COUNT_THRESHOLD = 50 -- TODO: tweak value, move into search manager?
    local guildName = self.tradingHouseWrapper:GetTradingGuildName(guildId)
    if(ignoreResultCount or self.tradingHouseWrapper.searchTab.searchManager:GetNumVisibleResults(guildName) < AUTO_SEARCH_RESULT_COUNT_THRESHOLD) then
        local activity = RequestSearchActivity:New(self.tradingHouseWrapper, guildId)
        self:QueueActivity(activity)
        return activity
    end
end

function ActivityManager:RequestNewestResults(guildId)
    local key = RequestNewestActivity.CreateKey(guildId)
    if(not (self:CanQueue(key) and self.tradingHouseWrapper.searchTab.isOpen)) then return end
    -- TODO: check cooldown too

    local activity = RequestNewestActivity:New(self.tradingHouseWrapper, guildId) -- TODO handle pages
    self:QueueActivity(activity)
    return activity
end

function ActivityManager:RequestListings(guildId)
    local key = RequestListingsActivity.CreateKey(guildId)
    if(not self:CanQueue(key)) then return end -- TODO: check currently opened tab too?

    local activity = RequestListingsActivity:New(self.tradingHouseWrapper, guildId)
    self:QueueActivity(activity)
    return activity
end

function ActivityManager:PostItem(guildId, bagId, slotIndex, stackCount, price)
    local key = PostItemActivity.CreateKey()
    if(not self:CanQueue(key)) then return end

    local activity = PostItemActivity:New(self.tradingHouseWrapper, guildId, bagId, slotIndex, stackCount, price)
    self:QueueActivity(activity)
    return activity
end

function ActivityManager:PurchaseItem(guildId, itemData)
    local key = PurchaseItemActivity.CreateKey(guildId, itemData.itemUniqueId, itemData.purchasePrice)
    if(not self:CanQueue(key)) then return end

    local activity = PurchaseItemActivity:New(self.tradingHouseWrapper, guildId, itemData)
    self:QueueActivity(activity)
    return activity
end

function ActivityManager:CancelItem(guildId, listingIndex)
    local uniqueId = select(9, GetTradingHouseListingItemInfo(listingIndex))
    local key = CancelItemActivity.CreateKey(guildId, uniqueId)
    if(not self:CanQueue(key)) then return end

    local activity = CancelItemActivity:New(self.tradingHouseWrapper, guildId, listingIndex, uniqueId, price)
    self:QueueActivity(activity)
    return activity
end

function ActivityManager:FetchGuildItems(guildId)
    local key = FetchGuildItemsActivity.CreateKey(guildId)
    if(not self:CanQueue(key)) then return end

    local activity = FetchGuildItemsActivity:New(self.tradingHouseWrapper, guildId)
    self:QueueActivity(activity)
    return activity
end

function ActivityManager:CancelSearch()
    self:RemoveActivitiesByType(ActivityBase.ACTIVITY_TYPE_REQUEST_SEARCH)
end

function ActivityManager:CancelRequestNewest()
    self:RemoveActivitiesByType(ActivityBase.ACTIVITY_TYPE_REQUEST_NEWEST)
end
