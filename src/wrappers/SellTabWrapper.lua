local L = AwesomeGuildStore.Localization
local RegisterForEvent = AwesomeGuildStore.RegisterForEvent

local SellTabWrapper = ZO_Object:Subclass()
AwesomeGuildStore.SellTabWrapper = SellTabWrapper

local iconMarkup = string.format("|t%u:%u:%s|t", 16, 16, "EsoUI/Art/currency/currency_gold.dds")

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
	self:InitializeListedNotification(tradingHouseWrapper)
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

function SellTabWrapper:InitializeListedNotification(tradingHouseWrapper)
	local saveData = self.saveData
	local listedMessage = ""
	tradingHouseWrapper:Wrap("PostPendingItem", function(originalPostPendingItem, self)
		if(self.m_pendingItemSlot and self.m_pendingSaleIsValid) then
			local count = ZO_InventorySlot_GetStackCount(self.m_pendingItem)
			local price = zo_strformat("<<1>> <<2>>", ZO_CurrencyControl_FormatCurrency(self.m_invoiceSellPrice.sellPrice or 0), iconMarkup)
			local _, guildName = GetCurrentTradingHouseGuildDetails()
			local itemLink = GetItemLink(BAG_BACKPACK, self.m_pendingItemSlot)

			listedMessage = zo_strformat(L["LISTED_NOTIFICATION"], count, itemLink, price, guildName)
		end
		originalPostPendingItem(self)
	end)

	RegisterForEvent(EVENT_TRADING_HOUSE_RESPONSE_RECEIVED, function(_, responseType, result)
		if(responseType == TRADING_HOUSE_RESULT_POST_PENDING and result == TRADING_HOUSE_RESULT_SUCCESS) then
			if(saveData.listedNotification and listedMessage ~= "") then
				df("[AwesomeGuildStore] %s", listedMessage)
				listedMessage = ""
			end
		end
	end)
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
