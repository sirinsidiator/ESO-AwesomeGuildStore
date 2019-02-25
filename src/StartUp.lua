local ADDON_NAME = "AwesomeGuildStore"

local callbackObject = ZO_CallbackObject:New()
local AGS = {
    class = {},
    data = {},
    callback = {},
    internal = {
        callbackObject = callbackObject,
        logger = LibDebugLogger.Create(ADDON_NAME),
        gettext = LibStub("LibGetText")(ADDON_NAME).gettext
    }
}
_G[ADDON_NAME] = AGS

function AGS.internal:FireCallbacks(...)
    return callbackObject:FireCallbacks(...)
end

function AGS:RegisterCallback(...)
    return callbackObject:RegisterCallback(...)
end

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

AGS.internal.UnregisterForEvent = UnregisterForEvent
AGS.internal.RegisterForEvent = RegisterForEvent
AGS.internal.WrapFunction = WrapFunction
-----------------------------------------------------------------------------------------

AGS.GetAPIVersion = function() return 4 end

do
    local LONG_PREFIX = "AwesomeGuildStore"
    local SHORT_PREFIX = "AGS"

    local prefix = LONG_PREFIX
    local function SetMessagePrefix(isShort)
        prefix = isShort and SHORT_PREFIX or LONG_PREFIX
    end

    local function Print(message, ...)
        if(select("#", ...) > 0) then
            message = message:format(...)
        end
        df("[%s] %s", prefix, message)
    end

    AGS.internal.Print = Print
    AGS.internal.SetMessagePrefix = SetMessagePrefix
end

local function IsSameAction(actionName, layerIndex, categoryIndex, actionIndex)
    local targetTayerIndex, targetCategoryIndex, targetActionIndex = GetActionIndicesFromName(actionName)
    return not (layerIndex ~= targetTayerIndex or categoryIndex ~= targetCategoryIndex or actionIndex ~= targetActionIndex)
end

local function IntegrityCheck()
    assert(LibStub)
    assert(LibStub("LibAddonMenu-2.0", true))
    assert(LAMCreateControl.panel)
    assert(LAMCreateControl.submenu)
    assert(LAMCreateControl.button)
    assert(LAMCreateControl.checkbox)
    assert(LAMCreateControl.colorpicker)
    assert(LAMCreateControl.custom)
    assert(LAMCreateControl.description)
    assert(LAMCreateControl.dropdown)
    assert(LAMCreateControl.editbox)
    assert(LAMCreateControl.header)
    assert(LAMCreateControl.slider)
    assert(LAMCreateControl.iconpicker)
    assert(LAMCreateControl.divider)
    assert(LibStub("LibTextFilter", true))
    assert(LibStub("LibCustomMenu", true))
    assert(LibStub("LibMapPing", true))
    assert(LibStub("LibGPS2", true))
    assert(LibStub("LibPromises", true))
    assert(LibStub("LibGetText", true))
    assert(AGS.internal.LoadSettings)
    assert(AGS.internal.IsUnitGuildKiosk)
    assert(AGS.class.MinMaxRangeSlider)
    assert(AGS.class.ButtonGroup)
    assert(AGS.class.ToggleButton)
    assert(AGS.class.SimpleIconButton)
    assert(AGS.class.LoadingIcon)
    assert(AGS.internal.InitializeAugmentedMails)
    assert(AGS.class.HiredTraderTooltip)
    assert(AGS.class.GuildSelector)
    assert(AGS.class.ActivityBase)
    assert(AGS.class.RequestSearchActivity)
    assert(AGS.class.RequestNewestActivity)
    assert(AGS.class.RequestListingsActivity)
    assert(AGS.class.PurchaseItemActivity)
    assert(AGS.class.PostItemActivity)
    assert(AGS.class.CancelItemActivity)
    assert(AGS.class.ActivityManager)
    assert(AGS.class.TradingHouseWrapper)
    assert(AGS.class.SearchTabWrapper)
    assert(AGS.class.SellTabWrapper)
    assert(AGS.class.ListingTabWrapper)
    assert(AGS.class.KeybindStripWrapper)
    assert(AGS.class.ActivityLogWrapper)
    assert(AGS.class.KioskData)
    assert(AGS.class.StoreData)
    assert(AGS.class.KioskList)
    assert(AGS.class.StoreList)
    assert(AGS.class.OwnerList)
    assert(AwesomeGuildStoreGuildTraders)
    assert(AwesomeGuildStoreGuilds)
    assert(AGS.class.TraderListControl)
    assert(AGS.class.GuildListControl)
    assert(AGS.class.OwnerHistoryControl)
    assert(AGS.class.KioskHistoryControl)
    assert(AGS.internal.InitializeGuildList)
    assert(AGS.internal.InitializeGuildStoreList)
    assert(AGS.class.SalesCategorySelector)
end

OnAddonLoaded(function()
    IntegrityCheck()

    local saveData = AGS.internal.LoadSettings()
    AGS.internal.SetMessagePrefix(saveData.shortMessagePrefix)
    if(saveData.guildTraderListEnabled) then
        AGS.internal.InitializeGuildStoreList(saveData)
    end
    AGS.internal.tradingHouse = AGS.class.TradingHouseWrapper:New(saveData)
    AGS.internal.InitializeAugmentedMails(saveData)

    local gettext = AGS.internal.gettext

    local actionName, defaultKey = "AGS_SUPPRESS_LOCAL_FILTERS", KEY_CTRL
    -- TRANSLATORS: keybind label in the controls menu
    ZO_CreateStringId("SI_BINDING_NAME_AGS_SUPPRESS_LOCAL_FILTERS", gettext("Suppress Local Filters"))

    local function HandleKeyBindReset()
        saveData.hasTouchedAction = {}
    end

    ZO_PreHook("ResetAllBindsToDefault", HandleKeyBindReset)
    ZO_PreHook("ResetKeyboardBindsToDefault", HandleKeyBindReset)

    local function HandleKeyBindTouched(_, layerIndex, categoryIndex, actionIndex, bindingIndex)
        if(IsSameAction(actionName, layerIndex, categoryIndex, actionIndex) and bindingIndex == 1) then
            saveData.hasTouchedAction[actionName] = true
        end
    end

    RegisterForEvent(EVENT_KEYBINDING_CLEARED, HandleKeyBindTouched)
    RegisterForEvent(EVENT_KEYBINDING_SET, HandleKeyBindTouched)

    if(not saveData.hasTouchedAction["AGS_SUPPRESS_LOCAL_FILTERS"]) then
        CreateDefaultActionBind(actionName, defaultKey)
    end
    end)
end
