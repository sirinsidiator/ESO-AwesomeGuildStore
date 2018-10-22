local FilterBase = AwesomeGuildStore.class.FilterBase

local SILENT = true

local MultiChoiceFilterBase = FilterBase:Subclass()
AwesomeGuildStore.class.MultiChoiceFilterBase = MultiChoiceFilterBase

function MultiChoiceFilterBase:New(...)
    return FilterBase.New(self, ...)
end

function MultiChoiceFilterBase:Initialize(id, group, values)
    FilterBase.Initialize(self, id, group)
    self.values = values
    self.temp = {}

    local valueById = {}
    for i = 1, #values do
        local value = values[i]
        if(value.values) then
            for j = 1, #value.values do
                local subvalue = value.values[j]
                valueById[subvalue.id] = subvalue
            end
        else
            valueById[value.id] = value
        end
    end
    self.valueById = valueById

    self.selection = {}
    self:Reset(SILENT)
end

function MultiChoiceFilterBase:GetRawValues()
    return self.values
end

function MultiChoiceFilterBase:GetValue(id)
    return self.valueById[id]
end

function MultiChoiceFilterBase:SetSelected(value, selected, silent)
    local selection = self.selection
    if(selection[value] ~= selected) then
        local delta = selected and 1 or -1
        self.count = self.count + delta
        selection[value] = selected
        if(not silent) then
            self:HandleChange(selection)
        end
    end
end

function MultiChoiceFilterBase:IsSelected(value)
    return self.selection[value]
end

function MultiChoiceFilterBase:GetSelectionCount()
    return self.count
end

function MultiChoiceFilterBase:OnSelectionChanged()
    self:HandleChange(self.selection)
end

function MultiChoiceFilterBase:Reset(silent)
    local selection = self.selection
    for _, value in pairs(self.valueById) do
        selection[value] = false
    end

    self.count = 0
    if(not silent) then
        self:HandleChange(selection)
    end
end

function MultiChoiceFilterBase:IsDefault()
    return (self.count == 0)
end

function MultiChoiceFilterBase:GetValues()
    return ZO_ShallowTableCopy(self.selection)
end

function MultiChoiceFilterBase:SetValues(selection)
    local changed = false
    local currentSelection = self.selection
    for value, state in pairs(selection) do
        if(currentSelection[value] ~= state) then
            changed = true
        end
        self:SetSelected(value, state, SILENT)
    end

    self:HandleChange(currentSelection)
end

function MultiChoiceFilterBase:SetUpLocalFilter(selection)
    self.localSelection = selection
    return next(selection) ~= nil
end

local DEFAULT_PLACEHOLDER = "-"
local BOOLEAN_TRUE = tostring(true) -- TODO: move somewhere?
local BOOLEAN_FALSE = tostring(false)
local function DeserializeId(value)
    if(value == BOOLEAN_TRUE) then
        return true
    elseif(value == BOOLEAN_FALSE) then
        return false
    else
        local number = tonumber(value)
        if(number) then
            return number
        end
    end
    return value
end

function MultiChoiceFilterBase:Serialize(selection)
    local temp = self.temp
    ZO_ClearTable(temp)
    for value, selected in pairs(selection) do
        if(selected) then
            temp[#temp + 1] = tostring(value.id)
        end
    end
    table.sort(temp)

    return table.concat(temp, ",")
end

function MultiChoiceFilterBase:Deserialize(state)
    local selection = {}
    local ids = {zo_strsplit("," , state)}

    for _, value in pairs(self.valueById) do
        selection[value] = false
    end

    for i = 1, #ids do
        local id = DeserializeId(ids[i])
        local value = self.valueById[id]
        if(value) then
            selection[value] = true
        end
    end

    return selection
end
