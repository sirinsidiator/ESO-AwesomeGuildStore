local mfloor = math.floor
local GetUIMousePosition = GetUIMousePosition
local GetFrameTimeSeconds = GetFrameTimeSeconds

local TOPLEFT = TOPLEFT
local TOPCENTER = TOPCENTER
local MOUSE_BUTTON_INDEX_LEFT = MOUSE_BUTTON_INDEX_LEFT

local FULL_RANGE_UPDATE_DELAY = 0.15 -- seconds
local MIN_SLIDER_HORIZONTAL_OFFSET = -4
local MAX_SLIDER_HORIZONTAL_OFFSET = 4
local ENABLED_DESATURATION = 0
local DISABLED_DESATURATION = 1

local MinMaxRangeSlider = ZO_Object:Subclass()
AwesomeGuildStore.class.MinMaxRangeSlider = MinMaxRangeSlider

function MinMaxRangeSlider:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function MinMaxRangeSlider:Initialize(name, parent)
    local control = CreateControlFromVirtual(name, parent, "AwesomeGuildStoreMinMaxRangeSliderTemplate")
    control.parent = self
    self.control = control

    local function OnSliderDragStart(...)
        return self:OnSliderDragStart(...)
    end

    local function OnSliderMouseUp(...)
        return self:OnSliderMouseUp(...)
    end

    local function OnSliderUpdate(...)
        return self:OnSliderUpdate(...)
    end

    self.step = 1
    self.min = 1
    self.max = 2
    self.minRange = 0

    local minSlider = control:GetNamedChild("MinSlider")
    minSlider.value = self.min
    minSlider.offset = MIN_SLIDER_HORIZONTAL_OFFSET
    minSlider.SetValue = self.SetMinValue
    minSlider:ClearAnchors()
    minSlider:SetHandler("OnDragStart", OnSliderDragStart)
    minSlider:SetHandler("OnMouseUp", OnSliderMouseUp)
    minSlider:SetHandler("OnUpdate", OnSliderUpdate)
    self.minSlider = minSlider

    local maxSlider = control:GetNamedChild("MaxSlider")
    maxSlider.value = self.max
    maxSlider.offset = MAX_SLIDER_HORIZONTAL_OFFSET
    maxSlider.SetValue = self.SetMaxValue
    maxSlider:ClearAnchors()
    maxSlider:SetHandler("OnDragStart", OnSliderDragStart)
    maxSlider:SetHandler("OnMouseUp", OnSliderMouseUp)
    maxSlider:SetHandler("OnUpdate", OnSliderUpdate)
    self.maxSlider = maxSlider

    local rangeSlider = control:GetNamedChild("RangeSlider")
    rangeSlider:SetHandler("OnDragStart", function(...) return self:OnRangeDragStart(...) end)
    rangeSlider:SetHandler("OnMouseUp", function(...) return self:OnRangeDragStop(...) end)
    rangeSlider:SetHandler("OnUpdate", function(...) return self:OnRangeUpdate(...) end)
    self.rangeSlider = rangeSlider

    local fullRange = control:GetNamedChild("FullRange")
    fullRange:SetHandler("OnMouseDown", function(...) return self:OnFullRangeMouseDown(...) end)
    fullRange:SetHandler("OnMouseUp", function(...) return self:OnFullRangeMouseUp(...) end)
    fullRange:SetHandler("OnUpdate", function(...) return self:OnFullRangeUpdate(...) end)
    self.fullRange = fullRange

    self.glow = control:GetNamedChild("Glow")

    self:UpdateVisuals()
    self:SetRangeValue(self:GetMinMax())

    self:SetEnabled(true)
end

function MinMaxRangeSlider:PositionToValue(x)
    return mfloor((x - self.offsetX) / self.interval) + self.step
end

function MinMaxRangeSlider:OnRangeDragStart(clickedControl, button)
    if(not self.enabled) then return end

    clickedControl.dragging = true
    clickedControl.draggingXStart = GetUIMousePosition()
    clickedControl.dragStartOldX = self.minSlider.oldX
    clickedControl.difference = self.maxSlider.value - self.minSlider.value
