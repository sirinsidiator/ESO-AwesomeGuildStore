local AGS = AwesomeGuildStore

local FilterBase = AGS.class.FilterBase
local MultiChoiceFilterBase = AGS.class.MultiChoiceFilterBase

local FILTER_ID = AGS.data.FILTER_ID
local SUB_CATEGORY_ID = AGS.data.SUB_CATEGORY_ID

local gettext = AGS.internal.gettext


local RecipeKnowledgeFilter = MultiChoiceFilterBase:Subclass()
AGS.class.RecipeKnowledgeFilter = RecipeKnowledgeFilter

function RecipeKnowledgeFilter:New(...)
    return MultiChoiceFilterBase.New(self, ...)
end

function RecipeKnowledgeFilter:Initialize()
    -- TRANSLATORS: title of the recipe knowledge filter in the left panel on the search tab
    MultiChoiceFilterBase.Initialize(self, FILTER_ID.RECIPE_KNOWLEDGE_FILTER, FilterBase.GROUP_LOCAL, gettext("Recipe Knowledge"), {
        {
            id = false,
            -- TRANSLATORS: tooltip text for the recipe knowledge filter
            label = gettext("Unknown Recipes"),
            icon = "EsoUI/Art/Campaign/overview_indexIcon_bonus_%s.dds",
        },
        {
            id = true,
            -- TRANSLATORS: tooltip text for the recipe knowledge filter
            label = gettext("Known Recipes"),
            icon = "EsoUI/Art/Journal/journal_tabIcon_loreLibrary_%s.dds",
        },
    })
    self:SetEnabledSubcategories({
        [SUB_CATEGORY_ID.CONSUMABLE_RECIPE] = true,
    })
end

function RecipeKnowledgeFilter:FilterLocalResult(itemData)
    local id = IsItemLinkRecipeKnown(itemData.itemLink)
    local value = self.valueById[id]
    return self.localSelection[value]
end
