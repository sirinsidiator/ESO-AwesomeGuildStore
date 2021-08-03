local AGS = AwesomeGuildStore

local FilterBase = AGS.class.FilterBase
local MultiChoiceFilterBase = AGS.class.MultiChoiceFilterBase

local FILTER_ID = AGS.data.FILTER_ID
local SUB_CATEGORY_ID = AGS.data.SUB_CATEGORY_ID

local gettext = AGS.internal.gettext

local function IsSetItemCollected(itemLink)
    if not IsItemLinkSetCollectionPiece(itemLink) then return nil end
    return IsItemSetCollectionPieceUnlocked(GetItemLinkItemId(itemLink))
end

local function IsContainerCollected(itemLink)
    local collectibleId = GetItemLinkContainerCollectibleId(itemLink)
    if collectibleId == 0 then return nil end
    return IsCollectibleUnlocked(collectibleId)
end

local function IsItemCollected(itemLink)
    if GetItemLinkEquipType(itemLink) == EQUIP_TYPE_INVALID then
        return IsContainerCollected(itemLink)
    else
        return IsSetItemCollected(itemLink)
    end
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
            label = GetString(SI_ITEM_FORMAT_STR_SET_COLLECTION_PIECE_LOCKED),
            icon = "EsoUI/Art/Campaign/overview_indexIcon_bonus_%s.dds",
        },
        {
            id = true,
            label = GetString(SI_ITEM_FORMAT_STR_SET_COLLECTION_PIECE_UNLOCKED),
            icon = "EsoUI/Art/Journal/journal_tabIcon_loreLibrary_%s.dds",
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
        [SUB_CATEGORY_ID.CONSUMABLE_CONTAINER] = true,
        [SUB_CATEGORY_ID.CONSUMABLE_TROPHY] = true,
    })
end

function CollectibleOwnershipFilter:FilterLocalResult(itemData)
    local id = IsItemCollected(itemData.itemLink)
    -- don't show items without a collection when the filter is active
    if id == nil then return false end

    local value = self.valueById[id]
    return self.localSelection[value]
end
