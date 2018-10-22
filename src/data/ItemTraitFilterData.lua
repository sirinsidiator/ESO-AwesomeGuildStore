local gettext = LibStub("LibGetText")("AwesomeGuildStore").gettext
local SUB_CATEGORY_ID = AwesomeGuildStore.data.SUB_CATEGORY_ID
local FILTER_ID = AwesomeGuildStore.data.FILTER_ID

local function UnpackTrait(filter, itemData) -- TODO: collect all unpack functions in utils
    local id = GetItemLinkTraitInfo(itemData.itemLink)
    return id
end

local WEAPON_TRAIT_FILTER = {
    id = FILTER_ID.WEAPON_TRAIT_FILTER,
    type = TRADING_HOUSE_FILTER_TYPE_TRAIT,
    unpack = UnpackTrait,
    label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_WEAPON_TRAIT)),
    enabled = {
        [SUB_CATEGORY_ID.WEAPONS_ALL] = true,
        [SUB_CATEGORY_ID.WEAPONS_ONE_HANDED] = true,
        [SUB_CATEGORY_ID.WEAPONS_TWO_HANDED] = true,
        [SUB_CATEGORY_ID.WEAPONS_BOW] = true,
        [SUB_CATEGORY_ID.WEAPONS_DESTRUCTION_STAFF] = true,
        [SUB_CATEGORY_ID.WEAPONS_RESTORATION_STAFF] = true,
    },
    values = {
        {
            id = ITEM_TRAIT_TYPE_WEAPON_POWERED,
            label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_WEAPON_POWERED),
            icon = "EsoUI/Art/Crafting/smithing_tabIcon_weaponset_%s.dds",
        },
        {
            id = ITEM_TRAIT_TYPE_WEAPON_CHARGED,
            label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_WEAPON_CHARGED),
            icon = "EsoUI/Art/Campaign/overview_indexIcon_bonus_%s.dds",
        },
        {
            id = ITEM_TRAIT_TYPE_WEAPON_PRECISE,
            label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_WEAPON_PRECISE),
            icon = "EsoUI/Art/Campaign/overview_indexIcon_scoring_%s.dds",
        },
        {
            id = ITEM_TRAIT_TYPE_WEAPON_INFUSED,
            label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_WEAPON_INFUSED),
            icon = "EsoUI/Art/Progression/progression_tabIcon_combatskills_%s.dds",
        },
        {
            id = ITEM_TRAIT_TYPE_WEAPON_DEFENDING,
            label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_WEAPON_DEFENDING),
            icon = "EsoUI/Art/Guild/tabIcon_heraldry_%s.dds",
        },
        {
            id = ITEM_TRAIT_TYPE_WEAPON_TRAINING,
            label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_WEAPON_TRAINING),
            icon = "EsoUI/Art/Guild/tabIcon_ranks_%s.dds",
        },
        {
            id = ITEM_TRAIT_TYPE_WEAPON_SHARPENED,
            label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_WEAPON_SHARPENED),
            icon = "EsoUI/Art/Campaign/campaignBrowser_indexIcon_normal_%s.dds",
        },
        {
            id = ITEM_TRAIT_TYPE_WEAPON_DECISIVE,
            label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_WEAPON_DECISIVE),
            icon = "EsoUI/Art/Inventory/inventory_tabicon_misc_%s.dds",
        },
        {
            id = ITEM_TRAIT_TYPE_WEAPON_ORNATE,
            label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_WEAPON_ORNATE),
            icon = "EsoUI/Art/Tradinghouse/tradinghouse_sell_tabIcon_%s.dds",
        },
        {
            id = ITEM_TRAIT_TYPE_WEAPON_INTRICATE,
            label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_WEAPON_INTRICATE),
            icon = "EsoUI/Art/Progression/progression_indexIcon_guilds_%s.dds",
        },
        {
            id = ITEM_TRAIT_TYPE_WEAPON_NIRNHONED,
            label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_WEAPON_NIRNHONED),
            icon = "EsoUI/Art/WorldMap/map_ava_tabIcon_resourceProduction_%s.dds",
        },
    }
}

