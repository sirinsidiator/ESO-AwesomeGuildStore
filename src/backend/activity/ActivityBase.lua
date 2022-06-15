local AGS = AwesomeGuildStore

local Promise = LibPromises

local logger = AGS.internal.logger

local ActivityBase = ZO_InitializingObject:Subclass()
AGS.class.ActivityBase = ActivityBase

ActivityBase.ACTIVITY_TYPE_STORE_STATE = 1
ActivityBase.ACTIVITY_TYPE_REQUEST_SEARCH = 2
ActivityBase.ACTIVITY_TYPE_REQUEST_NEWEST = 3
ActivityBase.ACTIVITY_TYPE_REQUEST_LISTINGS = 4
ActivityBase.ACTIVITY_TYPE_PURCHASE_ITEM = 5
ActivityBase.ACTIVITY_TYPE_POST_ITEM = 6
ActivityBase.ACTIVITY_TYPE_CANCEL_ITEM = 7
ActivityBase.ACTIVITY_TYPE_FETCH_GUILD_ITEMS = 8

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
ActivityBase.ERROR_RESPONSE_TIMEOUT = -3
ActivityBase.ERROR_USER_CANCELLED = -4 -- this is for when a user stops an already running request
ActivityBase.ERROR_TRADING_HOUSE_CLOSED = -5
ActivityBase.ERROR_INVALID_STATE = -6
ActivityBase.RESULT_PAGE_ALREADY_LOADED = -100
ActivityBase.RESULT_LISTINGS_ALREADY_LOADED = -101

ActivityBase.TOOLTIP_LINE_TEMPLATE = "%s: |cFFFFFF%s|r"

local RESPONSE_TYPE_BY_ACTIVITY_TYPE = { -- TODO: should be part of each activity
    [ActivityBase.ACTIVITY_TYPE_REQUEST_SEARCH] = TRADING_HOUSE_RESULT_SEARCH_PENDING,
    [ActivityBase.ACTIVITY_TYPE_REQUEST_NEWEST] = TRADING_HOUSE_RESULT_SEARCH_PENDING,
    [ActivityBase.ACTIVITY_TYPE_REQUEST_LISTINGS] = TRADING_HOUSE_RESULT_LISTINGS_PENDING,
    [ActivityBase.ACTIVITY_TYPE_PURCHASE_ITEM] = TRADING_HOUSE_RESULT_PURCHASE_PENDING,
    [ActivityBase.ACTIVITY_TYPE_POST_ITEM] = TRADING_HOUSE_RESULT_POST_PENDING,
    [ActivityBase.ACTIVITY_TYPE_CANCEL_ITEM] = TRADING_HOUSE_RESULT_CANCEL_SALE_PENDING,
}

local STATE_TO_STRING = { -- TODO translate
    [ActivityBase.STATE_QUEUED] = "STATE_QUEUED",
    [ActivityBase.STATE_PENDING] = "STATE_PENDING",
    [ActivityBase.STATE_AWAITING_RESPONSE] = "STATE_AWAITING_RESPONSE",
    [ActivityBase.STATE_FAILED] = "STATE_FAILED",
    [ActivityBase.STATE_SUCCEEDED] = "STATE_SUCCEEDED",
    [ActivityBase.STATE_CANCELLED] = "STATE_CANCELLED",
}

local FINISHED_STATES = {
    [ActivityBase.STATE_FAILED] = true,
    [ActivityBase.STATE_SUCCEEDED] = true,
    [ActivityBase.STATE_CANCELLED] = true,
}

local RESULT_IS_PENDING = {
    [TRADING_HOUSE_RESULT_CANCEL_SALE_PENDING] = true,
    [TRADING_HOUSE_RESULT_LISTINGS_PENDING] = true,
    [TRADING_HOUSE_RESULT_NAME_MATCH_PENDING] = true,
    [TRADING_HOUSE_RESULT_POST_PENDING] = true,
    [TRADING_HOUSE_RESULT_PURCHASE_PENDING] = true,
    [TRADING_HOUSE_RESULT_SEARCH_PENDING] = true,
}

