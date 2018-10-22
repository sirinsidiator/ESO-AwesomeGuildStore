local AGS = AwesomeGuildStore

local SortOrderBase = AwesomeGuildStore.class.SortOrderBase
local SORT_ORDER_ID = AGS.data.SORT_ORDER_ID

local gettext = AGS.internal.gettext


local SortOrderLastSeen = SortOrderBase:Subclass()
AGS.class.SortOrderLastSeen = SortOrderLastSeen

function SortOrderLastSeen:New(...)
    return SortOrderBase.New(self, ...)
end

function SortOrderLastSeen:Initialize()
    -- TRANSLATORS: label of the last seen sort order
    local label = gettext("Last Seen")
    SortOrderBase.Initialize(self, SORT_ORDER_ID.LAST_SEEN_ORDER, label, function(a, b)
        if(a.lastSeen == b.lastSeen or not a.lastSeen or not b.lastSeen) then
            return 0
        end
        return a.lastSeen < b.lastSeen and 1 or -1
    end)
end
