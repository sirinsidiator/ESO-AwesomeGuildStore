local AGS = AwesomeGuildStore

local gettext = AGS.internal.gettext
local SUB_CATEGORY_ID = AGS.data.SUB_CATEGORY_ID
local FILTER_ID = AGS.data.FILTER_ID

local function UnpackEquipType(filter, itemData) -- TODO: collect all unpack functions in utils
    local id = GetItemLinkEquipType(itemData.itemLink)
    return id
end

local function UnpackArmorWeight(filter, itemData) -- TODO: collect all unpack functions in utils
    local id = GetItemLinkArmorType(itemData.itemLink)
    return id
end

-- TRANSLATORS: title of the armor type filter in the left panel on the search tab
local label = gettext("Armor Type")

local ARMOR_EQUIP_TYPE_FILTER = {
    id = FILTER_ID.ARMOR_EQUIP_TYPE_FILTER,
    type = TRADING_HOUSE_FILTER_TYPE_EQUIP,
    unpack = UnpackEquipType,
    label = label,
    enabled = {
        [SUB_CATEGORY_ID.ARMOR_ALL] = true,
        [SUB_CATEGORY_ID.ARMOR_HEAVY] = true,
        [SUB_CATEGORY_ID.ARMOR_MEDIUM] = true,
        [SUB_CATEGORY_ID.ARMOR_LIGHT] = true,
    },
    values = {
        {
            id = EQUIP_TYPE_HEAD,
            label = GetString("SI_EQUIPTYPE", EQUIP_TYPE_HEAD),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Apparel_Head_%s.dds",
        },
        {
            id = EQUIP_TYPE_CHEST,
            label = GetString("SI_EQUIPTYPE", EQUIP_TYPE_CHEST),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Apparel_Chest_%s.dds",
        },
        {
            id = EQUIP_TYPE_SHOULDERS,
            label = GetString("SI_EQUIPTYPE", EQUIP_TYPE_SHOULDERS),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Apparel_Shoulders_%s.dds",
        },
        {
            id = EQUIP_TYPE_WAIST,
            label = GetString("SI_EQUIPTYPE", EQUIP_TYPE_WAIST),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Apparel_Waist_%s.dds",
        },
        {
            id = EQUIP_TYPE_LEGS,
            label = GetString("SI_EQUIPTYPE", EQUIP_TYPE_LEGS),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Apparel_Legs_%s.dds",
        },
        {
            id = EQUIP_TYPE_FEET,
            label = GetString("SI_EQUIPTYPE", EQUIP_TYPE_FEET),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Apparel_Feet_%s.dds",
        },
        {
            id = EQUIP_TYPE_HAND,
            label = GetString("SI_EQUIPTYPE", EQUIP_TYPE_HAND),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Apparel_Hands_%s.dds",
        },
    }
}

local COMPANION_ARMOR_TYPE_FILTER = {
    id = FILTER_ID.COMPANION_ARMOR_TYPE_FILTER,
    type = TRADING_HOUSE_FILTER_TYPE_EQUIP,
    unpack = UnpackEquipType,
    label = label,
    enabled = {
        [SUB_CATEGORY_ID.COMPANION_ARMOR] = true,
    },
    values = {
        {
            id = EQUIP_TYPE_HEAD,
            label = GetString("SI_EQUIPTYPE", EQUIP_TYPE_HEAD),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Apparel_Head_%s.dds",
        },
        {
            id = EQUIP_TYPE_CHEST,
            label = GetString("SI_EQUIPTYPE", EQUIP_TYPE_CHEST),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Apparel_Chest_%s.dds",
        },
        {
            id = EQUIP_TYPE_SHOULDERS,
            label = GetString("SI_EQUIPTYPE", EQUIP_TYPE_SHOULDERS),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Apparel_Shoulders_%s.dds",
        },
        {
            id = EQUIP_TYPE_WAIST,
            label = GetString("SI_EQUIPTYPE", EQUIP_TYPE_WAIST),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Apparel_Waist_%s.dds",
        },
        {
            id = EQUIP_TYPE_LEGS,
            label = GetString("SI_EQUIPTYPE", EQUIP_TYPE_LEGS),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Apparel_Legs_%s.dds",
        },
        {
            id = EQUIP_TYPE_FEET,
            label = GetString("SI_EQUIPTYPE", EQUIP_TYPE_FEET),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Apparel_Feet_%s.dds",
        },
        {
            id = EQUIP_TYPE_HAND,
            label = GetString("SI_EQUIPTYPE", EQUIP_TYPE_HAND),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Apparel_Hands_%s.dds",
        },
        {
            id = EQUIP_TYPE_OFF_HAND,
            label = GetString(SI_TRADING_HOUSE_BROWSE_ARMOR_TYPE_SHIELD),
            icon = "EsoUI/Art/Inventory/inventory_tabIcon_shield_%s.dds",
        },
    }
}

