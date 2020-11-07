local AGS = AwesomeGuildStore

local gettext = AGS.internal.gettext
local SUB_CATEGORY_ID = AGS.data.SUB_CATEGORY_ID
local FILTER_ID = AGS.data.FILTER_ID

local function UnpackEnchantSearchCategory(filter, itemData)
    local enchantId = GetItemLinkFinalEnchantId(itemData.itemLink)
    local searchCategory = GetEnchantSearchCategoryType(enchantId)
    if searchCategory == ENCHANTMENT_SEARCH_CATEGORY_NONE then
        return nil
    end
    return searchCategory
end

local WEAPON_ENCHANTMENT_FILTER = {
    id = FILTER_ID.WEAPON_ENCHANTMENT_FILTER,
    type = TRADING_HOUSE_FILTER_TYPE_ENCHANTMENT,
    unpack = UnpackEnchantSearchCategory,
    -- TRANSLATORS: title text for the weapon enchantment filter in the left panel on the search tab
    label = gettext("Weapon Enchantment"),
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
            id = ENCHANTMENT_SEARCH_CATEGORY_FIERY_WEAPON, -- deals x flame damage
            label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_FIERY_WEAPON),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Weapons_Staff_Flame_%s.dds",
        },
        {
            id = ENCHANTMENT_SEARCH_CATEGORY_FROZEN_WEAPON, -- deals x cold damage
            label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_FROZEN_WEAPON),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Weapons_Staff_Frost_%s.dds",
        },
        {
            id = ENCHANTMENT_SEARCH_CATEGORY_CHARGED_WEAPON, -- deals x shock damage
            label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_CHARGED_WEAPON),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Weapons_Staff_Lightning_%s.dds",
        },
        {
            id = ENCHANTMENT_SEARCH_CATEGORY_POISONED_WEAPON, -- deals x poison damage
            label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_POISONED_WEAPON),
            icon = "EsoUI/Art/Campaign/overview_indexIcon_bonus_%s.dds",
        },
        {
            id = ENCHANTMENT_SEARCH_CATEGORY_BEFOULED_WEAPON, -- deals x disease damage
            label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_BEFOULED_WEAPON),
            icon = "EsoUI/Art/Campaign/overview_indexIcon_scoring_%s.dds",
        },
        {
            id = ENCHANTMENT_SEARCH_CATEGORY_DAMAGE_HEALTH, -- deals x unresistable damage
            label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_DAMAGE_HEALTH),
            icon = "EsoUI/Art/Progression/progression_tabIcon_combatskills_%s.dds",
        },
        {
            id = ENCHANTMENT_SEARCH_CATEGORY_BERSERKER, -- increase your weapon damage by x for y seconds
            label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_BERSERKER),
            icon = "EsoUI/Art/Campaign/campaignBrowser_indexIcon_normal_%s.dds",
        },
        {
            id = ENCHANTMENT_SEARCH_CATEGORY_REDUCE_POWER, -- reduce target weapon damage by x for y seconds
            label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_REDUCE_POWER),
            icon = "EsoUI/Art/Crafting/smithing_tabIcon_weaponset_%s.dds",
        },
        {
            id = ENCHANTMENT_SEARCH_CATEGORY_DAMAGE_SHIELD, -- grants a x point damage shield for y seconds
            label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_DAMAGE_SHIELD),
            icon = "EsoUI/Art/Guild/tabIcon_heraldry_%s.dds",
        },
        {
            id = ENCHANTMENT_SEARCH_CATEGORY_REDUCE_ARMOR, -- reduce target's armor by x for y seconds
            label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_REDUCE_ARMOR),
            icon = "EsoUI/Art/Crafting/smithing_tabIcon_armorset_%s.dds",
        },
        {
            id = ENCHANTMENT_SEARCH_CATEGORY_ABSORB_MAGICKA, -- deals x magic damage and restores y magicka
            label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_ABSORB_MAGICKA),
            icon = "EsoUI/Art/Inventory/inventory_tabIcon_consumables_%s.dds",
        },
        {
            id = ENCHANTMENT_SEARCH_CATEGORY_ABSORB_HEALTH, -- deals x magic damage and restores y health
            label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_ABSORB_HEALTH),
            icon = "EsoUI/Art/Crafting/provisioner_indexIcon_meat_%s.dds",
        },
        {
            id = ENCHANTMENT_SEARCH_CATEGORY_ABSORB_STAMINA, -- deals x magic damage and restores y stamina
            label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_ABSORB_STAMINA),
            icon = "EsoUI/Art/Crafting/provisioner_indexIcon_beer_%s.dds",
        },
        {
            id = ENCHANTMENT_SEARCH_CATEGORY_PRISMATIC_ONSLAUGHT, -- prismatic enchantments
            label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_PRISMATIC_ONSLAUGHT),
            icon = "EsoUI/Art/Inventory/inventory_tabIcon_misc_%s.dds", -- TODO
        },
    }
}

