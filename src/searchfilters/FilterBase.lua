local SimpleIconButton = AwesomeGuildStore.SimpleIconButton

local FilterBase = ZO_Object:Subclass()
AwesomeGuildStore.FilterBase = FilterBase

local RESET_BUTTON_SIZE = 18
local RESET_BUTTON_TEXTURE = "EsoUI/Art/Buttons/decline_%s.dds"

function FilterBase:New(type, name, tradingHouseWrapper, ...)
	local filter = ZO_Object.New(self)
	filter:InitializeBase(type, name)
	filter:Initialize(name, tradingHouseWrapper, ...)
	return filter
end

function FilterBase:InitializeBase(type, name)
	self.type = type
	self.callbackName = name .. "Changed"

	local container = WINDOW_MANAGER:CreateControl(name .. "Container", GuiRoot, CT_CONTROL)
	self.container = container

	local resetButton = SimpleIconButton:New(name .. "ResetButton", RESET_BUTTON_TEXTURE, RESET_BUTTON_SIZE)
	resetButton:SetAnchor(TOPRIGHT, container, TOPRIGHT, 0, 0)
	resetButton:SetHidden(true)
	resetButton.OnClick = function(control, mouseButton, ctrl, alt, shift)
		if(mouseButton == 1) then
			self:Reset()
		end
	end
	self.resetButton = resetButton
end

-- the following functions are placeholders and can be overwritten
function FilterBase:Initialize(name, tradingHouseWrapper)
end

function FilterBase:HandleChange()
	if(not self.fireChangeCallback) then
		self.fireChangeCallback = zo_callLater(function()
			self.fireChangeCallback = nil
			CALLBACK_MANAGER:FireCallbacks(self.callbackName, self)
		end, 100)
	end
	self.resetButton:SetHidden(self:IsDefault())
end

-- these functions are used by the search tab wrapper
function FilterBase:SetParent(parent)
	self.container:SetParent(parent)
end

function FilterBase:SetWidth(width)
	self.container:SetWidth(width)
end

function FilterBase:SetHidden(hidden)
	self.container:SetHidden(hidden)
end

-- these functions are used by the reset button
function FilterBase:Reset()
end

function FilterBase:IsDefault()
end

-- these functions are used by the search history
function FilterBase:Serialize()
	return ""
end

function FilterBase:Deserialize(state)
end

function FilterBase:GetTooltipText(state)
	return {}
end
