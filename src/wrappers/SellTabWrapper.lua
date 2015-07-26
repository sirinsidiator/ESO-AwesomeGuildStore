local SellTabWrapper = ZO_Object:Subclass()
AwesomeGuildStore.SellTabWrapper = SellTabWrapper

function SellTabWrapper:New(saveData)
	local wrapper = ZO_Object.New(self)
	wrapper:Initialize(saveData)
	return wrapper
end

function SellTabWrapper:Initialize(saveData)
	self.saveData = saveData

	if(saveData.disableCustomSellTabFilter) then
		self.customFilterDisabled = true
	else
		self.customFilterDisabled = false
		local libCIF = LibStub:GetLibrary("libCommonInventoryFilters", LibStub.SILENT)
		libCIF:disableGuildStoreSellFilters()
	end
end

function SellTabWrapper:RunInitialSetup(tradingHouseWrapper)
	self:InitializeQuickListing(tradingHouseWrapper)
end

function SellTabWrapper:InitializeQuickListing(tradingHouseWrapper)
	self.interceptInventoryItemClicks = false

	ZO_PreHook("ZO_InventorySlot_OnSlotClicked", function(inventorySlot, button)
		if(self.interceptInventoryItemClicks and self.saveData.listWithSingleClick and button == 1) then
			ZO_InventorySlot_DoPrimaryAction(inventorySlot)
			return true
		end
	end)
end

function SellTabWrapper:InitializeCategoryFilter(tradingHouseWrapper)
	local postItems = tradingHouseWrapper.tradingHouse.m_postItems
	local salesCategoryFilter = AwesomeGuildStore.SalesCategorySelector:New(postItems, "AwesomeGuildStoreSalesItemCategory")
	salesCategoryFilter.control:ClearAnchors()
	salesCategoryFilter.control:SetAnchor(TOPLEFT, postItems, TOPRIGHT, 70, -53)
	self.salesCategoryFilter = salesCategoryFilter
end

function SellTabWrapper:SetInterceptInventoryItemClicks(enabled)
	self.interceptInventoryItemClicks = enabled
end

function SellTabWrapper:ResetSalesCategoryFilter()
	if(self.salesCategoryFilter) then
		self.salesCategoryFilter:Reset()
	end
end

function SellTabWrapper:OnOpen(tradingHouseWrapper)
	if(not self.salesCategoryFilter and not self.customFilterDisabled) then
		self:InitializeCategoryFilter(tradingHouseWrapper)
	end
	if(self.salesCategoryFilter) then
		self.salesCategoryFilter:Refresh()
	end
	self.interceptInventoryItemClicks = true
end

function SellTabWrapper:OnClose(tradingHouseWrapper)
	self.interceptInventoryItemClicks = false
end
