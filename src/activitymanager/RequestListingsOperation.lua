local ActivityBase = AwesomeGuildStore.ActivityBase

local RequestListingsOperation = ActivityBase:Subclass()
AwesomeGuildStore.RequestListingsOperation = RequestListingsOperation

function RequestListingsOperation:New(...)
	return ActivityBase.New(self, ...)
end

function RequestListingsOperation:Initialize(guildId)
	self.priority = 1
	self.type = ActivityBase.ACTIVITY_TYPE_REQUEST_LISTINGS
	self.guildId = guildId
end

function RequestListingsOperation:CanExecute()
	return self.tradingHouseWrapper.tradingHouse:CanDoCommonOperation() and GetSelectedTradingHouseGuildId() == self.guildId
end

function RequestListingsOperation:DoExecute()
--	self:PushTradingHouseGuildId(self.guildId)
	--d("RequestTradingHouseListings()")
	RequestTradingHouseListings()
--	self:PopTradingHouseGuildId()
end

function RequestListingsOperation:GetKey()
	return string.format("%d_%d", self.type, self.guildId)
end
