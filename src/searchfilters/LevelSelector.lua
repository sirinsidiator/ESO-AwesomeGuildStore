local L = AwesomeGuildStore.Localization
local MinMaxRangeSlider = AwesomeGuildStore.MinMaxRangeSlider

local MIN_LEVEL = 1
local MAX_LEVEL = 50
local MIN_RANK = 1
local MAX_RANK = 14
local RESET_BUTTON_SIZE = 18
local RESET_BUTTON_TEXTURE = "EsoUI/Art/Buttons/decline_%s.dds"

local LevelSelector = ZO_Object:Subclass()
AwesomeGuildStore.LevelSelector = LevelSelector

function LevelSelector:New(parent, name)
	local selector = ZO_Object.New(self)
	selector.callbackName = name .. "Changed"
	selector.type = 3

	local setFromTextBox = false
	local togglingRangeMode = false
	local minLevelBox = parent:GetNamedChild("MinLevelBox")
	self.minLevelBox = minLevelBox
	local maxLevelBox = parent:GetNamedChild("MaxLevelBox")
	self.maxLevelBox = maxLevelBox
	local slider = MinMaxRangeSlider:New(parent, name .. "LevelSlider", 0, 0, 195, 16)
	slider:SetMinMax(MIN_LEVEL, MAX_LEVEL)
	slider:SetRangeValue(MIN_LEVEL, MAX_LEVEL)
	selector.slider = slider
	selector.min = {}
	selector.max = {}

	slider.OnValueChanged = function(self, min, max)
		selector:HandleChange()
		selector.resetButton:SetHidden(selector:IsDefault())
		if(setFromTextBox) then return end
		minLevelBox:SetText(min)
		maxLevelBox:SetText(max)
	end

	local function ValueFromText(value, limit)
		return tonumber(value) or limit
	end

	local function UpdateSliderFromTextBox()
		setFromTextBox = true
		local isLevel = (TRADING_HOUSE.m_levelRangeFilterType == TRADING_HOUSE_FILTER_TYPE_LEVEL)
		if(togglingRangeMode) then isLevel = not isLevel end
		local minValue = minLevelBox:GetText()
		local maxValue = maxLevelBox:GetText()
		local min = ValueFromText(minValue, isLevel and MIN_LEVEL or MIN_RANK)
		local max = ValueFromText(maxValue, isLevel and MAX_LEVEL or MAX_RANK)

		if(not togglingRangeMode) then
			selector.min[TRADING_HOUSE.m_levelRangeFilterType] = tonumber(minValue)
			selector.max[TRADING_HOUSE.m_levelRangeFilterType] = tonumber(maxValue)
		end

		slider:SetRangeValue(min, max)
		setFromTextBox = false
	end

	minLevelBox:SetHandler("OnTextChanged", UpdateSliderFromTextBox)
	maxLevelBox:SetHandler("OnTextChanged", UpdateSliderFromTextBox)

	ZO_PreHook(TRADING_HOUSE, "ToggleLevelRangeMode", function(self)
		togglingRangeMode = true
		if(self.m_levelRangeFilterType == TRADING_HOUSE_FILTER_TYPE_LEVEL) then
			slider:SetMinMax(MIN_RANK, MAX_RANK)
			minLevelBox:SetText(selector.min[TRADING_HOUSE_FILTER_TYPE_VETERAN_LEVEL] or "")
			maxLevelBox:SetText(selector.max[TRADING_HOUSE_FILTER_TYPE_VETERAN_LEVEL] or "")
		else
			slider:SetMinMax(MIN_LEVEL, MAX_LEVEL)
			minLevelBox:SetText(selector.min[TRADING_HOUSE_FILTER_TYPE_LEVEL] or "")
			maxLevelBox:SetText(selector.max[TRADING_HOUSE_FILTER_TYPE_LEVEL] or "")
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

		if(min == nil and max == nil) then
			return
		elseif(min == nil) then
			min = isLevel and MIN_LEVEL or MIN_RANK
		elseif(max == nil) then
			max = isLevel and MAX_LEVEL or MAX_RANK
		end

		if(min == max) then max = nil end
		filter.values = {min, max}
	end)

	local levelRangeLabel = parent:GetNamedChild("LevelRangeLabel")
	local tooltipText = L["RESET_FILTER_LABEL_TEMPLATE"]:format(levelRangeLabel:GetText():gsub(":", ""))
	local resetButton = AwesomeGuildStore.SimpleIconButton:New(name .. "ResetButton", RESET_BUTTON_TEXTURE, RESET_BUTTON_SIZE, tooltipText)
	resetButton:SetAnchor(TOPRIGHT, levelRangeLabel, TOPLEFT, 196, 0)
	resetButton:SetHidden(true)
	resetButton.OnClick = function(self, mouseButton, ctrl, alt, shift)
		if(mouseButton == 1) then
			selector:Reset()
		end
	end
	selector.resetButton = resetButton

	minLevelBox:SetText("")
	maxLevelBox:SetText("")

	return selector
