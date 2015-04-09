local L = AwesomeGuildStore.Localization
local MinMaxRangeSlider = AwesomeGuildStore.MinMaxRangeSlider
local FilterBase = AwesomeGuildStore.FilterBase

local LevelFilter = FilterBase:Subclass()
AwesomeGuildStore.LevelFilter = LevelFilter

local MIN_LEVEL = 1
local MAX_LEVEL = 50
local MIN_RANK = 1
local MAX_RANK = 14
local LINE_SPACING = 4
local LEVEL_FITLER_TYPE_ID = 3

function LevelFilter:New(name, tradingHouseWrapper, ...)
	return FilterBase.New(self, LEVEL_FITLER_TYPE_ID, name, tradingHouseWrapper, ...)
end

function LevelFilter:Initialize(name, tradingHouseWrapper)
	self:InitializeControls(name, tradingHouseWrapper.tradingHouse)
	self:InitializeHandlers(tradingHouseWrapper.tradingHouse)
end

function LevelFilter:InitializeControls(name, tradingHouse)
	local common = tradingHouse.m_browseItems:GetNamedChild("Common")
	local container = self.container

	local levelRangeLabel = common:GetNamedChild("LevelRangeLabel")
	levelRangeLabel:SetParent(container)
	self:SetLabelControl(levelRangeLabel)

	local levelRangeToggle = common:GetNamedChild("LevelRangeToggle")
	levelRangeToggle:SetNormalTexture("EsoUI/Art/LFG/LFG_normalDungeon_up.dds")
	levelRangeToggle:SetMouseOverTexture("EsoUI/Art/LFG/LFG_normalDungeon_over.dds")
	levelRangeToggle:SetParent(container)
	levelRangeToggle:ClearAnchors()

	local minLevel = common:GetNamedChild("MinLevel")
	minLevel:SetParent(container)
	minLevel:ClearAnchors()
	minLevel:SetAnchor(LEFT, levelRangeToggle, RIGHT, 0, 0)

	local levelRangeDivider = common:GetNamedChild("LevelRangeDivider")
	levelRangeDivider:SetParent(container)

	local maxLevel = common:GetNamedChild("MaxLevel")
	maxLevel:SetParent(container)

	self.minLevelBox =  common:GetNamedChild("MinLevelBox")
	self.maxLevelBox = common:GetNamedChild("MaxLevelBox")

	local slider = MinMaxRangeSlider:New(container, name .. "Slider")
	slider:SetMinMax(MIN_LEVEL, MAX_LEVEL)
	slider:SetRangeValue(MIN_LEVEL, MAX_LEVEL)
	slider.control:ClearAnchors()
	slider.control:SetAnchor(TOPLEFT, levelRangeLabel, BOTTOMLEFT, 0, LINE_SPACING)
	slider.control:SetAnchor(RIGHT, container, RIGHT, 0, 0)
	self.slider = slider

	levelRangeToggle:SetAnchor(TOPLEFT, slider.control, BOTTOMLEFT, 0, LINE_SPACING)

	container:SetHeight(levelRangeLabel:GetHeight() + LINE_SPACING + slider.control:GetHeight() + LINE_SPACING + minLevel:GetHeight())

	local tooltipText = L["RESET_FILTER_LABEL_TEMPLATE"]:format(levelRangeLabel:GetText():gsub(":", ""))
	self.resetButton:SetTooltipText(tooltipText)
end

