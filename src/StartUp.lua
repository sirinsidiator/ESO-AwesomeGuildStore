local ADDON_NAME = "AwesomeGuildStore"

AwesomeGuildStore = {}

local nextEventHandleIndex = 1

local function RegisterForEvent(event, callback)
	local eventHandleName = ADDON_NAME .. nextEventHandleIndex
	EVENT_MANAGER:RegisterForEvent(eventHandleName, event, callback)
	nextEventHandleIndex = nextEventHandleIndex + 1
	return eventHandleName
end

local function UnregisterForEvent(event, name)
	EVENT_MANAGER:UnregisterForEvent(name, event)
end

local function WrapFunction(object, functionName, wrapper)
	if(type(object) == "string") then
		wrapper = functionName
		functionName = object
		object = _G
	end
	local originalFunction = object[functionName]
	object[functionName] = function(...) return wrapper(originalFunction, ...) end
end

local function OnAddonLoaded(callback)
	local eventHandle = ""
	eventHandle = RegisterForEvent(EVENT_ADD_ON_LOADED, function(event, name)
		if(name ~= ADDON_NAME) then return end
		callback()
		UnregisterForEvent(event, name)
	end)
end

AwesomeGuildStore.RegisterForEvent = RegisterForEvent
AwesomeGuildStore.WrapFunction = WrapFunction
-----------------------------------------------------------------------------------------

AwesomeGuildStore.GetAPIVersion = function() return 2 end
AwesomeGuildStore.BeforeInitialSetupCallbackName = ADDON_NAME .. "_BeforeInitialSetup"
AwesomeGuildStore.AfterInitialSetupCallbackName = ADDON_NAME .. "_AfterInitialSetup"
AwesomeGuildStore.OnOpenSearchTabCallbackName = ADDON_NAME .. "_OnOpenSearchTab"
AwesomeGuildStore.OnCloseSearchTabCallbackName = ADDON_NAME .. "_OnCloseSearchTab"
OnAddonLoaded(function()
	local saveData = AwesomeGuildStore.LoadSettings()
	local tradingHouseWrapper = AwesomeGuildStore.TradingHouseWrapper:New(saveData)
	AwesomeGuildStore.InitializeAugmentedMails(saveData)
end)
