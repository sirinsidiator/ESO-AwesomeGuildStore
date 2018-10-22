local AGS = AwesomeGuildStore

local FilterBase = AGS.class.FilterBase
local ValueRangeFilterBase = AGS.class.ValueRangeFilterBase

local FILTER_ID = AGS.data.FILTER_ID
local SUB_CATEGORY_ID = AGS.data.SUB_CATEGORY_ID

local gettext = AGS.internal.gettext

local GetItemLinkQuality = GetItemLinkQuality
local TRADING_HOUSE_FILTER_TYPE_QUALITY = TRADING_HOUSE_FILTER_TYPE_QUALITY


local MIN_INDEX = 1
local MAX_INDEX = 2

local QualityFilter = ValueRangeFilterBase:Subclass()
AGS.class.QualityFilter = QualityFilter

function QualityFilter:New(...)
    return ValueRangeFilterBase.New(self, ...)
end

function QualityFilter:Initialize()
    ValueRangeFilterBase.Initialize(self, FILTER_ID.QUALITY_FILTER, FilterBase.GROUP_SERVER, {
        -- TRANSLATORS: label of the quality filter
        label = gettext("Quality Range"),
        min = ITEM_QUALITY_NORMAL,
        max = ITEM_QUALITY_LEGENDARY,
        steps = {
            {
                id = ITEM_QUALITY_NORMAL,
                label = GetString(SI_TRADING_HOUSE_BROWSE_QUALITY_NORMAL),
                icon = "AwesomeGuildStore/images/qualitybuttons/normal_%s.dds",
            },
            {
                id = ITEM_QUALITY_MAGIC,
                label = GetString(SI_TRADING_HOUSE_BROWSE_QUALITY_MAGIC),
                icon = "AwesomeGuildStore/images/qualitybuttons/magic_%s.dds",
            },
            {
                id = ITEM_QUALITY_ARCANE,
                label = GetString(SI_TRADING_HOUSE_BROWSE_QUALITY_ARCANE),
                icon = "AwesomeGuildStore/images/qualitybuttons/arcane_%s.dds",
            },
            {
                id = ITEM_QUALITY_ARTIFACT,
                label = GetString(SI_TRADING_HOUSE_BROWSE_QUALITY_ARTIFACT),
                icon = "AwesomeGuildStore/images/qualitybuttons/artifact_%s.dds",
            },
            {
                id = ITEM_QUALITY_LEGENDARY,
                label = GetString(SI_TRADING_HOUSE_BROWSE_QUALITY_LEGENDARY),
                icon = "AwesomeGuildStore/images/qualitybuttons/legendary_%s.dds",
            }
        }
    })
end

function QualityFilter:IsLocal()
    return false
end

function QualityFilter:ApplyToSearch(search)
    if(not self:IsAttached() or self:IsDefault()) then return end
    local filterValues = search.m_filters[TRADING_HOUSE_FILTER_TYPE_QUALITY].values
    filterValues[MIN_INDEX] = self.min
    filterValues[MAX_INDEX] = self.max
end

function QualityFilter:FilterLocalResult(itemData)
    local quality = GetItemLinkQuality(itemData.itemLink)
    return not (quality < self.localMin or quality > self.localMax)
end

function QualityFilter:CanAttach()
    return true
end
