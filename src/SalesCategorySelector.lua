local FILTER_PRESETS = {
    [ITEMFILTERTYPE_ALL] = {
        name = "All",
        label = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_ALL),
        texture = "EsoUI/Art/Inventory/inventory_tabIcon_all_%s.dds",
        index = 0,
        hasLevelFilter = true,
        isDefault = true,
        subcategories = {}
    },
    [ITEMFILTERTYPE_WEAPONS] = {
        name = "Weapon",
        label = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_WEAPONS),
        texture = "EsoUI/Art/Inventory/inventory_tabIcon_weapons_%s.dds",
        index = 1,
        hasLevelFilter = true,
        subcategories = {
            {
                label = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_ALL),
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_all_%s.dds",
                isDefault = true,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_EQUIP] = { EQUIP_TYPE_ONE_HAND, EQUIP_TYPE_TWO_HAND }
                },
            },
            {
                label = GetString("SI_EQUIPTYPE", EQUIP_TYPE_ONE_HAND),
                texture = "AwesomeGuildStore/images/weapon/onehand_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_EQUIP] = { EQUIP_TYPE_ONE_HAND }
                },
            },
            {
                label = GetString("SI_EQUIPTYPE", EQUIP_TYPE_TWO_HAND),
                texture = "AwesomeGuildStore/images/weapon/twohand_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_EQUIP] = { EQUIP_TYPE_TWO_HAND },
                    [TRADING_HOUSE_FILTER_TYPE_WEAPON] = { WEAPONTYPE_TWO_HANDED_AXE, WEAPONTYPE_TWO_HANDED_SWORD, WEAPONTYPE_TWO_HANDED_HAMMER }
                },
            },
            {
                label = GetString("SI_WEAPONTYPE", WEAPONTYPE_BOW),
                texture = "AwesomeGuildStore/images/weapon/bow_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_EQUIP] = { EQUIP_TYPE_TWO_HAND },
                    [TRADING_HOUSE_FILTER_TYPE_WEAPON] = { WEAPONTYPE_BOW }
                },
            },
            {
                label = zo_strformat(SI_SKILLS_TREE_NAME_FORMAT, GetSkillLineInfo(SKILL_TYPE_WEAPON, 5)),
                texture = "AwesomeGuildStore/images/weapon/fire_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_EQUIP] = { EQUIP_TYPE_TWO_HAND },
                    [TRADING_HOUSE_FILTER_TYPE_WEAPON] = { WEAPONTYPE_FIRE_STAFF, WEAPONTYPE_FROST_STAFF, WEAPONTYPE_LIGHTNING_STAFF }
                },
            },
            {
                label = zo_strformat(SI_SKILLS_TREE_NAME_FORMAT, GetSkillLineInfo(SKILL_TYPE_WEAPON, 6)),
                texture = "AwesomeGuildStore/images/weapon/restoration_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_EQUIP] = { EQUIP_TYPE_TWO_HAND },
                    [TRADING_HOUSE_FILTER_TYPE_WEAPON] = { WEAPONTYPE_HEALING_STAFF }
                },
            }
        }
    },
    [ITEMFILTERTYPE_ARMOR] = {
        name = "Armor",
        label = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_ARMOR),
        texture = "EsoUI/Art/Inventory/inventory_tabIcon_armor_%s.dds",
        index = 2,
        hasLevelFilter = true,
        subcategories = {
            {
                label = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_ALL),
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_all_%s.dds",
                index = 1,
                isDefault = true,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_EQUIP] = { EQUIP_TYPE_HEAD, EQUIP_TYPE_CHEST, EQUIP_TYPE_SHOULDERS, EQUIP_TYPE_WAIST, EQUIP_TYPE_LEGS, EQUIP_TYPE_FEET, EQUIP_TYPE_HAND, EQUIP_TYPE_OFF_HAND, EQUIP_TYPE_COSTUME },
                },
            },
            {
                label = GetString(SI_TRADING_HOUSE_BROWSE_ARMOR_TYPE_HEAVY),
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_armor_%s.dds",
                index = 2,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_EQUIP] = { EQUIP_TYPE_HEAD, EQUIP_TYPE_CHEST, EQUIP_TYPE_SHOULDERS, EQUIP_TYPE_WAIST, EQUIP_TYPE_LEGS, EQUIP_TYPE_FEET, EQUIP_TYPE_HAND },
                    [TRADING_HOUSE_FILTER_TYPE_ARMOR] = { ARMORTYPE_HEAVY }
                },
            },
            {
                label = GetString(SI_TRADING_HOUSE_BROWSE_ARMOR_TYPE_MEDIUM),
                texture = "AwesomeGuildStore/images/armor/medium_%s.dds",
                index = 3,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_EQUIP] = { EQUIP_TYPE_HEAD, EQUIP_TYPE_CHEST, EQUIP_TYPE_SHOULDERS, EQUIP_TYPE_WAIST, EQUIP_TYPE_LEGS, EQUIP_TYPE_FEET, EQUIP_TYPE_HAND },
                    [TRADING_HOUSE_FILTER_TYPE_ARMOR] = { ARMORTYPE_MEDIUM }
                },
            },
            {
                label = GetString(SI_TRADING_HOUSE_BROWSE_ARMOR_TYPE_LIGHT),
                texture = "AwesomeGuildStore/images/armor/light_%s.dds",
                index = 4,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_EQUIP] = { EQUIP_TYPE_HEAD, EQUIP_TYPE_CHEST, EQUIP_TYPE_SHOULDERS, EQUIP_TYPE_WAIST, EQUIP_TYPE_LEGS, EQUIP_TYPE_FEET, EQUIP_TYPE_HAND },
                    [TRADING_HOUSE_FILTER_TYPE_ARMOR] = { ARMORTYPE_LIGHT }
                },
            },
            {
                label = GetString(SI_TRADING_HOUSE_BROWSE_ARMOR_TYPE_SHIELD),
                texture = "AwesomeGuildStore/images/armor/shield_%s.dds",
                index = 5,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_EQUIP] = { EQUIP_TYPE_OFF_HAND },
                    [TRADING_HOUSE_FILTER_TYPE_WEAPON] = { WEAPONTYPE_SHIELD }
                },
            },
            {
                -- this is the old entry for jewelry. we have to keep it around for now, due to way the state is saved and how tooltips work
                hidden = true,
                label = GetString(SI_GAMEPADITEMCATEGORY38),
                texture = "AwesomeGuildStore/images/armor/neck_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_EQUIP] = { EQUIP_TYPE_RING, EQUIP_TYPE_NECK },
                },
            },
            {
                label = GetString("SI_EQUIPTYPE", EQUIP_TYPE_COSTUME),
                texture = "AwesomeGuildStore/images/armor/costume_%s.dds",
                index = 6,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_EQUIP] = { EQUIP_TYPE_COSTUME },
                },
                showTabards = true,
            }
        }
    },
    [ITEMFILTERTYPE_JEWELRY] = {
        name = "Jewelry",
        label = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_JEWELRY),
        texture = "AwesomeGuildStore/images/jewelry_%s.dds",
        index = 3,
        hasLevelFilter = true,
        subcategories = {
            {
                label = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_ALL),
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_all_%s.dds",
                isDefault = true,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_EQUIP] = { EQUIP_TYPE_RING, EQUIP_TYPE_NECK },
                },
            },
            {
                label = GetString("SI_EQUIPTYPE", EQUIP_TYPE_RING),
                texture = "AwesomeGuildStore/images/armor/ring_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_EQUIP] = { EQUIP_TYPE_RING },
                },
            },
            {
                label = GetString("SI_EQUIPTYPE", EQUIP_TYPE_NECK),
                texture = "AwesomeGuildStore/images/armor/neck_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_EQUIP] = { EQUIP_TYPE_NECK },
                },
            },
        }
    },
    [ITEMFILTERTYPE_CONSUMABLE] = {
        name = "Consumable",
        label = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_CONSUMABLE),
        texture = "EsoUI/Art/Inventory/inventory_tabIcon_consumables_%s.dds",
        index = 4,
        subcategories = {
            {
                label = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_ALL),
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_all_%s.dds",
                isDefault = true,
                index = 1,
                hasLevelFilter = true,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_FOOD, ITEMTYPE_DRINK, ITEMTYPE_RECIPE, ITEMTYPE_POTION, ITEMTYPE_POISON, ITEMTYPE_RACIAL_STYLE_MOTIF, ITEMTYPE_CONTAINER, ITEMTYPE_FISH, ITEMTYPE_AVA_REPAIR, ITEMTYPE_MASTER_WRIT }
                },
            },
            {
                label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_FOOD)),
                texture = "EsoUI/Art/Crafting/provisioner_indexIcon_meat_%s.dds",
                index = 2,
                hasLevelFilter = true,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_FOOD },
                },
            },
            {
                label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_DRINK)),
                texture = "EsoUI/Art/Crafting/provisioner_indexIcon_beer_%s.dds",
                index = 3,
                hasLevelFilter = true,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_DRINK },
                },
            },
            {
                label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_RECIPE)),
                texture = "EsoUI/Art/Guild/tabIcon_roster_%s.dds",
                index = 4,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_RECIPE },
                },
            },
            {
                label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_POTION)),
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_consumables_%s.dds",
                index = 5,
                hasLevelFilter = true,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_POTION },
                },
            },
            {
                label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_POISON)),
                texture = "EsoUI/Art/Crafting/alchemy_tabIcon_solvent_%s.dds",
                index = 6,
                hasLevelFilter = true,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_POISON },
                },
            },
            {
                label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_RACIAL_STYLE_MOTIF)),
                texture = "EsoUI/Art/MainMenu/menuBar_journal_%s.dds",
                index = 7,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_RACIAL_STYLE_MOTIF },
                },
            },
            {
                label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_CONTAINER)),
                texture = "EsoUI/Art/MainMenu/menuBar_inventory_%s.dds",
                index = 9,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_CONTAINER, ITEMTYPE_FISH },
                },
            },
            {
                label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_AVA_REPAIR)),
                texture = "EsoUI/Art/Vendor/vendor_tabIcon_repair_%s.dds",
                index = 10,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_AVA_REPAIR },
                },
            },
            { -- needs to stay here because the table index is used for the save data
                label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_MASTER_WRIT)),
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
        label = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_CRAFTING),
        texture = "EsoUI/Art/Inventory/inventory_tabIcon_crafting_%s.dds",
        index = 5,
        subcategories = {
            {
                label = zo_strformat(SI_TOOLTIP_ITEM_NAME, ZO_GetCraftingSkillName(CRAFTING_TYPE_BLACKSMITHING)),
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_craftbag_blacksmithing_%s.dds",
                index = 2,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_BLACKSMITHING_RAW_MATERIAL, ITEMTYPE_BLACKSMITHING_MATERIAL, ITEMTYPE_BLACKSMITHING_BOOSTER },
                },
            },
            {
                label = zo_strformat(SI_TOOLTIP_ITEM_NAME, ZO_GetCraftingSkillName(CRAFTING_TYPE_CLOTHIER)),
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_craftbag_clothing_%s.dds",
                index = 3,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_CLOTHIER_RAW_MATERIAL, ITEMTYPE_CLOTHIER_MATERIAL, ITEMTYPE_CLOTHIER_BOOSTER },
                },
            },
            {
                label = zo_strformat(SI_TOOLTIP_ITEM_NAME, ZO_GetCraftingSkillName(CRAFTING_TYPE_WOODWORKING)),
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_craftbag_woodworking_%s.dds",
                index = 4,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_WOODWORKING_RAW_MATERIAL, ITEMTYPE_WOODWORKING_MATERIAL, ITEMTYPE_WOODWORKING_BOOSTER },
                },
            },
            {
                label = zo_strformat(SI_TOOLTIP_ITEM_NAME, ZO_GetCraftingSkillName(CRAFTING_TYPE_ALCHEMY)),
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_craftbag_alchemy_%s.dds",
                index = 6,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_POTION_BASE, ITEMTYPE_POISON_BASE, ITEMTYPE_REAGENT },
                },
            },
            {
                label = zo_strformat(SI_TOOLTIP_ITEM_NAME, ZO_GetCraftingSkillName(CRAFTING_TYPE_ENCHANTING)),
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_craftbag_enchanting_%s.dds",
                index = 7,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_ENCHANTING_RUNE_ASPECT, ITEMTYPE_ENCHANTING_RUNE_ESSENCE, ITEMTYPE_ENCHANTING_RUNE_POTENCY },
                },
            },
            {
                label = zo_strformat(SI_TOOLTIP_ITEM_NAME, ZO_GetCraftingSkillName(CRAFTING_TYPE_PROVISIONING)),
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_craftbag_provisioning_%s.dds",
                index = 8,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_INGREDIENT },
                },
            },
            {
                label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_STYLE_MATERIAL)),
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_craftbag_stylematerial_%s.dds",
                index = 9,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_STYLE_MATERIAL, ITEMTYPE_RAW_MATERIAL },
                },
            },
            {
                -- these are the old entries for traits. we have to keep them around for now, due to way the state is saved and how tooltips work
                hidden = true,
                label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_WEAPON_TRAIT)),
                texture = "EsoUI/Art/Crafting/smithing_tabIcon_weaponSet_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_WEAPON_TRAIT },
                }
            },
            {
                hidden = true,
                label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_ARMOR_TRAIT)),
                texture = "EsoUI/Art/Crafting/smithing_tabIcon_armorSet_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_ARMOR_TRAIT },
                }
            },
            {
                label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_FURNISHING_ORNAMENTAL)),
                texture = "EsoUI/Art/treeIcons/collection_indexicon_furnishings_%s.dds",
                index = 11,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_FURNISHING_MATERIAL },
                },
            },
            { -- needs to stay here because the table index is used for the save data
                label = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_ALL),
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_all_%s.dds",
                isDefault = true,
                index = 1,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = {
                        ITEMTYPE_BLACKSMITHING_RAW_MATERIAL, ITEMTYPE_BLACKSMITHING_MATERIAL, ITEMTYPE_BLACKSMITHING_BOOSTER,
                        ITEMTYPE_CLOTHIER_RAW_MATERIAL, ITEMTYPE_CLOTHIER_MATERIAL, ITEMTYPE_CLOTHIER_BOOSTER,
                        ITEMTYPE_WOODWORKING_RAW_MATERIAL, ITEMTYPE_WOODWORKING_MATERIAL, ITEMTYPE_WOODWORKING_BOOSTER,
                        ITEMTYPE_POTION_BASE, ITEMTYPE_POISON_BASE, ITEMTYPE_REAGENT,
                        ITEMTYPE_ENCHANTING_RUNE_ASPECT, ITEMTYPE_ENCHANTING_RUNE_ESSENCE, ITEMTYPE_ENCHANTING_RUNE_POTENCY,
                        ITEMTYPE_INGREDIENT,
                        ITEMTYPE_STYLE_MATERIAL, ITEMTYPE_RAW_MATERIAL,
                        -- ITEMTYPE_WEAPON_TRAIT,
                        -- ITEMTYPE_ARMOR_TRAIT,
                        ITEMTYPE_FURNISHING_MATERIAL,
                        -- ITEMTYPE_JEWELRY_TRAIT, ITEMTYPE_JEWELRY_RAW_TRAIT,
                        ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL, ITEMTYPE_JEWELRYCRAFTING_MATERIAL, ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER, ITEMTYPE_JEWELRYCRAFTING_BOOSTER
                    },
                },
            },
            {
                label = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_JEWELRY),
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_craftBag_jewelryCrafting_%s.dds",
                index = 5,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL, ITEMTYPE_JEWELRYCRAFTING_MATERIAL, ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER, ITEMTYPE_JEWELRYCRAFTING_BOOSTER },
                },
            },
            {
                label = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_TRAIT_ITEMS),
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_craftBag_itemTrait_%s.dds",
                index = 10,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_WEAPON_TRAIT, ITEMTYPE_ARMOR_TRAIT, ITEMTYPE_JEWELRY_TRAIT, ITEMTYPE_JEWELRY_RAW_TRAIT },
                },
            },
        }
    },
    [ITEMFILTERTYPE_FURNISHING] = {
        name = "Furnishing",
        label = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_FURNISHING),
        texture = "EsoUI/Art/treeIcons/collection_indexicon_furnishings_%s.dds",
        index = 6,
        subcategories = {
            {
                label = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_ALL),
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_all_%s.dds",
                isDefault = true,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM] = {
                        SPECIALIZED_ITEMTYPE_FURNISHING_ORNAMENTAL,
                        SPECIALIZED_ITEMTYPE_FURNISHING_LIGHT,
                        SPECIALIZED_ITEMTYPE_FURNISHING_SEATING,
                        SPECIALIZED_ITEMTYPE_FURNISHING_CRAFTING_STATION,
                        SPECIALIZED_ITEMTYPE_FURNISHING_TARGET_DUMMY,
                        SPECIALIZED_ITEMTYPE_FURNISHING_ATTUNABLE_STATION
                    },
                },
            },
            {
                label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_FURNISHING_CRAFTING_STATION)),
                texture = "EsoUI/Art/treeIcons/housing_indexicon_workshop_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM] = {
                        SPECIALIZED_ITEMTYPE_FURNISHING_CRAFTING_STATION ,
                        SPECIALIZED_ITEMTYPE_FURNISHING_ATTUNABLE_STATION
                    },
                },
            },
            {
                label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_FURNISHING_LIGHT)),
                texture = "EsoUI/Art/treeIcons/housing_indexicon_shrine_%s.dds",
                filters = {
                    -- [TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM] = { SPECIALIZED_ITEMTYPE_FURNISHING_LIGHT },
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_FURNISHING },
                    [TRADING_HOUSE_FILTER_TYPE_FURNITURE_CATEGORY] = { 11 }, -- lighting
                },
            },
            {
                label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_FURNISHING_ORNAMENTAL)),
                texture = "EsoUI/Art/treeIcons/housing_indexicon_gallery_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM] = { SPECIALIZED_ITEMTYPE_FURNISHING_ORNAMENTAL },
                },
            },
            {
                label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_FURNISHING_SEATING)),
                texture = "EsoUI/Art/treeIcons/collection_indexicon_furnishings_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM] = { SPECIALIZED_ITEMTYPE_FURNISHING_SEATING },
                },
            },
            {
                label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_FURNISHING_TARGET_DUMMY)),
                texture = "EsoUI/Art/treeIcons/collection_indexicon_weapons+armor_%s.dds",
                filters = {
                    -- [TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM] = { SPECIALIZED_ITEMTYPE_FURNISHING_TARGET_DUMMY },
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_FURNISHING },
                    [TRADING_HOUSE_FILTER_TYPE_FURNITURE_CATEGORY] = { 25 }, -- services
                    [TRADING_HOUSE_FILTER_TYPE_FURNITURE_SUBCATEGORY] = { 98 }, -- training dummies
                },
            },
        },
    },
    [ITEMFILTERTYPE_MISCELLANEOUS] = {
        name = "Misc",
        label = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_MISCELLANEOUS),
        texture = "EsoUI/Art/Inventory/inventory_tabIcon_misc_%s.dds",
        index = 7,
        subcategories = {
            {
                label = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_ALL),
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_all_%s.dds",
                isDefault = true,
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_GLYPH_WEAPON, ITEMTYPE_GLYPH_JEWELRY, ITEMTYPE_GLYPH_ARMOR, ITEMTYPE_SOUL_GEM, ITEMTYPE_SIEGE, ITEMTYPE_LURE, ITEMTYPE_TOOL, ITEMTYPE_TROPHY, ITEMTYPE_COLLECTIBLE },
                },
            },
            {
                label = GetString(SI_GAMEPADITEMCATEGORY13),
                texture = "AwesomeGuildStore/images/misc/glyphs_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_GLYPH_WEAPON, ITEMTYPE_GLYPH_JEWELRY, ITEMTYPE_GLYPH_ARMOR },
                },
            },
            {
                label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_SOUL_GEM)),
                texture = "AwesomeGuildStore/images/misc/soulgem_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_SOUL_GEM },
                },
            },
            {
                label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_SIEGE)),
                texture = "EsoUI/Art/MainMenu/menuBar_ava_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_SIEGE },
                },
            },
            {
                label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_LURE)),
                texture = "EsoUI/Art/Inventory/inventory_tabIcon_craftbag_fishing_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_LURE },
                },
            },
            {
                label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_TOOL)),
                texture = "EsoUI/Art/Vendor/vendor_tabIcon_repair_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_TOOL },
                },
            },
            {
                label = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_TROPHY)),
                texture = "EsoUI/Art/Journal/journal_tabIcon_leaderboard_%s.dds",
                filters = {
                    [TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_TROPHY, ITEMTYPE_COLLECTIBLE },
                },
            },
        },
    },
}