local ARMOR_ENCHANTMENT_FILTER = {
    id = FILTER_ID.ARMOR_ENCHANTMENT_FILTER,
    type = TRADING_HOUSE_FILTER_TYPE_ENCHANTMENT,
    unpack = UnpackEnchantSearchCategory,
    -- TRANSLATORS: title of the armor enchantment filter in the left panel on the search tab
    label = gettext("Armor Enchantment"),
    enabled = {
        [SUB_CATEGORY_ID.ARMOR_ALL] = true,
        [SUB_CATEGORY_ID.ARMOR_HEAVY] = true,
        [SUB_CATEGORY_ID.ARMOR_MEDIUM] = true,
        [SUB_CATEGORY_ID.ARMOR_LIGHT] = true,
        [SUB_CATEGORY_ID.ARMOR_SHIELD] = true,
    },
    values = {
        {
            id = ENCHANTMENT_SEARCH_CATEGORY_MAGICKA, -- adds x max magicka
            label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_MAGICKA),
            icon = "EsoUI/Art/Inventory/inventory_tabIcon_consumables_%s.dds",
        },
        {
            id = ENCHANTMENT_SEARCH_CATEGORY_HEALTH, -- adds x max health
            label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_HEALTH),
            icon = "EsoUI/Art/Crafting/provisioner_indexIcon_meat_%s.dds",
        },
        {
            id = ENCHANTMENT_SEARCH_CATEGORY_STAMINA, -- adds x max stamina
            label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_STAMINA),
            icon = "EsoUI/Art/Crafting/provisioner_indexIcon_beer_%s.dds",
        },
        {
            id = ENCHANTMENT_SEARCH_CATEGORY_PRISMATIC_DEFENSE, -- prismatic enchantments
            label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_PRISMATIC_DEFENSE),
            icon = "EsoUI/Art/Inventory/inventory_tabIcon_misc_%s.dds",
        },
    }
}

