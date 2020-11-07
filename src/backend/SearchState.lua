local AGS = AwesomeGuildStore

local FilterState = AGS.class.FilterState
local FILTER_ID = AGS.data.FILTER_ID
local CATEGORY_DEFINITION = AGS.data.CATEGORY_DEFINITION
local WriteToSavedVariable = AGS.internal.WriteToSavedVariable
local ReadFromSavedVariable = AGS.internal.ReadFromSavedVariable

local logger = AGS.internal.logger

local SearchState = ZO_Object:Subclass()
AGS.class.SearchState = SearchState

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
    saveData.automatic = nil
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

function SearchState:SetAutomatic(automatic)
    if automatic then
        logger:Verbose("set automatic search")
        self.saveData.automatic = true
    else
        if self.saveData.automatic then
            logger:Verbose("unset automatic search")
            self.saveData.automatic = nil
            AGS.internal:FireCallbacks(AGS.callback.SEARCH_LIST_CHANGED, true)
        end
    end
end

function SearchState:IsAutomatic()
    return self.saveData.automatic == true
end

function SearchState:GetSaveData()
    return self.saveData
end

function SearchState:GetFilterState()
    return self.filterState
end

function SearchState:HandleFilterChanged(filter, fromSearchItem)
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

        if not fromSearchItem then
            self:SetAutomatic(false)
        end
    end
end

function SearchState:Apply()
    local searchManager = self.searchManager
    if self ~= searchManager.activeSearch then return end

    self.applying = true
    local availableFilters = searchManager:GetAvailableFilters()
    for id, filter in pairs(availableFilters) do
        if(not self.filterState:HasFilter(id) and not filter:IsDefault()) then
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

    AGS.internal:FireCallbacks(AGS.callback.SELECTED_SEARCH_CHANGED, self)
end

function SearchState:IsApplying()
    return self.applying
end

function SearchState:Update()
    local label = self.label
    local icons = self.icons

    local subcategory = self.filterState:GetSubcategory()
    local category = CATEGORY_DEFINITION[subcategory.category]

    if(not self.customLabel) then
        if(subcategory.isDefault) then
            self.label = category.label
        else
            self.label = string.format("%s > %s", category.label, subcategory.label)
        end
    end

    if(subcategory.isDefault) then
        self.icons = category.icons
    else
        self.icons = subcategory.icons
    end

    if(label ~= self.label or icons ~= self.icons) then
        AGS.internal:FireCallbacks(AGS.callback.SEARCH_LIST_CHANGED)
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

function SearchState:GetIcons()
    return self.icons
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
