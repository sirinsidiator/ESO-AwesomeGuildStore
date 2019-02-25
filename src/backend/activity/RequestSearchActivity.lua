local AGS = AwesomeGuildStore

local ActivityBase = AGS.class.ActivityBase
local SortOrderBase = AGS.class.SortOrderBase

local logger = AGS.internal.logger
local gettext = AGS.internal.gettext

local Promise = LibStub("LibPromises")
local sformat = string.format


local RequestSearchActivity = ActivityBase:Subclass()
AGS.class.RequestSearchActivity = RequestSearchActivity

function RequestSearchActivity:New(...)
    return ActivityBase.New(self, ...)
end

function RequestSearchActivity:Initialize(tradingHouseWrapper, guildId)
    local key = RequestSearchActivity.CreateKey(guildId)
    ActivityBase.Initialize(self, tradingHouseWrapper, key, ActivityBase.PRIORITY_MEDIUM, guildId)
    self.searchManager = tradingHouseWrapper.searchManager
    self.itemDatabase = tradingHouseWrapper.itemDatabase
    self.pendingGuildName = tradingHouseWrapper:GetTradingGuildName(guildId)
end

function RequestSearchActivity:Update()
    self.canExecute = (GetTradingHouseCooldownRemaining() == 0)
end

function RequestSearchActivity:RequestSearch()
    if(not self.responsePromise) then
        self.responsePromise = Promise:New()

        local searchManager = self.searchManager
        local filterState = searchManager:GetActiveSearch():GetFilterState()
        local page = searchManager.searchPageHistory:GetNextPage(self.pendingGuildName, filterState)
        if(page) then
            ClearAllTradingHouseSearchTerms()

            local filters = searchManager:GetActiveFilters()
            for _, filter in ipairs(filters) do
                if(not filter:IsLocal()) then
                    filter:ApplyToSearch()
                end
            end

            self.pendingFilterState = filterState

            ExecuteTradingHouseSearch(page, SortOrderBase.SORT_FIELD_TIME_LEFT, SortOrderBase.SORT_ORDER_DOWN) -- TODO
        else
            self.state = ActivityBase.STATE_SUCCEEDED
            self.result = ActivityBase.RESULT_PAGE_ALREADY_LOADED
            self.responsePromise:Resolve(self)
        end
    end
    return self.responsePromise
end

function RequestSearchActivity:DoExecute(panel)
    return self:ApplyGuildId(panel):Then(self.RequestSearch)
end

local AUTO_SEARCH_RESULT_COUNT_THRESHOLD = 50 -- TODO: tweak value
function RequestSearchActivity:OnResponse(responseType, result, panel)
    if(responseType == self.expectedResponseType) then
        self.result = result
        if(result == TRADING_HOUSE_RESULT_SUCCESS and self.responsePromise) then
            self.numItems, self.page, self.hasMore = GetTradingHouseSearchResultsInfo()
            self.state = ActivityBase.STATE_SUCCEEDED
            local hasAnyResultAlreadyStored = self.itemDatabase:Update(self.pendingGuildName, self.numItems)

            self:HandleSearchResultsReceived(hasAnyResultAlreadyStored)

            AGS.internal:FireCallbacks(AGS.callback.SEARCH_RESULTS_RECEIVED, self.pendingGuildName, self.numItems, self.page, self.hasMore)

            panel:SetStatusText("Request finished") -- TODO translate
            panel:Refresh()
            self.responsePromise:Resolve(self)
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

function RequestSearchActivity:HandleSearchResultsReceived(hasAnyResultAlreadyStored)
    if(self.hasMore) then
        self.searchManager.searchPageHistory:SetHighestSearchedPage(self.pendingGuildName, self.pendingFilterState, self.page)
    else
        self.searchManager.searchPageHistory:SetStateHasNoMorePages(self.pendingGuildName, self.pendingFilterState)
    end
end

function RequestSearchActivity:GetErrorMessage()
    -- TRANSLATORS: error text shown to the user when search results could not be requested
    return gettext("Could not request search results")
end

function RequestSearchActivity:GetLogEntry()
    if(not self.logEntry) then -- TODO: show filter state too
        -- TRANSLATORS: log text shown to the user for each request of the search results. Placeholder is for the guild name
        self.logEntry = zo_strformat(gettext("Request search results in <<1>>"), self.pendingGuildName)
    end
    return self.logEntry
end

function RequestSearchActivity:AddTooltipText(output)
    ActivityBase.AddTooltipText(self, output)
    if(self.numItems) then -- TODO translate
        output[#output + 1] = ActivityBase.TOOLTIP_LINE_TEMPLATE:format("Item Count", tostring(self.numItems))
    end
    if(self.page) then
        output[#output + 1] = ActivityBase.TOOLTIP_LINE_TEMPLATE:format("Page", tostring(self.page + 1)) -- pages are zero based
    end
    if(self.hasMore ~= nil) then
        output[#output + 1] = ActivityBase.TOOLTIP_LINE_TEMPLATE:format("Last Page", tostring(not self.hasMore))
    end
end

function RequestSearchActivity:GetType()
    return ActivityBase.ACTIVITY_TYPE_REQUEST_SEARCH
end

function RequestSearchActivity.CreateKey(guildId)
    return sformat("%d_%s", ActivityBase.ACTIVITY_TYPE_REQUEST_SEARCH, guildId)
end
