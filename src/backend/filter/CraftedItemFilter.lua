local AGS = AwesomeGuildStore

local FilterBase = AGS.class.FilterBase
local MultiChoiceFilterBase = AGS.class.MultiChoiceFilterBase

local FILTER_ID = AGS.data.FILTER_ID
local SUB_CATEGORY_ID = AGS.data.SUB_CATEGORY_ID

local gettext = AGS.internal.gettext
local IsItemLinkCraftedAllTypes = AGS.internal.IsItemLinkCraftedAllTypes


local CraftedItemFilter = MultiChoiceFilterBase:Subclass()
AGS.class.CraftedItemFilter = CraftedItemFilter

function CraftedItemFilter:New(...)
    return MultiChoiceFilterBase.New(self, ...)
end

function CraftedItemFilter:Initialize()
    -- TRANSLATORS: title of the crafted item filter in the left panel on the search tab
    MultiChoiceFilterBase.Initialize(self, FILTER_ID.ITEM_CRAFTED_FILTER, FilterBase.GROUP_LOCAL, gettext("Crafting"), {
        {
            id = false,
            -- TRANSLATORS: tooltip text for the crafted item filter
            label = gettext("Looted item"),
            icon = "Esoui/Art/Progression/progression_indexIcon_class_%s.dds",
        }, {
            id = true,
            -- TRANSLATORS: tooltip text for the crafted item filter
            label = gettext("Crafted item"),
            icon = "Esoui/Art/TreeIcons/achievements_indexIcon_crafting_%s.dds",
        }
    }, label)

    self:SetEnabledSubcategories({
        [SUB_CATEGORY_ID.WEAPONS_ALL] = true,
        [SUB_CATEGORY_ID.WEAPONS_ONE_HANDED] = true,
        [SUB_CATEGORY_ID.WEAPONS_TWO_HANDED] = true,
        [SUB_CATEGORY_ID.WEAPONS_BOW] = true,
        [SUB_CATEGORY_ID.WEAPONS_DESTRUCTION_STAFF] = true,
        [SUB_CATEGORY_ID.WEAPONS_RESTORATION_STAFF] = true,
        [SUB_CATEGORY_ID.ARMOR_ALL] = true,
        [SUB_CATEGORY_ID.ARMOR_HEAVY] = true,
        [SUB_CATEGORY_ID.ARMOR_MEDIUM] = true,
        [SUB_CATEGORY_ID.ARMOR_LIGHT] = true,
        [SUB_CATEGORY_ID.ARMOR_SHIELD] = true,
        [SUB_CATEGORY_ID.JEWELRY_ALL] = true,
        [SUB_CATEGORY_ID.JEWELRY_RING] = true,
        [SUB_CATEGORY_ID.JEWELRY_NECK] = true,
        [SUB_CATEGORY_ID.JEWELRY_ALL] = true,
        [SUB_CATEGORY_ID.JEWELRY_RING] = true,
        [SUB_CATEGORY_ID.JEWELRY_NECK] = true,
        [SUB_CATEGORY_ID.CONSUMABLE_FOOD] = true,
        [SUB_CATEGORY_ID.CONSUMABLE_DRINK] = true,
        [SUB_CATEGORY_ID.CONSUMABLE_POTION] = true,
        [SUB_CATEGORY_ID.CONSUMABLE_POISON] = true,
        [SUB_CATEGORY_ID.MISCELLANEOUS_GLYPHS] = true,
    })
end

function CraftedItemFilter:FilterLocalResult(itemData)
    local id = IsItemLinkCraftedAllTypes(itemData.itemLink)
    local value = self.valueById[id]
    return self.localSelection[value]
end