local ARMOR_TRAIT_FILTER = {
    id = FILTER_ID.ARMOR_TRAIT_FILTER,
    type = TRADING_HOUSE_FILTER_TYPE_TRAIT,
    unpack = UnpackTrait,
    label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_ARMOR_TRAIT)),
    enabled = {
        [SUB_CATEGORY_ID.ARMOR_ALL] = true,
        [SUB_CATEGORY_ID.ARMOR_HEAVY] = true,
        [SUB_CATEGORY_ID.ARMOR_MEDIUM] = true,
        [SUB_CATEGORY_ID.ARMOR_LIGHT] = true,
        [SUB_CATEGORY_ID.ARMOR_SHIELD] = true,
    },
    values = {
        {
            id = ITEM_TRAIT_TYPE_ARMOR_STURDY,
            label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_STURDY),
            icon = "EsoUI/Art/Campaign/campaignBrowser_indexIcon_hardcore_%s.dds",
        },
        {
            id = ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE,
            label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE),
            icon = "EsoUI/Art/Guild/tabIcon_heraldry_%s.dds",
        },
        {
            id = ITEM_TRAIT_TYPE_ARMOR_REINFORCED,
            label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_REINFORCED),
            icon = "EsoUI/Art/Crafting/smithing_tabIcon_armorset_%s.dds",
        },
        {
            id = ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED,
            label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED),
            icon = "EsoUI/Art/Campaign/campaign_tabIcon_summary_%s.dds",
        },
        {
            id = ITEM_TRAIT_TYPE_ARMOR_TRAINING,
            label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_TRAINING),
            icon = "EsoUI/Art/Guild/tabIcon_ranks_%s.dds",
        },
        {
            id = ITEM_TRAIT_TYPE_ARMOR_INFUSED,
            label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_INFUSED),
            icon = "EsoUI/Art/Progression/progression_tabIcon_combatSkills_%s.dds",
        },
        {
            id = ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS,
            label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS),
            icon = "EsoUI/Art/Progression/progression_indexIcon_world_%s.dds",
        },
        {
            id = ITEM_TRAIT_TYPE_ARMOR_DIVINES,
            label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_DIVINES),
            icon = "EsoUI/Art/Progression/progression_indexIcon_race_%s.dds",
        },
        {
            id = ITEM_TRAIT_TYPE_ARMOR_ORNATE,
            label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_ORNATE),
            icon = "EsoUI/Art/Tradinghouse/tradinghouse_sell_tabIcon_%s.dds",
        },
        {
            id = ITEM_TRAIT_TYPE_ARMOR_INTRICATE,
            label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_INTRICATE),
            icon = "EsoUI/Art/Progression/progression_indexIcon_guilds_%s.dds",
        },
        {
            id = ITEM_TRAIT_TYPE_ARMOR_NIRNHONED,
            label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_NIRNHONED),
            icon = "EsoUI/Art/WorldMap/map_ava_tabIcon_resourceProduction_%s.dds",
        },
    }
}

local JEWELRY_TRAIT_FILTER = {
    id = FILTER_ID.JEWELRY_TRAIT_FILTER,
    type = TRADING_HOUSE_FILTER_TYPE_TRAIT,
    unpack = UnpackTrait,
    -- TRANSLATORS: title of the jewelry trait filter in the left panel on the search tab
    label = gettext("Jewelry Trait"),
    enabled = {
        [SUB_CATEGORY_ID.JEWELRY_ALL] = true,
        [SUB_CATEGORY_ID.JEWELRY_RING] = true,
        [SUB_CATEGORY_ID.JEWELRY_NECK] = true,
    },
    values = {
        {
            id = ITEM_TRAIT_TYPE_JEWELRY_HEALTHY,
            label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_JEWELRY_HEALTHY),
            icon = "EsoUI/Art/Crafting/provisioner_indexIcon_beer_%s.dds",
        },
        {
            id = ITEM_TRAIT_TYPE_JEWELRY_ARCANE,
            label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_JEWELRY_ARCANE),
            icon = "EsoUI/Art/Campaign/campaignBrowser_indexIcon_specialEvents_%s.dds",
        },
        {
            id = ITEM_TRAIT_TYPE_JEWELRY_ROBUST,
            label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_JEWELRY_ROBUST),
            icon = "EsoUI/Art/Repair/inventory_tabIcon_repair_%s.dds",
        },
        {
            id = ITEM_TRAIT_TYPE_JEWELRY_ORNATE,
            label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_JEWELRY_ORNATE),
            icon = "EsoUI/Art/Tradinghouse/tradinghouse_sell_tabIcon_%s.dds",
        },
        {
            id = ITEM_TRAIT_TYPE_JEWELRY_INTRICATE,
            label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_JEWELRY_INTRICATE),
            icon = "EsoUI/Art/Progression/progression_indexIcon_guilds_%s.dds",
        },
        {
            id = ITEM_TRAIT_TYPE_JEWELRY_SWIFT,
            label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_JEWELRY_SWIFT),
            icon = "EsoUI/Art/Emotes/emotes_indexIcon_physical_%s.dds",
        },
        {
            id = ITEM_TRAIT_TYPE_JEWELRY_HARMONY,
            label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_JEWELRY_HARMONY),
            icon = "EsoUI/Art/Emotes/emotes_indexIcon_perpetual_%s.dds",
        },
        {
            id = ITEM_TRAIT_TYPE_JEWELRY_TRIUNE,
            label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_JEWELRY_TRIUNE),
            icon = "EsoUI/Art/Crafting/smithing_tabIcon_research_%s.dds",
        },
        {
            id = ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY,
            label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY),
            icon = "EsoUI/Art/TreeIcons/achievements_indexIcon_justice_%s.dds",
        },
        {
            id = ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE,
            label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE),
            icon = "EsoUI/Art/Crafting/smithing_tabIcon_armorset_%s.dds",
        },
        {
            id = ITEM_TRAIT_TYPE_JEWELRY_INFUSED,
            label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_JEWELRY_INFUSED),
            icon = "EsoUI/Art/Progression/progression_tabIcon_combatSkills_%s.dds",
        },
    }
}

AwesomeGuildStore.data.WEAPON_TRAIT_FILTER = WEAPON_TRAIT_FILTER
AwesomeGuildStore.data.ARMOR_TRAIT_FILTER = ARMOR_TRAIT_FILTER
AwesomeGuildStore.data.JEWELRY_TRAIT_FILTER = JEWELRY_TRAIT_FILTER