local RESULT_TO_STRING = {
    [TRADING_HOUSE_RESULT_AWAITING_INITIAL_STATUS] = "TRADING_HOUSE_RESULT_AWAITING_INITIAL_STATUS",
    [TRADING_HOUSE_RESULT_CANCEL_SALE_PENDING] = "TRADING_HOUSE_RESULT_CANCEL_SALE_PENDING",
    [TRADING_HOUSE_RESULT_CANT_AFFORD_BUYPRICE] = "TRADING_HOUSE_RESULT_CANT_AFFORD_BUYPRICE",
    [TRADING_HOUSE_RESULT_CANT_AFFORD_POST_FEE] = "TRADING_HOUSE_RESULT_CANT_AFFORD_POST_FEE",
    [TRADING_HOUSE_RESULT_CANT_BUY_YOUR_OWN_POSTS] = "TRADING_HOUSE_RESULT_CANT_BUY_YOUR_OWN_POSTS",
    [TRADING_HOUSE_RESULT_CANT_POST_BOUND] = "TRADING_HOUSE_RESULT_CANT_POST_BOUND",
    [TRADING_HOUSE_RESULT_CANT_POST_FROM_THAT_BAG] = "TRADING_HOUSE_RESULT_CANT_POST_FROM_THAT_BAG",
    [TRADING_HOUSE_RESULT_CANT_POST_LOCKED] = "TRADING_HOUSE_RESULT_CANT_POST_LOCKED",
    [TRADING_HOUSE_RESULT_CANT_POST_STOLEN] = "TRADING_HOUSE_RESULT_CANT_POST_STOLEN",
    [TRADING_HOUSE_RESULT_CANT_SELL_FOR_FREE] = "TRADING_HOUSE_RESULT_CANT_SELL_FOR_FREE",
    [TRADING_HOUSE_RESULT_CANT_SELL_FOR_OVER_MAX_AMOUNT] = "TRADING_HOUSE_RESULT_CANT_SELL_FOR_OVER_MAX_AMOUNT",
    [TRADING_HOUSE_RESULT_CANT_SWITCH_GUILDS_WHILE_AWAITING_RESPONSE] = "TRADING_HOUSE_RESULT_CANT_SWITCH_GUILDS_WHILE_AWAITING_RESPONSE",
    [TRADING_HOUSE_RESULT_GUILD_TOO_SMALL] = "TRADING_HOUSE_RESULT_GUILD_TOO_SMALL",
    [TRADING_HOUSE_RESULT_INVALID_GUILD_ID] = "TRADING_HOUSE_RESULT_INVALID_GUILD_ID",
    [TRADING_HOUSE_RESULT_ITEM_NOT_FOUND] = "TRADING_HOUSE_RESULT_ITEM_NOT_FOUND",
    [TRADING_HOUSE_RESULT_LISTINGS_PENDING] = "TRADING_HOUSE_RESULT_LISTINGS_PENDING",
    [TRADING_HOUSE_RESULT_NAME_MATCH_PENDING] = "TRADING_HOUSE_RESULT_NAME_MATCH_PENDING",
    [TRADING_HOUSE_RESULT_NOT_A_MEMBER] = "TRADING_HOUSE_RESULT_NOT_A_MEMBER",
    [TRADING_HOUSE_RESULT_NOT_IN_A_GUILD] = "TRADING_HOUSE_RESULT_NOT_IN_A_GUILD",
    [TRADING_HOUSE_RESULT_NOT_OPEN] = "TRADING_HOUSE_RESULT_NOT_OPEN",
    [TRADING_HOUSE_RESULT_NO_NAME_SEARCH_DATA] = "TRADING_HOUSE_RESULT_NO_NAME_SEARCH_DATA",
    [TRADING_HOUSE_RESULT_NO_PERMISSION] = "TRADING_HOUSE_RESULT_NO_PERMISSION",
    [TRADING_HOUSE_RESULT_POST_PENDING] = "TRADING_HOUSE_RESULT_POST_PENDING",
    [TRADING_HOUSE_RESULT_PURCHASE_PENDING] = "TRADING_HOUSE_RESULT_PURCHASE_PENDING",
    [TRADING_HOUSE_RESULT_QUEUED_POST] = "TRADING_HOUSE_RESULT_QUEUED_POST",
    [TRADING_HOUSE_RESULT_SEARCH_PENDING] = "TRADING_HOUSE_RESULT_SEARCH_PENDING",
    [TRADING_HOUSE_RESULT_SEARCH_RATE_EXCEEDED] = "TRADING_HOUSE_RESULT_SEARCH_RATE_EXCEEDED",
    [TRADING_HOUSE_RESULT_SUCCESS] = "TRADING_HOUSE_RESULT_SUCCESS",
    [TRADING_HOUSE_RESULT_TOO_MANY_POSTS] = "TRADING_HOUSE_RESULT_TOO_MANY_POSTS",
    [ActivityBase.ERROR_GUILD_SELECTION_FAILED] = "ERROR_GUILD_SELECTION_FAILED",
    [ActivityBase.ERROR_OPERATION_TIMEOUT] = "ERROR_OPERATION_TIMEOUT",
    [ActivityBase.ERROR_RESPONSE_TIMEOUT] = "ERROR_RESPONSE_TIMEOUT",
    [ActivityBase.ERROR_USER_CANCELLED] = "ERROR_USER_CANCELLED",
    [ActivityBase.ERROR_TRADING_HOUSE_CLOSED] = "ERROR_TRADING_HOUSE_CLOSED",
    [ActivityBase.ERROR_INVALID_STATE] = "ERROR_INVALID_STATE",
    [ActivityBase.RESULT_PAGE_ALREADY_LOADED] = "RESULT_PAGE_ALREADY_LOADED",
    [ActivityBase.RESULT_LISTINGS_ALREADY_LOADED] = "RESULT_LISTINGS_ALREADY_LOADED",
}
ActivityBase.RESULT_TO_STRING = RESULT_TO_STRING

