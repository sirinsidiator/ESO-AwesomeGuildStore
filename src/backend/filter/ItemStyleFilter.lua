local AGS = AwesomeGuildStore

local FilterBase = AGS.class.FilterBase
local MultiChoiceFilterBase = AGS.class.MultiChoiceFilterBase

local FILTER_ID = AGS.data.FILTER_ID
local SUB_CATEGORY_ID = AGS.data.SUB_CATEGORY_ID
local STYLE_CATEGORIES = AGS.data.STYLE_CATEGORIES

local GetItemLinkItemStyle = GetItemLinkItemStyle


local ItemStyleFilter = MultiChoiceFilterBase:Subclass()
AGS.class.ItemStyleFilter = ItemStyleFilter

function ItemStyleFilter:New(...)
    return MultiChoiceFilterBase.New(self, ...)
end

function ItemStyleFilter:Initialize()
    MultiChoiceFilterBase.Initialize(self, FILTER_ID.ITEM_STYLE_FILTER, FilterBase.GROUP_LOCAL, GetString(SI_SMITHING_HEADER_STYLE), STYLE_CATEGORIES)
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
    })
end

function ItemStyleFilter:FilterLocalResult(itemData)
    local itemStyle = GetItemLinkItemStyle(itemData.itemLink)
    local value = self.valueById[itemStyle]
    return self.localSelection[value]
end
