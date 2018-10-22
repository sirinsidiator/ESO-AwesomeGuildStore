local AGS = AwesomeGuildStore

local tonumber = tonumber
local select = select
local sformat = string.format
local GetItemLinkItemType = GetItemLinkItemType
local GetItemLinkQuality = GetItemLinkQuality
local IsItemLinkCrafted = IsItemLinkCrafted
local GetItemLinkRecipeNumTradeskillRequirements = GetItemLinkRecipeNumTradeskillRequirements
local GetItemLinkRecipeTradeskillRequirement = GetItemLinkRecipeTradeskillRequirement
local GetNonCombatBonus = GetNonCombatBonus
local GetNonCombatBonusLevelTypeForTradeskillType = GetNonCombatBonusLevelTypeForTradeskillType
local GetItemLinkRecipeQualityRequirement = GetItemLinkRecipeQualityRequirement
local ZO_LinkHandler_ParseLink = ZO_LinkHandler_ParseLink
local ITEMTYPE_POTION = ITEMTYPE_POTION
local ITEMTYPE_POISON = ITEMTYPE_POISON
local ITEMTYPE_FOOD = ITEMTYPE_FOOD
local ITEMTYPE_DRINK = ITEMTYPE_DRINK
local ITEM_QUALITY_NORMAL = ITEM_QUALITY_NORMAL
local NON_COMBAT_BONUS_PROVISIONING_RARITY_LEVEL = NON_COMBAT_BONUS_PROVISIONING_RARITY_LEVEL


local function IsItemLinkCraftedAllTypes(itemLink)
    local isCrafted = false
    local itemType = GetItemLinkItemType(itemLink)
    if(itemType == ITEMTYPE_POTION or itemType == ITEMTYPE_POISON) then
        local data = select(24, ZO_LinkHandler_ParseLink(itemLink))
        isCrafted = (tonumber(data) ~= 0) -- assuming that only crafted potions have data in this field
    elseif(itemType == ITEMTYPE_FOOD or itemType == ITEMTYPE_DRINK) then
        isCrafted = (GetItemLinkQuality(itemLink) > ITEM_QUALITY_NORMAL) -- assuming that only crafted food can be better than normal quality
    else
        isCrafted = IsItemLinkCrafted(itemLink)
    end
    return isCrafted
end
AGS.internal.IsItemLinkCraftedAllTypes = IsItemLinkCraftedAllTypes

local function CanItemLinkBeCraftedByPlayer(itemLink)
    for tradeskillIndex = 1, GetItemLinkRecipeNumTradeskillRequirements(itemLink) do
        local tradeskill, levelReq = GetItemLinkRecipeTradeskillRequirement(itemLink, tradeskillIndex)
        local level = GetNonCombatBonus(GetNonCombatBonusLevelTypeForTradeskillType(tradeskill))
        if level < levelReq then
            return false
        end
    end

    local requiredQuality = GetItemLinkRecipeQualityRequirement(itemLink)
    if requiredQuality > 0 then
        local quality = GetNonCombatBonus(NON_COMBAT_BONUS_PROVISIONING_RARITY_LEVEL)
        if(quality < requiredQuality) then
            return false
        end
    end

    return true
end
AGS.internal.CanItemLinkBeCraftedByPlayer = CanItemLinkBeCraftedByPlayer

local function GetItemLinkWritVoucherCount(itemLink)
    local data = select(24, ZO_LinkHandler_ParseLink(itemLink))
    local vouchers = tonumber(data) / 10000
    return tonumber(sformat("%.0f", vouchers))
end
AGS.internal.GetItemLinkWritVoucherCount = GetItemLinkWritVoucherCount
