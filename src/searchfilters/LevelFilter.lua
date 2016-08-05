local L = AwesomeGuildStore.Localization
local MinMaxRangeSlider = AwesomeGuildStore.MinMaxRangeSlider
local FilterBase = AwesomeGuildStore.FilterBase

local LevelFilter = FilterBase:Subclass()
AwesomeGuildStore.LevelFilter = LevelFilter

local MIN_LEVEL = 1
local MAX_LEVEL = GetMaxLevel()
local MIN_POINTS = 10
local MAX_POINTS = GetChampionPointsPlayerProgressionCap()
local LINE_SPACING = 4
local LEVEL_FILTER_TYPE_ID = 3

function LevelFilter:New(name, tradingHouseWrapper, ...)
    return FilterBase.New(self, LEVEL_FILTER_TYPE_ID, name, tradingHouseWrapper, ...)
end

function LevelFilter:Initialize(name, tradingHouseWrapper)
    self.isLocal = false
    self:InitializeControls(name, tradingHouseWrapper)
    self:InitializeHandlers(tradingHouseWrapper)
end

function LevelFilter:InitializeControls(name, tradingHouseWrapper)
    local tradingHouse = tradingHouseWrapper.tradingHouse
    local common = tradingHouse.m_browseItems:GetNamedChild("Common")
    local container = self.container

    local levelRangeLabel = common:GetNamedChild("LevelRangeLabel")
    levelRangeLabel:SetParent(container)
    self:SetLabelControl(levelRangeLabel)

    local levelRangeToggle = common:GetNamedChild("LevelRangeToggle")
    levelRangeToggle:SetNormalTexture("EsoUI/Art/LFG/LFG_normalDungeon_up.dds")
    levelRangeToggle:SetMouseOverTexture("EsoUI/Art/LFG/LFG_normalDungeon_over.dds")
    levelRangeToggle:SetParent(container)
    levelRangeToggle:SetClickSound(SOUNDS.DEFAULT_CLICK)
    levelRangeToggle:ClearAnchors()

    local minLevel = common:GetNamedChild("MinLevel")
    minLevel:SetParent(container)
    minLevel:ClearAnchors()
    minLevel:SetAnchor(LEFT, levelRangeToggle, RIGHT, 10, 0)

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

function LevelFilter:InitializeHandlers(tradingHouseWrapper)
    local tradingHouse = tradingHouseWrapper.tradingHouse
    local minLevelBox = self.minLevelBox
    local maxLevelBox = self.maxLevelBox
    local slider = self.slider
    self.tradingHouse = tradingHouse
    self.range = {
        [TRADING_HOUSE_FILTER_TYPE_LEVEL] = {
            currentMin = nil,
            currentMax = nil,
            min = MIN_LEVEL,
            max = MAX_LEVEL,
        },
        [TRADING_HOUSE_FILTER_TYPE_CHAMPION_POINTS] = {
            currentMin = nil,
            currentMax = nil,
            min = MIN_POINTS,
            max = MAX_POINTS,
            step = 10,
        },
    }
    self.currentRange = self.range[TRADING_HOUSE_FILTER_TYPE_LEVEL]

    slider.OnValueChanged = function(slider, min, max)
        if(self.isRefreshing) then return end
        if(min == self.currentRange.min) then
            min = nil
        end
        if(max == self.currentRange.max) then
            max = nil
        end
        self:SetValues(min, max)
        self:RefreshDisplay()
        self:HandleChange()
    end

    local function UpdateSliderFromTextBox()
        if(self.isRefreshing) then return end
        local min = tonumber(minLevelBox:GetText())
        local max = tonumber(maxLevelBox:GetText())
        self:SetValues(min, max)
        self:RefreshDisplay()
        self:HandleChange()
    end

    minLevelBox:SetHandler("OnTextChanged", UpdateSliderFromTextBox)
    maxLevelBox:SetHandler("OnTextChanged", UpdateSliderFromTextBox)

    tradingHouseWrapper:Wrap("ToggleLevelRangeMode", function(originalToggleLevelRangeMode, ...)
        originalToggleLevelRangeMode(...)
        self.currentRange = self.range[tradingHouse.m_levelRangeFilterType]
        self:RefreshDisplay()
    end)

    ZO_PreHook(tradingHouse.m_search, "InternalExecuteSearch", function(search)
        local filter = search.m_filters[tradingHouse.m_levelRangeFilterType]
        local currentRange = self.currentRange
        local min = currentRange.currentMin
        local max = currentRange.currentMax
        if(min ~= nil and min == max) then
            max = nil
        elseif(min == nil and max ~= nil) then
            min = currentRange.min
        elseif(min ~= nil and max == nil) then
            max = currentRange.max
        end
        filter.values[1] = min
        filter.values[2] = max
    end)

    self:RefreshDisplay()