function LevelFilter:InitializeHandlers(tradingHouse)
	local minLevelBox = self.minLevelBox
	local maxLevelBox = self.maxLevelBox
	local slider = self.slider
	local setFromTextBox = false
	local togglingRangeMode = false
	self.tradingHouse = tradingHouse
	self.min = {}
	self.max = {}

	slider.OnValueChanged = function(slider, min, max)
		self:HandleChange()
		if(setFromTextBox) then return end
		minLevelBox:SetText(min)
		maxLevelBox:SetText(max)
	end

	local function ValueFromText(value, limit)
		return tonumber(value) or limit
	end

	local function UpdateSliderFromTextBox()
		setFromTextBox = true
		local isLevel = (tradingHouse.m_levelRangeFilterType == TRADING_HOUSE_FILTER_TYPE_LEVEL)
		if(togglingRangeMode) then isLevel = not isLevel end
		local minValue = minLevelBox:GetText()
		local maxValue = maxLevelBox:GetText()
		local min = ValueFromText(minValue, isLevel and MIN_LEVEL or MIN_RANK)
		local max = ValueFromText(maxValue, isLevel and MAX_LEVEL or MAX_RANK)

		if(not togglingRangeMode) then
			self.min[tradingHouse.m_levelRangeFilterType] = tonumber(minValue)
			self.max[tradingHouse.m_levelRangeFilterType] = tonumber(maxValue)
		end

		slider:SetRangeValue(min, max)
		setFromTextBox = false
	end

	minLevelBox:SetHandler("OnTextChanged", UpdateSliderFromTextBox)
	maxLevelBox:SetHandler("OnTextChanged", UpdateSliderFromTextBox)

	ZO_PreHook(tradingHouse, "ToggleLevelRangeMode", function(tradingHouse)
		togglingRangeMode = true
		if(tradingHouse.m_levelRangeFilterType == TRADING_HOUSE_FILTER_TYPE_LEVEL) then
			slider:SetMinMax(MIN_RANK, MAX_RANK)
			minLevelBox:SetText(self.min[TRADING_HOUSE_FILTER_TYPE_VETERAN_LEVEL] or "")
			maxLevelBox:SetText(self.max[TRADING_HOUSE_FILTER_TYPE_VETERAN_LEVEL] or "")
		else
			slider:SetMinMax(MIN_LEVEL, MAX_LEVEL)
			minLevelBox:SetText(self.min[TRADING_HOUSE_FILTER_TYPE_LEVEL] or "")
			maxLevelBox:SetText(self.max[TRADING_HOUSE_FILTER_TYPE_LEVEL] or "")
		end
		togglingRangeMode = false
		zo_callLater(function()
			self.resetButton:SetHidden(self:IsDefault())
		end, 1)
	end)

	ZO_PreHook(tradingHouse.m_search, "InternalExecuteSearch", function(self)
		local min = tonumber(minLevelBox:GetText())
		local max = tonumber(maxLevelBox:GetText())
		local isLevel = (tradingHouse.m_levelRangeFilterType == TRADING_HOUSE_FILTER_TYPE_LEVEL)
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

	minLevelBox:SetText("")
	maxLevelBox:SetText("")
end

function LevelFilter:SetWidth(width)
	self.container:SetWidth(width)
	self.slider:UpdateVisuals()
end

function LevelFilter:Reset()
	self.tradingHouse.m_levelRangeFilterType = TRADING_HOUSE_FILTER_TYPE_LEVEL
	self.tradingHouse.m_levelRangeToggle:SetState(BSTATE_NORMAL, false)
	self.tradingHouse.m_levelRangeLabel:SetText(GetString(SI_TRADING_HOUSE_BROWSE_LEVEL_RANGE_LABEL))

	self.min[TRADING_HOUSE_FILTER_TYPE_LEVEL] = nil
	self.min[TRADING_HOUSE_FILTER_TYPE_VETERAN_LEVEL] = nil
	self.max[TRADING_HOUSE_FILTER_TYPE_LEVEL] = nil
	self.max[TRADING_HOUSE_FILTER_TYPE_VETERAN_LEVEL] = nil

	self.slider:SetMinMax(MIN_LEVEL, MAX_LEVEL)
	self.minLevelBox:SetText("")
	self.maxLevelBox:SetText("")
end

function LevelFilter:IsDefault()
	local min = self.minLevelBox:GetText()
	local max = self.maxLevelBox:GetText()
	return min == "" and max == ""
end

function LevelFilter:Serialize()
	local min = self.minLevelBox:GetText()
	local max = self.maxLevelBox:GetText()
	local vr = (self.tradingHouse.m_levelRangeFilterType ~= TRADING_HOUSE_FILTER_TYPE_LEVEL) and "1" or "0"
	return vr .. ";" .. tostring(min) .. ";" .. tostring(max)
end

function LevelFilter:Deserialize(state)
	local vr, min, max = zo_strsplit(";", state)

	local isNormal = (vr == "0")
	local isNormalActive = (self.tradingHouse.m_levelRangeFilterType == TRADING_HOUSE_FILTER_TYPE_LEVEL)
	if((isNormal and not isNormalActive) or (not isNormal and isNormalActive)) then
		self.tradingHouse:ToggleLevelRangeMode()
	end

	self.minLevelBox:SetText(min or "")
	self.maxLevelBox:SetText(max or "")
end

function LevelFilter:GetTooltipText(state)
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
