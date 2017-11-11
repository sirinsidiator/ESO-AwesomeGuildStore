local gettext = LibStub("LibGetText")("AwesomeGuildStore").gettext
local MinMaxRangeSlider = AwesomeGuildStore.MinMaxRangeSlider
local FilterBase = AwesomeGuildStore.FilterBase
local ToggleButton = AwesomeGuildStore.ToggleButton

local LevelFilter = FilterBase:Subclass()
AwesomeGuildStore.LevelFilter = LevelFilter

local MIN_LEVEL = 1
local MAX_LEVEL = GetMaxLevel()
local MIN_POINTS = 10
local MAX_POINTS = GetChampionPointsPlayerProgressionCap()
local LINE_SPACING = 4
local LEVEL_FILTER_TYPE_ID = 3
local SET_LEVEL_TEXTURE = "EsoUI/Art/Inventory/inventory_currencyTab_onCharacter_%s.dds"
local BUTTON_SIZE = 32
local SKIP_REFRESH = true

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

    -- TRANSLATORS: tooltip text for the set to level filter's "set to level" button on the sell tab
    local charLevelButtonLabel = gettext("Set To Character Level")
    local charLevelButtonLabel = ToggleButton:New(container, "$(parent)CharLevelButton", SET_LEVEL_TEXTURE, 0, 0, BUTTON_SIZE, BUTTON_SIZE, charLevelButtonLabel)
    charLevelButtonLabel.control:ClearAnchors()
    charLevelButtonLabel.control:SetAnchor(LEFT, maxLevel, RIGHT, 5, 0)
    charLevelButtonLabel.HandlePress = function(button)
        self:Reset(SKIP_REFRESH)
        local level = GetUnitLevel("player")
        if(level < MAX_LEVEL) then
            self:SetValues(level, level)
        else
            local cp = math.min(MAX_POINTS, GetUnitChampionPoints("player"))
            tradingHouse:ToggleLevelRangeMode(SKIP_REFRESH)
            self:SetValues(cp, cp)
        end
        self:RefreshDisplay()
    end

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

    local tooltipText = gettext("Reset <<1>> Filter", levelRangeLabel:GetText():gsub(":", ""))
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

    local function SetValues(min, max, skipTextboxUpdate)
        if(self.isRefreshing) then return end
        self:SetValues(min, max)
        self:RefreshDisplay(skipTextboxUpdate)
        self:HandleChange()
    end

    slider.OnValueChanged = function(slider, min, max)
        if(min == self.currentRange.min) then
            min = nil
        end
        if(max == self.currentRange.max) then
            max = nil
        end
        SetValues(min, max)
    end

    local function UpdateSliderFromTextBoxSkipTextboxUpdate()
        local min = tonumber(minLevelBox:GetText())
        local max = tonumber(maxLevelBox:GetText())
        SetValues(min, max, true)
    end

    local function UpdateSliderFromTextBox()
        local min = tonumber(minLevelBox:GetText())
        local max = tonumber(maxLevelBox:GetText())
        SetValues(min, max)
    end

    minLevelBox:SetHandler("OnTextChanged", UpdateSliderFromTextBoxSkipTextboxUpdate)
    maxLevelBox:SetHandler("OnTextChanged", UpdateSliderFromTextBoxSkipTextboxUpdate)
    minLevelBox:SetHandler("OnFocusLost", UpdateSliderFromTextBox)
    maxLevelBox:SetHandler("OnFocusLost", UpdateSliderFromTextBox)

    tradingHouseWrapper:Wrap("ToggleLevelRangeMode", function(originalToggleLevelRangeMode, tradingHouse, skipRefresh)
        originalToggleLevelRangeMode(tradingHouse)
        if(not skipRefresh) then
            self:RefreshDisplay()
        end
    end)

    local stateMap = {
        [BSTATE_NORMAL] = TRADING_HOUSE_FILTER_TYPE_LEVEL,
        [BSTATE_PRESSED] = TRADING_HOUSE_FILTER_TYPE_CHAMPION_POINTS,
    }

    ZO_PreHook(tradingHouse.m_levelRangeToggle, "SetState", function(_, state)
        local type = stateMap[state]
        if(type) then
            self.currentRange = self.range[type]
        end
    end)

    ZO_PreHook(tradingHouse.m_search, "InternalExecuteSearch", function(search)
        local filter = search.m_filters[tradingHouse.m_levelRangeFilterType]
        local min, max
        if(self.isAttached) then
            local currentRange = self.currentRange
            min = currentRange.currentMin
            max = currentRange.currentMax
            if(min ~= nil and min == max) then
                max = nil
            elseif(min == nil and max ~= nil) then
                min = currentRange.min
            elseif(min ~= nil and max == nil) then
                max = currentRange.max
            end
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

function LevelFilter:RefreshDisplay(skipRefreshingTextboxes)
    self.isRefreshing = true
    local currentRange = self.currentRange

    if(not skipRefreshingTextboxes) then
        self.minLevelBox:SetText(currentRange.currentMin or "")
        self.maxLevelBox:SetText(currentRange.currentMax or "")
    end

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

function LevelFilter:Reset(skipRefresh)
    self.tradingHouse.m_levelRangeFilterType = TRADING_HOUSE_FILTER_TYPE_LEVEL
    self.tradingHouse.m_levelRangeToggle:SetState(BSTATE_NORMAL, false)
    self.tradingHouse.m_levelRangeLabel:SetText(GetString(SI_TRADING_HOUSE_BROWSE_LEVEL_RANGE_LABEL))

    self.currentRange = self.range[TRADING_HOUSE_FILTER_TYPE_LEVEL]
    self.range[TRADING_HOUSE_FILTER_TYPE_LEVEL].currentMin = nil
    self.range[TRADING_HOUSE_FILTER_TYPE_LEVEL].currentMax = nil
    self.range[TRADING_HOUSE_FILTER_TYPE_CHAMPION_POINTS].currentMin = nil
    self.range[TRADING_HOUSE_FILTER_TYPE_CHAMPION_POINTS].currentMax = nil

    if(not skipRefresh) then
        self:RefreshDisplay()
    end
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
        local label = isNormal and GetString(SI_TRADING_HOUSE_BROWSE_LEVEL_RANGE_LABEL) or GetString(SI_TRADING_HOUSE_BROWSE_CHAMPION_POINTS_RANGE_LABEL)
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

function LevelFilter:OnAttached()
    self.isAttached = true
end

function LevelFilter:OnDetached()
    self.isAttached = false
end