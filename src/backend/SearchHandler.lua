local AGS = AwesomeGuildStore

local logger = AGS.internal.logger

local SearchHandler = ZO_Object:Subclass()
AGS.class.SearchHandler = SearchHandler

function SearchHandler:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

local response2string = {
    [TRADING_HOUSE_RESULT_SUCCESS] = "SUCCESS",
    [TRADING_HOUSE_RESULT_NOT_OPEN] = "NOT_OPEN",
    [TRADING_HOUSE_RESULT_NOT_A_MEMBER] = "NOT_A_MEMBER",
    [TRADING_HOUSE_RESULT_TOO_MANY_POSTS] = "TOO_MANY_POSTS",
    [TRADING_HOUSE_RESULT_POST_PENDING] = "POST_PENDING",
    [TRADING_HOUSE_RESULT_ITEM_NOT_FOUND] = "ITEM_NOT_FOUND",
    [TRADING_HOUSE_RESULT_CANT_POST_BOUND] = "CANT_POST_BOUND",
    [TRADING_HOUSE_RESULT_CANT_AFFORD_POST_FEE] = "CANT_AFFORD_POST_FEE",
    [TRADING_HOUSE_RESULT_SEARCH_RATE_EXCEEDED] = "SEARCH_RATE_EXCEEDED",
    [TRADING_HOUSE_RESULT_CAN_ONLY_POST_FROM_BACKPACK] = "CAN_ONLY_POST_FROM_BACKPACK",
    [TRADING_HOUSE_RESULT_INVALID_GUILD_ID] = "INVALID_GUILD_ID",
    [TRADING_HOUSE_RESULT_NO_PERMISSION] = "NO_PERMISSION",
    [TRADING_HOUSE_RESULT_GUILD_TOO_SMALL] = "GUILD_TOO_SMALL",
    [TRADING_HOUSE_RESULT_CANT_AFFORD_BUYPRICE] = "CANT_AFFORD_BUYPRICE",
    [TRADING_HOUSE_RESULT_SEARCH_PENDING] = "SEARCH_PENDING",
    [TRADING_HOUSE_RESULT_LISTINGS_PENDING] = "LISTINGS_PENDING",
    [TRADING_HOUSE_RESULT_CANT_SWITCH_GUILDS_WHILE_AWAITING_RESPONSE] = "CANT_SWITCH_GUILDS_WHILE_AWAITING_RESPONSE",
    [TRADING_HOUSE_RESULT_AWAITING_INITIAL_STATUS] = "AWAITING_INITIAL_STATUS",
    [TRADING_HOUSE_RESULT_PURCHASE_PENDING] = "PURCHASE_PENDING",
    [TRADING_HOUSE_RESULT_CANT_BUY_YOUR_OWN_POSTS] = "CANT_BUY_YOUR_OWN_POSTS",
    [TRADING_HOUSE_RESULT_CANCEL_SALE_PENDING] = "CANCEL_SALE_PENDING",
    [TRADING_HOUSE_RESULT_CANT_SELL_FOR_FREE] = "CANT_SELL_FOR_FREE",
    [TRADING_HOUSE_RESULT_CANT_SELL_FOR_OVER_MAX_AMOUNT] = "CANT_SELL_FOR_OVER_MAX_AMOUNT",
    [TRADING_HOUSE_RESULT_CANT_POST_STOLEN] = "CANT_POST_STOLEN",
}
EVENT_MANAGER:RegisterForEvent("AGS_TEST", EVENT_TRADING_HOUSE_AWAITING_RESPONSE, function(_, responseType)
    logger:Debug(string.format("AWAITING_RESPONSE(%s=%s)", tostring(responseType), response2string[responseType]))
    -- TODO: notify that search is pending?
end)
EVENT_MANAGER:RegisterForEvent("AGS_TEST", EVENT_TRADING_HOUSE_OPERATION_TIME_OUT, function(_, responseType)
    logger:Debug(string.format("OPERATION_TIME_OUT(%s=%s)", tostring(responseType), response2string[responseType]))
    -- TODO: reject?
end)
EVENT_MANAGER:RegisterForEvent("AGS_TEST", EVENT_TRADING_HOUSE_ERROR, function(_, errorCode)
    logger:Debug(string.format("ERROR(%s=%s)", tostring(errorCode), response2string[errorCode]))
    -- TODO: reject?
end)
EVENT_MANAGER:RegisterForEvent("AGS_TEST", EVENT_TRADING_HOUSE_RESPONSE_RECEIVED, function(_, responseType, result)
    logger:Debug(string.format("RESPONSE_RECEIVED(%s=%s, %s=%s)", tostring(responseType), response2string[responseType], tostring(result), response2string[result]))
    -- TODO: reject/resolve?
end)
EVENT_MANAGER:RegisterForEvent("AGS_TEST", EVENT_TRADING_HOUSE_SEARCH_COOLDOWN_UPDATE, function(_, cooldown)
    if(cooldown == 0) then
        logger:Debug(string.format("SEARCH_COOLDOWN_UPDATE(%s)", tostring(cooldown)))
    end
end)
EVENT_MANAGER:RegisterForEvent("AGS_TEST", EVENT_TRADING_HOUSE_SEARCH_RESULTS_RECEIVED, function(_, guildId, numItems, page, hasMore)
    logger:Debug(string.format("SEARCH_RESULTS_RECEIVED(%s=%s, %s, %s, %s)", tostring(guildId), GetGuildName(guildId), tostring(numItems), tostring(page), tostring(hasMore)))
    -- TODO: resolve
end)
EVENT_MANAGER:RegisterForEvent("AGS_TEST", EVENT_TRADING_HOUSE_STATUS_RECEIVED, function(_)
    logger:Debug(string.format("STATUS_RECEIVED"))
end)
EVENT_MANAGER:RegisterForEvent("AGS_TEST", EVENT_TRADING_HOUSE_CONFIRM_ITEM_PURCHASE, function(_, index)
    logger:Debug(string.format("CONFIRM_ITEM_PURCHASE(%s)", tostring(index)))
end)
EVENT_MANAGER:RegisterForEvent("AGS_TEST", EVENT_TRADING_HOUSE_PENDING_ITEM_UPDATE, function(_, index, pending)
    logger:Debug(string.format("PENDING_ITEM_UPDATE(%s, %s)", tostring(index), tostring(pending)))
end)
EVENT_MANAGER:RegisterForEvent("AGS_TEST", EVENT_OPEN_TRADING_HOUSE, function(_)
    logger:Debug(string.format("OPEN_TRADING_HOUSE"))
end)
EVENT_MANAGER:RegisterForEvent("AGS_TEST", EVENT_CLOSE_TRADING_HOUSE, function(_)
    logger:Debug(string.format("CLOSE_TRADING_HOUSE"))
end)
ZO_PreHook("ExecuteTradingHouseSearch", function(page, sortField, sortAscending)
    logger:Debug(string.format("ExecuteTradingHouseSearch(%s, %s, %s)", tostring(page), tostring(sortField), tostring(sortAscending)))
end)

function SearchHandler:Initialize(tradingHouseWrapper, searchManager)
end

function SearchHandler:DoSearch()
    -- reject early when search is in progress or still on cooldown

    -- create setter for SelectTradingHouseGuildId(guildId) (could actually rework the guild selector to do this)
    local promise = Promise:New()
    if(self.currentSearch) then
        promise:Reject(REASON_SEARCH_PENDING)
        return
    elseif(self:IsOnCooldown()) then
        promise:Reject(REASON_SEARCH_COOLDOWN)
        return
    end

    self.currentSearch = promise
    return promise
    -- resolve on results received and integrated into item database
    -- reject on error or timeout
    -- return promise
end
