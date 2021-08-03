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

local GLYPH_TYPE_FILTER = {
    id = FILTER_ID.GLYPH_TYPE_FILTER,
    type = TRADING_HOUSE_FILTER_TYPE_ITEM,
    unpack = UnpackItemType,
    -- TRANSLATORS: title of the glyph type filter in the left panel on the search tab
    label = gettext("Glyph Type"),
    enabled = {
        [SUB_CATEGORY_ID.MISCELLANEOUS_GLYPHS] = true,
    },
    values = {
        {
            id = ITEMTYPE_GLYPH_ARMOR,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_GLYPH_ARMOR)),
            icon = "AwesomeGuildStore/images/misc/armor_glyph_%s.dds",
        },
        {
            id = ITEMTYPE_GLYPH_WEAPON,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_GLYPH_WEAPON)),
            icon = "AwesomeGuildStore/images/misc/weapon_glyph_%s.dds",
        },
        {
            id = ITEMTYPE_GLYPH_JEWELRY,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_GLYPH_JEWELRY)),
            icon = "AwesomeGuildStore/images/misc/jewelry_glyph_%s.dds",
        },
    }
}

local RECIPE_TYPE_FILTER = {
    id = FILTER_ID.RECIPE_TYPE_FILTER,
    type = TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM,
    unpack = UnpackSpecializedItemType,
    -- TRANSLATORS: title of the recipe type filter in the left panel on the search tab
    label = gettext("Recipe Type"),
    enabled = {
        [SUB_CATEGORY_ID.CONSUMABLE_RECIPE] = true,
    },
    values = {
        {
            id = SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD)),
            icon = "EsoUI/Art/Crafting/provisioner_indexIcon_meat_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK)),
            icon = "EsoUI/Art/Crafting/provisioner_indexIcon_beer_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING)),
            icon = "EsoUI/Art/Crafting/diagrams_tabicon_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING)),
            icon = "EsoUI/Art/Crafting/patterns_tabicon_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING)),
            icon = "EsoUI/Art/Crafting/blueprints_tabicon_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING)),
            icon = "EsoUI/Art/Crafting/formulae_tabicon_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING)),
            icon = "EsoUI/Art/Crafting/schematics_tabicon_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING)),
            icon = "EsoUI/Art/Crafting/designs_tabicon_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_RECIPE_JEWELRYCRAFTING_SKETCH_FURNISHING,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_JEWELRYCRAFTING_SKETCH_FURNISHING)),
            icon = "EsoUI/Art/Crafting/sketches_tabicon_%s.dds",
        },
    }
}

local DRINK_TYPE_FILTER = {
    id = FILTER_ID.DRINK_TYPE_FILTER,
    type = TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM,
    unpack = UnpackSpecializedItemType,
    -- TRANSLATORS: title of the drink type filter in the left panel on the search tab
    label = gettext("Drink Type"),
    enabled = {
        [SUB_CATEGORY_ID.CONSUMABLE_DRINK] = true,
    },
    values = {
        {
            id = SPECIALIZED_ITEMTYPE_DRINK_ALCOHOLIC,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_DRINK_ALCOHOLIC)),
            icon = "EsoUI/Art/TreeIcons/provisioner_indexIcon_beer_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_DRINK_TEA,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_DRINK_TEA)),
            icon = "EsoUI/Art/WorldMap/map_indexIcon_filters_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_DRINK_TONIC,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_DRINK_TONIC)),
            icon = "EsoUI/Art/Crafting/alchemy_tabIcon_solvent_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_DRINK_LIQUEUR,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_DRINK_LIQUEUR)),
            icon = "EsoUI/Art/TreeIcons/provisioner_indexIcon_spirits_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_DRINK_TINCTURE,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_DRINK_TINCTURE)),
            icon = "EsoUI/Art/TreeIcons/provisioner_indexIcon_wine_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_DRINK_CORDIAL_TEA,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_DRINK_CORDIAL_TEA)),
            icon = "AwesomeGuildStore/images/crafting/tea_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_DRINK_DISTILLATE,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_DRINK_DISTILLATE)),
            icon = "EsoUI/Art/Inventory/inventory_tabIcon_consumables_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_DRINK_UNIQUE,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_FOOD_UNIQUE)), -- SPECIALIZED_ITEMTYPE_DRINK_UNIQUE is labeled as "Drink", so we use this for now
            icon = "EsoUI/Art/TreeIcons/collection_indexIcon_dyes_%s.dds",
        },
    }
}

local FOOD_TYPE_FILTER = {
    id = FILTER_ID.FOOD_TYPE_FILTER,
    type = TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM,
    unpack = UnpackSpecializedItemType,
    -- TRANSLATORS: title of the food type filter in the left panel on the search tab
    label = gettext("Food Type"),
    enabled = {
        [SUB_CATEGORY_ID.CONSUMABLE_FOOD] = true,
    },
    values = {
        {
            id = SPECIALIZED_ITEMTYPE_FOOD_MEAT,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_FOOD_MEAT)),
            icon = "EsoUI/Art/treeicons/provisioner_indexicon_meat_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_FOOD_FRUIT,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_FOOD_FRUIT)),
            icon = "AwesomeGuildStore/images/consumable/fruit_dish_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_FOOD_VEGETABLE,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_FOOD_VEGETABLE)),
            icon = "EsoUI/Art/worldmap/map_ava_tabicon_foodfarm_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_FOOD_SAVOURY,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_FOOD_SAVOURY)),
            icon = "EsoUI/Art/treeicons/provisioner_indexicon_baked_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_FOOD_RAGOUT,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_FOOD_RAGOUT)),
            icon = "EsoUI/Art/treeicons/provisioner_indexicon_stew_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_FOOD_ENTREMET,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_FOOD_ENTREMET)),
            icon = "AwesomeGuildStore/images/consumable/entremet_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_FOOD_GOURMET,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_FOOD_GOURMET)),
            icon = "EsoUI/Art/Inventory/inventory_tabIcon_craftbag_provisioning_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_FOOD_UNIQUE,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_FOOD_UNIQUE)),
            icon = "AwesomeGuildStore/images/consumable/unique_dish_%s.dds",
        },
    }
}

