local FilterState = AwesomeGuildStore.class.FilterState
local FILTER_ID = AwesomeGuildStore.data.FILTER_ID
local CATEGORY_DEFINITION = AwesomeGuildStore.data.CATEGORY_DEFINITION
local SUB_CATEGORY_DEFINITION = AwesomeGuildStore.data.SUB_CATEGORY_DEFINITION
local DEFAULT_CATEGORY_ID = AwesomeGuildStore.data.DEFAULT_CATEGORY_ID
local DEFAULT_SUB_CATEGORY_ID = AwesomeGuildStore.data.DEFAULT_SUB_CATEGORY_ID
local WriteToSavedVariable = AwesomeGuildStore.internal.WriteToSavedVariable
local ReadFromSavedVariable = AwesomeGuildStore.internal.ReadFromSavedVariable

local SearchState = ZO_Object:Subclass()
AwesomeGuildStore.SearchState = SearchState

function SearchState:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function SearchState:Initialize(searchManager, saveData)
    if(not saveData) then
        saveData = {
            label = nil,
            state = FilterState.DEFAULT_STATE:GetState(),
            history = {}, -- TODO implement
            enabled = true
        }
    end

    self.searchManager = searchManager
    self.saveData = saveData

    self.label = saveData.label
    self.customLabel = (saveData.label ~= nil)
    self.filterActive = {}
    self.filterState = FilterState.Deserialize(searchManager, ReadFromSavedVariable(saveData, "state"))
    self.applying = false
    self:Update()
end

function SearchState:Reset()
    local saveData = self.saveData
    saveData.label = nil
    saveData.enabled = true
    self.customLabel = false

    ZO_ClearTable(self.filterActive)

    self.filterState = FilterState.DEFAULT_STATE
    saveData.state = self.filterState:GetState()

    self:Update()
    self:Apply()
end

function SearchState:GetIndex()
    return self.sortIndex -- sort index is managed by the sort filter list
end

function SearchState:SetEnabled(enabled)
    self.saveData.enabled = enabled
end

function SearchState:IsEnabled()
    return self.saveData.enabled
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
    if(not subcategory) then
        subcategory = SUB_CATEGORY_DEFINITION[DEFAULT_SUB_CATEGORY_ID[DEFAULT_CATEGORY_ID]]
    end
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

function SearchState:GetDataEntry(type)
    if(not self.dataEntry) then
        ZO_ScrollList_CreateDataEntry(type, self)
    end
    return self.dataEntry
end

function SearchState:IsFilterActive(filterId)
    return self.filterActive[filterId] == true
end

function SearchState:SetFilterActive(filter, active)
    if(not filter) then return false end
    local filterId = filter:GetId()
    if(self.filterActive[filterId] ~= active) then
        self.filterActive[filterId] = active
        return true
    end
    return false
end
