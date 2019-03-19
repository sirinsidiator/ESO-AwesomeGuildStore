local AGS = AwesomeGuildStore

local ActivityBase = AGS.class.ActivityBase
local SortOrderBase = AGS.class.SortOrderBase

local logger = AGS.internal.logger
local gettext = AGS.internal.gettext

local Promise = LibPromises
local sformat = string.format


local FetchGuildItemsActivity = ActivityBase:Subclass()
AGS.class.FetchGuildItemsActivity = FetchGuildItemsActivity

function FetchGuildItemsActivity:New(...)
    return ActivityBase.New(self, ...)
end

function FetchGuildItemsActivity:Initialize(tradingHouseWrapper, guildId)
    local key = FetchGuildItemsActivity.CreateKey(guildId)
    ActivityBase.Initialize(self, tradingHouseWrapper, key, ActivityBase.PRIORITY_MEDIUM, guildId)
    self.itemDatabase = tradingHouseWrapper.itemDatabase
    self.pendingGuildName = tradingHouseWrapper:GetTradingGuildName(guildId)
end

function FetchGuildItemsActivity:Update()
    self.canExecute = (GetTradingHouseCooldownRemaining() == 0)
end

function FetchGuildItemsActivity:FetchGuildItems()
    local promise = Promise:New()

    local success, result = self.itemDatabase:UpdateGuildSpecificItems(self.guildId, self.pendingGuildName)
    if(success) then
        self:SetState(ActivityBase.STATE_SUCCEEDED, result)
        promise:Resolve(self)
    else
        self:SetState(ActivityBase.STATE_FAILED, result)
        promise:Reject(self)
    end
    return promise
end

function FetchGuildItemsActivity:DoExecute()
    return self:ApplyGuildId():Then(self.FetchGuildItems)
end

function FetchGuildItemsActivity:GetErrorMessage()
    -- TRANSLATORS: error text shown to the user when guild items could not be fetched
    return gettext("Could not fetch guild items")
end

function FetchGuildItemsActivity:GetLogEntry()
    if(not self.logEntry) then
        -- TRANSLATORS: log text shown to the user for each time the guild items are fetched. Placeholder is for the guild name
        self.logEntry = gettext("Fetch guild items in <<1>>", self.pendingGuildName)
    end
    return self.logEntry
end

function FetchGuildItemsActivity:GetType()
    return ActivityBase.ACTIVITY_TYPE_FETCH_GUILD_ITEMS
end

function FetchGuildItemsActivity.CreateKey(guildId)
    return sformat("%d_%s", ActivityBase.ACTIVITY_TYPE_FETCH_GUILD_ITEMS, guildId)
end
