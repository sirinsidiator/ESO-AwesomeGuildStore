local AGS = AwesomeGuildStore

local FilterBase = AGS.class.FilterBase

local ClampValue = AGS.internal.ClampValue


local ValueRangeFilterBase = FilterBase:Subclass()
AGS.class.ValueRangeFilterBase = ValueRangeFilterBase

function ValueRangeFilterBase:New(...)
    return FilterBase.New(self, ...)
end

function ValueRangeFilterBase:Initialize(id, group, config)
    FilterBase.Initialize(self, id, group)
    self:SetLabel(config.label)
    self:SetEnabledSubcategories(config.enabled)
    self.config = config
    self.serializationFormat = string.format("%%.%df", config.precision or 0)
    self.temp = {}
    self.min = config.min
    self.max = config.max
end

function ValueRangeFilterBase:GetConfig()
    return self.config
end

function ValueRangeFilterBase:GetValues()
    return self.min, self.max
end

function ValueRangeFilterBase:SetValues(min, max)
    local config = self.config
    min = ClampValue(min or config.min, config.min, config.max)
    max = ClampValue(max or config.max, config.min, config.max)

    local minChanged = (min ~= self.min)
    local maxChanged = (max ~= self.max)
    if(min > max) then
        if(maxChanged) then
            max = min
        elseif(maxChanged) then
            min = max
        end
    end

    self.min = min
    self.max = max

    if(minChanged or maxChanged) then
        self:HandleChange(min, max)
    end
end

function ValueRangeFilterBase:SetUpLocalFilter(min, max)
    self.localMin = min
    self.localMax = max
    return (min ~= self.config.min or max ~= self.config.max)
end

function ValueRangeFilterBase:Reset()
    self:SetValues(nil, nil)
end

function ValueRangeFilterBase:IsDefault()
    return not (self.min ~= self.config.min or self.max ~= self.config.max)
end

local DEFAULT_PLACEHOLDER = "-" -- TODO: use codec?
local function SerializeNumber(format, value, default)
    if(value ~= default) then
        return string.format(format, value)
    else
        return DEFAULT_PLACEHOLDER
    end
end

function ValueRangeFilterBase:Serialize(min, max)
    self.temp[1] = SerializeNumber(self.serializationFormat, min, self.config.min)
    self.temp[2] = SerializeNumber(self.serializationFormat, max, self.config.max)
    return table.concat(self.temp, ",")
end

function ValueRangeFilterBase:Deserialize(state)
    local min, max = zo_strsplit("," , state)
    return tonumber(min) or self.config.min, tonumber(max) or self.config.max
end
