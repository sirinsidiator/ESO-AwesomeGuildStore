local MAJOR_BUTTON_SIZE = 46
local MINOR_BUTTON_SIZE = 32
local SUBFILTER_BUTTON_SIZE = 32
local RESET_BUTTON_SIZE = 18
local RESET_BUTTON_TEXTURE = "EsoUI/Art/Buttons/decline_%s.dds"
local CATEGORY_ALL, CATEGORY_WEAPON, CATEGORY_ARMOR, CATEGORY_CONSUMABLE, CATEGORY_CRAFTING, CATEGORY_MISC = 1, 2, 3, 4, 5, 6
local SUBCATEGORY_WEAPON_ALL, SUBCATEGORY_WEAPON_ONE_HAND, SUBCATEGORY_WEAPON_TWO_HAND, SUBCATEGORY_WEAPON_BOW, SUBCATEGORY_WEAPON_DESTRUCTION, SUBCATEGORY_WEAPON_RESTORATION = 1, 2, 3, 4, 5, 6
local SUBCATEGORY_ARMOR_ALL, SUBCATEGORY_ARMOR_LIGHT, SUBCATEGORY_ARMOR_MEDIUM, SUBCATEGORY_ARMOR_HEAVY, SUBCATEGORY_ARMOR_SHIELD, SUBCATEGORY_ARMOR_RING, SUBCATEGORY_ARMOR_NECK, SUBCATEGORY_ARMOR_COSTUME = 1, 2, 3, 4, 5, 6, 7, 8
local SUBCATEGORY_CONSUMABLE_ALL, SUBCATEGORY_CONSUMABLE_FOOD, SUBCATEGORY_CONSUMABLE_DRINK, SUBCATEGORY_CONSUMABLE_RECIPE, SUBCATEGORY_CONSUMABLE_POTION, SUBCATEGORY_CONSUMABLE_MOTIF, SUBCATEGORY_CONSUMABLE_REPAIR = 1, 2, 3, 4, 5, 6, 7
local SUBCATEGORY_CRAFTING_BLACKSMITHING, SUBCATEGORY_CRAFTING_CLOTHING, SUBCATEGORY_CRAFTING_WOODWORKING, SUBCATEGORY_CRAFTING_ALCHEMY, SUBCATEGORY_CRAFTING_ENCHANTING, SUBCATEGORY_CRAFTING_PROVISIONING, SUBCATEGORY_CRAFTING_STYLE, SUBCATEGORY_CRAFTING_WEAPONTRAIT, SUBCATEGORY_CRAFTING_ARMORTRAIT = 1, 2, 3, 4, 5, 6, 7, 8, 9
local SUBCATEGORY_MISC_ALL, SUBCATEGORY_MISC_GLYPHS, SUBCATEGORY_MISC_SOULGEMS, SUBCATEGORY_MISC_SIEGE, SUBCATEGORY_MISC_BAIT, SUBCATEGORY_MISC_TOOLS = 1, 2, 3, 4, 5, 6
local SUBFILTER_WEAPON_TRAITS, SUBFILTER_WEAPON_ENCHANTMENTS, SUBFILTER_WEAPON_ONEHANDED, SUBFILTER_WEAPON_TWOHANDED, SUBFILTER_WEAPON_STAFF = 1, 2, 3, 4, 5
local SUBFILTER_ARMOR_SLOTS, SUBFILTER_ARMOR_TRAITS, SUBFILTER_ARMOR_ENCHANTMENTS, SUBFILTER_JEWELRY_TRAITS, SUBFILTER_JEWELRY_ENCHANTMENTS = 6, 7, 8, 9, 10
local SUBFILTER_BLACKSMITHING_MATERIALS, SUBFILTER_CLOTHING_MATERIALS, SUBFILTER_WOODWORKING_MATERIALS, SUBFILTER_ALCHEMY_MATERIALS = 11, 12, 13, 14
local SUBFILTER_ENCHANTING_MATERIALS, SUBFILTER_GLYPHS = 15, 16
local FILTER_PRESETS = {
	[CATEGORY_ALL] = {
		label = "All Items",
		texture = "EsoUI/Art/Inventory/inventory_tabIcon_all_%s.dds",
		isDefault = true,
		subcategories = {}
	},
	[CATEGORY_WEAPON] = {
		label = "Weapons",
		texture = "EsoUI/Art/Inventory/inventory_tabIcon_weapons_%s.dds",
		subcategories = {
			[SUBCATEGORY_WEAPON_ALL] = {
				label = "All Weapons",
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
			[SUBCATEGORY_WEAPON_ONE_HAND] = {
				label = "One Handed",
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
			[SUBCATEGORY_WEAPON_TWO_HAND] = {
				label = "Two Handed",
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
			[SUBCATEGORY_WEAPON_BOW] = {
				label = "Bow",
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
			[SUBCATEGORY_WEAPON_DESTRUCTION] = {
				label = "Destruction Staff",
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
			[SUBCATEGORY_WEAPON_RESTORATION] = {
				label = "Restoration Staff",
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
	[CATEGORY_ARMOR] = {
		label = "Armor",
		texture = "EsoUI/Art/Inventory/inventory_tabIcon_armor_%s.dds",
		subcategories = {
			[SUBCATEGORY_ARMOR_ALL] = {
				label = "All Armor",
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
			[SUBCATEGORY_ARMOR_HEAVY] = {
				label = "Heavy",
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
			[SUBCATEGORY_ARMOR_MEDIUM] = {
				label = "Medium",
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
			[SUBCATEGORY_ARMOR_LIGHT] = {
				label = "Light",
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
			[SUBCATEGORY_ARMOR_SHIELD] = {
				label = "Shield",
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
			[SUBCATEGORY_ARMOR_RING] = {
				label = "Ring",
				texture = "AwesomeGuildStore/images/armor/ring_%s.dds",
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_EQUIP] = { EQUIP_TYPE_RING },
				},
				subfilters = {
					SUBFILTER_JEWELRY_TRAITS,
					SUBFILTER_JEWELRY_ENCHANTMENTS,
				},
			},
			[SUBCATEGORY_ARMOR_NECK] = {
				label = "Neck",
				texture = "AwesomeGuildStore/images/armor/neck_%s.dds",
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_EQUIP] = { EQUIP_TYPE_NECK },
				},
				subfilters = {
					SUBFILTER_JEWELRY_TRAITS,
					SUBFILTER_JEWELRY_ENCHANTMENTS,
				},
			},
			[SUBCATEGORY_ARMOR_COSTUME] = {
				label = "Costumes",
				texture = "AwesomeGuildStore/images/armor/costume_%s.dds",
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_EQUIP] = { EQUIP_TYPE_COSTUME },
				}
			}
		}
	},

	[CATEGORY_CONSUMABLE] = {
		label = "Consumables",
		texture = "EsoUI/Art/Inventory/inventory_tabIcon_consumables_%s.dds",
		subcategories = {
			[SUBCATEGORY_CONSUMABLE_ALL] = {
				label = "All Consumables",
				texture = "EsoUI/Art/Inventory/inventory_tabIcon_all_%s.dds",
				isDefault = true,
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_FOOD, ITEMTYPE_DRINK, ITEMTYPE_RECIPE, ITEMTYPE_POTION, ITEMTYPE_RACIAL_STYLE_MOTIF, ITEMTYPE_AVA_REPAIR }
				},
			},
			[SUBCATEGORY_CONSUMABLE_FOOD] = {
				label = "Food",
				texture = "EsoUI/Art/Crafting/provisioner_indexIcon_meat_%s.dds",
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_FOOD },
				},
			},
			[SUBCATEGORY_CONSUMABLE_DRINK] = {
				label = "Drink",
				texture = "EsoUI/Art/Crafting/provisioner_indexIcon_beer_%s.dds",
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_DRINK },
				},
			},
			[SUBCATEGORY_CONSUMABLE_RECIPE] = {
				label = "Recipe",
				texture = "EsoUI/Art/Guild/tabIcon_roster_%s.dds",
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_RECIPE },
				},
			},
			[SUBCATEGORY_CONSUMABLE_POTION] = {
				label = "Potion",
				texture = "EsoUI/Art/Inventory/inventory_tabIcon_consumables_%s.dds",
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_POTION },
				},
			},
			[SUBCATEGORY_CONSUMABLE_MOTIF] = {
				label = "Motif",
				texture = "EsoUI/Art/MainMenu/menuBar_journal_%s.dds",
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_RACIAL_STYLE_MOTIF },
				},
			},
			[SUBCATEGORY_CONSUMABLE_REPAIR] = {
				label = "Repair",
				texture = "EsoUI/Art/Inventory/inventory_tabIcon_crafting_%s.dds",
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_AVA_REPAIR },
				}
			}
		}
	},
	[CATEGORY_CRAFTING] = {
		label = "Crafting",
		texture = "EsoUI/Art/Inventory/inventory_tabIcon_crafting_%s.dds",
		subcategories = {
			[SUBCATEGORY_CRAFTING_BLACKSMITHING] = {
				label = "Blacksmithing",
				texture = "EsoUI/Art/Crafting/smithing_tabIcon_refine_%s.dds",
				isDefault = true,
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_BLACKSMITHING_RAW_MATERIAL, ITEMTYPE_BLACKSMITHING_MATERIAL, ITEMTYPE_BLACKSMITHING_BOOSTER },
				},
				subfilters = {
					SUBFILTER_BLACKSMITHING_MATERIALS
				},
			},
			[SUBCATEGORY_CRAFTING_CLOTHING] = {
				label = "Clothing",
				texture = "AwesomeGuildStore/images/armor/chest_%s.dds",
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_CLOTHIER_RAW_MATERIAL, ITEMTYPE_CLOTHIER_MATERIAL, ITEMTYPE_CLOTHIER_BOOSTER },
				},
				subfilters = {
					SUBFILTER_CLOTHING_MATERIALS
				},
			},
			[SUBCATEGORY_CRAFTING_WOODWORKING] = {
				label = "Woodworking",
				texture = "EsoUI/Art/WorldMap/map_ava_tabIcon_woodmill_%s.dds",
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_WOODWORKING_RAW_MATERIAL, ITEMTYPE_WOODWORKING_MATERIAL, ITEMTYPE_WOODWORKING_BOOSTER },
				},
				subfilters = {
					SUBFILTER_WOODWORKING_MATERIALS
				},
			},
			[SUBCATEGORY_CRAFTING_ALCHEMY] = {
				label = "Alchemy",
				texture = "EsoUI/Art/Crafting/alchemy_tabIcon_reagent_%s.dds",
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_ALCHEMY_BASE, ITEMTYPE_REAGENT },
				},
				subfilters = {
					SUBFILTER_ALCHEMY_MATERIALS
				},
			},
			[SUBCATEGORY_CRAFTING_ENCHANTING] = {
				label = "Enchanting",
				texture = "EsoUI/Art/Crafting/enchantment_tabIcon_potency_%s.dds",
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_ENCHANTING_RUNE_ASPECT, ITEMTYPE_ENCHANTING_RUNE_ESSENCE, ITEMTYPE_ENCHANTING_RUNE_POTENCY },
				},
				subfilters = {
					SUBFILTER_ENCHANTING_MATERIALS
				},
			},
			[SUBCATEGORY_CRAFTING_PROVISIONING] = {
				label = "Provisioning",
				texture = "EsoUI/Art/Crafting/provisioner_indexIcon_meat_%s.dds",
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_INGREDIENT },
				},
			},
			[SUBCATEGORY_CRAFTING_STYLE] = {
				label = "Style",
				texture = "AwesomeGuildStore/images/armor/costume_%s.dds",
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_STYLE_MATERIAL },
				}
			},
			[SUBCATEGORY_CRAFTING_WEAPONTRAIT] = {
				label = "Weapon Trait",
				texture = "EsoUI/Art/Crafting/smithing_tabIcon_weaponSet_%s.dds",
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_WEAPON_TRAIT },
				}
			},
			[SUBCATEGORY_CRAFTING_ARMORTRAIT] = {
				label = "Armor Trait",
				texture = "EsoUI/Art/Crafting/smithing_tabIcon_armorSet_%s.dds",
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_ARMOR_TRAIT },
				}
			}
		}
	},
	[CATEGORY_MISC] = {
		label = "Miscellaneous",
		texture = "EsoUI/Art/Inventory/inventory_tabIcon_misc_%s.dds",
		subcategories = {
			[SUBCATEGORY_MISC_ALL] = {
				label = "All",
				texture = "EsoUI/Art/Inventory/inventory_tabIcon_all_%s.dds",
				isDefault = true,
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_GLYPH_WEAPON, ITEMTYPE_GLYPH_JEWELRY, ITEMTYPE_GLYPH_ARMOR, ITEMTYPE_SOUL_GEM, ITEMTYPE_SIEGE, ITEMTYPE_LURE, ITEMTYPE_TOOL },
				},
			},
			[SUBCATEGORY_MISC_GLYPHS] = {
				label = "Glyphs",
				texture = "AwesomeGuildStore/images/misc/glyphs_%s.dds",
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_GLYPH_WEAPON, ITEMTYPE_GLYPH_JEWELRY, ITEMTYPE_GLYPH_ARMOR },
				},
				subfilters = {
					SUBFILTER_GLYPHS
				},
			},
			[SUBCATEGORY_MISC_SOULGEMS] = {
				label = "Soul Gems",
				texture = "AwesomeGuildStore/images/misc/soulgem_%s.dds",
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_SOUL_GEM },
				},
			},
			[SUBCATEGORY_MISC_SIEGE] = {
				label = "Siege",
				texture = "EsoUI/Art/MainMenu/menuBar_ava_%s.dds",
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_SIEGE },
				},
			},
			[SUBCATEGORY_MISC_BAIT] = {
				label = "Bait",
				texture = "AwesomeGuildStore/images/misc/bait_%s.dds",
				filters = {
					[TRADING_HOUSE_FILTER_TYPE_ITEM] = { ITEMTYPE_LURE },
				},
			},
			[SUBCATEGORY_MISC_TOOLS] = {
				label = "Tools",
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
		label = "Weapon Traits",
		x = 0,
		y = 0,
		size = SUBFILTER_BUTTON_SIZE,
		perRow = 5,
		filter = TRADING_HOUSE_FILTER_TYPE_TRAIT,
		buttons = {
			{
				label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_WEAPON_POWERED),
				texture = "EsoUI/Art/Crafting/smithing_tabIcon_weaponset_%s.dds",
				value = ITEM_TRAIT_TYPE_WEAPON_POWERED,
			},
			{
				label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_WEAPON_CHARGED),
				texture = "EsoUI/Art/Campaign/overview_indexIcon_bonus_%s.dds",
				value = ITEM_TRAIT_TYPE_WEAPON_CHARGED,
			},
			{
				label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_WEAPON_PRECISE),
				texture = "EsoUI/Art/Campaign/overview_indexIcon_scoring_%s.dds",
				value = ITEM_TRAIT_TYPE_WEAPON_PRECISE,
			},
			{
				label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_WEAPON_INFUSED),
				texture = "EsoUI/Art/Progression/progression_tabIcon_combatskills_%s.dds",
				value = ITEM_TRAIT_TYPE_WEAPON_INFUSED,
			},
			{
				label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_WEAPON_DEFENDING),
				texture = "EsoUI/Art/Guild/tabIcon_heraldry_%s.dds",
				value = ITEM_TRAIT_TYPE_WEAPON_DEFENDING,
			},
			{
				label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_WEAPON_TRAINING),
				texture = "EsoUI/Art/Guild/tabIcon_ranks_%s.dds",
				value = ITEM_TRAIT_TYPE_WEAPON_TRAINING,
			},
			{
				label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_WEAPON_SHARPENED),
				texture = "EsoUI/Art/Campaign/campaignBrowser_indexIcon_normal_%s.dds",
				value = ITEM_TRAIT_TYPE_WEAPON_SHARPENED,
			},
			{
				label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_WEAPON_WEIGHTED),
				texture = "EsoUI/Art/Inventory/inventory_tabicon_misc_%s.dds",
				value = ITEM_TRAIT_TYPE_WEAPON_WEIGHTED,
			},
			{
				label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_WEAPON_ORNATE),
				texture = "EsoUI/Art/Tradinghouse/tradinghouse_sell_tabIcon_%s.dds",
				value = ITEM_TRAIT_TYPE_WEAPON_ORNATE,
			},
			{
				label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_WEAPON_INTRICATE),
				texture = "EsoUI/Art/Progression/progression_indexIcon_guilds_%s.dds",
				value = ITEM_TRAIT_TYPE_WEAPON_INTRICATE,
			},
		},
	},
	[SUBFILTER_WEAPON_ENCHANTMENTS] = {},
	[SUBFILTER_WEAPON_ONEHANDED] = {
		label = "Weapon Type",
		x = 0,
		y = 90,
		size = SUBFILTER_BUTTON_SIZE,
		perRow = 5,
		filter = TRADING_HOUSE_FILTER_TYPE_WEAPON,
		buttons = {
			{
				label = GetString("SI_WEAPONTYPE", WEAPONTYPE_AXE),
				texture = "AwesomeGuildStore/images/weapon/axe_%s.dds",
				value = WEAPONTYPE_AXE,
			},
			{
				label = GetString("SI_WEAPONTYPE", WEAPONTYPE_HAMMER),
				texture = "AwesomeGuildStore/images/weapon/mace_%s.dds",
				value = WEAPONTYPE_HAMMER,
			},
			{
				label = GetString("SI_WEAPONTYPE", WEAPONTYPE_SWORD),
				texture = "AwesomeGuildStore/images/weapon/twohand_%s.dds",
				value = WEAPONTYPE_SWORD,
			},
			{
				label = GetString("SI_WEAPONTYPE", WEAPONTYPE_DAGGER),
				texture = "AwesomeGuildStore/images/weapon/dagger_%s.dds",
				value = WEAPONTYPE_DAGGER,
			},
		},
	},
	[SUBFILTER_WEAPON_TWOHANDED] = {
		label = "Weapon Type",
		x = 0,
		y = 90,
		size = SUBFILTER_BUTTON_SIZE,
		perRow = 5,
		filter = TRADING_HOUSE_FILTER_TYPE_WEAPON,
		buttons = {
			{
				label = GetString("SI_WEAPONTYPE", WEAPONTYPE_TWO_HANDED_AXE),
				texture = "AwesomeGuildStore/images/weapon/axe_%s.dds",
				value = WEAPONTYPE_TWO_HANDED_AXE,
			},
			{
				label = GetString("SI_WEAPONTYPE", WEAPONTYPE_TWO_HANDED_HAMMER),
				texture = "AwesomeGuildStore/images/weapon/mace_%s.dds",
				value = WEAPONTYPE_TWO_HANDED_HAMMER,
			},
			{
				label = GetString("SI_WEAPONTYPE", WEAPONTYPE_TWO_HANDED_SWORD),
				texture = "AwesomeGuildStore/images/weapon/twohand_%s.dds",
				value = WEAPONTYPE_TWO_HANDED_SWORD,
			},
		},
	},
	[SUBFILTER_WEAPON_STAFF] = {
		label = "Weapon Type",
		x = 0,
		y = 90,
		size = SUBFILTER_BUTTON_SIZE,
		perRow = 5,
		filter = TRADING_HOUSE_FILTER_TYPE_WEAPON,
		buttons = {
			{
				label = GetString("SI_WEAPONTYPE", WEAPONTYPE_FIRE_STAFF),
				texture = "AwesomeGuildStore/images/weapon/fire_%s.dds",
				value = WEAPONTYPE_FIRE_STAFF,
			},
			{
				label = GetString("SI_WEAPONTYPE", WEAPONTYPE_FROST_STAFF),
				texture = "AwesomeGuildStore/images/weapon/ice_%s.dds",
				value = WEAPONTYPE_FROST_STAFF,
			},
			{
				label = GetString("SI_WEAPONTYPE", WEAPONTYPE_LIGHTNING_STAFF),
				texture = "AwesomeGuildStore/images/weapon/lightning_%s.dds",
				value = WEAPONTYPE_LIGHTNING_STAFF,
			},
		},
	},
	[SUBFILTER_ARMOR_SLOTS] = {
		label = "Armor Type",
		x = 0,
		y = 90,
		size = SUBFILTER_BUTTON_SIZE,
		perRow = 5,
		filter = TRADING_HOUSE_FILTER_TYPE_EQUIP,
		buttons = {
			{
				label = GetString("SI_EQUIPTYPE", EQUIP_TYPE_HEAD),
				texture = "EsoUI/Art/Inventory/inventory_tabIcon_armor_%s.dds",
				value = EQUIP_TYPE_HEAD,
			},
			{
				label = GetString("SI_EQUIPTYPE", EQUIP_TYPE_CHEST),
				texture = "AwesomeGuildStore/images/armor/chest_%s.dds",
				value = EQUIP_TYPE_CHEST,
			},
			{
				label = GetString("SI_EQUIPTYPE", EQUIP_TYPE_SHOULDERS),
				texture = "AwesomeGuildStore/images/armor/shoulders_%s.dds",
				value = EQUIP_TYPE_SHOULDERS,
			},
			{
				label = GetString("SI_EQUIPTYPE", EQUIP_TYPE_WAIST),
				texture = "AwesomeGuildStore/images/armor/belt_%s.dds",
				value = EQUIP_TYPE_WAIST,
			},
			{
				label = GetString("SI_EQUIPTYPE", EQUIP_TYPE_LEGS),
				texture = "AwesomeGuildStore/images/armor/legs_%s.dds",
				value = EQUIP_TYPE_LEGS,
			},
			{
				label = GetString("SI_EQUIPTYPE", EQUIP_TYPE_FEET),
				texture = "AwesomeGuildStore/images/armor/feet_%s.dds",
				value = EQUIP_TYPE_FEET,
			},
			{
				label = GetString("SI_EQUIPTYPE", EQUIP_TYPE_HAND),
				texture = "AwesomeGuildStore/images/armor/hands_%s.dds",
				value = EQUIP_TYPE_HAND,
			},
		},
	},
	[SUBFILTER_ARMOR_TRAITS] = {
		label = "Armor Traits",
		x = 0,
		y = 0,
		size = SUBFILTER_BUTTON_SIZE,
		perRow = 5,
		filter = TRADING_HOUSE_FILTER_TYPE_TRAIT,
		buttons = {
			{
				label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_STURDY),
				texture = "EsoUI/Art/Campaign/campaignBrowser_indexIcon_hardcore_%s.dds",
				value = ITEM_TRAIT_TYPE_ARMOR_STURDY,
			},
			{
				label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE),
				texture = "EsoUI/Art/Guild/tabIcon_heraldry_%s.dds",
				value = ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE,
			},
			{
				label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_REINFORCED),
				texture = "EsoUI/Art/Crafting/smithing_tabIcon_armorset_%s.dds",
				value = ITEM_TRAIT_TYPE_ARMOR_REINFORCED,
			},
			{
				label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED),
				texture = "EsoUI/Art/Campaign/campaign_tabIcon_summary_%s.dds",
				value = ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED,
			},
			{
				label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_TRAINING),
				texture = "EsoUI/Art/Guild/tabIcon_ranks_%s.dds",
				value = ITEM_TRAIT_TYPE_ARMOR_TRAINING,
			},
			{
				label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_INFUSED),
				texture = "EsoUI/Art/Progression/progression_tabIcon_combatSkills_%s.dds",
				value = ITEM_TRAIT_TYPE_ARMOR_INFUSED,
			},
			{
				label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_EXPLORATION),
				texture = "EsoUI/Art/Progression/progression_indexIcon_world_%s.dds",
				value = ITEM_TRAIT_TYPE_ARMOR_EXPLORATION,
			},
			{
				label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_DIVINES),
				texture = "EsoUI/Art/Progression/progression_indexIcon_race_%s.dds",
				value = ITEM_TRAIT_TYPE_ARMOR_DIVINES,
			},
			{
				label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_ORNATE),
				texture = "EsoUI/Art/Tradinghouse/tradinghouse_sell_tabIcon_%s.dds",
				value = ITEM_TRAIT_TYPE_ARMOR_ORNATE,
			},
			{
				label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_INTRICATE),
				texture = "EsoUI/Art/Progression/progression_indexIcon_guilds_%s.dds",
				value = ITEM_TRAIT_TYPE_ARMOR_INTRICATE,
			},
		},
	},
	[SUBFILTER_ARMOR_ENCHANTMENTS] = {},
	[SUBFILTER_JEWELRY_TRAITS] = {
		label = "Jewelry Traits",
		x = 0,
		y = 0,
		size = SUBFILTER_BUTTON_SIZE,
		perRow = 5,
		filter = TRADING_HOUSE_FILTER_TYPE_TRAIT,
		buttons = {
			{
				label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_JEWELRY_HEALTHY),
				texture = "EsoUI/Art/Crafting/provisioner_indexIcon_beer_%s.dds",
				value = ITEM_TRAIT_TYPE_JEWELRY_HEALTHY,
			},
			{
				label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_JEWELRY_ARCANE),
				texture = "EsoUI/Art/Campaign/campaignBrowser_indexIcon_specialEvents_%s.dds",
				value = ITEM_TRAIT_TYPE_JEWELRY_ARCANE,
			},
			{
				label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_JEWELRY_ROBUST),
				texture = "EsoUI/Art/Repair/inventory_tabIcon_repair_%s.dds",
				value = ITEM_TRAIT_TYPE_JEWELRY_ROBUST,
			},
			{
				label = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_JEWELRY_ORNATE),
				texture = "EsoUI/Art/Tradinghouse/tradinghouse_sell_tabIcon_%s.dds",
				value = ITEM_TRAIT_TYPE_JEWELRY_ORNATE,
			},
		},
	},
	[SUBFILTER_JEWELRY_ENCHANTMENTS] = {},
	[SUBFILTER_BLACKSMITHING_MATERIALS] = {
		label = "Material Types",
		x = 0,
		y = 0,
		size = SUBFILTER_BUTTON_SIZE,
		perRow = 5,
		filter = TRADING_HOUSE_FILTER_TYPE_ITEM,
		buttons = {
			{
				label = GetString("SI_ITEMTYPE", ITEMTYPE_BLACKSMITHING_RAW_MATERIAL),
				texture = "AwesomeGuildStore/images/crafting/rawmaterial_%s.dds",
				value = ITEMTYPE_BLACKSMITHING_RAW_MATERIAL,
			},
			{
				label = GetString("SI_ITEMTYPE", ITEMTYPE_BLACKSMITHING_MATERIAL),
				texture = "AwesomeGuildStore/images/crafting/material_%s.dds",
				value = ITEMTYPE_BLACKSMITHING_MATERIAL,
			},
			{
				label = GetString("SI_ITEMTYPE", ITEMTYPE_BLACKSMITHING_BOOSTER),
				texture = "EsoUI/Art/WorldMap/map_ava_tabIcon_resourceProduction_%s.dds",
				value = ITEMTYPE_BLACKSMITHING_BOOSTER,
			},
		},
	},
	[SUBFILTER_CLOTHING_MATERIALS] = {
		label = "Material Types",
		x = 0,
		y = 0,
		size = SUBFILTER_BUTTON_SIZE,
		perRow = 5,
		filter = TRADING_HOUSE_FILTER_TYPE_ITEM,
		buttons = {
			{
				label = GetString("SI_ITEMTYPE", ITEMTYPE_CLOTHIER_RAW_MATERIAL),
				texture = "AwesomeGuildStore/images/crafting/rawmaterial_%s.dds",
				value = ITEMTYPE_CLOTHIER_RAW_MATERIAL,
			},
			{
				label = GetString("SI_ITEMTYPE", ITEMTYPE_CLOTHIER_MATERIAL),
				texture = "AwesomeGuildStore/images/crafting/material_%s.dds",
				value = ITEMTYPE_CLOTHIER_MATERIAL,
			},
			{
				label = GetString("SI_ITEMTYPE", ITEMTYPE_CLOTHIER_BOOSTER),
				texture = "EsoUI/Art/WorldMap/map_ava_tabIcon_resourceProduction_%s.dds",
				value = ITEMTYPE_CLOTHIER_BOOSTER,
			},
		},
	},
	[SUBFILTER_WOODWORKING_MATERIALS] = {
		label = "Material Types",
		x = 0,
		y = 0,
		size = SUBFILTER_BUTTON_SIZE,
		perRow = 5,
		filter = TRADING_HOUSE_FILTER_TYPE_ITEM,
		buttons = {
			{
				label = GetString("SI_ITEMTYPE", ITEMTYPE_WOODWORKING_RAW_MATERIAL),
				texture = "AwesomeGuildStore/images/crafting/rawmaterial_%s.dds",
				value = ITEMTYPE_WOODWORKING_RAW_MATERIAL,
			},
			{
				label = GetString("SI_ITEMTYPE", ITEMTYPE_WOODWORKING_MATERIAL),
				texture = "AwesomeGuildStore/images/crafting/material_%s.dds",
				value = ITEMTYPE_WOODWORKING_MATERIAL,
			},
			{
				label = GetString("SI_ITEMTYPE", ITEMTYPE_WOODWORKING_BOOSTER),
				texture = "EsoUI/Art/WorldMap/map_ava_tabIcon_resourceProduction_%s.dds",
				value = ITEMTYPE_WOODWORKING_BOOSTER,
			},
		},
	},
	[SUBFILTER_ALCHEMY_MATERIALS] = {
		label = "Ingredient Types",
		x = 0,
		y = 0,
		size = SUBFILTER_BUTTON_SIZE,
		perRow = 5,
		filter = TRADING_HOUSE_FILTER_TYPE_ITEM,
		buttons = {
			{
				label = GetString("SI_ITEMTYPE", ITEMTYPE_ALCHEMY_BASE),
				texture = "EsoUI/Art/Crafting/alchemy_tabIcon_solvent_%s.dds",
				value = ITEMTYPE_ALCHEMY_BASE,
			},
			{
				label = GetString("SI_ITEMTYPE", ITEMTYPE_REAGENT),
				texture = "EsoUI/Art/Crafting/alchemy_tabIcon_reagent_%s.dds",
				value = ITEMTYPE_REAGENT,
			},
		},
	},
	[SUBFILTER_ENCHANTING_MATERIALS] = {
		label = "Rune Types",
		x = 0,
		y = 0,
		size = SUBFILTER_BUTTON_SIZE,
		perRow = 5,
		filter = TRADING_HOUSE_FILTER_TYPE_ITEM,
		buttons = {
			{
				label = GetString("SI_ITEMTYPE", ITEMTYPE_ENCHANTING_RUNE_ASPECT),
				texture = "EsoUI/Art/Crafting/enchantment_tabIcon_aspect_%s.dds",
				value = ITEMTYPE_ENCHANTING_RUNE_ASPECT,
			},
			{
				label = GetString("SI_ITEMTYPE", ITEMTYPE_ENCHANTING_RUNE_ESSENCE),
				texture = "EsoUI/Art/Crafting/enchantment_tabIcon_essence_%s.dds",
				value = ITEMTYPE_ENCHANTING_RUNE_ESSENCE,
			},
			{
				label = GetString("SI_ITEMTYPE", ITEMTYPE_ENCHANTING_RUNE_POTENCY),
				texture = "EsoUI/Art/Crafting/enchantment_tabIcon_potency_%s.dds",
				value = ITEMTYPE_ENCHANTING_RUNE_POTENCY,
			},
		},
	},
	[SUBFILTER_GLYPHS] = {
		label = "Glyph Types",
		x = 0,
		y = 0,
		size = SUBFILTER_BUTTON_SIZE,
		perRow = 5,
		filter = TRADING_HOUSE_FILTER_TYPE_ITEM,
		buttons = {
			{
				label = GetString("SI_ITEMTYPE", ITEMTYPE_GLYPH_ARMOR),
				texture = "AwesomeGuildStore/images/misc/armor_glyph_%s.dds",
				value = ITEMTYPE_GLYPH_ARMOR,
			},
			{
				label = GetString("SI_ITEMTYPE", ITEMTYPE_GLYPH_WEAPON),
				texture = "AwesomeGuildStore/images/misc/weapon_glyph_%s.dds",
				value = ITEMTYPE_GLYPH_WEAPON,
			},
			{
				label = GetString("SI_ITEMTYPE", ITEMTYPE_GLYPH_JEWELRY),
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

	local container = parent:CreateControl(name .. "Container", CT_CONTROL)
	container:SetResizeToFitDescendents(true)
	selector.control = container
	selector.group = {}
	selector.subfilters = {}
	selector.category = CATEGORY_ALL
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

	ZO_PreHook(TRADING_HOUSE.m_search, "InternalExecuteSearch", function(self)
		local filters = FILTER_PRESETS[selector.category].subcategories
		local subfilters
		local subcategory = selector.subcategory[selector.category]
		if(subcategory) then
			subfilters = filters[subcategory].subfilters
			filters = filters[subcategory].filters
		end

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
		if(selector.category == CATEGORY_ARMOR and selector.subcategory[CATEGORY_ARMOR] == SUBCATEGORY_ARMOR_COSTUME) then
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
		SetTooltipText(InformationTooltip, "Reset " .. subfilterPreset.label)
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
			ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, "Cannot filter for more than 8 at a time")
			return false
		end
		return true
	end
	button.HandleRelease = function(control, fromGroup)
		group.resetButton:SetHidden(group.pressedButtonCount == 1)
		return true
	end
	button.value = buttonPreset.value
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
	local group = self:CreateSubcategoryGroup(name .. categoryPreset.label:gsub(" ", "") .. "Group", category)
	for subcategory, preset in pairs(categoryPreset.subcategories) do
		self:CreateSubcategoryButton(group, subcategory, preset)
	end
end

function CategorySelector:CreateCategoryButton(group, category, preset)
	local button = ToggleButton:New(group.control, group.control:GetName() .. preset.label:gsub(" ", "") .. "Button", preset.texture, 100 + MAJOR_BUTTON_SIZE * category, 0, MAJOR_BUTTON_SIZE, MAJOR_BUTTON_SIZE, preset.label)
	button.HandlePress = function()
		group:ReleaseAllButtons()
		self.category = category
		group.label:SetText(preset.label)
		if(self.group[category]) then
			self.group[category].control:SetHidden(false)
		end
		self:UpdateSubfilterVisibility()
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
	local button = ToggleButton:New(group.control, group.control:GetName() .. preset.label:gsub(" ", "") .. "Button", preset.texture, 120 + MINOR_BUTTON_SIZE * subcategory, 0, MINOR_BUTTON_SIZE, MINOR_BUTTON_SIZE, preset.label)
	button.HandlePress = function()
		group:ReleaseAllButtons()
		group.label:SetText(preset.label)
		self.subcategory[group.category] = subcategory
		self:UpdateSubfilterVisibility()
		return true
	end
	button.HandleRelease = function(control, fromGroup)
		return fromGroup
	end
	if(preset.isDefault) then
		group.defaultButton = button
		button:Press()
	end
	group:AddButton(button)
	return button
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
