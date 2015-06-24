TRADING_HOUSE_SORT_LISTING_NAME = 1
TRADING_HOUSE_SORT_LISTING_PRICE = 2
TRADING_HOUSE_SORT_LISTING_TIME = 3

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

local ListingTabWrapper = ZO_Object:Subclass()
AwesomeGuildStore.ListingTabWrapper = ListingTabWrapper

function ListingTabWrapper:New(saveData)
	local wrapper = ZO_Object.New(self)
	wrapper.saveData = saveData
	return wrapper
end

function ListingTabWrapper:RunInitialSetup(tradingHouseWrapper)
	self:InitializeListingSortHeaders(tradingHouseWrapper)
	self:InitializeListingCount(tradingHouseWrapper)
	self:InitializeLoadingOverlay(tradingHouseWrapper)
end

local function PrepareSortHeader(container, name, key)
	local header = container:GetNamedChild(name)
	header.key = key
	header:SetMouseEnabled(true)
end

function ListingTabWrapper:InitializeListingSortHeaders(tradingHouseWrapper)
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
	tradingHouseWrapper:Wrap("OnListingsRequestSuccess", function(originalOnListingsRequestSuccess, tradingHouse)
		ZO_ScrollList_Commit = noop
		originalOnListingsRequestSuccess(tradingHouse)
		ZO_ScrollList_Commit = originalScrollListCommit
		self:UpdateResultList()
	end)
end

function ListingTabWrapper:InitializeListingCount(tradingHouseWrapper)
	local tradingHouse = tradingHouseWrapper.tradingHouse
	self.listingControl = tradingHouse.m_currentListings
	self.infoControl = self.listingControl:GetParent()
	self.itemControl = self.infoControl:GetNamedChild("Item")
	self.postedItemsControl = tradingHouse.m_postedItemsHeader:GetParent()
end

function ListingTabWrapper:InitializeLoadingOverlay(tradingHouseWrapper)
	tradingHouseWrapper:PreHook("OnAwaitingResponse", function(self, responseType)
		if(responseType == TRADING_HOUSE_RESULT_LISTINGS_PENDING or responseType == TRADING_HOUSE_RESULT_CANCEL_SALE_PENDING) then
			if(self:IsInListingsMode()) then
				tradingHouseWrapper:ShowLoadingOverlay()
			end
		end
	end)

	tradingHouseWrapper:PreHook("OnResponseReceived", function(self, responseType, result)
		if(responseType == TRADING_HOUSE_RESULT_LISTINGS_PENDING or responseType == TRADING_HOUSE_RESULT_CANCEL_SALE_PENDING) then
			if(result == TRADING_HOUSE_RESULT_SUCCESS) then
				self:UpdateListingCounts()
			end
			tradingHouseWrapper:HideLoadingOverlay()
		end
	end)
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

function ListingTabWrapper:OnOpen(tradingHouseWrapper)
	self.listingControl:SetParent(self.postedItemsControl)
	self.listingControl:ClearAnchors()
	self.listingControl:SetAnchor(TOPLEFT, self.postedItemsControl, TOPLEFT, 55, -47)
	tradingHouseWrapper:SetLoadingOverlayParent(ZO_TradingHousePostedItemsList)
end

function ListingTabWrapper:OnClose(tradingHouseWrapper)
	self.listingControl:SetParent(self.infoControl)
	self.listingControl:ClearAnchors()
	self.listingControl:SetAnchor(TOP, self.itemControl, BOTTOM, 0, 15)
end
