local CategorySubfilter = AwesomeGuildStore.CategorySubfilter

local KnownRecipeFilter = CategorySubfilter:Subclass()
AwesomeGuildStore.KnownRecipeFilter = KnownRecipeFilter

local SHOW_UNKNOWN_VALUE = 1
local SHOW_KNOWN_VALUE = 2

function KnownRecipeFilter:New(name, tradingHouseWrapper, subfilterPreset, ...)
	return CategorySubfilter.New(self, name, tradingHouseWrapper, subfilterPreset, ...)
end

function KnownRecipeFilter:ApplyFilterValues(filterArray)
-- do nothing here as we want to filter on the result page
end

function KnownRecipeFilter:BeforeRebuildSearchResultsPage(tradingHouseWrapper)
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

function KnownRecipeFilter:FilterPageResult(index, icon, name, quality, stackCount, sellerName, timeRemaining, purchasePrice)
	local itemLink = GetTradingHouseSearchResultItemLink(index, LINK_STYLE_BRACKETS)
	local isKnown = IsItemLinkRecipeKnown(itemLink)
	return (self.showUnknown and not isKnown) or (self.showKnown and isKnown)
end