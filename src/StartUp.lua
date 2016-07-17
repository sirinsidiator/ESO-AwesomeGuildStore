local ADDON_NAME = "AwesomeGuildStore"

AwesomeGuildStore = ZO_CallbackObject:New()

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

AwesomeGuildStore.UnregisterForEvent = UnregisterForEvent
AwesomeGuildStore.RegisterForEvent = RegisterForEvent
AwesomeGuildStore.WrapFunction = WrapFunction
-----------------------------------------------------------------------------------------

AwesomeGuildStore.GetAPIVersion = function() return 2 end

-- convenience functions for using the callback object:
function AwesomeGuildStore:RegisterBeforeInitialSetupCallback(...)
    self:RegisterCallback("BeforeInitialSetup", ...)
end
function AwesomeGuildStore:FireBeforeInitialSetupCallbacks(...)
    self:FireCallbacks("BeforeInitialSetup", ...)
end

function AwesomeGuildStore:RegisterAfterInitialSetupCallback(...)
    self:RegisterCallback("AfterInitialSetup", ...)
end
function AwesomeGuildStore:FireAfterInitialSetupCallbacks(...)
    self:FireCallbacks("AfterInitialSetup", ...)
end

function AwesomeGuildStore:RegisterOnOpenSearchTabCallback(...)
    self:RegisterCallback("OnOpenSearchTab", ...)
end
function AwesomeGuildStore:FireOnOpenSearchTabCallbacks(...)
    self:FireCallbacks("OnOpenSearchTab", ...)
end

function AwesomeGuildStore:RegisterOnCloseSearchTabCallback(...)
    self:RegisterCallback("OnCloseSearchTab", ...)
end
function AwesomeGuildStore:FireOnCloseSearchTabCallbacks(...)
    self:FireCallbacks("OnCloseSearchTab", ...)
end

function AwesomeGuildStore:RegisterOnInitializeFiltersCallback(...)
    self:RegisterCallback("OnInitializeFilters", ...)
end
function AwesomeGuildStore:FireOnInitializeFiltersCallbacks(...)
    self:FireCallbacks("OnInitializeFilters", ...)
end

-- deprecated callback names for CALLBACK_MANAGER:
AwesomeGuildStore.BeforeInitialSetupCallbackName = ADDON_NAME .. "_BeforeInitialSetup"
AwesomeGuildStore.AfterInitialSetupCallbackName = ADDON_NAME .. "_AfterInitialSetup"
AwesomeGuildStore.OnOpenSearchTabCallbackName = ADDON_NAME .. "_OnOpenSearchTab"
AwesomeGuildStore.OnCloseSearchTabCallbackName = ADDON_NAME .. "_OnCloseSearchTab"
AwesomeGuildStore.OnInitializeFiltersCallbackName = ADDON_NAME .. "_OnInitializeFilters"

-- compatibility layer for old callback handling:
AwesomeGuildStore:RegisterBeforeInitialSetupCallback(function(...) CALLBACK_MANAGER:FireCallbacks(AwesomeGuildStore.BeforeInitialSetupCallbackName, ...) end)
AwesomeGuildStore:RegisterAfterInitialSetupCallback(function(...) CALLBACK_MANAGER:FireCallbacks(AwesomeGuildStore.AfterInitialSetupCallbackName, ...) end)
AwesomeGuildStore:RegisterOnOpenSearchTabCallback(function(...) CALLBACK_MANAGER:FireCallbacks(AwesomeGuildStore.OnOpenSearchTabCallbackName, ...) end)
AwesomeGuildStore:RegisterOnCloseSearchTabCallback(function(...) CALLBACK_MANAGER:FireCallbacks(AwesomeGuildStore.OnCloseSearchTabCallbackName, ...) end)
AwesomeGuildStore:RegisterOnInitializeFiltersCallback(function(...) CALLBACK_MANAGER:FireCallbacks(AwesomeGuildStore.OnInitializeFiltersCallbackName, ...) end)

local function IsSameAction(actionName, layerIndex, categoryIndex, actionIndex)
    local targetTayerIndex, targetCategoryIndex, targetActionIndex = GetActionIndicesFromName(actionName)
    return not (layerIndex ~= targetTayerIndex or categoryIndex ~= targetCategoryIndex or actionIndex ~= targetActionIndex)
end

OnAddonLoaded(function()
    local saveData = AwesomeGuildStore.LoadSettings()
    AwesomeGuildStore.main = AwesomeGuildStore.TradingHouseWrapper:New(saveData)
    AwesomeGuildStore.InitializeAugmentedMails(saveData)

    local L = AwesomeGuildStore.Localization

    local actionName, defaultKey = "AGS_SUPPRESS_LOCAL_FILTERS", KEY_CTRL
    ZO_CreateStringId("SI_BINDING_NAME_AGS_SUPPRESS_LOCAL_FILTERS", L["CONTROLS_SUPPRESS_LOCAL_FILTERS"])

    local function HandleKeyBindReset()
        saveData.hasUnboundAction = {}
    end

    ZO_PreHook("ResetAllBindsToDefault", HandleKeyBindReset)
    ZO_PreHook("ResetKeyboardBindsToDefault", HandleKeyBindReset)

    local function HandleKeyBindTouched(_, layerIndex, categoryIndex, actionIndex, bindingIndex)
        if(IsSameAction(actionName, layerIndex, categoryIndex, actionIndex) and bindingIndex == 1) then
            saveData.hasUnboundAction[actionName] = false
        end
    end

    RegisterForEvent(EVENT_KEYBINDING_CLEARED, HandleKeyBindTouched)
    RegisterForEvent(EVENT_KEYBINDING_SET, HandleKeyBindTouched)

    if(saveData.hasUnboundAction["AGS_SUPPRESS_LOCAL_FILTERS"] ~= false) then
        CreateDefaultActionBind(actionName, defaultKey)
    end
end)
