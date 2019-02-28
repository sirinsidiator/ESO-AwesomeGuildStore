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
                label = GetString("SI_ITEMQUALITY", ITEM_QUALITY_NORMAL),
                icon = "AwesomeGuildStore/images/qualitybuttons/normal_%s.dds",
            },
            {
                id = ITEM_QUALITY_MAGIC,
                label = GetString("SI_ITEMQUALITY", ITEM_QUALITY_MAGIC),
                icon = "AwesomeGuildStore/images/qualitybuttons/magic_%s.dds",
            },
            {
                id = ITEM_QUALITY_ARCANE,
                label = GetString("SI_ITEMQUALITY", ITEM_QUALITY_ARCANE),
                icon = "AwesomeGuildStore/images/qualitybuttons/arcane_%s.dds",
            },
            {
                id = ITEM_QUALITY_ARTIFACT,
                label = GetString("SI_ITEMQUALITY", ITEM_QUALITY_ARTIFACT),
                icon = "AwesomeGuildStore/images/qualitybuttons/artifact_%s.dds",
            },
            {
                id = ITEM_QUALITY_LEGENDARY,
                label = GetString("SI_ITEMQUALITY", ITEM_QUALITY_LEGENDARY),
                icon = "AwesomeGuildStore/images/qualitybuttons/legendary_%s.dds",
            }
        }
    })

    local qualityById = {}
    for i = 1, #self.config.steps do
        local step = self.config.steps[i]
        local color = GetItemQualityColor(step.id)
        step.colorizedLabel = color:Colorize(step.label)
        qualityById[step.id] = step
    end
    self.qualityById = qualityById
end

function QualityFilter:SetFromItem(itemLink)
    local quality = GetItemLinkQuality(itemLink)
    self:SetValues(quality, quality)
end

function QualityFilter:IsLocal()
    return false
end

function QualityFilter:ApplyToSearch()
    if(not self:IsAttached() or self:IsDefault()) then return end
    SetTradingHouseFilterRange(TRADING_HOUSE_FILTER_TYPE_QUALITY, self.min, self.max)
end

function QualityFilter:FilterLocalResult(itemData)
    local quality = GetItemLinkQuality(itemData.itemLink)
    return not (quality < self.localMin or quality > self.localMax)
end

function QualityFilter:CanFilter(subcategory)
    return true
end

function QualityFilter:GetTooltipText(min, max)
    if(min ~= self.config.min or max ~= self.config.max) then
        local out = {}
        for id = min, max do
            local step = self.qualityById[id]
            out[#out + 1] = step.colorizedLabel
        end
        return table.concat(out, ", ")
    end
    return ""
end