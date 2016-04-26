local L = AwesomeGuildStore.Localization
local MinMaxRangeSlider = AwesomeGuildStore.MinMaxRangeSlider
local FilterBase = AwesomeGuildStore.FilterBase

local LevelFilter = FilterBase:Subclass()
AwesomeGuildStore.LevelFilter = LevelFilter

local MIN_LEVEL = 1
local MAX_LEVEL = 50
local MIN_POINTS = 1
local MAX_POINTS = 160
local LINE_SPACING = 4
local LEVEL_FILTER_TYPE_ID = 3
local TRADING_HOUSE_FILTER_TYPE_CHAMPION_POINTS = TRADING_HOUSE_FILTER_TYPE_CHAMPION_POINTS
if(GetAPIVersion() == 100014) then
	TRADING_HOUSE_FILTER_TYPE_CHAMPION_POINTS = TRADING_HOUSE_FILTER_TYPE_VETERAN_LEVEL
	MAX_POINTS = 16
end

function LevelFilter:New(name, tradingHouseWrapper, ...)
	return FilterBase.New(self, LEVEL_FILTER_TYPE_ID, name, tradingHouseWrapper, ...)
end

function LevelFilter:Initialize(name, tradingHouseWrapper)
	self.isLocal = false
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
	minLevel:SetAnchor(LEFT, levelRangeToggle, RIGHT, (GetAPIVersion() == 100014 and 0 or 10), 0) -- TODO

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
		local min = ValueFromText(minValue, isLevel and MIN_LEVEL or MIN_POINTS)
		local max = ValueFromText(maxValue, isLevel and MAX_LEVEL or MAX_POINTS)

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
			slider:SetMinMax(MIN_POINTS, MAX_POINTS)
			minLevelBox:SetText(self.min[TRADING_HOUSE_FILTER_TYPE_CHAMPION_POINTS] or "")
			maxLevelBox:SetText(self.max[TRADING_HOUSE_FILTER_TYPE_CHAMPION_POINTS] or "")
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
		local filter = self.m_filters[isLevel and TRADING_HOUSE_FILTER_TYPE_LEVEL or TRADING_HOUSE_FILTER_TYPE_CHAMPION_POINTS]

		if(min == nil and max == nil) then
			return
		elseif(min == nil) then
			min = isLevel and MIN_LEVEL or MIN_POINTS
		elseif(max == nil) then
			max = isLevel and MAX_LEVEL or MAX_POINTS
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
	self.max[TRADING_HOUSE_FILTER_TYPE_LEVEL] = nil
	self.min[TRADING_HOUSE_FILTER_TYPE_CHAMPION_POINTS] = nil
	self.max[TRADING_HOUSE_FILTER_TYPE_CHAMPION_POINTS] = nil

	self.slider:SetMinMax(MIN_LEVEL, MAX_LEVEL)
	self.minLevelBox:SetText("")
	self.maxLevelBox:SetText("")
end

function LevelFilter:IsDefault()
	local min = self.minLevelBox:GetText()
	local max = self.maxLevelBox:GetText()
	return min == "" and max == "" and self.tradingHouse.m_levelRangeFilterType == TRADING_HOUSE_FILTER_TYPE_LEVEL
end

function LevelFilter:Serialize()
	local min = self.minLevelBox:GetText()
	local max = self.maxLevelBox:GetText()
	local cp = (self.tradingHouse.m_levelRangeFilterType ~= TRADING_HOUSE_FILTER_TYPE_LEVEL) and "1" or "0"
	return cp .. ";" .. tostring(min) .. ";" .. tostring(max)
end

function LevelFilter:Deserialize(state, version)
	local cp, min, max = zo_strsplit(";", state)
	local isNormal = (cp == "0")
	if(not isNormal and version == 2 and GetAPIVersion() > 100014) then -- TODO
		min = tonumber(min)
		max = tonumber(max)
		if(min and min > 1) then min = min * 10 end
		if(max and max > 1) then max = max * 10 end
	end

	local isNormalActive = (self.tradingHouse.m_levelRangeFilterType == TRADING_HOUSE_FILTER_TYPE_LEVEL)
	if((isNormal and not isNormalActive) or (not isNormal and isNormalActive)) then
		self.tradingHouse:ToggleLevelRangeMode()
	end

	self.minLevelBox:SetText(min or "")
	self.maxLevelBox:SetText(max or "")
end

function LevelFilter:GetTooltipText(state, version)
	local cp, minLevel, maxLevel = zo_strsplit(";", state)
	local isNormal = (cp == "0")
	minLevel = tonumber(minLevel)
	maxLevel = tonumber(maxLevel)
	if(not isNormal and version == 2 and GetAPIVersion() > 100014) then -- TODO
		if(minLevel and minLevel > 1) then minLevel = minLevel * 10 end
		if(maxLevel and maxLevel > 1) then maxLevel = maxLevel * 10 end
	end

	if(minLevel or maxLevel) then
		local label = isNormal and L["LEVEL_SELECTOR_TITLE"] or L["CP_SELECTOR_TITLE"] or L["VR_SELECTOR_TITLE"] -- TODO
		local text = ("%d - %d"):format(minLevel or 1, maxLevel or (isNormal and MAX_LEVEL or MAX_POINTS))
		return {{label = label:sub(0, -2), text = text}}
	end
	return {}
end
