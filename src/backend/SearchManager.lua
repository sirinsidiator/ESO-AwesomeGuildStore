local AGS = AwesomeGuildStore

local logger = AGS.internal.logger
local RegisterForEvent = AGS.RegisterForEvent

local SearchState = AGS.SearchState
local ClearCallLater = AGS.ClearCallLater

local FILTER_UPDATE_DELAY = 0 -- TODO do we even need this? check with profiler
local FILTER_UPDATE_CALLBACK_NAME = "FilterUpdateRequest"
local SILENT = true
AGS.FILTER_UPDATE_CALLBACK_NAME = FILTER_UPDATE_CALLBACK_NAME -- TODO move somewhere else

local SearchManager = ZO_Object:Subclass()
AGS.SearchManager = SearchManager

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

    self.search = tradingHouseWrapper.search
    -- disable the internal filter system
    self.search:DisassociateWithSearchFeatures()
    self.search.features = {} -- TODO better way?
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
        self:AddSearch()
    end
    if(not saveData.activeIndex) then
        saveData.activeIndex = 1
    end
    self.activeSearch = self.searches[saveData.activeIndex]

    self.tradingHouseWrapper.tradingHouse.DoSearch = function() -- TODO
        self:RequestSearch()
    end

    RegisterForEvent(EVENT_TRADING_HOUSE_STATUS_RECEIVED, function()
        self:RequestSearch()
    end)

    self.activeSearch:Apply()

    AwesomeGuildStore:RegisterCallback("FilterValueChanged", function(id)
        local filter = self.availableFilters[id]
        if(filter == self.categoryFilter) then
            self:UpdateAttachedFilters(SILENT)
        end
        self.activeSearch:HandleFilterChanged(self.availableFilters[id])
        if(not self.activeSearch:IsApplying()) then
            self:RequestSearch()
        end
    end)

    AwesomeGuildStore:RegisterCallback("FilterActiveChanged", function(filter)
        self.activeSearch:HandleFilterChanged(filter)
        if(not self.activeSearch:IsApplying()) then
            self:RequestSearch()
        end
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
    filter:SetSearchManager(self)
    self.availableFilters[filterId] = filter
end

function SearchManager:GetFilter(filterId)
    local filter = self.availableFilters[filterId]
    if(not filter) then
        logger:Debug(string.format("filter with id %d is not registered", filterId))
    end
    return filter
end

function SearchManager:UpdateAttachedFilters(silent)
    df("UpdateAttachedFilters %s", tostring(silent)) -- TODO
    for filterId, filter in pairs(self.availableFilters) do
        local isAttached = filter:IsAttached()
        local shouldAttach = (filter:IsPinned() or self.activeSearch:IsFilterActive(filterId)) and filter:CanAttach()
        if(isAttached and (not shouldAttach)) then
            self:DetachFilter(filterId)
        elseif((not isAttached) and shouldAttach) then
            self:AttachFilter(filterId)
        end
        if(not silent) then
            AwesomeGuildStore:FireCallbacks("FilterActiveChanged", filter)
        end
    end
end

function SearchManager:AttachFilter(filterId)
    local filter = self:GetFilter(filterId)
    if(filter and not filter:IsAttached() and filter:CanAttach()) then
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

function SearchManager:UpdateState() -- TODO is this used?
-- go through all activeFilters and store it
end

function SearchManager:SetActiveSearch(searchId)
    for i = 1, #self.searches do
        local search = self.searches[i]
        if(search:GetId() == searchId) then
            self.activeSearch = search
            self.saveData.activeIndex = i
            search:Apply()
            self:RequestSearch()
            return true
        end
    end
    return false
end

function SearchManager:GetActiveSearch()
    return self.activeSearch
end

function SearchManager:GetSearches()
    return self.searches
end

function SearchManager:AddSearch()
    local search = SearchState:New(self)
    local newIndex = #self.searches + 1
    self.searches[newIndex] = search
    self.saveData.searches[newIndex] = search:GetSaveData()
    return search
end

function SearchManager:RemoveSearch(searchId)
    local searches = self.searches
    for i = 1, #searches do
        if(searches[i]:GetId() == searchId) then
            local removedSearch = table.remove(searches, i)
            if(self.activeSearch == removedSearch) then
                local activeSearch
                if(#self.searches == 0) then
                    activeSearch = self:AddSearch()
                    self.saveData.activeIndex = 1
                else
                    local index = math.min(i, #searches)
                    activeSearch = self.searches[index]
                    self.saveData.activeIndex = index
                end

                self.activeSearch = activeSearch
                activeSearch:Apply()
                self:RequestSearch()
            end
            break
        end
    end
end

function SearchManager:GetAvailableFilters()
    return self.availableFilters
end

function SearchManager:GetActiveFilters()
    return self.activeFilters
end

function SearchManager:RequestFilterUpdate()
    if(self.updateCallback) then -- TODO use the delay call lib we started but never finished
        ClearCallLater(self.updateCallback)
    end
    self.updateCallback = zo_callLater(function()
        self.updateCallback = nil
        AwesomeGuildStore:FireCallbacks(FILTER_UPDATE_CALLBACK_NAME, self.activeFilters)
    end, FILTER_UPDATE_DELAY)
end

function SearchManager:SelectCategory(category)
    self.categoryFilter:SetCategory(category)
end

function SearchManager:SelectSubcategory(subcategory)
    self.categoryFilter:SetSubcategory(subcategory)
end

function SearchManager:GetNumVisibleResults(guildName)
    if(not guildName) then
        guildName = select(2, GetCurrentTradingHouseGuildDetails())
    end
    local filterState = self.activeSearch:GetFilterState()
    local results = self.itemDatabase:GetFilteredView(guildName, filterState):GetItems()
    return #results
end

function SearchManager:HasMorePages()
    local _, guildName = GetCurrentTradingHouseGuildDetails()
    local currentState = self.activeSearch:GetFilterState()
    local page = self.searchPageHistory:GetNextPage(guildName, currentState)
    return page ~= false
end

function SearchManager:RequestSearch(ignoreResultCount)
    local guildId, guildName = GetCurrentTradingHouseGuildDetails()
    local currentState = self.activeSearch:GetFilterState()
    local page = self.searchPageHistory:GetNextPage(guildName, currentState)
    if(page) then -- TODO take into account if we already have enough results (+ an option to ignore that for the actual "search more" button)
        if(self.activityManager:RequestSearchResults(guildId, ignoreResultCount)) then
            logger:Debug("Queued request search results")
        else
            logger:Debug("Could not queue request search results")
        end
    else
        logger:Debug("No more pages for current state") -- TODO user feedback
    end
end

function SearchManager:DoSearch() -- TODO remove / this is now handled by the activity
    assert(false, "should not be called anymore")
    return false
end
