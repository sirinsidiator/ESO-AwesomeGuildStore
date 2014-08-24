local L = AwesomeGuildStore.Localization
local MinMaxRangeSlider = AwesomeGuildStore.MinMaxRangeSlider

local MIN_LEVEL = 1
local MAX_LEVEL = 50
local MIN_RANK = 1
local MAX_RANK = 12
local RESET_BUTTON_SIZE = 18
local RESET_BUTTON_TEXTURE = "EsoUI/Art/Buttons/decline_%s.dds"

local LevelSelector = ZO_Object:Subclass()
AwesomeGuildStore.LevelSelector = LevelSelector

function LevelSelector:New(parent, name)
	local selector = ZO_Object.New(self)

	local setFromTextBox = false
	local togglingRangeMode = false
	local minLevelBox = parent:GetNamedChild("MinLevelBox")
	local maxLevelBox = parent:GetNamedChild("MaxLevelBox")
	local slider = MinMaxRangeSlider:New(parent, name .. "LevelSlider", 0, 0, 195, 16)
	slider:SetMinMax(MIN_LEVEL, MAX_LEVEL)
	slider:SetRangeValue(MIN_LEVEL, MAX_LEVEL)
	selector.slider = slider
	selector.min = {
		[TRADING_HOUSE_FILTER_TYPE_LEVEL] = MIN_LEVEL,
		[TRADING_HOUSE_FILTER_TYPE_VETERAN_LEVEL] = MIN_RANK,
	}
	selector.max = {
		[TRADING_HOUSE_FILTER_TYPE_LEVEL] = MAX_LEVEL,
		[TRADING_HOUSE_FILTER_TYPE_VETERAN_LEVEL] = MAX_RANK,
	}

	slider.OnValueChanged = function(self, min, max)
		selector.resetButton:SetHidden(selector:IsDefault())
		if(not togglingRangeMode) then
			selector.min[TRADING_HOUSE.m_levelRangeFilterType] = min
			selector.max[TRADING_HOUSE.m_levelRangeFilterType] = max
		end
		if(setFromTextBox) then return end
		minLevelBox:SetText(min)
		maxLevelBox:SetText(max)
	end

	local function UpdateSliderFromTextBox()
		setFromTextBox = true
		local oldMin, oldMax = slider:GetRangeValue()
		local min = tonumber(minLevelBox:GetText()) or oldMin
		local max = tonumber(maxLevelBox:GetText()) or oldMax

		slider:SetRangeValue(min, max)
		setFromTextBox = false
	end

	local function UpdateTextBoxFromSlider()
		local min, max = slider:GetRangeValue()
		minLevelBox:SetText(min)
		maxLevelBox:SetText(max)
	end

	minLevelBox:SetHandler("OnTextChanged", UpdateSliderFromTextBox)
	maxLevelBox:SetHandler("OnTextChanged", UpdateSliderFromTextBox)
	minLevelBox:SetHandler("OnFocusLost", UpdateTextBoxFromSlider)
	maxLevelBox:SetHandler("OnFocusLost", UpdateTextBoxFromSlider)

	ZO_PreHook(TRADING_HOUSE, "ToggleLevelRangeMode", function(self)
		togglingRangeMode = true
		if(self.m_levelRangeFilterType == TRADING_HOUSE_FILTER_TYPE_LEVEL) then
			slider:SetMinMax(MIN_RANK, MAX_RANK)
			slider:SetRangeValue(selector.min[TRADING_HOUSE_FILTER_TYPE_VETERAN_LEVEL], selector.max[TRADING_HOUSE_FILTER_TYPE_VETERAN_LEVEL])
		else
			slider:SetMinMax(MIN_LEVEL, MAX_LEVEL)
			slider:SetRangeValue(selector.min[TRADING_HOUSE_FILTER_TYPE_LEVEL], selector.max[TRADING_HOUSE_FILTER_TYPE_LEVEL])
		end
		togglingRangeMode = false
		zo_callLater(function()
			selector.resetButton:SetHidden(selector:IsDefault())
		end, 1)
	end)

	local levelRangeToggle = parent:GetNamedChild("LevelRangeToggle")
	levelRangeToggle:SetNormalTexture("EsoUI/Art/LFG/LFG_normalDungeon_up.dds")
	levelRangeToggle:SetMouseOverTexture("EsoUI/Art/LFG/LFG_normalDungeon_over.dds")

	ZO_PreHook(TRADING_HOUSE.m_search, "InternalExecuteSearch", function(self)
		local min = tonumber(minLevelBox:GetText())
		local max = tonumber(maxLevelBox:GetText())
		local isLevel = (TRADING_HOUSE.m_levelRangeFilterType == TRADING_HOUSE_FILTER_TYPE_LEVEL)
		local filter = self.m_filters[isLevel and TRADING_HOUSE_FILTER_TYPE_LEVEL or TRADING_HOUSE_FILTER_TYPE_VETERAN_LEVEL]
		if((isLevel and min == MIN_LEVEL and max == MAX_LEVEL) or (not isLevel and min == MIN_RANK and max == MAX_RANK)) then
			filter.values = {}
		else
			if(min == max) then max = nil end
			filter.values = {min, max}
		end
	end)

	local levelRangeLabel = parent:GetNamedChild("LevelRangeLabel")
	local resetButton = CreateControlFromVirtual(name .. "ResetButton", parent, "ZO_DefaultButton")
	resetButton:SetNormalTexture(RESET_BUTTON_TEXTURE:format("up"))
	resetButton:SetPressedTexture(RESET_BUTTON_TEXTURE:format("down"))
	resetButton:SetMouseOverTexture(RESET_BUTTON_TEXTURE:format("over"))
	resetButton:SetEndCapWidth(0)
	resetButton:SetDimensions(RESET_BUTTON_SIZE, RESET_BUTTON_SIZE)
	resetButton:SetAnchor(TOPRIGHT, levelRangeLabel, TOPLEFT, 196, 0)
	resetButton:SetHidden(true)
	resetButton:SetHandler("OnMouseUp",function(control, button, isInside)
		if(button == 1 and isInside) then
			selector:Reset()
		end
	end)
	local text = L["RESET_FILTER_LABEL_TEMPLATE"]:format(levelRangeLabel:GetText():gsub(":", ""))
	resetButton:SetHandler("OnMouseEnter", function()
		InitializeTooltip(InformationTooltip)
		InformationTooltip:ClearAnchors()
		InformationTooltip:SetOwner(resetButton, BOTTOM, 5, 0)
		SetTooltipText(InformationTooltip, text)
	end)
	resetButton:SetHandler("OnMouseExit", function()
		ClearTooltip(InformationTooltip)
	end)
	selector.resetButton = resetButton

	UpdateTextBoxFromSlider()

	return selector
