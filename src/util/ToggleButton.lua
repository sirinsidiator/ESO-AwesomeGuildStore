local ToggleButton = ZO_Object:Subclass()
AwesomeGuildStore.class.ToggleButton = ToggleButton

function ToggleButton:New(parent, name, textureName, x, y, width, height, tooltipText, sound)
	local button = ZO_Object.New(self)
	button.pressed = false
	button.locked = false

	local control = parent:CreateControl(name, CT_BUTTON)
	control:SetNormalTexture(textureName:format("up"))
	control:SetPressedTexture(textureName:format("down"))
	control:SetMouseOverTexture(textureName:format("over"))
	control:SetClickSound(sound or SOUNDS.DEFAULT_CLICK)
	control:SetHidden(false)
	control:SetDimensions(width, height)
	control:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
	control:SetHandler("OnMouseUp", function(control, button, isInside)
		if(button == 1 and isInside) then
			control.parent:Toggle(false)
		end
	end)
	control.mouseInside = false
	control.OnMouseEnter = function()
		control.mouseInside = true
		local text = button.toolTipText
		if(not text or text == "") then return end
		InitializeTooltip(InformationTooltip)
		InformationTooltip:ClearAnchors()
		InformationTooltip:SetOwner(control, BOTTOM, 5, 0)
		SetTooltipText(InformationTooltip, text)
	end
	control:SetHandler("OnMouseEnter", control.OnMouseEnter)
	control.OnMouseExit = function()
		control.mouseInside = false
		local text = button.toolTipText
		if(not text or text == "") then return end
		ClearTooltip(InformationTooltip)
	end
	control:SetHandler("OnMouseExit", control.OnMouseExit)
	control.parent = button
	button.control = control

	if(tooltipText) then
		button:SetTooltipText(tooltipText)
	end

	return button
end

function ToggleButton:SetTooltipText(text)
	self.toolTipText = text
	if(self.control.mouseInside) then
		local handler = self.control:GetHandler("OnMouseEnter")
		if(handler) then handler() end
	end
end

function ToggleButton:Toggle(fromGroup)
	if(self:IsPressed()) then
		self:Release(fromGroup)
	else
		self:Press(fromGroup)
	end
end

function ToggleButton:Press(fromGroup)
	local canPress = (not self:IsLocked() and not self:IsPressed())
	if(canPress and self.group) then self.group:IncrementPressedButtonCount() end
	if(not canPress or not self:HandlePress(fromGroup)) then
		if(canPress and self.group) then self.group:DecrementPressedButtonCount() end
		return
	end
	self.control:SetState(BSTATE_PRESSED, true)
	self.pressed = true
end

function ToggleButton:HandlePress(fromGroup)
	-- overwrite this
	return true
end

function ToggleButton:Release(fromGroup)
	local canRelease = (not self:IsLocked() and self:IsPressed())
	if(canRelease and self.group) then self.group:DecrementPressedButtonCount() end
	if(not canRelease or not self:HandleRelease(fromGroup)) then
		if(canRelease and self.group) then self.group:IncrementPressedButtonCount() end
		return
	end
	self.control:SetState(BSTATE_NORMAL, true)
	self.pressed = false
end

function ToggleButton:HandleRelease(fromGroup)
	-- overwrite this
	return true
end

function ToggleButton:IsPressed()
	return self.pressed
end

function ToggleButton:Lock(fromGroup)
	if(self:IsLocked() or not self:HandleLock(fromGroup)) then return end
	self.control:SetState(self:IsPressed() and BSTATE_DISABLED_PRESSED or BSTATE_DISABLED)
	self.locked = true
end

function ToggleButton:HandleLock(fromGroup)
	-- overwrite this
	return true
end

function ToggleButton:Unlock(fromGroup)
	if(not self:IsLocked() or not self:HandleUnlock(fromGroup)) then return end
	self.control:SetState(self:IsPressed() and BSTATE_PRESSED or BSTATE_NORMAL)
	self.locked = false
end

function ToggleButton:HandleUnlock(fromGroup)
	-- overwrite this
	return true
end

function ToggleButton:IsLocked()
	return self.locked
end
