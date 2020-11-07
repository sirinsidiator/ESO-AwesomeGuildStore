local INPUT_TYPE_ALL = 1
local INPUT_TYPE_NUMERIC = 2
local INPUT_TYPE_NUMERIC_HEX = 3
local INPUT_TYPE_ALPHABETIC = 4
local INPUT_TYPE_CUSTOM = 5

local TEXT_ALIGN_LEFT = 1
local TEXT_ALIGN_RIGHT = 2

local SimpleInputBox = ZO_Object:Subclass()
AwesomeGuildStore.class.SimpleInputBox = SimpleInputBox

SimpleInputBox.INPUT_TYPE_ALL = INPUT_TYPE_ALL
SimpleInputBox.INPUT_TYPE_NUMERIC = INPUT_TYPE_NUMERIC
SimpleInputBox.INPUT_TYPE_NUMERIC_HEX = INPUT_TYPE_NUMERIC_HEX
SimpleInputBox.INPUT_TYPE_ALPHABETIC = INPUT_TYPE_ALPHABETIC
SimpleInputBox.INPUT_TYPE_CUSTOM = INPUT_TYPE_CUSTOM

SimpleInputBox.TEXT_ALIGN_LEFT = TEXT_ALIGN_LEFT
SimpleInputBox.TEXT_ALIGN_RIGHT = TEXT_ALIGN_RIGHT

local ShowPulse, HidePulse, ShowBadPulse
do
    local pulseControl = AwesomeGuildStoreSimpleInputBoxPulse
    local pulseBackground = pulseControl:GetNamedChild("BG")
    local pulseTimeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("CurrencyInputPulse", pulseBackground)
    local badInputTimeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("CurrencyInputBadInput", pulseBackground)

    badInputTimeline:SetHandler("OnPlay", function() pulseBackground:SetAlpha(1) pulseTimeline:Stop() end)
    badInputTimeline:SetHandler("OnStop", function() pulseTimeline:PlayFromStart(1000) end)

    function ShowPulse(control)
        pulseControl:ClearAnchors()
        pulseControl:SetAnchorFill(control)
        pulseControl:SetHidden(false)
        pulseTimeline:PlayFromStart()
    end

    function HidePulse()
        pulseControl:SetHidden(true)
        pulseTimeline:Stop()
    end

    function ShowBadPulse()
        badInputTimeline:PlayFromStart()
    end
end

local function ToNumber(value, base)
    if(not value) then return nil end
    return tonumber(value:gsub(",", "."), base)
end

local function ClampToRange(value, min, max)
    if(min and value < min) then
        return min
    elseif(max and value > max) then
        return max
    end
    return value
end

-- we do not want to loose trailing zeroes, so we have to use string operations
local function ClampToPrecision(value, precision)
    if(not value:find("[.,]")) then return value end

    -- we try our best in case we got something copy pasted that isn't quite a number, but could be made into one
    local integer, comma, decimals = value:match("^(.-)([.,])(.-)$")
    integer = tostring(tonumber(integer) or "0")

    if(precision == 0) then return integer end

    decimals = decimals:gsub("[.,]", ""):sub(1, precision)
    return string.format("%s%s%s", integer, comma, decimals)
end

local RAW_TEXT_FUNCTION = {
    [INPUT_TYPE_ALL] = function(self, value)
        return value
    end,
    [INPUT_TYPE_NUMERIC] = function(self, value)
        if(not value) then
            return ""
        else
            return zo_strformat("<<1>>", tostring(value))
        end
    end,
    [INPUT_TYPE_NUMERIC_HEX] = function(self, value)
        if(not value) then
            return ""
        else
            return string.format("%X", value)
        end
    end,
}

