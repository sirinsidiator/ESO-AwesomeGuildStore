local AGS = AwesomeGuildStore

local FilterBase = AGS.class.FilterBase
local MultiChoiceFilterBase = AGS.class.MultiChoiceFilterBase

local FILTER_ID = AGS.data.FILTER_ID
local SUB_CATEGORY_ID = AGS.data.SUB_CATEGORY_ID

local gettext = AGS.internal.gettext

local GetItemLinkSetInfo = GetItemLinkSetInfo


local ItemSetFilter = MultiChoiceFilterBase:Subclass()
AGS.class.ItemSetFilter = ItemSetFilter

function ItemSetFilter:New(...)
    return MultiChoiceFilterBase.New(self, ...)
end

function ItemSetFilter:Initialize()
    -- TRANSLATORS: title of the set item filter in the left panel on the search tab
    MultiChoiceFilterBase.Initialize(self, FILTER_ID.ITEM_SET_FILTER, FilterBase.GROUP_LOCAL, gettext("Itemset"), {
        {
            id = false,
            -- TRANSLATORS: tooltip text for the set item filter
            label = gettext("Regular item"),
            icon = "EsoUI/Art/TreeIcons/achievements_indexIcon_collections_%s.dds",
        },
        {
            id = true,
            -- TRANSLATORS: tooltip text for the set item filter
            label = gettext("Set item"),
            icon = "EsoUI/Art/Campaign/campaign_tabIcon_summary_%s.dds",
        },
    })
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
    })
end

function ItemSetFilter:FilterLocalResult(itemData)
    local id = GetItemLinkSetInfo(itemData.itemLink)
    local value = self.valueById[id]
    return self.localSelection[value]
end