local JEWELRY_ENCHANTMENT_FILTER = {
    id = FILTER_ID.JEWELRY_ENCHANTMENT_FILTER,
    type = TRADING_HOUSE_FILTER_TYPE_ENCHANTMENT,
    unpack = UnpackEnchantSearchCategory,
    -- TRANSLATORS: title of the jewelry enchantment filter in the left panel on the search tab
    label = gettext("Jewelry Enchantment"),
    enabled = {
        [SUB_CATEGORY_ID.JEWELRY_ALL] = true,
        [SUB_CATEGORY_ID.JEWELRY_RING] = true,
        [SUB_CATEGORY_ID.JEWELRY_NECK] = true,
    },
    values = {
        {
            id = ENCHANTMENT_SEARCH_CATEGORY_FIRE_RESISTANT, -- adds x flame resistance
            label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_FIRE_RESISTANT),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Weapons_Staff_Flame_%s.dds",
        },
        {
            id = ENCHANTMENT_SEARCH_CATEGORY_FROST_RESISTANT, -- adds x cold resistance
            label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_FROST_RESISTANT),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Weapons_Staff_Frost_%s.dds",
        },
        {
            id = ENCHANTMENT_SEARCH_CATEGORY_SHOCK_RESISTANT, -- adds x shock resistance
            label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_SHOCK_RESISTANT),
            icon = "EsoUI/Art/Repair/inventory_tabIcon_repair_%s.dds",
        },
        {
            id = ENCHANTMENT_SEARCH_CATEGORY_POISON_RESISTANT, -- adds x poison resistance
            label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_POISON_RESISTANT),
            icon = "EsoUI/Art/Campaign/overview_indexIcon_bonus_%s.dds",
        },
        {
            id = ENCHANTMENT_SEARCH_CATEGORY_DISEASE_RESISTANT, -- adds x disease resistance
            label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_DISEASE_RESISTANT),
            icon = "EsoUI/Art/Campaign/overview_indexIcon_scoring_%s.dds",
        },
        {
            id = ENCHANTMENT_SEARCH_CATEGORY_DECREASE_SPELL_DAMAGE, -- adds x spell resistance
            label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_DECREASE_SPELL_DAMAGE),
            icon = "EsoUI/Art/Campaign/campaignBrowser_indexIcon_hardcore_%s.dds",
        },
        {
            id = ENCHANTMENT_SEARCH_CATEGORY_DECREASE_PHYSICAL_DAMAGE, -- adds x armor
            label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_DECREASE_PHYSICAL_DAMAGE),
            icon = "EsoUI/Art/Campaign/campaign_tabIcon_browser_%s.dds",
        },
        {
            id = ENCHANTMENT_SEARCH_CATEGORY_INCREASE_SPELL_DAMAGE, -- adds x spell damage
            label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_INCREASE_SPELL_DAMAGE),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Weapons_Staff_Lightning_%s.dds",
        },
        {
            id = ENCHANTMENT_SEARCH_CATEGORY_INCREASE_PHYSICAL_DAMAGE, -- adds x weapon damage
            label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_INCREASE_PHYSICAL_DAMAGE),
            icon = "EsoUI/Art/Progression/progression_tabIcon_combatskills_%s.dds",
        },
        {
            id = ENCHANTMENT_SEARCH_CATEGORY_INCREASE_BASH_DAMAGE, -- increase bash damage by x
            label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_INCREASE_BASH_DAMAGE),
            icon = "EsoUI/Art/Inventory/inventory_tabIcon_shield_%s.dds",
        },
        {
            id = ENCHANTMENT_SEARCH_CATEGORY_INCREASE_POTION_EFFECTIVENESS, -- increase the effect of restoration potions by x
            label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_INCREASE_POTION_EFFECTIVENESS),
            icon = "EsoUI/Art/Crafting/alchemy_tabIcon_solvent_%s.dds",
        },
        {
            id = ENCHANTMENT_SEARCH_CATEGORY_REDUCE_POTION_COOLDOWN, -- reduce the cooldown of positions below this item's level by x seconds
            label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_REDUCE_POTION_COOLDOWN),
            icon = "EsoUI/Art/Guild/tabIcon_history_%s.dds",
        },
        {
            id = ENCHANTMENT_SEARCH_CATEGORY_REDUCE_SPELL_COST, -- reduce magicka cost of spells by x
            label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_REDUCE_SPELL_COST),
            icon = "EsoUI/Art/Progression/progression_indexIcon_world_%s.dds",
        },
        {
            id = ENCHANTMENT_SEARCH_CATEGORY_REDUCE_FEAT_COST, -- reduce stamina cost of abilities by x
            label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_REDUCE_FEAT_COST),
            icon = "EsoUI/Art/Guild/guildHeraldry_indexIcon_crest_%s.dds",
        },
        {
            id = ENCHANTMENT_SEARCH_CATEGORY_REDUCE_BLOCK_AND_BASH, -- reduce cost of bash by x and reduce cost of blocking by y
            label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_REDUCE_BLOCK_AND_BASH),
            icon = "EsoUI/Art/Guild/tabIcon_heraldry_%s.dds",
        },
        {
            id = ENCHANTMENT_SEARCH_CATEGORY_MAGICKA_REGEN, -- adds x magicka recovery
            label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_MAGICKA_REGEN),
            icon = "EsoUI/Art/Inventory/inventory_tabIcon_consumables_%s.dds",
        },
        {
            id = ENCHANTMENT_SEARCH_CATEGORY_HEALTH_REGEN, -- adds x health recovery
            label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_HEALTH_REGEN),
            icon = "EsoUI/Art/Crafting/provisioner_indexIcon_meat_%s.dds",
        },
        {
            id = ENCHANTMENT_SEARCH_CATEGORY_STAMINA_REGEN, -- adds x stamina recovery
            label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_STAMINA_REGEN),
            icon = "EsoUI/Art/Crafting/provisioner_indexIcon_beer_%s.dds",
        },
    }
}

AGS.data.WEAPON_ENCHANTMENT_FILTER = WEAPON_ENCHANTMENT_FILTER
AGS.data.ARMOR_ENCHANTMENT_FILTER = ARMOR_ENCHANTMENT_FILTER
AGS.data.JEWELRY_ENCHANTMENT_FILTER = JEWELRY_ENCHANTMENT_FILTER