local MAJOR_BUTTON_SIZE = 46
local MINOR_BUTTON_SIZE = 32
local RESET_BUTTON_SIZE = 18
local RESET_BUTTON_TEXTURE = "EsoUI/Art/Buttons/decline_%s.dds"
local DEFAULT_LAYOUT = BACKPACK_TRADING_HOUSE_LAYOUT_FRAGMENT.layoutData

local AGS = AwesomeGuildStore

local RegisterForEvent = AGS.internal.RegisterForEvent
local ButtonGroup = AGS.class.ButtonGroup
local ToggleButton = AGS.class.ToggleButton

local SalesCategorySelector = ZO_Object:Subclass()
AGS.class.SalesCategorySelector = SalesCategorySelector

local ALL_CRAFTING_FILTERS = {
    [TRADING_HOUSE_FILTER_TYPE_ITEM] = {
        ITEMTYPE_BLACKSMITHING_RAW_MATERIAL, ITEMTYPE_BLACKSMITHING_MATERIAL, ITEMTYPE_BLACKSMITHING_BOOSTER,
        ITEMTYPE_CLOTHIER_RAW_MATERIAL, ITEMTYPE_CLOTHIER_MATERIAL, ITEMTYPE_CLOTHIER_BOOSTER,
        ITEMTYPE_WOODWORKING_RAW_MATERIAL, ITEMTYPE_WOODWORKING_MATERIAL, ITEMTYPE_WOODWORKING_BOOSTER,
        ITEMTYPE_POTION_BASE, ITEMTYPE_POISON_BASE, ITEMTYPE_REAGENT,
        ITEMTYPE_ENCHANTING_RUNE_ASPECT, ITEMTYPE_ENCHANTING_RUNE_ESSENCE, ITEMTYPE_ENCHANTING_RUNE_POTENCY,
        ITEMTYPE_INGREDIENT,
        ITEMTYPE_STYLE_MATERIAL, ITEMTYPE_RAW_MATERIAL,
        ITEMTYPE_WEAPON_TRAIT,
        ITEMTYPE_ARMOR_TRAIT,
        ITEMTYPE_FURNISHING_MATERIAL,
        ITEMTYPE_JEWELRY_TRAIT, ITEMTYPE_JEWELRY_RAW_TRAIT,
        ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL, ITEMTYPE_JEWELRYCRAFTING_MATERIAL, ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER, ITEMTYPE_JEWELRYCRAFTING_BOOSTER
    },
}