end

function MinMaxRangeSlider:OnRangeDragStop(clickedControl, button, upInside)
    if(not clickedControl.dragging) then return end

    clickedControl.dragging = false

    local totalDeltaX = GetUIMousePosition() - clickedControl.draggingXStart
    local newValue = self:PositionToValue(clickedControl.dragStartOldX + totalDeltaX)
    if(newValue ~= self.minSlider.value and not (newValue < self.min) and not (newValue + clickedControl.difference > self.max)) then
        self:SetMinValue(newValue)
        self:SetMaxValue(newValue + clickedControl.difference)
    end
end

function MinMaxRangeSlider:OnRangeUpdate(control)
    if(not control.dragging) then return end

    local totalDeltaX = GetUIMousePosition() - control.draggingXStart
    local newValue = self:PositionToValue(control.dragStartOldX + totalDeltaX)
    if(newValue ~= self.minSlider.value and not (newValue < self.min) and not (newValue + control.difference > self.max)) then
        self:SetMinValue(newValue)
        self:SetMaxValue(newValue + control.difference)
    end
end

function MinMaxRangeSlider:OnSliderDragStart(clickedControl, button)
    if(not self.enabled) then return end

    clickedControl.dragging = true
    clickedControl.draggingXStart = GetUIMousePosition()
    clickedControl.dragStartOldX = clickedControl.oldX
end

function MinMaxRangeSlider:OnSliderDragStop(clickedControl)
    if(not clickedControl.dragging) then return end

    clickedControl.dragging = false

    local totalDeltaX = GetUIMousePosition() - clickedControl.draggingXStart
    local newValue = self:PositionToValue(clickedControl.dragStartOldX + totalDeltaX)
    if(newValue ~= clickedControl.value) then
        clickedControl.SetValue(self, newValue)
    end
end

function MinMaxRangeSlider:OnSliderMouseUp(clickedControl, button)
    if(clickedControl.dragging and button == MOUSE_BUTTON_INDEX_LEFT) then
        self:OnSliderDragStop(clickedControl)
    end
end

function MinMaxRangeSlider:OnSliderUpdate(control)
    if(not control.dragging) then return end

    local totalDeltaX = GetUIMousePosition() - control.draggingXStart
    local newValue = self:PositionToValue(control.dragStartOldX + totalDeltaX)
    if(newValue ~= control.value) then
        control.SetValue(self, newValue)
    end
end

function MinMaxRangeSlider:OnFullRangeMouseDown(control, button)
    local offset = control:GetScreenRect() - self.interval / 2 - self.minSlider.offset
    control.pressedValue = self:PositionToValue(GetUIMousePosition() - offset)
    control.isPressed = true
    control.lastUpdateTime = GetFrameTimeSeconds()
    control.updateCount = 0
    control.moveDistance = 1
end

function MinMaxRangeSlider:OnFullRangeMouseUp(control)
    control.isPressed = false
end

function MinMaxRangeSlider:OnFullRangeUpdate(control, time)
    if(not control.isPressed or (time - control.lastUpdateTime) < FULL_RANGE_UPDATE_DELAY) then return end

    local min, max = self:GetRangeValue()
    local avg = mfloor((min + max) / 2)

    if(control.pressedValue < min) then
        local value = min - control.moveDistance
        self:SetMinValue((value < control.pressedValue) and control.pressedValue or value)
    elseif(control.pressedValue > min and control.pressedValue < avg) then
        local value = min + control.moveDistance
        self:SetMinValue((value > control.pressedValue) and control.pressedValue or value)
    elseif(control.pressedValue > avg and control.pressedValue < max) then
        local value = max - control.moveDistance
        self:SetMaxValue((value < control.pressedValue) and control.pressedValue or value)
    elseif(control.pressedValue > max) then
        local value = max + control.moveDistance
        self:SetMaxValue((value > control.pressedValue) and control.pressedValue or value)
    end

    control.lastUpdateTime = time
    control.updateCount = control.updateCount + 1
    if(control.updateCount > 2) then
        control.moveDistance = control.moveDistance * 2
        control.updateCount = 0
    end
