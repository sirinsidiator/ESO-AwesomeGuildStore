local AGS = AwesomeGuildStore

local FilterRequest = AGS.class.FilterRequest

local logger = AGS.internal.logger
local RegisterForEvent = AGS.internal.RegisterForEvent

local Promise = LibPromises

local ItemNameMatcher = ZO_InitializingObject:Subclass()
AGS.class.ItemNameMatcher = ItemNameMatcher

ItemNameMatcher.ERROR_INPUT_TOO_SHORT = -1
ItemNameMatcher.ERROR_TASK_CANCELLED = -2

ItemNameMatcher.GetErrorMessage = function(code)
    if code == ItemNameMatcher.ERROR_INPUT_TOO_SHORT then
        return "Input was too short"
    elseif code == ItemNameMatcher.ERROR_TASK_CANCELLED then
        return "Task was cancelled"
    end
    return "Unhandled error code (" .. tostring(code) .. ")"
end

function ItemNameMatcher:Initialize(searchManager)
    self.searchManager = searchManager

    RegisterForEvent(EVENT_MATCH_TRADING_HOUSE_ITEM_NAMES_COMPLETE, function(_, id, numResults)
        local promise = self.pendingMatch
        if promise and promise.taskId == id then
            local names = {}
            local hashes = {}
            for i = 1, numResults do
                local name, hash = GetMatchTradingHouseItemNamesResult(id, i)
                names[i] = name
                hashes[i] = hash
            end
            promise:Resolve({
                id = id,
                count = numResults,
                names = names,
                hashes = hashes,
            })
        end
    end)
end

function ItemNameMatcher:IsSearchTextLongEnough(text)
    local length = ZoUTF8StringLength(text)
    return length >= GetMinLettersInTradingHouseItemNameForCurrentLanguage()
end

function ItemNameMatcher:SetRelevantFilters()
    local filterState = self.searchManager:GetActiveSearch():GetFilterState()
    return self.searchManager:PrepareActiveFilters(filterState, true):Then(function(activeFilters)
        self.appliedValues = FilterRequest:New(filterState, activeFilters)
        self.appliedValues:Apply(activeFilters)
        return self
    end)
end

function ItemNameMatcher:PrepareActiveFilters()
    return self.searchManager:PrepareActiveFilters():Then(function() return self end)
end

function ItemNameMatcher:MatchText(text)
    if not self.pendingMatch or self.pendingMatch.text ~= text then
        self:CancelPendingMatch()

        local promise
        if self:IsSearchTextLongEnough(text) then
            promise = self:SetRelevantFilters():Then(self.PrepareActiveFilters):Then(function()
                promise.taskId = MatchTradingHouseItemNames(text)
                -- promise is resolved in the event handler above
            end)
        else
            promise = Promise:New()
            promise:Reject(ItemNameMatcher.ERROR_INPUT_TOO_SHORT)
        end

        promise.text = text
        self.pendingMatch = promise
        return promise
    else
        return self.pendingMatch
    end
end

function ItemNameMatcher:CancelPendingMatch()
    local promise = self.pendingMatch
    if not promise or not promise.taskId or promise.value ~= nil then return end
    CancelMatchTradingHouseItemNames(promise.taskId)
    promise:Reject(ItemNameMatcher.ERROR_TASK_CANCELLED)
end
