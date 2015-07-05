local L = AwesomeGuildStore.Localization

local SUBFILTER_WEAPON_TRAITS, SUBFILTER_WEAPON_ENCHANTMENTS, SUBFILTER_WEAPON_ONEHANDED, SUBFILTER_WEAPON_TWOHANDED, SUBFILTER_WEAPON_STAFF = 1, 2, 3, 4, 5
local SUBFILTER_ARMOR_SLOTS, SUBFILTER_ARMOR_TRAITS, SUBFILTER_ARMOR_ENCHANTMENTS, SUBFILTER_JEWELRY_TRAITS, SUBFILTER_JEWELRY_ENCHANTMENTS = 6, 7, 8, 9, 10
local SUBFILTER_BLACKSMITHING_MATERIALS, SUBFILTER_CLOTHING_MATERIALS, SUBFILTER_WOODWORKING_MATERIALS, SUBFILTER_ALCHEMY_MATERIALS = 11, 12, 13, 14
local SUBFILTER_ENCHANTING_MATERIALS, SUBFILTER_GLYPHS, SUBFILTER_JEWELRY_TYPE, SUBFILTER_STYLE_MATERIALS = 15, 16, 17, 18
local SUBFILTER_RECIPE_KNOWLEDGE, SUBFILTER_MOTIF_KNOWLEDGE, SUBFILTER_TRAIT_KNOWLEDGE, SUBFILTER_RUNE_KNOWLEDGE = 19, 20, 21, 22

