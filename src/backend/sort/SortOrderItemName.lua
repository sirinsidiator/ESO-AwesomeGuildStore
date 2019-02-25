local AGS = AwesomeGuildStore

local SortOrderBase = AGS.class.SortOrderBase
local SORT_ORDER_ID = AGS.data.SORT_ORDER_ID

local gettext = AGS.internal.gettext


local SortOrderItemName = SortOrderBase:Subclass()
AGS.class.SortOrderItemName = SortOrderItemName

function SortOrderItemName:New(...)
    return SortOrderBase.New(self, ...)
end

function SortOrderItemName:Initialize()
    -- TRANSLATORS: label of the item name sort order
    local label = gettext("Item Name")
    SortOrderBase.Initialize(self, SORT_ORDER_ID.ITEM_NAME_ORDER, label, function(a, b)
        if(a.name == b.name) then
            return 0
        end
        return a.name < b.name and 1 or -1
    end)
end
