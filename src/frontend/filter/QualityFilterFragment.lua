local AGS = AwesomeGuildStore

local ValueRangeFilterFragmentBase = AGS.class.ValueRangeFilterFragmentBase
local SimpleIconButton = AGS.class.SimpleIconButton

local BUTTON_SIZE = 36
local BUTTON_PADDING = 14
local BUTTON_OFFSET_Y = 18

local QUALITY_BUTTON_OVER_ICON = "AwesomeGuildStore/images/qualitybuttons/over.dds"

local QualityFilterFragment = ValueRangeFilterFragmentBase:Subclass()
AGS.class.QualityFilterFragment = QualityFilterFragment

function QualityFilterFragment:New(...)
    return ValueRangeFilterFragmentBase.New(self, ...)
end

function QualityFilterFragment:Initialize(filterId)
    ValueRangeFilterFragmentBase.Initialize(self, filterId)

    local filter = self.filter
    local container = self:GetContainer()
    local config = self.filter:GetConfig()
    self.steps = config.steps

    local function SetMinQuality(button, ctrl, alt, shift)
        local min, max = filter:GetValues()
        if(not shift) then max = button.value end
        filter:SetValues(button.value, max)
    end

    local function SetMaxQuality(button, ctrl, alt, shift)
        local min, max = filter:GetValues()
        if(not shift) then min = button.value end
        filter:SetValues(min, button.value)
    end

    local buttons = {}
    local width = container:GetWidth()
    local valueCount = #config.steps
    for i = 1, valueCount do
        local button = self:CreateButton(container, i, config.steps[i])
        local spacing = (width + BUTTON_PADDING) / valueCount
        button:SetAnchor(TOPLEFT, self.slider.control, TOPLEFT, spacing * (i - 1), BUTTON_OFFSET_Y)
        button:SetClickHandler(MOUSE_BUTTON_INDEX_LEFT, SetMinQuality)
        button:SetClickHandler(MOUSE_BUTTON_INDEX_RIGHT, SetMaxQuality)
        buttons[#buttons + 1] = button
    end
    self.buttons = buttons
end

function QualityFilterFragment:ToNearestValue(value)
    return self.steps[value].id
end

function QualityFilterFragment:CreateButton(container, i, data)
    local control = CreateControl("$(parent)Button" .. i, container, CT_BUTTON)
    local button = SimpleIconButton:New(control)
    button:SetClickSound(SOUNDS.DEFAULT_CLICK)
    button:SetSize(BUTTON_SIZE)
    button:SetTooltipText(data.label)
    button:SetTextureTemplate(data.icon)
    button:SetMouseOverTexture(QUALITY_BUTTON_OVER_ICON)
    button.value = data.id
    return button
end

function QualityFilterFragment:SetEnabled(enabled)
    ValueRangeFilterFragmentBase.SetEnabled(self, enabled)
    local buttons = self.buttons
    for i = 1, #buttons do
        buttons[i]:SetEnabled(enabled)
    end
end
