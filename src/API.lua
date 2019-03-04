local AGS = AwesomeGuildStore

-- Returns the current AwesomeGuildStore API version. It will be incremented in case there are any breaking changes. You should check it before accessing any functions to avoid errors.
AGS.GetAPIVersion = function() return 4 end

-- Register to a callback fired by the addon. Usage is the same as with CALLBACK_MANAGER:RegisterCallback. You can find the list of them in CallbackNames.lua
function AGS:RegisterCallback(...)
    return AGS.internal.callbackObject:RegisterCallback(...)
end

-- Unregister from a callback. Usage is the same as with CALLBACK_MANAGER:UnregisterCallback. 
function AGS:UnregisterCallback(...)
    return AGS.internal.callbackObject:UnregisterCallback(...)
end

-- A function to retrieve an object with all registered filter ids. Check data/FilterIds.lua for the available field names and ids.
-- Please contact me on ESOUI in case you want to have a new filter id added to the list.
function AGS:GetFilterIds()
    return AGS.data.FILTER_ID
end

-- Returns the filter for the given id, or nil if it is not registered.
function AGS:GetFilter(filterId)
    return AGS.internal.tradingHouse.searchManager:GetFilter(filterId)
end

-- The following three methods should only be called inside AGS.callback.AFTER_FILTER_SETUP:

-- A function to register a filter. Refer to backend/filter/ for examples on how a filter should be implemented.
function AGS:RegisterFilter(filter)
    AGS.internal.tradingHouse.searchManager:RegisterFilter(filter)
end

-- A function to register a filter fragment. Refer to frontend/filter/ for examples on how a filter fragment should be implemented.
function AGS:RegisterFilterFragment(filterFragment)
    AGS.internal.tradingHouse.searchTab.filterArea:RegisterFilterFragment(filterFragment)
end

-- A function to register a sort order. Refer to backend/sort/ for examples on how a sort order should be implemented.
function AGS:RegisterSortOrder(sortOrder)
    local sortFilter = AGS.internal.tradingHouse.searchManager:GetSortFilter()
    sortFilter:RegisterSortOrder(sortOrder)
end

-- This function returns the backpack layouts used on the sell tab when the custom item category filtering is active.
-- The first layout is used when no sub categories are shown and the second one otherwise.
-- May return nil in the future, in case the layouts are no longer necessary.
function AGS:GetSellTabBackpackLayouts()
    return AGS.internal.BACKPACK_TRADING_HOUSE_LAYOUT_FRAGMENT_BASIC, AGS.internal.BACKPACK_TRADING_HOUSE_LAYOUT_FRAGMENT_ADVANCED
end