local L = AwesomeGuildStore.Localization

local SUBFILTER_WEAPON_TRAITS, SUBFILTER_WEAPON_ENCHANTMENTS, SUBFILTER_WEAPON_ONEHANDED, SUBFILTER_WEAPON_TWOHANDED, SUBFILTER_WEAPON_STAFF = 1, 2, 3, 4, 5
local SUBFILTER_ARMOR_SLOTS, SUBFILTER_ARMOR_TRAITS, SUBFILTER_ARMOR_ENCHANTMENTS, SUBFILTER_JEWELRY_TRAITS, SUBFILTER_JEWELRY_ENCHANTMENTS = 6, 7, 8, 9, 10
local SUBFILTER_BLACKSMITHING_MATERIALS, SUBFILTER_CLOTHING_MATERIALS, SUBFILTER_WOODWORKING_MATERIALS, SUBFILTER_ALCHEMY_MATERIALS = 11, 12, 13, 14
local SUBFILTER_ENCHANTING_MATERIALS, SUBFILTER_GLYPHS, SUBFILTER_JEWELRY_TYPE, SUBFILTER_STYLE_MATERIALS = 15, 16, 17, 18
local SUBFILTER_RECIPE_KNOWLEDGE, SUBFILTER_MOTIF_KNOWLEDGE, SUBFILTER_TRAIT_KNOWLEDGE, SUBFILTER_RUNE_KNOWLEDGE, SUBFILTER_ITEM_STYLE = 19, 20, 21, 22, 23
local SUBFILTER_ITEM_SET, SUBFILTER_CRAFTING, SUBFILTER_RECIPE_IMPROVEMENT, SUBFILTER_RECIPE_TYPE = 24, 25, 26, 27
local SUBFILTER_DRINK_TYPE, SUBFILTER_FOOD_TYPE, SUBFILTER_INGREDIENT_TYPE, SUBFILTER_SIEGE_TYPE = 28, 29, 30, 31
local SUBFILTER_TROPHY_TYPE = 32

