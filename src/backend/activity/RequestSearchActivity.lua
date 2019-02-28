local AGS = AwesomeGuildStore

local ActivityBase = AGS.class.ActivityBase
local SortOrderBase = AGS.class.SortOrderBase

local logger = AGS.internal.logger
local gettext = AGS.internal.gettext

local Promise = LibPromises
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

function RequestSearchActivity:PrepareFilters()
    local promise = Promise:New()

    local searchManager = self.searchManager
    local filterState = searchManager:GetActiveSearch():GetFilterState()
    local page = searchManager.searchPageHistory:GetNextPage(self.pendingGuildName, filterState)
    if(page) then
        local count = 0
        local filters = searchManager:GetActiveFilters()
        for _, filter in ipairs(filters) do
            if(filter:PrepareForSearch()) then
                count = count + 1
            end
        end

        self.pendingPage = page
        self.pendingFilterState = filterState

        if(count > 0) then
            logger:Info("Waiting for %d filters to prepare", count)
            local function OnFilterPrepared(filter)
                count = count - 1
                logger:Info("%s ready, %d filters left to prepare", filter:GetLabel(), count)
                if(count == 0) then
                    AGS:UnregisterCallback(AGS.callback.FILTER_PREPARED, OnFilterPrepared)
                    promise:Resolve(self)
                end
            end

            AGS:RegisterCallback(AGS.callback.FILTER_PREPARED, OnFilterPrepared)
        else
            promise:Resolve(self)
        end
    else
        self:SetState(ActivityBase.STATE_SUCCEEDED, ActivityBase.RESULT_PAGE_ALREADY_LOADED)
        promise:Resolve(self)
    end

    return promise
end

function RequestSearchActivity:RequestSearch()
    if(not self.responsePromise) then
        self.responsePromise = Promise:New()
        if(self.state ~= ActivityBase.STATE_SUCCEEDED) then
            ClearAllTradingHouseSearchTerms()

            local _, subcategory = self.searchManager:GetCurrentCategories()
            local filters = self.searchManager:GetActiveFilters()
            for _, filter in ipairs(filters) do
                if(not filter:IsLocal() and filter:CanFilter(subcategory)) then
                    filter:ApplyToSearch() -- TODO pass values from pending filter state
                end
            end

            ExecuteTradingHouseSearch(self.pendingPage, SortOrderBase.SORT_FIELD_TIME_LEFT, SortOrderBase.SORT_ORDER_DOWN) -- TODO use appropriate sort order
        else
            self.responsePromise:Resolve(self)
        end
    end
    return self.responsePromise
end

function RequestSearchActivity:DoExecute()
    return self:ApplyGuildId():Then(self.PrepareFilters):Then(self.RequestSearch)
end

local AUTO_SEARCH_RESULT_COUNT_THRESHOLD = 50 -- TODO: tweak value
function RequestSearchActivity:OnResponse(responseType, result)
    if(responseType == self.expectedResponseType) then
        if(result == TRADING_HOUSE_RESULT_SUCCESS and self.responsePromise) then
            self.numItems, self.page, self.hasMore = GetTradingHouseSearchResultsInfo()
            self:SetState(ActivityBase.STATE_SUCCEEDED, result)
            local hasAnyResultAlreadyStored = self.itemDatabase:Update(self.pendingGuildName, self.numItems)

            self:HandleSearchResultsReceived(hasAnyResultAlreadyStored)

            AGS.internal:FireCallbacks(AGS.callback.SEARCH_RESULTS_RECEIVED, self.pendingGuildName, self.numItems, self.page, self.hasMore)

            self.responsePromise:Resolve(self)
        else
            self:SetState(ActivityBase.STATE_FAILED, result)
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
        local prefix = ActivityBase.GetLogEntry(self)
        -- TRANSLATORS: log text shown to the user for each request of the search results. Placeholder is for the guild name
        self.logEntry = prefix .. zo_strformat(gettext("Request search results in <<1>>"), self.pendingGuildName)
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