function SalesCategorySelector:New(parent, name)
    local selector = ZO_Object.New(self)
    selector.callbackName = name .. "Changed"
    selector.type = 10

    local container = parent:CreateControl(name .. "Container", CT_CONTROL)
    container:SetResizeToFitDescendents(true)
    container:ClearAnchors()
    container:SetAnchor(TOPLEFT, parent, TOPRIGHT, 100, -47)
    selector.control = container
    selector.group = {}
    selector.category = ITEMFILTERTYPE_ALL
    selector.subcategory = {}

    local group = ButtonGroup:New(container, name .. "MainGroup", 0, 0)
    local label = group.control:CreateControl(name .. "Label", CT_LABEL)
    label:SetFont("ZoFontWinH4")
    label:SetModifyTextType(MODIFY_TEXT_TYPE_UPPERCASE)
    label:SetAnchor(TOPLEFT, group.control, TOPLEFT, 0, 13)
    group.label = label

    local divider = CreateControlFromVirtual(name .. "SubDivider", container, "ZO_InventoryFilterDivider")
    divider:SetWidth(565)
    divider:SetAlpha(0.3)
    divider:ClearAnchors()
    divider:SetAnchor(TOPLEFT, ZO_PlayerInventoryFilterDivider, TOPLEFT, 0, MINOR_BUTTON_SIZE + 10)
    selector.subDivider = divider

    selector.mainGroup = group

    for category, preset in pairs(FILTER_PRESETS) do
        selector:CreateCategoryButton(group, category, preset)
        selector:CreateSubcategory(name, category, preset)
    end

    RegisterForEvent(EVENT_CLOSE_TRADING_HOUSE, function()
        selector:ResetLayout()
    end)

    return selector
