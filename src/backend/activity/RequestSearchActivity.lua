local AGS = AwesomeGuildStore

local ActivityBase = AGS.class.ActivityBase
local SortOrderBase = AGS.class.SortOrderBase

local logger = AGS.internal.logger
local gettext = AGS.internal.gettext

local CATEGORY_DEFINITION = AGS.data.CATEGORY_DEFINITION

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
    self.sortField = SortOrderBase.SORT_FIELD_UNIT_PRICE
    self.sortOrder = SortOrderBase.SORT_ORDER_UP
end

function RequestSearchActivity:Update()
    self.canExecute = (GetTradingHouseCooldownRemaining() == 0)
end

function RequestSearchActivity:PrepareFilters()
    local promise = Promise:New()

    local searchManager = self.searchManager
    local filterState = searchManager:GetActiveSearch():GetFilterState()
    local page = searchManager.searchPageHistory:GetNextPage(self.guildId, filterState)
    self.pendingPage = page
    self.pendingFilterState = filterState

    if(page) then
        local count = 0
        local subcategory = filterState:GetSubcategory()
        local filters = searchManager:GetActiveFilters()
        local activeFilters = {}
        for _, filter in ipairs(filters) do
            local id = filter:GetId()
            if(not filter:IsLocal() and filter:CanFilter(subcategory) and filterState:HasFilter(id)) then
                if(filter:PrepareForSearch(filterState:GetFilterValues(id))) then
                    count = count + 1
                end
                activeFilters[#activeFilters + 1] = filter
            end
        end
        self.activeFilters = activeFilters

        if(count > 0) then
            logger:Debug("Waiting for %d filters to prepare", count)
            local function OnFilterPrepared(filter)
                count = count - 1
                logger:Debug("%s ready, %d filters left to prepare", filter:GetLabel(), count)
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

function RequestSearchActivity:GetPendingCategories()
    local subcategory = self.pendingFilterState:GetSubcategory()
    return CATEGORY_DEFINITION[subcategory.category], subcategory
end

function RequestSearchActivity:SetFilterValues(type, ...)
    self.appliedValues[type] = {...}
end

function RequestSearchActivity:SetFilterRange(type, min, max)
    local values = self.appliedValues[type] or {}
    values.min = min
    values.max = max
    self.appliedValues[type] = values
end

function RequestSearchActivity:SetSortOrder(field, order)
    self.sortField = field
    self.sortOrder = order
end

function RequestSearchActivity:RequestSearch()
    if(not self.responsePromise) then
        self.responsePromise = Promise:New()
        if(self.state ~= ActivityBase.STATE_SUCCEEDED) then
            self.appliedValues = {}
            ClearAllTradingHouseSearchTerms()

            local filters = self.activeFilters
            for _, filter in ipairs(filters) do
                filter:ApplyToSearch(self)
            end

            for type, values in pairs(self.appliedValues) do
                if(values.min) then
                    SetTradingHouseFilterRange(type, values.min, values.max)
                else
                    SetTradingHouseFilter(type, unpack(values))
                end
            end

            ExecuteTradingHouseSearch(self.pendingPage, self.sortField, self.sortOrder)
        else
            self.responsePromise:Resolve(self)
        end
    end
    return self.responsePromise
end

function RequestSearchActivity:DoExecute()
    return self:ApplyGuildId():Then(self.PrepareFilters):Then(self.RequestSearch)
end

function RequestSearchActivity:OnResponse(responseType, result)
    if(responseType == self.expectedResponseType) then
        if(result == TRADING_HOUSE_RESULT_SUCCESS and self.responsePromise) then
            self.numItems, self.page, self.hasMore = GetTradingHouseSearchResultsInfo()
            self:SetState(ActivityBase.STATE_SUCCEEDED, result)
            local hasAnyResultAlreadyStored = self.itemDatabase:Update(self.guildId, self.pendingGuildName, self.numItems)

            self:HandleSearchResultsReceived(hasAnyResultAlreadyStored)

            AGS.internal:FireCallbacks(AGS.callback.SEARCH_RESULTS_RECEIVED, self.pendingGuildName, self.numItems, self.page, self.hasMore, self.guildId)

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
        self.searchManager.searchPageHistory:SetHighestSearchedPage(self.guildId, self.pendingFilterState, self.page)
    else
        self.searchManager.searchPageHistory:SetStateHasNoMorePages(self.guildId, self.pendingFilterState)
    end
end

function RequestSearchActivity:GetErrorMessage()
    -- TRANSLATORS: error text shown to the user when search results could not be requested
    return gettext("Could not request search results")
end

function RequestSearchActivity:GetLogEntry()
    if(not self.logEntry) then -- TODO: show filter state too
        if(self.pendingFilterState and self.pendingPage) then
            local category, subcategory = self:GetPendingCategories()
            local categoryLabel = category.label
            if(not subcategory.isDefault) then
                categoryLabel = string.format("%s > %s", category.label, subcategory.label)
            end
            -- TRANSLATORS: log text shown to the user for an executed request of the search results. Placeholders are for the page, category and guild name
            self.logEntry = gettext("Request page <<1>> of <<2>> in <<3>>", self.pendingPage + 1, categoryLabel, self.pendingGuildName)
        else
            -- TRANSLATORS: log text shown to the user for a queued request of the search results. Placeholder is for the guild name
            self.logEntry = gettext("Request search results in <<1>>", self.pendingGuildName)
        end
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
