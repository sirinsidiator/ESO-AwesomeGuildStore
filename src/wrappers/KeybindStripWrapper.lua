local KeybindStripWrapper = ZO_Object:Subclass()
AwesomeGuildStore.KeybindStripWrapper = KeybindStripWrapper

function KeybindStripWrapper:New(...)
	local wrapper = ZO_Object.New(self)
	wrapper:Initialize(...)
	return wrapper
end

function KeybindStripWrapper:Initialize(tradingHouse, activityManager)
	local keybindStripDescriptor = tradingHouse.keybindStripDescriptor

	local secondaryDescriptor = keybindStripDescriptor[1]
	assert(secondaryDescriptor.keybind == "UI_SHORTCUT_SECONDARY")
	local originalEnabled = secondaryDescriptor.enabled
	secondaryDescriptor.enabled = function()
		if(tradingHouse:IsInSearchMode()) then
			return not self.isSearchDisabled
		else
			return originalEnabled()
		end
	end

	secondaryDescriptor.callback = function()
		if(tradingHouse:IsInSearchMode()) then
			activityManager:ExecuteSearch()
		elseif(tradingHouse:CanPostWithMoneyCheck()) then
			tradingHouse:PostPendingItem()
		end
	end

	local tertiaryDescriptor = keybindStripDescriptor[2]
	assert(tertiaryDescriptor.keybind == "UI_SHORTCUT_TERTIARY")
	tertiaryDescriptor.enabled = function()
		return not self.isSearchDisabled
	end

	self.keybindStripDescriptor = keybindStripDescriptor
	self.keybindStrip = KEYBIND_STRIP
end

function KeybindStripWrapper:DisableSearch()
	self.isSearchDisabled = true
	self:UpdateKeybindStrip()
end

function KeybindStripWrapper:EnableSearch()
	self.isSearchDisabled = false
	self:UpdateKeybindStrip()
end

function KeybindStripWrapper:UpdateKeybindStrip()
	self.keybindStrip:UpdateKeybindButtonGroup(self.keybindButtonDescriptor)
end
