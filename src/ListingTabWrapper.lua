TRADING_HOUSE_SORT_LISTING_NAME = 1
TRADING_HOUSE_SORT_LISTING_PRICE = 2
TRADING_HOUSE_SORT_LISTING_TIME = 3

local ListingTabWrapper = ZO_Object:Subclass()
AwesomeGuildStore.ListingTabWrapper = ListingTabWrapper

function ListingTabWrapper:New(saveData)
	local wrapper = ZO_Object.New(self)
	wrapper.saveData = saveData
	return wrapper
end

local function PrepareSortHeader(container, name, key)
	local header = container:GetNamedChild(name)
	header.key = key
	header:SetMouseEnabled(true)
end

local ascSortFunctions = {
	[TRADING_HOUSE_SORT_LISTING_NAME] = function(a, b) return a.data.name < b.data.name end,
	[TRADING_HOUSE_SORT_LISTING_PRICE] = function(a, b) return a.data.purchasePrice < b.data.purchasePrice end,
	[TRADING_HOUSE_SORT_LISTING_TIME] = function(a, b) return a.data.timeRemaining < b.data.timeRemaining end,
}

local descSortFunctions = {
	[TRADING_HOUSE_SORT_LISTING_NAME] = function(a, b) return a.data.name > b.data.name end,
	[TRADING_HOUSE_SORT_LISTING_PRICE] = function(a, b) return a.data.purchasePrice > b.data.purchasePrice end,
	[TRADING_HOUSE_SORT_LISTING_TIME] = function(a, b) return a.data.timeRemaining > b.data.timeRemaining end,
}

function ListingTabWrapper:InitializeListingSortHeaders()
	local control = ZO_TradingHouse
	local sortHeadersControl = control:GetNamedChild("PostedItemsHeader")
	PrepareSortHeader(sortHeadersControl, "Name", TRADING_HOUSE_SORT_LISTING_NAME)
	PrepareSortHeader(sortHeadersControl, "Price", TRADING_HOUSE_SORT_LISTING_PRICE)
	PrepareSortHeader(sortHeadersControl, "TimeRemaining", TRADING_HOUSE_SORT_LISTING_TIME)

	local sortHeaders = ZO_SortHeaderGroup:New(sortHeadersControl, true)

	self.sortHeadersControl = sortHeadersControl
	self.sortHeaders = sortHeaders

	local function OnSortHeaderClicked(key, order)
		self:ChangeSort(key, order)
	end

	sortHeaders:RegisterCallback(ZO_SortHeaderGroup.HEADER_CLICKED, OnSortHeaderClicked)
	sortHeaders:AddHeadersFromContainer()
	self.currentSortKey = self.saveData.listingSortField
	self.currentSortOrder = self.saveData.listingSortOrder
	sortHeaders:SelectHeaderByKey(self.currentSortKey, ZO_SortHeaderGroup.SUPPRESS_CALLBACKS)
	if(not self.currentSortOrder) then -- call it a second time to invert the sort order
		sortHeaders:SelectHeaderByKey(self.currentSortKey, ZO_SortHeaderGroup.SUPPRESS_CALLBACKS)
	end

	local originalScrollListCommit = ZO_ScrollList_Commit
	local noop = function() end
	local originalOnListingsRequestSuccess = TRADING_HOUSE.OnListingsRequestSuccess
	TRADING_HOUSE.OnListingsRequestSuccess = function()
		ZO_ScrollList_Commit = noop
		originalOnListingsRequestSuccess(TRADING_HOUSE)
		ZO_ScrollList_Commit = originalScrollListCommit
		self:UpdateResultList()
	end
end

function ListingTabWrapper:ChangeSort(key, order)
	self.currentSortKey = key
	self.currentSortOrder = order
	self.saveData.listingSortField = key
	self.saveData.listingSortOrder = order
	self:UpdateResultList()
end

function ListingTabWrapper:UpdateResultList()
	local list = TRADING_HOUSE.m_postedItemsList
	local scrollData = ZO_ScrollList_GetDataList(list)
	local sortFunctions = self.currentSortOrder and ascSortFunctions or descSortFunctions
	table.sort(scrollData, sortFunctions[self.currentSortKey])
	ZO_ScrollList_Commit(list)
end
