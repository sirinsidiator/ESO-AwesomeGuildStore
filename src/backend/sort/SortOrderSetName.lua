local AGS = AwesomeGuildStore

local SortOrderBase = AGS.class.SortOrderBase
local SORT_ORDER_ID = AGS.data.SORT_ORDER_ID

local gettext = AGS.internal.gettext


local SortOrderSetName = SortOrderBase:Subclass()
AGS.class.SortOrderSetName = SortOrderSetName

function SortOrderSetName:New(...)
    return SortOrderBase.New(self, ...)
end

function SortOrderSetName:Initialize()
    -- TRANSLATORS: label of the set name sort order
    local label = gettext("Set Name")
    SortOrderBase.Initialize(self, SORT_ORDER_ID.SET_NAME_ORDER, label, function(a, b)
        local hasSetA, setNameA = a:GetSetInfo()
        local hasSetB, setNameB = b:GetSetInfo()
        if(hasSetA and not hasSetB) then
            return 1
        elseif(hasSetB and not hasSetA) then
            return -1
        elseif(not hasSetA and not hasSetB) then
            return 0
        elseif(setNameA == setNameB) then
            return 0
        end
        return setNameA < setNameB and 1 or -1
    end)
end
