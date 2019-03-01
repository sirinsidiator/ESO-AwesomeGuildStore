local AGS = AwesomeGuildStore

local FilterBase = AGS.class.FilterBase
local MultiChoiceFilterBase = AGS.class.MultiChoiceFilterBase

local FILTER_ID = AGS.data.FILTER_ID
local SUB_CATEGORY_ID = AGS.data.SUB_CATEGORY_ID

local gettext = AGS.internal.gettext
local CanItemLinkBeCraftedByPlayer = AGS.internal.CanItemLinkBeCraftedByPlayer


local SkillRequirementsFilter = MultiChoiceFilterBase:Subclass()
AGS.class.SkillRequirementsFilter = SkillRequirementsFilter

function SkillRequirementsFilter:New(...)
    return MultiChoiceFilterBase.New(self, ...)
end

function SkillRequirementsFilter:Initialize()
    -- TRANSLATORS: label of the recipe improvement filter
    MultiChoiceFilterBase.Initialize(self, FILTER_ID.SKILL_REQUIREMENTS_FILTER, FilterBase.GROUP_LOCAL, gettext("Skill requirements"), {
        {
            id = true,
            -- TRANSLATORS: tooltip text for the recipe skill requirement filter
            label = gettext("Can craft"),
            icon = "Esoui/Art/Guild/guildHeraldry_indexIcon_finalize_%s.dds",
        },
        {
            id = false,
            -- TRANSLATORS: tooltip text for the recipe skill requirement filter
            label = gettext("Cannot craft"),
            icon = "Esoui/Art/Contacts/tabIcon_ignored_%s.dds",
        },
    })
    self:SetEnabledSubcategories({
        [SUB_CATEGORY_ID.CONSUMABLE_RECIPE] = true,
    })
end

function SkillRequirementsFilter:FilterLocalResult(itemData)
    local id = CanItemLinkBeCraftedByPlayer(itemData.itemLink)
    local value = self.valueById[id]
    return self.localSelection[value]
end
