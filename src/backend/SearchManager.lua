local AGS = AwesomeGuildStore

local logger = AGS.internal.logger
local RegisterForEvent = AGS.internal.RegisterForEvent

local ActivityBase = AGS.class.ActivityBase
local SearchState = AGS.class.SearchState

local FILTER_UPDATE_DELAY = 0 -- TODO do we even need this? check with profiler
local AUTO_SEARCH_RESULT_COUNT_THRESHOLD = 20
local SILENT = true
local REQUIRES_FULL_UPDATE = true

local SearchManager = ZO_Object:Subclass()
AGS.class.SearchManager = SearchManager

function SearchManager:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function SearchManager:Initialize(tradingHouseWrapper, saveData)
    self.tradingHouseWrapper = tradingHouseWrapper
    self.activityManager = tradingHouseWrapper.activityManager
    self.itemDatabase = tradingHouseWrapper.itemDatabase
    self.searchPageHistory = AGS.class.SearchPageHistory:New()
    if(not saveData) then
        saveData = {
            searches = {},
            activeIndex = nil
        }
    end

    self.availableFilters = {}
    self.activeFilters = {}
    self.saveData = saveData
    self.searches = {}
    self.categoryFilter = nil
    self.sortFilter = nil
    self.searchResults = {}
    self.hasMorePages = true

    self.search = tradingHouseWrapper.search
    self.search.DoSearch = function()
        self:RequestSearch()
    end

    ZO_PreHook(self.search, "LoadSearchItem", function(_, itemLink)
        self.isChangingFromSearchItem = true
        local search = self:GetOrCreateAutomaticSearch()
        search:SetLabel(zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(itemLink)))
        self:SetActiveSearch(search)
        for id, filter in pairs(self.availableFilters) do
            filter:SetFromItem(itemLink)
        end
        self.isChangingFromSearchItem = nil
        return true
    end)

    local function RequestRefreshResults()
        self:RequestResultUpdate()
    end

    self.requestNewestInterval = nil

    AGS:RegisterCallback(AGS.callback.FILTER_UPDATE, RequestRefreshResults)
    AGS:RegisterCallback(AGS.callback.GUILD_SELECTION_CHANGED, function(guildData)
        self.activityManager:CancelRequestNewest()
        local guildId = guildData.guildId
        if(not self.itemDatabase:HasGuildSpecificItems(guildId)) then
            self.activityManager:FetchGuildItems(guildId)
        else
            RequestRefreshResults()
        end
    end)
    AGS:RegisterCallback(AGS.callback.ITEM_DATABASE_UPDATE, function(itemDatabase, guildId, hasAnyResultAlreadyStored)
        if(hasAnyResultAlreadyStored == nil) then
            RequestRefreshResults()
        end
    end)
    AGS:RegisterCallback(AGS.callback.CURRENT_ACTIVITY_CHANGED, function(currentActivity, previousActivity)
        if(not currentActivity and previousActivity:GetState() == ActivityBase.STATE_SUCCEEDED) then
            local type = previousActivity:GetType()
            if(type == ActivityBase.ACTIVITY_TYPE_REQUEST_SEARCH) then
                RequestRefreshResults()
            elseif(type == ActivityBase.ACTIVITY_TYPE_REQUEST_NEWEST) then
                RequestRefreshResults()
                self:RequestNewest()
            end
        end
    end)
    AGS:RegisterCallback(AGS.callback.STORE_TAB_CHANGED, function(oldTab, newTab)
        if(newTab == tradingHouseWrapper.searchTab) then
            RequestRefreshResults()
        end
    end)

    AGS:RegisterCallback(AGS.callback.SELECTED_SEARCH_CHANGED, function()
        self:UpdateAttachedFilters()
    end)

    AGS:RegisterCallback(AGS.callback.SEARCH_RESULT_UPDATE, function(searchResults, hasMorePages)
        if(hasMorePages and self:IsResultCountBelowAutoSearchThreshold(#searchResults)) then
            self:RequestSearch()
        else
            self:RequestNewest()
        end
    end)

    AGS:RegisterCallback(AGS.callback.ITEM_POSTED, function(guildId, itemLink, price, stackCount)
        self.searchPageHistory:ResetRequestNewestCooldown(guildId)
    end)
end

function SearchManager:SetCategoryFilter(categoryFilter)
    self.categoryFilter = categoryFilter
end

function SearchManager:GetCategoryFilter()
    return self.categoryFilter
end

function SearchManager:SetSortFilter(sortFilter)
    self.sortFilter = sortFilter
end

function SearchManager:GetSortFilter()
    return self.sortFilter
end

function SearchManager:OnFiltersInitialized()
    local saveData = self.saveData
    for i = 1, #saveData.searches do
        self.searches[i] = SearchState:New(self, saveData.searches[i])
    end
    if(#self.searches == 0) then
        self:GetOrCreateAutomaticSearch()
    end
    if(not saveData.activeIndex or not self.searches[saveData.activeIndex]) then
        saveData.activeIndex = 1
    end
    self.activeSearch = self.searches[saveData.activeIndex]
    self.activeSearch:Apply()

    AGS:RegisterCallback(AGS.callback.FILTER_VALUE_CHANGED, function(id)
        local filter = self.availableFilters[id]
        if(filter == self.categoryFilter) then
            self:UpdateAttachedFilters(SILENT)
        end
        self.activeSearch:HandleFilterChanged(self.availableFilters[id], self.isChangingFromSearchItem)
        self:RequestFilterUpdate()
    end)

    AGS:RegisterCallback(AGS.callback.FILTER_ACTIVE_CHANGED, function(filter)
        self.activeSearch:HandleFilterChanged(filter)
    end)
end

function SearchManager:GetSaveData()
    return self.saveData
end

function SearchManager:GetCurrentCategories()
    return self.categoryFilter:GetCurrentCategories()
end

function SearchManager:RegisterFilter(filter)
    local filterId = filter:GetId()
    assert(not self.availableFilters[filterId], "Filter is already registered")
    self.availableFilters[filterId] = filter
end

function SearchManager:GetFilter(filterId)
    local filter = self.availableFilters[filterId]
    if(not filter) then
        logger:Debug("Filter with id %d is not registered", filterId)
    end
    return filter
end

function SearchManager:UpdateAttachedFilters(silent)
    local hasChanges = false
    local _, subcategory = self.categoryFilter:GetCurrentCategories()
    for filterId, filter in pairs(self.availableFilters) do
        local shouldAttach = (filter:IsPinned() or self.activeSearch:IsFilterActive(filterId)) and filter:CanFilter(subcategory)
        if(filter:IsAttached() ~= shouldAttach) then
            hasChanges = true
            if(shouldAttach) then
                self:AttachFilter(filterId)
            else
                self:DetachFilter(filterId)
            end
            if(not silent) then
                AGS.internal:FireCallbacks(AGS.callback.FILTER_ACTIVE_CHANGED, filter)
            end
        end
    end

    if(hasChanges) then
        self:RequestFilterUpdate()
    end
end

function SearchManager:AttachFilter(filterId)
    local filter = self:GetFilter(filterId)
    local _, subcategory = self.categoryFilter:GetCurrentCategories()
    if(filter and not filter:IsAttached() and filter:CanFilter(subcategory)) then
        filter:Attach()
        self.activeFilters[#self.activeFilters + 1] = filter
        return true
    end
    return false
end

function SearchManager:DetachFilter(filterId)
    local filter = self:GetFilter(filterId)
    if(filter and filter:IsAttached()) then
        for i = 1, #self.activeFilters do
            if(self.activeFilters[i] == filter) then
                filter:Detach()
                table.remove(self.activeFilters, i)
                return true
            end
        end
    end
    return false
end

function SearchManager:SetActiveSearch(search)
    if(search == self.activeSearch) then return false end

    local searches = self.searches
    local index = search:GetIndex()
    if(not searches[index] or search ~= searches[index]) then return false end

    self.activeSearch = search
    self.saveData.activeIndex = index
    search:Apply()
    return true
end

function SearchManager:GetActiveSearch()
    return self.activeSearch
end

function SearchManager:GetSearches()
    return self.searches
end

function SearchManager:AddSearch(saveData)
    local search = self:CreateSearch(saveData)
    AGS.internal:FireCallbacks(AGS.callback.SEARCH_LIST_CHANGED, REQUIRES_FULL_UPDATE)
    return search
end

function SearchManager:CreateSearch(saveData)
    local search = SearchState:New(self, saveData)
    local newIndex = #self.searches + 1
    search.sortIndex = newIndex -- this is so we do not have to refresh the list twice
    self.searches[newIndex] = search
    self.saveData.searches[newIndex] = search:GetSaveData()
    return search
end

function SearchManager:GetOrCreateAutomaticSearch()
    for i = 1, #self.searches do
        local search = self.searches[i]
        if search:IsAutomatic() then
            logger:Verbose("Found automatic search to reuse")
            search:Reset()
            search:SetAutomatic(true)
            return search
        end
    end

    logger:Verbose("Create new automatic search")
    local search = self:CreateSearch()
    search:SetAutomatic(true)
    AGS.internal:FireCallbacks(AGS.callback.SEARCH_LIST_CHANGED, REQUIRES_FULL_UPDATE)
    return search
end

function SearchManager:RemoveSearch(search)
    local searches = self.searches
    local index = search:GetIndex()
    if(not searches[index] or search ~= searches[index]) then return false end

    table.remove(searches, index)
    table.remove(self.saveData.searches, index)
    if(self.activeSearch == search) then
        local activeSearch
        if(#self.searches == 0) then
            activeSearch = self:GetOrCreateAutomaticSearch()
            self.saveData.activeIndex = 1
        else
            local index = math.min(index, #searches)
            activeSearch = self.searches[index]
            self.saveData.activeIndex = index
        end

        self.activeSearch = activeSearch
        activeSearch:Apply()
    elseif(self.saveData.activeIndex > index) then
        self.saveData.activeIndex = self.saveData.activeIndex - 1
    end

    AGS.internal:FireCallbacks(AGS.callback.SEARCH_LIST_CHANGED, REQUIRES_FULL_UPDATE)
    return true
end

function SearchManager:MoveSearch(search, newIndex)
    local searches = self.searches
    local index = search:GetIndex()
    if(not searches[index] or search ~= searches[index]) then return false end
    local savedSearches = self.saveData.searches

    table.insert(searches, newIndex, table.remove(searches, index))
    table.insert(savedSearches, newIndex, table.remove(savedSearches, index))

    if(self.activeSearch == search) then
        self.saveData.activeIndex = newIndex
    end

    AGS.internal:FireCallbacks(AGS.callback.SEARCH_LIST_CHANGED, REQUIRES_FULL_UPDATE)
    return true
end

function SearchManager:GetAvailableFilters()
    return self.availableFilters
end

function SearchManager:GetActiveFilters()
    return self.activeFilters
end

function SearchManager:UpdateSearchResults()
    ZO_ClearNumericallyIndexedTable(self.searchResults)

    local guildId = GetSelectedTradingHouseGuildId()
    local activeSearch = self:GetActiveSearch()
    local filterState = activeSearch:GetFilterState()
    local view = self.itemDatabase:GetFilteredView(guildId, filterState)
    ZO_ShallowTableCopy(view:GetItems(), self.searchResults)

    local page = self.searchPageHistory:GetNextPage(guildId, filterState)
    self.hasMorePages = (page ~= false)
    AGS.internal:FireCallbacks(AGS.callback.SEARCH_RESULT_UPDATE, self.searchResults, self.hasMorePages)
end

function SearchManager:RequestResultUpdate()
    if(self.resultUpdateCallback) then -- TODO use the delay call lib we started but never finished
        zo_removeCallLater(self.resultUpdateCallback)
    end
    self.resultUpdateCallback = zo_callLater(function()
        self.resultUpdateCallback = nil
        self:UpdateSearchResults()
    end, FILTER_UPDATE_DELAY)
end

function SearchManager:RequestFilterUpdate()
    if(self.updateCallback) then -- TODO use the delay call lib we started but never finished
        zo_removeCallLater(self.updateCallback)
    end
    self.updateCallback = zo_callLater(function()
        self.updateCallback = nil
        AGS.internal:FireCallbacks(AGS.callback.FILTER_UPDATE, self.activeFilters)
    end, FILTER_UPDATE_DELAY)
end

function SearchManager:SelectCategory(category)
    self.categoryFilter:SetCategory(category)
end

function SearchManager:SelectSubcategory(subcategory)
    self.categoryFilter:SetSubcategory(subcategory)
end

function SearchManager:GetNumVisibleResults()
    return #self.searchResults
end

function SearchManager:IsResultCountBelowAutoSearchThreshold(resultCount)
    return resultCount < AUTO_SEARCH_RESULT_COUNT_THRESHOLD
end

function SearchManager:HasMorePages()
    return self.hasMorePages
end

function SearchManager:GetSearchResults()
    return self.searchResults
end

function SearchManager:HasCurrentSearchMorePages(guildId)
    local currentState = self.activeSearch:GetFilterState()
    return self.searchPageHistory:GetNextPage(guildId, currentState) ~= false
end

function SearchManager:RequestSearch(ignoreResultCount)
    if(ignoreResultCount or self:IsResultCountBelowAutoSearchThreshold(#self.searchResults)) then
        local guildId = GetSelectedTradingHouseGuildId()
        if(self:HasCurrentSearchMorePages(guildId)) then
            if(self.activityManager:RequestSearchResults(guildId, ignoreResultCount)) then
                if(self.requestNewestInterval) then
                    zo_removeCallLater(self.requestNewestInterval)
                end

                logger:Verbose("Queued request search results")
                return true
            else
                logger:Verbose("Could not queue request search results") -- TODO notify users somehow
            end
        else
            logger:Verbose("No more pages for current state") -- TODO notify users somehow
        end
    end
    return false
end

function SearchManager:RequestNewest(ignoreCooldown)
    if(self.requestNewestInterval) then
        zo_removeCallLater(self.requestNewestInterval)
    end

    local guildId = GetSelectedTradingHouseGuildId()
    if(ignoreCooldown) then
        self.activityManager:RequestNewestResults(guildId)
        return
    end

    local canRequest, cooldown = self.searchPageHistory:CanRequestNewest(guildId)
    if(canRequest) then
        self.activityManager:RequestNewestResults(guildId)
    else
        self.requestNewestInterval = zo_callLater(function()
            self.requestNewestInterval = nil
            self.activityManager:RequestNewestResults(guildId)
        end, cooldown * 1000)
    end
end
