local CategorySubfilter = AwesomeGuildStore.CategorySubfilter

local CraftedItemFilter = CategorySubfilter:Subclass()
AwesomeGuildStore.CraftedItemFilter = CraftedItemFilter

local SHOW_CRAFTED = 1
local SHOW_LOOTED = 2

function CraftedItemFilter:New(name, tradingHouseWrapper, subfilterPreset, ...)
	return CategorySubfilter.New(self, name, tradingHouseWrapper, subfilterPreset, ...)
end

function CraftedItemFilter:ApplyFilterValues(filterArray)
-- do nothing here as we want to filter on the result page
end

function CraftedItemFilter:BeforeRebuildSearchResultsPage(tradingHouseWrapper)
	self.showCrafted = false
	self.showLooted = false

	local group = self.group
	for _, button in pairs(group.buttons) do
		if(button:IsPressed()) then
			if(button.value == SHOW_CRAFTED) then
				self.showCrafted = true
			elseif(button.value == SHOW_LOOTED) then
				self.showLooted = true
			end
		end
	end

	return (self.showCrafted ~= self.showLooted)
end

function CraftedItemFilter:FilterPageResult(index, icon, name, quality, stackCount, sellerName, timeRemaining, purchasePrice)
	local isCrafted = false
	local itemLink = GetTradingHouseSearchResultItemLink(index, LINK_STYLE_BRACKETS)
	local itemType = GetItemLinkItemType(itemLink)
	if(itemType == ITEMTYPE_POTION or itemType == ITEMTYPE_POISON) then
		local data = {ZO_LinkHandler_ParseLink(itemLink)}
		isCrafted = (tonumber(data[24]) ~= 0) -- assuming that only crafted potions have data in this field
	elseif(itemType == ITEMTYPE_FOOD or itemType == ITEMTYPE_DRINK) then
		isCrafted = (GetItemLinkQuality(itemLink) > ITEM_QUALITY_NORMAL) -- assuming that only crafted food can be better than normal quality
	else
		isCrafted = IsItemLinkCrafted(itemLink)
	end
	return (self.showLooted and not isCrafted) or (self.showCrafted and isCrafted)
end
