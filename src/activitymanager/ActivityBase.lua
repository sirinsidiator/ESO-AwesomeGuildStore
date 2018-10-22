local AGS = AwesomeGuildStore

local Promise = LibStub("LibPromises")

local ActivityBase = ZO_Object:Subclass()
AGS.class.ActivityBase = ActivityBase

ActivityBase.ACTIVITY_TYPE_REQUEST_SEARCH = 1
ActivityBase.ACTIVITY_TYPE_REQUEST_NEWEST = 2
ActivityBase.ACTIVITY_TYPE_REQUEST_LISTINGS = 3
ActivityBase.ACTIVITY_TYPE_PURCHASE_ITEM = 4
ActivityBase.ACTIVITY_TYPE_POST_ITEM = 5
ActivityBase.ACTIVITY_TYPE_CANCEL_ITEM = 6

ActivityBase.PRIORITY_LOW = 3
ActivityBase.PRIORITY_MEDIUM = 2
ActivityBase.PRIORITY_HIGH = 1

ActivityBase.STATE_QUEUED = 1
ActivityBase.STATE_PENDING = 2
ActivityBase.STATE_AWAITING_RESPONSE = 3
ActivityBase.STATE_FAILED = 4
ActivityBase.STATE_SUCCEEDED = 5
ActivityBase.STATE_CANCELLED = 6 -- this is for when a queued request is cancelled

ActivityBase.ERROR_GUILD_SELECTION_FAILED = -1
ActivityBase.ERROR_OPERATION_TIMEOUT = -2
ActivityBase.ERROR_PAGE_ALREADY_LOADED = -3
ActivityBase.ERROR_USER_CANCELLED = -4 -- this is for when a user stops an already running request

local RESPONSE_TYPE_BY_ACTIVITY_TYPE = {
    [ActivityBase.ACTIVITY_TYPE_REQUEST_SEARCH] = TRADING_HOUSE_RESULT_SEARCH_PENDING,
    [ActivityBase.ACTIVITY_TYPE_REQUEST_NEWEST] = TRADING_HOUSE_RESULT_SEARCH_PENDING,
    [ActivityBase.ACTIVITY_TYPE_REQUEST_LISTINGS] = TRADING_HOUSE_RESULT_LISTINGS_PENDING,
    [ActivityBase.ACTIVITY_TYPE_PURCHASE_ITEM] = TRADING_HOUSE_RESULT_PURCHASE_PENDING,
    [ActivityBase.ACTIVITY_TYPE_POST_ITEM] = TRADING_HOUSE_RESULT_POST_PENDING,
    [ActivityBase.ACTIVITY_TYPE_CANCEL_ITEM] = TRADING_HOUSE_RESULT_CANCEL_SALE_PENDING,
}

function ActivityBase:New(...)
    local selector = ZO_Object.New(self)
    selector:Initialize(...)
    return selector
end

function ActivityBase:Initialize(tradingHouseWrapper, key, priority, guildId)
    self.tradingHouseWrapper = tradingHouseWrapper
    self.tradingHouse = self.tradingHouseWrapper.tradingHouse
    self.guildSelection = self.tradingHouseWrapper.guildSelection
    self.key = key
    self.priority = priority
    self.guildId = guildId or 0
    self.canExecute = false
    self.expectedResponseType = RESPONSE_TYPE_BY_ACTIVITY_TYPE[self:GetType()] -- TODO: handle response inside the requests?
    self.state = ActivityBase.STATE_QUEUED
end

function ActivityBase:ApplyGuildId(panel)
    local promise = Promise:New()
    if(self.guildSelection:ApplySelectedGuildId(self.guildId)) then
        self.state = ActivityBase.STATE_PENDING
        promise:Resolve(self)
    else
        self.state = ActivityBase.STATE_FAILED
        self.result = ActivityBase.ERROR_GUILD_SELECTION_FAILED
        promise:Reject(self)
    end
    panel:Refresh()
    return promise
end

function ActivityBase:GetType()
-- needs to be overwritten
end

function ActivityBase:CanExecute()
    return self.canExecute
end

function ActivityBase:DoExecute()
    return false
end

function ActivityBase:GetLogEntry()
    return ""
end

function ActivityBase:GetErrorMessage()
    return ""
end

function ActivityBase:GetKey()
    return self.key
end

function ActivityBase:Update()
-- overwrite to determine if it can execute
end

function ActivityBase:OnPendingPurchaseChanged()
-- overwrite if needed
end

function ActivityBase:OnAwaitingResponse(responseType, panel)
    if(responseType == self.expectedResponseType) then
        self.state = ActivityBase.STATE_AWAITING_RESPONSE
        panel:SetStatusText("Waiting for response") -- TODO translate
        panel:Refresh()
        return true
    end
    return false
end

function ActivityBase:OnTimeout(responseType, panel)
    if(responseType == self.expectedResponseType) then
        self.state = ActivityBase.STATE_FAILED
        self.result = ActivityBase.ERROR_OPERATION_TIMEOUT
        panel:SetStatusText("Request timed out") -- TODO translate
        panel:Refresh()
        if(self.responsePromise) then self.responsePromise:Reject(self) end
        return true
    end
    return false
end

function ActivityBase:OnResponse(responseType, result, panel)
    if(responseType == self.expectedResponseType and responseType ~= result) then -- TODO: the second condition is a hack to ignore the error that occurs the first time we request listings during a session. for some reason it sends an error where the errorCode is TRADING_HOUSE_RESULT_LISTINGS_PENDING which happens to be the same as the requestType in our handler
        self.result = result
        if(result == TRADING_HOUSE_RESULT_SUCCESS) then
            self.state = ActivityBase.STATE_SUCCEEDED
            panel:SetStatusText("Request finished") -- TODO translate
            panel:Refresh()
            if(self.responsePromise) then self.responsePromise:Resolve(self) end
        else
            self.state = ActivityBase.STATE_FAILED
            panel:SetStatusText("Request failed") -- TODO translate
            panel:Refresh()
            if(self.responsePromise) then self.responsePromise:Reject(self) end
        end
        return true
    end
    return false
end

function ActivityBase:OnSearchResults(guildId, numItems, page, hasMore)
    -- overwrite if needed
    return false
end

function ActivityBase:OnRemove()
    if(self.state == ActivityBase.STATE_QUEUED) then
        self.state = ActivityBase.STATE_CANCELLED
    elseif(self.state ~= ActivityBase.STATE_FAILED and self.state ~= ActivityBase.STATE_SUCCEEDED) then
        self.state = ActivityBase.STATE_FAILED
        self.result = ActivityBase.ERROR_USER_CANCELLED
        if(self.responsePromise) then self.responsePromise:Reject(self) end
    end
end

function ActivityBase.ByPriority(a, b)
    if(a.canExecute == b.canExecute) then
        if(a.priority == b.priority) then
            return a.guildId < b.guildId
        end
        return a.priority < b.priority
    end
    return a.canExecute
end