local startTime = GetTimeStamp() * 1000 - GetGameTimeMilliseconds()

function ActivityBase:Initialize(tradingHouseWrapper, key, priority, guildId)
    self.tradingHouseWrapper = tradingHouseWrapper
    self.tradingHouse = tradingHouseWrapper.tradingHouse
    self.guildSelection = tradingHouseWrapper.guildSelection
    self.key = key
    self.priority = priority
    self.guildId = guildId or 0
    self.canExecute = false
    self.expectedResponseType = RESPONSE_TYPE_BY_ACTIVITY_TYPE[self:GetType()] -- TODO: handle response inside the requests?
    self.state = ActivityBase.STATE_QUEUED
    self.creationTime = GetGameTimeMilliseconds() + startTime
    self.updateTime = self.creationTime
end

function ActivityBase:SetState(state, result)
    self.updateTime = GetGameTimeMilliseconds() + startTime
    if self.state == ActivityBase.STATE_QUEUED and state ~= self.state and not FINISHED_STATES[state] then
        self.executionTime = self.updateTime
    end
    logger:Verbose("set activity state")
    local oldState = self.state
    self.state = state
    local oldResult = self.result
    self.result = result
    self.logEntry = nil -- force it to refresh
    AGS.internal:FireCallbacks(AGS.callback.ACTIVITY_STATE_CHANGED, state, result, oldState, oldResult)
end

function ActivityBase:ApplyGuildId()
    local promise = Promise:New()
    if self.guildSelection:ApplySelectedGuildId(self.guildId) then
        self:SetState(ActivityBase.STATE_PENDING)
        promise:Resolve(self)
    else
        self:SetState(ActivityBase.STATE_FAILED, ActivityBase.ERROR_GUILD_SELECTION_FAILED)
        promise:Reject(self)
    end
    return promise
end

function ActivityBase:GetType()
-- needs to be overwritten
end

function ActivityBase:GetState()
    return self.state
end

function ActivityBase:CanExecute()
    return self.canExecute
end

function ActivityBase:DoExecute()
    return false
end

function ActivityBase:GetFormattedTime()
    return os.date("[%T] ", math.floor(self.updateTime / 1000))
end

function ActivityBase:GetLogEntry()
    return ("missing (%s)"):format(self.key)
end

