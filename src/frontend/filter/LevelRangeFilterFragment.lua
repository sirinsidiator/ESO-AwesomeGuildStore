local AGS = AwesomeGuildStore

local ValueRangeFilterFragmentBase = AGS.class.ValueRangeFilterFragmentBase
local SimpleIconButton = AGS.class.SimpleIconButton
local SimpleInputBox = AGS.class.SimpleInputBox

local ITEM_REQUIREMENT_RANGE = AGS.data.ITEM_REQUIREMENT_RANGE

local gettext = AGS.internal.gettext

local GetNormalizedLevel = AGS.internal.GetNormalizedLevel
local GetLevelAndType = AGS.internal.GetLevelAndType
local GetSteppedNormalizedLevel = AGS.internal.GetSteppedNormalizedLevel


local SKIP_UPDATE = true
local RANGE_TYPE_LEVEL = ITEM_REQUIREMENT_RANGE.RANGE_TYPE_LEVEL
local RANGE_TYPE_CHAMPION_POINTS = ITEM_REQUIREMENT_RANGE.RANGE_TYPE_CHAMPION_POINTS
local RANGE_INFO = ITEM_REQUIREMENT_RANGE.BUTTON_INFO
local MAX_LEVEL = ITEM_REQUIREMENT_RANGE.MAX_LEVEL
local MIN_CHAMPION_POINTS = ITEM_REQUIREMENT_RANGE.MIN_CHAMPION_POINTS

local LevelRangeFilterFragment = ValueRangeFilterFragmentBase:Subclass()
AGS.class.LevelRangeFilterFragment = LevelRangeFilterFragment

function LevelRangeFilterFragment:New(...)
    return ValueRangeFilterFragmentBase.New(self, ...)
end

function LevelRangeFilterFragment:Initialize(filterId) -- TODO: extract base ValueRangeFilterFragment
    ValueRangeFilterFragmentBase.Initialize(self, filterId)
    self.currentRangeType = {}

    local container = self:GetContainer()
    local config = self.filter:GetConfig()
    self.min = config.min
    self.max = config.max

    local inputContainer = CreateControlFromVirtual("$(parent)Input", container, "AwesomeGuildStoreLevelInputTemplate")
    inputContainer:SetAnchor(TOPLEFT, self.slider.control, BOTTOMLEFT, 0, 4)
    inputContainer:SetAnchor(RIGHT, container, RIGHT, 0, 0, ANCHOR_CONSTRAINS_X)

    local minLevel, minLevelToggle = self:SetupInputBox(inputContainer, "MinLevel")
    local maxLevel, maxLevelToggle = self:SetupInputBox(inputContainer, "MaxLevel")

    local function OnInputChanged(input)
        if(self.fromFilter) then return end
        local min, max = self:GetInputValues()
        self.filter:SetValues(min, max)
        if min ~= minLevel:GetValue() or max ~= maxLevel:GetValue() then
            self:OnValueChanged(min, max)
        end
    end
    minLevel.OnValueChanged = OnInputChanged
    maxLevel.OnValueChanged = OnInputChanged

    local function ToggleLevelRangeType(control)
        local type = self.currentRangeType[control]
        if(type == RANGE_TYPE_LEVEL) then
            type = RANGE_TYPE_CHAMPION_POINTS
        else
            type = RANGE_TYPE_LEVEL
        end

        self:SetLevelRangeType(control, type)
    end
    minLevelToggle:SetHandler("OnClicked", ToggleLevelRangeType)
    maxLevelToggle:SetHandler("OnClicked", ToggleLevelRangeType)

    self:SetLevelRangeType(minLevelToggle, RANGE_TYPE_LEVEL, SKIP_UPDATE)
    self:SetLevelRangeType(maxLevelToggle, RANGE_TYPE_CHAMPION_POINTS, SKIP_UPDATE)

    local currentLevelButton = SimpleIconButton:New(inputContainer:GetNamedChild("CurrentLevelButton"))
    currentLevelButton:SetTextureTemplate("EsoUI/Art/Inventory/inventory_currencyTab_onCharacter_%s.dds")
    -- TRANSLATORS: tooltip text for the set to level filter's "set to level" button on the sell tab
    currentLevelButton:SetTooltipText(gettext("Set To Character Level"))
    currentLevelButton:SetClickHandler(MOUSE_BUTTON_INDEX_LEFT, function()
        local level, cp = GetUnitLevel("player"), GetUnitChampionPoints("player")
        if(cp > 0 and level >= MAX_LEVEL) then
            level = cp + MAX_LEVEL
        end
        self.filter:SetValues(level, level)
    end)

    self.minLevel = minLevel
    self.maxLevel = maxLevel
    self.minLevelToggle = minLevelToggle
    self.maxLevelToggle = maxLevelToggle
    self.currentLevelButton = currentLevelButton
end

