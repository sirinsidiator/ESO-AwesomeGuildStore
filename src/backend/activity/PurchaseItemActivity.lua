local AGS = AwesomeGuildStore

local ActivityBase = AGS.class.ActivityBase

local logger = AGS.internal.logger
local gettext = AGS.internal.gettext

local Promise = LibPromises
local sformat = string.format


local PurchaseItemActivity = ActivityBase:Subclass()
AGS.class.PurchaseItemActivity = PurchaseItemActivity

function PurchaseItemActivity:New(...)
    return ActivityBase.New(self, ...)
end

function PurchaseItemActivity:Initialize(tradingHouseWrapper, guildId, itemData)
    local key = PurchaseItemActivity.CreateKey(guildId, itemData.itemUniqueId, itemData.purchasePrice)
    ActivityBase.Initialize(self, tradingHouseWrapper, key, ActivityBase.PRIORITY_HIGH, guildId)
    self.itemData = itemData
end

function PurchaseItemActivity:Update()
    self.canExecute = self.guildSelection:IsAppliedGuildId(self.guildId) or (GetTradingHouseCooldownRemaining() == 0)
end

function PurchaseItemActivity:SetPendingItem()
    if(not self.pendingPromise) then
        self.pendingPromise = Promise:New()
        SetPendingItemPurchaseByItemUniqueId(self.itemData.itemUniqueId, self.itemData.purchasePrice)
    end
    return self.pendingPromise
end

function PurchaseItemActivity:OnPendingPurchaseChanged()
    if(self.pendingPromise) then
        self.pendingPromise:Resolve(self)
    end
end

function PurchaseItemActivity:ConfirmPurchase()
    if(not self.responsePromise) then
        self.responsePromise = Promise:New()
        ConfirmPendingItemPurchase()
    end
    return self.responsePromise
end

function PurchaseItemActivity:FinalizePurchase()
    local promise = Promise:New()
    AGS.internal:FireCallbacks(AGS.callback.ITEM_PURCHASED, self.itemData)
    promise:Resolve(self)
    return promise
end

function PurchaseItemActivity:FailPurchase()
    local promise = Promise:New()
    if self.result == TRADING_HOUSE_RESULT_ITEM_NOT_FOUND then
        self.itemData.soldout = true
    end
    AGS.internal:FireCallbacks(AGS.callback.ITEM_PURCHASE_FAILED, self.itemData)
    promise:Reject(self)
    return promise
end

function PurchaseItemActivity:DoExecute()
    return self:ApplyGuildId():Then(self.SetPendingItem):Then(self.ConfirmPurchase):Then(self.FinalizePurchase, self.FailPurchase)
end

function PurchaseItemActivity:GetErrorMessage()
    -- TRANSLATORS: error text shown to the user when an item could not be listed
    return gettext("Could not purchase item")
end

function PurchaseItemActivity:GetLogEntry()
    if(not self.logEntry) then
        local itemData = self.itemData
        local price = ZO_Currency_FormatPlatform(CURT_MONEY, itemData.purchasePrice, ZO_CURRENCY_FORMAT_AMOUNT_ICON)
        -- TRANSLATORS: log text shown to the user for each purchase item request. Placeholders are for the stackCount, itemLink, price, seller and guild name respectively
        self.logEntry = gettext("Purchase <<1>>x <<2>> for <<3>> from <<4>> in <<5>>", itemData.stackCount, itemData.itemLink, price, itemData.sellerName, itemData.guildName)
    end
    return self.logEntry
end

function PurchaseItemActivity:GetType()
    return ActivityBase.ACTIVITY_TYPE_PURCHASE_ITEM
end

function PurchaseItemActivity.CreateKey(guildId, uniqueId, price)
    return sformat("%d_%d_%s_%d", ActivityBase.ACTIVITY_TYPE_PURCHASE_ITEM, guildId, Id64ToString(uniqueId), price)
end
