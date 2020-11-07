local AGS = AwesomeGuildStore

local ActivityBase = AGS.class.ActivityBase
local RequestSearchActivity = AGS.class.RequestSearchActivity
local SortOrderBase = AGS.class.SortOrderBase

local logger = AGS.internal.logger
local gettext = AGS.internal.gettext

local Promise = LibPromises
local sformat = string.format


local RequestNewestActivity = RequestSearchActivity:Subclass()
AGS.class.RequestNewestActivity = RequestNewestActivity

function RequestNewestActivity:New(...)
    return RequestSearchActivity.New(self, ...)
end

function RequestNewestActivity:Initialize(tradingHouseWrapper, guildId)
    local key = RequestNewestActivity.CreateKey(guildId)
    ActivityBase.Initialize(self, tradingHouseWrapper, key, ActivityBase.PRIORITY_LOW, guildId)
    self.searchManager = tradingHouseWrapper.searchManager
    self.itemDatabase = tradingHouseWrapper.itemDatabase
    self.pendingGuildName = tradingHouseWrapper:GetTradingGuildName(guildId)
end

function RequestNewestActivity:RequestSearch()
    if(not self.responsePromise) then
        self.responsePromise = Promise:New()

        self.pendingPage = self.searchManager.searchPageHistory:GetNextRequestNewestPage(self.guildId)

        ClearAllTradingHouseSearchTerms()
        ExecuteTradingHouseSearch(self.pendingPage, SortOrderBase.SORT_FIELD_TIME_LEFT, SortOrderBase.SORT_ORDER_DOWN)
    end
    return self.responsePromise
end

function RequestNewestActivity:GetLogEntry()
    if(not self.logEntry) then
        if(self.pendingPage) then
            -- TRANSLATORS: log text shown to the user for each executed request of the newest search results. Placeholders are for the page and guild name
            self.logEntry = gettext("Request page <<1>> of newest results in <<2>>", self.pendingPage + 1, self.pendingGuildName)
        else
            -- TRANSLATORS: log text shown to the user for each request of the newest search results. Placeholder is for the guild name
            self.logEntry = gettext("Request newest results in <<1>>", self.pendingGuildName)
        end
    end
    return self.logEntry
end

function RequestNewestActivity:HandleSearchResultsReceived(hasAnyResultAlreadyStored)
    logger:Verbose("handle newest results received")
    local page = 0
    if(not hasAnyResultAlreadyStored and self.hasMore) then
        page = self.page + 1
    end
    self.searchManager.searchPageHistory:SetRequestNewest(self.guildId, page)
end

function RequestNewestActivity:GetType()
    return ActivityBase.ACTIVITY_TYPE_REQUEST_NEWEST
end

function RequestNewestActivity.CreateKey(guildId)
    return sformat("%d_%s", ActivityBase.ACTIVITY_TYPE_REQUEST_NEWEST, guildId)
end
