local FilterBase = AwesomeGuildStore.class.FilterBase
local EncodeValue = AwesomeGuildStore.EncodeValue
local DecodeValue = AwesomeGuildStore.DecodeValue

local SILENT = true

local MultiChoiceFilterBase = FilterBase:Subclass()
AwesomeGuildStore.class.MultiChoiceFilterBase = MultiChoiceFilterBase

function MultiChoiceFilterBase:New(...)
    return FilterBase.New(self, ...)
end

function MultiChoiceFilterBase:Initialize(id, group, values)
    FilterBase.Initialize(self, id, group)

    -- detect the encoding based on the used value types
    local first = values[1]
    if(first.values) then
        first = first.values[1]
    end
    self.encoding = type(first.id)

    -- for numbers, we default to integer, since it is more compact
    -- if a filter needs a different encoding they have to specify it
    if(self.encoding == "number") then self.encoding = "integer" end

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

function MultiChoiceFilterBase:SetEncoding(encoding)
    self.encoding = encoding
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

function MultiChoiceFilterBase:Serialize(selection)
    local temp = self.temp
    ZO_ClearTable(temp)
    for value, selected in pairs(selection) do
        if(selected) then
            temp[#temp + 1] = EncodeValue(self.encoding, value.id)
        end
    end
    table.sort(temp)

    return table.concat(temp, ",")
end

function MultiChoiceFilterBase:Deserialize(state)
    local selection = {}
    local ids
    if(self.encoding == "boolean") then
        -- boolean uses an empty string to express false, which is ignored by zo_strsplit
        if(string.find(state, ",")) then
            ids = {string.match(state, "^(.-),(.-)$")}
        else
            ids = {state}
        end
    else
        ids = {zo_strsplit("," , state)}
    end

    for _, value in pairs(self.valueById) do
        selection[value] = false
    end

    if(#ids > 0) then
        for i = 1, #ids do
            local id = DecodeValue(self.encoding, ids[i])
            local value = self.valueById[id]
            if(value) then
                selection[value] = true
            end
        end
    end

    return selection
end

function MultiChoiceFilterBase:GetTooltipText(selection)
    local temp = self.temp
    ZO_ClearTable(temp)
    for value, selected in pairs(selection) do
        if(selected) then
            temp[#temp + 1] = value.label
        end
    end
    return table.concat(temp, ", ")
end
