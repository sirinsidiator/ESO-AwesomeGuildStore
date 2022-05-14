local AGS = AwesomeGuildStore

local FilterBase = AGS.class.FilterBase

local FILTER_ID = AGS.data.FILTER_ID
local CATEGORY_DEFINITION = AGS.data.CATEGORY_DEFINITION
local DEFAULT_SUBCATEGORY = AGS.data.SUB_CATEGORY_DEFINITION[AGS.data.DEFAULT_SUB_CATEGORY_ID[AGS.data.DEFAULT_CATEGORY_ID]]

local FilterState = ZO_Object:Subclass()
AGS.class.FilterState = FilterState

FilterState.ID_INDEX = 1
FilterState.VALUES_INDEX = 2
FilterState.STATE_INDEX = 3

local VERSION = "4"
local ID_SEPARATOR = ":"
local STATE_MATCHER = string.format("^(.-)%s(.-)$", ID_SEPARATOR)
local FIELD_SEPARATOR = ";"

-- TODO: use luadoc comments
function FilterState:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function FilterState.Deserialize(searchManager, state) -- TODO: see if this can be done elsewhere
    local filterState = {}
    local temp = {zo_strsplit(FIELD_SEPARATOR, state)}
    if(temp[1] == VERSION) then
        for i = 2, #temp do
            local id, state = string.match(temp[i], STATE_MATCHER)
            filterState[tonumber(id)] = state
        end
    end
    return FilterState:New(searchManager, filterState)
end

local function ById(a, b)
    return a[FilterState.ID_INDEX] < b[FilterState.ID_INDEX]
end

local function GenerateState(values)
    local temp = {}
    table.sort(values, ById)
    for i = 1, #values do
        local id, _, state = unpack(values[i])
        temp[#temp + 1] = string.format("%d%s%s", id, ID_SEPARATOR, state)
    end
    table.insert(temp, 1, VERSION)
    return table.concat(temp, FIELD_SEPARATOR)
end

-- expects a map of filterId -> serializedState
function FilterState:Initialize(searchManager, filterStates)
    local values = {}
    local valuesById = {}
    local valuesByGroup = {}
    self.subcategory = DEFAULT_SUBCATEGORY

    for id, filterState in pairs(filterStates) do
        local filter = searchManager:GetFilter(id)
        local group = FilterBase.GROUP_NONE
        local filterValues

        if(filter) then -- TODO how do we treat external filters that are not enabled?
            -- disabled filters should be added with group_none and an empty object for the filterValues
            group = filter:GetGroup()
            filterValues = { filter:Deserialize(filterState) }
            if(id == FILTER_ID.CATEGORY_FILTER) then
                self.subcategory = filterValues[1]
            end
        end

        valuesById[id] = {id, filterValues or {}, filterState}

        local groupValues = valuesByGroup[group] or {}
        groupValues[#groupValues + 1] = valuesById[id]
        valuesByGroup[group] = groupValues

        values[#values + 1] = valuesById[id]
    end

    local groups = {}
    local stateByGroup = {}
    for group, groupValues in pairs(valuesByGroup) do
        stateByGroup[group] = GenerateState(groupValues)
        groups[#groups + 1] = group
    end

    table.sort(groups)
    self.groups = groups
    self.state = GenerateState(values)
    self.stateByGroup = stateByGroup
    self.values = values
    self.valuesById = valuesById
    self.valuesByGroup = valuesByGroup
end

-- returns the subcategory object for this filter state
function FilterState:GetSubcategory()
    return self.subcategory
end

function FilterState:GetPendingCategories()
    local subcategory = self.subcategory
    return CATEGORY_DEFINITION[subcategory.category], subcategory
end

-- return an object containing {filterId, values, state}
-- or nil if the filter is not part of this state
function FilterState:GetRawFilterValues(id)
    return self.valuesById[id]
end

-- return true if the filter is part of this state
function FilterState:HasFilter(id)
    return self.valuesById[id] ~= nil
end

-- return an array of objects containing {filterId, values, state} sorted by filterId
-- or nil if the group is not part of this state
function FilterState:GetGroupValues(group)
    return self.valuesByGroup[group]
end

-- return an array of objects containing {filterId, values, state} sorted by filterId
function FilterState:GetValues()
    return self.values
end

-- return the state for a filter as a string
-- or nil if the filter is not part of this state
function FilterState:GetFilterState(id)
    local values = self.valuesById[id]
    if(not values) then return nil end
    return values[FilterState.STATE_INDEX]
end

-- return the individual values for a filter as multiple return values
-- or nil if the filter is not part of this state
function FilterState:GetFilterValues(id)
    local values = self.valuesById[id]
    if(not values) then return nil end
    return unpack(values[FilterState.VALUES_INDEX])
end

-- return the state for a group as a string
-- or nil if the group is not part of this state
function FilterState:GetGroupState(group)
    return self.stateByGroup[group]
end

-- return the state as a string
function FilterState:GetState()
    return self.state
end

-- return an array with all groups present in this state
function FilterState:GetGroups()
    return self.groups
end

FilterState.DEFAULT_STATE = FilterState:New(nil, {})
