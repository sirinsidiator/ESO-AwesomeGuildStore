local AGS = AwesomeGuildStore

local ActivityBase = AGS.class.ActivityBase

local logger = AGS.internal.logger
local gettext = AGS.internal.gettext

local Promise = LibPromises
local sformat = string.format


local RequestListingsActivity = ActivityBase:Subclass()
AGS.class.RequestListingsActivity = RequestListingsActivity

function RequestListingsActivity:New(...)
    return ActivityBase.New(self, ...)
end

function RequestListingsActivity:Initialize(tradingHouseWrapper, guildId)
    local key = RequestListingsActivity.CreateKey(guildId)
    ActivityBase.Initialize(self, tradingHouseWrapper, key, ActivityBase.PRIORITY_MEDIUM, guildId)
end

function RequestListingsActivity:Update()
    self.canExecute = self.tradingHouseWrapper:IsConnected() and (self.guildSelection:IsAppliedGuildId(self.guildId) or (GetTradingHouseCooldownRemaining() == 0))
end

function RequestListingsActivity:RequestListings()
    if not self.responsePromise then
        self.responsePromise = Promise:New()
        if not HasTradingHouseListings() then
            RequestTradingHouseListings()
        else
            self:SetState(ActivityBase.STATE_SUCCEEDED, ActivityBase.RESULT_LISTINGS_ALREADY_LOADED)
            self.responsePromise:Resolve(self)
        end
    end
    return self.responsePromise
end

function RequestListingsActivity:DoExecute()
    logger:Debug("Execute RequestListingsActivity")
    return self:ApplyGuildId():Then(self.RequestListings)
end

function RequestListingsActivity:GetLogEntry()
    if not self.logEntry then
        -- TRANSLATORS: log text shown to the user for each listings request. Placeholder is for the guild name
        self.logEntry = gettext("Request listings in <<1>>", GetGuildName(self.guildId))
    end
    return self.logEntry
end

function RequestListingsActivity:GetErrorMessage()
    -- TRANSLATORS: error text shown to the user when listings could not be requested
    return gettext("Could not request listings")
end

function RequestListingsActivity:GetType()
    return ActivityBase.ACTIVITY_TYPE_REQUEST_LISTINGS
end

function RequestListingsActivity.CreateKey(guildId)
    return sformat("%d_%d", ActivityBase.ACTIVITY_TYPE_REQUEST_LISTINGS, guildId)
end
