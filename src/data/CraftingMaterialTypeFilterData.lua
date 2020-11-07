local AGS = AwesomeGuildStore

local gettext = AGS.internal.gettext
local SUB_CATEGORY_ID = AGS.data.SUB_CATEGORY_ID
local FILTER_ID = AGS.data.FILTER_ID

local function UnpackItemType(filter, itemData) -- TODO: collect all unpack functions in utils
    local id = GetItemLinkItemType(itemData.itemLink)
    return id
end

local function UnpackSpecializedItemType(filter, itemData) -- TODO: collect all unpack functions in utils
    local _, id = GetItemLinkItemType(itemData.itemLink)
    return id
end

-- TRANSLATORS: title of the crafting material filter in the left panel on the search tab
local label = gettext("Material Type")

local BLACKSMITHING_MATERIAL_TYPE_FILTER = {
    id = FILTER_ID.BLACKSMITHING_MATERIAL_TYPE_FILTER,
    type = TRADING_HOUSE_FILTER_TYPE_ITEM,
    unpack = UnpackItemType,
    label = label,
    enabled = {
        [SUB_CATEGORY_ID.CRAFTING_BLACKSMITHING] = true,
    },
    values = {
        {
            id = ITEMTYPE_BLACKSMITHING_RAW_MATERIAL,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_BLACKSMITHING_RAW_MATERIAL)),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Materials_Blacksmithing_Rawmats_%s.dds",
        },
        {
            id = ITEMTYPE_BLACKSMITHING_MATERIAL,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_BLACKSMITHING_MATERIAL)),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Materials_Blacksmithing_Mats_%s.dds",
        },
        {
            id = ITEMTYPE_BLACKSMITHING_BOOSTER,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_BLACKSMITHING_BOOSTER)),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Materials_Blacksmithing_Temper_%s.dds",
        },
    }
}

local CLOTHING_MATERIAL_TYPE_FILTER = {
    id = FILTER_ID.CLOTHING_MATERIAL_TYPE_FILTER,
    type = TRADING_HOUSE_FILTER_TYPE_ITEM,
    unpack = UnpackItemType,
    label = label,
    enabled = {
        [SUB_CATEGORY_ID.CRAFTING_CLOTHIER] = true,
    },
    values = {
        {
            id = ITEMTYPE_CLOTHIER_RAW_MATERIAL,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_CLOTHIER_RAW_MATERIAL)),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Materials_Tailoring_Rawmats_%s.dds",
        },
        {
            id = ITEMTYPE_CLOTHIER_MATERIAL,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_CLOTHIER_MATERIAL)),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Materials_Tailoring_Mats_%s.dds",
        },
        {
            id = ITEMTYPE_CLOTHIER_BOOSTER,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_CLOTHIER_BOOSTER)),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Materials_Tailoring_Tannin_%s.dds",
        },
    }
}

local WOODWORKING_MATERIAL_TYPE_FILTER = {
    id = FILTER_ID.WOODWORKING_MATERIAL_TYPE_FILTER,
    type = TRADING_HOUSE_FILTER_TYPE_ITEM,
    unpack = UnpackItemType,
    label = label,
    enabled = {
        [SUB_CATEGORY_ID.CRAFTING_WOODWORKING] = true,
    },
    values = {
        {
            id = ITEMTYPE_WOODWORKING_RAW_MATERIAL,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_WOODWORKING_RAW_MATERIAL)),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Materials_Woodworking_Rawmats_%s.dds",
        },
        {
            id = ITEMTYPE_WOODWORKING_MATERIAL,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_WOODWORKING_MATERIAL)),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Materials_Woodworking_Mats_%s.dds",
        },
        {
            id = ITEMTYPE_WOODWORKING_BOOSTER,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_WOODWORKING_BOOSTER)),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Materials_Woodworking_Resin_%s.dds",
        },
    }
}

local STYLE_MATERIAL_TYPE_FILTER = {
    id = FILTER_ID.STYLE_MATERIAL_TYPE_FILTER,
    type = TRADING_HOUSE_FILTER_TYPE_ITEM,
    unpack = UnpackItemType,
    label = label,
    enabled = {
        [SUB_CATEGORY_ID.CRAFTING_STYLE_MATERIAL] = true,
    },
    values = {
        {
            id = ITEMTYPE_RAW_MATERIAL,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_RAW_MATERIAL)),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Materials_Style_RawMats_%s.dds",
        },
        {
            id = ITEMTYPE_STYLE_MATERIAL,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_STYLE_MATERIAL)),
            icon = "EsoUI/Art/Inventory/inventory_tabIcon_Craftbag_styleMaterial_%s.dds",
        }
    }
}

