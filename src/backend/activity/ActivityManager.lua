local AGS = AwesomeGuildStore

local logger = AGS.internal.logger
local gettext = AGS.internal.gettext

local ActivityManager = ZO_Object:Subclass()
AGS.class.ActivityManager = ActivityManager

local RegisterForEvent = AGS.internal.RegisterForEvent
local ActivityBase = AGS.class.ActivityBase
local RequestSearchActivity = AGS.class.RequestSearchActivity
local RequestNewestActivity = AGS.class.RequestNewestActivity
local RequestListingsActivity = AGS.class.RequestListingsActivity
local PurchaseItemActivity = AGS.class.PurchaseItemActivity
local PostItemActivity = AGS.class.PostItemActivity
local CancelItemActivity = AGS.class.CancelItemActivity
local FetchGuildItemsActivity = AGS.class.FetchGuildItemsActivity

local ByPriority = ActivityBase.ByPriority

function ActivityManager:New(...)
    local selector = ZO_Object.New(self)
    selector:Initialize(...)
    return selector
end

function ActivityManager:Initialize(tradingHouseWrapper, loadingIndicator, loadingOverlay)
    self.queue = {}
    self.lookup = {}
    self.tradingHouseWrapper = tradingHouseWrapper
    self.tradingHouse = tradingHouseWrapper.tradingHouse

    RegisterForEvent(EVENT_TRADING_HOUSE_AWAITING_RESPONSE, function(_, responseType)
        if(self.currentActivity and self.currentActivity:OnAwaitingResponse(responseType)) then
            -- TRANSLATORS: Status text when waiting for a server response
            self:SetStatusText(gettext("Waiting for response"))
        end
    end)

    local function OnTimeout(_, responseType)
        if(self.currentActivity and self.currentActivity:OnTimeout(responseType)) then
            -- TRANSLATORS: Status text when a server response timed out
            self:SetStatusText(gettext("Request timed out"))
        end
    end
    RegisterForEvent(EVENT_TRADING_HOUSE_RESPONSE_TIMEOUT, OnTimeout)
    RegisterForEvent(EVENT_TRADING_HOUSE_OPERATION_TIME_OUT, OnTimeout)

    RegisterForEvent(EVENT_TRADING_HOUSE_ERROR, function(_, errorCode)
        if(self.currentActivity) then
            local responseType = self.currentActivity.expectedResponseType
            self.currentActivity:OnResponse(responseType, errorCode)
        end
    end)

    -- need to prehook this in order to update the itemdatabase before anything else happens
    tradingHouseWrapper:PreHook("OnResponseReceived", function(_, responseType, result)
        if(self.currentActivity) then
            self.currentActivity:OnResponse(responseType, result)
        end
    end)

    RegisterForEvent(EVENT_TRADING_HOUSE_SEARCH_COOLDOWN_UPDATE, function(_, cooldown)
        -- TODO prehook?
        if(cooldown == 0) then
            self:HideLoading()
            self:RefreshStatusPanel()
            self:ExecuteNext()
        end
    end)

    RegisterForEvent(EVENT_TRADING_HOUSE_STATUS_RECEIVED, function(_)
        logger:Verbose("cooldown on status received: %d", GetTradingHouseCooldownRemaining())
        -- TODO: queue is ready to do work
        self:RefreshStatusPanel()
    end)

    RegisterForEvent(EVENT_CLOSE_TRADING_HOUSE, function(_)
        if(self.currentActivity) then
            local activity = self.currentActivity
            self:RemoveCurrentActivity()
            activity.result = ActivityBase.ERROR_TRADING_HOUSE_CLOSED
        end
        self:ClearQueue()
        self:RefreshStatusPanel()
    end)

    RegisterForEvent(EVENT_TRADING_HOUSE_CONFIRM_ITEM_PURCHASE, function(_, index)
        if(self.currentActivity) then
            self.currentActivity:OnPendingPurchaseChanged()
        end
    end)

    self.executeNext = function()
        self:ExecuteNext()
    end

    -- TODO find a proper place for this. handle it inside each tab?
    AGS:RegisterCallback(AGS.callback.STORE_TAB_CHANGED, function(oldTab, newTab)
        if(oldTab == tradingHouseWrapper.searchTab) then
            self:CancelSearch()
        end

        if(newTab == tradingHouseWrapper.searchTab) then
            self:RemoveActivitiesByType(ActivityBase.ACTIVITY_TYPE_REQUEST_LISTINGS)
        else
            local guildId = GetSelectedTradingHouseGuildId()
            self:RequestListings(guildId)
        end
    end)

    -- TODO handle this inside each tab?
    AGS:RegisterCallback(AGS.callback.GUILD_SELECTION_CHANGED, function(guildData)
        self:CancelSearch()

        if(self.tradingHouse:IsInListingsMode() or self.tradingHouse:IsInSellMode()) then
            self:RequestListings(guildData.guildId)
        end
    end)
end

-- TODO: these functions should be removed and we should react to callbacks instead
function ActivityManager:SetStatusLine(statusLine)
    self.statusLine = statusLine