function LevelRangeFilterFragment:SetupInputBox(inputContainer, name)
    local input = SimpleInputBox:New(inputContainer:GetNamedChild(name .. "Input"))
    input:SetType(SimpleInputBox.INPUT_TYPE_NUMERIC)
    input:SetTextAlign(SimpleInputBox.TEXT_ALIGN_RIGHT)

    local rangeToggle = inputContainer:GetNamedChild(name .. "Type")
    rangeToggle.input = input
    return input, rangeToggle
end

function LevelRangeFilterFragment:ToNearestValue(value)
    return GetSteppedNormalizedLevel(value)
end

function LevelRangeFilterFragment:OnValueChanged(min, max)
    self.fromFilter = true

    if(max and max >= self.max) then max = nil end
    if(min and min >= self.max) then min = self.max end
    if(not max and min == self.min) then min = nil end
    if(max and not min) then min = 1 end

    self.slider:SetRangeValue(min, max)
    self:SetInputValues(min, max)

    self.fromFilter = false
end

function LevelRangeFilterFragment:GetInputValues()
    local minType = self.currentRangeType[self.minLevelToggle]
    local maxType = self.currentRangeType[self.maxLevelToggle]
    local min = GetNormalizedLevel(self.minLevel:GetValue(), minType)
    local max = GetNormalizedLevel(self.maxLevel:GetValue(), maxType)
    return min, max
end

function LevelRangeFilterFragment:SetInputValues(min, max)
    local min, minType = GetLevelAndType(min)
    local max, maxType = GetLevelAndType(max)

    self:SetLevelRangeType(self.minLevelToggle, minType or RANGE_TYPE_LEVEL, SKIP_UPDATE)
    self:SetLevelRangeType(self.maxLevelToggle, maxType or RANGE_TYPE_CHAMPION_POINTS, SKIP_UPDATE)
    self.minLevel:SetValue(min)
    self.maxLevel:SetValue(max)
end

function LevelRangeFilterFragment:SetLevelRangeType(control, type, skipUpdate)
    local currentRangeType = self.currentRangeType
    if(not type or type == currentRangeType[control]) then return end

    local minLevelToggle = self.minLevelToggle
    local maxLevelToggle = self.maxLevelToggle
    local oldMinType = currentRangeType[minLevelToggle]
    local oldMaxType = currentRangeType[maxLevelToggle]

    local rangeInfo = RANGE_INFO[type]
    control:SetNormalTexture(rangeInfo.normal)
    control:SetPressedTexture(rangeInfo.pressed)
    control:SetMouseOverTexture(rangeInfo.mouseOver)
    control.input:SetMin(rangeInfo.minValue)
    control.input:SetMax(rangeInfo.maxValue)

    currentRangeType[control] = type

    if(not skipUpdate) then
        if(control == minLevelToggle and currentRangeType[minLevelToggle] == RANGE_TYPE_CHAMPION_POINTS) then
            self:SetLevelRangeType(maxLevelToggle, RANGE_TYPE_CHAMPION_POINTS, SKIP_UPDATE)
        elseif(control == maxLevelToggle and currentRangeType[maxLevelToggle] == RANGE_TYPE_LEVEL) then
            self:SetLevelRangeType(minLevelToggle, RANGE_TYPE_LEVEL, SKIP_UPDATE)
        end

        local minType = currentRangeType[minLevelToggle]
        local maxType = currentRangeType[maxLevelToggle]
        local min = self.minLevel:GetValue()
        local max = self.maxLevel:GetValue()

        if(oldMinType ~= minType) then
            if(minType == RANGE_TYPE_CHAMPION_POINTS) then
                min = MIN_CHAMPION_POINTS
            else
                min = MAX_LEVEL
            end
        end

        if(oldMaxType ~= maxType) then
            if(maxType == RANGE_TYPE_LEVEL) then
                max = MAX_LEVEL
            else
                max = MIN_CHAMPION_POINTS
            end
        end

        self.filter:SetValues(GetNormalizedLevel(min, minType), GetNormalizedLevel(max, maxType))
    end
end

function LevelRangeFilterFragment:OnAttach(filterArea)
    local editGroup = filterArea:GetEditGroup()
    editGroup:InsertControl(self.minLevel)
    editGroup:InsertControl(self.maxLevel)
end

function LevelRangeFilterFragment:OnDetach(filterArea)
    local editGroup = filterArea:GetEditGroup()
    editGroup:RemoveControl(self.minLevel)
    editGroup:RemoveControl(self.maxLevel)
end

function LevelRangeFilterFragment:SetEnabled(enabled)
    ValueRangeFilterFragmentBase.SetEnabled(self, enabled)
    self.minLevel:SetEnabled(enabled)
    self.maxLevel:SetEnabled(enabled)
    self.minLevelToggle:SetEnabled(enabled)
    self.maxLevelToggle:SetEnabled(enabled)
    self.currentLevelButton:SetEnabled(enabled)
end
