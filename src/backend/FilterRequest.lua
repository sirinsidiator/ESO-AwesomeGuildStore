local AGS = AwesomeGuildStore

local logger = AGS.internal.logger


local FilterRequest = ZO_InitializingObject:Subclass()
AGS.class.FilterRequest = FilterRequest

function FilterRequest:Initialize(filterState, activeFilters)
    self.filterState = filterState
    self.activeFilters = activeFilters
    self.values = {}
end

function FilterRequest:GetPendingCategories()
    return self.filterState:GetPendingCategories()
end

function FilterRequest:SetFilterValues(type, ...)
    self.values[type] = {...}
end

function FilterRequest:SetFilterRange(type, min, max)
    local values = self.values[type] or {}
    values.min = min
    values.max = max
    self.values[type] = values
end

function FilterRequest:Apply()
    local activeFilters = self.activeFilters
    logger:Verbose("Apply %d active filters", #activeFilters)
    for _, filter in ipairs(activeFilters) do
        filter:ApplyToSearch(self)
    end

    ClearAllTradingHouseSearchTerms()
    for type, values in pairs(self.values) do
        if(values.min) then
            SetTradingHouseFilterRange(type, values.min, values.max)
        else
            SetTradingHouseFilter(type, unpack(values))
        end
    end
end