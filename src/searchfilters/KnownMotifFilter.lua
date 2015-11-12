local L = AwesomeGuildStore.Localization
local CategorySubfilter = AwesomeGuildStore.CategorySubfilter

local KnownMotifFilter = CategorySubfilter:Subclass()
AwesomeGuildStore.KnownMotifFilter = KnownMotifFilter

local SHOW_UNKNOWN_VALUE = 1
local SHOW_KNOWN_VALUE = 2

function KnownMotifFilter:New(name, tradingHouseWrapper, subfilterPreset, ...)
	return CategorySubfilter.New(self, name, tradingHouseWrapper, subfilterPreset, ...)
end

function KnownMotifFilter:ApplyFilterValues(filterArray)
-- do nothing here as we want to filter on the result page
end


function KnownMotifFilter:BeforeRebuildSearchResultsPage(tradingHouseWrapper)
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

-- TODO: this is just a workaround until ZOS fixes the mercenary motif books; remove it once it works
local MERCENARY_ACHIEVEMENT_ID = 1348
local MERCENARY_BOOK_ITEM_ID = 64715
local MERCENARY_CHAPTER_START_ID = 64716
local MERCENARY_CHAPTER_END_ID = 64729
local function IsMercenaryMotifKnown(link)
	local itemId = select(3, zo_strsplit(":", link))
	itemId = tonumber(itemId)
	if(itemId < MERCENARY_BOOK_ITEM_ID or itemId > MERCENARY_CHAPTER_END_ID) then return false end
	if(IsAchievementComplete(MERCENARY_ACHIEVEMENT_ID)) then return true end
	if(itemId ~= MERCENARY_BOOK_ITEM_ID) then
	local index = itemId - MERCENARY_CHAPTER_START_ID + 1
	local _, numCompleted, numRequired = GetAchievementCriterion(MERCENARY_ACHIEVEMENT_ID, index)
		return numCompleted == numRequired
	end
	return false
end

function KnownMotifFilter:FilterPageResult(index, icon, name, quality, stackCount, sellerName, timeRemaining, purchasePrice)
	local itemLink = GetTradingHouseSearchResultItemLink(index, LINK_STYLE_BRACKETS)
	local isKnown = IsItemLinkBookKnown(itemLink) or IsMercenaryMotifKnown(itemLink)
	return (self.showUnknown and not isKnown) or (self.showKnown and isKnown)
end
