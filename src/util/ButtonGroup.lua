local ButtonGroup = ZO_Object:Subclass()
AwesomeGuildStore.class.ButtonGroup = ButtonGroup

function ButtonGroup:New(parent, name, x, y)
	local group = ZO_Object.New(self)

	local control =  parent:CreateControl(name, CT_CONTROL)
	control:SetHidden(false)
	control:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
	control:SetResizeToFitDescendents(true)
	group.control = control

	group.buttons = {}
	group.pressedButtonCount = 0
	group.buttonCount = 0
	return group
end

function ButtonGroup:AddButton(button)
	self.buttons[button.control:GetName()] = button
	self.buttonCount = self.buttonCount + 1
	if(button:IsPressed()) then self:IncrementPressedButtonCount() end
	button.group = self
end

function ButtonGroup:RemoveButton(button)
	self.buttons[button.control:GetName()] = nil
	self.buttonCount = self.buttonCount - 1
	if(button:IsPressed()) then self:DecrementPressedButtonCount() end
	button.group = nil
end

function ButtonGroup:PressAllButtons()
	for name, button in pairs(self.buttons) do
		button:Press(true)
	end
end

function ButtonGroup:ReleaseAllButtons()
	for name, button in pairs(self.buttons) do
		button:Release(true)
	end
end

function ButtonGroup:LockAllButtons()
	for name, button in pairs(self.buttons) do
		button:Lock(true)
	end
end

function ButtonGroup:UnlockAllButtons()
	for name, button in pairs(self.buttons) do
		button:Unlock(true)
	end
end

function ButtonGroup:IncrementPressedButtonCount()
	self.pressedButtonCount = self.pressedButtonCount + 1
	assert(not (self.pressedButtonCount > self.buttonCount))
end

function ButtonGroup:DecrementPressedButtonCount()
	self.pressedButtonCount = self.pressedButtonCount - 1
	assert(not (self.pressedButtonCount < 0))
end
