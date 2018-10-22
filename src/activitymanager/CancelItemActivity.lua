local AGS = AwesomeGuildStore

local ActivityBase = AGS.class.ActivityBase

local logger = AGS.internal.logger
local gettext = AGS.internal.gettext

local Promise = LibStub("LibPromises")
local sformat = string.format


local CancelItemActivity = ActivityBase:Subclass()
AGS.class.CancelItemActivity = CancelItemActivity

function CancelItemActivity:New(...)
    return ActivityBase.New(self, ...)
end

function CancelItemActivity:Initialize(tradingHouseWrapper, guildId, listingIndex, uniqueId, price)
    local key = CancelItemActivity.CreateKey(guildId, uniqueId, price)
    ActivityBase.Initialize(self, tradingHouseWrapper, key, ActivityBase.PRIORITY_HIGH, guildId)
    self.listingIndex = listingIndex
    self.uniqueId = uniqueId
    self.price = price
end

function CancelItemActivity:Update()
    self.canExecute = self.guildSelection:IsAppliedGuildId(self.guildId) or (GetTradingHouseCooldownRemaining() == 0)
end

function CancelItemActivity:CancelListing()
    if(not self.responsePromise) then
        self.responsePromise = Promise:New()

        local price, _, uniqueId = select(7, GetTradingHouseListingItemInfo(self.listingIndex))
        if(uniqueId ~= self.uniqueId or price ~= self.price) then
            logger:Warn(sformat("Listed item doesn't match for cancel operation (%s => %s, %d => %d)", Id64ToString(uniqueId), Id64ToString(self.uniqueId), price, self.price))
            self.responsePromise:Reject(ActivityBase.ERROR_TARGET_ITEM_MISMATCH)
        else
            CancelTradingHouseListing(self.listingIndex)
        end
    end
    return self.responsePromise
end

function CancelItemActivity:FinalizeCancellation()
    local promise = Promise:New()
    AGS:FireCallback("ItemCancelled", self.guildId, self.itemLink, self.price) -- TODO
    promise:Resolve(self)
    return promise
end

function CancelItemActivity:DoExecute(panel)
    return self:ApplyGuildId(panel):Then(self.CancelListing):Then(self.FinalizeCancellation)
end

function CancelItemActivity:GetErrorMessage()
    -- TRANSLATORS: error text shown to the user when a listed item could not be cancelled
    return gettext("Could not cancel listing")
end

function CancelItemActivity:GetLogEntry()
    if(not self.logEntry) then
        -- TRANSLATORS: log text shown to the user for each cancel item activity. First placeholder is for the item link and second for the guild name
        local itemLink = GetTradingHouseListingItemLink(self.listingIndex, LINK_STYLE_BRACKETS)
        self.logEntry = zo_strformat(gettext("Cancel listing of <<1>> in <<2>>"), itemLink, GetGuildName(self.guildId))
    end
    return self.logEntry
end

function CancelItemActivity:GetType()
    return ActivityBase.ACTIVITY_TYPE_CANCEL_ITEM
end

function CancelItemActivity.CreateKey(guildId, uniqueId, price)
    return sformat("%d_%d_%s_%d", ActivityBase.ACTIVITY_TYPE_CANCEL_ITEM, guildId, Id64ToString(uniqueId), price)
end