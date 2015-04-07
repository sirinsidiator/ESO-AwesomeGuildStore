local L = AwesomeGuildStore.Localization
local MinMaxRangeSlider = AwesomeGuildStore.MinMaxRangeSlider
local SimpleIconButton = AwesomeGuildStore.SimpleIconButton
local FilterBase = AwesomeGuildStore.FilterBase

local QualityFilter = FilterBase:Subclass()
AwesomeGuildStore.QualityFilter = QualityFilter

local BUTTON_SIZE = 36
local BUTTON_PADDING = 14
local BUTTON_OFFSET_Y = 12
local BUTTON_FOLDER = "AwesomeGuildStore/images/qualitybuttons/"
local MOUSE_LEFT = 1
local MOUSE_RIGHT = 2
local MOUSE_MIDDLE = 3
local MIN_QUALITY = 1
local MAX_QUALITY = 5
local QUALITY_LABEL = {L["NORMAL_QUALITY_LABEL"], L["MAGIC_QUALITY_LABEL"], L["ARCANE_QUALITY_LABEL"], L["ARTIFACT_QUALITY_LABEL"], L["LEGENDARY_QUALITY_LABEL"]}
local LINE_SPACING = 4
local QUALITY_FITLER_TYPE_ID = 4

function QualityFilter:New(name, tradingHouseWrapper, ...)
	return FilterBase.New(self, QUALITY_FITLER_TYPE_ID, name, tradingHouseWrapper, ...)
end

function QualityFilter:Initialize(name, tradingHouseWrapper)
	self:InitializeControls(name, tradingHouseWrapper.tradingHouse, tradingHouseWrapper.saveData)
	self:InitializeHandlers(tradingHouseWrapper.tradingHouse)
end

function QualityFilter:InitializeControls(name, tradingHouse, saveData)
	local container = self.container

	-- hide the original filter
	tradingHouse.m_browseItems:GetNamedChild("Common"):GetNamedChild("Quality"):SetHidden(true)

	local label = container:CreateControl(name .. "Label", CT_LABEL)
	label:SetFont("ZoFontWinH4")
	label:SetText(L["QUALITY_SELECTOR_TITLE"])
	label:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
	label:SetAnchor(TOPRIGHT, container, TOPRIGHT, 0, 0)

	local slider = MinMaxRangeSlider:New(container, name .. "Slider")
	slider:SetMinMax(MIN_QUALITY, MAX_QUALITY)
	slider:SetRangeValue(MIN_QUALITY, MAX_QUALITY)
	slider.control:SetAnchor(TOPLEFT, label, BOTTOMLEFT, 0, LINE_SPACING)
	slider.control:SetAnchor(TOPRIGHT, label, BOTTOMRIGHT, 0, LINE_SPACING)
	self.slider = slider

	local function SafeSetRangeValue(button, value)
		local min, max = slider:GetRangeValue()
		if(button == MOUSE_LEFT) then
			if(value > max) then slider:SetMaxValue(value) end
			slider:SetMinValue(value)
		elseif(button == MOUSE_RIGHT) then
			if(value < min) then slider:SetMinValue(value) end
			slider:SetMaxValue(value)
		elseif(button == MOUSE_MIDDLE) then
			slider:SetRangeValue(value, value)
		end
	end

	local function CreateButtonControl(name, textureName, tooltipText, value)
		local button = SimpleIconButton:New(name, BUTTON_FOLDER .. textureName, BUTTON_SIZE, tooltipText)
		button:SetMouseOverTexture(BUTTON_FOLDER .. "over.dds") -- we reuse the texture as it is the same for all quality buttons
		button.control:SetHandler("OnMouseDoubleClick", function(control, button)
			SafeSetRangeValue(MOUSE_MIDDLE, value)
		end)
		button.OnClick = function(self, mouseButton, ctrl, alt, shift)
			local oldBehavior = saveData.oldQualitySelectorBehavior
			local setBoth = (oldBehavior and shift) or (not oldBehavior and not shift)
			if(setBoth) then
				SafeSetRangeValue(MOUSE_MIDDLE, value)
			else
				SafeSetRangeValue(mouseButton, value)
			end
			return true
		end
		return button
	end

	self.buttons = {}
	self.buttons[1] = CreateButtonControl(name .. "NormalQualityButton", "normal_%s.dds", L["NORMAL_QUALITY_LABEL"], 1)
	self.buttons[2] = CreateButtonControl(name .. "MagicQualityButton", "magic_%s.dds", L["MAGIC_QUALITY_LABEL"], 2)
	self.buttons[3] = CreateButtonControl(name .. "ArcaneQualityButton", "arcane_%s.dds", L["ARCANE_QUALITY_LABEL"], 3)
	self.buttons[4] = CreateButtonControl(name .. "ArtifactQualityButton", "artifact_%s.dds", L["ARTIFACT_QUALITY_LABEL"], 4)
	self.buttons[5] = CreateButtonControl(name .. "LegendaryQualityButton", "legendary_%s.dds", L["LEGENDARY_QUALITY_LABEL"], 5)

	container:SetHeight(label:GetHeight() + LINE_SPACING + slider.control:GetHeight() + LINE_SPACING + BUTTON_OFFSET_Y + BUTTON_SIZE)
	
	local tooltipText = L["RESET_FILTER_LABEL_TEMPLATE"]:format(label:GetText():gsub(":", ""))
	self.resetButton:SetTooltipText(tooltipText)
end

function QualityFilter:InitializeHandlers(tradingHouse)
	local slider = self.slider

	slider.OnValueChanged = function(slider, min, max)
		self:HandleChange()
	end

	ZO_PreHook(TRADING_HOUSE.m_search, "InternalExecuteSearch", function(self)
		local min, max = slider:GetRangeValue()
		if min == MIN_QUALITY then min = ITEM_QUALITY_TRASH end
		if min == max then max = nil end
		self.m_filters[TRADING_HOUSE_FILTER_TYPE_QUALITY].values = {min, max}
	end)
end

function QualityFilter:SetWidth(width)
	self.container:SetWidth(width)
	self.slider:UpdateVisuals()

	local buttons = self.buttons
	local sliderControl = self.slider.control
	local spacing = (width + BUTTON_PADDING) / MAX_QUALITY
	for i = 1, #buttons do
		buttons[i]:SetAnchor(TOPLEFT, sliderControl, TOPLEFT, spacing * (i - 1), LINE_SPACING + BUTTON_OFFSET_Y)
	end
end

function QualityFilter:Reset()
	self.slider:SetRangeValue(MIN_QUALITY, MAX_QUALITY)
end

function QualityFilter:IsDefault()
	local min, max = self.slider:GetRangeValue()
	return (min == MIN_QUALITY and max == MAX_QUALITY)
end

function QualityFilter:Serialize()
	local min, max = self.slider:GetRangeValue()
	return tostring(min) .. ";" .. tostring(max)
end

function QualityFilter:Deserialize(state)
	local min, max = zo_strsplit(";", state)
	assert(min and max)
	self.slider:SetRangeValue(tonumber(min), tonumber(max))
end

function QualityFilter:GetTooltipText(state)
	local minQuality, maxQuality = zo_strsplit(";", state)
	minQuality = tonumber(minQuality)
	maxQuality = tonumber(maxQuality)
	if(minQuality and maxQuality and not (minQuality == 1 and maxQuality == 5)) then
		local text = ""
		for i = minQuality, maxQuality do
			text = text .. QUALITY_LABEL[i] .. ", "
		end
		return {{label = L["QUALITY_SELECTOR_TITLE"]:sub(0, -2), text = text:sub(0, -3)}}
	end
	return {}
end
