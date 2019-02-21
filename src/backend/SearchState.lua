local FilterState = AwesomeGuildStore.class.FilterState
local FILTER_ID = AwesomeGuildStore.data.FILTER_ID
local CATEGORY_DEFINITION = AwesomeGuildStore.data.CATEGORY_DEFINITION
local WriteToSavedVariable = AwesomeGuildStore.internal.WriteToSavedVariable
local ReadFromSavedVariable = AwesomeGuildStore.internal.ReadFromSavedVariable

local VERSION = "4"
local ID_SEPARATOR = ":"
local FIELD_SEPARATOR = ";"
local DEFAULT_PLACEHOLDER = "-"

local SearchState = ZO_Object:Subclass()
AwesomeGuildStore.SearchState = SearchState

SearchState.DEFAULT_STATE = string.format("%s%s%s", VERSION, FIELD_SEPARATOR, DEFAULT_PLACEHOLDER)
SearchState.nextId = 1

function SearchState:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

local REVERSE_FILTER_ID = {}
for name, id in pairs(FILTER_ID) do
    REVERSE_FILTER_ID[id] = name
end

local function DeserializeActiveFilters(active)
    active = {zo_strsplit(FIELD_SEPARATOR , active)}
    local deserialized = {}
    for i = 1, #active do
        local id = tonumber(active[i])
        if(id and REVERSE_FILTER_ID[id]) then
            deserialized[id] = true
        else
            df("Tried to deserialize non-existing filter id '%s'", tostring(id)) -- TODO use logger
        end
    end
    return deserialized
end

local function SerializeActiveFilters(active)
    local sorted = {}
    for id, active in pairs(active) do
        if(active) then
            if(REVERSE_FILTER_ID[id]) then
                sorted[#sorted + 1] = id
            else
                df("Tried to serialize non-existing filter id '%s'", tostring(id)) -- TODO use logger
            end
        end
    end
    table.sort(sorted)
    return table.concat(sorted, FIELD_SEPARATOR)
end

local function DeserializeFilterState(state)
    local filterState = {}
    local temp = {zo_strsplit(FIELD_SEPARATOR, state)}
    if(temp[1] == VERSION) then
        if(#temp > 2 or temp[2] ~= DEFAULT_PLACEHOLDER) then
            for i = 2, #temp do
                local id, state = zo_strsplit(ID_SEPARATOR, temp[i])
                filterState[tonumber(id)] = state
            end
        end
    end
    return filterState
end

local function SerializeFilterState(filterState)
    local temp = {}
    for id, state in pairs(filterState) do
        temp[#temp + 1] = string.format("%d%s%s", id, ID_SEPARATOR, state)
    end
    if(#temp == 0) then
        temp[#temp + 1] = DEFAULT_PLACEHOLDER
    else
        table.sort(temp)
    end
    table.insert(temp, 1, VERSION)
    return table.concat(temp, FIELD_SEPARATOR)
end

function SearchState:Initialize(searchManager, saveData)
    if(not saveData) then
        saveData = {
            id = SearchState.nextId,
            label = nil,
            active = "",
            state = FilterState.DEFAULT_STATE:GetState()
        }
        SearchState.nextId = SearchState.nextId + 1
    else
        SearchState.nextId = math.max(SearchState.nextId, saveData.id + 1)
    end

    self.searchManager = searchManager
    self.saveData = saveData

    self.id = saveData.id
    self.customLabel = (saveData.label ~= nil)
    self.filterActive = DeserializeActiveFilters(saveData.active)
    self.filterState = FilterState.Deserialize(searchManager, ReadFromSavedVariable(saveData, "state"))
    local values = self.filterState:GetValues()
    for i = 1, #values do
        self.filterActive[values[i][FilterState.ID_INDEX]] = true
    end
    saveData.active = SerializeActiveFilters(self.filterActive)
    self.applying = false
    self:Update()
end

function SearchState:Reset()
    local saveData = self.saveData
    saveData.label = nil
    self.customLabel = false

    saveData.active = ""
    ZO_ClearTable(self.filterActive)

    self.filterState = FilterState.DEFAULT_STATE
    saveData.state = self.filterState:GetState()

    self:Update()
    self:Apply()
end

function SearchState:GetSaveData()
    return self.saveData
end

function SearchState:GetFilterState()
    return self.filterState
end

function SearchState:HandleFilterChanged(filter)
    local id = filter:GetId()
    local state = nil
    if(filter:IsAttached() and not filter:IsDefault()) then
        state = filter:Serialize(filter:GetValues())
    end
    if(self.filterState:GetFilterState(id) ~= state) then
        df("handle filter changed %d, %d = %s", self.id, id, tostring(state))
        local filterStates = {}
        local values = self.filterState:GetValues()
        for i = 1, #values do
            local fid, _, fstate = unpack(values[i])
            filterStates[fid] = fstate
        end
        filterStates[id] = state

        self.filterState = FilterState:New(self.searchManager, filterStates)
        WriteToSavedVariable(self.saveData, "state", self.filterState:GetState())
        if(id == FILTER_ID.CATEGORY_FILTER) then
            self:Update()
        end
    end
end

function SearchState:Apply()
    self.applying = true
    local searchManager = self.searchManager
    local availableFilters = searchManager:GetAvailableFilters()
    for id, filter in pairs(availableFilters) do
        if(not self.filterState:GetRawFilterValues(id) and not filter:IsDefault()) then
            filter:Reset()
        end
    end
    local filterValues = self.filterState:GetValues()
    for i = 1, #filterValues do
        local id, values, state = unpack(filterValues[i])
        local filter = availableFilters[id]
        if(filter) then
            filter:SetValues(unpack(values)) -- TODO: transaction mode so we can change everything at once - still needed?
        end
    end
    self.applying = false

    AwesomeGuildStore:FireCallbacks(AwesomeGuildStore.callback.SELECTED_SEARCH_CHANGED, self)
end

function SearchState:IsApplying()
    return self.applying
end

function SearchState:Update()
    local subcategory = self.filterState:GetFilterValues(FILTER_ID.CATEGORY_FILTER)
    local category = CATEGORY_DEFINITION[subcategory.category]

    if(not self.customLabel) then
        if(subcategory.isDefault) then
            self.label = category.label
        else
            self.label = string.format("%s > %s", category.label, subcategory.label)
        end
    end

    if(subcategory.isDefault) then
        self.icon = category.icon
    else
        self.icon = subcategory.icon
    end
end

function SearchState:GetId()
    return self.id
end

function SearchState:SetLabel(label)
    self.label = label
    self.saveData.label = label
    self.customLabel = true
    self:Update()
end

function SearchState:ResetLabel()
    self.customLabel = false
    self.saveData.label = nil
    self:Update()
end

function SearchState:GetLabel()
    return self.label
end

function SearchState:HasCustomLabel()
    return self.customLabel
end

function SearchState:GetIcon()
    return self.icon
end

function SearchState:CreateDataEntry()
    return { -- TODO cache object
        id = self.id,
        label = self.label,
        icon = self.icon,
        state = self.state,
    }
end

function SearchState:IsFilterActive(filterId)
    return self.filterActive[filterId] == true
end

-- active filters change when
-- we select a item category
-- we add or remove a filter (disregard for now)
-- we pin or unpin a filter (disregard for now)
-- we change the active state
function SearchState:SetFilterActive(filter, active)
    if(not filter) then return false end
    local filterId = filter:GetId()
    if(self.filterActive[filterId] ~= active) then
        self.filterActive[filterId] = active
        self.saveData.active = SerializeActiveFilters(self.filterActive)
        return true
    end
    return false
end
