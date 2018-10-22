local gettext = LibStub("LibGetText")("AwesomeGuildStore").gettext
local SUB_CATEGORY_ID = AwesomeGuildStore.data.SUB_CATEGORY_ID
local FILTER_ID = AwesomeGuildStore.data.FILTER_ID

local function UnpackWeaponType(filter, itemData) -- TODO: collect all unpack functions in utils
    local id = GetItemLinkWeaponType(itemData.itemLink)
    return id
end

-- TRANSLATORS: title for the weapon type filter in the left panel on the search tab
local label = gettext("Weapon Type")

local ONE_HANDED_WEAPON_TYPE_FILTER = {
    id = FILTER_ID.ONE_HANDED_WEAPON_TYPE_FILTER,
    type = TRADING_HOUSE_FILTER_TYPE_WEAPON,
    unpack = UnpackWeaponType,
    label = label,
    enabled = {
        [SUB_CATEGORY_ID.WEAPONS_ONE_HANDED] = true,
    },
    values = {
        {
            id = WEAPONTYPE_AXE,
            label = GetString("SI_WEAPONTYPE", WEAPONTYPE_AXE),
            icon = "AwesomeGuildStore/images/weapon/axe_%s.dds",
        },
        {
            id = WEAPONTYPE_HAMMER,
            label = GetString("SI_WEAPONTYPE", WEAPONTYPE_HAMMER),
            icon = "AwesomeGuildStore/images/weapon/mace_%s.dds",
        },
        {
            id = WEAPONTYPE_SWORD,
            label = GetString("SI_WEAPONTYPE", WEAPONTYPE_SWORD),
            icon = "AwesomeGuildStore/images/weapon/twohand_%s.dds",
        },
        {
            id = WEAPONTYPE_DAGGER,
            label = GetString("SI_WEAPONTYPE", WEAPONTYPE_DAGGER),
            icon = "AwesomeGuildStore/images/weapon/dagger_%s.dds",
        },
    }
}

local TWO_HANDED_WEAPON_TYPE_FILTER = {
    id = FILTER_ID.TWO_HANDED_WEAPON_TYPE_FILTER,
    type = TRADING_HOUSE_FILTER_TYPE_WEAPON,
    unpack = UnpackWeaponType,
    label = label,
    enabled = {
        [SUB_CATEGORY_ID.WEAPONS_TWO_HANDED] = true,
    },
    values = {
        {
            id = WEAPONTYPE_TWO_HANDED_AXE,
            label = GetString("SI_WEAPONTYPE", WEAPONTYPE_TWO_HANDED_AXE),
            icon = "AwesomeGuildStore/images/weapon/axe_%s.dds",
        },
        {
            id = WEAPONTYPE_TWO_HANDED_HAMMER,
            label = GetString("SI_WEAPONTYPE", WEAPONTYPE_TWO_HANDED_HAMMER),
            icon = "AwesomeGuildStore/images/weapon/mace_%s.dds",
        },
        {
            id = WEAPONTYPE_TWO_HANDED_SWORD,
            label = GetString("SI_WEAPONTYPE", WEAPONTYPE_TWO_HANDED_SWORD),
            icon = "AwesomeGuildStore/images/weapon/twohand_%s.dds",
        },
    }
}

local STAFF_WEAPON_TYPE_FILTER = {
    id = FILTER_ID.STAFF_WEAPON_TYPE_FILTER,
    type = TRADING_HOUSE_FILTER_TYPE_WEAPON,
    unpack = UnpackWeaponType,
    label = label,
    enabled = {
        [SUB_CATEGORY_ID.WEAPONS_DESTRUCTION_STAFF] = true,
    },
    values = {
        {
            id = WEAPONTYPE_FIRE_STAFF,
            label = GetString("SI_WEAPONTYPE", WEAPONTYPE_FIRE_STAFF),
            icon = "AwesomeGuildStore/images/weapon/fire_%s.dds",
        },
        {
            id = WEAPONTYPE_FROST_STAFF,
            label = GetString("SI_WEAPONTYPE", WEAPONTYPE_FROST_STAFF),
            icon = "AwesomeGuildStore/images/weapon/ice_%s.dds",
        },
        {
            id = WEAPONTYPE_LIGHTNING_STAFF,
            label = GetString("SI_WEAPONTYPE", WEAPONTYPE_LIGHTNING_STAFF),
            icon = "AwesomeGuildStore/images/weapon/lightning_%s.dds",
        },
    }
}

AwesomeGuildStore.data.ONE_HANDED_WEAPON_TYPE_FILTER = ONE_HANDED_WEAPON_TYPE_FILTER
AwesomeGuildStore.data.TWO_HANDED_WEAPON_TYPE_FILTER = TWO_HANDED_WEAPON_TYPE_FILTER
AwesomeGuildStore.data.STAFF_WEAPON_TYPE_FILTER = STAFF_WEAPON_TYPE_FILTER
