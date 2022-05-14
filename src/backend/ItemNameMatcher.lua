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
            promise:Resolve({
                id = id,
                count = numResults
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
    end)
end

function ItemNameMatcher:MatchText(text)
    if not self.pendingMatch or self.pendingMatch.text ~= text then
        self:CancelPendingMatch()

        local promise = Promise:New()
        promise.text = text

        if self:IsSearchTextLongEnough(text) then
            self:SetRelevantFilters():Then()
            self.searchManager:PrepareActiveFilters():Then(function()
                promise.taskId = MatchTradingHouseItemNames(text)
            end)
        else
            promise:Reject(ItemNameMatcher.ERROR_INPUT_TOO_SHORT)
        end

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
