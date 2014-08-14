local BUTTON_SIZE = 36
local BUTTON_X = -7
local BUTTON_Y = 46
local BUTTON_SPACING = 7.5

local ButtonGroup = AwesomeGuildStore.ButtonGroup
local ToggleButton = AwesomeGuildStore.ToggleButton
local MinMaxRangeSlider = AwesomeGuildStore.MinMaxRangeSlider

local QualitySelector = ZO_Object:Subclass()
AwesomeGuildStore.QualitySelector = QualitySelector

local function CreateButtonControl(parent, name, textureName, tooltipText, callback)
	local button = CreateControlFromVirtual(name .. "NormalQualityButton", parent, "ZO_DefaultButton")
	button:SetNormalTexture(textureName:format("up"))
	button:SetPressedTexture(textureName:format("down"))
	button:SetDisabledTexture(textureName:format("disabled"))
	button:SetDisabledPressedTexture(textureName:format("disabled"))
	button:SetMouseOverTexture(textureName:format("over"))
	button:SetEndCapWidth(0)
	button:SetDimensions(BUTTON_SIZE, BUTTON_SIZE)
	button:SetHandler("OnMouseUp", function(control, button, isInside)
		if(button == 1 and isInside) then
			callback()
		end
	end)
	button:SetHandler("OnMouseEnter", function()
		InitializeTooltip(InformationTooltip)
		ZO_Tooltips_SetupDynamicTooltipAnchors(InformationTooltip, button)
		SetTooltipText(InformationTooltip, tooltipText)
	end)
	button:SetHandler("OnMouseExit", function()
		ClearTooltip(InformationTooltip)
	end)
	return button
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
	slider:SetRange(1, 5)
	self.slider = slider

	ZO_PreHook(TRADING_HOUSE.m_search, "InternalExecuteSearch", function(self)
		local values = {}
		local min, max = slider:GetRange()
		for i = min, max do
			if i == 1 then
				table.insert(values, ITEM_QUALITY_TRASH)
			end
			table.insert(values, i)
		end
		self.m_filters[TRADING_HOUSE_FILTER_TYPE_QUALITY].values = values
	end)

	local normalButton = CreateButtonControl(container, name .. "NormalQualityButton", "AwesomeGuildStore/images/qualitybuttons/normal_%s.dds", GetString(SI_TRADING_HOUSE_BROWSE_QUALITY_NORMAL), function()
		slider:SetRange(1, 1)
	end)
	normalButton:SetAnchor(TOPLEFT, container, TOPLEFT, BUTTON_X, BUTTON_Y)

	local magicButton = CreateButtonControl(container, name .. "MagicQualityButton", "AwesomeGuildStore/images/qualitybuttons/magic_%s.dds", GetString(SI_TRADING_HOUSE_BROWSE_QUALITY_MAGIC), function()
		slider:SetRange(2, 2)
	end)
	magicButton:SetAnchor(TOPLEFT, container, TOPLEFT, BUTTON_X + (BUTTON_SIZE + BUTTON_SPACING), BUTTON_Y)

	local arcaneButton = CreateButtonControl(container, name .. "ArcaneQualityButton", "AwesomeGuildStore/images/qualitybuttons/arcane_%s.dds", GetString(SI_TRADING_HOUSE_BROWSE_QUALITY_ARCANE), function()
		slider:SetRange(3, 3)
	end)
	arcaneButton:SetAnchor(TOPLEFT, container, TOPLEFT, BUTTON_X + (BUTTON_SIZE + BUTTON_SPACING) * 2, BUTTON_Y)

	local artifactButton = CreateButtonControl(container, name .. "ArtifactQualityButton", "AwesomeGuildStore/images/qualitybuttons/artifact_%s.dds", GetString(SI_TRADING_HOUSE_BROWSE_QUALITY_ARTIFACT), function()
		slider:SetRange(4, 4)
	end)
	artifactButton:SetAnchor(TOPLEFT, container, TOPLEFT, BUTTON_X + (BUTTON_SIZE + BUTTON_SPACING) * 3, BUTTON_Y)

	local legendaryButton = CreateButtonControl(container, name .. "LegendaryQualityButton", "AwesomeGuildStore/images/qualitybuttons/legendary_%s.dds", GetString(SI_TRADING_HOUSE_BROWSE_QUALITY_LEGENDARY), function()
		slider:SetRange(5, 5)
	end)
	legendaryButton:SetAnchor(TOPLEFT, container, TOPLEFT, BUTTON_X + (BUTTON_SIZE + BUTTON_SPACING) * 4, BUTTON_Y)

	return selector
end

function QualitySelector:Reset()
	self.slider:SetRange(1, 5)
end
