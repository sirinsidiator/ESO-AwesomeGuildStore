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
            icon = "EsoUI/Art/Inventory/inventory_tabIcon_armor_%s.dds",
        },
        {
            id = EQUIP_TYPE_CHEST,
            label = GetString("SI_EQUIPTYPE", EQUIP_TYPE_CHEST),
            icon = "AwesomeGuildStore/images/armor/chest_%s.dds",
        },
        {
            id = EQUIP_TYPE_SHOULDERS,
            label = GetString("SI_EQUIPTYPE", EQUIP_TYPE_SHOULDERS),
            icon = "AwesomeGuildStore/images/armor/shoulders_%s.dds",
        },
        {
            id = EQUIP_TYPE_WAIST,
            label = GetString("SI_EQUIPTYPE", EQUIP_TYPE_WAIST),
            icon = "AwesomeGuildStore/images/armor/belt_%s.dds",
        },
        {
            id = EQUIP_TYPE_LEGS,
            label = GetString("SI_EQUIPTYPE", EQUIP_TYPE_LEGS),
            icon = "AwesomeGuildStore/images/armor/legs_%s.dds",
        },
        {
            id = EQUIP_TYPE_FEET,
            label = GetString("SI_EQUIPTYPE", EQUIP_TYPE_FEET),
            icon = "AwesomeGuildStore/images/armor/feet_%s.dds",
        },
        {
            id = EQUIP_TYPE_HAND,
            label = GetString("SI_EQUIPTYPE", EQUIP_TYPE_HAND),
            icon = "AwesomeGuildStore/images/armor/hands_%s.dds",
        },
    }
}

AGS.data.ARMOR_EQUIP_TYPE_FILTER = ARMOR_EQUIP_TYPE_FILTER
