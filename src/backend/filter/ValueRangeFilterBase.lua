local AGS = AwesomeGuildStore

local FilterBase = AGS.class.FilterBase

local ClampValue = AGS.internal.ClampValue
local EncodeValue = AGS.EncodeValue
local DecodeValue = AGS.DecodeValue


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
    self.modifier = math.pow(10, config.precision or 0)
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

function ValueRangeFilterBase:Serialize(min, max)
    self.temp[1] = EncodeValue("integer", min * self.modifier)
    self.temp[2] = EncodeValue("integer", max * self.modifier)
    return table.concat(self.temp, ",")
end

function ValueRangeFilterBase:Deserialize(state)
    local min, max = zo_strsplit("," , state)
    min = DecodeValue("integer", min) / self.modifier
    max = DecodeValue("integer", max) / self.modifier
    return min, max
end
