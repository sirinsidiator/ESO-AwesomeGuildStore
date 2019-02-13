local AGS = AwesomeGuildStore

local ActivityBase = AGS.class.ActivityBase

local logger = AGS.internal.logger
local gettext = AGS.internal.gettext

local Promise = LibStub("LibPromises")
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
        d("set pending item")
        self.pendingPromise = Promise:New()
        SetPendingItemPurchaseByItemUniqueId(self.itemData.itemUniqueId, self.itemData.purchasePrice)
    end
    return self.pendingPromise
end

function PurchaseItemActivity:OnPendingPurchaseChanged()
    if(self.pendingPromise) then
        d("pending purchase changed")
        self.pendingPromise:Resolve(self)
    end
end

function PurchaseItemActivity:ConfirmPurchase()
    if(not self.responsePromise) then
        d("confirm purchase")
        self.responsePromise = Promise:New()
        ConfirmPendingItemPurchase()
    end
    return self.responsePromise
end

function PurchaseItemActivity:FinalizePurchase()
    local promise = Promise:New()
    d("finalize purchase")
    AGS:FireCallbacks("ItemPurchased", self.itemData) -- TODO
    promise:Resolve(self)
    return promise
end

function PurchaseItemActivity:DoExecute(panel)
    d("do execute")
    return self:ApplyGuildId(panel):Then(self.SetPendingItem):Then(self.ConfirmPurchase):Then(self.FinalizePurchase)
end

function PurchaseItemActivity:GetErrorMessage()
    -- TRANSLATORS: error text shown to the user when an item could not be listed
    return gettext("Could not purchase item")
end

function PurchaseItemActivity:GetLogEntry()
    if(not self.logEntry) then
        local itemData = self.itemData
        -- TRANSLATORS: log text shown to the user for each purchase item request. Placeholders are for the stackCount, itemLink, price, seller and guild name respectively
        self.logEntry = zo_strformat(gettext("Purchase <<1>>x <<2>> for <<3>> from <<4>> in <<5>>"), itemData.stackCount, itemData.itemLink, itemData.purchasePrice, itemData.sellerName, itemData.guildName)
    end
    return self.logEntry
end

function PurchaseItemActivity:GetType()
    return ActivityBase.ACTIVITY_TYPE_PURCHASE_ITEM
end

function PurchaseItemActivity.CreateKey(guildId, uniqueId, price)
    return sformat("%d_%d_%s_%d", ActivityBase.ACTIVITY_TYPE_PURCHASE_ITEM, guildId, Id64ToString(uniqueId), price)
end