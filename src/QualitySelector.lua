local BUTTON_SIZE = 36
local BUTTON_X = -7
local BUTTON_Y = 46
local BUTTON_SPACING = 7.5
local RESET_BUTTON_SIZE = 18
local RESET_BUTTON_TEXTURE = "EsoUI/Art/Buttons/decline_%s.dds"

local MinMaxRangeSlider = AwesomeGuildStore.MinMaxRangeSlider

local QualitySelector = ZO_Object:Subclass()
AwesomeGuildStore.QualitySelector = QualitySelector

local function CreateButtonControl(parent, name, textureName, tooltipText, callback)
	local buttonControl = CreateControlFromVirtual(name .. "NormalQualityButton", parent, "ZO_DefaultButton")
	buttonControl:SetNormalTexture(textureName:format("up"))
	buttonControl:SetPressedTexture(textureName:format("down"))
	buttonControl:SetMouseOverTexture("AwesomeGuildStore/images/qualitybuttons/over.dds")
	buttonControl:SetEndCapWidth(0)
	buttonControl:SetDimensions(BUTTON_SIZE, BUTTON_SIZE)
	buttonControl:SetHandler("OnMouseDoubleClick", function(control, button)
		callback(3)
	end)
	buttonControl:SetHandler("OnMouseUp", function(control, button, isInside)
		if(isInside) then
			callback(button)
			if(button == 2) then
				-- the mouse down event does not fire for right click and the button does not show any click behavior at all
				-- we emulate it by changing the texture for a bit and playing the click sound manually
				buttonControl:SetNormalTexture(textureName:format("down"))
				buttonControl:SetMouseOverTexture("")
				zo_callLater(function()
					buttonControl:SetNormalTexture(textureName:format("up"))
					buttonControl:SetMouseOverTexture("AwesomeGuildStore/images/qualitybuttons/over.dds")
				end, 100)
				PlaySound("Click")
			end
		end
	end)
	buttonControl:SetHandler("OnMouseEnter", function()
		InitializeTooltip(InformationTooltip)
		InformationTooltip:ClearAnchors()
		InformationTooltip:SetOwner(buttonControl, BOTTOM, 5, 0)
		SetTooltipText(InformationTooltip, tooltipText)
	end)
	buttonControl:SetHandler("OnMouseExit", function()
		ClearTooltip(InformationTooltip)
	end)
	return buttonControl
end

function QualitySelector:New(parent, name)
	local selector = ZO_Object.New(self)

	local container = parent:CreateControl(name .. "Container", CT_CONTROL)
	container:SetDimensions(195, 100)
	selector.control = container

	local label = container:CreateControl(name .. "Label", CT_LABEL)
	label:SetFont("ZoFontWinH4")
	label:SetText("Quality Range:")
	label:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)

	local slider = MinMaxRangeSlider:New(container, name .. "QualitySlider", 0, 30, 195, 16)
	slider:SetMinMax(1, 5)
	slider:SetRangeValue(1, 5)
	slider.OnValueChanged = function(self, min, max)
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
		if(button == 1) then
			if(value > max) then slider:SetMaxValue(value) end
			slider:SetMinValue(value)
		elseif(button == 2) then
			if(value < min) then slider:SetMinValue(value) end
			slider:SetMaxValue(value) 
		elseif(button == 3) then
			slider:SetRangeValue(value, value)
		end
	end

	local normalButton = CreateButtonControl(container, name .. "NormalQualityButton", "AwesomeGuildStore/images/qualitybuttons/normal_%s.dds", GetString(SI_TRADING_HOUSE_BROWSE_QUALITY_NORMAL), function(button)
		SafeSetRangeValue(button, 1)
	end)
	normalButton:SetAnchor(TOPLEFT, container, TOPLEFT, BUTTON_X, BUTTON_Y)

	local magicButton = CreateButtonControl(container, name .. "MagicQualityButton", "AwesomeGuildStore/images/qualitybuttons/magic_%s.dds", GetString(SI_TRADING_HOUSE_BROWSE_QUALITY_MAGIC), function(button)
		SafeSetRangeValue(button, 2)
	end)
	magicButton:SetAnchor(TOPLEFT, container, TOPLEFT, BUTTON_X + (BUTTON_SIZE + BUTTON_SPACING), BUTTON_Y)

	local arcaneButton = CreateButtonControl(container, name .. "ArcaneQualityButton", "AwesomeGuildStore/images/qualitybuttons/arcane_%s.dds", GetString(SI_TRADING_HOUSE_BROWSE_QUALITY_ARCANE), function(button)
		SafeSetRangeValue(button, 3)
	end)
	arcaneButton:SetAnchor(TOPLEFT, container, TOPLEFT, BUTTON_X + (BUTTON_SIZE + BUTTON_SPACING) * 2, BUTTON_Y)

	local artifactButton = CreateButtonControl(container, name .. "ArtifactQualityButton", "AwesomeGuildStore/images/qualitybuttons/artifact_%s.dds", GetString(SI_TRADING_HOUSE_BROWSE_QUALITY_ARTIFACT), function(button)
		SafeSetRangeValue(button, 4)
	end)
	artifactButton:SetAnchor(TOPLEFT, container, TOPLEFT, BUTTON_X + (BUTTON_SIZE + BUTTON_SPACING) * 3, BUTTON_Y)

	local legendaryButton = CreateButtonControl(container, name .. "LegendaryQualityButton", "AwesomeGuildStore/images/qualitybuttons/legendary_%s.dds", GetString(SI_TRADING_HOUSE_BROWSE_QUALITY_LEGENDARY), function(button)
		SafeSetRangeValue(button, 5)
	end)
	legendaryButton:SetAnchor(TOPLEFT, container, TOPLEFT, BUTTON_X + (BUTTON_SIZE + BUTTON_SPACING) * 4, BUTTON_Y)

	local resetButton = CreateControlFromVirtual(name .. "ResetButton", parent, "ZO_DefaultButton")
	resetButton:SetNormalTexture(RESET_BUTTON_TEXTURE:format("up"))
	resetButton:SetPressedTexture(RESET_BUTTON_TEXTURE:format("down"))
	resetButton:SetMouseOverTexture(RESET_BUTTON_TEXTURE:format("over"))
	resetButton:SetEndCapWidth(0)
	resetButton:SetDimensions(RESET_BUTTON_SIZE, RESET_BUTTON_SIZE)
	resetButton:SetAnchor(TOPRIGHT, label, TOPLEFT, 196, 0)
	resetButton:SetHidden(true)
	resetButton:SetHandler("OnMouseUp",function(control, button, isInside)
		if(button == 1 and isInside) then
			selector:Reset()
		end
	end)
	resetButton:SetHandler("OnMouseEnter", function()
		InitializeTooltip(InformationTooltip)
		InformationTooltip:ClearAnchors()
		InformationTooltip:SetOwner(resetButton, BOTTOM, 5, 0)
		SetTooltipText(InformationTooltip, "reset quality range")
	end)
	resetButton:SetHandler("OnMouseExit", function()
		ClearTooltip(InformationTooltip)
	end)
	selector.resetButton = resetButton

	return selector
end

function QualitySelector:Reset()
	self.slider:SetRangeValue(1, 5)
end

function QualitySelector:IsDefault()
	local min, max = self.slider:GetRangeValue()
	return (min == 1 and max == 5)
end
