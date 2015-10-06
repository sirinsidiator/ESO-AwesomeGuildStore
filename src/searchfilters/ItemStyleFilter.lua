local L = AwesomeGuildStore.Localization
local CategorySubfilter = AwesomeGuildStore.CategorySubfilter

local ItemStyleFilter = CategorySubfilter:Subclass()
AwesomeGuildStore.ItemStyleFilter = ItemStyleFilter

local OTHER_STYLES = {
	[0] = true,
	[10] = true,
	[11] = true,
	[12] = true,
	[13] = true,
	[18] = true,
	[21] = true,
	[22] = true,
	[26] = true,
	[27] = true,
	[30] = true,
	[31] = true,
	[32] = true,
	[33] = true,
	[35] = true,
}
local IMPERIAL_STYLE_VALUE = 16
local OTHER_STYLE_VALUE = 99

function ItemStyleFilter:New(name, tradingHouseWrapper, subfilterPreset, ...)
	return CategorySubfilter.New(self, name, tradingHouseWrapper, subfilterPreset, ...)
end

function ItemStyleFilter:ApplyFilterValues(filterArray)
-- do nothing here as we want to filter on the result page
end

function ItemStyleFilter:BeforeRebuildSearchResultsPage(tradingHouseWrapper)
	self.selectedStyles = {}
	self.showOtherStyles = false
	local hasSelections = false

	local group = self.group
	for _, button in pairs(group.buttons) do
		if(button:IsPressed()) then
			if(button.value == OTHER_STYLE_VALUE) then
				self.showOtherStyles = true
			elseif(button.value == IMPERIAL_STYLE_VALUE) then
				self.selectedStyles[34] = true -- there are two different imperial styles it seems
			else
				self.selectedStyles[button.value] = true
			end
			hasSelections = true
		end
	end

	return hasSelections
end

function ItemStyleFilter:FilterPageResult(index, icon, name, quality, stackCount, sellerName, timeRemaining, purchasePrice)
	local itemLink = GetTradingHouseSearchResultItemLink(index, LINK_STYLE_BRACKETS)
	local itemStyle = GetItemLinkItemStyle(itemLink)
	return self.selectedStyles[itemStyle] or (self.showOtherStyles and OTHER_STYLES[itemStyle])
end
