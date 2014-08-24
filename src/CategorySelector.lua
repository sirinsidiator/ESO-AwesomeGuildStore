local L = AwesomeGuildStore.Localization

local MAJOR_BUTTON_SIZE = 46
local MINOR_BUTTON_SIZE = 32
local SUBFILTER_BUTTON_SIZE = 32
local RESET_BUTTON_SIZE = 18
local RESET_BUTTON_TEXTURE = "EsoUI/Art/Buttons/decline_%s.dds"
local SUBFILTER_WEAPON_TRAITS, SUBFILTER_WEAPON_ENCHANTMENTS, SUBFILTER_WEAPON_ONEHANDED, SUBFILTER_WEAPON_TWOHANDED, SUBFILTER_WEAPON_STAFF = 1, 2, 3, 4, 5
local SUBFILTER_ARMOR_SLOTS, SUBFILTER_ARMOR_TRAITS, SUBFILTER_ARMOR_ENCHANTMENTS, SUBFILTER_JEWELRY_TRAITS, SUBFILTER_JEWELRY_ENCHANTMENTS = 6, 7, 8, 9, 10
local SUBFILTER_BLACKSMITHING_MATERIALS, SUBFILTER_CLOTHING_MATERIALS, SUBFILTER_WOODWORKING_MATERIALS, SUBFILTER_ALCHEMY_MATERIALS = 11, 12, 13, 14
local SUBFILTER_ENCHANTING_MATERIALS, SUBFILTER_GLYPHS = 15, 16

local FILTER_PRESETS = {
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
					[TRADING_HOUSE_FILTER_TYPE_EQUIP] = { EQUIP_TYPE_HEAD, EQUIP_TYPE_CHEST, EQUIP_TYPE_SHOULDERS, EQUIP_TYPE_WAIST, EQUIP_TYPE_LEGS, EQUIP_TYPE_FEET, EQUIP_TYPE_HAND }
				},
				subfilters = {
					SUBFILTER_ARMOR_SLOTS,
					SUBFILTER_ARMOR_TRAITS,
					SUBFILTER_ARMOR_ENCHANTMENTS,
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
				},
			},
			{
				label = L["FILTER_SUBCATEGORY_RING"],
				texture = "AwesomeGuildStore/images/armor/ring_%s.dds",
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_EQUIP] = { EQUIP_TYPE_RING },
				},
				subfilters = {
					SUBFILTER_JEWELRY_TRAITS,
					SUBFILTER_JEWELRY_ENCHANTMENTS,
				},
			},
			{
				label = L["FILTER_SUBCATEGORY_NECK"],
				texture = "AwesomeGuildStore/images/armor/neck_%s.dds",
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_EQUIP] = { EQUIP_TYPE_NECK },
				},
				subfilters = {
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
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_FOOD, ITEMTYPE_DRINK, ITEMTYPE_RECIPE, ITEMTYPE_POTION, ITEMTYPE_RACIAL_STYLE_MOTIF, ITEMTYPE_AVA_REPAIR }
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
			},
			{
				label = L["FILTER_SUBCATEGORY_REPAIR"],
				texture = "EsoUI/Art/Vendor/vendor_tabIcon_repair_%s.dds",
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_AVA_REPAIR },
				}
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
					SUBFILTER_ENCHANTING_MATERIALS
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
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_STYLE_MATERIAL },
				}
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
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_GLYPH_WEAPON, ITEMTYPE_GLYPH_JEWELRY, ITEMTYPE_GLYPH_ARMOR, ITEMTYPE_SOUL_GEM, ITEMTYPE_SIEGE, ITEMTYPE_LURE, ITEMTYPE_TOOL },
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
		},
	},
}

