local ActivityBase = AwesomeGuildStore.ActivityBase

local ExecuteSearchOperation = ActivityBase:Subclass()
AwesomeGuildStore.ExecuteSearchOperation = ExecuteSearchOperation

function ExecuteSearchOperation:New(...)
	return ActivityBase.New(self, ...)
end

function ExecuteSearchOperation:Initialize()
	self.priority = 4
	self.type = ActivityBase.ACTIVITY_TYPE_EXECUTE_SEARCH
end

function ExecuteSearchOperation:CanExecute()
	return self.tradingHouseWrapper.tradingHouse:CanDoCommonOperation() and GetTradingHouseCooldownRemaining() == 0
end

function ExecuteSearchOperation:DoExecute()
	--d("DoSearch()")
	self.tradingHouseWrapper.tradingHouse:DoSearch()
end

function ExecuteSearchOperation:GetKey()
	return string.format("%d", self.type)
end