local SANITIZATION_FUNCTION = {
    [INPUT_TYPE_ALL] = function(self, input, lastInput)
        return input, true
    end,
    [INPUT_TYPE_NUMERIC] = function(self, input, lastInput)
        if(not input or input == "") then return "", true end

        local value = ToNumber(input)
        if(not value) then
            if(self.precision > 0 and (input == "," or input == ".")) then
                local prefix = math.max(0, self.min or 0)
                return prefix .. input, true
            end
            return lastInput, false
        end

        local clamped = ClampToRange(value, self.min, self.max)
        if(value ~= clamped) then
            return RAW_TEXT_FUNCTION[INPUT_TYPE_NUMERIC](self, clamped), false
        end

        clamped = ClampToPrecision(input, self.precision)
        if(input ~= clamped) then
            return clamped, false
        end

        return input, true
    end,
    [INPUT_TYPE_NUMERIC_HEX] = function(self, input, lastInput)
        if(input == "") then return input, true end

        local value = ToNumber(input, 16)
        if(not value) then
            return lastInput, false
        end

        local clamped = ClampToRange(value, self.min, self.max)
        if(value ~= clamped) then
            return RAW_TEXT_FUNCTION[INPUT_TYPE_NUMERIC_HEX](self, clamped), false
        end

        return input, true
    end,
    [INPUT_TYPE_ALPHABETIC] = function(self, input, lastInput)
        if(not input:find("[^%a]")) then
            return lastInput, false
        end
        return input, true
    end,
}

local PARSING_FUNCTION = {
    [INPUT_TYPE_ALL] = function(self, input)
        return input
    end,
    [INPUT_TYPE_NUMERIC] = function(self, input)
        return ToNumber(input)
    end,
    [INPUT_TYPE_NUMERIC_HEX] = function(self, input)
        return ToNumber(input, 16)
    end,
}

local FORMATTING_FUNCTION = {
    [INPUT_TYPE_ALL] = function(self, value)
        return value
    end,
    [INPUT_TYPE_NUMERIC] = function(self, value)
        if(not value) then
            return ""
        else
            return zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(value))
        end
    end,
    [INPUT_TYPE_NUMERIC_HEX] = function(self, value)
        if(not value) then
            return ""
        else
            return string.format("%X", value)
        end
    end,
}

SimpleInputBox.RAW_TEXT_FUNCTION = RAW_TEXT_FUNCTION
SimpleInputBox.SANITIZATION_FUNCTION = SANITIZATION_FUNCTION
SimpleInputBox.PARSING_FUNCTION = PARSING_FUNCTION
SimpleInputBox.FORMATTING_FUNCTION = FORMATTING_FUNCTION

function SimpleInputBox:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function SimpleInputBox:Initialize(control, currencies)
    control.controller = self
    self.control = control
    self.virtual = control:GetNamedChild("Virtual")
    self.input = control:GetNamedChild("Box")

    self.value = nil
    self.precision = 0
    self.min = nil
    self.max = nil
    self.enabled = true
    self:SetType(INPUT_TYPE_ALL)
    self:SetTextAlign(TEXT_ALIGN_LEFT)
    self.oldText = ""
    self.oldCursorPosition = 0

    local input = self.input
    local revert = false

    input:SetHandler("OnFocusGained", function()
        if(not self.enabled) then
            input:LoseFocus()
            return
        end

        self:SetText(self:GetRawText(self.value))
        self.oldText = input:GetText()

        ShowPulse(control)

        if(WINDOW_MANAGER:IsHandlingHardwareEvent()) then
            PlaySound(SOUNDS.EDIT_CLICK)
        end
    end)

    input:SetHandler("OnFocusLost", function()
        HidePulse()
        if(revert) then
            revert = false
            self:SetText(self:GetFormattedText(self.value))
        else
            self:SetValue(self:ParseInput(input:GetText()))
        end
    end)

    input:SetHandler("OnEnter", function()
        input:LoseFocus()
    end)

    input:SetHandler("OnEscape", function()
        revert = true
        input:LoseFocus()
    end)

    input:SetHandler("OnTextChanged", function()
        if(self.fromCode) then return end

        local text, valid = self:SanitizeInput(input:GetText(), self.oldText)
        self:OnTextChanged(text)
        self:SetText(text)

        if(not valid) then
            ShowBadPulse()
            input:SetCursorPosition(self.oldCursorPosition)
        end

        self.oldText = text
        self.oldCursorPosition = input:GetCursorPosition()
    end)

    input:SetHandler("OnRectWidthChanged", function()
        if(self.align ~= TEXT_ALIGN_RIGHT) then return end
        -- small hack to prevent the input jumping out of view when it is too long
        local cursorPosition = input:GetCursorPosition()
        input:SetCursorPosition(0)
        input:SetCursorPosition(cursorPosition)
    end)

    control:SetHandler("OnMouseUp", function(control, button, upInside)
        if not self.enabled then return end
        input:TakeFocus()
    end)
end

