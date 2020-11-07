local AGS = AwesomeGuildStore

local FilterBase = AGS.class.FilterBase
local SortOrderBase = AGS.class.SortOrderBase

local FILTER_ID = AGS.data.FILTER_ID

local gettext = AGS.internal.gettext
local logger = AGS.internal.logger

local TRADING_HOUSE_SORT_ITEM_NAME = 3 -- TODO move somewhere

local SORT_ORDER_TO_LABEL = {
    [SortOrderBase.SORT_ORDER_UP] = gettext("ascending"),
    [SortOrderBase.SORT_ORDER_DOWN] = gettext("descending"),
}

local SortFilter = FilterBase:Subclass()
AGS.class.SortFilter = SortFilter

-- it's not really a filter, but since we want to save the order together with
-- the other filter states and add a fragment to the filter area, we use it like one
function SortFilter:New(...)
    return FilterBase.New(self, ...)
end

function SortFilter:Initialize()
    -- TRANSLATORS: label of the sort filter
    FilterBase.Initialize(self, FILTER_ID.SORT_ORDER, FilterBase.GROUP_SORT, gettext("Sort By"))
    self.pinned = true
    self.availableSortOrders = {}
    self.sortOrderCount = 0
end

function SortFilter:RegisterSortOrder(sortOrder)
    self.availableSortOrders[sortOrder.id] = sortOrder
    if(not self.defaultSortOrder) then
        self.defaultSortOrder = sortOrder
    end
    self.sortOrderCount = self.sortOrderCount + 1
end

function SortFilter:GetSortOrderCount()
    return self.sortOrderCount
end

function SortFilter:SetCurrentSortOrder(sortOrderId, direction)
    local sortOrder
    if(not sortOrderId) then
        sortOrder = self.defaultSortOrder
    else
        sortOrder = self.availableSortOrders[sortOrderId] or self.defaultSortOrder
    end

    local oldDirection = sortOrder:GetDirection()
    if(direction == nil) then
        sortOrder:ResetDirection()
        direction = sortOrder:GetDirection()
    else
        sortOrder:SetDirection(direction)
    end

    local changed = (sortOrder ~= self.sortOrder or direction ~= oldDirection)
    self.sortOrder = sortOrder

    if(changed) then
        self:HandleChange(sortOrder)
    end
end

function SortFilter:GetSortOrder(sortOrderId)
    return self.availableSortOrders[sortOrderId]
end

function SortFilter:GetAvailableSortOrders()
    return self.availableSortOrders
end

function SortFilter:GetCurrentSortOrder()
    return self.sortOrder
end

function SortFilter:Reset()
    self:SetCurrentSortOrder(nil)
end

function SortFilter:IsDefault(id, direction)
    local sortOrder = self.sortOrder
    if(self.availableSortOrders[id]) then
        sortOrder = self.availableSortOrders[id]
    end
    return sortOrder == self.defaultSortOrder and sortOrder:IsDefaultDirection()
end

function SortFilter:IsLocal()
    return false
end

function SortFilter:PrepareForSearch(id, direction)
    self.serverSortOrder = self.availableSortOrders[id]
    self.serverSortDirection = direction
end

function SortFilter:ApplyToSearch(request)
    if(self.serverSortOrder) then
        self.serverSortOrder:ApplySortValues(request, self.serverSortDirection)
    end
end

function SortFilter:GetValues()
    return self.sortOrder:GetId(), self.sortOrder:GetDirection()
end

function SortFilter:SetValues(id, direction)
    if(not id or direction == nil) then
        self:Reset()
        return
    end

    self:SetCurrentSortOrder(id, direction)
end

function SortFilter:SetUpLocalFilter()
    return false
end

local MAX_RESULT_TYPE_ID = 3 -- keep in sync with tradinghouse_keyboard.lua
local sortOrder -- TODO make part of class
local function SortEntries(listEntry1, listEntry2)
    local data1, data2 = listEntry1.data or listEntry1, listEntry2.data or listEntry2
    if(listEntry1.typeId > MAX_RESULT_TYPE_ID or listEntry2.typeId > MAX_RESULT_TYPE_ID) then
        return listEntry1.typeId < listEntry2.typeId
    end

    local result = sortOrder:GetSortResult(data1, data2)
    if(result == 0) then
        -- TODO use other sort functions as tie breaker
        if(data2.lastSeen == data1.lastSeen) then
            return data1.slotIndex < data2.slotIndex
        end
        return data2.lastSeen < data1.lastSeen
    end
    return result > 0
end

function SortFilter:SortLocalResults(items, sortOrderId, direction)
    sortOrder = self.availableSortOrders[sortOrderId] or self.sortOrder

    local oldDirection
    if(direction ~= nil) then
        oldDirection = sortOrder:GetDirection()
        sortOrder:SetDirection(direction)
    end

    table.sort(items, SortEntries)

    if(oldDirection ~= nil) then
        sortOrder:SetDirection(oldDirection)
    end
end

function SortFilter:CanFilter(subcategory)
    return true
end

function SortFilter:Serialize(id, direction)
    local sortOrder = self.availableSortOrders[id]
    return sortOrder:Serialize(direction)
end

function SortFilter:Deserialize(state)
    local id, direction = SortOrderBase.Deserialize(state)
    if(not id or direction == nil) then
        logger:Warn("Could not deserialize sort filter state '%s'", state)
    end
    return id, direction
end

function SortFilter:GetTooltipText(id, direction)
    local sortOrder = self.availableSortOrders[id]
    return string.format("%s (%s)", sortOrder:GetLabel(), SORT_ORDER_TO_LABEL[direction])
end