function ActivityBase:GetErrorMessage()
    return ("missing (%s)"):format(self.key)
end

function ActivityBase:AddTooltipText(output)
    output[#output + 1] = ActivityBase.TOOLTIP_LINE_TEMPLATE:format("Key", self.key) -- TODO translate
    output[#output + 1] = ActivityBase.TOOLTIP_LINE_TEMPLATE:format("State", STATE_TO_STRING[self.state] or tostring(self.state))
    output[#output + 1] = ActivityBase.TOOLTIP_LINE_TEMPLATE:format("Created", os.date("%T", math.floor(self.creationTime / 1000)))
    output[#output + 1] = ActivityBase.TOOLTIP_LINE_TEMPLATE:format("Updated", os.date("%T", math.floor(self.updateTime / 1000)))

    local queueTime, executionTime = self:GetFormattedDuration()
    output[#output + 1] = ActivityBase.TOOLTIP_LINE_TEMPLATE:format("Queue Time", queueTime)

    if self.executionTime then
        output[#output + 1] = ActivityBase.TOOLTIP_LINE_TEMPLATE:format("Execution Time", executionTime)
    elseif not FINISHED_STATES[self.state] then
        output[#output + 1] = ActivityBase.TOOLTIP_LINE_TEMPLATE:format("Cooldown", executionTime)
    end

    if self.result then
        output[#output + 1] = ActivityBase.TOOLTIP_LINE_TEMPLATE:format("Result", RESULT_TO_STRING[self.result] or tostring(self.result))
    end
end

local function FormatTimeMs(time)
    if time then
        time = ZO_CommaDelimitDecimalNumber(time)
    else
        time = "-"
    end
    return zo_strformat("<<1>> ms", time)
end

function ActivityBase:GetFormattedDuration()
    local updateTime, queueTime, executionTime
    local isFinished = FINISHED_STATES[self.state]

    if isFinished then
        updateTime = self.updateTime
    else
        updateTime = GetGameTimeMilliseconds() + startTime
    end

    if self.executionTime then
        queueTime = self.executionTime - self.creationTime
        executionTime = updateTime - self.executionTime
    else
        queueTime = updateTime - self.creationTime
        if not isFinished then
            executionTime = GetTradingHouseCooldownRemaining()
        end
    end
    return FormatTimeMs(queueTime), FormatTimeMs(executionTime)
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

function ActivityBase:GetExpectedResponseType()
    return self.expectedResponseType
end

function ActivityBase:OnAwaitingResponse(result)
    self:SetState(ActivityBase.STATE_AWAITING_RESPONSE, result)
end

function ActivityBase:OnResponse(result)
    if result == TRADING_HOUSE_RESULT_SUCCESS then
        self:SetState(ActivityBase.STATE_SUCCEEDED, result)
        if self.responsePromise then self.responsePromise:Resolve(self) end
    elseif RESULT_IS_PENDING[result] then
        self:SetState(ActivityBase.STATE_PENDING, result)
    else
        self:OnError(result)
    end
end

function ActivityBase:OnError(reason)
    self:SetState(ActivityBase.STATE_FAILED, reason)
    if self.responsePromise then self.responsePromise:Reject(self) end
end

function ActivityBase:OnSearchResults(guildId, numItems, page, hasMore)
    -- overwrite if needed
    return false
end

function ActivityBase:OnRemove(reason)
    if self.CleanUp then
        self.CleanUp()
    end

    if self.state == ActivityBase.STATE_QUEUED then
        self:SetState(ActivityBase.STATE_CANCELLED, reason or self.result)
    elseif self.state ~= ActivityBase.STATE_FAILED and self.state ~= ActivityBase.STATE_SUCCEEDED then
        self:SetState(ActivityBase.STATE_FAILED, reason or ActivityBase.ERROR_USER_CANCELLED)
        if self.responsePromise then self.responsePromise:Reject(self) end
    end
end

function ActivityBase.ByPriority(a, b)
    if a.canExecute == b.canExecute then
        if a.priority == b.priority then
            return a.guildId < b.guildId
        end
        return a.priority < b.priority
    end
    return a.canExecute
end
