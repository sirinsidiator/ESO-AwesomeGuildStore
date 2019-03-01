local AGS = AwesomeGuildStore

local SortOrderBase = AGS.class.SortOrderBase
local SORT_ORDER_ID = AGS.data.SORT_ORDER_ID

local gettext = AGS.internal.gettext


local SortOrderTimeLeft = SortOrderBase:Subclass()
AGS.class.SortOrderTimeLeft = SortOrderTimeLeft

function SortOrderTimeLeft:New(...)
    return SortOrderBase.New(self, ...)
end

function SortOrderTimeLeft:Initialize()
    -- TRANSLATORS: label of the time left sort order
    local label = gettext("Time Left")
    SortOrderBase.Initialize(self, SORT_ORDER_ID.TIME_LEFT_ORDER, label, function(a, b)
        if(a.timeRemaining == b.timeRemaining) then
            return 0
        end
        return a.timeRemaining < b.timeRemaining and 1 or -1
    end)

    self.useLocalDirection = true
end
