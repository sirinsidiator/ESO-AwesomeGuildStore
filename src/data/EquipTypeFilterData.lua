local AGS = AwesomeGuildStore

local gettext = AGS.internal.gettext
local SUB_CATEGORY_ID = AGS.data.SUB_CATEGORY_ID
local FILTER_ID = AGS.data.FILTER_ID

local function UnpackEquipType(filter, itemData) -- TODO: collect all unpack functions in utils
    local id = GetItemLinkEquipType(itemData.itemLink)
    return id
end

local ARMOR_EQUIP_TYPE_FILTER = {
    id = FILTER_ID.ARMOR_EQUIP_TYPE_FILTER,
    type = TRADING_HOUSE_FILTER_TYPE_EQUIP,
    unpack = UnpackEquipType,
    -- TRANSLATORS: title of the armor type filter in the left panel on the search tab
    label = gettext("Armor Type"),
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

AGS.data.ARMOR_EQUIP_TYPE_FILTER = ARMOR_EQUIP_TYPE_FILTER
