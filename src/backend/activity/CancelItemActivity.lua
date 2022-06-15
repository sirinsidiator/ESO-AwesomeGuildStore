local AGS = AwesomeGuildStore

local ActivityBase = AGS.class.ActivityBase

local logger = AGS.internal.logger
local gettext = AGS.internal.gettext

local Promise = LibPromises
local sformat = string.format

local CancelItemActivity = ActivityBase:Subclass()
AGS.class.CancelItemActivity = CancelItemActivity

function CancelItemActivity:New(...)
    return ActivityBase.New(self, ...)
end

function CancelItemActivity:Initialize(tradingHouseWrapper, guildId, listingIndex)
    local stackCount, _, _, price, _, uniqueId, purchasePricePerUnit = select(4, GetTradingHouseListingItemInfo(listingIndex))
    local key = CancelItemActivity.CreateKey(guildId, uniqueId)
    ActivityBase.Initialize(self, tradingHouseWrapper, key, ActivityBase.PRIORITY_HIGH, guildId)
    self.uniqueId = uniqueId
    self.stackCount = stackCount
    self.price = price
    self.itemLink = GetTradingHouseListingItemLink(listingIndex, LINK_STYLE_DEFAULT)
end

function CancelItemActivity:Update()
    self.canExecute = self.tradingHouseWrapper:IsConnected() and (self.guildSelection:IsAppliedGuildId(self.guildId) or (GetTradingHouseCooldownRemaining() == 0))
end

function CancelItemActivity:CancelListing()
    if not self.responsePromise then
        self.responsePromise = Promise:New()
        CancelTradingHouseListingByItemUniqueId(self.uniqueId)
    end
    return self.responsePromise
end

function CancelItemActivity:FinalizeCancellation()
    local promise = Promise:New()
    AGS.internal:FireCallbacks(AGS.callback.ITEM_CANCELLED, self.guildId, self.itemLink, self.price, self.stackCount)
    promise:Resolve(self)
    return promise
end

function CancelItemActivity:DoExecute()
    logger:Debug("Execute CancelItemActivity")
    return self:ApplyGuildId():Then(self.CancelListing):Then(self.FinalizeCancellation)
end

function CancelItemActivity:GetErrorMessage()
    -- TRANSLATORS: error text shown to the user when a listed item could not be cancelled
    return gettext("Could not cancel listing")
end

function CancelItemActivity:GetLogEntry()
    if not self.logEntry then
        local price = ZO_Currency_FormatPlatform(CURT_MONEY, self.price, ZO_CURRENCY_FORMAT_AMOUNT_ICON)
        -- TRANSLATORS: log text shown to the user for each cancel item activity. First placeholder is for the item link and second for the guild name
        self.logEntry = gettext("Cancel listing of <<1>>x <<t:2>> for <<3>> in <<4>>", self.stackCount, self.itemLink, price, GetGuildName(self.guildId))
    end
    return self.logEntry
end

function CancelItemActivity:GetType()
    return ActivityBase.ACTIVITY_TYPE_CANCEL_ITEM
end

function CancelItemActivity.CreateKey(guildId, uniqueId)
    return sformat("%d_%d_%s", ActivityBase.ACTIVITY_TYPE_CANCEL_ITEM, guildId, Id64ToString(uniqueId))
end