AwesomeGuildStore.FILTER_PRESETS = {
    [ITEMFILTERTYPE_ALL] = {
        name = "All",
        label = L["FILTER_CATEGORY_ALL"],
        texture = "EsoUI/Art/Inventory/inventory_tabIcon_all_%s.dds",
        index = 0,
        hasLevelFilter = true,
        isDefault = true,
        subcategories = {}
    },
    [ITEMFILTERTYPE_WEAPONS] = {
        name = "Weapon",
        label = L["FILTER_CATEGORY_WEAPON"],
        texture = "EsoUI/Art/Inventory/inventory_tabIcon_weapons_%s.dds",
        index = 1,
        hasLevelFilter = true,
        subcategories = {
            {
                label = L["FILTER_SUBCATEGORY_ALL"],
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_all_%s.dds",
                isDefault = true,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_EQUIP] = { EQUIP_TYPE_ONE_HAND, EQUIP_TYPE_TWO_HAND }
                },
                subfilters = {
                    SUBFILTER_WEAPON_TRAITS,
                    SUBFILTER_WEAPON_ENCHANTMENTS,
                    SUBFILTER_TRAIT_KNOWLEDGE,
                    SUBFILTER_ITEM_STYLE,
                    SUBFILTER_ITEM_SET,
                    SUBFILTER_CRAFTING
                },
            },
            {
                label = L["FILTER_SUBCATEGORY_ONEHANDED"],
                texture = "AwesomeGuildStore/images/weapon/onehand_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_EQUIP] = { EQUIP_TYPE_ONE_HAND }
                },
                subfilters = {
                    SUBFILTER_WEAPON_ONEHANDED,
                    SUBFILTER_WEAPON_TRAITS,
                    SUBFILTER_WEAPON_ENCHANTMENTS,
                    SUBFILTER_TRAIT_KNOWLEDGE,
                    SUBFILTER_ITEM_STYLE,
                    SUBFILTER_ITEM_SET,
                    SUBFILTER_CRAFTING
                },
            },
            {
                label = L["FILTER_SUBCATEGORY_TWOHANDED"],
                texture = "AwesomeGuildStore/images/weapon/twohand_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_EQUIP] = { EQUIP_TYPE_TWO_HAND },
                    [TRADING_HOUSE_FILTER_TYPE_WEAPON] = { WEAPONTYPE_TWO_HANDED_AXE, WEAPONTYPE_TWO_HANDED_SWORD, WEAPONTYPE_TWO_HANDED_HAMMER }
                },
                subfilters = {
                    SUBFILTER_WEAPON_TWOHANDED,
                    SUBFILTER_WEAPON_TRAITS,
                    SUBFILTER_WEAPON_ENCHANTMENTS,
                    SUBFILTER_TRAIT_KNOWLEDGE,
                    SUBFILTER_ITEM_STYLE,
                    SUBFILTER_ITEM_SET,
                    SUBFILTER_CRAFTING
                },
            },
            {
                label = L["FILTER_SUBCATEGORY_BOW"],
                texture = "AwesomeGuildStore/images/weapon/bow_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_EQUIP] = { EQUIP_TYPE_TWO_HAND },
                    [TRADING_HOUSE_FILTER_TYPE_WEAPON] = { WEAPONTYPE_BOW }
                },
                subfilters = {
                    SUBFILTER_WEAPON_TRAITS,
                    SUBFILTER_WEAPON_ENCHANTMENTS,
                    SUBFILTER_TRAIT_KNOWLEDGE,
                    SUBFILTER_ITEM_STYLE,
                    SUBFILTER_ITEM_SET,
                    SUBFILTER_CRAFTING
                },
            },
            {
                label = L["FILTER_SUBCATEGORY_DESTRUCTION_STAFF"],
                texture = "AwesomeGuildStore/images/weapon/fire_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_EQUIP] = { EQUIP_TYPE_TWO_HAND },
                    [TRADING_HOUSE_FILTER_TYPE_WEAPON] = { WEAPONTYPE_FIRE_STAFF, WEAPONTYPE_FROST_STAFF, WEAPONTYPE_LIGHTNING_STAFF }
                },
                subfilters = {
                    SUBFILTER_WEAPON_STAFF,
                    SUBFILTER_WEAPON_TRAITS,
                    SUBFILTER_WEAPON_ENCHANTMENTS,
                    SUBFILTER_TRAIT_KNOWLEDGE,
                    SUBFILTER_ITEM_STYLE,
                    SUBFILTER_ITEM_SET,
                    SUBFILTER_CRAFTING
                },
            },
            {
                label = L["FILTER_SUBCATEGORY_RESTORATION_STAFF"],
                texture = "AwesomeGuildStore/images/weapon/restoration_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_EQUIP] = { EQUIP_TYPE_TWO_HAND },
                    [TRADING_HOUSE_FILTER_TYPE_WEAPON] = { WEAPONTYPE_HEALING_STAFF }
                },
                subfilters = {
                    SUBFILTER_WEAPON_TRAITS,
                    SUBFILTER_WEAPON_ENCHANTMENTS,
                    SUBFILTER_TRAIT_KNOWLEDGE,
                    SUBFILTER_ITEM_STYLE,
                    SUBFILTER_ITEM_SET,
                    SUBFILTER_CRAFTING
                },
            }
        }
    },
    [ITEMFILTERTYPE_ARMOR] = {
        name = "Armor",
        label = L["FILTER_CATEGORY_ARMOR"],
        texture = "EsoUI/Art/Inventory/inventory_tabIcon_armor_%s.dds",
        index = 2,
        hasLevelFilter = true,
        subcategories = {
            {
                label = L["FILTER_SUBCATEGORY_ALL"],
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_all_%s.dds",
                isDefault = true,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_ARMOR, ITEMTYPE_COSTUME, ITEMTYPE_DISGUISE, ITEMTYPE_TABARD },
                },
                subfilters = {
                    SUBFILTER_ARMOR_SLOTS,
                    SUBFILTER_ARMOR_TRAITS,
                    SUBFILTER_ARMOR_ENCHANTMENTS,
                    SUBFILTER_TRAIT_KNOWLEDGE,
                    SUBFILTER_ITEM_STYLE,
                    SUBFILTER_ITEM_SET,
                    SUBFILTER_CRAFTING
                },
            },
            {
                label = L["FILTER_SUBCATEGORY_HEAVYARMOR"],
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_armor_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_EQUIP] = { EQUIP_TYPE_HEAD, EQUIP_TYPE_CHEST, EQUIP_TYPE_SHOULDERS, EQUIP_TYPE_WAIST, EQUIP_TYPE_LEGS, EQUIP_TYPE_FEET, EQUIP_TYPE_HAND },
                    [TRADING_HOUSE_FILTER_TYPE_ARMOR] = { ARMORTYPE_HEAVY }
                },
                subfilters = {
                    SUBFILTER_ARMOR_SLOTS,
                    SUBFILTER_ARMOR_TRAITS,
                    SUBFILTER_ARMOR_ENCHANTMENTS,
                    SUBFILTER_TRAIT_KNOWLEDGE,
                    SUBFILTER_ITEM_STYLE,
                    SUBFILTER_ITEM_SET,
                    SUBFILTER_CRAFTING
                },
            },
            {
                label = L["FILTER_SUBCATEGORY_MEDIUMARMOR"],
                texture = "AwesomeGuildStore/images/armor/medium_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_EQUIP] = { EQUIP_TYPE_HEAD, EQUIP_TYPE_CHEST, EQUIP_TYPE_SHOULDERS, EQUIP_TYPE_WAIST, EQUIP_TYPE_LEGS, EQUIP_TYPE_FEET, EQUIP_TYPE_HAND },
                    [TRADING_HOUSE_FILTER_TYPE_ARMOR] = { ARMORTYPE_MEDIUM }
                },
                subfilters = {
                    SUBFILTER_ARMOR_SLOTS,
                    SUBFILTER_ARMOR_TRAITS,
                    SUBFILTER_ARMOR_ENCHANTMENTS,
                    SUBFILTER_TRAIT_KNOWLEDGE,
                    SUBFILTER_ITEM_STYLE,
                    SUBFILTER_ITEM_SET,
                    SUBFILTER_CRAFTING
                },
            },
            {
                label = L["FILTER_SUBCATEGORY_LIGHTARMOR"],
                texture = "AwesomeGuildStore/images/armor/light_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_EQUIP] = { EQUIP_TYPE_HEAD, EQUIP_TYPE_CHEST, EQUIP_TYPE_SHOULDERS, EQUIP_TYPE_WAIST, EQUIP_TYPE_LEGS, EQUIP_TYPE_FEET, EQUIP_TYPE_HAND },
                    [TRADING_HOUSE_FILTER_TYPE_ARMOR] = { ARMORTYPE_LIGHT }
                },
                subfilters = {
                    SUBFILTER_ARMOR_SLOTS,
                    SUBFILTER_ARMOR_TRAITS,
                    SUBFILTER_ARMOR_ENCHANTMENTS,
                    SUBFILTER_TRAIT_KNOWLEDGE,
                    SUBFILTER_ITEM_STYLE,
                    SUBFILTER_ITEM_SET,
                    SUBFILTER_CRAFTING
                },
            },
            {
                label = L["FILTER_SUBCATEGORY_SHIELD"],
                texture = "AwesomeGuildStore/images/armor/shield_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_EQUIP] = { EQUIP_TYPE_OFF_HAND },
                    [TRADING_HOUSE_FILTER_TYPE_WEAPON] = { WEAPONTYPE_SHIELD }
                },
                subfilters = {
                    SUBFILTER_ARMOR_TRAITS,
                    SUBFILTER_ARMOR_ENCHANTMENTS,
                    SUBFILTER_TRAIT_KNOWLEDGE,
                    SUBFILTER_ITEM_STYLE,
                    SUBFILTER_ITEM_SET,
                    SUBFILTER_CRAFTING
                },
            },
            {
                label = L["FILTER_SUBCATEGORY_JEWELRY"],
                texture = "AwesomeGuildStore/images/armor/neck_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_EQUIP] = { EQUIP_TYPE_RING, EQUIP_TYPE_NECK },
                },
                subfilters = {
                    SUBFILTER_JEWELRY_TYPE,
                    SUBFILTER_JEWELRY_TRAITS,
                    SUBFILTER_JEWELRY_ENCHANTMENTS,
                    SUBFILTER_ITEM_SET
                },
            },
            {
                label = L["FILTER_SUBCATEGORY_COSTUME"],
                texture = "AwesomeGuildStore/images/armor/costume_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_EQUIP] = { EQUIP_TYPE_COSTUME },
                },
                showTabards = true,
            }
        }
    },
    [ITEMFILTERTYPE_CONSUMABLE] = {
        name = "Consumable",
        label = L["FILTER_CATEGORY_CONSUMEABLE"],
        texture = "EsoUI/Art/Inventory/inventory_tabIcon_consumables_%s.dds",
        index = 3,
        subcategories = {
            {
                label = L["FILTER_SUBCATEGORY_ALL"],
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_all_%s.dds",
                isDefault = true,
                index = 1,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_FOOD, ITEMTYPE_DRINK, ITEMTYPE_RECIPE, ITEMTYPE_POTION, ITEMTYPE_POISON, ITEMTYPE_RACIAL_STYLE_MOTIF, ITEMTYPE_CONTAINER, ITEMTYPE_AVA_REPAIR, ITEMTYPE_MASTER_WRIT }
                },
            },
            {
                label = L["FILTER_SUBCATEGORY_FOOD"],
                texture = "EsoUI/Art/Crafting/provisioner_indexIcon_meat_%s.dds",
                index = 2,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_FOOD },
                },
                subfilters = {
                    SUBFILTER_FOOD_TYPE,
                    SUBFILTER_CRAFTING
                }
            },
            {
                label = L["FILTER_SUBCATEGORY_DRINK"],
                texture = "EsoUI/Art/Crafting/provisioner_indexIcon_beer_%s.dds",
                index = 3,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_DRINK },
                },
                subfilters = {
--                    SUBFILTER_DRINK_TYPE,
                    SUBFILTER_CRAFTING
                }
            },
            {
                label = L["FILTER_SUBCATEGORY_RECIPE"],
                texture = "EsoUI/Art/Guild/tabIcon_roster_%s.dds",
                index = 4,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_RECIPE },
                },
                subfilters = {
                    SUBFILTER_RECIPE_TYPE,
                    SUBFILTER_RECIPE_KNOWLEDGE,
                    SUBFILTER_RECIPE_IMPROVEMENT,
                },
            },
            {
                label = L["FILTER_SUBCATEGORY_POTION"],
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_consumables_%s.dds",
                index = 5,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_POTION },
                },
                subfilters = {
                    SUBFILTER_CRAFTING
                }
            },
            {
                label = L["FILTER_SUBCATEGORY_POISON"],
                texture = "EsoUI/Art/Crafting/alchemy_tabIcon_solvent_%s.dds",
                index = 6,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_POISON },
                },
                subfilters = {
                    SUBFILTER_CRAFTING
                }
            },
            {
                label = L["FILTER_SUBCATEGORY_MOTIF"],
                texture = "EsoUI/Art/MainMenu/menuBar_journal_%s.dds",
                index = 7,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_RACIAL_STYLE_MOTIF },
                },
                subfilters = {
                    SUBFILTER_MOTIF_KNOWLEDGE
                },
            },
            {
                label = L["FILTER_SUBCATEGORY_CONTAINER"],
                texture = "EsoUI/Art/MainMenu/menuBar_inventory_%s.dds",
                index = 9,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_CONTAINER, ITEMTYPE_FISH },
                },
            },
            {
                label = L["FILTER_SUBCATEGORY_REPAIR"],
                texture = "EsoUI/Art/Vendor/vendor_tabIcon_repair_%s.dds",
                index = 10,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_AVA_REPAIR },
                },
            },
            { -- needs to stay here because the table index is used for the save data
                label = L["FILTER_SUBCATEGORY_MASTER_WRIT"],
                texture = "EsoUI/Art/crafting/formulae_tabicon_%s.dds",
                index = 8,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_MASTER_WRIT },
                },
            },
        }
    },
    [ITEMFILTERTYPE_CRAFTING] = {
        name = "Crafting",
        label = L["FILTER_CATEGORY_CRAFTING"],
        texture = "EsoUI/Art/Inventory/inventory_tabIcon_crafting_%s.dds",
        index = 4,
        subcategories = {
            {
                label = L["FILTER_SUBCATEGORY_BLACKSMITHING"],
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_craftbag_blacksmithing_%s.dds",
                isDefault = true,
--                index = 2,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_BLACKSMITHING_RAW_MATERIAL, ITEMTYPE_BLACKSMITHING_MATERIAL, ITEMTYPE_BLACKSMITHING_BOOSTER },
                },
                subfilters = {
                    SUBFILTER_BLACKSMITHING_MATERIALS
                },
            },
            {
                label = L["FILTER_SUBCATEGORY_CLOTHING"],
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_craftbag_clothing_%s.dds",
--                index = 3,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_CLOTHIER_RAW_MATERIAL, ITEMTYPE_CLOTHIER_MATERIAL, ITEMTYPE_CLOTHIER_BOOSTER },
                },
                subfilters = {
                    SUBFILTER_CLOTHING_MATERIALS
                },
            },
            {
                label = L["FILTER_SUBCATEGORY_WOODWORKING"],
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_craftbag_woodworking_%s.dds",
--                index = 4,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_WOODWORKING_RAW_MATERIAL, ITEMTYPE_WOODWORKING_MATERIAL, ITEMTYPE_WOODWORKING_BOOSTER },
                },
                subfilters = {
                    SUBFILTER_WOODWORKING_MATERIALS
                },
            },
            {
                label = L["FILTER_SUBCATEGORY_ALCHEMY"],
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_craftbag_alchemy_%s.dds",
--                index = 5,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_POTION_BASE, ITEMTYPE_POISON_BASE, ITEMTYPE_REAGENT },
                },
                subfilters = {
                    SUBFILTER_ALCHEMY_MATERIALS
                },
            },
            {
                label = L["FILTER_SUBCATEGORY_ENCHANTING"],
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_craftbag_enchanting_%s.dds",
--                index = 6,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_ENCHANTING_RUNE_ASPECT, ITEMTYPE_ENCHANTING_RUNE_ESSENCE, ITEMTYPE_ENCHANTING_RUNE_POTENCY },
                },
                subfilters = {
                    SUBFILTER_ENCHANTING_MATERIALS,
                    SUBFILTER_RUNE_KNOWLEDGE
                },
            },
            {
                label = L["FILTER_SUBCATEGORY_PROVISIONING"],
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_craftbag_provisioning_%s.dds",
--                index = 7,
                filters = {
--                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_INGREDIENT },
                    [TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM] = { 
                        SPECIALIZED_ITEMTYPE_INGREDIENT_ALCOHOL,
                        SPECIALIZED_ITEMTYPE_INGREDIENT_DRINK_ADDITIVE,
                        SPECIALIZED_ITEMTYPE_INGREDIENT_FOOD_ADDITIVE,
                        SPECIALIZED_ITEMTYPE_INGREDIENT_FRUIT,
                        SPECIALIZED_ITEMTYPE_INGREDIENT_MEAT,
                        SPECIALIZED_ITEMTYPE_INGREDIENT_TEA,
                        SPECIALIZED_ITEMTYPE_INGREDIENT_TONIC,
                        SPECIALIZED_ITEMTYPE_INGREDIENT_VEGETABLE,
                    },
                },
                subfilters = {
--                    SUBFILTER_INGREDIENT_TYPE
                },
            },
            {
                label = L["FILTER_SUBCATEGORY_STYLE"],
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_craftbag_stylematerial_%s.dds",
--                index = 8,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_STYLE_MATERIAL, ITEMTYPE_RAW_MATERIAL },
                },
                subfilters = {
                    SUBFILTER_STYLE_MATERIALS
                },
            },
            {
                label = L["FILTER_SUBCATEGORY_WEAPONTRAIT"],
                texture = "EsoUI/Art/Crafting/smithing_tabIcon_weaponSet_%s.dds",
--                index = 9,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_WEAPON_TRAIT },
                }
            },
            {
                label = L["FILTER_SUBCATEGORY_ARMORTRAIT"],
                texture = "EsoUI/Art/Crafting/smithing_tabIcon_armorSet_%s.dds",
--                index = 10,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_ARMOR_TRAIT },
                }
            },
            {
                label = L["FILTER_SUBCATEGORY_FURNISHING_ORNAMENTAL"],
                texture = "EsoUI/Art/treeIcons/collection_indexicon_furnishings_%s.dds",
--                index = 11,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM] = { SPECIALIZED_ITEMTYPE_INGREDIENT_RARE },
                },
            },
