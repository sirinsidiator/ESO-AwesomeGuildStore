local AGS = AwesomeGuildStore

local FilterBase = AGS.class.FilterBase
local MultiChoiceFilterBase = AGS.class.MultiChoiceFilterBase

local FILTER_ID = AGS.data.FILTER_ID
local SUB_CATEGORY_ID = AGS.data.SUB_CATEGORY_ID

local gettext = AGS.internal.gettext
local IsItemLinkCraftedAllTypes = AGS.internal.IsItemLinkCraftedAllTypes


local RuneKnowledgeFilter = MultiChoiceFilterBase:Subclass()
AGS.class.RuneKnowledgeFilter = RuneKnowledgeFilter

function RuneKnowledgeFilter:New(...)
    return MultiChoiceFilterBase.New(self, ...)
end

function RuneKnowledgeFilter:Initialize()
    -- TRANSLATORS: title of the rune knowledge filter in the left panel on the search tab
    MultiChoiceFilterBase.Initialize(self, FILTER_ID.RUNE_KNOWLEDGE_FILTER, FilterBase.GROUP_LOCAL, gettext("Rune Knowledge"), {
        {
            id = false,
            -- TRANSLATORS: tooltip text for the rune knowledge filter
            label = gettext("Unknown Rune"),
            icon = "EsoUI/Art/Campaign/overview_indexIcon_bonus_%s.dds",
        },
        {
            id = true,
            -- TRANSLATORS: tooltip text for the rune knowledge filter
            label = gettext("Known Rune"),
            icon = "EsoUI/Art/Journal/journal_tabIcon_loreLibrary_%s.dds",
        },
    })
    self:SetEnabledSubcategories({
        [SUB_CATEGORY_ID.CRAFTING_ENCHANTING] = true,
    })
end

function RuneKnowledgeFilter:FilterLocalResult(itemData)
    local id = GetItemLinkEnchantingRuneName(itemData.itemLink)
    local value = self.valueById[id]
    return self.localSelection[value]
end
