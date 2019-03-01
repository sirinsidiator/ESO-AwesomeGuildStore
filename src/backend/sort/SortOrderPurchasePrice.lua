local AGS = AwesomeGuildStore

local SortOrderBase = AGS.class.SortOrderBase
local SORT_ORDER_ID = AGS.data.SORT_ORDER_ID

local gettext = AGS.internal.gettext


local SortOrderPurchasePrice = SortOrderBase:Subclass()
AGS.class.SortOrderPurchasePrice = SortOrderPurchasePrice

function SortOrderPurchasePrice:New(...)
    return SortOrderBase.New(self, ...)
end

function SortOrderPurchasePrice:Initialize()
    -- TRANSLATORS: label of the purchase price sort order
    local label = gettext("Purchase Price")
    SortOrderBase.Initialize(self, SORT_ORDER_ID.PURCHASE_PRICE_ORDER, label, function(a, b)
        if(a.purchasePrice == b.purchasePrice) then
            return 0
        end
        return a.purchasePrice < b.purchasePrice and 1 or -1
    end)

    self.serverKey = SortOrderBase.SORT_FIELD_PURCHASE_PRICE
    self.useLocalDirection = true
end
