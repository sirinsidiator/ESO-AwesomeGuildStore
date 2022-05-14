local AGS = AwesomeGuildStore

local FilterBase = AGS.class.FilterBase

local FILTER_ID = AGS.data.FILTER_ID
local CATEGORY_ID = AGS.data.CATEGORY_ID
local SUB_CATEGORY_ID = AGS.data.SUB_CATEGORY_ID
local CATEGORY_DEFINITION = AGS.data.CATEGORY_DEFINITION
local SUB_CATEGORY_DEFINITION = AGS.data.SUB_CATEGORY_DEFINITION
local DEFAULT_CATEGORY_ID = AGS.data.DEFAULT_CATEGORY_ID
local DEFAULT_SUB_CATEGORY_ID = AGS.data.DEFAULT_SUB_CATEGORY_ID

local gettext = AGS.internal.gettext
local logger = AGS.internal.logger
local EncodeValue = AGS.internal.EncodeValue
local DecodeValue = AGS.internal.DecodeValue

local ITEMFILTERTYPE_LOCAL = "itemFilterType"
local filterDefinition = {
    [SUB_CATEGORY_ID.ALL] = {},
    [SUB_CATEGORY_ID.WEAPONS_ALL] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_EQUIP,
            allowed = {
                [EQUIP_TYPE_ONE_HAND] = true,
                [EQUIP_TYPE_TWO_HAND] = true,
            }
        },
        {
            type = TRADING_HOUSE_FILTER_TYPE_GAMEPLAY_ACTOR_CATEGORY,
            allowed = {
                [GAMEPLAY_ACTOR_CATEGORY_PLAYER] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.WEAPONS_ONE_HANDED] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_EQUIP,
            allowed = {
                [EQUIP_TYPE_ONE_HAND] = true,
            }
        },
        {
            type = TRADING_HOUSE_FILTER_TYPE_GAMEPLAY_ACTOR_CATEGORY,
            allowed = {
                [GAMEPLAY_ACTOR_CATEGORY_PLAYER] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.WEAPONS_TWO_HANDED] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_WEAPON,
            allowed = {
                [WEAPONTYPE_TWO_HANDED_AXE] = true,
                [WEAPONTYPE_TWO_HANDED_SWORD] = true,
                [WEAPONTYPE_TWO_HANDED_HAMMER] = true,
            }
        },
        {
            type = TRADING_HOUSE_FILTER_TYPE_GAMEPLAY_ACTOR_CATEGORY,
            allowed = {
                [GAMEPLAY_ACTOR_CATEGORY_PLAYER] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.WEAPONS_BOW] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_WEAPON,
            allowed = {
                [WEAPONTYPE_BOW] = true,
            }
        },
        {
            type = TRADING_HOUSE_FILTER_TYPE_GAMEPLAY_ACTOR_CATEGORY,
            allowed = {
                [GAMEPLAY_ACTOR_CATEGORY_PLAYER] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.WEAPONS_DESTRUCTION_STAFF] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_WEAPON,
            allowed = {
                [WEAPONTYPE_FIRE_STAFF] = true,
                [WEAPONTYPE_FROST_STAFF] = true,
                [WEAPONTYPE_LIGHTNING_STAFF] = true,
            }
        },
        {
            type = TRADING_HOUSE_FILTER_TYPE_GAMEPLAY_ACTOR_CATEGORY,
            allowed = {
                [GAMEPLAY_ACTOR_CATEGORY_PLAYER] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.WEAPONS_RESTORATION_STAFF] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_WEAPON,
            allowed = {
                [WEAPONTYPE_HEALING_STAFF] = true,
            }
        },
        {
            type = TRADING_HOUSE_FILTER_TYPE_GAMEPLAY_ACTOR_CATEGORY,
            allowed = {
                [GAMEPLAY_ACTOR_CATEGORY_PLAYER] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.ARMOR_ALL] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM,
            allowed = {
                [SPECIALIZED_ITEMTYPE_WEAPON] = true,
                [SPECIALIZED_ITEMTYPE_ARMOR] = true,
            }
        },
        {
            type = TRADING_HOUSE_FILTER_TYPE_EQUIP,
            allowed = {
                [EQUIP_TYPE_HEAD] = true,
                [EQUIP_TYPE_CHEST] = true,
                [EQUIP_TYPE_SHOULDERS] = true,
                [EQUIP_TYPE_WAIST] = true,
                [EQUIP_TYPE_LEGS] = true,
                [EQUIP_TYPE_FEET] = true,
                [EQUIP_TYPE_HAND] = true,
                [EQUIP_TYPE_OFF_HAND] = true,
            }
        },
        {
            type = TRADING_HOUSE_FILTER_TYPE_GAMEPLAY_ACTOR_CATEGORY,
            allowed = {
                [GAMEPLAY_ACTOR_CATEGORY_PLAYER] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.ARMOR_HEAVY] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_ARMOR,
            allowed = {
                [ARMORTYPE_HEAVY] = true,
            }
        },
        {
            type = TRADING_HOUSE_FILTER_TYPE_EQUIP,
            allowed = {
                [EQUIP_TYPE_HEAD] = true,
                [EQUIP_TYPE_CHEST] = true,
                [EQUIP_TYPE_SHOULDERS] = true,
                [EQUIP_TYPE_WAIST] = true,
                [EQUIP_TYPE_LEGS] = true,
                [EQUIP_TYPE_FEET] = true,
                [EQUIP_TYPE_HAND] = true,
            }
        },
        {
            type = TRADING_HOUSE_FILTER_TYPE_GAMEPLAY_ACTOR_CATEGORY,
            allowed = {
                [GAMEPLAY_ACTOR_CATEGORY_PLAYER] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.ARMOR_MEDIUM] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_ARMOR,
            allowed = {
                [ARMORTYPE_MEDIUM] = true,
            }
        },
        {
            type = TRADING_HOUSE_FILTER_TYPE_EQUIP,
            allowed = {
                [EQUIP_TYPE_HEAD] = true,
                [EQUIP_TYPE_CHEST] = true,
                [EQUIP_TYPE_SHOULDERS] = true,
                [EQUIP_TYPE_WAIST] = true,
                [EQUIP_TYPE_LEGS] = true,
                [EQUIP_TYPE_FEET] = true,
                [EQUIP_TYPE_HAND] = true,
            }
        },
        {
            type = TRADING_HOUSE_FILTER_TYPE_GAMEPLAY_ACTOR_CATEGORY,
            allowed = {
                [GAMEPLAY_ACTOR_CATEGORY_PLAYER] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.ARMOR_LIGHT] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_ARMOR,
            allowed = {
                [ARMORTYPE_LIGHT] = true,
            }
        },
        {
            type = TRADING_HOUSE_FILTER_TYPE_EQUIP,
            allowed = {
                [EQUIP_TYPE_HEAD] = true,
                [EQUIP_TYPE_CHEST] = true,
                [EQUIP_TYPE_SHOULDERS] = true,
                [EQUIP_TYPE_LEGS] = true,
                [EQUIP_TYPE_WAIST] = true,
                [EQUIP_TYPE_FEET] = true,
                [EQUIP_TYPE_HAND] = true,
            }
        },
        {
            type = TRADING_HOUSE_FILTER_TYPE_GAMEPLAY_ACTOR_CATEGORY,
            allowed = {
                [GAMEPLAY_ACTOR_CATEGORY_PLAYER] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.ARMOR_SHIELD] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_WEAPON,
            allowed = {
                [WEAPONTYPE_SHIELD] = true,
            }
        },
        {
            type = TRADING_HOUSE_FILTER_TYPE_GAMEPLAY_ACTOR_CATEGORY,
            allowed = {
                [GAMEPLAY_ACTOR_CATEGORY_PLAYER] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.JEWELRY_ALL] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_EQUIP,
            allowed = {
                [EQUIP_TYPE_RING] = true,
                [EQUIP_TYPE_NECK] = true,
            }
        },
        {
            type = TRADING_HOUSE_FILTER_TYPE_GAMEPLAY_ACTOR_CATEGORY,
            allowed = {
                [GAMEPLAY_ACTOR_CATEGORY_PLAYER] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.JEWELRY_RING] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_EQUIP,
            allowed = {
                [EQUIP_TYPE_RING] = true,
            }
        },
        {
            type = TRADING_HOUSE_FILTER_TYPE_GAMEPLAY_ACTOR_CATEGORY,
            allowed = {
                [GAMEPLAY_ACTOR_CATEGORY_PLAYER] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.JEWELRY_NECK] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_EQUIP,
            allowed = {
                [EQUIP_TYPE_NECK] = true,
            }
        },
        {
            type = TRADING_HOUSE_FILTER_TYPE_GAMEPLAY_ACTOR_CATEGORY,
            allowed = {
                [GAMEPLAY_ACTOR_CATEGORY_PLAYER] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.CONSUMABLE_ALL] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_ITEM,
            allowed = {
                [ITEMTYPE_FOOD] = true,
                [ITEMTYPE_DRINK] = true,
                [ITEMTYPE_RECIPE] = true,
                [ITEMTYPE_POTION] = true,
                [ITEMTYPE_POISON] = true,
                [ITEMTYPE_MASTER_WRIT] = true,
                [ITEMTYPE_RACIAL_STYLE_MOTIF] = true,
                [ITEMTYPE_CONTAINER] = true,
                [ITEMTYPE_AVA_REPAIR] = true,
                [ITEMTYPE_TOOL] = true,
                [ITEMTYPE_COLLECTIBLE] = true,
                [ITEMTYPE_FISH] = true,
                [ITEMTYPE_TREASURE] = true,
                [ITEMTYPE_TROPHY] = true,
                [ITEMTYPE_TRASH] = true,
            }
        },
        {
            type = ITEMFILTERTYPE_LOCAL,
            allowed = {
                [ITEMFILTERTYPE_CONSUMABLE] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.CONSUMABLE_FOOD] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_ITEM,
            allowed = {
                [ITEMTYPE_FOOD] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.CONSUMABLE_DRINK] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_ITEM,
            allowed = {
                [ITEMTYPE_DRINK] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.CONSUMABLE_RECIPE] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_ITEM,
            allowed = {
                [ITEMTYPE_RECIPE] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.CONSUMABLE_POTION] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_ITEM,
            allowed = {
                [ITEMTYPE_POTION] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.CONSUMABLE_POISON] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_ITEM,
            allowed = {
                [ITEMTYPE_POISON] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.CONSUMABLE_WRIT] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_ITEM,
            allowed = {
                [ITEMTYPE_MASTER_WRIT] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.CONSUMABLE_MOTIF] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_ITEM,
            allowed = {
                [ITEMTYPE_RACIAL_STYLE_MOTIF] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.CONSUMABLE_CONTAINER] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_ITEM,
            allowed = {
                [ITEMTYPE_CONTAINER] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.CONSUMABLE_TOOL] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_ITEM,
            allowed = {
                [ITEMTYPE_AVA_REPAIR] = true,
                [ITEMTYPE_TOOL] = true,
            }
        },
        {
            type = ITEMFILTERTYPE_LOCAL,
            allowed = {
                [ITEMFILTERTYPE_CONSUMABLE] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.CONSUMABLE_TROPHY] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_ITEM,
            allowed = {
                [ITEMTYPE_COLLECTIBLE] = true,
                [ITEMTYPE_FISH] = true,
                [ITEMTYPE_TREASURE] = true,
                [ITEMTYPE_TROPHY] = true,
                [ITEMTYPE_TRASH] = true,
            }
        },
        {
            type = ITEMFILTERTYPE_LOCAL,
            allowed = {
                [ITEMFILTERTYPE_CONSUMABLE] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.CRAFTING_ALL] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_ITEM,
            allowed = {
                [ITEMTYPE_BLACKSMITHING_RAW_MATERIAL] = true,
                [ITEMTYPE_BLACKSMITHING_MATERIAL] = true,
                [ITEMTYPE_BLACKSMITHING_BOOSTER] = true,
                [ITEMTYPE_CLOTHIER_RAW_MATERIAL] = true,
                [ITEMTYPE_CLOTHIER_MATERIAL] = true,
                [ITEMTYPE_CLOTHIER_BOOSTER] = true,
                [ITEMTYPE_WOODWORKING_RAW_MATERIAL] = true,
                [ITEMTYPE_WOODWORKING_MATERIAL] = true,
                [ITEMTYPE_WOODWORKING_BOOSTER] = true,
                [ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL] = true,
                [ITEMTYPE_JEWELRYCRAFTING_MATERIAL] = true,
                [ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER] = true,
                [ITEMTYPE_JEWELRYCRAFTING_BOOSTER] = true,
                [ITEMTYPE_POTION_BASE] = true,
                [ITEMTYPE_POISON_BASE] = true,
                [ITEMTYPE_REAGENT] = true,
                [ITEMTYPE_ENCHANTING_RUNE_ASPECT] = true,
                [ITEMTYPE_ENCHANTING_RUNE_ESSENCE] = true,
                [ITEMTYPE_ENCHANTING_RUNE_POTENCY] = true,
                [ITEMTYPE_INGREDIENT] = true,
                [ITEMTYPE_STYLE_MATERIAL] = true,
                [ITEMTYPE_RAW_MATERIAL] = true,
                [ITEMTYPE_WEAPON_TRAIT] = true,
                [ITEMTYPE_ARMOR_TRAIT] = true,
                [ITEMTYPE_JEWELRY_TRAIT] = true,
                [ITEMTYPE_JEWELRY_RAW_TRAIT] = true,
                [ITEMTYPE_FURNISHING_MATERIAL] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.CRAFTING_BLACKSMITHING] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_ITEM,
            allowed = {
                [ITEMTYPE_BLACKSMITHING_RAW_MATERIAL] = true,
                [ITEMTYPE_BLACKSMITHING_MATERIAL] = true,
                [ITEMTYPE_BLACKSMITHING_BOOSTER] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.CRAFTING_CLOTHIER] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_ITEM,
            allowed = {
                [ITEMTYPE_CLOTHIER_RAW_MATERIAL] = true,
                [ITEMTYPE_CLOTHIER_MATERIAL] = true,
                [ITEMTYPE_CLOTHIER_BOOSTER] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.CRAFTING_WOODWORKING] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_ITEM,
            allowed = {
                [ITEMTYPE_WOODWORKING_RAW_MATERIAL] = true,
                [ITEMTYPE_WOODWORKING_MATERIAL] = true,
                [ITEMTYPE_WOODWORKING_BOOSTER] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.CRAFTING_JEWELRY] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_ITEM,
            allowed = {
                [ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL] = true,
                [ITEMTYPE_JEWELRYCRAFTING_MATERIAL] = true,
                [ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER] = true,
                [ITEMTYPE_JEWELRYCRAFTING_BOOSTER] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.CRAFTING_ALCHEMY] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_ITEM,
            allowed = {
                [ITEMTYPE_POTION_BASE] = true,
                [ITEMTYPE_POISON_BASE] = true,
                [ITEMTYPE_REAGENT] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.CRAFTING_ENCHANTING] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_ITEM,
            allowed = {
                [ITEMTYPE_ENCHANTING_RUNE_ASPECT] = true,
                [ITEMTYPE_ENCHANTING_RUNE_ESSENCE] = true,
                [ITEMTYPE_ENCHANTING_RUNE_POTENCY] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.CRAFTING_PROVISIONING] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_ITEM,
            allowed = {
                [ITEMTYPE_INGREDIENT] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.CRAFTING_STYLE_MATERIAL] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_ITEM,
            allowed = {
                [ITEMTYPE_STYLE_MATERIAL] = true,
                [ITEMTYPE_RAW_MATERIAL] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.CRAFTING_TRAIT_MATERIAL] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_ITEM,
            allowed = {
                [ITEMTYPE_WEAPON_TRAIT] = true,
                [ITEMTYPE_ARMOR_TRAIT] = true,
                [ITEMTYPE_JEWELRY_TRAIT] = true,
                [ITEMTYPE_JEWELRY_RAW_TRAIT] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.CRAFTING_FURNISHING_MATERIAL] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_ITEM,
            allowed = {
                [ITEMTYPE_FURNISHING_MATERIAL] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.FURNISHING_ALL] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_ITEM,
            allowed = {
                [ITEMTYPE_FURNISHING] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.FURNISHING_CRAFTING_STATION] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM,
            allowed = {
                [SPECIALIZED_ITEMTYPE_FURNISHING_CRAFTING_STATION] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.FURNISHING_LIGHT] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM,
            allowed = {
                [SPECIALIZED_ITEMTYPE_FURNISHING_LIGHT] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.FURNISHING_ORNAMENTAL] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM,
            allowed = {
                [SPECIALIZED_ITEMTYPE_FURNISHING_ORNAMENTAL] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.FURNISHING_SEATING] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM,
            allowed = {
                [SPECIALIZED_ITEMTYPE_FURNISHING_SEATING] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.FURNISHING_TARGET_DUMMY] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM,
            allowed = {
                [SPECIALIZED_ITEMTYPE_FURNISHING_TARGET_DUMMY] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.MISCELLANEOUS_ALL] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM,
            allowed = {
                [SPECIALIZED_ITEMTYPE_NONE] = true,
                [SPECIALIZED_ITEMTYPE_COLLECTIBLE_RARE_FISH] = true,
                [SPECIALIZED_ITEMTYPE_COLLECTIBLE_MONSTER_TROPHY] = true,
                [SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP] = true,
                [SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT] = true,
                [SPECIALIZED_ITEMTYPE_TROPHY_KEY_FRAGMENT] = true,
                [SPECIALIZED_ITEMTYPE_TROPHY_MUSEUM_PIECE] = true,
                [SPECIALIZED_ITEMTYPE_TROPHY_SCROLL] = true,
                [SPECIALIZED_ITEMTYPE_TROPHY_KEY] = true,
                [SPECIALIZED_ITEMTYPE_TROPHY_DUNGEON_BUFF_INGREDIENT] = true,
                [SPECIALIZED_ITEMTYPE_SIEGE_TREBUCHET] = true,
                [SPECIALIZED_ITEMTYPE_SIEGE_BALLISTA] = true,
                [SPECIALIZED_ITEMTYPE_SIEGE_RAM] = true,
                [SPECIALIZED_ITEMTYPE_SIEGE_CATAPULT] = true,
                [SPECIALIZED_ITEMTYPE_SIEGE_GRAVEYARD] = true,
                [SPECIALIZED_ITEMTYPE_SIEGE_MONSTER] = true,
                [SPECIALIZED_ITEMTYPE_SIEGE_OIL] = true,
                [SPECIALIZED_ITEMTYPE_SIEGE_LANCER] = true,
                [SPECIALIZED_ITEMTYPE_TOOL] = true,
                [SPECIALIZED_ITEMTYPE_DISGUISE] = true,
                [SPECIALIZED_ITEMTYPE_TABARD] = true,
                [SPECIALIZED_ITEMTYPE_LURE] = true,
                [SPECIALIZED_ITEMTYPE_SOUL_GEM] = true,
                [SPECIALIZED_ITEMTYPE_GLYPH_WEAPON] = true,
                [SPECIALIZED_ITEMTYPE_GLYPH_ARMOR] = true,
                [SPECIALIZED_ITEMTYPE_GLYPH_JEWELRY] = true,
                [SPECIALIZED_ITEMTYPE_TRASH] = true,
                [SPECIALIZED_ITEMTYPE_TREASURE] = true,
            }
        },
        {
            type = TRADING_HOUSE_FILTER_TYPE_EQUIP,
            allowed = {
                [EQUIP_TYPE_INVALID] = true,
                [EQUIP_TYPE_CHEST] = true,
                [EQUIP_TYPE_LEGS] = true,
                [EQUIP_TYPE_FEET] = true,
                [EQUIP_TYPE_HAND] = true,
                [EQUIP_TYPE_COSTUME] = true,
            }
        },
        {
            type = ITEMFILTERTYPE_LOCAL,
            allowed = {
                [ITEMFILTERTYPE_MISCELLANEOUS] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.MISCELLANEOUS_COSTUME] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_ITEM,
            allowed = {
                [ITEMTYPE_ARMOR] = true,
                [ITEMTYPE_COSTUME] = true,
                [ITEMTYPE_DISGUISE] = true,
                [ITEMTYPE_TABARD] = true,
            }
        },
        {
            type = TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM,
            allowed = {
                [SPECIALIZED_ITEMTYPE_NONE] = true,
                [SPECIALIZED_ITEMTYPE_COSTUME] = true,
                [SPECIALIZED_ITEMTYPE_DISGUISE] = true,
                [SPECIALIZED_ITEMTYPE_TABARD] = true,
            }
        },
        {
            type = TRADING_HOUSE_FILTER_TYPE_EQUIP,
            allowed = {
                [EQUIP_TYPE_HEAD] = true,
                [EQUIP_TYPE_CHEST] = true,
                [EQUIP_TYPE_SHOULDERS] = true,
                [EQUIP_TYPE_LEGS] = true,
                [EQUIP_TYPE_WAIST] = true,
                [EQUIP_TYPE_FEET] = true,
                [EQUIP_TYPE_HAND] = true,
                [EQUIP_TYPE_COSTUME] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.MISCELLANEOUS_GLYPHS] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_ITEM,
            allowed = {
                [ITEMTYPE_GLYPH_WEAPON] = true,
                [ITEMTYPE_GLYPH_JEWELRY] = true,
                [ITEMTYPE_GLYPH_ARMOR] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.MISCELLANEOUS_SOUL_GEM] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_ITEM,
            allowed = {
                [ITEMTYPE_SOUL_GEM] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.MISCELLANEOUS_SIEGE] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_ITEM,
            allowed = {
                [ITEMTYPE_SIEGE] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.MISCELLANEOUS_FISHING] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_ITEM,
            allowed = {
                [ITEMTYPE_LURE] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.MISCELLANEOUS_TOOL] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_ITEM,
            allowed = {
                [ITEMTYPE_TOOL] = true,
            }
        },
        {
            type = ITEMFILTERTYPE_LOCAL,
            allowed = {
                [ITEMFILTERTYPE_MISCELLANEOUS] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.MISCELLANEOUS_TROPHY] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_ITEM,
            allowed = {
                [ITEMTYPE_TROPHY] = true,
                [ITEMTYPE_COLLECTIBLE] = true,
                [ITEMTYPE_TREASURE] = true,
            }
        },
        {
            type = ITEMFILTERTYPE_LOCAL,
            allowed = {
                [ITEMFILTERTYPE_MISCELLANEOUS] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.MISCELLANEOUS_TRASH] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_ITEM,
            allowed = {
                [ITEMTYPE_TRASH] = true,
            }
        },
        {
            type = ITEMFILTERTYPE_LOCAL,
            allowed = {
                [ITEMFILTERTYPE_MISCELLANEOUS] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.MISCELLANEOUS_MISC] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_ITEM,
            allowed = {
                [ITEMTYPE_NONE] = true,
            }
        },
        {
            type = ITEMFILTERTYPE_LOCAL,
            allowed = {
                [ITEMFILTERTYPE_MISCELLANEOUS] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.COMPANION_ALL] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_ITEM,
            allowed = {
                [ITEMTYPE_WEAPON] = true,
                [ITEMTYPE_ARMOR] = true,
            }
        },
        {
            type = TRADING_HOUSE_FILTER_TYPE_GAMEPLAY_ACTOR_CATEGORY,
            allowed = {
                [GAMEPLAY_ACTOR_CATEGORY_COMPANION] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.COMPANION_WEAPONS] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_EQUIP,
            allowed = {
                [EQUIP_TYPE_ONE_HAND] = true,
                [EQUIP_TYPE_TWO_HAND] = true,
            }
        },
        {
            type = TRADING_HOUSE_FILTER_TYPE_GAMEPLAY_ACTOR_CATEGORY,
            allowed = {
                [GAMEPLAY_ACTOR_CATEGORY_COMPANION] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.COMPANION_ARMOR] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM,
            allowed = {
                [SPECIALIZED_ITEMTYPE_WEAPON] = true,
                [SPECIALIZED_ITEMTYPE_ARMOR] = true,
            }
        },
        {
            type = TRADING_HOUSE_FILTER_TYPE_EQUIP,
            allowed = {
                [EQUIP_TYPE_HEAD] = true,
                [EQUIP_TYPE_CHEST] = true,
                [EQUIP_TYPE_SHOULDERS] = true,
                [EQUIP_TYPE_WAIST] = true,
                [EQUIP_TYPE_LEGS] = true,
                [EQUIP_TYPE_FEET] = true,
                [EQUIP_TYPE_HAND] = true,
                [EQUIP_TYPE_OFF_HAND] = true,
            }
        },
        {
            type = TRADING_HOUSE_FILTER_TYPE_GAMEPLAY_ACTOR_CATEGORY,
            allowed = {
                [GAMEPLAY_ACTOR_CATEGORY_COMPANION] = true,
            }
        }
    },
    [SUB_CATEGORY_ID.COMPANION_JEWELRY] = {
        {
            type = TRADING_HOUSE_FILTER_TYPE_EQUIP,
            allowed = {
                [EQUIP_TYPE_RING] = true,
                [EQUIP_TYPE_NECK] = true,
            }
        },
        {
            type = TRADING_HOUSE_FILTER_TYPE_GAMEPLAY_ACTOR_CATEGORY,
            allowed = {
                [GAMEPLAY_ACTOR_CATEGORY_COMPANION] = true,
            }
        }
    }
}