AwesomeGuildStore.FILTER_PRESETS = {
	[ITEMFILTERTYPE_ALL] = {
		name = "All",
		label = L["FILTER_CATEGORY_ALL"],
		texture = "EsoUI/Art/Inventory/inventory_tabIcon_all_%s.dds",
		isDefault = true,
		subcategories = {}
	},
	[ITEMFILTERTYPE_WEAPONS] = {
		name = "Weapon",
		label = L["FILTER_CATEGORY_WEAPON"],
		texture = "EsoUI/Art/Inventory/inventory_tabIcon_weapons_%s.dds",
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
					SUBFILTER_TRAIT_KNOWLEDGE
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
					SUBFILTER_TRAIT_KNOWLEDGE
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
					SUBFILTER_TRAIT_KNOWLEDGE
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
					SUBFILTER_TRAIT_KNOWLEDGE
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
					SUBFILTER_TRAIT_KNOWLEDGE
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
					SUBFILTER_TRAIT_KNOWLEDGE
				},
			}
		}
	},
	[ITEMFILTERTYPE_ARMOR] = {
		name = "Armor",
		label = L["FILTER_CATEGORY_ARMOR"],
		texture = "EsoUI/Art/Inventory/inventory_tabIcon_armor_%s.dds",
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
					SUBFILTER_TRAIT_KNOWLEDGE
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
					SUBFILTER_TRAIT_KNOWLEDGE
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
					SUBFILTER_TRAIT_KNOWLEDGE
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
					SUBFILTER_TRAIT_KNOWLEDGE
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
					SUBFILTER_TRAIT_KNOWLEDGE
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
		subcategories = {
			{
				label = L["FILTER_SUBCATEGORY_ALL"],
				texture = "EsoUI/Art/Inventory/inventory_tabIcon_all_%s.dds",
				isDefault = true,
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_FOOD, ITEMTYPE_DRINK, ITEMTYPE_RECIPE, ITEMTYPE_POTION, ITEMTYPE_RACIAL_STYLE_MOTIF, ITEMTYPE_CONTAINER, ITEMTYPE_AVA_REPAIR }
				},
			},
			{
				label = L["FILTER_SUBCATEGORY_FOOD"],
				texture = "EsoUI/Art/Crafting/provisioner_indexIcon_meat_%s.dds",
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_FOOD },
				},
			},
			{
				label = L["FILTER_SUBCATEGORY_DRINK"],
				texture = "EsoUI/Art/Crafting/provisioner_indexIcon_beer_%s.dds",
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_DRINK },
				},
			},
			{
				label = L["FILTER_SUBCATEGORY_RECIPE"],
				texture = "EsoUI/Art/Guild/tabIcon_roster_%s.dds",
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_RECIPE },
				},
				subfilters = {
					SUBFILTER_RECIPE_KNOWLEDGE
				},
			},
			{
				label = L["FILTER_SUBCATEGORY_POTION"],
				texture = "EsoUI/Art/Inventory/inventory_tabIcon_consumables_%s.dds",
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_POTION },
				},
			},
			{
				label = L["FILTER_SUBCATEGORY_MOTIF"],
				texture = "EsoUI/Art/MainMenu/menuBar_journal_%s.dds",
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
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_CONTAINER },
				},
			},
			{
				label = L["FILTER_SUBCATEGORY_REPAIR"],
				texture = "EsoUI/Art/Vendor/vendor_tabIcon_repair_%s.dds",
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_AVA_REPAIR },
				},
			}
		}
	},
	[ITEMFILTERTYPE_CRAFTING] = {
		name = "Crafting",
		label = L["FILTER_CATEGORY_CRAFTING"],
		texture = "EsoUI/Art/Inventory/inventory_tabIcon_crafting_%s.dds",
		subcategories = {
			{
				label = L["FILTER_SUBCATEGORY_BLACKSMITHING"],
				texture = "EsoUI/Art/Crafting/smithing_tabIcon_refine_%s.dds",
				isDefault = true,
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_BLACKSMITHING_RAW_MATERIAL, ITEMTYPE_BLACKSMITHING_MATERIAL, ITEMTYPE_BLACKSMITHING_BOOSTER },
				},
				subfilters = {
					SUBFILTER_BLACKSMITHING_MATERIALS
				},
			},
			{
				label = L["FILTER_SUBCATEGORY_CLOTHING"],
				texture = "AwesomeGuildStore/images/armor/chest_%s.dds",
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_CLOTHIER_RAW_MATERIAL, ITEMTYPE_CLOTHIER_MATERIAL, ITEMTYPE_CLOTHIER_BOOSTER },
				},
				subfilters = {
					SUBFILTER_CLOTHING_MATERIALS
				},
			},
			{
				label = L["FILTER_SUBCATEGORY_WOODWORKING"],
				texture = "EsoUI/Art/WorldMap/map_ava_tabIcon_woodmill_%s.dds",
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_WOODWORKING_RAW_MATERIAL, ITEMTYPE_WOODWORKING_MATERIAL, ITEMTYPE_WOODWORKING_BOOSTER },
				},
				subfilters = {
					SUBFILTER_WOODWORKING_MATERIALS
				},
			},
			{
				label = L["FILTER_SUBCATEGORY_ALCHEMY"],
				texture = "EsoUI/Art/Crafting/alchemy_tabIcon_reagent_%s.dds",
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_ALCHEMY_BASE, ITEMTYPE_REAGENT },
				},
				subfilters = {
					SUBFILTER_ALCHEMY_MATERIALS
				},
			},
			{
				label = L["FILTER_SUBCATEGORY_ENCHANTING"],
				texture = "EsoUI/Art/Crafting/enchantment_tabIcon_potency_%s.dds",
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
				texture = "EsoUI/Art/Crafting/provisioner_indexIcon_meat_%s.dds",
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_INGREDIENT },
				},
			},
			{
				label = L["FILTER_SUBCATEGORY_STYLE"],
				texture = "AwesomeGuildStore/images/armor/costume_%s.dds",
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
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_WEAPON_TRAIT },
				}
			},
			{
				label = L["FILTER_SUBCATEGORY_ARMORTRAIT"],
				texture = "EsoUI/Art/Crafting/smithing_tabIcon_armorSet_%s.dds",
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_ARMOR_TRAIT },
				}
			}
		}
	},
	[ITEMFILTERTYPE_MISCELLANEOUS] = {
		name = "Misc",
		label = L["FILTER_CATEGORY_MISC"],
		texture = "EsoUI/Art/Inventory/inventory_tabIcon_misc_%s.dds",
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
					SUBFILTER_GLYPHS
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
			},
			{
				label = L["FILTER_SUBCATEGORY_BAIT"],
				texture = "AwesomeGuildStore/images/misc/bait_%s.dds",
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
				label = L["SUBFILTER_WEAPON_TRAIT_WEIGHTED"],
				texture = "EsoUI/Art/Inventory/inventory_tabicon_misc_%s.dds",
				value = ITEM_TRAIT_TYPE_WEAPON_WEIGHTED,
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
				label = L["SUBFILTER_WEAPON_TYPE_MACE"],
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
				label = L["SUBFILTER_WEAPON_TYPE_AXE"],
				texture = "AwesomeGuildStore/images/weapon/axe_%s.dds",
				value = WEAPONTYPE_TWO_HANDED_AXE,
			},
			{
				label = L["SUBFILTER_WEAPON_TYPE_MACE"],
				texture = "AwesomeGuildStore/images/weapon/mace_%s.dds",
				value = WEAPONTYPE_TWO_HANDED_HAMMER,
			},
			{
				label = L["SUBFILTER_WEAPON_TYPE_SWORD"],
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
				label = L["SUBFILTER_ARMOR_TRAIT_EXPLORATION"],
				texture = "EsoUI/Art/Progression/progression_indexIcon_world_%s.dds",
				value = ITEM_TRAIT_TYPE_ARMOR_EXPLORATION,
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
		filter = TRADING_HOUSE_FILTER_TYPE_ITEM,
		buttons = {
			{
				label = L["SUBFILTER_INGREDIENT_TYPE_SOLVENT"],
				texture = "EsoUI/Art/Crafting/alchemy_tabIcon_solvent_%s.dds",
				value = ITEMTYPE_ALCHEMY_BASE,
			},
			{
				label = L["SUBFILTER_INGREDIENT_TYPE_REAGENT"],
				texture = "EsoUI/Art/Crafting/alchemy_tabIcon_reagent_%s.dds",
				value = ITEMTYPE_REAGENT,
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
}
