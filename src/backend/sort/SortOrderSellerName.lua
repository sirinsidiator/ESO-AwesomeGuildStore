local AGS = AwesomeGuildStore

local SortOrderBase = AGS.class.SortOrderBase
local SORT_ORDER_ID = AGS.data.SORT_ORDER_ID

local gettext = AGS.internal.gettext


local SortOrderSellerName = SortOrderBase:Subclass()
AGS.class.SortOrderSellerName = SortOrderSellerName

function SortOrderSellerName:New(...)
    return SortOrderBase.New(self, ...)
end

function SortOrderSellerName:Initialize()
    -- TRANSLATORS: label of the seller name sort order
    local label = gettext("Seller Name")
    SortOrderBase.Initialize(self, SORT_ORDER_ID.SELLER_NAME_ORDER, label, function(a, b)
        if(a.sellerName == b.sellerName) then
            return 0
        end
        return a.sellerName < b.sellerName and 1 or -1
    end)
end
