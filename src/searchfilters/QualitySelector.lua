local L = AwesomeGuildStore.Localization
local MinMaxRangeSlider = AwesomeGuildStore.MinMaxRangeSlider
local SimpleIconButton = AwesomeGuildStore.SimpleIconButton

local BUTTON_SIZE = 36
local BUTTON_X = -7
local BUTTON_Y = 46
local BUTTON_SPACING = 7.5
local RESET_BUTTON_SIZE = 18
local RESET_BUTTON_TEXTURE = "EsoUI/Art/Buttons/decline_%s.dds"

local QualitySelector = ZO_Object:Subclass()
AwesomeGuildStore.QualitySelector = QualitySelector

local MOUSE_LEFT = 1
local MOUSE_RIGHT = 2
local MOUSE_MIDDLE = 3

function QualitySelector:New(parent, name, saveData)
	local selector = ZO_Object.New(self)
	selector.callbackName = name .. "Changed"
	selector.type = 4

	local container = parent:CreateControl(name .. "Container", CT_CONTROL)
	container:SetDimensions(195, 100)
	selector.control = container

	local label = container:CreateControl(name .. "Label", CT_LABEL)
	label:SetFont("ZoFontWinH4")
	label:SetText(L["QUALITY_SELECTOR_TITLE"])
	label:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)

	local slider = MinMaxRangeSlider:New(container, name .. "QualitySlider", 0, 30, 195, 16)
	slider:SetMinMax(1, 5)
	slider:SetRangeValue(1, 5)
	slider.OnValueChanged = function(self, min, max)
		selector:HandleChange()
		selector.resetButton:SetHidden(selector:IsDefault())
	end
	selector.slider = slider

	ZO_PreHook(TRADING_HOUSE.m_search, "InternalExecuteSearch", function(self)
		local min, max = slider:GetRangeValue()
		if min == 1 then min = ITEM_QUALITY_TRASH end
		if min == max then max = nil end
		self.m_filters[TRADING_HOUSE_FILTER_TYPE_QUALITY].values = {min, max}
	end)

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

	local folder = "AwesomeGuildStore/images/qualitybuttons/"
	local function CreateButtonControl(name, textureName, tooltipText, value)
		local button = SimpleIconButton:New(name, folder .. textureName, BUTTON_SIZE, tooltipText)
		button:SetMouseOverTexture(folder .. "over.dds") -- we reuse the texture as it is the same for all quality buttons
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
		button:SetAnchor(TOPLEFT, container, TOPLEFT, BUTTON_X + (BUTTON_SIZE + BUTTON_SPACING) * (value - 1), BUTTON_Y)
		return button
	end
	CreateButtonControl(name .. "NormalQualityButton", "normal_%s.dds", L["NORMAL_QUALITY_LABEL"], 1)
	CreateButtonControl(name .. "MagicQualityButton", "magic_%s.dds", L["MAGIC_QUALITY_LABEL"], 2)
	CreateButtonControl(name .. "ArcaneQualityButton", "arcane_%s.dds", L["ARCANE_QUALITY_LABEL"], 3)
	CreateButtonControl(name .. "ArtifactQualityButton", "artifact_%s.dds", L["ARTIFACT_QUALITY_LABEL"], 4)
	CreateButtonControl(name .. "LegendaryQualityButton", "legendary_%s.dds", L["LEGENDARY_QUALITY_LABEL"], 5)

	local tooltipText = L["RESET_FILTER_LABEL_TEMPLATE"]:format(label:GetText():gsub(":", ""))
	local resetButton = SimpleIconButton:New(name .. "ResetButton", RESET_BUTTON_TEXTURE, RESET_BUTTON_SIZE, tooltipText)
	resetButton:SetAnchor(TOPRIGHT, label, TOPLEFT, 196, 0)
	resetButton:SetHidden(true)
	resetButton.OnClick = function(self, mouseButton, ctrl, alt, shift)
		if(mouseButton == MOUSE_LEFT) then
			selector:Reset()
		end
	end
	selector.resetButton = resetButton

	return selector
end

function QualitySelector:HandleChange()
	if(not self.fireChangeCallback) then
		self.fireChangeCallback = zo_callLater(function()
			self.fireChangeCallback = nil
			CALLBACK_MANAGER:FireCallbacks(self.callbackName, self)
		end, 100)
	end
end

function QualitySelector:Reset()
	self.slider:SetRangeValue(1, 5)
end

function QualitySelector:IsDefault()
	local min, max = self.slider:GetRangeValue()
	return (min == 1 and max == 5)
end

function QualitySelector:Serialize()
	local min, max = self.slider:GetRangeValue()
	return tostring(min) .. ";" .. tostring(max)
end

function QualitySelector:Deserialize(state)
	local min, max = zo_strsplit(";", state)
	assert(min and max)
	self.slider:SetRangeValue(tonumber(min), tonumber(max))
end

local QUALITY_LABEL = {L["NORMAL_QUALITY_LABEL"], L["MAGIC_QUALITY_LABEL"], L["ARCANE_QUALITY_LABEL"], L["ARTIFACT_QUALITY_LABEL"], L["LEGENDARY_QUALITY_LABEL"]}
function QualitySelector:GetTooltipText(state)
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