local filterFunctions = {
    [TRADING_HOUSE_FILTER_TYPE_EQUIP] = function(itemLink, allowedTypes)
        local equipType = GetItemLinkEquipType(itemLink)
        return allowedTypes[equipType]
    end,
    [TRADING_HOUSE_FILTER_TYPE_WEAPON] = function(itemLink, allowedTypes)
        local weaponType = GetItemLinkWeaponType(itemLink)
        return allowedTypes[weaponType]
    end,
    [TRADING_HOUSE_FILTER_TYPE_ARMOR] = function(itemLink, allowedTypes)
        local armorType = GetItemLinkArmorType(itemLink)
        return allowedTypes[armorType]
    end,
    [TRADING_HOUSE_FILTER_TYPE_ITEM] = function(itemLink, allowedTypes)
        local itemType = GetItemLinkItemType(itemLink)
        return allowedTypes[itemType]
    end,
    [TRADING_HOUSE_FILTER_TYPE_TRAIT] = function(itemLink, allowedTypes)
        local traitType = GetItemLinkTraitInfo(itemLink)
        return allowedTypes[traitType]
    end,
    [TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM] = function(itemLink, allowedTypes)
        local _, specializedItemType = GetItemLinkItemType(itemLink)
        return allowedTypes[specializedItemType]
    end,
    [TRADING_HOUSE_FILTER_TYPE_FURNITURE_CATEGORY] = function(itemLink, allowedTypes)
        local furnitureDataId = GetItemLinkFurnitureDataId(itemLink)
        local category = GetFurnitureDataInfo(furnitureDataId)
        return allowedTypes[category]
    end,
    [TRADING_HOUSE_FILTER_TYPE_FURNITURE_SUBCATEGORY] = function(itemLink, allowedTypes)
        local furnitureDataId = GetItemLinkFurnitureDataId(itemLink)
        local _, subcategory = GetFurnitureDataInfo(furnitureDataId)
        return allowedTypes[subcategory]
    end,
    [TRADING_HOUSE_FILTER_TYPE_GAMEPLAY_ACTOR_CATEGORY] = function(itemLink, allowedTypes)
        local actorCategory = GetItemLinkActorCategory(itemLink)
        return allowedTypes[actorCategory]
    end,
    [ITEMFILTERTYPE_LOCAL] = function(itemLink, allowedTypes)
        local itemFilterTypes = {GetItemLinkFilterTypeInfo(itemLink)}
        if allowedTypes.checkLastReturnOnly then
            return allowedTypes[itemFilterTypes[#itemFilterTypes]]
        else
            for i = 1, #itemFilterTypes do
                if allowedTypes[itemFilterTypes[i]] then
                    return true
                end
            end
        end
        return false
    end,
}

local temp = {}
local function GetSubcategoryFromItem(itemLink)
    local subcategory = SUB_CATEGORY_DEFINITION[SUB_CATEGORY_ID.ALL]
    temp[TRADING_HOUSE_FILTER_TYPE_EQUIP] = GetItemLinkEquipType(itemLink)
    temp[TRADING_HOUSE_FILTER_TYPE_WEAPON] = GetItemLinkWeaponType(itemLink)
    temp[TRADING_HOUSE_FILTER_TYPE_ARMOR] = GetItemLinkArmorType(itemLink)
    temp[TRADING_HOUSE_FILTER_TYPE_TRAIT] = GetItemLinkTraitInfo(itemLink)
    temp[TRADING_HOUSE_FILTER_TYPE_ITEM], temp[TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM] = GetItemLinkItemType(itemLink)
    temp[TRADING_HOUSE_FILTER_TYPE_FURNITURE_CATEGORY], temp[TRADING_HOUSE_FILTER_TYPE_FURNITURE_SUBCATEGORY] = GetFurnitureDataInfo(GetItemLinkFurnitureDataId(itemLink))
    temp[TRADING_HOUSE_FILTER_TYPE_GAMEPLAY_ACTOR_CATEGORY] = GetItemLinkActorCategory(itemLink)
    temp[ITEMFILTERTYPE_LOCAL] = GetItemLinkFilterTypeInfo(itemLink)

    for subcategoryId, filters in pairs(filterDefinition) do
        if(subcategoryId ~= SUB_CATEGORY_ID.ALL) then
            local isMatch = true
            for i = 1, #filters do
                local filter = filters[i]
                if(not filter.allowed[temp[filter.type]]) then
                    isMatch = false
                    break
                end
            end

            if(isMatch and (subcategory.id == SUB_CATEGORY_ID.ALL or not SUB_CATEGORY_DEFINITION[subcategoryId].isDefault)) then
                subcategory = SUB_CATEGORY_DEFINITION[subcategoryId]
                local category = CATEGORY_DEFINITION[subcategory.category]
            end
        end
    end

    return subcategory
end

local ItemCategoryFilter = FilterBase:Subclass()
AGS.class.ItemCategoryFilter = ItemCategoryFilter

function ItemCategoryFilter:New(...)
    return FilterBase.New(self, ...)
end

function ItemCategoryFilter:Initialize()
    -- TRANSLATORS: label of the category filter
    FilterBase.Initialize(self, FILTER_ID.CATEGORY_FILTER, FilterBase.GROUP_CATEGORY, gettext("Item Category"))

    self.activeSubcategoryForCategory = {}
    for categoryId, subcategoryId in pairs(DEFAULT_SUB_CATEGORY_ID) do
        self.activeSubcategoryForCategory[categoryId] = SUB_CATEGORY_DEFINITION[subcategoryId]
    end
    self.category = CATEGORY_DEFINITION[DEFAULT_CATEGORY_ID]
    self.subcategory = self.activeSubcategoryForCategory[self.category.id]

    self.filters = {}
    self.allowedTypes = {}
    self.pinned = true
end

function ItemCategoryFilter:GetCurrentFilterDefinition(subcategory)
    if(not filterDefinition[subcategory.id]) then
        logger:Warn("No filter definition for category %d (%s) found", subcategory.id, subcategory.label)
        return {}
    end
    return filterDefinition[subcategory.id]
end

function ItemCategoryFilter:IsLocal()
    return false
end

function ItemCategoryFilter:IsAffectingTextFilter()
    return true
end

function ItemCategoryFilter:PrepareForSearch(subcategory)
    self.serverSubcategory = subcategory
end

function ItemCategoryFilter:ApplyToSearch(request)
    local filters = self:GetCurrentFilterDefinition(self.serverSubcategory)
    for i = 1, #filters do
        local filter = filters[i]
        if(filter.type ~= ITEMFILTERTYPE_LOCAL) then
            local values = {}
            for value in pairs(filter.allowed) do
                values[#values + 1] = value
            end
            request:SetFilterValues(filter.type, unpack(values))
        end
    end
end

function ItemCategoryFilter:GetValues()
    return self.subcategory
end

function ItemCategoryFilter:SetValues(subcategory)
    self:SetSubcategory(subcategory)
end

function ItemCategoryFilter:SetFromItem(itemLink)
    local subcategory = GetSubcategoryFromItem(itemLink)
    self:SetSubcategory(subcategory)
end

function ItemCategoryFilter:SetUpLocalFilter(subcategory)
    ZO_ClearNumericallyIndexedTable(self.filters)
    ZO_ClearNumericallyIndexedTable(self.allowedTypes)
    local filters = self:GetCurrentFilterDefinition(subcategory)
    for i = 1, #filters do
        local filter = filters[i]
        self.filters[#self.filters + 1] = filterFunctions[filter.type]
        self.allowedTypes[#self.allowedTypes + 1] = filter.allowed
    end
    return true
end

function ItemCategoryFilter:FilterLocalResult(itemData)
    local itemLink = itemData.itemLink
    for i = 1, #self.filters do
        if(not self.filters[i](itemLink, self.allowedTypes[i])) then
            return false
        end
    end
    return true
end

function ItemCategoryFilter:CanFilter(subcategory)
    return true
end

function ItemCategoryFilter:SetCategory(category)
    if(self.category ~= category) then
        self.category = category
        self.subcategory = self.activeSubcategoryForCategory[category.id]
        self:HandleChange(self.category, self.subcategory)
    end
end

function ItemCategoryFilter:SetSubcategory(subcategory)
    if(self.subcategory ~= subcategory) then
        self.category = CATEGORY_DEFINITION[subcategory.category]
        self.subcategory = subcategory
        self.activeSubcategoryForCategory[subcategory.category] = self.subcategory
        self:HandleChange(self.category, self.subcategory)
    end
end

function ItemCategoryFilter:GetCurrentCategories()
    return self.category, self.subcategory
end

function ItemCategoryFilter:Reset()
    for categoryId, subcategoryId in pairs(DEFAULT_SUB_CATEGORY_ID) do
        self.activeSubcategoryForCategory[categoryId] = SUB_CATEGORY_DEFINITION[subcategoryId]
    end
    self.category = CATEGORY_DEFINITION[DEFAULT_CATEGORY_ID]
    self.subcategory = self.activeSubcategoryForCategory[self.category.id]

    self:HandleChange(self.category, self.subcategory)
end

function ItemCategoryFilter:IsDefault(subcategory)
    if(subcategory) then
        return subcategory.id ~= DEFAULT_SUB_CATEGORY_ID[DEFAULT_CATEGORY_ID]
    end

    if(self.category.id ~= DEFAULT_CATEGORY_ID or self.subcategory.id ~= DEFAULT_SUB_CATEGORY_ID[DEFAULT_CATEGORY_ID]) then
        return false
    end
    for categoryId, subcategoryId in pairs(DEFAULT_SUB_CATEGORY_ID) do
        if(self.activeSubcategoryForCategory[categoryId].id ~= subcategoryId) then
            return false
        end
    end
    return true
end

function ItemCategoryFilter:Serialize(subcategory)
    return EncodeValue("integer", subcategory.id)
end

function ItemCategoryFilter:Deserialize(state)
    local subcategoryId = DecodeValue("integer", state)
    if(subcategoryId and SUB_CATEGORY_DEFINITION[subcategoryId]) then
        return SUB_CATEGORY_DEFINITION[subcategoryId]
    end
    return SUB_CATEGORY_DEFINITION[DEFAULT_SUB_CATEGORY_ID[DEFAULT_CATEGORY_ID]]
end

function ItemCategoryFilter:GetTooltipText(subcategory)
    local category = CATEGORY_DEFINITION[subcategory.category]

    if(subcategory.isDefault) then
        return category.label
    else
        return string.format("%s > %s", category.label, subcategory.label)
    end
end
