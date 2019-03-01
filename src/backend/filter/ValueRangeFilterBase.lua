local AGS = AwesomeGuildStore

local FilterBase = AGS.class.FilterBase

local ClampValue = AGS.internal.ClampValue
local gettext = AGS.internal.gettext
local EncodeValue = AGS.internal.EncodeValue
local DecodeValue = AGS.internal.DecodeValue

local DONT_USE_SHORT_FORMAT = false

local ValueRangeFilterBase = FilterBase:Subclass()
AGS.class.ValueRangeFilterBase = ValueRangeFilterBase

function ValueRangeFilterBase:New(...)
    return FilterBase.New(self, ...)
end

function ValueRangeFilterBase:Initialize(id, group, config)
    FilterBase.Initialize(self, id, group, config.label)
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
        if(minChanged) then
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

function ValueRangeFilterBase:PrepareForSearch(min, max)
    self.serverMin = min
    self.serverMax = max
end

function ValueRangeFilterBase:SetUpLocalFilter(min, max)
    self.localMin = min
    self.localMax = max
    return (min ~= self.config.min or max ~= self.config.max)
end

function ValueRangeFilterBase:Reset()
    self:SetValues(nil, nil)
end

function ValueRangeFilterBase:IsDefault(min, max)
    min = min or self.min
    max = max or self.max
    return not (min ~= self.config.min or max ~= self.config.max)
end

function ValueRangeFilterBase:Serialize(min, max)
    self.temp[1] = EncodeValue("integer", min * self.modifier)
    self.temp[2] = EncodeValue("integer", max * self.modifier)
    return table.concat(self.temp, ",")
end

function ValueRangeFilterBase:Deserialize(state)
    local min, max = string.match(state, "^(.-),(.-)$")
    min = DecodeValue("integer", min) / self.modifier
    max = DecodeValue("integer", max) / self.modifier
    return min, max
end

function ValueRangeFilterBase:GetFormattedValue(value)
    if(self.config.currency) then
        return ZO_CurrencyControl_FormatCurrencyAndAppendIcon(value, DONT_USE_SHORT_FORMAT, self.config.currency)
    else
        return zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(value))
    end
end

function ValueRangeFilterBase:GetTooltipText(min, max)
    local text = ""
    local hasMin = (min ~= self.config.min)
    local hasMax = (max ~= self.config.max)
    if(hasMin and hasMax) then
        if(min == max) then
            text = gettext("exactly <<1>>", self:GetFormattedValue(min))
        else
            text = gettext("<<1>> - <<2>>", self:GetFormattedValue(min), self:GetFormattedValue(max))
        end
    elseif(hasMin) then
        text = gettext("over <<1>>", self:GetFormattedValue(min))
    elseif(hasMax) then
        text = gettext("under <<1>>", self:GetFormattedValue(max))
    end

    return text
end