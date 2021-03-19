local AGS = AwesomeGuildStore
local GetItemLinkItemId = GetItemLinkItemId
local GetItemLinkItemType = GetItemLinkItemType
local GetItemLinkRequiredLevel = GetItemLinkRequiredLevel
local GetItemLinkGlyphMinLevels = GetItemLinkGlyphMinLevels
local IsItemLinkFurnitureRecipe = IsItemLinkFurnitureRecipe
local GetItemLinkRecipeResultItemLink = GetItemLinkRecipeResultItemLink
local GetItemLinkRequiredChampionPoints = GetItemLinkRequiredChampionPoints
local unpack = unpack
local mceil = math.ceil
local mfloor = math.floor
local range = AGS.data.ITEM_REQUIREMENT_RANGE

local LVL = range.LVL
local CP = range.CP
local LVL_STEP = range.LVL_STEP
local CP_STEP = range.CP_STEP
local RANGE_TYPE_LEVEL = range.RANGE_TYPE_LEVEL
local RANGE_TYPE_CHAMPION_POINTS = range.RANGE_TYPE_CHAMPION_POINTS
local MIN_LEVEL_THRESHOLD = range.MIN_LEVEL_THRESHOLD
local MIN_CP_THRESHOLD = range.MIN_CP_THRESHOLD
local MIN_LEVEL = range.MIN_LEVEL
local MAX_LEVEL = range.MAX_LEVEL
local MIN_CHAMPION_POINTS = range.MIN_CHAMPION_POINTS
local MAX_CHAMPION_POINTS = range.MAX_CHAMPION_POINTS
local MIN_NORMALIZED_LEVEL = range.MIN_NORMALIZED_LEVEL
local MAX_NORMALIZED_LEVEL = range.MAX_NORMALIZED_LEVEL

local MATERIAL_REQUIREMENT_LEVELS = range.MATERIAL_REQUIREMENT_LEVELS
local PROVISIONING_ITEM_TYPE_HAS_FULL_RANGE = range.PROVISIONING_ITEM_TYPE_HAS_FULL_RANGE
local PROVISIONING_REQUIREMENT_MAPPING = range.PROVISIONING_REQUIREMENT_MAPPING
local GLYPH_REQUIREMENT_LEVEL_MAPPING = range.GLYPH_REQUIREMENT_LEVEL_MAPPING
local ALCHEMY_REQUIREMENT_LEVEL_MAPPING = range.ALCHEMY_REQUIREMENT_LEVEL_MAPPING

local function GetNormalizedLevelFromItemLink(itemLink)
    return GetItemLinkRequiredLevel(itemLink) + (GetItemLinkRequiredChampionPoints(itemLink) or 0)
end

local function GetNormalizedGlyphMinLevelFromItemLink(itemLink)
    local minLevel, minCp = GetItemLinkGlyphMinLevels(itemLink)
    return (minLevel or MAX_LEVEL) + (minCp or 0)
end

local function GetNormalizedLevel(level, type)
    if(not level) then return nil end

    if(type == RANGE_TYPE_CHAMPION_POINTS) then
        return math.min(level + MAX_LEVEL, MAX_NORMALIZED_LEVEL)
    end
    return math.min(level, MAX_LEVEL)
end

local function GetLevelAndType(normalizedLevel)
    if(not normalizedLevel) then return nil, nil end

    if(normalizedLevel > MAX_LEVEL) then
        return normalizedLevel - MAX_LEVEL, RANGE_TYPE_CHAMPION_POINTS
    end
    return normalizedLevel, RANGE_TYPE_LEVEL
end

local function GetSteppedNormalizedLevel(normalizedLevel)
    local threshold, min, step
    if(normalizedLevel > MAX_LEVEL) then
        threshold, min, step = MIN_CP_THRESHOLD, MAX_LEVEL, CP_STEP
    else
        threshold, min, step = MIN_LEVEL_THRESHOLD, MIN_NORMALIZED_LEVEL, LVL_STEP
    end

    if(normalizedLevel < threshold) then
        return min
    else
        return mfloor(normalizedLevel / step) * step
    end
end

local function GetRequirementLevelRangeFromEquipmentItemLink(itemLink)
    local min = GetNormalizedLevelFromItemLink(itemLink)
    local max

    if(min <= MIN_LEVEL_THRESHOLD) then
        max = MIN_LEVEL_THRESHOLD
    elseif(min < MAX_LEVEL) then
        max = mceil(min / LVL_STEP) * LVL_STEP
    else
        max = mceil(min / CP_STEP) * CP_STEP
    end

    return min, max
end

local function GetLevelData(lookupTable, key)
    local levelData = lookupTable[key]
    if(levelData) then
        return unpack(levelData)
    end
    return nil, nil
end

