local L = AwesomeGuildStore.Localization
local CategorySubfilter = AwesomeGuildStore.CategorySubfilter

local ResearchableTraitsFilter = CategorySubfilter:Subclass()
AwesomeGuildStore.ResearchableTraitsFilter = ResearchableTraitsFilter

local SHOW_UNKNOWN_VALUE = 1
local SHOW_KNOWN_VALUE = 2

function ResearchableTraitsFilter:New(name, tradingHouseWrapper, subfilterPreset, ...)
	return CategorySubfilter.New(self, name, tradingHouseWrapper, subfilterPreset, ...)
end

function ResearchableTraitsFilter:ApplyFilterValues(filterArray)
-- do nothing here as we want to filter on the result page
end

function ResearchableTraitsFilter:BeforeRebuildSearchResultsPage(tradingHouseWrapper)
	self.showUnknown = false
	self.showKnown = false

	local group = self.group
	for _, button in pairs(group.buttons) do
		if(button:IsPressed()) then
			if(button.value == SHOW_UNKNOWN_VALUE) then
				self.showUnknown = true
			elseif(button.value == SHOW_KNOWN_VALUE) then
				self.showKnown = true
			end
		end
	end

	return (self.showUnknown ~= self.showKnown)
end

local EQUIP_TYPE_BY_RESEARCH_LINE = {
	[1] = EQUIP_TYPE_CHEST, -- light armor
	[2] = EQUIP_TYPE_FEET,
	[3] = EQUIP_TYPE_HAND,
	[4] = EQUIP_TYPE_HEAD,
	[5] = EQUIP_TYPE_LEGS,
	[6] = EQUIP_TYPE_SHOULDERS,
	[7] = EQUIP_TYPE_WAIST,
	[8] = EQUIP_TYPE_CHEST, -- medium and heavy armor
	[9] = EQUIP_TYPE_FEET,
	[10] = EQUIP_TYPE_HAND,
	[11] = EQUIP_TYPE_HEAD,
	[12] = EQUIP_TYPE_LEGS,
	[13] = EQUIP_TYPE_SHOULDERS,
	[14] = EQUIP_TYPE_WAIST,
}

local BLACKSMITHING_WEAPON_TYPE_BY_RESEARCH_LINE = {
	[1] = WEAPONTYPE_AXE,
	[2] = WEAPONTYPE_HAMMER,
	[3] = WEAPONTYPE_SWORD,
	[4] = WEAPONTYPE_TWO_HANDED_AXE,
	[5] = WEAPONTYPE_TWO_HANDED_HAMMER,
	[6] = WEAPONTYPE_TWO_HANDED_SWORD,
	[7] = WEAPONTYPE_DAGGER,
}

local WOODWORKING_WEAPON_TYPE_BY_RESEARCH_LINE = {
	[1] = WEAPONTYPE_BOW,
	[2] = WEAPONTYPE_FIRE_STAFF,
	[3] = WEAPONTYPE_FROST_STAFF,
	[4] = WEAPONTYPE_LIGHTNING_STAFF,
	[5] = WEAPONTYPE_HEALING_STAFF,
	[6] = WEAPONTYPE_SHIELD,
}

local function GetResearchLineKey(craftingSkillType, researchLineIndex)
	if(craftingSkillType == CRAFTING_TYPE_BLACKSMITHING) then
		if(researchLineIndex <= 7) then
			return ("%d_%d"):format(ITEMTYPE_WEAPON, BLACKSMITHING_WEAPON_TYPE_BY_RESEARCH_LINE[researchLineIndex])
		else
			return ("%d_%d_%d"):format(ITEMTYPE_ARMOR, ARMORTYPE_HEAVY, EQUIP_TYPE_BY_RESEARCH_LINE[researchLineIndex])
		end
	elseif(craftingSkillType == CRAFTING_TYPE_WOODWORKING) then
		return ("%d_%d"):format(ITEMTYPE_WEAPON, WOODWORKING_WEAPON_TYPE_BY_RESEARCH_LINE[researchLineIndex])
	elseif(craftingSkillType == CRAFTING_TYPE_CLOTHIER) then
		if(researchLineIndex <= 7) then
			return ("%d_%d_%d"):format(ITEMTYPE_ARMOR, ARMORTYPE_LIGHT, EQUIP_TYPE_BY_RESEARCH_LINE[researchLineIndex])
		else
			return ("%d_%d_%d"):format(ITEMTYPE_ARMOR, ARMORTYPE_MEDIUM, EQUIP_TYPE_BY_RESEARCH_LINE[researchLineIndex])
		end
	end
end

local traitDictionary = {}
local function BuildTraitDictionary(craftingSkillType)
	for researchLineIndex = 1, GetNumSmithingResearchLines(craftingSkillType) do
		local _,_, numTraits = GetSmithingResearchLineInfo(craftingSkillType, researchLineIndex)
		local key = GetResearchLineKey(craftingSkillType, researchLineIndex)
		if(not traitDictionary[key]) then traitDictionary[key] = {} end

		for traitIndex = 1, numTraits do
			local traitType, _, known = GetSmithingResearchLineTraitInfo(craftingSkillType, researchLineIndex, traitIndex)

			traitDictionary[key][traitType] = {
				known = known,
				researching = (GetSmithingResearchLineTraitTimes(craftingSkillType, researchLineIndex, traitIndex) ~= nil),
				craftingSkillType = craftingSkillType,
				researchLineIndex = researchLineIndex,
				traitIndex = traitIndex,
			}
		end
	end
end
BuildTraitDictionary(CRAFTING_TYPE_BLACKSMITHING)
BuildTraitDictionary(CRAFTING_TYPE_CLOTHIER)
BuildTraitDictionary(CRAFTING_TYPE_WOODWORKING)

local function GetTraitDictionaryForItemLink(itemLink)
	local itemType = GetItemLinkItemType(itemLink)
	local key
	if(itemType == ITEMTYPE_ARMOR) then
		local equipType = GetItemLinkEquipType(itemLink)
		local armorType = GetItemLinkArmorType(itemLink)
		key = ("%d_%d_%d"):format(itemType, armorType, equipType)
	elseif(itemType == ITEMTYPE_WEAPON) then
		local weaponType = GetItemLinkWeaponType(itemLink)
		key = ("%d_%d"):format(itemType, weaponType)
	end
	return traitDictionary[key]
end

local function IsItemLinkTraitKnown(itemLink)
	local traitType = GetItemLinkTraitInfo(itemLink)
	if(traitType > 0) then
		local dictionary = GetTraitDictionaryForItemLink(itemLink)
		if(dictionary) then
			local info = dictionary[traitType]
			if(info) then
				if(not info.known) then
					local _, _, known = GetSmithingResearchLineTraitInfo(info.craftingSkillType, info.researchLineIndex, info.traitIndex)
					info.known = known
					info.researching = (GetSmithingResearchLineTraitTimes(info.craftingSkillType, info.researchLineIndex, info.traitIndex) ~= nil)
				end
				return true, info.known, info.researching
			end
		end
	end
	return false, false, false
end

function ResearchableTraitsFilter:FilterPageResult(index, icon, name, quality, stackCount, sellerName, timeRemaining, purchasePrice)
	local itemLink = GetTradingHouseSearchResultItemLink(index, LINK_STYLE_BRACKETS)
	local researchable, known, researching = IsItemLinkTraitKnown(itemLink)
	local isKnown = (known or researching)
	return researchable and ((self.showUnknown and not isKnown) or (self.showKnown and isKnown))
end