end

function LevelSelector:Reset()
	TRADING_HOUSE.m_levelRangeFilterType = TRADING_HOUSE_FILTER_TYPE_LEVEL
	TRADING_HOUSE.m_levelRangeToggle:SetState(BSTATE_NORMAL, false)
	TRADING_HOUSE.m_levelRangeLabel:SetText(GetString(SI_TRADING_HOUSE_BROWSE_LEVEL_RANGE_LABEL))

	self.min[TRADING_HOUSE_FILTER_TYPE_LEVEL] = MIN_LEVEL
	self.min[TRADING_HOUSE_FILTER_TYPE_VETERAN_LEVEL] = MIN_RANK
	self.max[TRADING_HOUSE_FILTER_TYPE_LEVEL] = MAX_LEVEL
	self.max[TRADING_HOUSE_FILTER_TYPE_VETERAN_LEVEL] = MAX_RANK

	self.slider:SetMinMax(MIN_LEVEL, MAX_LEVEL)
	zo_callLater(function()
		self.slider:SetRangeValue(MIN_LEVEL, MAX_LEVEL)
	end, 1)
end

function LevelSelector:IsDefault()
	local min, max = self.slider:GetRangeValue()
	return (TRADING_HOUSE.m_levelRangeFilterType == TRADING_HOUSE_FILTER_TYPE_LEVEL and min == MIN_LEVEL and max == MAX_LEVEL)
end

function LevelSelector:Serialize()
	local min, max = self.slider:GetRangeValue()
	local vr = (TRADING_HOUSE.m_levelRangeFilterType ~= TRADING_HOUSE_FILTER_TYPE_LEVEL) and "1" or "0"
	return vr .. ";" .. tostring(min) .. ";" .. tostring(max)
end

function LevelSelector:Deserialize(state)
	local vr, min, max = zo_strsplit(";", state)
	assert(vr and min and max)

	local isNormal = (vr == "0")
	local isNormalActive = (TRADING_HOUSE.m_levelRangeFilterType == TRADING_HOUSE_FILTER_TYPE_LEVEL)
	if((isNormal and not isNormalActive) or (not isNormal and isNormalActive)) then
		TRADING_HOUSE:ToggleLevelRangeMode()
	end

	self.slider:SetRangeValue(tonumber(min), tonumber(max))
end