local function GetRequirementLevelRangeFromProvisioningResultItemLink(itemLink, itemType, specializedItemType)
    if(PROVISIONING_ITEM_TYPE_HAS_FULL_RANGE[specializedItemType]) then
        return MIN_NORMALIZED_LEVEL, MAX_NORMALIZED_LEVEL
    end

    local level = GetNormalizedLevelFromItemLink(itemLink)
    return GetLevelData(PROVISIONING_REQUIREMENT_MAPPING, level)
end

local function GetRequirementLevelRangeFromProvisioningRecipeItemLink(itemLink)
    if(IsItemLinkFurnitureRecipe(itemLink)) then return nil, nil end
    local resultLink = GetItemLinkRecipeResultItemLink(itemLink)
    local itemType, specializedItemType = GetItemLinkItemType(resultLink)
    return GetRequirementLevelRangeFromProvisioningResultItemLink(resultLink, itemType, specializedItemType)
end

local function GetRequirementLevelRangeFromMaterialItemLink(itemLink)
    local itemId = GetItemLinkItemId(itemLink)
    return GetLevelData(MATERIAL_REQUIREMENT_LEVELS, itemId)
end

local function GetRequirementLevelRangeFromGlyphItemLink(itemLink)
    local level = GetNormalizedGlyphMinLevelFromItemLink(itemLink)
    return GetLevelData(GLYPH_REQUIREMENT_LEVEL_MAPPING, level)
end

local function GetRequirementLevelRangeFromAlchemyResultItemLink(itemLink)
    local level = GetNormalizedLevelFromItemLink(itemLink)
    return GetLevelData(ALCHEMY_REQUIREMENT_LEVEL_MAPPING, level)
end

local REQUIREMENT_LEVEL_BY_ITEM_TYPE = {
    [ITEMTYPE_WEAPON] = GetRequirementLevelRangeFromEquipmentItemLink,
    [ITEMTYPE_ARMOR] = GetRequirementLevelRangeFromEquipmentItemLink,
    [ITEMTYPE_FOOD] = GetRequirementLevelRangeFromProvisioningResultItemLink,
    [ITEMTYPE_DRINK] = GetRequirementLevelRangeFromProvisioningResultItemLink,
    [ITEMTYPE_RECIPE] = GetRequirementLevelRangeFromProvisioningRecipeItemLink,
    [ITEMTYPE_POTION] = GetRequirementLevelRangeFromAlchemyResultItemLink,
    [ITEMTYPE_POISON] = GetRequirementLevelRangeFromAlchemyResultItemLink,
    [ITEMTYPE_BLACKSMITHING_RAW_MATERIAL] = GetRequirementLevelRangeFromMaterialItemLink,
    [ITEMTYPE_BLACKSMITHING_MATERIAL] = GetRequirementLevelRangeFromMaterialItemLink,
    [ITEMTYPE_CLOTHIER_RAW_MATERIAL] = GetRequirementLevelRangeFromMaterialItemLink,
    [ITEMTYPE_CLOTHIER_MATERIAL] = GetRequirementLevelRangeFromMaterialItemLink,
    [ITEMTYPE_WOODWORKING_RAW_MATERIAL] = GetRequirementLevelRangeFromMaterialItemLink,
    [ITEMTYPE_WOODWORKING_MATERIAL] = GetRequirementLevelRangeFromMaterialItemLink,
    [ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL] = GetRequirementLevelRangeFromMaterialItemLink,
    [ITEMTYPE_JEWELRYCRAFTING_MATERIAL] = GetRequirementLevelRangeFromMaterialItemLink,
    [ITEMTYPE_POTION_BASE] = GetRequirementLevelRangeFromMaterialItemLink,
    [ITEMTYPE_POISON_BASE] = GetRequirementLevelRangeFromMaterialItemLink,
    [ITEMTYPE_ENCHANTING_RUNE_POTENCY] = GetRequirementLevelRangeFromMaterialItemLink,
    [ITEMTYPE_GLYPH_WEAPON] = GetRequirementLevelRangeFromGlyphItemLink,
    [ITEMTYPE_GLYPH_JEWELRY] = GetRequirementLevelRangeFromGlyphItemLink,
    [ITEMTYPE_GLYPH_ARMOR] = GetRequirementLevelRangeFromGlyphItemLink,
}

local function GetItemLinkRequirementLevelRange(itemLink)
    local itemType, specializedItemType = GetItemLinkItemType(itemLink)
    local GetRequirementLevel = REQUIREMENT_LEVEL_BY_ITEM_TYPE[itemType]
    if(GetRequirementLevel) then
        return GetRequirementLevel(itemLink, itemType, specializedItemType)
    end
    return nil, nil
end

AGS.internal.GetNormalizedLevel = GetNormalizedLevel
AGS.internal.GetLevelAndType = GetLevelAndType
AGS.internal.GetSteppedNormalizedLevel = GetSteppedNormalizedLevel
AGS.internal.GetItemLinkRequirementLevelRange = GetItemLinkRequirementLevelRange