end

local function Clamp(value, min, max)
    return math.min(math.max(value, min), max)
end

function LevelFilter:SetValues(min, max)
    local currentRange = self.currentRange
    local step = currentRange.step
    if(min) then
        if(step) then min = math.floor(min / step) * step end
        min = Clamp(min, currentRange.min, currentRange.max)
    end
    if(max) then
        if(step) then max = math.floor(max / step) * step end
        max = Clamp(max, currentRange.min, currentRange.max)
    end
    currentRange.currentMin = min
    currentRange.currentMax = max
end

function LevelFilter:RefreshDisplay()
    self.isRefreshing = true
    local currentRange = self.currentRange
    self.minLevelBox:SetText(currentRange.currentMin or "")
    self.maxLevelBox:SetText(currentRange.currentMax or "")

    local slider = self.slider
    slider:SetMinMax(currentRange.min, currentRange.max)
    slider:SetRangeValue(currentRange.currentMin or currentRange.min, currentRange.currentMax or currentRange.max)

    self.resetButton:SetHidden(self:IsDefault())
    self.isRefreshing = false
end

function LevelFilter:SetWidth(width)
    self.container:SetWidth(width)
    self.slider:UpdateVisuals()
end

function LevelFilter:Reset()
    self.tradingHouse.m_levelRangeFilterType = TRADING_HOUSE_FILTER_TYPE_LEVEL
    self.tradingHouse.m_levelRangeToggle:SetState(BSTATE_NORMAL, false)
    self.tradingHouse.m_levelRangeLabel:SetText(GetString(SI_TRADING_HOUSE_BROWSE_LEVEL_RANGE_LABEL))

    self.currentRange = self.range[TRADING_HOUSE_FILTER_TYPE_LEVEL]
    self.range[TRADING_HOUSE_FILTER_TYPE_LEVEL].currentMin = nil
    self.range[TRADING_HOUSE_FILTER_TYPE_LEVEL].currentMax = nil
    self.range[TRADING_HOUSE_FILTER_TYPE_CHAMPION_POINTS].currentMin = nil
    self.range[TRADING_HOUSE_FILTER_TYPE_CHAMPION_POINTS].currentMax = nil

    self:RefreshDisplay()
end

function LevelFilter:IsDefault()
    local levelFilter = self.range[TRADING_HOUSE_FILTER_TYPE_LEVEL]
    local isMin = (levelFilter.currentMin == nil)
    local isMax = (levelFilter.currentMax == nil)
    local isLevelFilter = self:IsLevelRangeActive()
    return isMin and isMax and isLevelFilter
end

function LevelFilter:IsLevelRangeActive()
    return self.currentRange == self.range[TRADING_HOUSE_FILTER_TYPE_LEVEL]
end

function LevelFilter:Serialize()
    local min = tostring(self.currentRange.currentMin or "-")
    local max = tostring(self.currentRange.currentMax or "-")
    local cp = self:IsLevelRangeActive() and "0" or "1"
    return string.format("%s;%s;%s", cp, min, max)
end

local function Deserialize(state, version)
    local cp, min, max = zo_strsplit(";", state)
    local isNormal = (cp == "0")
    if(not isNormal and version == 2) then
        min = tonumber(min)
        max = tonumber(max)
        if(min and min > 1) then min = min * 10 end
        if(max and max > 1) then max = max * 10 end
    end
    return isNormal, tonumber(min), tonumber(max)
end

function LevelFilter:Deserialize(state, version)
    local isNormal, min, max = Deserialize(state, version)
    local isNormalActive = self:IsLevelRangeActive()
    if(isNormal ~= isNormalActive) then
        self.tradingHouse:ToggleLevelRangeMode()
    end

    self:SetValues(min, max)
    self:RefreshDisplay()
end

function LevelFilter:GetTooltipText(state, version)
    local isNormal, min, max = Deserialize(state, version)
    if(min or max) then
        local label = isNormal and L["LEVEL_SELECTOR_TITLE"] or L["CP_SELECTOR_TITLE"]
        local text
        if(not min) then
            max = max or (isNormal and MAX_LEVEL or MAX_POINTS)
            text = ("≤%d"):format(max)
        elseif(not max) then
            min = min or (isNormal and MIN_LEVEL or MIN_POINTS)
            text = ("≥%d"):format(min)
        else
            min = min or (isNormal and MIN_LEVEL or MIN_POINTS)
            max = max or (isNormal and MAX_LEVEL or MAX_POINTS)
            text = ("%d - %d"):format(min, max)
        end
        return {{label = label:sub(0, -2), text = text}}
    end
    return {}
end
