local ADDON_NAME = "AwesomeGuildStore"

local callbackObject = ZO_CallbackObject:New()
local AGS = {
    class = {},
    data = {},
    callback = {},
    internal = {
        callbackObject = callbackObject,
        logger = LibDebugLogger(ADDON_NAME),
        chat = LibChatMessage(ADDON_NAME, "AGS"),
        gettext = LibGetText(ADDON_NAME).gettext
    }
}
_G[ADDON_NAME] = AGS

function AGS.internal:FireCallbacks(...)
    return callbackObject:FireCallbacks(...)
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

local function IsSameAction(actionName, layerIndex, categoryIndex, actionIndex)
    local targetTayerIndex, targetCategoryIndex, targetActionIndex = GetActionIndicesFromName(actionName)
    return not (layerIndex ~= targetTayerIndex or categoryIndex ~= targetCategoryIndex or actionIndex ~= targetActionIndex)
end

local integrityCheckList = {
    ["API.lua"] = function() return AGS.GetAPIVersion ~= nil end,
    ["CallbackNames.lua"] = function() return AGS.callback.BEFORE_INITIAL_SETUP ~= nil end,
    ["i18n/en.lua"] = function() return next(LibGetText(ADDON_NAME).dict) ~= nil end,
    ["Settings.lua"] = function() return AGS.internal.LoadSettings ~= nil end,
    ["util/misc.lua"] = function() return AGS.internal.IsUnitGuildKiosk ~= nil end,
    ["util/Codec.lua"] = function() return AGS.internal.EncodeValue ~= nil end,
    ["util/EditControlGroup.lua"] = function() return AGS.class.EditControlGroup ~= nil end,
    ["data/ItemRequirementLevelRanges.lua"] = function() return AGS.data.ITEM_REQUIREMENT_RANGE ~= nil end,
    ["util/ItemRequirementLevel.lua"] = function() return AGS.internal.GetNormalizedLevel ~= nil end,
    ["util/ItemLinkUtils.lua"] = function() return AGS.internal.IsItemLinkCraftedAllTypes ~= nil end,
    ["templates/MinMaxRangeSlider.xml"] = function() return AwesomeGuildStoreMinMaxRangeSliderTemplateLoaded ~= nil end,
    ["templates/MinMaxRangeSlider.lua"] = function() return AGS.class.MinMaxRangeSlider ~= nil end,
    ["templates/SimpleIconButton.lua"] = function() return AGS.class.SimpleIconButton ~= nil end,
    ["templates/SimpleInputBox.xml"] = function() return AwesomeGuildStoreSimpleInputBoxPulse ~= nil end,
    ["templates/SimpleInputBox.lua"] = function() return AGS.class.SimpleInputBox ~= nil end,
    ["util/ButtonGroup.lua"] = function() return AGS.class.ButtonGroup ~= nil end,
    ["util/ToggleButton.lua"] = function() return AGS.class.ToggleButton ~= nil end,
    ["util/LoadingOverlay.lua"] = function() return AGS.class.LoadingIcon ~= nil end,
    ["util/ItemPreviewHelper.lua"] = function() return AGS.class.ItemPreviewHelper ~= nil end,
    ["history/GuildHistoryHelper.lua"] = function() return AGS.class.GuildHistoryHelper ~= nil end,
    ["history/MailBox.lua"] = function() return AGS.internal.InitializeAugmentedMails ~= nil end,
    ["guildselector/HiredTraderTooltip.lua"] = function() return AGS.class.HiredTraderTooltip ~= nil end,
    ["guildselector/GuildSelector.lua"] = function() return AGS.class.GuildSelector ~= nil end,
    ["guildselector/GuildSelector.xml"] = function() return AwesomeGuildStoreGuildSelectorTemplateLoaded ~= nil end,
    ["backend/sort/SortOrderBase.lua"] = function() return AGS.class.SortOrderBase ~= nil end,
    ["data/CategoryDefinitions.lua"] = function() return AGS.data.CATEGORY_ID ~= nil end,
    ["backend/FilterRequest.lua"] = function() return AGS.class.FilterRequest ~= nil end,
    ["backend/activity/ActivityBase.lua"] = function() return AGS.class.ActivityBase ~= nil end,
    ["backend/activity/StoreStatusActivity.lua"] = function() return AGS.class.StoreStatusActivity ~= nil end,
    ["backend/activity/RequestSearchActivity.lua"] = function() return AGS.class.RequestSearchActivity ~= nil end,
    ["backend/activity/RequestNewestActivity.lua"] = function() return AGS.class.RequestNewestActivity ~= nil end,
    ["backend/activity/RequestListingsActivity.lua"] = function() return AGS.class.RequestListingsActivity ~= nil end,
    ["backend/activity/PostItemActivity.lua"] = function() return AGS.class.PostItemActivity ~= nil end,
    ["backend/activity/PurchaseItemActivity.lua"] = function() return AGS.class.PurchaseItemActivity ~= nil end,
    ["backend/activity/CancelItemActivity.lua"] = function() return AGS.class.CancelItemActivity ~= nil end,
    ["backend/activity/FetchGuildItemsActivity.lua"] = function() return AGS.class.FetchGuildItemsActivity ~= nil end,
    ["frontend/ActivityWindow.xml"] = function() return AwesomeGuildStoreActivityWindow ~= nil end,
    ["frontend/ActivityWindow.lua"] = function() return AGS.class.ActivityWindow ~= nil end,
    ["frontend/StatusLine.xml"] = function() return AwesomeGuildStoreActivityStatusLineTemplateLoaded ~= nil end,
    ["frontend/StatusLine.lua"] = function() return AGS.class.StatusLine ~= nil end,
    ["backend/activity/ActivityManager.lua"] = function() return AGS.class.ActivityManager ~= nil end,
    ["util/InteractionHelper.lua"] = function() return AGS.class.InteractionHelper ~= nil end,
    ["data/FilterIds.lua"] = function() return AGS.data.FILTER_ID ~= nil end,
    ["data/SortOrderIds.lua"] = function() return AGS.data.SORT_ORDER_ID ~= nil end,
    ["data/FurnitureCategoryFilterData.lua"] = function() return AGS.data.FURNITURE_CATEGORIES ~= nil end,
    ["data/ItemStyleFilterData.lua"] = function() return AGS.data.STYLE_CATEGORIES ~= nil end,
    ["data/ItemTraitFilterData.lua"] = function() return AGS.data.WEAPON_TRAIT_FILTER ~= nil end,
    ["data/ItemEnchantmentFilterData.lua"] = function() return AGS.data.WEAPON_ENCHANTMENT_FILTER ~= nil end,
    ["data/WeaponTypeFilterData.lua"] = function() return AGS.data.ONE_HANDED_WEAPON_TYPE_FILTER ~= nil end,
    ["data/EquipTypeFilterData.lua"] = function() return AGS.data.ARMOR_EQUIP_TYPE_FILTER ~= nil end,
    ["data/CraftingMaterialTypeFilterData.lua"] = function() return AGS.data.BLACKSMITHING_MATERIAL_TYPE_FILTER ~= nil end,
    ["data/ItemTypeFilterData.lua"] = function() return AGS.data.GLYPH_TYPE_FILTER ~= nil end,
    ["data/WritTypeFilterData.lua"] = function() return AGS.data.MASTER_WRIT_TYPE ~= nil end,
    ["backend/filter/FilterBase.lua"] = function() return AGS.class.FilterBase ~= nil end,
    ["backend/FilterState.lua"] = function() return AGS.class.FilterState ~= nil end,
    ["backend/ItemNameMatcher.lua"] = function() return AGS.class.ItemNameMatcher ~= nil end,
    ["backend/database/ItemData.lua"] = function() return AGS.class.ItemData ~= nil end,
    ["backend/database/view/BaseItemDatabaseView.lua"] = function() return AGS.class.BaseItemDatabaseView ~= nil end,
    ["backend/database/view/ItemDatabaseGuildView.lua"] = function() return AGS.class.ItemDatabaseGuildView ~= nil end,
    ["backend/database/view/ItemDatabaseFilterView.lua"] = function() return AGS.class.ItemDatabaseFilterView ~= nil end,
    ["backend/database/ItemDatabase.lua"] = function() return AGS.class.ItemDatabase ~= nil end,
    ["backend/sort/SortOrderTimeLeft.lua"] = function() return AGS.class.SortOrderTimeLeft ~= nil end,
    ["backend/sort/SortOrderPurchasePrice.lua"] = function() return AGS.class.SortOrderPurchasePrice ~= nil end,
    ["backend/sort/SortOrderUnitPrice.lua"] = function() return AGS.class.SortOrderUnitPrice ~= nil end,
    ["backend/sort/SortOrderItemName.lua"] = function() return AGS.class.SortOrderItemName ~= nil end,
    ["backend/sort/SortOrderSellerName.lua"] = function() return AGS.class.SortOrderSellerName ~= nil end,
    ["backend/sort/SortOrderSetName.lua"] = function() return AGS.class.SortOrderSetName ~= nil end,
    ["backend/sort/SortOrderItemQuality.lua"] = function() return AGS.class.SortOrderItemQuality ~= nil end,
    ["backend/filter/ValueRangeFilterBase.lua"] = function() return AGS.class.ValueRangeFilterBase ~= nil end,
    ["backend/filter/MultiChoiceFilterBase.lua"] = function() return AGS.class.MultiChoiceFilterBase ~= nil end,
    ["backend/filter/SortFilter.lua"] = function() return AGS.class.SortFilter ~= nil end,
    ["backend/filter/ItemCategoryFilter.lua"] = function() return AGS.class.ItemCategoryFilter ~= nil end,
    ["backend/filter/PriceFilter.lua"] = function() return AGS.class.PriceFilter ~= nil end,
    ["backend/filter/LevelFilter.lua"] = function() return AGS.class.LevelFilter ~= nil end,
    ["backend/filter/UnitPriceFilter.lua"] = function() return AGS.class.UnitPriceFilter ~= nil end,
    ["backend/filter/QualityFilter.lua"] = function() return AGS.class.QualityFilter ~= nil end,
    ["backend/filter/TextFilter.lua"] = function() return AGS.class.TextFilter ~= nil end,
    ["backend/filter/ItemStyleFilter.lua"] = function() return AGS.class.ItemStyleFilter ~= nil end,
    ["backend/filter/GenericTradingHouseFilter.lua"] = function() return AGS.class.GenericTradingHouseFilter ~= nil end,
    ["backend/filter/RecipeKnowledgeFilter.lua"] = function() return AGS.class.RecipeKnowledgeFilter ~= nil end,
    ["backend/filter/MotifKnowledgeFilter.lua"] = function() return AGS.class.MotifKnowledgeFilter ~= nil end,
    ["backend/filter/TraitKnowledgeFilter.lua"] = function() return AGS.class.TraitKnowledgeFilter ~= nil end,
    ["backend/filter/RuneKnowledgeFilter.lua"] = function() return AGS.class.RuneKnowledgeFilter ~= nil end,
    ["backend/filter/ItemSetFilter.lua"] = function() return AGS.class.ItemSetFilter ~= nil end,
    ["backend/filter/CraftedItemFilter.lua"] = function() return AGS.class.CraftedItemFilter ~= nil end,
    ["backend/filter/SkillRequirementsFilter.lua"] = function() return AGS.class.SkillRequirementsFilter ~= nil end,
    ["backend/filter/WritVoucherFilter.lua"] = function() return AGS.class.WritVoucherFilter ~= nil end,
    ["backend/filter/FurnitureCategoryFilter.lua"] = function() return AGS.class.FurnitureCategoryFilter ~= nil end,
    ["backend/filter/CollectibleOwnershipFilter.lua"] = function() return AGS.class.CollectibleOwnershipFilter ~= nil end,
    ["backend/SearchState.lua"] = function() return AGS.class.SearchState ~= nil end,
    ["backend/SearchPageHistory.lua"] = function() return AGS.class.SearchPageHistory ~= nil end,
    ["backend/SearchManager.lua"] = function() return AGS.class.SearchManager ~= nil end,
    ["backend/GuildSelection.lua"] = function() return AGS.class.GuildSelection ~= nil end,
    ["backend/GuildIdMapping.lua"] = function() return AGS.class.GuildIdMapping ~= nil end,
    ["frontend/SearchList.xml"] = function() return AwesomeGuildStoreSearchListContainer ~= nil end,
    ["frontend/SearchList.lua"] = function() return AGS.class.SearchList ~= nil end,
    ["frontend/SearchResultListWrapper.lua"] = function() return AGS.class.SearchResultListWrapper ~= nil end,
    ["frontend/CategorySelector.xml"] = function() return AwesomeGuildStoreCategorySelectorTemplateLoaded ~= nil end,
    ["frontend/CategorySelector.lua"] = function() return AGS.class.CategorySelector ~= nil end,
    ["frontend/FilterFragment.xml"] = function() return AwesomeGuildStoreFilterFragmentTemplateLoaded ~= nil end,
    ["frontend/FilterFragment.lua"] = function() return AGS.class.FilterFragment ~= nil end,
    ["frontend/FilterArea.lua"] = function() return AGS.class.FilterArea ~= nil end,
    ["frontend/filter/ValueRangeFilterFragmentBase.lua"] = function() return AGS.class.ValueRangeFilterFragmentBase ~= nil end,
    ["frontend/filter/PriceRangeFilterFragment.xml"] = function() return AwesomeGuildStorePriceInputTemplateLoaded ~= nil end,
    ["frontend/filter/PriceRangeFilterFragment.lua"] = function() return AGS.class.PriceRangeFilterFragment ~= nil end,
    ["frontend/filter/LevelRangeFilterFragment.xml"] = function() return AwesomeGuildStoreLevelInputTemplateLoaded ~= nil end,
    ["frontend/filter/LevelRangeFilterFragment.lua"] = function() return AGS.class.LevelRangeFilterFragment ~= nil end,
    ["frontend/filter/QualityFilterFragment.lua"] = function() return AGS.class.QualityFilterFragment ~= nil end,
    ["frontend/filter/TextFilterFragment.xml"] = function() return AwesomeGuildStoreTextSearchInputTemplateLoaded ~= nil end,
    ["frontend/filter/TextFilterFragment.lua"] = function() return AGS.class.TextFilterFragment ~= nil end,
    ["frontend/filter/MultiCategoryFilterFragment.xml"] = function() return AwesomeGuildStoreMultiCategoryFilterRowTemplateLoaded ~= nil end,
    ["frontend/filter/MultiCategoryFilterFragment.lua"] = function() return AGS.class.MultiCategoryFilterFragment ~= nil end,
    ["frontend/filter/MultiButtonFilterFragment.lua"] = function() return AGS.class.MultiButtonFilterFragment ~= nil end,
    ["frontend/filter/SortFilterFragment.lua"] = function() return AGS.class.SortFilterFragment ~= nil end,
    ["wrappers/TradingHouseWrapper.lua"] = function() return AGS.class.TradingHouseWrapper ~= nil end,
    ["wrappers/SearchTabWrapper.lua"] = function() return AGS.class.SearchTabWrapper ~= nil end,
    ["wrappers/SellTabWrapper.lua"] = function() return AGS.class.SellTabWrapper ~= nil end,
    ["wrappers/ListingTabWrapper.lua"] = function() return AGS.class.ListingTabWrapper ~= nil end,
    ["wrappers/KeybindStripWrapper.lua"] = function() return AGS.class.KeybindStripWrapper ~= nil end,
    ["guildstorelist/KioskData.lua"] = function() return AGS.class.KioskData ~= nil end,
    ["guildstorelist/StoreData.lua"] = function() return AGS.class.StoreData ~= nil end,
    ["guildstorelist/KioskList.lua"] = function() return AGS.class.KioskList ~= nil end,
    ["guildstorelist/StoreList.lua"] = function() return AGS.class.StoreList ~= nil end,
    ["guildstorelist/OwnerList.lua"] = function() return AGS.class.OwnerList ~= nil end,
    ["guildstorelist/StoreLocationHelper.lua"] = function() return AGS.class.StoreLocationHelper ~= nil end,
    ["guildstorelist/GuildStoreList.xml"] = function() return AGS.class.OwnerList ~= nil end,
    ["guildstorelist/GuildList.xml"] = function() return AwesomeGuildStoreGuildTraders ~= nil end,
    ["guildstorelist/TraderListControl.lua"] = function() return AGS.class.TraderListControl ~= nil end,
    ["guildstorelist/GuildListControl.lua"] = function() return AGS.class.GuildListControl ~= nil end,
    ["guildstorelist/OwnerHistoryControl.lua"] = function() return AGS.class.OwnerHistoryControl ~= nil end,
    ["guildstorelist/KioskHistoryControl.lua"] = function() return AGS.class.KioskHistoryControl ~= nil end,
    ["guildstorelist/GuildList.lua"] = function() return AGS.internal.InitializeGuildList ~= nil end,
    ["guildstorelist/GuildStoreList.lua"] = function() return AGS.internal.InitializeGuildStoreList ~= nil end,
    ["AwesomeGuildStore.xml"] = function() return AwesomeGuildStoreXmlLoaded ~= nil end,
-- "Bindings.xml", -- TODO: how to test?
}

local libraryCheckList = {
    ["LibAddonMenu-2.0 r31"] = function() return LibAddonMenu2 ~= nil end,
}

local function IntegrityCheck()
    local internal = AGS.internal
    local chat = internal.chat
    local logger = internal.logger
    local gettext = internal.gettext
    for fileName, check in pairs(integrityCheckList) do
        if(not check()) then
            logger:Warn("Detected missing file:", fileName)
            -- TRANSLATORS: Chat message when the addon was not installed correctly and some files are missing. Placeholder is for the filename.
            local message = gettext("The file '<<1>>' is missing. Please reinstall AwesomeGuildStore.", fileName)
            chat:Print(message)
            return false
        end
    end
    for libName, check in pairs(libraryCheckList) do
        if(not check()) then
            logger:Warn("Detected outdated library:", libName)
            -- TRANSLATORS: Chat message when a dependency does not fulfill the minimal version requirement. Placeholder is for the required library name and version.
            local message = gettext("Cannot start due to an outdated library. Please install <<1>> or newer.", libName)
            chat:Print(message)
            return false
        end
    end
    return true
end

OnAddonLoaded(function()
    if(not IntegrityCheck()) then return end

    local saveData = AGS.internal.LoadSettings()
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
