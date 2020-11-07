local AGS = AwesomeGuildStore

local gettext = AGS.internal.gettext
local SUB_CATEGORY_ID = AGS.data.SUB_CATEGORY_ID
local FILTER_ID = AGS.data.FILTER_ID

local MASTER_WRIT_TYPE = {
    BLACKSMITHING = 1,
    CLOTHIER = 2,
    WOODWORKING = 3,
    ALCHEMY = 4,
    ENCHANTING = 5,
    PROVISIONING = 6,
    JEWELRY = 7,
    OTHER = 8,
}

local MASTER_WRIT_TYPE_BY_ICON = {
    ["/esoui/art/icons/master_writ_blacksmithing.dds"] = MASTER_WRIT_TYPE.BLACKSMITHING,
    ["/esoui/art/icons/master_writ_clothier.dds"] = MASTER_WRIT_TYPE.CLOTHIER,
    ["/esoui/art/icons/master_writ_woodworking.dds"] = MASTER_WRIT_TYPE.WOODWORKING,
    ["/esoui/art/icons/master_writ_alchemy.dds"] = MASTER_WRIT_TYPE.ALCHEMY,
    ["/esoui/art/icons/master_writ_enchanting.dds"] = MASTER_WRIT_TYPE.ENCHANTING,
    ["/esoui/art/icons/master_writ_provisioning.dds"] = MASTER_WRIT_TYPE.PROVISIONING,
    ["/esoui/art/icons/master_writ_jewelry.dds"] = MASTER_WRIT_TYPE.JEWELRY,
    ["/esoui/art/icons/master_writ-newlife.dds"] = MASTER_WRIT_TYPE.OTHER,
}

local function UnpackWritType(filter, itemData) -- TODO: collect all unpack functions in utils
    return MASTER_WRIT_TYPE_BY_ICON[itemData.icon] or MASTER_WRIT_TYPE.OTHER
end

local MASTER_WRIT_TYPE_FILTER = {
    id = FILTER_ID.MASTER_WRIT_TYPE_FILTER,
    unpack = UnpackWritType,
    -- TRANSLATORS: title of the master writ type filter in the left panel on the search tab
    label = gettext("Writ Type"),
    enabled = {
        [SUB_CATEGORY_ID.CONSUMABLE_WRIT] = true,
    },
    values = {
        {
            id = MASTER_WRIT_TYPE.BLACKSMITHING,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, ZO_GetCraftingSkillName(CRAFTING_TYPE_BLACKSMITHING)),
            icon = "EsoUI/Art/Inventory/inventory_tabIcon_craftbag_blacksmithing_%s.dds",
        },
        {
            id = MASTER_WRIT_TYPE.CLOTHIER,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, ZO_GetCraftingSkillName(CRAFTING_TYPE_CLOTHIER)),
            icon = "EsoUI/Art/Inventory/inventory_tabIcon_craftbag_clothing_%s.dds",
        },
        {
            id = MASTER_WRIT_TYPE.WOODWORKING,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, ZO_GetCraftingSkillName(CRAFTING_TYPE_WOODWORKING)),
            icon = "EsoUI/Art/Inventory/inventory_tabIcon_craftbag_woodworking_%s.dds",
        },
        {
            id = MASTER_WRIT_TYPE.ALCHEMY,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, ZO_GetCraftingSkillName(CRAFTING_TYPE_ALCHEMY)),
            icon = "EsoUI/Art/Inventory/inventory_tabIcon_craftbag_alchemy_%s.dds",
        },
        {
            id = MASTER_WRIT_TYPE.ENCHANTING,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, ZO_GetCraftingSkillName(CRAFTING_TYPE_ENCHANTING)),
            icon = "EsoUI/Art/Inventory/inventory_tabIcon_craftbag_enchanting_%s.dds",
        },
        {
            id = MASTER_WRIT_TYPE.PROVISIONING,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, ZO_GetCraftingSkillName(CRAFTING_TYPE_PROVISIONING)),
            icon = "EsoUI/Art/Inventory/inventory_tabIcon_craftbag_provisioning_%s.dds",
        },
        {
            id = MASTER_WRIT_TYPE.JEWELRY,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, ZO_GetCraftingSkillName(CRAFTING_TYPE_JEWELRYCRAFTING)),
            icon = "EsoUI/Art/Inventory/inventory_tabIcon_craftbag_jewelrycrafting_%s.dds",
        },
        {
            id = MASTER_WRIT_TYPE.OTHER,
            label = GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_HOLIDAY_WRIT),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Holiday_Writ_%s.dds",
        },
    }
}

AGS.data.MASTER_WRIT_TYPE = MASTER_WRIT_TYPE
AGS.data.MASTER_WRIT_TYPE_FILTER = MASTER_WRIT_TYPE_FILTER
