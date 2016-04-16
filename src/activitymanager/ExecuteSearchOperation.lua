local ActivityBase = AwesomeGuildStore.ActivityBase

local ExecuteSearchOperation = ActivityBase:Subclass()
AwesomeGuildStore.ExecuteSearchOperation = ExecuteSearchOperation

local CURRENT_PAGE = 1
local PREVIOUS_PAGE = 2
local NEXT_PAGE = 3
local JUMP_TO_PAGE = 4
ExecuteSearchOperation.CURRENT_PAGE = CURRENT_PAGE
ExecuteSearchOperation.PREVIOUS_PAGE = PREVIOUS_PAGE
ExecuteSearchOperation.NEXT_PAGE = NEXT_PAGE
ExecuteSearchOperation.JUMP_TO_PAGE = JUMP_TO_PAGE

function ExecuteSearchOperation:New(...)
	return ActivityBase.New(self, ...)
end

function ExecuteSearchOperation:Initialize(navType, page)
	self.priority = 4
	self.type = ActivityBase.ACTIVITY_TYPE_EXECUTE_SEARCH
	self.navType = navType or CURRENT_PAGE
	self.page = page
end

function ExecuteSearchOperation:CanExecute()
	return self.tradingHouseWrapper.tradingHouse:CanDoCommonOperation() and GetTradingHouseCooldownRemaining() == 0
end

function ExecuteSearchOperation:DoExecute()
	--d("DoSearch()")
	local tradingHouse = self.tradingHouseWrapper.tradingHouse
	if(self.navType == JUMP_TO_PAGE and self.page) then
		local search = tradingHouse.m_search
		search.m_page = math.max(self.page, 0)
		search.m_hasMorePages = false
		search:InternalExecuteSearch()
	elseif(self.navType == PREVIOUS_PAGE) then
		tradingHouse.m_search:SearchPreviousPage()
	elseif(self.navType == NEXT_PAGE) then
		tradingHouse.m_search:SearchNextPage()
	else
		tradingHouse:DoSearch()
	end
end

function ExecuteSearchOperation:GetKey()
	return string.format("%d", self.type)
end

function ExecuteSearchOperation:SetFromOperation(operation)
	if(operation.type == ActivityBase.ACTIVITY_TYPE_EXECUTE_SEARCH) then
		self.navType = operation.navType
		self.page = operation.page
	end
end
