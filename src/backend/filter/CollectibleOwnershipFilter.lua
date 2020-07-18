local AGS = AwesomeGuildStore

local FilterBase = AGS.class.FilterBase
local MultiChoiceFilterBase = AGS.class.MultiChoiceFilterBase

local FILTER_ID = AGS.data.FILTER_ID
local SUB_CATEGORY_ID = AGS.data.SUB_CATEGORY_ID

local gettext = AGS.internal.gettext

local function IsItemCollected(itemLink)
    local collectibleId = GetItemLinkContainerCollectibleId(itemLink)
    return IsCollectibleUnlocked(collectibleId)
end

local CollectibleOwnershipFilter = MultiChoiceFilterBase:Subclass()
AGS.class.CollectibleOwnershipFilter = CollectibleOwnershipFilter

function CollectibleOwnershipFilter:New(...)
    return MultiChoiceFilterBase.New(self, ...)
end

function CollectibleOwnershipFilter:Initialize()
    -- TRANSLATORS: title of the collectible ownership filter in the left panel on the search tab
    MultiChoiceFilterBase.Initialize(self, FILTER_ID.COLLECTIBLE_OWNERSHIP_FILTER, FilterBase.GROUP_LOCAL, gettext("Collectible Ownership"), {
        {
            id = false,
            -- TRANSLATORS: tooltip text for the collectible ownership filter
            label = gettext("Uncollected"),
            icon = "EsoUI/Art/Campaign/overview_indexIcon_bonus_%s.dds",
        },
        {
            id = true,
            -- TRANSLATORS: tooltip text for the collectible ownership filter
            label = gettext("Collected"),
            icon = "EsoUI/Art/Journal/journal_tabIcon_loreLibrary_%s.dds",
        },
    })
    self:SetEnabledSubcategories({
        [SUB_CATEGORY_ID.CONSUMABLE_CONTAINER] = true,
    })
end

function CollectibleOwnershipFilter:FilterLocalResult(itemData)
    local id = IsItemCollected(itemData.itemLink)
    local value = self.valueById[id]
    return self.localSelection[value]
end
