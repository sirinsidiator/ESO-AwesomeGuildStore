local AGS = AwesomeGuildStore

local RegisterForEvent = AGS.internal.RegisterForEvent

local Promise = LibPromises

local MIN_LETTERS = GetMinLettersInTradingHouseItemNameForCurrentLanguage()

local ItemNameMatcher = ZO_Object:Subclass()
AGS.class.ItemNameMatcher = ItemNameMatcher

ItemNameMatcher.ERROR_INPUT_TOO_SHORT = -1
ItemNameMatcher.ERROR_TASK_CANCELLED = -2
ItemNameMatcher.ERROR_NO_MATCHES = -3

function ItemNameMatcher:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function ItemNameMatcher:Initialize()
    RegisterForEvent(EVENT_MATCH_TRADING_HOUSE_ITEM_NAMES_COMPLETE, function(_, id, numResults)
        local promise = self.pendingMatch
        if(promise and promise.taskId == id) then
            self.pendingMatch = nil
            if(numResults > 0) then
                local hashes = {}
                for i = 1, numResults do
                    local _, hash = GetMatchTradingHouseItemNamesResult(id, i)
                    hashes[#hashes + 1] = hash
                end
                promise:Resolve(hashes)
            else
                promise:Reject(ItemNameMatcher.ERROR_NO_MATCHES)
            end
        end
    end)
end

function ItemNameMatcher:MatchItemLink(itemLink)
    local text = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(itemLink))
    return self:MatchText(text)
end

function ItemNameMatcher:MatchText(text)
    local promise = Promise:New()

    self:CancelPendingMatch()

    if(ZoUTF8StringLength(text) > MIN_LETTERS) then
        promise.text = text
        promise.taskId = MatchTradingHouseItemNames(text)
        self.pendingMatch = promise
    else
        promise:Reject(ItemNameMatcher.ERROR_INPUT_TOO_SHORT)
    end

    return promise
end

function ItemNameMatcher:CancelPendingMatch()
    local promise = self.pendingMatch
    if(promise) then
        CancelMatchTradingHouseItemNames(promise.taskId)
        promise:Reject(ItemNameMatcher.ERROR_TASK_CANCELLED)
    end
end