--            { -- needs to stay here because the table index is used for the save data
--                label = L["FILTER_SUBCATEGORY_ALL"],
--                texture = "EsoUI/Art/Inventory/inventory_tabIcon_all_%s.dds",
--                isDefault = true,
--                index = 1,
--                filters = {
--                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { 
--                        ITEMTYPE_BLACKSMITHING_RAW_MATERIAL, ITEMTYPE_BLACKSMITHING_MATERIAL, ITEMTYPE_BLACKSMITHING_BOOSTER,
--                        ITEMTYPE_CLOTHIER_RAW_MATERIAL, ITEMTYPE_CLOTHIER_MATERIAL, ITEMTYPE_CLOTHIER_BOOSTER,
--                        ITEMTYPE_WOODWORKING_RAW_MATERIAL, ITEMTYPE_WOODWORKING_MATERIAL, ITEMTYPE_WOODWORKING_BOOSTER,
--                        ITEMTYPE_POTION_BASE, ITEMTYPE_POISON_BASE, ITEMTYPE_REAGENT,
--                        ITEMTYPE_ENCHANTING_RUNE_ASPECT, ITEMTYPE_ENCHANTING_RUNE_ESSENCE, ITEMTYPE_ENCHANTING_RUNE_POTENCY,
--                        ITEMTYPE_INGREDIENT,
--                        ITEMTYPE_STYLE_MATERIAL, ITEMTYPE_RAW_MATERIAL,
--                        ITEMTYPE_WEAPON_TRAIT,
--                        ITEMTYPE_ARMOR_TRAIT
--                    },
--                },
--            },
        }
    },
    [ITEMFILTERTYPE_FURNISHING] = {
        name = "Furnishing",
        label = L["FILTER_CATEGORY_FURNISHING"],
        texture = "EsoUI/Art/treeIcons/collection_indexicon_furnishings_%s.dds",
        index = 5,
        subcategories = {
            {
                label = L["FILTER_SUBCATEGORY_ALL"],
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_all_%s.dds",
                isDefault = true,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_FURNISHING },
                },
            },
            {
                label = L["FILTER_SUBCATEGORY_FURNISHING_CRAFTING_STATION"],
                texture = "EsoUI/Art/treeIcons/housing_indexicon_workshop_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM] = { SPECIALIZED_ITEMTYPE_FURNISHING_CRAFTING_STATION },
                },
            },
            {
                label = L["FILTER_SUBCATEGORY_FURNISHING_LIGHT"],
                texture = "EsoUI/Art/treeIcons/housing_indexicon_shrine_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM] = { SPECIALIZED_ITEMTYPE_FURNISHING_LIGHT },
                },
            },
            {
                label = L["FILTER_SUBCATEGORY_FURNISHING_ORNAMENTAL"],
                texture = "EsoUI/Art/treeIcons/housing_indexicon_gallery_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM] = { SPECIALIZED_ITEMTYPE_FURNISHING_ORNAMENTAL },
                },
            },
            {
                label = L["FILTER_SUBCATEGORY_FURNISHING_SEATING"],
                texture = "EsoUI/Art/treeIcons/collection_indexicon_furnishings_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM] = { SPECIALIZED_ITEMTYPE_FURNISHING_SEATING },
                },
            },
            {
                label = L["FILTER_SUBCATEGORY_FURNISHING_TARGET_DUMMY"],
                texture = "EsoUI/Art/treeIcons/collection_indexicon_weapons+armor_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM] = { SPECIALIZED_ITEMTYPE_FURNISHING_TARGET_DUMMY },
                },
            },
        },
    },
    [ITEMFILTERTYPE_MISCELLANEOUS] = {
        name = "Misc",
        label = L["FILTER_CATEGORY_MISC"],
        texture = "EsoUI/Art/Inventory/inventory_tabIcon_misc_%s.dds",
        index = 6,
        subcategories = {
            {
                label = L["FILTER_SUBCATEGORY_ALL"],
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_all_%s.dds",
                isDefault = true,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_GLYPH_WEAPON, ITEMTYPE_GLYPH_JEWELRY, ITEMTYPE_GLYPH_ARMOR, ITEMTYPE_SOUL_GEM, ITEMTYPE_SIEGE, ITEMTYPE_LURE, ITEMTYPE_TOOL, ITEMTYPE_TROPHY },
                },
            },
            {
                label = L["FILTER_SUBCATEGORY_GLYPHS"],
                texture = "AwesomeGuildStore/images/misc/glyphs_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_GLYPH_WEAPON, ITEMTYPE_GLYPH_JEWELRY, ITEMTYPE_GLYPH_ARMOR },
                },
                subfilters = {
                    SUBFILTER_GLYPHS,
                    SUBFILTER_CRAFTING
                },
            },
            {
                label = L["FILTER_SUBCATEGORY_SOULGEMS"],
                texture = "AwesomeGuildStore/images/misc/soulgem_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_SOUL_GEM },
                },
            },
            {
                label = L["FILTER_SUBCATEGORY_SIEGE"],
                texture = "EsoUI/Art/MainMenu/menuBar_ava_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_SIEGE },
                },
                subfilters = {
--                    SUBFILTER_SIEGE_TYPE,
                },
            },
            {
                label = L["FILTER_SUBCATEGORY_BAIT"],
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_craftbag_fishing_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_LURE },
                },
            },
            {
                label = L["FILTER_SUBCATEGORY_TOOLS"],
                texture = "EsoUI/Art/Vendor/vendor_tabIcon_repair_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_TOOL },
                },
            },
            {
                label = L["FILTER_SUBCATEGORY_TROPHY"],
                texture = "EsoUI/Art/Journal/journal_tabIcon_leaderboard_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_TROPHY },
                },
                subfilters = {
                    SUBFILTER_TROPHY_TYPE,
                },
            },
        },
    },
}

