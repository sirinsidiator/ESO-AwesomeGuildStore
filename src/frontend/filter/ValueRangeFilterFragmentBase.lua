local AGS = AwesomeGuildStore

local MinMaxRangeSlider = AGS.class.MinMaxRangeSlider
local FilterFragment = AGS.class.FilterFragment

local gettext = AGS.internal.gettext


local ValueRangeFilterFragmentBase = FilterFragment:Subclass()
AGS.class.ValueRangeFilterFragmentBase = ValueRangeFilterFragmentBase

function ValueRangeFilterFragmentBase:New(...)
    return FilterFragment.New(self, ...)
end

function ValueRangeFilterFragmentBase:Initialize(filterId)
    FilterFragment.Initialize(self, filterId)
    self.fromFilter = false

    local container = self:GetContainer()
    local config = self.filter:GetConfig()

    local slider = MinMaxRangeSlider:New("$(parent)Slider", container)
    if(config.steps) then
        slider:SetMinMax(1, #config.steps)
    else
        slider:SetMinMax(config.min, config.max)
    end
    slider:SetMinRange(config.minRange or 0)
    slider:SetRangeValue(slider:GetMinMax())
    slider.control:ClearAnchors()
    slider.control:SetAnchor(TOPLEFT, container, TOPLEFT, 5, 0)
    slider.control:SetAnchor(TOPRIGHT, container, TOPRIGHT, -5, 0)
    slider:UpdateVisuals()

    slider.OnValueChanged = function(slider, min, max)
        if(self.fromFilter) then return end
        min, max = self:ToNearestValue(min), self:ToNearestValue(max)
        self.filter:SetValues(min, max)
    end

    self.slider = slider
end

function ValueRangeFilterFragmentBase:ToNearestValue(value)
    return value
end

function ValueRangeFilterFragmentBase:OnValueChanged(min, max)
    self.fromFilter = true
    self.slider:SetRangeValue(min, max)
    self.fromFilter = false
end

function ValueRangeFilterFragmentBase:SetEnabled(enabled)
    FilterFragment.SetEnabled(self, enabled)
    self.slider:SetEnabled(enabled)
end