end

function ActivityManager:SetActivityWindow(activityWindow)
    self.activityWindow = activityWindow
end

function ActivityManager:SetStatusText(text)
    if(not self.statusLine) then return end
    self.statusLine:SetStatusText(text)
end

function ActivityManager:RefreshStatusPanel()
    if(not self.activityWindow) then return end
    self.activityWindow:Refresh()
end

function ActivityManager:AddActivityToStatusPanel(activity)
    if(not self.activityWindow) then return end
    self.activityWindow:AddActivity(activity)
end

function ActivityManager:ShowLoading()
    if(not self.statusLine) then return end
    self.statusLine:ShowLoading()
end

function ActivityManager:HideLoading()
    if(not self.statusLine) then return end
    self.statusLine:HideLoading()
end

function ActivityManager:UpdateQueuedActivityStatus()
    -- TRANSLATORS: Status text when a new activity was queued
    self:SetStatusText(gettext("<<1[No activity/One activity/$d activities]>> queued", #self.queue))
    self:RefreshStatusPanel()
end

function ActivityManager:QueueActivity(activity)
    local queue, lookup = self.queue, self.lookup
    local key = activity:GetKey()
    if(lookup[key]) then return false end
    queue[#queue + 1] = activity
    lookup[key] = activity
    zo_callLater(self.executeNext, 0)

    self:UpdateQueuedActivityStatus()

    return true
end

function ActivityManager:ClearQueue()
    for _, activity in pairs(self.queue) do
        activity:OnRemove()
        self:AddActivityToStatusPanel(activity)
    end

    ZO_ClearTable(self.lookup)
    ZO_ClearTable(self.queue)

    self:UpdateQueuedActivityStatus()
end

function ActivityManager:RemoveCurrentActivity()
    if(self.currentActivity) then
        self.currentActivity:OnRemove()
        self:AddActivityToStatusPanel(self.currentActivity)
        self.lookup[self.currentActivity:GetKey()] = nil
        local oldActivity = self.currentActivity
        self.currentActivity = nil
        AGS.internal:FireCallbacks(AGS.callback.CURRENT_ACTIVITY_CHANGED, nil, oldActivity)
        self:RefreshStatusPanel()
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
            self:AddActivityToStatusPanel(activity)
        end
    end
    self:UpdateQueuedActivityStatus()
end

function ActivityManager:RemoveActivityByKey(key)
    local queue = self.queue
    for i = #queue, 1, -1 do
        local activity = queue[i]
        if(activity:GetKey() == key) then
            table.remove(queue, i)
            self.lookup[key] = nil
            activity:OnRemove()
            self:AddActivityToStatusPanel(activity)
        end
    end
    self:UpdateQueuedActivityStatus()
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
        AGS.internal:FireCallbacks(AGS.callback.CURRENT_ACTIVITY_CHANGED, activity)
        -- TRANSLATORS: Status text when the next activity can be executed
        self:SetStatusText(gettext("Execute next activity"))
        self:ShowLoading()

        activity:DoExecute():Then(function(activity)
            self:OnSuccess(activity)
        end, function(activity)
            self:OnFailure(activity)
        end)
        return true
    end

    self:RefreshStatusPanel()

    return false
end

function ActivityManager:OnSuccess(activity)
    -- TRANSLATORS: Status text when a server request was successfully completed
    self:SetStatusText(gettext("Request finished"))
    self:HideLoading()
    self:RemoveCurrentActivity()
    self:ExecuteNext()
end

function ActivityManager:OnFailure(activity)
    local message
    if(type(activity) == "string") then
        -- TRANSLATORS: Alert text when an activity fails unexpectedly
        message = gettext("Unknown Error")
        logger:Error(activity)
    else
        message = activity:GetErrorMessage()
        logger:Warn(message)
    end

    if(self.tradingHouseWrapper.search:IsAtTradingHouse()) then
        -- TRANSLATORS: Status text when a server request has failed. Placeholder is for an explanation text
        self:SetStatusText(gettext("Request failed: <<1>>", message))
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, message)

        self:HideLoading()
        self:RemoveCurrentActivity()
        self:ExecuteNext()
    end
end

function ActivityManager:CanQueue(key)
    return not self.lookup[key]
end

function ActivityManager:RequestSearchResults(guildId, ignoreResultCount)
    -- TODO: should we use filter state too?
    local key = RequestSearchActivity.CreateKey(guildId)
    if(not (self:CanQueue(key) and self.tradingHouseWrapper.searchTab.isOpen)) then return end

    local searchManager = self.tradingHouseWrapper.searchManager
    if(ignoreResultCount or searchManager:IsResultCountBelowAutoSearchThreshold(searchManager:GetNumVisibleResults())) then
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
    if(not self:CanQueue(key)) then return end
    if(self.tradingHouseWrapper.guildSelection:IsAppliedGuildId(GetSelectedTradingHouseGuildId()) and HasTradingHouseListings()) then return end

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

    local activity = CancelItemActivity:New(self.tradingHouseWrapper, guildId, listingIndex)
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
