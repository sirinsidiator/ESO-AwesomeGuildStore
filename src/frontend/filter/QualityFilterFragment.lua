local AGS = AwesomeGuildStore

local ValueRangeFilterFragmentBase = AGS.class.ValueRangeFilterFragmentBase
local SimpleIconButton = AGS.class.SimpleIconButton

local BUTTON_SIZE = 36
local BUTTON_OFFSET_X = -12
local BUTTON_OFFSET_Y = 2

local QUALITY_BUTTON_ICON = "AwesomeGuildStore/images/qualitybuttons/qualitybutton_%s.dds"

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
    local width = container:GetWidth() - BUTTON_OFFSET_X * 2
    local valueCount = #config.steps
    local spacing = width / valueCount
    for i = 1, valueCount do
        local button = self:CreateButton(container, i, config.steps[i])
        button:SetAnchor(TOP, self.slider.control, BOTTOM, 0, BUTTON_OFFSET_Y, ANCHOR_CONSTRAINS_Y)
        button:SetAnchor(CENTER, container, LEFT, BUTTON_OFFSET_X + spacing * (i - 0.5), 0, ANCHOR_CONSTRAINS_X)
        button:SetClickHandler(MOUSE_BUTTON_INDEX_LEFT, SetMinQuality)
        button:SetClickHandler(MOUSE_BUTTON_INDEX_RIGHT, SetMaxQuality)
        buttons[#buttons + 1] = button
    end
    self.buttons = buttons
end

function QualityFilterFragment:OnValueChanged(min, max)
    ValueRangeFilterFragmentBase.OnValueChanged(self, min, max)
    local buttons = self.buttons
    local isDefault = self:IsDefault(min, max)
    for i = 1, #buttons do
        local value = buttons[i].value
        local deselected = isDefault or value < min or value > max
        buttons[i]:SetState(not deselected, false)
    end
end

function QualityFilterFragment:CreateButton(container, i, data)
    local control = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)Button", container, "AwesomeGuildStoreQualityButtonTemplate", i)
    local button = SimpleIconButton:New(control)
    button:SetSize(BUTTON_SIZE)
    button:SetTooltipText(data.label)
    button:SetTextureTemplate(QUALITY_BUTTON_ICON)
    button.value = data.id
    control:GetNamedChild("Color"):SetColor(data.color:UnpackRGBA())
    return button
end

function QualityFilterFragment:SetEnabled(enabled)
    ValueRangeFilterFragmentBase.SetEnabled(self, enabled)
    local buttons = self.buttons
    for i = 1, #buttons do
        buttons[i]:SetEnabled(enabled)
    end
end