local ALCHEMY_MATERIAL_TYPE_FILTER = {
    id = FILTER_ID.ALCHEMY_MATERIAL_TYPE_FILTER,
    type = TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM,
    unpack = UnpackSpecializedItemType,
    -- TRANSLATORS: title of the alchemy and provisioning material filter in the left panel on the search tab
    label = gettext("Ingredient Type"),
    enabled = {
        [SUB_CATEGORY_ID.CRAFTING_ALCHEMY] = true,
    },
    values = {
        {
            id = SPECIALIZED_ITEMTYPE_POTION_BASE,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_POTION_BASE)),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Potions_Potionsolvent_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_POISON_BASE,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_POISON_BASE)),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Potions_Poisonsolvent_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_REAGENT_ANIMAL_PART,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_REAGENT_ANIMAL_PART)),
            icon = "AwesomeGuildStore/images/crafting/animal_parts_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_REAGENT_FUNGUS,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_REAGENT_FUNGUS)),
            icon = "AwesomeGuildStore/images/crafting/fungus_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_REAGENT_HERB,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_REAGENT_HERB)),
            icon = "EsoUI/Art/Crafting/alchemy_tabIcon_reagent_%s.dds",
        },
    }
}

local ENCHANTING_MATERIAL_TYPE_FILTER = {
    id = FILTER_ID.ENCHANTING_MATERIAL_TYPE_FILTER,
    type = TRADING_HOUSE_FILTER_TYPE_ITEM,
    unpack = UnpackItemType,
    -- TRANSLATORS: title of the enchanting material filter in the left panel on the search tab
    label = gettext("Rune Type"),
    enabled = {
        [SUB_CATEGORY_ID.CRAFTING_ENCHANTING] = true,
    },
    values = {
        {
            id = ITEMTYPE_ENCHANTING_RUNE_ASPECT,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_ENCHANTING_RUNE_ASPECT)),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Materials_Enchanting_Aspect_%s.dds",
        },
        {
            id = ITEMTYPE_ENCHANTING_RUNE_ESSENCE,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_ENCHANTING_RUNE_ESSENCE)),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Materials_Enchanting_Essence_%s.dds",
        },
        {
            id = ITEMTYPE_ENCHANTING_RUNE_POTENCY,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_ENCHANTING_RUNE_POTENCY)),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Materials_Enchanting_Potency_%s.dds",
        },
    }
}

local PROVISIONING_MATERIAL_TYPE_FILTER = {
    id = FILTER_ID.PROVISIONING_MATERIAL_TYPE_FILTER,
    type = TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM,
    unpack = UnpackSpecializedItemType,
    label = gettext("Ingredient Type"),
    enabled = {
        [SUB_CATEGORY_ID.CRAFTING_PROVISIONING] = true,
    },
    values = {
        {
            id = SPECIALIZED_ITEMTYPE_INGREDIENT_FOOD_ADDITIVE,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_INGREDIENT_FOOD_ADDITIVE)),
            icon = "EsoUI/Art/Inventory/inventory_tabIcon_craftbag_provisioning_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_INGREDIENT_MEAT,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_INGREDIENT_MEAT)),
            icon = "EsoUI/Art/treeicons/provisioner_indexicon_meat_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_INGREDIENT_FRUIT,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_INGREDIENT_FRUIT)),
            icon = "AwesomeGuildStore/images/consumable/fruit_dish_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_INGREDIENT_VEGETABLE,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_INGREDIENT_VEGETABLE)),
            icon = "EsoUI/Art/worldmap/map_ava_tabicon_foodfarm_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_INGREDIENT_DRINK_ADDITIVE,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_INGREDIENT_DRINK_ADDITIVE)),
            icon = "EsoUI/Art/Inventory/inventory_tabIcon_consumables_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_INGREDIENT_ALCOHOL,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_INGREDIENT_ALCOHOL)),
            icon = "EsoUI/Art/TreeIcons/provisioner_indexIcon_beer_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_INGREDIENT_TEA,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_INGREDIENT_TEA)),
            icon = "AwesomeGuildStore/images/crafting/tea_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_INGREDIENT_TONIC,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_INGREDIENT_TONIC)),
            icon =  "EsoUI/Art/Crafting/alchemy_tabIcon_solvent_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_INGREDIENT_RARE,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_INGREDIENT_RARE)),
            icon = "EsoUI/Art/TreeIcons/collection_indexIcon_dyes_%s.dds",
        },
    }
}

