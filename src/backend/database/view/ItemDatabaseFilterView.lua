local AGS = AwesomeGuildStore

local BaseItemDatabaseView = AGS.class.BaseItemDatabaseView
local FilterBase = AGS.class.FilterBase

local ItemDatabaseFilterView = BaseItemDatabaseView:Subclass()
AGS.class.ItemDatabaseFilterView = ItemDatabaseFilterView

BaseItemDatabaseView.CLASS_BY_GROUP[FilterBase.GROUP_CATEGORY] = ItemDatabaseFilterView -- TODO: find a way to separate items by category when they are received
BaseItemDatabaseView.CLASS_BY_GROUP[FilterBase.GROUP_SERVER] = ItemDatabaseFilterView -- TODO: is this even needed when we only have one filter view?
BaseItemDatabaseView.CLASS_BY_GROUP[FilterBase.GROUP_LOCAL] = ItemDatabaseFilterView

function ItemDatabaseFilterView:New(...)
    return BaseItemDatabaseView.New(self, ...)
end

function ItemDatabaseFilterView:Initialize(searchManager, filterStates, subcategory)
    BaseItemDatabaseView.Initialize(self)

    local filters = {}
    local filterValues = {}
    for i = 1, #filterStates do
        local id, values = unpack(filterStates[i])
        local filter = searchManager:GetFilter(id)
        if(filter) then
            local index = #filters + 1
            filters[index] = filter
            filterValues[index] = values
        end
    end
    self.filters = filters
    self.filterValues = filterValues
    self.subcategory = subcategory
end

function ItemDatabaseFilterView:PrepareFilterFunction(activeFilters)
    if(#activeFilters == 0) then return end

    return function(result)
        if(not result or result.name == "" or result.stackCount == 0) then return false end
        for i = 1, #activeFilters do
            if(not activeFilters[i]:FilterLocalResult(result)) then
                return true
            end
        end
        return false
    end
end

function ItemDatabaseFilterView:UpdateItems()
    -- before
    local filters = self.filters
    local activeFilters = {}
    for i = 1, #filters do
        local filter = filters[i]
        if(filter:CanFilter(self.subcategory) and filter:SetUpLocalFilter(unpack(self.filterValues[i]))) then
            activeFilters[#activeFilters + 1] = filter
        end
    end
    -- TODO: sort activeFilters by resource cost -> cheap filters come first
    -- table.sort(activeFilters, ByCost)

    local FilterItem = self:PrepareFilterFunction(activeFilters)

    local parentItems = self.parent:GetItems()
    local items = self.items
    ZO_ClearNumericallyIndexedTable(items)
    for i = 1, #parentItems do
        local item = parentItems[i]
        if(not FilterItem or not FilterItem(item)) then
            items[#items + 1] = item
        end
    end

    -- after
    for i = 1, #activeFilters do
        activeFilters[i]:TearDownLocalFilter()
    end
end