function SimpleInputBox:SetText(text)
    self.fromCode = true
    self.virtual:SetText(text)
    if(self.input:GetText() ~= text) then
        self.input:SetText(text)
    end
    self.fromCode = false
end

function SimpleInputBox:SetCursorPosition(position)
    return self.input:SetCursorPosition(position)
end

function SimpleInputBox:SetPrecision(precision)
    if(precision < 0) then precision = 0 end
    self.precision = precision
end

function SimpleInputBox:SetMin(min)
    self.min = min
end

function SimpleInputBox:SetMax(max)
    self.max = max
end

function SimpleInputBox:SetTextAlign(align)
    if(align ~= self.align) then
        if(align == TEXT_ALIGN_LEFT) then
            self.input:ClearAnchors()
            self.input:SetHeight(24 + ZO_SINGLE_LINE_EDIT_CONTAINER_PADDING_TOP + ZO_SINGLE_LINE_EDIT_CONTAINER_PADDING_BOTTOM)
            self.input:SetAnchor(TOPLEFT, self.control, TOPLEFT, ZO_SINGLE_LINE_EDIT_CONTAINER_PADDING_LEFT, ZO_SINGLE_LINE_EDIT_CONTAINER_PADDING_TOP)
            self.input:SetAnchor(BOTTOMRIGHT, self.control, BOTTOMRIGHT, -ZO_SINGLE_LINE_EDIT_CONTAINER_PADDING_RIGHT, 0, ANCHOR_CONSTRAINS_X)
        elseif(align == TEXT_ALIGN_RIGHT) then
            self.input:ClearAnchors()
            self.input:SetHeight(24)
            self.input:SetAnchor(TOPLEFT, self.virtual, TOPLEFT, -20, 0)
            self.input:SetAnchor(BOTTOMRIGHT, self.virtual, BOTTOMRIGHT, 0, 0)
        else
            return
        end
        self.align = align
    end
end

function SimpleInputBox:SetType(type, base)
    self.type = type
    self.GetRawText = RAW_TEXT_FUNCTION[type] or RAW_TEXT_FUNCTION[INPUT_TYPE_ALL]
    self.SanitizeInput = SANITIZATION_FUNCTION[type] or SANITIZATION_FUNCTION[INPUT_TYPE_ALL]
    self.ParseInput = PARSING_FUNCTION[type] or PARSING_FUNCTION[INPUT_TYPE_ALL]
    self.GetFormattedText = FORMATTING_FUNCTION[type] or FORMATTING_FUNCTION[INPUT_TYPE_ALL]
end

function SimpleInputBox:SetValue(value)
    local hasChanged = (value ~= self.value)
    self.value = value
    self:SetText(self:GetFormattedText(value))
    if(hasChanged) then
        self:OnValueChanged(value)
    end
end

function SimpleInputBox:OnValueChanged(value)
-- overwrite if needed
end

function SimpleInputBox:OnTextChanged(text)
-- overwrite if needed
end

function SimpleInputBox:GetValue()
    return self.value
end

function SimpleInputBox:GetEditControlGroupIndex()
    return self.input.editControlGroupIndex
end

function SimpleInputBox:SetEditControlGroupIndex(index)
    self.input.editControlGroupIndex = index
end

function SimpleInputBox:SetHandler(name, callback)
    return self.input:SetHandler(name, callback)
end

function SimpleInputBox:GetHandler(name)
    return self.input:GetHandler(name)
end

function SimpleInputBox:TakeFocus()
    return self.input:TakeFocus()
end

function SimpleInputBox:LoseFocus()
    return self.input:LoseFocus()
end

function SimpleInputBox:HasFocus()
    return self.input:HasFocus()
end

function SimpleInputBox:SetMaxInputChars(maxChars)
    return self.input:SetMaxInputChars(maxChars)
end

function SimpleInputBox:SetEnabled(enabled)
    self.enabled = enabled
    local input = self.input
    input:SetEditEnabled(enabled)
    input:SetMouseEnabled(enabled)
    local color = enabled and ZO_DEFAULT_ENABLED_COLOR or ZO_DEFAULT_DISABLED_MOUSEOVER_COLOR
    input:SetColor(color:UnpackRGBA())
    if(not enabled) then
        input:LoseFocus()
    end
end

function SimpleInputBox:IsEnabled()
    return self.enabled
end
