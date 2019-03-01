local AGS = AwesomeGuildStore

local FilterBase = AGS.class.FilterBase
local ValueRangeFilterBase = AGS.class.ValueRangeFilterBase

local FILTER_ID = AGS.data.FILTER_ID
local CATEGORY_ID = AGS.data.CATEGORY_ID
local SUB_CATEGORY_ID = AGS.data.SUB_CATEGORY_ID
local ITEM_REQUIREMENT_RANGE = AGS.data.ITEM_REQUIREMENT_RANGE
local RANGE_INFO = ITEM_REQUIREMENT_RANGE.BUTTON_INFO

local gettext = AGS.internal.gettext
local GetLevelAndType = AGS.internal.GetLevelAndType
local GetItemLinkRequirementLevelRange = AGS.internal.GetItemLinkRequirementLevelRange

local TRADING_HOUSE_FILTER_TYPE_LEVEL = TRADING_HOUSE_FILTER_TYPE_LEVEL
local TRADING_HOUSE_FILTER_TYPE_CHAMPION_POINTS = TRADING_HOUSE_FILTER_TYPE_CHAMPION_POINTS


local MIN_INDEX = 1
local MAX_INDEX = 2
local MAX_LEVEL = ITEM_REQUIREMENT_RANGE.MAX_LEVEL
local ICON_SIZE = 24

local CAN_SERVER_FILTER_IN_CATEGORY = {
    [CATEGORY_ID.ALL] = true,
    [CATEGORY_ID.WEAPONS] = true,
    [CATEGORY_ID.ARMOR] = true,
    [CATEGORY_ID.JEWELRY] = true,
}

local LevelFilter = ValueRangeFilterBase:Subclass()
AGS.class.LevelFilter = LevelFilter

function LevelFilter:New(...)
    return ValueRangeFilterBase.New(self, ...)
end

function LevelFilter:Initialize()
    ValueRangeFilterBase.Initialize(self, FILTER_ID.LEVEL_FILTER, FilterBase.GROUP_SERVER, {
        -- TRANSLATORS: label of the level filter
        label = gettext("Level Range"),
        min = ITEM_REQUIREMENT_RANGE.MIN_NORMALIZED_LEVEL,
        max = ITEM_REQUIREMENT_RANGE.MAX_NORMALIZED_LEVEL,
        precision = 0,
        enabled = {
            [SUB_CATEGORY_ID.ALL] = true,
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
            [SUB_CATEGORY_ID.CONSUMABLE_ALL] = true,
            [SUB_CATEGORY_ID.CONSUMABLE_FOOD] = true,
            [SUB_CATEGORY_ID.CONSUMABLE_DRINK] = true,
            [SUB_CATEGORY_ID.CONSUMABLE_RECIPE] = true,
            [SUB_CATEGORY_ID.CONSUMABLE_POTION] = true,
            [SUB_CATEGORY_ID.CONSUMABLE_POISON] = true,
            [SUB_CATEGORY_ID.CRAFTING_ALL] = true,
            [SUB_CATEGORY_ID.CRAFTING_BLACKSMITHING] = true,
            [SUB_CATEGORY_ID.CRAFTING_CLOTHIER] = true,
            [SUB_CATEGORY_ID.CRAFTING_WOODWORKING] = true,
            [SUB_CATEGORY_ID.CRAFTING_JEWELRY] = true,
            [SUB_CATEGORY_ID.CRAFTING_ALCHEMY] = true,
            [SUB_CATEGORY_ID.CRAFTING_ENCHANTING] = true,
            [SUB_CATEGORY_ID.MISCELLANEOUS_ALL] = true,
            [SUB_CATEGORY_ID.MISCELLANEOUS_GLYPHS] = true,
        }
    })
end

function LevelFilter:IsLocal()
    return false
end

function LevelFilter:ApplyToSearch(request)
    local category = request:GetPendingCategories()
    if(not CAN_SERVER_FILTER_IN_CATEGORY[category.id]) then return end

    local min = self.serverMin
    local max = self.serverMax
    local minType = min > MAX_LEVEL and TRADING_HOUSE_FILTER_TYPE_CHAMPION_POINTS or TRADING_HOUSE_FILTER_TYPE_LEVEL
    local maxType = max > MAX_LEVEL and TRADING_HOUSE_FILTER_TYPE_CHAMPION_POINTS or TRADING_HOUSE_FILTER_TYPE_LEVEL
    if(minType ~= maxType) then return end

    if(minType == TRADING_HOUSE_FILTER_TYPE_CHAMPION_POINTS) then
        min = min - MAX_LEVEL
        max = max - MAX_LEVEL
    end

    request:SetFilterRange(minType, min, max)
end

function LevelFilter:SetFromItem(itemLink)
    local min, max = GetItemLinkRequirementLevelRange(itemLink)
    if(min) then
        self:SetValues(min, max)
    end
end

function LevelFilter:FilterLocalResult(itemData)
    local itemMin, itemMax = GetItemLinkRequirementLevelRange(itemData.itemLink)
    if(itemMin) then
        return not (itemMax < self.localMin or itemMin > self.localMax)
    end
    return false
end

function LevelFilter:GetFormattedValue(value)
    local level, type = GetLevelAndType(value)
    local icon = RANGE_INFO[type].normal
    return zo_strformat("<<1>> <<2>>", ZO_LocalizeDecimalNumber(level), zo_iconFormat(icon, ICON_SIZE, ICON_SIZE))
end
