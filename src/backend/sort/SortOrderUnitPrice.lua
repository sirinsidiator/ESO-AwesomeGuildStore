local AGS = AwesomeGuildStore

local SortOrderBase = AGS.class.SortOrderBase
local SORT_ORDER_ID = AGS.data.SORT_ORDER_ID

local gettext = AGS.internal.gettext


local SortOrderUnitPrice = SortOrderBase:Subclass()
AGS.class.SortOrderUnitPrice = SortOrderUnitPrice

function SortOrderUnitPrice:New(...)
    return SortOrderBase.New(self, ...)
end

function SortOrderUnitPrice:Initialize()
    -- TRANSLATORS: label of the last seen sort order
    local label = gettext("Unit Price")
    SortOrderBase.Initialize(self, SORT_ORDER_ID.UNIT_PRICE_ORDER, label, function(a, b)
        if(a.purchasePricePerUnit == b.purchasePricePerUnit) then
            return 0
        end
        return a.purchasePricePerUnit < b.purchasePricePerUnit and 1 or -1
    end)

    self.serverKey = SortOrderBase.SORT_FIELD_UNIT_PRICE
    self.useLocalDirection = true
end
