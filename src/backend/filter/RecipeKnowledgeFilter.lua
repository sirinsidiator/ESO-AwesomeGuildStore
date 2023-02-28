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
        if LibCharacterKnowledge == nil then
		MultiChoiceFilterBase.Initialize(self, FILTER_ID.RECIPE_KNOWLEDGE_FILTER, FilterBase.GROUP_LOCAL, gettext("Recipe Knowledge"), {
        {
            id = 0,
            -- TRANSLATORS: tooltip text for the recipe knowledge filter
            label = gettext("Unknown Recipes"),
            icon = "EsoUI/Art/Campaign/overview_indexIcon_bonus_%s.dds",
        },
        {
            id = 1,
            -- TRANSLATORS: tooltip text for the recipe knowledge filter
            label = gettext("Known Recipes"),
            icon = "EsoUI/Art/Journal/journal_tabIcon_loreLibrary_%s.dds",
        },
		{
            id = 2,
            -- TRANSLATORS: tooltip text for the motif knowledge filter
            label = gettext("Unknown Recipes Crafter\nRequires LibCharacterKnowledge"),
            icon = "EsoUI/Art/Icons/achievements_indexicon_crafting_%s.dds",
        },    })
	else
		MultiChoiceFilterBase.Initialize(self, FILTER_ID.RECIPE_KNOWLEDGE_FILTER, FilterBase.GROUP_LOCAL, gettext("Recipe Knowledge"), {
        {
            id = 0,
            -- TRANSLATORS: tooltip text for the recipe knowledge filter
            label = gettext("Unknown Recipes"),
            icon = "EsoUI/Art/Campaign/overview_indexIcon_bonus_%s.dds",
        },
        {
            id = 1,
            -- TRANSLATORS: tooltip text for the recipe knowledge filter
            label = gettext("Known Recipes"),
            icon = "EsoUI/Art/Journal/journal_tabIcon_loreLibrary_%s.dds",
        },
		{
            id = 2,
            -- TRANSLATORS: tooltip text for the motif knowledge filter
            label = gettext("Unknown Recipes Crafter"),
            icon = "EsoUI/Art/Icons/achievements_indexicon_crafting_%s.dds",
        },    })
	end
    self:SetEnabledSubcategories({
        [SUB_CATEGORY_ID.CONSUMABLE_RECIPE] = true,
    })
end


function RecipeKnowledgeFilter:SetSelected(value, selected, silent)

	if selected then self:Reset(true) end
	if LibCharacterKnowledge == nil and ( selected and value.id == 2 ) then 
		self:Reset(true) -- no LibCharacterKnowledge -> make 2 not selectable
	else
		local selection = self.selection
		if(selection[value] ~= selected) then
			local delta = selected and 1 or -1
			self.count = self.count + delta
			selection[value] = selected
			if(not silent) then
				self:HandleChange(selection)
			end
		end
	end
end


local world = GetWorldName()
local name = GetDisplayName()
local key = world .. name

function RecipeKnowledgeFilter:FilterLocalResult(itemData)
--    local id = IsItemLinkRecipeKnown(itemData.itemLink)
	local id = 0
	if ( not ( LibCharacterKnowledge == nil ) ) and self:IsSelected(self.valueById[2]) then 
		id = LibCharacterKnowledge.GetItemKnowledgeForCharacter( itemData.itemLink, nil, AwesomeGuildStore_Data[key].crafter )
	elseif IsItemLinkRecipeKnown(itemData.itemLink) then
		id = 1
	end
    local value = self.valueById[id]
    return self.localSelection[value]
end
