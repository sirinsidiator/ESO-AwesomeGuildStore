local SimpleIconButton = ZO_Object:Subclass()
AwesomeGuildStore.SimpleIconButton = SimpleIconButton

local MOUSE_LEFT = 1
local MOUSE_RIGHT = 2
local MOUSE_MIDDLE = 3

function SimpleIconButton:New(name, icon, size, tooltipText, parent)
	local button = ZO_Object.New(self)
	button.locked = false
	button.mouseInside = false

	local control = CreateControlFromVirtual(name, parent or GuiRoot, "ZO_DefaultButton")
	control:SetEndCapWidth(0)
	control:SetDimensions(size, size)
	control:SetHandler("OnMouseUp", function(control, mouseButton, isInside, ctrl, alt, shift)
		if(isInside) then
			local simulateClick = button:OnClick(mouseButton, ctrl, alt, shift)

			if(mouseButton ~= MOUSE_LEFT and simulateClick) then
				-- the mouse down event does not fire for right and middle click and the button does not show any click behavior at all
				-- we emulate it by changing the texture for a bit and playing the click sound manually
				control:SetNormalTexture(button.pressedTexture)
				control:SetMouseOverTexture("")
				zo_callLater(function()
					control:SetNormalTexture(button.normalTexture)
					control:SetMouseOverTexture(button.mouseOverTexture)
				end, 100)
				PlaySound("Click")
			end
		end
	end)
	control:SetHandler("OnMouseEnter", function()
		button.mouseInside = true
		local text = button.tooltipText
		if(not text or text == "") then return end
		InitializeTooltip(InformationTooltip, control, BOTTOM, 5, 0)
		SetTooltipText(InformationTooltip, text)
	end)
	control:SetHandler("OnMouseExit", function()
		button.mouseInside = false
		local text = button.tooltipText
		if(not text or text == "") then return end
		ClearTooltip(InformationTooltip)
	end)
	control.parent = button
	button.control = control

	button:SetNormalTexture(icon:format("up"))
	button:SetPressedTexture(icon:format("down"))
	button:SetMouseOverTexture(icon:format("over"))

	if(tooltipText) then
		button:SetTooltipText(tooltipText)
	end

	return button
end

function SimpleIconButton:SetNormalTexture(texture)
	self.control:SetNormalTexture(texture)
	self.normalTexture = texture
end

function SimpleIconButton:SetPressedTexture(texture)
	self.control:SetPressedTexture(texture)
	self.pressedTexture = texture
end

function SimpleIconButton:SetMouseOverTexture(texture)
	self.control:SetMouseOverTexture(texture)
	self.mouseOverTexture = texture
end

function SimpleIconButton:SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)
	local control = self.control
	control:SetParent(relativeTo)
	control:ClearAnchors()
	control:SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)
end

function SimpleIconButton:SetHidden(hidden)
	self.control:SetHidden(hidden)
end

function SimpleIconButton:SetTooltipText(text)
	self.tooltipText = text
	if(self.mouseInside) then
		local handler = self.control:GetHandler("OnMouseEnter")
		if(handler) then handler() end
	end
end

function SimpleIconButton:OnClick(mouseButton, ctrl, alt, shift)
	-- overwrite this
end
