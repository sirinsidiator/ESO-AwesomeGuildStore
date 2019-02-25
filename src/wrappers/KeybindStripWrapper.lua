local AGS = AwesomeGuildStore

local ActivityBase = AGS.class.ActivityBase
local gettext = AGS.internal.gettext

local DO_SEARCH_SHORTCUT_INDEX = 1
local SWITCH_GUILD_SHORTCUT_INDEX = 2
local RESET_SEARCH_SHORTCUT_INDEX = 3
local IGNORE_RESULT_COUNT = true

local KeybindStripWrapper = ZO_Object:Subclass()
AGS.class.KeybindStripWrapper = KeybindStripWrapper

function KeybindStripWrapper:New(...)
    local wrapper = ZO_Object.New(self)
    wrapper:Initialize(...)
    return wrapper
end

function KeybindStripWrapper:Initialize(tradingHouseWrapper)
    local tradingHouse = tradingHouseWrapper.tradingHouse
    local searchManager = tradingHouseWrapper.searchManager
    local activityManager = tradingHouseWrapper.activityManager

    local browseKeybindStripDescriptor = tradingHouse.browseKeybindStripDescriptor
    local doSearchDescriptor = browseKeybindStripDescriptor[DO_SEARCH_SHORTCUT_INDEX]
    doSearchDescriptor.enabled = function()
        -- TODO consolidate into one function together with the show more row state
        local activity = activityManager:GetCurrentActivity()
        if(activity and activity:GetType() == ActivityBase.ACTIVITY_TYPE_REQUEST_SEARCH) then
            return false
        else
            local searchActivities = activityManager:GetActivitiesByType(ActivityBase.ACTIVITY_TYPE_REQUEST_SEARCH)
            return (#searchActivities == 0)
        end
        return true
    end

    doSearchDescriptor.callback = function()
        searchManager:RequestSearch(IGNORE_RESULT_COUNT)
    end

    -- TRANSLATORS: Label for the keybind to show more results
    doSearchDescriptor.name = gettext("Show More Results")

    local switchGuildDescriptor = browseKeybindStripDescriptor[SWITCH_GUILD_SHORTCUT_INDEX]
    switchGuildDescriptor.enabled = true

    local resetSearchDescriptor = browseKeybindStripDescriptor[RESET_SEARCH_SHORTCUT_INDEX]
    resetSearchDescriptor.callback = function()
        searchManager:GetActiveSearch():Reset()
    end

    AGS:RegisterCallback(AGS.callback.CURRENT_ACTIVITY_CHANGED, function(currentActivity, previousActivity)
        KEYBIND_STRIP:UpdateKeybindButtonGroup(tradingHouse.keybindStripDescriptor)
    end)
end
