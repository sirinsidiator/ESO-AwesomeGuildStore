local AGS = AwesomeGuildStore

local ActivityBase = AGS.class.ActivityBase

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
    self.searchManager = tradingHouseWrapper.searchTab.searchManager -- TODO
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
            local search = self.tradingHouseWrapper.tradingHouse.m_search

            search:ResetSearchData()
            search:ResetPageData()

            search.m_page = page

            for _, setter in ipairs(search.m_setters) do -- TODO use search manager instead and only apply active filters
                setter:ApplyToSearch(search)
            end

            self.pendingFilterState = filterState
            search:InternalExecuteSearch()
        else
            self.result = ActivityBase.ERROR_PAGE_ALREADY_LOADED
            self.responsePromise:Reject(self)
        end
    end
    return self.responsePromise
end

function RequestSearchActivity:DoExecute(panel)
    return self:ApplyGuildId(panel):Then(self.RequestSearch)
end

function RequestSearchActivity:OnResponse(responseType, result, panel)
    if(responseType == self.expectedResponseType and result ~= TRADING_HOUSE_RESULT_SUCCESS) then
        self.state = ActivityBase.STATE_FAILED
        panel:SetStatusText("Request failed") -- TODO translate
        panel:Refresh()
        if(self.responsePromise) then self.responsePromise:Reject(self) end
        return true
    end
    return false
end

local AUTO_SEARCH_RESULT_COUNT_THRESHOLD = 50 -- TODO: tweak value

function RequestSearchActivity:OnSearchResults(guildId, numItems, page, hasMore, panel)
    if(self.responsePromise) then
        logger:Debug("handle results received")
        self.state = ActivityBase.STATE_SUCCEEDED
        self.itemDatabase:Update(self.pendingGuildName, numItems)
        if(hasMore) then
            self.searchManager.searchPageHistory:SetHighestSearchedPage(self.pendingGuildName, self.pendingFilterState, page)
            local results = self.itemDatabase:GetFilteredView(self.pendingGuildName, self.pendingFilterState):GetItems() -- TODO: should store the view for each request and get the info from there
            if(#results < AUTO_SEARCH_RESULT_COUNT_THRESHOLD) then
                zo_callLater(function()
                    d("search more") -- TODO
                    self.searchManager:RequestSearch()
                end, 0)
            end
        else
            self.searchManager.searchPageHistory:SetStateHasNoMorePages(self.pendingGuildName, self.pendingFilterState)
        end

        panel:SetStatusText("Request finished") -- TODO translate
        panel:Refresh()

        self.responsePromise:Resolve(self)
        return true
    end
    return false
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

function RequestSearchActivity:GetType()
    return ActivityBase.ACTIVITY_TYPE_REQUEST_SEARCH
end

function RequestSearchActivity.CreateKey(guildId)
    return sformat("%d_%s", ActivityBase.ACTIVITY_TYPE_REQUEST_SEARCH, guildId)
end