local SIEGE_TYPE_FILTER = {
    id = FILTER_ID.SIEGE_TYPE_FILTER,
    type = TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM,
    unpack = UnpackSpecializedItemType,
    -- TRANSLATORS: title of the siege type filter in the left panel on the search tab
    label = gettext("Siege Type"),
    enabled = {
        [SUB_CATEGORY_ID.MISCELLANEOUS_SIEGE] = true,
    },
    values = {
        {
            id = SPECIALIZED_ITEMTYPE_SIEGE_BALLISTA,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_SIEGE_BALLISTA)),
            icon = "EsoUI/Art/Icons/progression_tabIcon_solspear_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_SIEGE_CATAPULT,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_SIEGE_CATAPULT)),
            icon = "EsoUI/Art/Icons/progression_tabIcon_avasiege_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_SIEGE_TREBUCHET,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_SIEGE_TREBUCHET)),
            icon = "EsoUI/Art/MainMenu/menuBar_ava_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_SIEGE_OIL,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_SIEGE_OIL)),
            icon = "EsoUI/Art/Icons/progression_tabIcon_flames_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_SIEGE_RAM,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_SIEGE_RAM)),
            icon = "EsoUI/Art/WorldMap/map_ava_tabIcon_woodmill_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_SIEGE_GRAVEYARD,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_SIEGE_GRAVEYARD)),
            icon = "EsoUI/Art/Guild/tabIcon_home_%s.dds",
        },
    }
}

local CONSUMABLE_TROPHY_TYPE_FILTER = {
    id = FILTER_ID.CONSUMABLE_TROPHY_TYPE_FILTER,
    type = TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM,
    unpack = UnpackSpecializedItemType,
    -- TRANSLATORS: title of the trophy type filter in the left panel on the search tab
    label = gettext("Trophy Type"),
    enabled = {
        [SUB_CATEGORY_ID.CONSUMABLE_TROPHY] = true,
    },
    values = {
        {
            id = SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT)),
            icon = "EsoUI/Art/tradinghouse/tradinghouse_trophy_recipe_fragment_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE)),
            icon = "EsoUI/Art/tradinghouse/tradinghouse_racial_style_motif_book_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_TROPHY_RUNEBOX_FRAGMENT,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_TROPHY_RUNEBOX_FRAGMENT)),
            icon = "EsoUI/Art/tradinghouse/tradinghouse_trophy_runebox_fragment_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_TROPHY_SCROLL,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_TROPHY_SCROLL)),
            icon = "EsoUI/Art/tradinghouse/tradinghouse_trophy_scroll_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_FURNISHING_ATTUNABLE_STATION,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_FURNISHING_ATTUNABLE_STATION)),
            icon = "EsoUI/Art/Inventory/inventory_tabIcon_crafting_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_FISH,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_FISH)),
            icon = "EsoUI/Art/treeicons/tutorial_idexicon_fishing_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_TREASURE,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_TREASURE)),
            icon = "EsoUI/Art/tradinghouse/tradinghouse_other_trophy_types_%s.dds",
        },
    }
}

local MISC_TROPHY_TYPE_FILTER = {
    id = FILTER_ID.MISC_TROPHY_TYPE_FILTER,
    type = TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM,
    unpack = UnpackSpecializedItemType,
    -- TRANSLATORS: title of the trophy type filter in the left panel on the search tab
    label = gettext("Trophy Type"),
    enabled = {
        [SUB_CATEGORY_ID.MISCELLANEOUS_TROPHY] = true,
    },
    values = {
        {
            id = SPECIALIZED_ITEMTYPE_TROPHY_KEY_FRAGMENT,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_TROPHY_KEY_FRAGMENT)),
            icon = "EsoUI/Art/worldmap/map_indexicon_key_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP)),
            icon = "EsoUI/Art/tradinghouse/tradinghouse_trophy_treasure_map_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_COLLECTIBLE_RARE_FISH,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_COLLECTIBLE_RARE_FISH)),
            icon = "EsoUI/Art/treeicons/tutorial_idexicon_fishing_%s.dds",
        },
        {
            id = SPECIALIZED_ITEMTYPE_TROPHY_MUSEUM_PIECE,
            label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_TROPHY_MUSEUM_PIECE)),
            icon = "EsoUI/Art/tradinghouse/tradinghouse_other_trophy_types_%s.dds",
        },
    }
}

AGS.data.GLYPH_TYPE_FILTER = GLYPH_TYPE_FILTER
AGS.data.RECIPE_TYPE_FILTER = RECIPE_TYPE_FILTER
AGS.data.DRINK_TYPE_FILTER = DRINK_TYPE_FILTER
AGS.data.FOOD_TYPE_FILTER = FOOD_TYPE_FILTER
AGS.data.SIEGE_TYPE_FILTER = SIEGE_TYPE_FILTER
AGS.data.CONSUMABLE_TROPHY_TYPE_FILTER = CONSUMABLE_TROPHY_TYPE_FILTER
AGS.data.MISC_TROPHY_TYPE_FILTER = MISC_TROPHY_TYPE_FILTER