AwesomeGuildStore.SUBFILTER_PRESETS = {
    [SUBFILTER_WEAPON_TRAITS] = {
        type = 20,
        label = L["SUBFILTER_WEAPON_TRAIT_LABEL"],
        filter = TRADING_HOUSE_FILTER_TYPE_TRAIT,
        buttons = {
            {
                label = L["SUBFILTER_WEAPON_TRAIT_POWERED"],
                texture = "EsoUI/Art/Crafting/smithing_tabIcon_weaponset_%s.dds",
                value = ITEM_TRAIT_TYPE_WEAPON_POWERED,
            },
            {
                label = L["SUBFILTER_WEAPON_TRAIT_CHARGED"],
                texture = "EsoUI/Art/Campaign/overview_indexIcon_bonus_%s.dds",
                value = ITEM_TRAIT_TYPE_WEAPON_CHARGED,
            },
            {
                label = L["SUBFILTER_WEAPON_TRAIT_PRECISE"],
                texture = "EsoUI/Art/Campaign/overview_indexIcon_scoring_%s.dds",
                value = ITEM_TRAIT_TYPE_WEAPON_PRECISE,
            },
            {
                label = L["SUBFILTER_WEAPON_TRAIT_INFUSED"],
                texture = "EsoUI/Art/Progression/progression_tabIcon_combatskills_%s.dds",
                value = ITEM_TRAIT_TYPE_WEAPON_INFUSED,
            },
            {
                label = L["SUBFILTER_WEAPON_TRAIT_DEFENDING"],
                texture = "EsoUI/Art/Guild/tabIcon_heraldry_%s.dds",
                value = ITEM_TRAIT_TYPE_WEAPON_DEFENDING,
            },
            {
                label = L["SUBFILTER_WEAPON_TRAIT_TRAINING"],
                texture = "EsoUI/Art/Guild/tabIcon_ranks_%s.dds",
                value = ITEM_TRAIT_TYPE_WEAPON_TRAINING,
            },
            {
                label = L["SUBFILTER_WEAPON_TRAIT_SHARPENED"],
                texture = "EsoUI/Art/Campaign/campaignBrowser_indexIcon_normal_%s.dds",
                value = ITEM_TRAIT_TYPE_WEAPON_SHARPENED,
            },
            {
                label = L["SUBFILTER_WEAPON_TRAIT_DECISIVE"],
                texture = "EsoUI/Art/Inventory/inventory_tabicon_misc_%s.dds",
                value = ITEM_TRAIT_TYPE_WEAPON_DECISIVE,
            },
            {
                label = L["SUBFILTER_WEAPON_TRAIT_ORNATE"],
                texture = "EsoUI/Art/Tradinghouse/tradinghouse_sell_tabIcon_%s.dds",
                value = ITEM_TRAIT_TYPE_WEAPON_ORNATE,
            },
            {
                label = L["SUBFILTER_WEAPON_TRAIT_INTRICATE"],
                texture = "EsoUI/Art/Progression/progression_indexIcon_guilds_%s.dds",
                value = ITEM_TRAIT_TYPE_WEAPON_INTRICATE,
            },
            {
                label = L["SUBFILTER_WEAPON_TRAIT_NIRNHONED"],
                texture = "EsoUI/Art/WorldMap/map_ava_tabIcon_resourceProduction_%s.dds",
                value = ITEM_TRAIT_TYPE_WEAPON_NIRNHONED,
            },
        },
    },
    [SUBFILTER_WEAPON_ENCHANTMENTS] = {
        type = 21,
        label = L["SUBFILTER_WEAPON_ENCHANTMENT_LABEL"],
        filter = TRADING_HOUSE_FILTER_TYPE_ENCHANTMENT,
        singleButtonMode = true,
        buttons = {
            {
                label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_FIERY_WEAPON),
                texture = "AwesomeGuildStore/images/weapon/fire_%s.dds",
                value = ENCHANTMENT_SEARCH_CATEGORY_FIERY_WEAPON, -- deals x flame damage
            },
            {
                label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_FROZEN_WEAPON),
                texture = "AwesomeGuildStore/images/weapon/ice_%s.dds",
                value = ENCHANTMENT_SEARCH_CATEGORY_FROZEN_WEAPON, -- deals x cold damage
            },
            {
                label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_CHARGED_WEAPON),
                texture = "AwesomeGuildStore/images/weapon/lightning_%s.dds",
                value = ENCHANTMENT_SEARCH_CATEGORY_CHARGED_WEAPON, -- deals x shock damage
            },
            {
                label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_POISONED_WEAPON),
                texture = "EsoUI/Art/Campaign/overview_indexIcon_bonus_%s.dds",
                value = ENCHANTMENT_SEARCH_CATEGORY_POISONED_WEAPON, -- deals x poison damage
            },
            {
                label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_BEFOULED_WEAPON),
                texture = "EsoUI/Art/Campaign/overview_indexIcon_scoring_%s.dds",
                value = ENCHANTMENT_SEARCH_CATEGORY_BEFOULED_WEAPON, -- deals x disease damage
            },
            {
                label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_DAMAGE_HEALTH),
                texture = "EsoUI/Art/Progression/progression_tabIcon_combatskills_%s.dds",
                value = ENCHANTMENT_SEARCH_CATEGORY_DAMAGE_HEALTH, -- deals x unresistable damage
            },
            {
                label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_BERSERKER),
                texture = "EsoUI/Art/Campaign/campaignBrowser_indexIcon_normal_%s.dds",
                value = ENCHANTMENT_SEARCH_CATEGORY_BERSERKER, -- increase your weapon damage by x for y seconds
            },
            {
                label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_REDUCE_POWER),
                texture = "EsoUI/Art/Crafting/smithing_tabIcon_weaponset_%s.dds",
                value = ENCHANTMENT_SEARCH_CATEGORY_REDUCE_POWER, -- reduce target weapon damage by x for y seconds
            },
            {
                label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_DAMAGE_SHIELD),
                texture = "EsoUI/Art/Guild/tabIcon_heraldry_%s.dds",
                value = ENCHANTMENT_SEARCH_CATEGORY_DAMAGE_SHIELD, -- grants a x point damage shield for y seconds
            },
            {
                label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_REDUCE_ARMOR),
                texture = "EsoUI/Art/Crafting/smithing_tabIcon_armorset_%s.dds",
                value = ENCHANTMENT_SEARCH_CATEGORY_REDUCE_ARMOR, -- reduce target's armor by x for y seconds
            },
            {
                label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_ABSORB_MAGICKA),
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_consumables_%s.dds",
                value = ENCHANTMENT_SEARCH_CATEGORY_ABSORB_MAGICKA, -- deals x magic damage and restores y magicka
            },
            {
                label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_ABSORB_HEALTH),
                texture = "EsoUI/Art/Crafting/provisioner_indexIcon_meat_%s.dds",
                value = ENCHANTMENT_SEARCH_CATEGORY_ABSORB_HEALTH, -- deals x magic damage and restores y health
            },
            {
                label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_ABSORB_STAMINA),
                texture = "EsoUI/Art/Crafting/provisioner_indexIcon_beer_%s.dds",
                value = ENCHANTMENT_SEARCH_CATEGORY_ABSORB_STAMINA, -- deals x magic damage and restores y stamina
            },
            {
                label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_OTHER),
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_misc_%s.dds",
                value = ENCHANTMENT_SEARCH_CATEGORY_OTHER, -- ability changing enchantments
            },
        },
    },
    [SUBFILTER_WEAPON_ONEHANDED] = {
        type = 22,
        label = L["SUBFILTER_WEAPON_TYPE_LABEL"],
        filter = TRADING_HOUSE_FILTER_TYPE_WEAPON,
        buttons = {
            {
                label = L["SUBFILTER_WEAPON_TYPE_AXE"],
                texture = "AwesomeGuildStore/images/weapon/axe_%s.dds",
                value = WEAPONTYPE_AXE,
            },
            {
                label = L["SUBFILTER_WEAPON_TYPE_HAMMER"],
                texture = "AwesomeGuildStore/images/weapon/mace_%s.dds",
                value = WEAPONTYPE_HAMMER,
            },
            {
                label = L["SUBFILTER_WEAPON_TYPE_SWORD"],
                texture = "AwesomeGuildStore/images/weapon/twohand_%s.dds",
                value = WEAPONTYPE_SWORD,
            },
            {
                label = L["SUBFILTER_WEAPON_TYPE_DAGGER"],
                texture = "AwesomeGuildStore/images/weapon/dagger_%s.dds",
                value = WEAPONTYPE_DAGGER,
            },
        },
    },
    [SUBFILTER_WEAPON_TWOHANDED] = {
        type = 23,
        label = L["SUBFILTER_WEAPON_TYPE_LABEL"],
        filter = TRADING_HOUSE_FILTER_TYPE_WEAPON,
        buttons = {
            {
                label = L["SUBFILTER_WEAPON_TYPE_TWO_HANDED_AXE"],
                texture = "AwesomeGuildStore/images/weapon/axe_%s.dds",
                value = WEAPONTYPE_TWO_HANDED_AXE,
            },
            {
                label = L["SUBFILTER_WEAPON_TYPE_TWO_HANDED_HAMMER"],
                texture = "AwesomeGuildStore/images/weapon/mace_%s.dds",
                value = WEAPONTYPE_TWO_HANDED_HAMMER,
            },
            {
                label = L["SUBFILTER_WEAPON_TYPE_TWO_HANDED_SWORD"],
                texture = "AwesomeGuildStore/images/weapon/twohand_%s.dds",
                value = WEAPONTYPE_TWO_HANDED_SWORD,
            },
        },
    },
    [SUBFILTER_WEAPON_STAFF] = {
        type = 24,
        label = L["SUBFILTER_WEAPON_TYPE_LABEL"],
        filter = TRADING_HOUSE_FILTER_TYPE_WEAPON,
        buttons = {
            {
                label = L["SUBFILTER_WEAPON_TYPE_FIRE"],
                texture = "AwesomeGuildStore/images/weapon/fire_%s.dds",
                value = WEAPONTYPE_FIRE_STAFF,
            },
            {
                label = L["SUBFILTER_WEAPON_TYPE_FROST"],
                texture = "AwesomeGuildStore/images/weapon/ice_%s.dds",
                value = WEAPONTYPE_FROST_STAFF,
            },
            {
                label = L["SUBFILTER_WEAPON_TYPE_LIGHTNING"],
                texture = "AwesomeGuildStore/images/weapon/lightning_%s.dds",
                value = WEAPONTYPE_LIGHTNING_STAFF,
            },
        },
    },
    [SUBFILTER_ARMOR_SLOTS] = {
        type = 25,
        label = L["SUBFILTER_ARMOR_TYPE_LABEL"],
        filter = TRADING_HOUSE_FILTER_TYPE_EQUIP,
        buttons = {
            {
                label = L["SUBFILTER_ARMOR_TYPE_HEAD"],
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_armor_%s.dds",
                value = EQUIP_TYPE_HEAD,
            },
            {
                label = L["SUBFILTER_ARMOR_TYPE_CHEST"],
                texture = "AwesomeGuildStore/images/armor/chest_%s.dds",
                value = EQUIP_TYPE_CHEST,
            },
            {
                label = L["SUBFILTER_ARMOR_TYPE_SHOULDERS"],
                texture = "AwesomeGuildStore/images/armor/shoulders_%s.dds",
                value = EQUIP_TYPE_SHOULDERS,
            },
            {
                label = L["SUBFILTER_ARMOR_TYPE_WAIST"],
                texture = "AwesomeGuildStore/images/armor/belt_%s.dds",
                value = EQUIP_TYPE_WAIST,
            },
            {
                label = L["SUBFILTER_ARMOR_TYPE_LEGS"],
                texture = "AwesomeGuildStore/images/armor/legs_%s.dds",
                value = EQUIP_TYPE_LEGS,
            },
            {
                label = L["SUBFILTER_ARMOR_TYPE_FEET"],
                texture = "AwesomeGuildStore/images/armor/feet_%s.dds",
                value = EQUIP_TYPE_FEET,
            },
            {
                label = L["SUBFILTER_ARMOR_TYPE_HAND"],
                texture = "AwesomeGuildStore/images/armor/hands_%s.dds",
                value = EQUIP_TYPE_HAND,
            },
        },
    },
    [SUBFILTER_ARMOR_TRAITS] = {
        type = 26,
        label = L["SUBFILTER_ARMOR_TRAIT_LABEL"],
        filter = TRADING_HOUSE_FILTER_TYPE_TRAIT,
        buttons = {
            {
                label = L["SUBFILTER_ARMOR_TRAIT_STURDY"],
                texture = "EsoUI/Art/Campaign/campaignBrowser_indexIcon_hardcore_%s.dds",
                value = ITEM_TRAIT_TYPE_ARMOR_STURDY,
            },
            {
                label = L["SUBFILTER_ARMOR_TRAIT_IMPENETRABLE"],
                texture = "EsoUI/Art/Guild/tabIcon_heraldry_%s.dds",
                value = ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE,
            },
            {
                label = L["SUBFILTER_ARMOR_TRAIT_REINFORCED"],
                texture = "EsoUI/Art/Crafting/smithing_tabIcon_armorset_%s.dds",
                value = ITEM_TRAIT_TYPE_ARMOR_REINFORCED,
            },
            {
                label = L["SUBFILTER_ARMOR_TRAIT_WELLFITTED"],
                texture = "EsoUI/Art/Campaign/campaign_tabIcon_summary_%s.dds",
                value = ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED,
            },
            {
                label = L["SUBFILTER_ARMOR_TRAIT_TRAINING"],
                texture = "EsoUI/Art/Guild/tabIcon_ranks_%s.dds",
                value = ITEM_TRAIT_TYPE_ARMOR_TRAINING,
            },
            {
                label = L["SUBFILTER_ARMOR_TRAIT_INFUSED"],
                texture = "EsoUI/Art/Progression/progression_tabIcon_combatSkills_%s.dds",
                value = ITEM_TRAIT_TYPE_ARMOR_INFUSED,
            },
            {
                label = L["SUBFILTER_ARMOR_TRAIT_PROSPEROUS"],
                texture = "EsoUI/Art/Progression/progression_indexIcon_world_%s.dds",
                value = ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS,
            },
            {
                label = L["SUBFILTER_ARMOR_TRAIT_DIVINES"],
                texture = "EsoUI/Art/Progression/progression_indexIcon_race_%s.dds",
                value = ITEM_TRAIT_TYPE_ARMOR_DIVINES,
            },
            {
                label = L["SUBFILTER_ARMOR_TRAIT_ORNATE"],
                texture = "EsoUI/Art/Tradinghouse/tradinghouse_sell_tabIcon_%s.dds",
                value = ITEM_TRAIT_TYPE_ARMOR_ORNATE,
            },
            {
                label = L["SUBFILTER_ARMOR_TRAIT_INTRICATE"],
                texture = "EsoUI/Art/Progression/progression_indexIcon_guilds_%s.dds",
                value = ITEM_TRAIT_TYPE_ARMOR_INTRICATE,
            },
            {
                label = L["SUBFILTER_ARMOR_TRAIT_NIRNHONED"],
                texture = "EsoUI/Art/WorldMap/map_ava_tabIcon_resourceProduction_%s.dds",
                value = ITEM_TRAIT_TYPE_ARMOR_NIRNHONED,
            },
        },
    },
    [SUBFILTER_ARMOR_ENCHANTMENTS] = {
        type = 27,
        label = L["SUBFILTER_ARMOR_ENCHANTMENT_LABEL"],
        filter = TRADING_HOUSE_FILTER_TYPE_ENCHANTMENT,
        singleButtonMode = true,
        buttons = {
            {
                label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_MAGICKA),
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_consumables_%s.dds",
                value = ENCHANTMENT_SEARCH_CATEGORY_MAGICKA, -- adds x max magicka
            },
            {
                label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_HEALTH),
                texture = "EsoUI/Art/Crafting/provisioner_indexIcon_meat_%s.dds",
                value = ENCHANTMENT_SEARCH_CATEGORY_HEALTH, -- adds x max health
            },
            {
                label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_STAMINA),
                texture = "EsoUI/Art/Crafting/provisioner_indexIcon_beer_%s.dds",
                value = ENCHANTMENT_SEARCH_CATEGORY_STAMINA, -- adds x max stamina
            },
            {
                label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_OTHER),
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_misc_%s.dds",
                value = ENCHANTMENT_SEARCH_CATEGORY_OTHER, -- ability changing enchantments
            },
        },
    },
    [SUBFILTER_JEWELRY_TYPE] = {
        type = 28,
        label = L["SUBFILTER_JEWELRY_TYPE_LABEL"],
        filter = TRADING_HOUSE_FILTER_TYPE_EQUIP,
        singleButtonMode = true,
        buttons = {
            {
                label = L["SUBFILTER_JEWELRY_TYPE_RING"],
                texture = "AwesomeGuildStore/images/armor/ring_%s.dds",
                value = EQUIP_TYPE_RING,
            },
            {
                label = L["SUBFILTER_JEWELRY_TYPE_NECK"],
                texture = "AwesomeGuildStore/images/armor/neck_%s.dds",
                value = EQUIP_TYPE_NECK,
            },
        },
    },
    [SUBFILTER_JEWELRY_TRAITS] = {
        type = 29,
        label = L["SUBFILTER_JEWELRY_TRAIT_LABEL"],
        filter = TRADING_HOUSE_FILTER_TYPE_TRAIT,
        buttons = {
            {
                label = L["SUBFILTER_JEWELRY_TRAIT_HEALTHY"],
                texture = "EsoUI/Art/Crafting/provisioner_indexIcon_beer_%s.dds",
                value = ITEM_TRAIT_TYPE_JEWELRY_HEALTHY,
            },
            {
                label = L["SUBFILTER_JEWELRY_TRAIT_ARCANE"],
                texture = "EsoUI/Art/Campaign/campaignBrowser_indexIcon_specialEvents_%s.dds",
                value = ITEM_TRAIT_TYPE_JEWELRY_ARCANE,
            },
            {
                label = L["SUBFILTER_JEWELRY_TRAIT_ROBUST"],
                texture = "EsoUI/Art/Repair/inventory_tabIcon_repair_%s.dds",
                value = ITEM_TRAIT_TYPE_JEWELRY_ROBUST,
            },
            {
                label = L["SUBFILTER_JEWELRY_TRAIT_ORNATE"],
                texture = "EsoUI/Art/Tradinghouse/tradinghouse_sell_tabIcon_%s.dds",
                value = ITEM_TRAIT_TYPE_JEWELRY_ORNATE,
            },
        },
    },
    [SUBFILTER_JEWELRY_ENCHANTMENTS] = {
        type = 30,
        label = L["SUBFILTER_JEWELRY_ENCHANTMENT_LABEL"],
        filter = TRADING_HOUSE_FILTER_TYPE_ENCHANTMENT,
        singleButtonMode = true,
        buttons = {
            {
                label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_FIRE_RESISTANT),
                texture = "AwesomeGuildStore/images/weapon/fire_%s.dds",
                value = ENCHANTMENT_SEARCH_CATEGORY_FIRE_RESISTANT, -- adds x flame resistance
            },
            {
                label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_FROST_RESISTANT),
                texture = "AwesomeGuildStore/images/weapon/ice_%s.dds",
                value = ENCHANTMENT_SEARCH_CATEGORY_FROST_RESISTANT, -- adds x cold resistance
            },
            {
                label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_SHOCK_RESISTANT),
                texture = "EsoUI/Art/Repair/inventory_tabIcon_repair_%s.dds",
                value = ENCHANTMENT_SEARCH_CATEGORY_SHOCK_RESISTANT, -- adds x shock resistance
            },
            {
                label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_POISON_RESISTANT),
                texture = "EsoUI/Art/Campaign/overview_indexIcon_bonus_%s.dds",
                value = ENCHANTMENT_SEARCH_CATEGORY_POISON_RESISTANT, -- adds x poison resistance
            },
            {
                label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_DISEASE_RESISTANT),
                texture = "EsoUI/Art/Campaign/overview_indexIcon_scoring_%s.dds",
                value = ENCHANTMENT_SEARCH_CATEGORY_DISEASE_RESISTANT, -- adds x disease resistance
            },
            {
                label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_DECREASE_SPELL_DAMAGE),
                texture = "EsoUI/Art/Campaign/campaignBrowser_indexIcon_hardcore_%s.dds",
                value = ENCHANTMENT_SEARCH_CATEGORY_DECREASE_SPELL_DAMAGE, -- adds x spell resistance
            },
            {
                label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_DECREASE_PHYSICAL_DAMAGE),
                texture = "EsoUI/Art/Campaign/campaign_tabIcon_browser_%s.dds",
                value = ENCHANTMENT_SEARCH_CATEGORY_DECREASE_PHYSICAL_DAMAGE, -- adds x armor
            },
            {
                label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_INCREASE_SPELL_DAMAGE),
                texture = "AwesomeGuildStore/images/weapon/lightning_%s.dds",
                value = ENCHANTMENT_SEARCH_CATEGORY_INCREASE_SPELL_DAMAGE, -- adds x spell damage
            },
            {
                label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_INCREASE_PHYSICAL_DAMAGE),
                texture = "EsoUI/Art/Progression/progression_tabIcon_combatskills_%s.dds",
                value = ENCHANTMENT_SEARCH_CATEGORY_INCREASE_PHYSICAL_DAMAGE, -- adds x weapon damage
            },
            {
                label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_INCREASE_BASH_DAMAGE),
                texture = "AwesomeGuildStore/images/armor/shield_%s.dds",
                value = ENCHANTMENT_SEARCH_CATEGORY_INCREASE_BASH_DAMAGE, -- increase bash damage by x
            },
            {
                label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_INCREASE_POTION_EFFECTIVENESS),
                texture = "EsoUI/Art/Crafting/alchemy_tabIcon_solvent_%s.dds",
                value = ENCHANTMENT_SEARCH_CATEGORY_INCREASE_POTION_EFFECTIVENESS, -- increase the effect of restoration potions by x
            },
            {
                label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_REDUCE_POTION_COOLDOWN),
                texture = "EsoUI/Art/Guild/tabIcon_history_%s.dds",
                value = ENCHANTMENT_SEARCH_CATEGORY_REDUCE_POTION_COOLDOWN, -- reduce the cooldown of positions below this item's level by x seconds
            },
            {
                label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_REDUCE_SPELL_COST),
                texture = "EsoUI/Art/Progression/progression_indexIcon_world_%s.dds",
                value = ENCHANTMENT_SEARCH_CATEGORY_REDUCE_SPELL_COST, -- reduce magicka cost of spells by x
            },
            {
                label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_REDUCE_FEAT_COST),
                texture = "EsoUI/Art/Guild/guildHeraldry_indexIcon_crest_%s.dds",
                value = ENCHANTMENT_SEARCH_CATEGORY_REDUCE_FEAT_COST, -- reduce stamina cost of abilities by x
            },
            {
                label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_REDUCE_BLOCK_AND_BASH),
                texture = "EsoUI/Art/Guild/tabIcon_heraldry_%s.dds",
                value = ENCHANTMENT_SEARCH_CATEGORY_REDUCE_BLOCK_AND_BASH, -- reduce cost of bash by x and reduce cost of blocking by y
            },
            {
                label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_MAGICKA_REGEN),
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_consumables_%s.dds",
                value = ENCHANTMENT_SEARCH_CATEGORY_MAGICKA_REGEN, -- adds x magicka recovery
            },
            {
                label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_HEALTH_REGEN),
                texture = "EsoUI/Art/Crafting/provisioner_indexIcon_meat_%s.dds",
                value = ENCHANTMENT_SEARCH_CATEGORY_HEALTH_REGEN, -- adds x health recovery
            },
            {
                label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_STAMINA_REGEN),
                texture = "EsoUI/Art/Crafting/provisioner_indexIcon_beer_%s.dds",
                value = ENCHANTMENT_SEARCH_CATEGORY_STAMINA_REGEN, -- adds x stamina recovery
            },
            {
                label = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_OTHER),
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_misc_%s.dds",
                value = ENCHANTMENT_SEARCH_CATEGORY_OTHER, -- ability changing enchantments
            },
        },
    },
    [SUBFILTER_BLACKSMITHING_MATERIALS] = {
        type = 31,
        label = L["SUBFILTER_MATERIAL_TYPE_LABEL"],
        filter = TRADING_HOUSE_FILTER_TYPE_ITEM,
        buttons = {
            {
                label = L["SUBFILTER_MATERIAL_BLACKSMITHING_RAWMATERIAL"],
                texture = "AwesomeGuildStore/images/crafting/rawmaterial_%s.dds",
                value = ITEMTYPE_BLACKSMITHING_RAW_MATERIAL,
            },
            {
                label = L["SUBFILTER_MATERIAL_BLACKSMITHING_MATERIAL"],
                texture = "AwesomeGuildStore/images/crafting/material_%s.dds",
                value = ITEMTYPE_BLACKSMITHING_MATERIAL,
            },
            {
                label = L["SUBFILTER_MATERIAL_BLACKSMITHING_BOOSTER"],
                texture = "EsoUI/Art/WorldMap/map_ava_tabIcon_resourceProduction_%s.dds",
                value = ITEMTYPE_BLACKSMITHING_BOOSTER,
            },
        },
    },
    [SUBFILTER_CLOTHING_MATERIALS] = {
        type = 32,
        label = L["SUBFILTER_MATERIAL_TYPE_LABEL"],
        filter = TRADING_HOUSE_FILTER_TYPE_ITEM,
        buttons = {
            {
                label = L["SUBFILTER_MATERIAL_CLOTHING_RAWMATERIAL"],
                texture = "AwesomeGuildStore/images/crafting/rawmaterial_%s.dds",
                value = ITEMTYPE_CLOTHIER_RAW_MATERIAL,
            },
            {
                label = L["SUBFILTER_MATERIAL_CLOTHING_MATERIAL"],
                texture = "AwesomeGuildStore/images/crafting/material_%s.dds",
                value = ITEMTYPE_CLOTHIER_MATERIAL,
            },
            {
                label = L["SUBFILTER_MATERIAL_CLOTHING_BOOSTER"],
                texture = "EsoUI/Art/WorldMap/map_ava_tabIcon_resourceProduction_%s.dds",
                value = ITEMTYPE_CLOTHIER_BOOSTER,
            },
        },
    },
    [SUBFILTER_WOODWORKING_MATERIALS] = {
        type = 33,
        label = L["SUBFILTER_MATERIAL_TYPE_LABEL"],
        filter = TRADING_HOUSE_FILTER_TYPE_ITEM,
        buttons = {
            {
                label = L["SUBFILTER_MATERIAL_WOODWORKING_RAWMATERIAL"],
                texture = "AwesomeGuildStore/images/crafting/rawmaterial_%s.dds",
                value = ITEMTYPE_WOODWORKING_RAW_MATERIAL,
            },
            {
                label = L["SUBFILTER_MATERIAL_WOODWORKING_MATERIAL"],
                texture = "AwesomeGuildStore/images/crafting/material_%s.dds",
                value = ITEMTYPE_WOODWORKING_MATERIAL,
            },
            {
                label = L["SUBFILTER_MATERIAL_WOODWORKING_BOOSTER"],
                texture = "EsoUI/Art/WorldMap/map_ava_tabIcon_resourceProduction_%s.dds",
                value = ITEMTYPE_WOODWORKING_BOOSTER,
            },
        },
    },
    [SUBFILTER_STYLE_MATERIALS] = {
        type = 34,
        label = L["SUBFILTER_MATERIAL_TYPE_LABEL"],
        filter = TRADING_HOUSE_FILTER_TYPE_ITEM,
        buttons = {
            {
                label = L["SUBFILTER_MATERIAL_STYLE_RAWMATERIAL"],
                texture = "AwesomeGuildStore/images/crafting/rawmaterial_%s.dds",
                value = ITEMTYPE_RAW_MATERIAL,
            },
            {
                label = L["SUBFILTER_MATERIAL_STYLE_MATERIAL"],
                texture = "AwesomeGuildStore/images/crafting/material_%s.dds",
                value = ITEMTYPE_STYLE_MATERIAL,
            }
        },
    },
    [SUBFILTER_ALCHEMY_MATERIALS] = {
        type = 35,
        label = L["SUBFILTER_INGREDIENT_TYPE_LABEL"],
        filter = TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM,
        buttons = {
            {
                label = L["SUBFILTER_INGREDIENT_TYPE_POTION_SOLVENT"],
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_consumables_%s.dds",
                value = SPECIALIZED_ITEMTYPE_POTION_BASE,
            },
            {
                label = L["SUBFILTER_INGREDIENT_TYPE_POISON_SOLVENT"],
                texture = "EsoUI/Art/Crafting/alchemy_tabIcon_solvent_%s.dds",
                value = SPECIALIZED_ITEMTYPE_POISON_BASE,
            },
            {
                label = L["SUBFILTER_INGREDIENT_TYPE_ANIMAL_PART"],
                texture = "AwesomeGuildStore/images/crafting/animal_parts_%s.dds",
                value = SPECIALIZED_ITEMTYPE_REAGENT_ANIMAL_PART,
            },
            {
                label = L["SUBFILTER_INGREDIENT_TYPE_FUNGUS"],
                texture = "AwesomeGuildStore/images/crafting/fungus_%s.dds",
                value = SPECIALIZED_ITEMTYPE_REAGENT_FUNGUS,
            },
            {
                label = L["SUBFILTER_INGREDIENT_TYPE_HERB"],
                texture = "EsoUI/Art/Crafting/alchemy_tabIcon_reagent_%s.dds",
                value = SPECIALIZED_ITEMTYPE_REAGENT_HERB,
            },
        },
    },
    [SUBFILTER_ENCHANTING_MATERIALS] = {
        type = 36,
        label = L["SUBFILTER_RUNE_TYPE_LABEL"],
        filter = TRADING_HOUSE_FILTER_TYPE_ITEM,
        buttons = {
            {
                label = L["SUBFILTER_RUNE_TYPE_ASPECT"],
                texture = "EsoUI/Art/Crafting/enchantment_tabIcon_aspect_%s.dds",
                value = ITEMTYPE_ENCHANTING_RUNE_ASPECT,
            },
            {
                label = L["SUBFILTER_RUNE_TYPE_ESSENCE"],
                texture = "EsoUI/Art/Crafting/enchantment_tabIcon_essence_%s.dds",
                value = ITEMTYPE_ENCHANTING_RUNE_ESSENCE,
            },
            {
                label = L["SUBFILTER_RUNE_TYPE_POTENCY"],
                texture = "EsoUI/Art/Crafting/enchantment_tabIcon_potency_%s.dds",
                value = ITEMTYPE_ENCHANTING_RUNE_POTENCY,
            },
        },
    },
    [SUBFILTER_GLYPHS] = {
        type = 37,
        label = L["SUBFILTER_GLYPH_TYPE_LABEL"],
        filter = TRADING_HOUSE_FILTER_TYPE_ITEM,
        buttons = {
            {
                label = L["SUBFILTER_GLYPH_TYPE_ARMOR"],
                texture = "AwesomeGuildStore/images/misc/armor_glyph_%s.dds",
                value = ITEMTYPE_GLYPH_ARMOR,
            },
            {
                label = L["SUBFILTER_GLYPH_TYPE_WEAPON"],
                texture = "AwesomeGuildStore/images/misc/weapon_glyph_%s.dds",
                value = ITEMTYPE_GLYPH_WEAPON,
            },
            {
                label = L["SUBFILTER_GLYPH_TYPE_JEWELRY"],
                texture = "AwesomeGuildStore/images/misc/jewelry_glyph_%s.dds",
                value = ITEMTYPE_GLYPH_JEWELRY,
            },
        },
    },
    [SUBFILTER_RECIPE_KNOWLEDGE] = {
        type = 38,
        label = L["SUBFILTER_RECIPE_KNOWLEDGE_LABEL"],
        class = "KnownRecipeFilter",
        filter = 38,
        singleButtonMode = true,
        buttons = {
            {
                label = L["SUBFILTER_RECIPE_KNOWLEDGE_UNKNOWN"],
                texture = "EsoUI/Art/Campaign/overview_indexIcon_bonus_%s.dds",
                value = 1,
            },
            {
                label = L["SUBFILTER_RECIPE_KNOWLEDGE_KNOWN"],
                texture = "EsoUI/Art/Journal/journal_tabIcon_loreLibrary_%s.dds",
                value = 2,
            },
        },
    },
    [SUBFILTER_MOTIF_KNOWLEDGE] = {
        type = 39,
        label = L["SUBFILTER_MOTIF_KNOWLEDGE_LABEL"],
        class = "KnownMotifFilter",
        filter = 39,
        singleButtonMode = true,
        buttons = {
            {
                label = L["SUBFILTER_MOTIF_KNOWLEDGE_UNKNOWN"],
                texture = "EsoUI/Art/Campaign/overview_indexIcon_bonus_%s.dds",
                value = 1,
            },
            {
                label = L["SUBFILTER_MOTIF_KNOWLEDGE_KNOWN"],
                texture = "EsoUI/Art/Journal/journal_tabIcon_loreLibrary_%s.dds",
                value = 2,
            },
        },
    },
    [SUBFILTER_TRAIT_KNOWLEDGE] = {
        type = 40,
        label = L["SUBFILTER_TRAIT_KNOWLEDGE_LABEL"],
        class = "ResearchableTraitsFilter",
        filter = 40,
        singleButtonMode = true,
        buttons = {
            {
                label = L["SUBFILTER_TRAIT_KNOWLEDGE_UNKNOWN"],
                texture = "EsoUI/Art/Campaign/overview_indexIcon_bonus_%s.dds",
                value = 1,
            },
            {
                label = L["SUBFILTER_TRAIT_KNOWLEDGE_KNOWN"],
                texture = "EsoUI/Art/Journal/journal_tabIcon_loreLibrary_%s.dds",
                value = 2,
            },
        },
    },
    [SUBFILTER_RUNE_KNOWLEDGE] = {
        type = 41,
        label = L["SUBFILTER_RUNE_KNOWLEDGE_LABEL"],
        class = "KnownRuneTranslationFilter",
        filter = 41,
        singleButtonMode = true,
        buttons = {
            {
                label = L["SUBFILTER_RUNE_KNOWLEDGE_UNKNOWN"],
                texture = "EsoUI/Art/Campaign/overview_indexIcon_bonus_%s.dds",
                value = 1,
            },
            {
                label = L["SUBFILTER_RUNE_KNOWLEDGE_KNOWN"],
                texture = "EsoUI/Art/Journal/journal_tabIcon_loreLibrary_%s.dds",
                value = 2,
            },
        },
    },
    [SUBFILTER_ITEM_STYLE] = {
        type = 42,
        label = L["SUBFILTER_ITEM_STYLE_LABEL"],
        class = "ItemStyleFilter",
        filter = 42,
        isLocal = true, -- TODO: this is just a quick hack to prevent the 8 button warning from showing
        buttons = {
            {
                label = L["SUBFILTER_ITEM_STYLE_BRETON"],
                texture = "EsoUI/Art/CharacterCreate/characterCreate_bretonIcon_%s.dds",
                value = ITEMSTYLE_RACIAL_BRETON,
            },
            {
                label = L["SUBFILTER_ITEM_STYLE_REDGUARD"],
                texture = "EsoUI/Art/CharacterCreate/characterCreate_redguardIcon_%s.dds",
                value = ITEMSTYLE_RACIAL_REDGUARD,
            },
            {
                label = L["SUBFILTER_ITEM_STYLE_ORC"],
                texture = "EsoUI/Art/CharacterCreate/characterCreate_orcIcon_%s.dds",
                value = ITEMSTYLE_RACIAL_ORC,
            },
            {
                label = L["SUBFILTER_ITEM_STYLE_DUNMER"],
                texture = "EsoUI/Art/CharacterCreate/characterCreate_dunmerIcon_%s.dds",
                value = ITEMSTYLE_RACIAL_DARK_ELF,
            },
            {
                label = L["SUBFILTER_ITEM_STYLE_NORD"],
                texture = "EsoUI/Art/CharacterCreate/characterCreate_nordIcon_%s.dds",
                value = ITEMSTYLE_RACIAL_NORD,
            },
            {
                label = L["SUBFILTER_ITEM_STYLE_ARGONIAN"],
                texture = "EsoUI/Art/CharacterCreate/characterCreate_argonianIcon_%s.dds",
                value = ITEMSTYLE_RACIAL_ARGONIAN,
            },
            {
                label = L["SUBFILTER_ITEM_STYLE_ALTMER"],
                texture = "EsoUI/Art/CharacterCreate/characterCreate_altmerIcon_%s.dds",
                value = ITEMSTYLE_RACIAL_HIGH_ELF,
            },
            {
                label = L["SUBFILTER_ITEM_STYLE_BOSMER"],
                texture = "EsoUI/Art/CharacterCreate/characterCreate_bosmerIcon_%s.dds",
                value = ITEMSTYLE_RACIAL_WOOD_ELF,
            },
            {
                label = L["SUBFILTER_ITEM_STYLE_KHAJIIT"],
                texture = "EsoUI/Art/CharacterCreate/characterCreate_khajiitIcon_%s.dds",
                value = ITEMSTYLE_RACIAL_KHAJIIT,
            },
            {
                label = L["SUBFILTER_ITEM_STYLE_IMPERIAL"],
                texture = "EsoUI/Art/CharacterCreate/characterCreate_imperialIcon_%s.dds",
                value = ITEMSTYLE_RACIAL_IMPERIAL,
            },
            {
                label = L["SUBFILTER_ITEM_STYLE_ANCIENT_ELF"],
                texture = "EsoUI/Art/Icons/progression_tabIcon_magma_%s.dds",
                value = ITEMSTYLE_AREA_ANCIENT_ELF,
            },
            {
                label = L["SUBFILTER_ITEM_STYLE_PRIMAL"],
                texture = "EsoUI/Art/Icons/progression_tabicon_flames_%s.dds",
                value = ITEMSTYLE_ENEMY_PRIMITIVE,
            },
            {
                label = L["SUBFILTER_ITEM_STYLE_BARBARIC"],
                texture = "EsoUI/Art/Icons/progression_tabicon_avasiege_%s.dds",
                value = ITEMSTYLE_AREA_REACH,
            },
            {
                label = L["SUBFILTER_ITEM_STYLE_DAEDRIC"],
                texture = "EsoUI/Art/Icons/progression_tabIcon_daedricConjuration_%s.dds",
                value = ITEMSTYLE_ENEMY_DAEDRIC,
            },
            {
                label = L["SUBFILTER_ITEM_STYLE_DWEMER"],
                texture = "AwesomeGuildStore/images/style/dwemer_%s.dds",
                value = ITEMSTYLE_AREA_DWEMER,
            },
            {
                label = L["SUBFILTER_ITEM_STYLE_GLASS"],
                texture = "EsoUI/Art/Icons/progression_tabIcon_sunMagic_%s.dds",
                value = ITEMSTYLE_GLASS,
            },
            {
                label = L["SUBFILTER_ITEM_STYLE_XIVKYN"],
                texture = "EsoUI/Art/Icons/progression_tabicon_darkmagic_%s.dds",
                value = ITEMSTYLE_AREA_XIVKYN,
            },
            {
                label = L["SUBFILTER_ITEM_STYLE_DAGGERFALL"],
                texture = "AwesomeGuildStore/images/style/daggerfall_%s.dds",
                value = ITEMSTYLE_ALLIANCE_DAGGERFALL,
            },
            {
                label = L["SUBFILTER_ITEM_STYLE_EBONHEART"],
                texture = "AwesomeGuildStore/images/style/ebonheart_%s.dds",
                value = ITEMSTYLE_ALLIANCE_EBONHEART,
            },
            {
                label = L["SUBFILTER_ITEM_STYLE_ALDMERI"],
                texture = "AwesomeGuildStore/images/style/aldmeri_%s.dds",
                value = ITEMSTYLE_ALLIANCE_ALDMERI,
            },
            {
                label = L["SUBFILTER_ITEM_STYLE_AKAVIRI"],
                texture = "EsoUI/Art/Campaign/overview_indexIcon_emperor_%s.dds",
                value = ITEMSTYLE_AREA_AKAVIRI,
            },
            {
                label = L["SUBFILTER_ITEM_STYLE_MERCENARY"],
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_armor_%s.dds",
                value = ITEMSTYLE_UNDAUNTED,
            },
            {
                label = L["SUBFILTER_ITEM_STYLE_ANCIENT_ORC"],
                texture = "EsoUI/Art/WorldMap/map_ava_tabIcon_oreMine_%s.dds",
                value = ITEMSTYLE_AREA_ANCIENT_ORC,
            },
            {
                label = L["SUBFILTER_ITEM_STYLE_MALACATH"],
                texture = "EsoUI/Art/Guild/guildHistory_indexIcon_combat_%s.dds",
                value = ITEMSTYLE_DEITY_MALACATH,
            },
            {
                label = L["SUBFILTER_ITEM_STYLE_TRINIMAC"],
                texture = "EsoUI/Art/Guild/guildHistory_indexIcon_campaigns_%s.dds",
                value = ITEMSTYLE_DEITY_TRINIMAC,
            },
            {
                label = L["SUBFILTER_ITEM_STYLE_SOUL_SHRIVEN"],
                texture = "EsoUI/Art/MainMenu/menuBar_collections_%s.dds",
                value = ITEMSTYLE_AREA_SOUL_SHRIVEN,
            },
            {
                label = L["SUBFILTER_ITEM_STYLE_OUTLAW"],
                texture = "EsoUI/Art/Vendor/vendor_tabicon_fence_%s.dds",
                value = ITEMSTYLE_ORG_OUTLAW,
            },
            {
                label = L["SUBFILTER_ITEM_STYLE_ABAHS_WATCH"],
                texture = "EsoUI/Art/Campaign/campaign_tabicon_browser_%s.dds",
                value = ITEMSTYLE_ORG_ABAHS_WATCH,
            },
            {
                label = L["SUBFILTER_ITEM_STYLE_THIEVES_GUILD"],
                texture = "EsoUI/Art/TreeIcons/tutorial_idexicon_thievesguild_%s.dds",
                value = ITEMSTYLE_ORG_THIEVES_GUILD,
            },
            {
                label = L["SUBFILTER_ITEM_STYLE_ASSASSINS"],
                texture = "EsoUI/Art/Campaign/overview_indexicon_scoring_%s.dds",
                value = ITEMSTYLE_ORG_ASSASSINS,
            },
            {
                label = L["SUBFILTER_ITEM_STYLE_DROMOTHRA"],
                texture = "EsoUI/Art/Cadwell/cadwell_indexIcon_silver_%s.dds",
                value = ITEMSTYLE_ENEMY_DROMOTHRA,
            },
            {
                label = L["SUBFILTER_ITEM_STYLE_HOUR"],
                texture = "EsoUI/Art/Icons/GuildRanks/guild_indexicon_misc08_%s.dds",
                value = ITEMSTYLE_DEITY_AKATOSH,
            },
            {
                label = L["SUBFILTER_ITEM_STYLE_DARK_BROTHERHOOD"],
                texture = "EsoUI/Art/TreeIcons/tutorial_idexicon_darkbrotherhood_%s.dds",
                value = ITEMSTYLE_ORG_DARK_BROTHERHOOD,
            },
            {
                label = L["SUBFILTER_ITEM_STYLE_MINOTAUR"],
                texture = "EsoUI/Art/Icons/progression_tabIcon_armorHeavy_%s.dds",
                value = ITEMSTYLE_ENEMY_MINOTAUR,
            },
            {
                label = L["SUBFILTER_ITEM_STYLE_OTHER"],
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_misc_%s.dds",
                value = 99,
            },
        },
    },
    [SUBFILTER_ITEM_SET] = {
        type = 43,
        label = L["SUBFILTER_ITEM_SET_LABEL"],
        class = "ItemSetFilter",
        filter = 43,
        singleButtonMode = true,
        buttons = {
            {
                label = L["SUBFILTER_ITEM_SET_NORMAL"],
                texture = "EsoUI/Art/TreeIcons/achievements_indexIcon_collections_%s.dds",
                value = 1,
            },
            {
                label = L["SUBFILTER_ITEM_SET_HAS_SET"],
                texture = "EsoUI/Art/Campaign/campaign_tabIcon_summary_%s.dds",
                value = 2,
            },
        },
    },
    [SUBFILTER_CRAFTING] = {
        type = 44,
        label = L["SUBFILTER_CRAFTING_LABEL"],
        class = "CraftedItemFilter",
        filter = 44,
        singleButtonMode = true,
        buttons = {
            {
                label = L["SUBFILTER_CRAFTING_IS_CRAFTED"],
                texture = "Esoui/Art/TreeIcons/achievements_indexIcon_crafting_%s.dds",
                value = 1,
            },
            {
                label = L["SUBFILTER_CRAFTING_IS_LOOT"],
                texture = "Esoui/Art/Progression/progression_indexIcon_class_%s.dds",
                value = 2,
            },
        },
    },
    [SUBFILTER_RECIPE_IMPROVEMENT] = {
        type = 45,
        label = L["SUBFILTER_RECIPE_IMPROVEMENT_LABEL"],
        class = "RecipeImprovementFilter",
        filter = 45,
    },
    [SUBFILTER_RECIPE_TYPE] = {
        type = 46,
        label = L["SUBFILTER_RECIPE_TYPE_LABEL"],
        filter = TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM,
        buttons = {
            {
                label = L["SUBFILTER_RECIPE_TYPE_FOOD"],
                texture = "EsoUI/Art/Crafting/provisioner_indexIcon_meat_%s.dds",
                value = SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD,
            },
            {
                label = L["SUBFILTER_RECIPE_TYPE_DRINK"],
                texture = "EsoUI/Art/Crafting/provisioner_indexIcon_beer_%s.dds",
                value = SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK,
            },
            {
                label = L["SUBFILTER_RECIPE_TYPE_BLACKSMITHING"],
                texture = "EsoUI/Art/Crafting/diagrams_tabicon_%s.dds",
                value = SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING,
            },
            {
                label = L["SUBFILTER_RECIPE_TYPE_CLOTHIER"],
                texture = "EsoUI/Art/Crafting/patterns_tabicon_%s.dds",
                value = SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING,
            },
            {
                label = L["SUBFILTER_RECIPE_TYPE_WOODWORKING"],
                texture = "EsoUI/Art/Crafting/blueprints_tabicon_%s.dds",
                value = SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING,
            },
            {
                label = L["SUBFILTER_RECIPE_TYPE_ALCHEMY"],
                texture = "EsoUI/Art/Crafting/formulae_tabicon_%s.dds",
                value = SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING,
            },
            {
                label = L["SUBFILTER_RECIPE_TYPE_ENCHANTING"],
                texture = "EsoUI/Art/Crafting/schematics_tabicon_%s.dds",
                value = SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING,
            },
            {
                label = L["SUBFILTER_RECIPE_TYPE_PROVISIONING"],
                texture = "EsoUI/Art/Crafting/designs_tabicon_%s.dds",
                value = SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING,
            },
        },
    },
    [SUBFILTER_DRINK_TYPE] = {
        type = 47,
        label = L["SUBFILTER_DRINK_TYPE_LABEL"],
        filter = TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM,
        buttons = {
            {
                label = L["SUBFILTER_DRINK_TYPE_ALCOHOLIC"],
                texture = "EsoUI/Art/Crafting/provisioner_indexIcon_meat_%s.dds",
                value = SPECIALIZED_ITEMTYPE_DRINK_ALCOHOLIC,
            },
            {
                label = L["SUBFILTER_DRINK_TYPE_CORDIAL_TEA"],
                texture = "EsoUI/Art/Crafting/provisioner_indexIcon_beer_%s.dds",
                value = SPECIALIZED_ITEMTYPE_DRINK_CORDIAL_TEA,
            },
            {
                label = L["SUBFILTER_DRINK_TYPE_DISTILLATE"],
                texture = "EsoUI/Art/Crafting/diagrams_tabicon_%s.dds",
                value = SPECIALIZED_ITEMTYPE_DRINK_DISTILLATE,
            },
            {
                label = L["SUBFILTER_DRINK_TYPE_LIQUER"],
                texture = "EsoUI/Art/Crafting/patterns_tabicon_%s.dds",
                value = SPECIALIZED_ITEMTYPE_DRINK_LIQUEUR,
            },
            {
                label = L["SUBFILTER_DRINK_TYPE_TEA"],
                texture = "EsoUI/Art/Crafting/blueprints_tabicon_%s.dds",
                value = SPECIALIZED_ITEMTYPE_DRINK_TEA,
            },
            {
                label = L["SUBFILTER_DRINK_TYPE_TINCTURE"],
                texture = "EsoUI/Art/Crafting/formulae_tabicon_%s.dds",
                value = SPECIALIZED_ITEMTYPE_DRINK_TINCTURE,
            },
            {
                label = L["SUBFILTER_DRINK_TYPE_TONIC"],
                texture = "EsoUI/Art/Crafting/schematics_tabicon_%s.dds",
                value = SPECIALIZED_ITEMTYPE_DRINK_TONIC,
            },
            {
                label = L["SUBFILTER_DRINK_TYPE_UNIQUE"],
                texture = "EsoUI/Art/Crafting/designs_tabicon_%s.dds",
                value = SPECIALIZED_ITEMTYPE_DRINK_UNIQUE,
            },
        },
    },
    [SUBFILTER_FOOD_TYPE] = {
        type = 48,
        label = L["SUBFILTER_FOOD_TYPE_LABEL"],
        filter = TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM,
        buttons = {
            {
                label = L["SUBFILTER_FOOD_TYPE_ENTREMET"],
                texture = "AwesomeGuildStore/images/consumable/entremet_%s.dds",
                value = SPECIALIZED_ITEMTYPE_FOOD_ENTREMET,
            },
            {
                label = L["SUBFILTER_FOOD_TYPE_FRUIT"],
                texture = "AwesomeGuildStore/images/consumable/fruit_dish_%s.dds",
                value = SPECIALIZED_ITEMTYPE_FOOD_FRUIT,
            },
            {
                label = L["SUBFILTER_FOOD_TYPE_GOURMET"],
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_craftbag_provisioning_%s.dds",
                value = SPECIALIZED_ITEMTYPE_FOOD_GOURMET,
            },
            {
                label = L["SUBFILTER_FOOD_TYPE_MEAT"],
                texture = "EsoUI/Art/treeicons/provisioner_indexicon_meat_%s.dds",
                value = SPECIALIZED_ITEMTYPE_FOOD_MEAT,
            },
            {
                label = L["SUBFILTER_FOOD_TYPE_RAGOUT"],
                texture = "EsoUI/Art/treeicons/provisioner_indexicon_stew_%s.dds",
                value = SPECIALIZED_ITEMTYPE_FOOD_RAGOUT,
            },
            {
                label = L["SUBFILTER_FOOD_TYPE_SAVOURY"],
                texture = "EsoUI/Art/treeicons/provisioner_indexicon_baked_%s.dds",
                value = SPECIALIZED_ITEMTYPE_FOOD_SAVOURY,
            },
            {
                label = L["SUBFILTER_FOOD_TYPE_VEGETABLE"],
                texture = "EsoUI/Art/worldmap/map_ava_tabicon_foodfarm_%s.dds",
                value = SPECIALIZED_ITEMTYPE_FOOD_VEGETABLE,
            },
            {
                label = L["SUBFILTER_FOOD_TYPE_UNIQUE"],
                texture = "AwesomeGuildStore/images/consumable/unique_dish_%s.dds",
                value = SPECIALIZED_ITEMTYPE_FOOD_UNIQUE,
            },
        },
    },
    [SUBFILTER_INGREDIENT_TYPE] = {
        type = 49,
        label = L["SUBFILTER_INGREDIENT_TYPE_LABEL"],
        filter = TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM,
        buttons = {
            {
                label = L["SUBFILTER_INGREDIENT_TYPE_ALCOHOL"],
                texture = "EsoUI/Art/Crafting/provisioner_indexIcon_meat_%s.dds",
                value = SPECIALIZED_ITEMTYPE_INGREDIENT_ALCOHOL,
            },
            {
                label = L["SUBFILTER_INGREDIENT_TYPE_DRINK_ADDITIVE"],
                texture = "EsoUI/Art/Crafting/provisioner_indexIcon_beer_%s.dds",
                value = SPECIALIZED_ITEMTYPE_INGREDIENT_DRINK_ADDITIVE,
            },
            {
                label = L["SUBFILTER_INGREDIENT_TYPE_FOOD_ADDITIVE"],
                texture = "EsoUI/Art/Crafting/diagrams_tabicon_%s.dds",
                value = SPECIALIZED_ITEMTYPE_INGREDIENT_FOOD_ADDITIVE,
            },
            {
                label = L["SUBFILTER_INGREDIENT_TYPE_FRUIT"],
                texture = "EsoUI/Art/Crafting/patterns_tabicon_%s.dds",
                value = SPECIALIZED_ITEMTYPE_INGREDIENT_FRUIT,
            },
            {
                label = L["SUBFILTER_INGREDIENT_TYPE_MEAT"],
                texture = "EsoUI/Art/Crafting/blueprints_tabicon_%s.dds",
                value = SPECIALIZED_ITEMTYPE_INGREDIENT_MEAT,
            },
            {
                label = L["SUBFILTER_INGREDIENT_TYPE_RARE"],
                texture = "EsoUI/Art/Crafting/formulae_tabicon_%s.dds",
                value = SPECIALIZED_ITEMTYPE_INGREDIENT_RARE,
            },
            {
                label = L["SUBFILTER_INGREDIENT_TYPE_TEA"],
                texture = "EsoUI/Art/Crafting/schematics_tabicon_%s.dds",
                value = SPECIALIZED_ITEMTYPE_INGREDIENT_TEA,
            },
            {
                label = L["SUBFILTER_INGREDIENT_TYPE_TONIC"],
                texture = "EsoUI/Art/Crafting/designs_tabicon_%s.dds",
                value = SPECIALIZED_ITEMTYPE_INGREDIENT_TONIC,
            },
            {
                label = L["SUBFILTER_INGREDIENT_TYPE_VEGETABLE"],
                texture = "EsoUI/Art/Crafting/designs_tabicon_%s.dds",
                value = SPECIALIZED_ITEMTYPE_INGREDIENT_VEGETABLE,
            },
        },
    },
    [SUBFILTER_SIEGE_TYPE] = {
        type = 50,
        label = L["SUBFILTER_SIEGE_TYPE_LABEL"],
        filter = TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM,
        buttons = {
            {
                label = L["SUBFILTER_SIEGE_TYPE_BALLISTA"],
                texture = "EsoUI/Art/Crafting/provisioner_indexIcon_meat_%s.dds",
                value = SPECIALIZED_ITEMTYPE_SIEGE_BALLISTA,
            },
            {
                label = L["SUBFILTER_SIEGE_TYPE_CATAPULT"],
                texture = "EsoUI/Art/Crafting/provisioner_indexIcon_beer_%s.dds",
                value = SPECIALIZED_ITEMTYPE_SIEGE_CATAPULT,
            },
            {
                label = L["SUBFILTER_SIEGE_TYPE_TREBUCHET"],
                texture = "EsoUI/Art/Crafting/diagrams_tabicon_%s.dds",
                value = SPECIALIZED_ITEMTYPE_SIEGE_TREBUCHET,
            },
            {
                label = L["SUBFILTER_SIEGE_TYPE_OIL"],
                texture = "EsoUI/Art/Crafting/patterns_tabicon_%s.dds",
                value = SPECIALIZED_ITEMTYPE_SIEGE_OIL,
            },
            {
                label = L["SUBFILTER_SIEGE_TYPE_RAM"],
                texture = "EsoUI/Art/Crafting/blueprints_tabicon_%s.dds",
                value = SPECIALIZED_ITEMTYPE_SIEGE_RAM,
            },
            {
                label = L["SUBFILTER_SIEGE_TYPE_GRAVEYARD"],
                texture = "EsoUI/Art/Crafting/formulae_tabicon_%s.dds",
                value = SPECIALIZED_ITEMTYPE_SIEGE_GRAVEYARD,
            },
            {
                label = L["SUBFILTER_SIEGE_TYPE_UNIVERSAL"],
                texture = "EsoUI/Art/Crafting/schematics_tabicon_%s.dds",
                value = SPECIALIZED_ITEMTYPE_SIEGE_UNIVERSAL, -- TODO see what this is and remove if it doesn't exist
            },
        },
    },
    [SUBFILTER_TROPHY_TYPE] = {
        type = 51,
        label = L["SUBFILTER_TROPHY_TYPE_LABEL"],
        filter = TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM,
        buttons = {
            {
                label = L["SUBFILTER_TROPHY_TYPE_KEY_FRAGMENT"],
                texture = "EsoUI/Art/worldmap/map_indexicon_key_%s.dds",
                value = SPECIALIZED_ITEMTYPE_TROPHY_KEY_FRAGMENT,
            },
            {
                label = L["SUBFILTER_TROPHY_TYPE_MUSEUM_PIECE"],
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_craftbag_stylematerial_%s.dds",
                value = SPECIALIZED_ITEMTYPE_TROPHY_MUSEUM_PIECE,
            },
            {
                label = L["SUBFILTER_TROPHY_TYPE_RECIPE_FRAGMENT"],
                texture = "EsoUI/Art/Guild/tabIcon_roster_%s.dds",
                value = SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT,
            },
            {
                label = L["SUBFILTER_TROPHY_TYPE_TREASURE_MAP"],
                texture = "EsoUI/Art/icons/achievements_indexicon_exploration_%s.dds",
                value = SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP,
            },
        },
    }
}