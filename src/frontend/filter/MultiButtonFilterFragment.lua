local AGS = AwesomeGuildStore

local FilterFragment = AGS.class.FilterFragment
local SimpleIconButton = AGS.class.SimpleIconButton

local BUTTON_SIZE = 32
local BUTTONS_PER_ROW = 7
local BUTTON_OFFSET_Y = 18
local DISABLED = true
local SILENT = true

local MultiButtonFilterFragment = FilterFragment:Subclass()
AGS.class.MultiButtonFilterFragment = MultiButtonFilterFragment

function MultiButtonFilterFragment:New(...)
    return FilterFragment.New(self, ...)
end

function MultiButtonFilterFragment:Initialize(filterId)
    FilterFragment.Initialize(self, filterId)

    self:InitializeControls()
    self:InitializeHandlers()
end

function MultiButtonFilterFragment:InitializeControls()
    local container = self:GetContainer()
    local values = self.filter:GetRawValues()

    local buttons = {}
    local buttonsByValue = {}
    local width = container:GetWidth()
    local spacing = width / BUTTONS_PER_ROW
    for i = 1, #values do
        local value = values[i]
        local button = self:CreateButton(container, i, value)

        local x = spacing * (math.mod(i - 1, BUTTONS_PER_ROW))
        local y = BUTTON_SIZE * math.floor((i - 1) / BUTTONS_PER_ROW)
        button:SetAnchor(TOPLEFT, container, TOPLEFT, x, y)

        buttons[#buttons + 1] = button
        buttonsByValue[value] = button
    end
    self.buttons = buttons
    self.buttonsByValue = buttonsByValue
end

function MultiButtonFilterFragment:CreateButton(container, i, value)
    local control = CreateControl("$(parent)Button" .. i, container, CT_BUTTON)
    local button = SimpleIconButton:New(control)
    button:SetClickSound(SOUNDS.DEFAULT_CLICK)
    button:SetSize(BUTTON_SIZE)
    button:SetTooltipText(value.label)
    button:SetTextureTemplate(value.icon)
    button.value = value
    button.index = i
    return button
end

function MultiButtonFilterFragment:InitializeHandlers()
    local buttons = self.buttons
    local buttonsByValue = self.buttonsByValue
    local filter = self.filter

    local lastInteractedButton = buttons[1]
    local lastInteraction = true
    local function OnClick(button, ctrl, alt, shift)
        local wasSelected = filter:IsSelected(button.value)
        if(shift) then -- change multiple buttons
            local startIndex = lastInteractedButton.index
            local endIndex = button.index
            if(startIndex > endIndex) then
                startIndex = button.index
                endIndex = lastInteractedButton.index
            end

            for i = 1, #buttons do
                if(ctrl) then
                    if(i < startIndex or i > endIndex) then
                        -- don't change them
                    else
                        filter:SetSelected(buttons[i].value, lastInteraction, SILENT)
                    end
                else
                    if(i < startIndex or i > endIndex) then
                        filter:SetSelected(buttons[i].value, false, SILENT)
                    else
                        filter:SetSelected(buttons[i].value, true, SILENT)
                    end
                    lastInteraction = true
                end
            end
        else -- just operate on one button
            if(not ctrl) then
                if(filter:GetSelectionCount() > 1) then
                    wasSelected = false
                end
                filter:Reset(SILENT)
            end

            if(not shift) then
                lastInteractedButton = button
            end
            filter:SetSelected(button.value, not wasSelected, SILENT)
            lastInteraction = not wasSelected
        end

        filter:OnSelectionChanged()
    end

    for i = 1, #buttons do
        local button = buttons[i]
        button:SetClickHandler(MOUSE_BUTTON_INDEX_LEFT, OnClick)
    end

    local function OnFilterChanged(self, selection)
        for value, state in pairs(selection) do
            buttonsByValue[value]:SetState(state, not DISABLED)
        end
    end

    self.OnValueChanged = OnFilterChanged
end

function MultiButtonFilterFragment:SetEnabled(enabled)
    FilterFragment.SetEnabled(self, enabled)
    local buttons = self.buttons
    for i = 1, #buttons do
        buttons[i]:SetEnabled(enabled)
    end
end
