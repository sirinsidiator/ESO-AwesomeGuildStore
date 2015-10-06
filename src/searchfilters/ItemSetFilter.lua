local L = AwesomeGuildStore.Localization
local CategorySubfilter = AwesomeGuildStore.CategorySubfilter

local ItemSetFilter = CategorySubfilter:Subclass()
AwesomeGuildStore.ItemSetFilter = ItemSetFilter

local SHOW_NORMAL_VALUE = 1
local SHOW_SET_VALUE = 2

function ItemSetFilter:New(name, tradingHouseWrapper, subfilterPreset, ...)
	return CategorySubfilter.New(self, name, tradingHouseWrapper, subfilterPreset, ...)
end

function ItemSetFilter:ApplyFilterValues(filterArray)
-- do nothing here as we want to filter on the result page
end

function ItemSetFilter:BeforeRebuildSearchResultsPage(tradingHouseWrapper)
	self.showNormal = false
	self.showSets = false

	local group = self.group
	for _, button in pairs(group.buttons) do
		if(button:IsPressed()) then
			if(button.value == SHOW_NORMAL_VALUE) then
				self.showNormal = true
			elseif(button.value == SHOW_SET_VALUE) then
				self.showSets = true
			end
		end
	end

	return (self.showNormal ~= self.showSets)
end

function ItemSetFilter:FilterPageResult(index, icon, name, quality, stackCount, sellerName, timeRemaining, purchasePrice)
	local itemLink = GetTradingHouseSearchResultItemLink(index, LINK_STYLE_BRACKETS)
	local hasSet = GetItemLinkSetInfo(itemLink)
	return (self.showNormal and not hasSet) or (self.showSets and hasSet)
end