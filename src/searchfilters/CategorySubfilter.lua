local L = AwesomeGuildStore.Localization
local ButtonGroup = AwesomeGuildStore.ButtonGroup
local ToggleButton = AwesomeGuildStore.ToggleButton
local SimpleIconButton = AwesomeGuildStore.SimpleIconButton
local FilterBase = AwesomeGuildStore.FilterBase

local CategorySubfilter = FilterBase:Subclass()
AwesomeGuildStore.CategorySubfilter = CategorySubfilter

local BUTTON_SIZE = 32
local BUTTONS_PER_ROW = 7
local BUTTON_OFFSET_Y = 20
local LINE_SPACING = 4

function CategorySubfilter:New(name, tradingHouseWrapper, subfilterPreset, ...)
	return FilterBase.New(self, subfilterPreset.type, name, tradingHouseWrapper, subfilterPreset, ...)
end

function CategorySubfilter:Initialize(name, tradingHouseWrapper, subfilterPreset)
	local container = self.container
	self.preset = subfilterPreset

	local label = container:CreateControl(name .. "Label", CT_LABEL)
	label:SetFont("ZoFontWinH4")
	label:SetText(subfilterPreset.label .. ":")
	self:SetLabelControl(label)

	local group = ButtonGroup:New(container, name .. "Group", 0, 0)
	group.filterType = subfilterPreset.filter
	self.group = group

	local buttons = {}
	self.buttons = buttons
	for index, buttonPreset in ipairs(subfilterPreset.buttons) do
		local button = ToggleButton:New(group.control, group.control:GetName() .. "Button" .. index, buttonPreset.texture, 0, 0, BUTTON_SIZE, BUTTON_SIZE, buttonPreset.label)
		button.HandlePress = function()
			if(group.pressedButtonCount >= 8) then
				ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, L["WARNING_SUBFILTER_LIMIT"])
				self.resetButton:SetHidden(false)
				return false
			end
			if(subfilterPreset.singleButtonMode) then
				group:ReleaseAllButtons()
			end
			self:HandleChange()
			return true
		end
		button.HandleRelease = function(control, fromGroup)
			if(not fromGroup) then
				self:HandleChange()
			end
			return true
		end
		button.value = buttonPreset.value
		button.index = index
		group:AddButton(button)
		buttons[#buttons + 1] = button
	end

	container:SetHeight(label:GetHeight() + LINE_SPACING + group.control:GetHeight())

	local tooltipText = L["RESET_FILTER_LABEL_TEMPLATE"]:format(subfilterPreset.label)
	self.resetButton:SetTooltipText(tooltipText)
end

function CategorySubfilter:ApplyFilterValues(filterArray)
	local group = self.group
	local subfilterValues = {}
	for _, button in pairs(group.buttons) do
		if(button:IsPressed()) then
			table.insert(subfilterValues, button.value)
		end
	end
	if(#subfilterValues > 0) then
		filterArray[group.filterType].values = subfilterValues
	end
end

function CategorySubfilter:SetWidth(width)
	local subfilterPreset = self.preset
	local container = self.container
	local label = self.label
	local groupContainer = self.group.control
	local buttons = self.buttons

	for i = 1, #buttons do
		local buttonControl = buttons[i].control
		local x = BUTTON_SIZE * (math.mod(i - 1, BUTTONS_PER_ROW))
		local y = LINE_SPACING + BUTTON_OFFSET_Y + BUTTON_SIZE * math.floor((i - 1) / BUTTONS_PER_ROW)
		buttonControl:ClearAnchors()
		buttonControl:SetAnchor(TOPLEFT, groupContainer, TOPLEFT, x, y)
	end

	container:SetWidth(width)
	container:SetHeight(label:GetHeight() + LINE_SPACING + BUTTON_OFFSET_Y + BUTTON_SIZE * math.floor((#buttons - 1) / BUTTONS_PER_ROW))
end

function CategorySubfilter:Reset()
	self.group:ReleaseAllButtons()
	self:HandleChange()
end

function CategorySubfilter:IsDefault()
	return (self.group.pressedButtonCount == 0)
end

function CategorySubfilter:Serialize()
	local subfilterValues = 0
	for _, button in pairs(self.group.buttons) do
		if(button:IsPressed()) then
			subfilterValues = subfilterValues + math.pow(2, button.index)
		end
	end
	return subfilterValues
end

function CategorySubfilter:Deserialize(state)
	local subfilterValues = tonumber(state)
	local buttonValue = 0
	while subfilterValues > 0 do
		local isPressed = (math.mod(subfilterValues, 2) == 1)
		if(isPressed) then
			for _, button in pairs(self.group.buttons) do
				if(buttonValue == button.index) then
					button:Press()
					break
				end
			end
		end
		subfilterValues = math.floor(subfilterValues / 2)
		buttonValue = buttonValue + 1
	end
end

function CategorySubfilter:GetTooltipText(state)
	local subfilterPreset = self.preset
	local subfilterValues = tonumber(state)
	local value = 0
	local text = ""
	local lines = {}
	while subfilterValues > 0 do
		local isSelected = (math.mod(subfilterValues, 2) == 1)
		if(isSelected) then
			for index, button in ipairs(subfilterPreset.buttons) do
				if(value == index) then
					text = text .. button.label .. ", "
					break
				end
			end
		end
		subfilterValues = math.floor(subfilterValues / 2)
		value = value + 1
	end
	if(#text > 0) then
		lines[#lines + 1] = {label = subfilterPreset.label, text = text:sub(0, -3)}
	end
	return lines
end
