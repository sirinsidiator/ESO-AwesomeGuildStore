local AGS = AwesomeGuildStore

local FilterBase = AGS.class.FilterBase
local MultiChoiceFilterBase = AGS.class.MultiChoiceFilterBase

local FILTER_ID = AGS.data.FILTER_ID
local SUB_CATEGORY_ID = AGS.data.SUB_CATEGORY_ID

local gettext = AGS.internal.gettext

local GetItemLinkTraitInfo = GetItemLinkTraitInfo
local CanItemLinkBeTraitResearched = CanItemLinkBeTraitResearched


local TraitKnowledgeFilter = MultiChoiceFilterBase:Subclass()
AGS.class.TraitKnowledgeFilter = TraitKnowledgeFilter

function TraitKnowledgeFilter:New(...)
    return MultiChoiceFilterBase.New(self, ...)
end

function TraitKnowledgeFilter:Initialize()
    -- TRANSLATORS: title of the trait knowledge filter in the left panel on the search tab
    MultiChoiceFilterBase.Initialize(self, FILTER_ID.TRAIT_KNOWLEDGE_FILTER, FilterBase.GROUP_LOCAL, gettext("Trait Knowledge"), {
        {
            id = false,
            -- TRANSLATORS: tooltip text for the trait knowledge filter
            label = gettext("Known Trait"),
            icon = "EsoUI/Art/Journal/journal_tabIcon_loreLibrary_%s.dds",
        },
        {
            id = true,
            -- TRANSLATORS: tooltip text for the trait knowledge filter
            label = gettext("Unknown Trait"),
            icon = "EsoUI/Art/Campaign/overview_indexIcon_bonus_%s.dds",
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

local UNRESEACHABLE_TRAIT = {
    [ITEM_TRAIT_TYPE_NONE] = true,
    [ITEM_TRAIT_TYPE_WEAPON_INTRICATE] = true,
    [ITEM_TRAIT_TYPE_WEAPON_ORNATE] = true,
    [ITEM_TRAIT_TYPE_ARMOR_INTRICATE] = true,
    [ITEM_TRAIT_TYPE_ARMOR_ORNATE] = true,
    [ITEM_TRAIT_TYPE_JEWELRY_ORNATE] = true,
    [ITEM_TRAIT_TYPE_JEWELRY_INTRICATE] = true,
}

function TraitKnowledgeFilter:FilterLocalResult(itemData)
    local itemTrait = GetItemLinkTraitInfo(itemData.itemLink)
    if(UNRESEACHABLE_TRAIT[itemTrait]) then
        return false
    end

    local id = CanItemLinkBeTraitResearched(itemData.itemLink)
    local value = self.valueById[id]
    return self.localSelection[value]
end
