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

local traitDictionary = {}
local function BuildTraitDictionary(craftingSkillType)
	if(not traitDictionary[craftingSkillType]) then traitDictionary[craftingSkillType] = {} end
	for researchLineIndex = 1, GetNumSmithingResearchLines(craftingSkillType) do
		local _,_, numTraits = GetSmithingResearchLineInfo(craftingSkillType, researchLineIndex)
		for traitIndex = 1, numTraits do
			local traitType, _, known = GetSmithingResearchLineTraitInfo(craftingSkillType, researchLineIndex, traitIndex)

			traitDictionary[craftingSkillType][traitType] = {
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
	if(itemType == ITEMTYPE_ARMOR) then
		local armorType = GetItemLinkArmorType(itemLink)
		if(armorType == ARMORTYPE_HEAVY) then
			return traitDictionary[CRAFTING_TYPE_BLACKSMITHING]
		elseif(armorType == ARMORTYPE_MEDIUM or armorType == ARMORTYPE_LIGHT) then
			return traitDictionary[CRAFTING_TYPE_CLOTHIER]
		end
	elseif(itemType == ITEMTYPE_WEAPON) then
		local weaponType = GetItemLinkWeaponType(itemLink)
		if(weaponType == WEAPONTYPE_BOW or weaponType == WEAPONTYPE_FIRE_STAFF
			or weaponType == WEAPONTYPE_FROST_STAFF or weaponType == WEAPONTYPE_HEALING_STAFF
			or weaponType == WEAPONTYPE_LIGHTNING_STAFF or weaponType == WEAPONTYPE_SHIELD) then
			return traitDictionary[CRAFTING_TYPE_WOODWORKING]
		elseif(weaponType ~= WEAPONTYPE_NONE) then
			return traitDictionary[CRAFTING_TYPE_BLACKSMITHING]
		end
	end
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
					info.researching = (GetSmithingResearchLineTraitTimes(craftingSkillType, researchLineIndex, traitIndex) ~= nil)
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