end

function LevelSelector:HandleChange()
	if(not self.fireChangeCallback) then
		self.fireChangeCallback = zo_callLater(function()
			self.fireChangeCallback = nil
			CALLBACK_MANAGER:FireCallbacks(self.callbackName, self)
		end, 100)
	end
end

function LevelSelector:Reset()
	TRADING_HOUSE.m_levelRangeFilterType = TRADING_HOUSE_FILTER_TYPE_LEVEL
	TRADING_HOUSE.m_levelRangeToggle:SetState(BSTATE_NORMAL, false)
	TRADING_HOUSE.m_levelRangeLabel:SetText(GetString(SI_TRADING_HOUSE_BROWSE_LEVEL_RANGE_LABEL))

	self.min[TRADING_HOUSE_FILTER_TYPE_LEVEL] = nil
	self.min[TRADING_HOUSE_FILTER_TYPE_VETERAN_LEVEL] = nil
	self.max[TRADING_HOUSE_FILTER_TYPE_LEVEL] = nil
	self.max[TRADING_HOUSE_FILTER_TYPE_VETERAN_LEVEL] = nil

	self.slider:SetMinMax(MIN_LEVEL, MAX_LEVEL)
	self.minLevelBox:SetText("")
	self.maxLevelBox:SetText("")
end

function LevelSelector:IsDefault()
	local min = self.minLevelBox:GetText()
	local max = self.maxLevelBox:GetText()
	return min == "" and max == ""
end

function LevelSelector:Serialize()
	local min = self.minLevelBox:GetText()
	local max = self.maxLevelBox:GetText()
	local vr = (TRADING_HOUSE.m_levelRangeFilterType ~= TRADING_HOUSE_FILTER_TYPE_LEVEL) and "1" or "0"
	return vr .. ";" .. tostring(min) .. ";" .. tostring(max)
end

function LevelSelector:Deserialize(state)
	local vr, min, max = zo_strsplit(";", state)

	local isNormal = (vr == "0")
	local isNormalActive = (TRADING_HOUSE.m_levelRangeFilterType == TRADING_HOUSE_FILTER_TYPE_LEVEL)
	if((isNormal and not isNormalActive) or (not isNormal and isNormalActive)) then
		TRADING_HOUSE:ToggleLevelRangeMode()
	end

	self.minLevelBox:SetText(min or "")
	self.maxLevelBox:SetText(max or "")
end

function LevelSelector:GetTooltipText(state)
	local vr, minLevel, maxLevel = zo_strsplit(";", state)
	local isNormal = (vr == "0")
	minLevel = tonumber(minLevel)
	maxLevel = tonumber(maxLevel)
	if(minLevel or maxLevel) then
		local label = isNormal and L["LEVEL_SELECTOR_TITLE"] or L["VR_SELECTOR_TITLE"]
		local text = ("%d - %d"):format(minLevel or 1, maxLevel or (isNormal and 50 or 14))
		return {{label = label:sub(0, -2), text = text}}
	end
	return {}
end
