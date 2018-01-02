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

-- this is just a workaround until ZOS fixes these motif books; can be removed once it works
local EXOTIC_BOOK_DATA = {
    { -- ebonshadow
        achievementId = 2045,
        bookId = 132581,
        chapterStartId = 132582,
        chapterEndId = 132595,
    },
    { -- apostle
        achievementId = 2044,
        bookId = 132549,
        chapterStartId = 132550,
        chapterEndId = 132563,
    }
}

local function TestMotif(motifData, link)
	local itemId = select(3, zo_strsplit(":", link))
	itemId = tonumber(itemId)
	if(itemId < motifData.bookId or itemId > motifData.chapterEndId) then return false end
	if(IsAchievementComplete(motifData.achievementId)) then return true end
	if(itemId ~= motifData.bookId) then
		local index = itemId - motifData.chapterStartId + 1
		local _, numCompleted, numRequired = GetAchievementCriterion(motifData.achievementId, index)
		return numCompleted == numRequired
	end
	return false
end

local function IsExoticMotifKnown(link)
	for i = 1, #EXOTIC_BOOK_DATA do
		if(TestMotif(EXOTIC_BOOK_DATA[i], link)) then return true end
	end
	return false
end
AwesomeGuildStore.IsExoticMotifKnown = IsExoticMotifKnown

function KnownMotifFilter:FilterPageResult(index, icon, name, quality, stackCount, sellerName, timeRemaining, purchasePrice)
	local itemLink = GetTradingHouseSearchResultItemLink(index, LINK_STYLE_BRACKETS)
	local isKnown = IsItemLinkBookKnown(itemLink) or IsExoticMotifKnown(itemLink)
	return (self.showUnknown and not isKnown) or (self.showKnown and isKnown)
end