local FURNISHING_MATERIAL_TYPE_FILTER = {
    id = FILTER_ID.FURNISHING_MATERIAL_TYPE_FILTER,
    type = TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM,
    unpack = UnpackSpecializedItemType,
    label = label,
    enabled = {
        [SUB_CATEGORY_ID.CRAFTING_FURNISHING_MATERIAL] = true,
    },
    values = {
        {
            id = SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_BLACKSMITHING,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, ZO_GetCraftingSkillName(CRAFTING_TYPE_BLACKSMITHING)),
            icon = "EsoUI/Art/Inventory/inventory_tabIcon_craftbag_blacksmithing_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_CLOTHIER,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, ZO_GetCraftingSkillName(CRAFTING_TYPE_CLOTHIER)),
            icon = "EsoUI/Art/Inventory/inventory_tabIcon_craftbag_clothing_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_WOODWORKING,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, ZO_GetCraftingSkillName(CRAFTING_TYPE_WOODWORKING)),
            icon = "EsoUI/Art/Inventory/inventory_tabIcon_craftbag_woodworking_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_ALCHEMY,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, ZO_GetCraftingSkillName(CRAFTING_TYPE_ALCHEMY)),
            icon = "EsoUI/Art/Inventory/inventory_tabIcon_craftbag_alchemy_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_ENCHANTING,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, ZO_GetCraftingSkillName(CRAFTING_TYPE_ENCHANTING)),
            icon = "EsoUI/Art/Inventory/inventory_tabIcon_craftbag_enchanting_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_PROVISIONING,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, ZO_GetCraftingSkillName(CRAFTING_TYPE_PROVISIONING)),
            icon = "EsoUI/Art/Inventory/inventory_tabIcon_craftbag_provisioning_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_JEWELRYCRAFTING,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, ZO_GetCraftingSkillName(CRAFTING_TYPE_JEWELRYCRAFTING)),
            icon = "EsoUI/Art/Inventory/inventory_tabIcon_craftbag_jewelrycrafting_%s.dds",
        },
    }
}

local TRAIT_MATERIAL_TYPE_FILTER = {
    id = FILTER_ID.TRAIT_MATERIAL_TYPE_FILTER,
    type = TRADING_HOUSE_FILTER_TYPE_ITEM,
    unpack = UnpackItemType,
    label = label,
    enabled = {
        [SUB_CATEGORY_ID.CRAFTING_TRAIT_MATERIAL] = true,
    },
    values = {
        {
            id = ITEMTYPE_WEAPON_TRAIT,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_WEAPON_TRAIT)),
            icon = "EsoUI/Art/Inventory/inventory_tabIcon_weapons_%s.dds",
        },
        {
            id = ITEMTYPE_ARMOR_TRAIT,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_ARMOR_TRAIT)),
            icon = "EsoUI/Art/Inventory/inventory_tabIcon_armor_%s.dds",
        },
        {
            id = ITEMTYPE_JEWELRY_RAW_TRAIT,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_JEWELRY_RAW_TRAIT)),
            icon = "EsoUI/Art/Crafting/smithing_tabIcon_refine_%s.dds",
        },
        {
            id = ITEMTYPE_JEWELRY_TRAIT,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_JEWELRY_TRAIT)),
            icon = "EsoUI/Art/Crafting/jewelry_tabIcon_icon_%s.dds",
        },
    }
}
-- the icon uses a wrong name, so our template approach won't work unless we redirect it to the correct name
RedirectTexture("EsoUI/Art/Crafting/jewelry_tabIcon_down.dds", "EsoUI/Art/Crafting/jewelry_tabIcon_icon_down.dds")

local JEWELRY_MATERIAL_TYPE_FILTER = {
    id = FILTER_ID.JEWELRY_MATERIAL_TYPE_FILTER,
    type = TRADING_HOUSE_FILTER_TYPE_ITEM,
    unpack = UnpackItemType,
    label = label,
    enabled = {
        [SUB_CATEGORY_ID.CRAFTING_JEWELRY] = true,
    },
    values = {
        {
            id = ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL)),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Materials_Jewelrymaking_Rawmats_%s.dds",
        },
        {
            id = ITEMTYPE_JEWELRYCRAFTING_MATERIAL,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_JEWELRYCRAFTING_MATERIAL)),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Materials_Jewelrymaking_Mats_%s.dds",
        },
        {
            id = ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER)),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Materials_Jewelrymaking_Rawplating_%s.dds",
        },
        {
            id = ITEMTYPE_JEWELRYCRAFTING_BOOSTER,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_JEWELRYCRAFTING_BOOSTER)),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Materials_Jewelrymaking_Plating_%s.dds",
        },
    }
}

AGS.data.BLACKSMITHING_MATERIAL_TYPE_FILTER = BLACKSMITHING_MATERIAL_TYPE_FILTER
AGS.data.CLOTHING_MATERIAL_TYPE_FILTER = CLOTHING_MATERIAL_TYPE_FILTER
AGS.data.WOODWORKING_MATERIAL_TYPE_FILTER = WOODWORKING_MATERIAL_TYPE_FILTER
AGS.data.STYLE_MATERIAL_TYPE_FILTER = STYLE_MATERIAL_TYPE_FILTER
AGS.data.ALCHEMY_MATERIAL_TYPE_FILTER = ALCHEMY_MATERIAL_TYPE_FILTER
AGS.data.ENCHANTING_MATERIAL_TYPE_FILTER = ENCHANTING_MATERIAL_TYPE_FILTER
AGS.data.PROVISIONING_MATERIAL_TYPE_FILTER = PROVISIONING_MATERIAL_TYPE_FILTER
AGS.data.FURNISHING_MATERIAL_TYPE_FILTER = FURNISHING_MATERIAL_TYPE_FILTER
AGS.data.TRAIT_MATERIAL_TYPE_FILTER = TRAIT_MATERIAL_TYPE_FILTER
AGS.data.JEWELRY_MATERIAL_TYPE_FILTER = JEWELRY_MATERIAL_TYPE_FILTER
