local BSTATE_NORMAL = BSTATE_NORMAL
local BSTATE_PRESSED = BSTATE_PRESSED
local BSTATE_DISABLED = BSTATE_DISABLED
local BSTATE_DISABLED_PRESSED = BSTATE_DISABLED_PRESSED
local ENABLED_DESATURATION = 0
local DISABLED_DESATURATION = 1

local SimpleIconButton = ZO_InitializingObject:Subclass()
AwesomeGuildStore.class.SimpleIconButton = SimpleIconButton

function SimpleIconButton:Initialize(nameOrControl, parent, suffix)
    local clickHandler = {}
    local doubleClickHandler = {}
    self.clickHandler = clickHandler
    self.doubleClickHandler = doubleClickHandler

    local control = nameOrControl
    if(type(nameOrControl) == "string") then -- TODO: create a static method and otherwise assume it has got a control
        control = CreateControlFromVirtual(nameOrControl, parent or GuiRoot, "ZO_DefaultButton", suffix)
    end

    control:SetEndCapWidth(0)
    control:SetHandler("OnClicked", function(control, button, ...)
        if(clickHandler[button]) then
            clickHandler[button](self, ...)
        end
    end)
    control:SetHandler("OnMouseDoubleClick", function(control, button, ...)
        if(doubleClickHandler[button]) then
            doubleClickHandler[button](self, ...)
        end
    end)
    control:SetHandler("OnMouseEnter", function()
        local text = self.tooltipText
        if(not text or text == "") then return end
        InitializeTooltip(InformationTooltip, control, BOTTOM, 5, 0)
        SetTooltipText(InformationTooltip, text)
    end)
    control:SetHandler("OnMouseExit", function()
        ClearTooltip(InformationTooltip)
    end)
    control.parent = self -- TODO rename to "controller"
    self.control = control
end

function SimpleIconButton:GetControl()
    return self.control
end

function SimpleIconButton:SetSize(size)
    self.control:SetDimensions(size, size)
end

function SimpleIconButton:SetTextureTemplate(textureTemplate)
    self:SetNormalTexture(textureTemplate:format("up"))
    self:SetPressedTexture(textureTemplate:format("down"))
    self:SetMouseOverTexture(textureTemplate:format("over"))
end

function SimpleIconButton:SetNormalTexture(texture)
    self.control:SetNormalTexture(texture)
    self.normalTexture = texture
end

function SimpleIconButton:SetPressedTexture(texture)
    self.control:SetPressedTexture(texture)
    self.control:SetDisabledPressedTexture(texture)
    self.pressedTexture = texture
end

function SimpleIconButton:SetMouseOverTexture(texture)
    self.control:SetMouseOverTexture(texture)
    self.mouseOverTexture = texture
end

function SimpleIconButton:SetClickSound(...)
    return self.control:SetClickSound(...)
end

function SimpleIconButton:ClearAnchors()
    return self.control:ClearAnchors()
end

function SimpleIconButton:SetAnchor(...)
    return self.control:SetAnchor(...)
end

function SimpleIconButton:SetHidden(...)
    return self.control:SetHidden(...)
end

function SimpleIconButton:SetHandler(...)
    return self.control:SetHandler(...)
end

function SimpleIconButton:SetTooltipText(text)
    self.tooltipText = text
end

local function UpdateMouseButtonEnabled(self, mouseButton)
    local callback = self.clickHandler[mouseButton] or self.doubleClickHandler[mouseButton]
    local shouldEnable = (callback ~= nil)
    self.control:EnableMouseButton(mouseButton, shouldEnable)
end

function SimpleIconButton:SetClickHandler(mouseButton, callback)
    self.clickHandler[mouseButton] = callback
    UpdateMouseButtonEnabled(self, mouseButton)
end

function SimpleIconButton:SetDoubleClickHandler(mouseButton, callback)
    self.doubleClickHandler[mouseButton] = callback
    UpdateMouseButtonEnabled(self, mouseButton)
end

function SimpleIconButton:SetState(pressed, disabled)
    if(disabled == nil) then disabled = pressed end

    local state
    if(disabled) then
        state = pressed and BSTATE_DISABLED_PRESSED or BSTATE_DISABLED
    else
        state = pressed and BSTATE_PRESSED or BSTATE_NORMAL
    end
    self.control:SetState(state, state ~= BSTATE_NORMAL)
    self.state = pressed
    self.disabled = disabled
end

function SimpleIconButton:SetEnabled(enabled)
    self.control:SetMouseEnabled(enabled)
    if(enabled) then
        self:SetState(self.state, self.disabled)
        self.control:SetDesaturation(ENABLED_DESATURATION)
    else
        self:SetState(self.state, enabled)
        self.control:SetDesaturation(DISABLED_DESATURATION)
    end
end