-- TRANSLATORS: title of the armor weight filter in the left panel on the search tab
local label = gettext("Armor Weight")

local COMPANION_ARMOR_WEIGHT_FILTER = {
    id = FILTER_ID.COMPANION_ARMOR_WEIGHT_FILTER,
    type = TRADING_HOUSE_FILTER_ARMOR,
    unpack = UnpackArmorWeight,
    label = label,
    enabled = {
        [SUB_CATEGORY_ID.COMPANION_ARMOR] = true,
    },
    values = {
        {
            id = ARMORTYPE_LIGHT,
            label = GetString("SI_ARMORTYPE", ARMORTYPE_LIGHT),
            icon = "EsoUI/Art/Inventory/inventory_tabIcon_armorLight_%s.dds",
        },
        {
            id = ARMORTYPE_MEDIUM,
            label = GetString("SI_ARMORTYPE", ARMORTYPE_MEDIUM),
            icon = "EsoUI/Art/Inventory/inventory_tabIcon_armorMedium_%s.dds",
        },
        {
            id = ARMORTYPE_HEAVY,
            label = GetString("SI_ARMORTYPE", ARMORTYPE_HEAVY),
            icon = "EsoUI/Art/Inventory/inventory_tabIcon_armorHeavy_%s.dds",
        },
    }
}

-- TRANSLATORS: title of the jewelry type filter in the left panel on the search tab
local label = gettext("Jewelry Type")

local COMPANION_JEWELRY_TYPE_FILTER = {
    id = FILTER_ID.COMPANION_JEWELRY_TYPE_FILTER,
    type = TRADING_HOUSE_FILTER_TYPE_EQUIP,
    unpack = UnpackEquipType,
    label = label,
    enabled = {
        [SUB_CATEGORY_ID.COMPANION_JEWELRY] = true,
    },
    values = {
        {
            id = EQUIP_TYPE_NECK,
            label = GetString("SI_EQUIPTYPE", EQUIP_TYPE_NECK),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Apparel_Accessories_Necklace_%s.dds",
        },
        {
            id = EQUIP_TYPE_RING,
            label = GetString("SI_EQUIPTYPE", EQUIP_TYPE_RING),
            icon = "EsoUI/Art/TradingHouse/Tradinghouse_Apparel_Accessories_Ring_%s.dds",
        },
    }
}

AGS.data.ARMOR_EQUIP_TYPE_FILTER = ARMOR_EQUIP_TYPE_FILTER
AGS.data.COMPANION_ARMOR_TYPE_FILTER = COMPANION_ARMOR_TYPE_FILTER
AGS.data.COMPANION_ARMOR_WEIGHT_FILTER = COMPANION_ARMOR_WEIGHT_FILTER
AGS.data.COMPANION_JEWELRY_TYPE_FILTER = COMPANION_JEWELRY_TYPE_FILTER
