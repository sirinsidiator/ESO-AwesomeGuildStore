local AGS = AwesomeGuildStore

local ActivityBase = AGS.class.ActivityBase
local RequestSearchActivity = AGS.class.RequestSearchActivity
local SortOrderBase = AGS.class.SortOrderBase

local logger = AGS.internal.logger
local gettext = AGS.internal.gettext

local Promise = LibStub("LibPromises")
local sformat = string.format


local RequestNewestActivity = RequestSearchActivity:Subclass()
AGS.class.RequestNewestActivity = RequestNewestActivity

function RequestNewestActivity:New(...)
    return RequestSearchActivity.New(self, ...)
end

function RequestNewestActivity:Initialize(tradingHouseWrapper, guildId)
    local key = RequestNewestActivity.CreateKey(guildId)
    ActivityBase.Initialize(self, tradingHouseWrapper, key, ActivityBase.PRIORITY_LOW, guildId)
    self.searchManager = tradingHouseWrapper.searchTab.searchManager -- TODO
    self.itemDatabase = tradingHouseWrapper.itemDatabase
    self.pendingGuildName = tradingHouseWrapper:GetTradingGuildName(guildId)
end

function RequestNewestActivity:Update()
    RequestSearchActivity.Update(self)
    if(self.canExecute) then
        self.canExecute = self.searchManager.searchPageHistory:CanRequestNewest(self.pendingGuildName)
    end
end

function RequestNewestActivity:RequestSearch()
    if(not self.responsePromise) then
        self.responsePromise = Promise:New()

        ExecuteTradingHouseSearch(0, SortOrderBase.SORT_FIELD_TIME_LEFT, SortOrderBase.SORT_ORDER_DOWN) -- TODO request all new pages
    end
    return self.responsePromise
end

function RequestNewestActivity:GetLogEntry()
    if(not self.logEntry) then
        -- TRANSLATORS: log text shown to the user for each request of the newest search results. Placeholder is for the guild name
        self.logEntry = zo_strformat(gettext("Request newest results in <<1>>"), self.pendingGuildName)
    end
    return self.logEntry
end

function RequestSearchActivity:HandleSearchResultsReceived()
    logger:Debug("handle newest results received")
    -- TODO: check if any of the returned items already exist -> if not, we need to request another page
    self.searchManager.searchPageHistory:SetRequestNewest(self.pendingGuildName)
    zo_callLater(function() -- TODO: this should probably be triggered somewhere else
        self.searchManager.activityManager:RequestNewestResults(self.guildId)
    end, 0)
end

function RequestNewestActivity:GetType()
    return ActivityBase.ACTIVITY_TYPE_REQUEST_NEWEST
end

function RequestNewestActivity.CreateKey(guildId)
    return sformat("%d_%s", ActivityBase.ACTIVITY_TYPE_REQUEST_NEWEST, guildId)
end