local SUBFILTER_PRESETS = {
	[SUBFILTER_WEAPON_TRAITS] = {
		label = L["SUBFILTER_WEAPON_TRAIT_LABEL"],
		x = 0,
		y = 0,
		size = SUBFILTER_BUTTON_SIZE,
		perRow = 5,
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
		},
	},
	[SUBFILTER_WEAPON_ENCHANTMENTS] = {},
	[SUBFILTER_WEAPON_ONEHANDED] = {
		label = L["SUBFILTER_WEAPON_TYPE_LABEL"],
		x = 0,
		y = 90,
		size = SUBFILTER_BUTTON_SIZE,
		perRow = 5,
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
		label = L["SUBFILTER_WEAPON_TYPE_LABEL"],
		x = 0,
		y = 90,
		size = SUBFILTER_BUTTON_SIZE,
		perRow = 5,
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
		label = L["SUBFILTER_WEAPON_TYPE_LABEL"],
		x = 0,
		y = 90,
		size = SUBFILTER_BUTTON_SIZE,
		perRow = 5,
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
		label = L["SUBFILTER_ARMOR_TYPE_LABEL"],
		x = 0,
		y = 90,
		size = SUBFILTER_BUTTON_SIZE,
		perRow = 5,
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
		label = L["SUBFILTER_ARMOR_TRAIT_LABEL"],
		x = 0,
		y = 0,
		size = SUBFILTER_BUTTON_SIZE,
		perRow = 5,
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
		},
	},
	[SUBFILTER_ARMOR_ENCHANTMENTS] = {},
	[SUBFILTER_JEWELRY_TRAITS] = {
		label = L["SUBFILTER_JEWELRY_TRAIT_LABEL"],
		x = 0,
		y = 0,
		size = SUBFILTER_BUTTON_SIZE,
		perRow = 5,
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
	[SUBFILTER_JEWELRY_ENCHANTMENTS] = {},
	[SUBFILTER_BLACKSMITHING_MATERIALS] = {
		label = L["SUBFILTER_MATERIAL_TYPE_LABEL"],
		x = 0,
		y = 0,
		size = SUBFILTER_BUTTON_SIZE,
		perRow = 5,
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
		label = L["SUBFILTER_MATERIAL_TYPE_LABEL"],
		x = 0,
		y = 0,
		size = SUBFILTER_BUTTON_SIZE,
		perRow = 5,
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
		label = L["SUBFILTER_MATERIAL_TYPE_LABEL"],
		x = 0,
		y = 0,
		size = SUBFILTER_BUTTON_SIZE,
		perRow = 5,
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
	[SUBFILTER_ALCHEMY_MATERIALS] = {
		label = L["SUBFILTER_INGREDIENT_TYPE_LABEL"],
		x = 0,
		y = 0,
		size = SUBFILTER_BUTTON_SIZE,
		perRow = 5,
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
		label = L["SUBFILTER_RUNE_TYPE_LABEL"],
		x = 0,
		y = 0,
		size = SUBFILTER_BUTTON_SIZE,
		perRow = 5,
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
		label = L["SUBFILTER_GLYPH_TYPE_LABEL"],
		x = 0,
		y = 0,
		size = SUBFILTER_BUTTON_SIZE,
		perRow = 5,
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
}

local RegisterForEvent = AwesomeGuildStore.RegisterForEvent
local ButtonGroup = AwesomeGuildStore.ButtonGroup
local ToggleButton = AwesomeGuildStore.ToggleButton

local CategorySelector = ZO_Object:Subclass()
AwesomeGuildStore.CategorySelector = CategorySelector

function CategorySelector:New(parent, name)
	local selector = ZO_Object.New(self)
	selector.callbackName = name .. "Changed"

	local container = parent:CreateControl(name .. "Container", CT_CONTROL)
	container:SetResizeToFitDescendents(true)
	selector.control = container
	selector.group = {}
	selector.subfilters = {}
	selector.category = ITEMFILTERTYPE_ALL
	selector.subcategory = {}

	local group = ButtonGroup:New(container, name .. "MainGroup", 0, 0)
	local label = group.control:CreateControl(name .. "Label", CT_LABEL)
	label:SetFont("ZoFontWinH4")
	label:SetModifyTextType(MODIFY_TEXT_TYPE_UPPERCASE)
	label:SetAnchor(TOPLEFT, group.control, TOPLEFT, 0, 13)
	group.label = label

	local divider = group.control:CreateControl(name .. "Divider", CT_TEXTURE)
	divider:SetDimensions(600, 4)
	divider:SetTexture("EsoUI/Art/Miscellaneous/centerscreen_topDivider.dds")
	divider:SetAnchor(TOPCENTER, group.control, TOPCENTER, 0, MAJOR_BUTTON_SIZE + 2)

	selector.mainGroup = group

	for category, preset in pairs(FILTER_PRESETS) do
		selector:CreateCategoryButton(group, category, preset)
		selector:CreateSubcategory(name, category, preset)
	end

	for subfilterId, preset in pairs(SUBFILTER_PRESETS) do
		selector.subfilters[subfilterId] = selector:CreateSubfilter(name .. "SubFilter" .. subfilterId, preset)
	end

	local function GetCurrentFilters()
		local filters = FILTER_PRESETS[selector.category].subcategories
		local subfilters
		local showTabards = false
		local subcategory = selector.subcategory[selector.category]
		if(subcategory) then
			if(filters[subcategory].showTabards) then showTabards = true end
			subfilters = filters[subcategory].subfilters
			filters = filters[subcategory].filters
		end
		return filters, subfilters, showTabards
	end

	local showTabardsInResult = false
	ZO_PreHook(TRADING_HOUSE.m_search, "InternalExecuteSearch", function(self)
		local filters, subfilters, showTabards = GetCurrentFilters()
		showTabardsInResult = showTabards

		for type, filterValues in pairs(filters) do
			self.m_filters[type].values = ZO_ShallowTableCopy(filterValues) -- we have to copy them, otherwise they will be cleared on the next search
		end

		if(subfilters) then
			for _, subfilterId in ipairs(subfilters) do
				local buttonGroup = selector.subfilters[subfilterId]
				if(buttonGroup) then
					local subfilterValues = {}
					for _, button in pairs(buttonGroup.buttons) do
						if(button:IsPressed()) then
							table.insert(subfilterValues, button.value)
						end
					end
					if(#subfilterValues > 0) then
						self.m_filters[buttonGroup.type].values = subfilterValues
					end
				end
			end
		end
	end)

	RegisterForEvent(EVENT_TRADING_HOUSE_SEARCH_RESULTS_RECEIVED, function(_, guildId, numItemsOnPage, currentPage, hasMorePages)
		if(showTabardsInResult) then
			TRADING_HOUSE:AddHeraldryItems(true) -- ignore the filters for now; maybe some day we will use it correctly and can let it check the requirements
		end
	end)

	return selector
end

function CategorySelector:CreateSubfilter(name, subfilterPreset)
	if(not subfilterPreset.buttons) then return end
	local group = self:CreateSubfilterGroup(name .. "Group", subfilterPreset)
	group.label = group.control:CreateControl(name .. "Label", CT_LABEL)
	group.label:SetFont("ZoFontWinH4")
	group.label:SetText(subfilterPreset.label .. ":")
	group.label:SetAnchor(TOPLEFT, group.control, TOPLEFT, 0, 0)
	for index, buttonPreset in ipairs(subfilterPreset.buttons) do
		self:CreateSubfilterButton(group, index, buttonPreset, subfilterPreset)
	end

	local resetButton = CreateControlFromVirtual(name .. "ResetButton", group.control, "ZO_DefaultButton")
	resetButton:SetNormalTexture(RESET_BUTTON_TEXTURE:format("up"))
	resetButton:SetPressedTexture(RESET_BUTTON_TEXTURE:format("down"))
	resetButton:SetMouseOverTexture(RESET_BUTTON_TEXTURE:format("over"))
	resetButton:SetEndCapWidth(0)
	resetButton:SetDimensions(RESET_BUTTON_SIZE, RESET_BUTTON_SIZE)
	resetButton:SetAnchor(TOPRIGHT, group.label, TOPLEFT, 196, 0)
	resetButton:SetHidden(true)
	resetButton:SetHandler("OnMouseUp",function(control, button, isInside)
		if(button == 1 and isInside) then
			group:ReleaseAllButtons()
		end
	end)
	resetButton:SetHandler("OnMouseEnter", function()
		InitializeTooltip(InformationTooltip)
		InformationTooltip:ClearAnchors()
		InformationTooltip:SetOwner(resetButton, BOTTOM, 5, 0)
		SetTooltipText(InformationTooltip, L["RESET_FILTER_LABEL_TEMPLATE"]:format(subfilterPreset.label))
	end)
	resetButton:SetHandler("OnMouseExit", function()
		ClearTooltip(InformationTooltip)
	end)
	group.resetButton = resetButton

	return group
end

function CategorySelector:CreateSubfilterGroup(name, subfilterPreset)
	local parent = self.control:GetParent()
	local group = ButtonGroup:New(parent, name, 0, 0)
	group.control:ClearAnchors()
	group.control:SetAnchor(TOPLEFT, parent:GetNamedChild("Header"), BOTTOMLEFT, subfilterPreset.x, subfilterPreset.y)
	group.control:SetHidden(true)
	group.type = subfilterPreset.filter
	return group
end

function CategorySelector:CreateSubfilterButton(group, index, buttonPreset, subfilterPreset)
	local x = subfilterPreset.size * (0.5 + math.mod(index - 1, subfilterPreset.perRow))
	local y = 20 + subfilterPreset.size * math.floor((index - 1) / subfilterPreset.perRow)
	local button = ToggleButton:New(group.control, group.control:GetName() .. "Button" .. index, buttonPreset.texture, x, y, subfilterPreset.size, subfilterPreset.size, buttonPreset.label)
	button.HandlePress = function()
		group.resetButton:SetHidden(false)
		if(group.pressedButtonCount == 8) then
			ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, L["WARNING_SUBFILTER_LIMIT"])
			return false
		end
		self:HandleChange()
		return true
	end
	button.HandleRelease = function(control, fromGroup)
		group.resetButton:SetHidden(group.pressedButtonCount == 1)
		self:HandleChange()
		return true
	end
	button.value = buttonPreset.value
	button.index = index
	group:AddButton(button)
	return button
end

function CategorySelector:UpdateSubfilterVisibility()
	local subfilters = FILTER_PRESETS[self.category].subcategories
	local subcategory = self.subcategory[self.category]
	if(subcategory) then subfilters = subfilters[subcategory].subfilters end

	for _, subfilter in pairs(self.subfilters) do
		subfilter.control:SetHidden(true)
	end
	if(subfilters) then
		for _, subfilterId in ipairs(subfilters) do
			if(self.subfilters[subfilterId]) then
				self.subfilters[subfilterId].control:SetHidden(false)
			end
		end
	end
end

function CategorySelector:CreateSubcategory(name, category, categoryPreset)
	if(#categoryPreset.subcategories == 0) then return end
	local group = self:CreateSubcategoryGroup(name .. categoryPreset.name .. "Group", category)
	for subcategory, preset in pairs(categoryPreset.subcategories) do
		self:CreateSubcategoryButton(group, subcategory, preset)
	end
end

function CategorySelector:CreateCategoryButton(group, category, preset)
	local button = ToggleButton:New(group.control, group.control:GetName() .. preset.name .. "Button", preset.texture, 180 + MAJOR_BUTTON_SIZE * category, 0, MAJOR_BUTTON_SIZE, MAJOR_BUTTON_SIZE, preset.label)
	button.HandlePress = function()
		group:ReleaseAllButtons()
		self.category = category
		group.label:SetText(preset.label)
		if(self.group[category]) then
			self.group[category].control:SetHidden(false)
		end
		self:UpdateSubfilterVisibility()
		self:HandleChange()
		return true
	end
	button.HandleRelease = function(control, fromGroup)
		if(fromGroup) then
			if(self.group[category]) then
				self.group[category].control:SetHidden(true)
			end
			return true
		end
	end
	button.value = category
	if(preset.isDefault) then
		group.defaultButton = button
		button:Press()
	end
	group:AddButton(button)
	return button
end

function CategorySelector:CreateSubcategoryGroup(name, category)
	local group = ButtonGroup:New(self.control, name, 0, MAJOR_BUTTON_SIZE + 4)
	group.category = category

	local label = group.control:CreateControl(name .. "Label", CT_LABEL)
	label:SetFont("ZoFontWinH5")
	label:SetModifyTextType(MODIFY_TEXT_TYPE_UPPERCASE)
	label:SetAnchor(TOPLEFT, group.control, TOPLEFT, 0, 7)
	group.label = label

	local divider = group.control:CreateControl(name .. "Divider", CT_TEXTURE)
	divider:SetDimensions(500, 3)
	divider:SetTexture("EsoUI/Art/Miscellaneous/centerscreen_topDivider.dds")
	divider:SetAnchor(TOPCENTER, group.control, TOPCENTER, 50, MINOR_BUTTON_SIZE + 2)

	self.group[category] = group
	group.control:SetHidden(true)
	return group
end

function CategorySelector:CreateSubcategoryButton(group, subcategory, preset)
	local button = ToggleButton:New(group.control, group.control:GetName() .. "SubcategoryButton" .. subcategory, preset.texture, 170 + MINOR_BUTTON_SIZE * subcategory, 0, MINOR_BUTTON_SIZE, MINOR_BUTTON_SIZE, preset.label)
	button.HandlePress = function()
		group:ReleaseAllButtons()
		group.label:SetText(preset.label)
		self.subcategory[group.category] = subcategory
		self:UpdateSubfilterVisibility()
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

function CategorySelector:HandleChange()
	if(not self.fireChangeCallback) then
		self.fireChangeCallback = zo_callLater(function()
			self.fireChangeCallback = nil
			CALLBACK_MANAGER:FireCallbacks(self.callbackName, self)
		end, 100)
	end
end

function CategorySelector:Reset()
	self.mainGroup.defaultButton:Press()
	for _, group in pairs(self.group) do
		group.defaultButton:Press()
	end
	for _, subfilter in pairs(self.subfilters) do
		subfilter:ReleaseAllButtons()
	end
end

-- category[;subcategory[;(subfilterId,subfilterState)*]]
function CategorySelector:Serialize()
	local category = self.category
	local state = tostring(category)

	local subcategory = self.subcategory[category]
	if(subcategory) then
		state = state .. ";" .. tostring(subcategory)

		local subfilters = FILTER_PRESETS[category].subcategories[subcategory].subfilters
		if(subfilters) then
			for _, subfilterId in ipairs(subfilters) do
				local buttonGroup = self.subfilters[subfilterId]
				if(buttonGroup) then
					local subfilterValues = 0
					for _, button in pairs(buttonGroup.buttons) do
						if(button:IsPressed()) then
							subfilterValues = subfilterValues + math.pow(2, button.index)
						end
					end
					if(subfilterValues > 0) then
						state = state .. ";" .. tostring(subfilterId) .. "," .. tostring(subfilterValues)
					end
				end
			end
		end
	end

	return state
end

function CategorySelector:Deserialize(state)
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
		else
			local subfilterId, subfilterValues = zo_strsplit(",", value)
			local buttonGroup = self.subfilters[tonumber(subfilterId)]
			assert(subfilterId and subfilterValues and buttonGroup)
			subfilterValues = tonumber(subfilterValues)
			local buttonValue = 0
			while subfilterValues > 0 do
				for _, button in pairs(buttonGroup.buttons) do
					if(buttonValue == button.index) then
						if(math.mod(subfilterValues, 2) == 1) then
							button:Press()
						else
							button:Release()
						end
						break
					end
				end
				subfilterValues = math.floor(subfilterValues / 2)
				buttonValue = buttonValue + 1
			end
		end
	end
	local category = self.category
end