end

function MinMaxRangeSlider:UpdateSliderAnchor(slider)
    local x = self.offsetX + (slider.value - self.min + 1 - self.step) * self.interval + slider.offset
    slider:SetAnchor(TOPCENTER, self.control, TOPLEFT, x, 0)
    slider.oldX = x
end

function MinMaxRangeSlider:UpdateVisuals()
    self.offsetX = self.minSlider:GetWidth() / 2
    self.interval = (self.control:GetWidth() - (self.minSlider:GetWidth() + self.maxSlider:GetWidth())) / ((self.max - self.min) * self.step)
    self:UpdateSliderAnchor(self.minSlider)
    self:UpdateSliderAnchor(self.maxSlider)
end

function MinMaxRangeSlider:SetWidth(width)
    self.control:SetWidth(width)
    self:UpdateVisuals()
end

function MinMaxRangeSlider:SetMinValue(value)
    if(not value or value < self.min) then
        value = self.min
    elseif(value > self.maxSlider.value - self.minRange) then
        value = self.maxSlider.value - self.minRange
    end

    if(self.minSlider.value == value) then return end

    self.minSlider.value = value
    self:UpdateSliderAnchor(self.minSlider)
    self:OnValueChanged(self:GetRangeValue())
end

function MinMaxRangeSlider:SetMaxValue(value)
    if(not value or value > self.max) then
        value = self.max
    elseif(value < self.minSlider.value + self.minRange) then
        value = self.minSlider.value + self.minRange
    end

    if(self.maxSlider.value == value) then return end

    self.maxSlider.value = value
    self:UpdateSliderAnchor(self.maxSlider)
    self:OnValueChanged(self:GetRangeValue())
end

function MinMaxRangeSlider:SetMinMax(min, max)
    self.min = min
    self.max = max
    self:SetRangeValue(self:GetRangeValue())
end

function MinMaxRangeSlider:GetMinMax()
    return self.min, self.max
end

function MinMaxRangeSlider:SetRangeValue(minValue, maxValue)
    self:SetMaxValue(maxValue)
    self:SetMinValue(minValue)
    -- set again to prevent max not getting set to the right value when min is larger than max
    self:SetMaxValue(maxValue)
end

function MinMaxRangeSlider:GetRangeValue()
    return self.minSlider.value, self.maxSlider.value
end

-- sets the smallest allowed difference between min and max value 
function MinMaxRangeSlider:SetMinRange(value)
    if(self.minRange == value) then return end

    self.minRange = value
    self:SetRangeValue(self:GetRangeValue())
end

function MinMaxRangeSlider:GetMinRange(value)
    return self.minRange
end

function MinMaxRangeSlider:GetRangeValue()
    return self.minSlider.value, self.maxSlider.value
end

function MinMaxRangeSlider:SetStepSize(step)
    if(self.step == step) then return end

    self.step = step
    self:UpdateVisuals()
end

function MinMaxRangeSlider:GetStepSize()
    return self.step
end

function MinMaxRangeSlider:SetEnabled(enabled)
    self.enabled = enabled
    self.minSlider:SetEnabled(enabled)
    self.maxSlider:SetEnabled(enabled)
    self.rangeSlider:SetEnabled(enabled)
    self.fullRange:SetEnabled(enabled)

    local desaturation = enabled and ENABLED_DESATURATION or DISABLED_DESATURATION
    self.glow:SetDesaturation(desaturation)
    self.minSlider:SetDesaturation(desaturation)
    self.maxSlider:SetDesaturation(desaturation)
    self.rangeSlider:SetDesaturation(desaturation)
end

function MinMaxRangeSlider:IsEnabled()
    return self.enabled
end

function MinMaxRangeSlider:OnValueChanged(min, max)
-- overwrite this
end
