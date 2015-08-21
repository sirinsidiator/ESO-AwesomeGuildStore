local ActivityBase = AwesomeGuildStore.ActivityBase

local CancelSaleOperation = ActivityBase:Subclass()
AwesomeGuildStore.CancelSaleOperation = CancelSaleOperation

function CancelSaleOperation:New(...)
	return ActivityBase.New(self, ...)
end

function CancelSaleOperation:Initialize(guildId, listingIndex)
	self.priority = 2
	self.type = ActivityBase.ACTIVITY_TYPE_CANCEL_SALE
	self.guildId = guildId
	self.listingIndex = listingIndex
end

function CancelSaleOperation:CanExecute()
	return self.tradingHouseWrapper.tradingHouse:CanDoCommonOperation() and GetSelectedTradingHouseGuildId() == self.guildId
end

function CancelSaleOperation:DoExecute()
--	self:PushTradingHouseGuildId(self.guildId)
	--df("CancelTradingHouseListing(%d)", self.listingIndex)
	CancelTradingHouseListing(self.listingIndex)
--	self:PopTradingHouseGuildId()
end

function CancelSaleOperation:GetKey()
	return string.format("%d_%d", self.type, self.guildId) -- TODO: for now we only allow one cancel operation per guild until we find a way to reliably match listings without relying on the index
end