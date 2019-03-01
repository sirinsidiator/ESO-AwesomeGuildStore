local AGS = AwesomeGuildStore

local FilterBase = AGS.class.FilterBase
local MultiChoiceFilterBase = AGS.class.MultiChoiceFilterBase

local FILTER_ID = AGS.data.FILTER_ID
local SUB_CATEGORY_ID = AGS.data.SUB_CATEGORY_ID

local gettext = AGS.internal.gettext

local IsItemLinkBookKnown = IsItemLinkBookKnown


local MotifKnowledgeFilter = MultiChoiceFilterBase:Subclass()
AGS.class.MotifKnowledgeFilter = MotifKnowledgeFilter

function MotifKnowledgeFilter:New(...)
    return MultiChoiceFilterBase.New(self, ...)
end

function MotifKnowledgeFilter:Initialize()
    -- TRANSLATORS: title of the motif knowledge filter in the left panel on the search tab
    MultiChoiceFilterBase.Initialize(self, FILTER_ID.MOTIF_KNOWLEDGE_FILTER, FilterBase.GROUP_LOCAL, gettext("Motif Knowledge"), {
        {
            id = false,
            -- TRANSLATORS: tooltip text for the motif knowledge filter
            label = gettext("Unknown Motifs"),
            icon = "EsoUI/Art/Campaign/overview_indexIcon_bonus_%s.dds",
        },
        {
            id = true,
            -- TRANSLATORS: tooltip text for the motif knowledge filter
            label = gettext("Known Motifs"),
            icon = "EsoUI/Art/Journal/journal_tabIcon_loreLibrary_%s.dds",
        },
    })
    self:SetEnabledSubcategories({
        [SUB_CATEGORY_ID.CONSUMABLE_MOTIF] = true,
    })
end

function MotifKnowledgeFilter:FilterLocalResult(itemData)
    local id = IsItemLinkBookKnown(itemData.itemLink)
    local value = self.valueById[id]
    return self.localSelection[value]
end
