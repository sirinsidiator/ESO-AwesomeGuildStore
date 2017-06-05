local gettext = LibStub("LibGetText")("AwesomeGuildStore").gettext
local MinMaxRangeSlider = AwesomeGuildStore.MinMaxRangeSlider
local SimpleIconButton = AwesomeGuildStore.SimpleIconButton
local FilterBase = AwesomeGuildStore.FilterBase

local RecipeImprovementFilter = FilterBase:Subclass()
AwesomeGuildStore.RecipeImprovementFilter = RecipeImprovementFilter

local BUTTON_SIZE = 36
local BUTTON_PADDING = 12
local BUTTON_OFFSET_X = -6
local BUTTON_OFFSET_Y = 12
local BUTTON_FOLDER = "AwesomeGuildStore/images/numerals/"
local MOUSE_LEFT = 1
local MOUSE_RIGHT = 2
local MOUSE_MIDDLE = 3
local MIN_VALUE = 1
local MAX_VALUE = 6
local LINE_SPACING = 4
local RECIPE_IMPROVEMENT_FILTER_TYPE_ID = 45

function RecipeImprovementFilter:New(name, tradingHouseWrapper, ...)
	return FilterBase.New(self, RECIPE_IMPROVEMENT_FILTER_TYPE_ID, name, tradingHouseWrapper, ...)
end

function RecipeImprovementFilter:Initialize(name, tradingHouseWrapper, subfilterPreset)
	self.preset = subfilterPreset
	self.saveData = tradingHouseWrapper.saveData
	self:InitializeControls(name)
	self:InitializeHandlers(tradingHouseWrapper.tradingHouse)
end

function RecipeImprovementFilter:InitializeControls(name)
	local container = self.container
	local saveData = self.saveData

	local label = container:CreateControl(name .. "Label", CT_LABEL)
	label:SetFont("ZoFontWinH4")
	label:SetText(self.preset.label .. ":")
	self:SetLabelControl(label)

	local slider = MinMaxRangeSlider:New(container, name .. "Slider")
	slider:SetMinMax(MIN_VALUE, MAX_VALUE)
	slider:SetRangeValue(MIN_VALUE, MAX_VALUE)
	slider.control:ClearAnchors()
	slider.control:SetAnchor(TOPLEFT, label, BOTTOMLEFT, 0, LINE_SPACING)
	slider.control:SetAnchor(RIGHT, container, RIGHT, 0, 0)
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

	local function GetLevelRangeFromImprovement(improvement)
		local label, min, max
		if(improvement < 5) then
			label = GetString(SI_EXPERIENCE_LEVEL_LABEL) .. " "
			min = improvement * 10
			max = min + 9
			if(improvement == 1) then min = 1 end
		else
			label = zo_iconFormat(GetChampionPointsIcon(), 24, 24)
			if(improvement == 5) then
				min = 10
				max = 90
			else
				min = 100
				max = 160
			end
		end
		return ("(%s%d - %d)"):format(label, min, max)
	end

	local function CreateNumeralButtonControl(value)
		local textureName = zo_strformat(BUTTON_FOLDER .. "<<R:1>>_%s.dds", value)
		-- TRANSLATORS: tooltip text for the recipe improvement filter buttons
		local tooltipText = gettext("Recipe Improvement <<1>> <<2>>", value, GetLevelRangeFromImprovement(value))
		local button = SimpleIconButton:New(name .. "Level" .. value .. "Button", textureName, BUTTON_SIZE, tooltipText)
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
	for i = 1, 6 do
		self.buttons[i] = CreateNumeralButtonControl(i)
	end

	container:SetHeight(71)

	local tooltipText = gettext("Reset <<1>> Filter", self.preset.label)
	self.resetButton:SetTooltipText(tooltipText)
end

local function ValueFromText(value, limit, old)
	if(value == "") then
		value = limit
	else
		value = tonumber(value) or old
	end
	return value
end

function RecipeImprovementFilter:InitializeHandlers(tradingHouse)
	local slider = self.slider

	slider.OnValueChanged = function(slider, min, max)
		self:HandleChange()
	end
end

function RecipeImprovementFilter:ApplyFilterValues(filterArray)
-- do nothing here as we want to filter on the result page
end

function RecipeImprovementFilter:BeforeRebuildSearchResultsPage(tradingHouseWrapper)
	self.min, self.max = self.slider:GetRangeValue()

	if(self.min == MIN_VALUE and self.max == MAX_VALUE) then
		self.min, self.max = nil, nil
		return false
	end

	return true
end

local function GetItemLinkRecipeMinAndMaxRankRequirement(itemLink)
    local tradeSkill, requiredLevel = GetItemLinkRecipeTradeskillRequirement(itemLink, 1)
    local min, max = requiredLevel, requiredLevel
    for i = 2, GetItemLinkRecipeNumTradeskillRequirements(itemLink) do
        tradeSkill, requiredLevel = GetItemLinkRecipeTradeskillRequirement(itemLink, i)
        min = math.min(min, requiredLevel)
        max = math.max(max, requiredLevel)
    end
    return min, max
end

function RecipeImprovementFilter:FilterPageResult(index, icon, name, quality, stackCount, sellerName, timeRemaining, purchasePrice)
    local itemLink = GetTradingHouseSearchResultItemLink(index, LINK_STYLE_BRACKETS)
    local min, max = GetItemLinkRecipeMinAndMaxRankRequirement(itemLink)
    return not (min < self.min or max > self.max)
end

function RecipeImprovementFilter:SetWidth(width)
	self.container:SetWidth(width)
	self.slider:UpdateVisuals()

	local buttons = self.buttons
	local sliderControl = self.slider.control
	local spacing = (width + BUTTON_PADDING) / MAX_VALUE
	for i = 1, #buttons do
		buttons[i]:SetAnchor(TOPLEFT, sliderControl, TOPLEFT, BUTTON_OFFSET_X + spacing * (i - 1), LINE_SPACING + BUTTON_OFFSET_Y)
	end
end

function RecipeImprovementFilter:Reset()
	self.slider:SetMinMax(MIN_VALUE, MAX_VALUE)
	self.slider:SetRangeValue(MIN_VALUE, MAX_VALUE)
end

function RecipeImprovementFilter:IsDefault()
	local min, max = self.slider:GetRangeValue()
	return (min == MIN_VALUE and max == MAX_VALUE)
end

function RecipeImprovementFilter:Serialize()
	local min = (not self.min or self.min == MIN_VALUE) and "-" or self.min
	local max = (not self.max or self.max == MAX_VALUE) and "-" or self.max
	return min .. "_" .. max
end

function RecipeImprovementFilter:Deserialize(state)
	local min, max = zo_strsplit("_", state)
	min = tonumber(min) or MIN_VALUE
	max = tonumber(max) or MAX_VALUE
	self.slider:SetRangeValue(min, max)
end

function RecipeImprovementFilter:GetTooltipText(state)
	local minImprovement, maxImprovement = zo_strsplit("_", state)
	minImprovement = tonumber(minImprovement)
	maxImprovement = tonumber(maxImprovement)
	local improvement = ""
	if(minImprovement and maxImprovement) then
		improvement = gettext("<<1>> - <<2>>", minImprovement, maxImprovement) 
	elseif(minImprovement) then
		improvement = gettext("over <<1>>", minImprovement)
	elseif(maxImprovement) then
		improvement = gettext("under <<1>>", maxImprovement)
	end

	if(improvement ~= "") then
		return {{label = self.preset.label, text = improvement}}
	end
	return {}
end
