local AGS = AwesomeGuildStore

local SortOrderBase = AGS.class.SortOrderBase
local SORT_ORDER_ID = AGS.data.SORT_ORDER_ID

local gettext = AGS.internal.gettext


local SortOrderItemQuality = SortOrderBase:Subclass()
AGS.class.SortOrderItemQuality = SortOrderItemQuality

function SortOrderItemQuality:New(...)
    return SortOrderBase.New(self, ...)
end

function SortOrderItemQuality:Initialize()
    -- TRANSLATORS: label of the item quality sort order
    local label = gettext("Item Quality")
    SortOrderBase.Initialize(self, SORT_ORDER_ID.ITEM_QUALITY_ORDER, label, function(a, b)
        if(a.quality == b.quality) then
            return 0
        end
        return a.quality < b.quality and 1 or -1
    end)
end
