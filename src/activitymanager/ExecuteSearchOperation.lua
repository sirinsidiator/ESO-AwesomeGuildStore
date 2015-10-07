local ActivityBase = AwesomeGuildStore.ActivityBase

local ExecuteSearchOperation = ActivityBase:Subclass()
AwesomeGuildStore.ExecuteSearchOperation = ExecuteSearchOperation

local CURRENT_PAGE = 1
local PREVIOUS_PAGE = 2
local NEXT_PAGE = 3
ExecuteSearchOperation.CURRENT_PAGE = CURRENT_PAGE
ExecuteSearchOperation.PREVIOUS_PAGE = PREVIOUS_PAGE
ExecuteSearchOperation.NEXT_PAGE = NEXT_PAGE

function ExecuteSearchOperation:New(...)
	return ActivityBase.New(self, ...)
end

function ExecuteSearchOperation:Initialize(page)
	self.priority = 4
	self.type = ActivityBase.ACTIVITY_TYPE_EXECUTE_SEARCH
	self.page = page or CURRENT_PAGE
end

function ExecuteSearchOperation:CanExecute()
	return self.tradingHouseWrapper.tradingHouse:CanDoCommonOperation() and GetTradingHouseCooldownRemaining() == 0
end

function ExecuteSearchOperation:DoExecute()
	--d("DoSearch()")
	local tradingHouse = self.tradingHouseWrapper.tradingHouse
	if(self.page == PREVIOUS_PAGE) then
		tradingHouse.m_search:SearchPreviousPage()
	elseif(self.page == NEXT_PAGE) then
		tradingHouse.m_search:SearchNextPage()
	else
		tradingHouse:DoSearch()
	end
end

function ExecuteSearchOperation:GetKey()
	return string.format("%d", self.type)
end
