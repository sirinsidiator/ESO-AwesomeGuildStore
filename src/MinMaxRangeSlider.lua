local MinMaxRangeSlider = ZO_Object:Subclass()
AwesomeGuildStore.MinMaxRangeSlider = MinMaxRangeSlider

function MinMaxRangeSlider:New(parent, name, x, y, width, height)
	local slider = ZO_Object.New(self)
	slider.min, slider.max, slider.step, slider.interval = 1, 2, 1, 0
	slider.enabled = true

	local control = CreateControlFromVirtual(name, parent, "AwesomeGuildStoreMinMaxRangeSliderTemplate")
	control:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
	control:SetDimensions(width, height)
	slider.control = control

	local minSlider = control:GetNamedChild("MinSlider")
	minSlider.value = 0
	minSlider.offset = -4
	minSlider.SetValue = self.SetMinValue
	slider.minSlider = minSlider

	local maxSlider = control:GetNamedChild("MaxSlider")
	maxSlider.value = 0
	maxSlider.offset = 4
	maxSlider.SetValue = self.SetMaxValue
	slider.maxSlider = maxSlider

	slider.rangeSlider = control:GetNamedChild("RangeSlider")

	slider.x, slider.y = x, y
	slider.offsetX = minSlider:GetWidth() / 2
	slider:SetMinMax(1, 2)
	slider:SetStepSize(1)
	slider:SetRange(1, 2)

	slider:InitializeHandlers()

	control.parent = slider
	slider.control = control

	return slider
end

function MinMaxRangeSlider:InitializeHandlers()
	local function PositionToValue(x)
		return math.floor((x - self.offsetX) / self.interval) + self.step
	end

	local function OnRangeDragStart(clickedControl, button)
		if self.enabled then
			clickedControl.dragging = true
			clickedControl.draggingXStart = GetUIMousePosition()
			clickedControl.dragStartOldX = self.minSlider.oldX
			clickedControl.difference = self.maxSlider.value - self.minSlider.value
		end
	end

	local function OnRangeDragStop(clickedControl, button, upInside)
		if clickedControl.dragging then
			clickedControl.dragging = false

			local totalDeltaX = GetUIMousePosition() - clickedControl.draggingXStart
			local newValue = PositionToValue(clickedControl.dragStartOldX + totalDeltaX)
			if(newValue ~= self.minSlider.value and not (newValue < self.min) and not (newValue + clickedControl.difference > self.max)) then
				self:SetMinValue(newValue)
				self:SetMaxValue(newValue + clickedControl.difference)
			end
		end
	end

	local function OnSliderDragStart(clickedControl, button)
		if self.enabled then
			clickedControl.dragging = true
			clickedControl.draggingXStart = GetUIMousePosition()
			clickedControl.dragStartOldX = clickedControl.oldX
		end
	end

	local function OnSliderDragStop(clickedControl)
		if clickedControl.dragging then
			clickedControl.dragging = false

			local totalDeltaX = GetUIMousePosition() - clickedControl.draggingXStart
			local newValue = PositionToValue(clickedControl.dragStartOldX + totalDeltaX)
			if(newValue ~= clickedControl.value) then clickedControl.SetValue(self, newValue) end
		end
	end

	local function OnSliderMouseUp(clickedControl, button, upInside)
		if clickedControl.dragging and button == 1 then
			OnSliderDragStop(clickedControl)
		end
	end

	local function OnSliderUpdate(control)
		if control.dragging then
			local totalDeltaX = GetUIMousePosition() - control.draggingXStart
			local newValue = PositionToValue(control.dragStartOldX + totalDeltaX)
			if(newValue ~= control.value) then control.SetValue(self, newValue) end
		end
	end

	local function OnRangeUpdate(control)
		if control.dragging then
			local totalDeltaX = GetUIMousePosition() - control.draggingXStart
			local newValue = PositionToValue(control.dragStartOldX + totalDeltaX)
			if(newValue ~= self.minSlider.value and not (newValue < self.min) and not (newValue + control.difference > self.max)) then
				self:SetMinValue(newValue)
				self:SetMaxValue(newValue + control.difference)
			end
		end
	end

	self.minSlider:SetHandler("OnDragStart", OnSliderDragStart)
	self.minSlider:SetHandler("OnMouseUp", OnSliderMouseUp)
	self.minSlider:SetHandler("OnUpdate", OnSliderUpdate)

	self.maxSlider:SetHandler("OnDragStart", OnSliderDragStart)
	self.maxSlider:SetHandler("OnMouseUp", OnSliderMouseUp)
	self.maxSlider:SetHandler("OnUpdate", OnSliderUpdate)

	self.rangeSlider:SetHandler("OnDragStart", OnRangeDragStart)
	self.rangeSlider:SetHandler("OnMouseUp", OnRangeDragStop)
	self.rangeSlider:SetHandler("OnUpdate", OnRangeUpdate)
end

function MinMaxRangeSlider:SetMinValue(value)
	if(value < self.min) then
		value = self.min
	elseif(value > self.maxSlider.value) then
		value = self.maxSlider.value
	end
	local x = self.x + self.offsetX + (value - self.step) * self.interval + self.minSlider.offset

	self.minSlider.value = value
	self.minSlider:ClearAnchors()
	self.minSlider:SetAnchor(TOPCENTER, self.control, TOPLEFT, x, 0)
	self.minSlider.oldX = x
	self:OnValueChanged(self:GetRange())
end

function MinMaxRangeSlider:SetMaxValue(value)
	if(value > self.max) then
		value = self.max
	elseif(value < self.minSlider.value) then
		value = self.minSlider.value
	end
	local x = self.x + self.offsetX + (value - self.step) * self.interval + self.maxSlider.offset

	self.maxSlider.value = value
	self.maxSlider:ClearAnchors()
	self.maxSlider:SetAnchor(TOPCENTER, self.control, TOPLEFT, x, 0)
	self.maxSlider.oldX = x
	self:OnValueChanged(self:GetRange())
end

function MinMaxRangeSlider:SetMinMax(min, max)
	self.min = min
	self.max = max
	self:SetStepSize(self:GetStepSize())
	self:SetRange(self:GetRange())
end

function MinMaxRangeSlider:SetRange(minValue, maxValue)
	self:SetMaxValue(maxValue)
	self:SetMinValue(minValue)
	if(self.maxSlider.value ~= maxValue) then
		self:SetMaxValue(maxValue) -- set again to prevent max not getting set to the right value when min is larger than max
	end
end

function MinMaxRangeSlider:GetRange()
	return self.minSlider.value, self.maxSlider.value
end

function MinMaxRangeSlider:SetStepSize(step)
	self.step = step
	self.interval = (self.control:GetWidth() - (self.minSlider:GetWidth() + self.maxSlider:GetWidth())) / ((self.max - self.min) * self.step)
end

function MinMaxRangeSlider:GetStepSize()
	return self.step
end

function MinMaxRangeSlider:SetEnabled(enable)
	self.enabled = enable
	self.minSlider:SetEnabled(enable)
	self.maxSlider:SetEnabled(enable)
	self.rangeSlider:SetEnabled(enable)
end

function MinMaxRangeSlider:IsEnabled()
	return self.enabled
end

function MinMaxRangeSlider:OnValueChanged(min, max)
-- overwrite this
end