end

function SalesCategorySelector:Hide()
    self.control:SetHidden(true)
end

function SalesCategorySelector:Show()
    self.control:SetHidden(false)
end

function SalesCategorySelector:CreateSubcategory(name, category, categoryPreset)
    if(#categoryPreset.subcategories == 0) then return end
    local group = self:CreateSubcategoryGroup(name .. categoryPreset.name .. "Group", category)
    for subcategory, preset in pairs(categoryPreset.subcategories) do
        if(not preset.hidden) then
            self:CreateSubcategoryButton(group, subcategory, preset)
        end
    end
end

function SalesCategorySelector:CreateCategoryButton(group, category, preset)
    local button = ToggleButton:New(group.control, group.control:GetName() .. preset.name .. "Button", preset.texture, 140 + MAJOR_BUTTON_SIZE * preset.index, 0, MAJOR_BUTTON_SIZE, MAJOR_BUTTON_SIZE, preset.label, SOUNDS.MENU_BAR_CLICK)
    button.HandlePress = function()
        group:ReleaseAllButtons()
        self.category = category
        group.label:SetText(preset.label)
        if(self.group[category]) then
            self.group[category].control:SetHidden(false)
            self.subDivider:SetHidden(false)
        else
            self.subDivider:SetHidden(true)
        end
        self:HandleChange()
        return true
    end
    button.HandleRelease = function(control, fromGroup)
        local subCategoryGroup = self.group[category]
        if(subCategoryGroup) then
            if(fromGroup) then
                subCategoryGroup.control:SetHidden(true)
            else
                subCategoryGroup.defaultButton:Press()
            end
        end
        return fromGroup
    end
    button.value = category
    if(preset.isDefault) then
        group.defaultButton = button
        button:Press()
    end
    group:AddButton(button)
    return button
end

function SalesCategorySelector:CreateSubcategoryGroup(name, category)
    local group = ButtonGroup:New(self.control, name, 0, MAJOR_BUTTON_SIZE + 12)
    group.category = category

    local label = group.control:CreateControl(name .. "Label", CT_LABEL)
    label:SetFont("ZoFontWinH5")
    label:SetModifyTextType(MODIFY_TEXT_TYPE_UPPERCASE)
    label:SetAnchor(TOPLEFT, group.control, TOPLEFT, 0, 7)
    group.label = label

    self.group[category] = group
    group.control:SetHidden(true)
    return group
end

function SalesCategorySelector:CreateSubcategoryButton(group, subcategory, preset)
    local button = ToggleButton:New(group.control, group.control:GetName() .. "SubcategoryButton" .. subcategory, preset.texture, 120 + MINOR_BUTTON_SIZE * (preset.index or subcategory), 0, MINOR_BUTTON_SIZE, MINOR_BUTTON_SIZE, preset.label, SOUNDS.MENU_BAR_CLICK)
    button.HandlePress = function()
        group:ReleaseAllButtons()
        group.label:SetText(preset.label)
        self.subcategory[group.category] = subcategory
        self:HandleChange()
        return true
    end
    button.HandleRelease = function(control, fromGroup)
        return fromGroup
    end
    button.value = subcategory
    if(preset.isDefault) then
        group.defaultButton = button
        button:Press()
    end
    group:AddButton(button)
    return button
end

local currentFilterValues = {}
local currentLayout = DEFAULT_LAYOUT

local function contains(haystack, needle)
    for _, value in pairs(haystack) do
        if(value == needle) then
            return true
        end
    end
    return false
end

local function SalesCategoryFilter(slot)
    if(slot.quality == ITEM_QUALITY_TRASH) then return false end
    if(IsItemBoPAndTradeable(slot.bagId, slot.slotIndex)) then return false end
    local itemLink = GetItemLink(slot.bagId, slot.slotIndex)
    if(IsItemLinkBound(itemLink) or IsItemLinkStolen(itemLink)) then return false end

    if(NonContiguousCount(currentFilterValues) == 0) then
        return true
    else
        local isValid = true
        for type, values in pairs(currentFilterValues) do
            if(type == TRADING_HOUSE_FILTER_TYPE_EQUIP) then
                isValid = isValid and contains(values, GetItemLinkEquipType(itemLink))
            elseif(type == TRADING_HOUSE_FILTER_TYPE_WEAPON) then
                isValid = isValid and contains(values, GetItemLinkWeaponType(itemLink))
            elseif(type == TRADING_HOUSE_FILTER_TYPE_ARMOR) then
                isValid = isValid and contains(values, GetItemLinkArmorType(itemLink))
            elseif(type == TRADING_HOUSE_FILTER_TYPE_ITEM or type == TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM) then
                local itemType, specializedItemType = GetItemLinkItemType(itemLink)
                if(type == TRADING_HOUSE_FILTER_TYPE_ITEM) then
                    isValid = isValid and contains(values, itemType)
                else
                    isValid = isValid and contains(values, specializedItemType)
                end
            end
            if(not isValid) then break end
        end
        return isValid
    end
    return false
end

local DEFAULT_INVENTORY_TOP_OFFSET_Y = ZO_SCENE_MENU_HEIGHT
local BACKPACK_TRADING_HOUSE_LAYOUT_FRAGMENT_BASIC = ZO_BackpackLayoutFragment:New(
    {
        width = 650,
        inventoryTopOffsetY = DEFAULT_INVENTORY_TOP_OFFSET_Y,
        backpackOffsetY = 128 - MINOR_BUTTON_SIZE,
        sortByOffsetY = 96 - MINOR_BUTTON_SIZE,
        sortByHeaderWidth = 600,
        sortByNameWidth = 341,
        additionalFilter = SalesCategoryFilter,
        useSearchBar = true,
        hideTabBar = true
    })

local BACKPACK_TRADING_HOUSE_LAYOUT_FRAGMENT_ADVANCED = ZO_BackpackLayoutFragment:New(
    {
        width = 650,
        inventoryTopOffsetY = DEFAULT_INVENTORY_TOP_OFFSET_Y,
        backpackOffsetY = 128 + 8,
        sortByOffsetY = 96 + 8,
        sortByHeaderWidth = 600,
        sortByNameWidth = 341,
        additionalFilter = SalesCategoryFilter,
        useSearchBar = true,
        hideTabBar = true
    })

AGS.internal.BACKPACK_TRADING_HOUSE_LAYOUT_FRAGMENT_BASIC = BACKPACK_TRADING_HOUSE_LAYOUT_FRAGMENT_BASIC
AGS.internal.BACKPACK_TRADING_HOUSE_LAYOUT_FRAGMENT_ADVANCED = BACKPACK_TRADING_HOUSE_LAYOUT_FRAGMENT_ADVANCED

local function InitializeLibFilterHooks()
    -- let libFilters hook into our custom fragments to ensure compatibility with other addons
    local libFilters = LibFilters3 or LibFilters2 or (LibStub and LibStub("LibFilters-2.0", true))
    if(libFilters) then
        libFilters:HookAdditionalFilter(LF_GUILDSTORE_SELL, BACKPACK_TRADING_HOUSE_LAYOUT_FRAGMENT_BASIC)
        libFilters:HookAdditionalFilter(LF_GUILDSTORE_SELL, BACKPACK_TRADING_HOUSE_LAYOUT_FRAGMENT_ADVANCED)
        InitializeLibFilterHooks = function() end
    end
end

function SalesCategorySelector:HandleChange()
    InitializeLibFilterHooks()
    local filters = FILTER_PRESETS[self.category].subcategories
    local subcategory = self.subcategory[self.category]
    currentLayout = BACKPACK_TRADING_HOUSE_LAYOUT_FRAGMENT_BASIC.layoutData

    if(subcategory) then
        if(self.category == ITEMFILTERTYPE_CRAFTING and subcategory == 11) then -- ugly special cases
            filters = ALL_CRAFTING_FILTERS
        else
            filters = filters[subcategory].filters
        end
        currentLayout = BACKPACK_TRADING_HOUSE_LAYOUT_FRAGMENT_ADVANCED.layoutData
    end
    if(filters ~= currentFilterValues) then
        currentFilterValues = filters
        self:RefreshLayout()
    end

    if(not self.fireChangeCallback) then
        self.fireChangeCallback = zo_callLater(function()
            self.fireChangeCallback = nil
            CALLBACK_MANAGER:FireCallbacks(self.callbackName, self)
        end, 100)
    end
end

function SalesCategorySelector:RefreshLayout()
    PLAYER_INVENTORY:ApplyBackpackLayout(DEFAULT_LAYOUT) -- need to force a refresh because we reuse fragments
    PLAYER_INVENTORY:ApplyBackpackLayout(currentLayout)
end

function SalesCategorySelector:SetBasicLayout()
    PLAYER_INVENTORY:ApplyBackpackLayout(DEFAULT_LAYOUT) -- need to force a refresh because we reuse fragments
    PLAYER_INVENTORY:ApplyBackpackLayout(BACKPACK_TRADING_HOUSE_LAYOUT_FRAGMENT_BASIC.layoutData)
end

function SalesCategorySelector:ResetLayout()
    PLAYER_INVENTORY:ApplyBackpackLayout(BACKPACK_MENU_BAR_LAYOUT_FRAGMENT.layoutData) -- required to make guild bank and other inventories look normal when advanced filters is used
end

function SalesCategorySelector:Reset()
    self.mainGroup.defaultButton:Press()
    for _, group in pairs(self.group) do
        group.defaultButton:Press()
    end
end

-- category[;subcategory]
function SalesCategorySelector:Serialize()
    local category = self.category
    local state = tostring(category)

    local subcategory = self.subcategory[category]
    if(subcategory) then
        state = state .. ";" .. tostring(subcategory)
    end

    return state
end

function SalesCategorySelector:Deserialize(state)
    local values = {zo_strsplit(";", state)}

    for index, value in ipairs(values) do
        if(index == 1) then
            for _, button in pairs(self.mainGroup.buttons) do
                if(button.value == tonumber(value)) then button:Press() break end
            end
        elseif(index == 2) then
            for _, button in pairs(self.group[self.category].buttons) do
                if(button.value == tonumber(value)) then button:Press() break end
            end
        end
    end
    local category = self.category
end
