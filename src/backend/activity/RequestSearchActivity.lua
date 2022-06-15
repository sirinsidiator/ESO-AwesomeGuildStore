local AGS = AwesomeGuildStore

local ActivityBase = AGS.class.ActivityBase
local FilterRequest = AGS.class.FilterRequest

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
end

function RequestSearchActivity:Update()
    self.canExecute = self.tradingHouseWrapper:IsConnected() and (GetTradingHouseCooldownRemaining() == 0)
end

function RequestSearchActivity:PrepareFilters()
    local promise = Promise:New()

    local searchManager = self.searchManager
    local filterState = searchManager:GetActiveSearch():GetFilterState()
    local page = searchManager.searchPageHistory:GetNextPage(self.guildId, filterState)
    self.pendingPage = page
    self.pendingFilterState = filterState

    if page then
        searchManager:PrepareActiveFilters(filterState):Then(function(activeFilters)
            self.appliedValues = FilterRequest:New(filterState, activeFilters)
            promise:Resolve(self)
        end)
    else
        self:SetState(ActivityBase.STATE_SUCCEEDED, ActivityBase.RESULT_PAGE_ALREADY_LOADED)
        promise:Resolve(self)
    end

    return promise
end

function RequestSearchActivity:RequestSearch()
    if not self.responsePromise then
        self.responsePromise = Promise:New()
        if self.state ~= ActivityBase.STATE_SUCCEEDED then
            self.appliedValues:Apply()
            ExecuteTradingHouseSearch(self.pendingPage, self.appliedValues.sortField, self.appliedValues.sortOrder)
        else
            self.responsePromise:Resolve(self)
        end
    end
    return self.responsePromise
end

function RequestSearchActivity:DoExecute()
    logger:Debug("Execute RequestSearchActivity")
    return self:ApplyGuildId():Then(self.PrepareFilters):Then(self.RequestSearch)
end

function RequestSearchActivity:OnResponse(result)
    if result == TRADING_HOUSE_RESULT_SUCCESS then
        self.numItems, self.page, self.hasMore = GetTradingHouseSearchResultsInfo()
        local hasAnyResultAlreadyStored = self.itemDatabase:Update(self.guildId, self.pendingGuildName, self.numItems)

        self:HandleSearchResultsReceived(hasAnyResultAlreadyStored)

        AGS.internal:FireCallbacks(AGS.callback.SEARCH_RESULTS_RECEIVED, self.pendingGuildName, self.numItems, self.page, self.hasMore, self.guildId)
    end
    ActivityBase.OnResponse(self, result)
end

function RequestSearchActivity:HandleSearchResultsReceived(hasAnyResultAlreadyStored)
    if self.hasMore then
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
    if not self.logEntry then -- TODO: show filter state too
        if self.pendingFilterState and self.pendingPage then
            local category, subcategory = self.pendingFilterState:GetPendingCategories()
            local categoryLabel = category.label
            if not subcategory.isDefault then
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
    if self.numItems then -- TODO translate
        output[#output + 1] = ActivityBase.TOOLTIP_LINE_TEMPLATE:format("Item Count", tostring(self.numItems))
    end
    if self.page then
        output[#output + 1] = ActivityBase.TOOLTIP_LINE_TEMPLATE:format("Page", tostring(self.page + 1)) -- pages are zero based
    end
    if self.hasMore ~= nil then
        output[#output + 1] = ActivityBase.TOOLTIP_LINE_TEMPLATE:format("Last Page", tostring(not self.hasMore))
    end
end

function RequestSearchActivity:GetType()
    return ActivityBase.ACTIVITY_TYPE_REQUEST_SEARCH
end

function RequestSearchActivity.CreateKey(guildId)
    return sformat("%d_%s", ActivityBase.ACTIVITY_TYPE_REQUEST_SEARCH, guildId)
end
