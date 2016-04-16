local ActivityManager = ZO_Object:Subclass()
AwesomeGuildStore.ActivityManager = ActivityManager

local CancelSaleOperation = AwesomeGuildStore.CancelSaleOperation
local RequestListingsOperation = AwesomeGuildStore.RequestListingsOperation
local ExecuteSearchOperation = AwesomeGuildStore.ExecuteSearchOperation
local SwitchGuildOperation = AwesomeGuildStore.SwitchGuildOperation

--local PRIORITY_MAP = {
--	[ACTIVITY_TYPE_POST_ITEM] = 3,
--	[ACTIVITY_TYPE_PURCHASE_ITEM] = 5,
--}
--
--local ACTIVITY_MAP = {
--	[ACTIVITY_TYPE_POST_ITEM] = function(guildId, itemSlot, stackCount, desiredPrice)
--		PushTradingHouseGuildId(guildId)
--		RequestPostItemOnTradingHouse(BAG_BACKPACK, itemSlot, stackCount, desiredPrice)
--		PopTradingHouseGuildId()
--	end,
--	[ACTIVITY_TYPE_PURCHASE_ITEM] = function()
--		-- TODO: save pending itemlink/cost and check if it is still available
--		ConfirmPendingItemPurchase()
--	end,
--}

function ActivityManager:New(...)
	local selector = ZO_Object.New(self)
	selector:Initialize(...)
	return selector
end

function ActivityManager:Initialize(tradingHouseWrapper, loadingIndicator, loadingOverlay)
	self.queue = {}
	self.lookup = {}
	self.tradingHouseWrapper = tradingHouseWrapper
	AGSQ = self.queue
	AGSL = self.lookup

	tradingHouseWrapper:Wrap("OnAwaitingResponse", function(originalOnAwaitingResponse, self, responseType)
		--df("OnAwaitingResponse %d", responseType)
		originalOnAwaitingResponse(self, responseType)
		loadingIndicator:Show()
	end)

	local function HandleTradingHouseReady()
		--d("HandleTradingHouseReady")
		loadingIndicator:Hide()
		self:ExecuteNext()
	end

	tradingHouseWrapper:Wrap("OnResponseReceived", function(originalOnResponseReceived, self, responseType, result)
		--df("OnResponseReceived %d, %s", responseType, tostring(result))
		originalOnResponseReceived(self, responseType, result)
		if(responseType ~= TRADING_HOUSE_RESULT_SEARCH_PENDING) then
			HandleTradingHouseReady()
		end
	end)
	tradingHouseWrapper:Wrap("OnOperationTimeout", function(originalOnOperationTimeout, self)
		--d("OnOperationTimeout")
		originalOnOperationTimeout(self)
		self.m_awaitingResponseType = nil
		HandleTradingHouseReady()
	end)
	tradingHouseWrapper:Wrap("OnSearchCooldownUpdate", function(originalOnSearchCooldownUpdate, self, cooldownMilliseconds)
		--d("OnSearchCooldownUpdate")
		originalOnSearchCooldownUpdate(self, cooldownMilliseconds)
		if(cooldownMilliseconds == 0) then
			HandleTradingHouseReady()
		end
	end)

	ZO_PreHook("ExecuteTradingHouseSearch", function()
		--d("ExecuteTradingHouseSearch")
		loadingOverlay:Show()
	end)

	tradingHouseWrapper:Wrap("OnSearchResultsReceived", function(originalOnSearchResultsReceived, self, guildId, numItemsOnPage, currentPage, hasMorePages)
		--d("OnSearchResultsReceived")
		originalOnSearchResultsReceived(self, guildId, numItemsOnPage, currentPage, hasMorePages)
		loadingOverlay:Hide()
	end)
end

local function ByPriority(a, b)
	if(a.priority == b.priority) then
		return a.time > b.time
	end
	return a.priority > b.priority
end

function ActivityManager:QueueActivity(activity)
	local queue, lookup = self.queue, self.lookup
	activity.time = GetTimeStamp()
	local key = activity:GetKey()
	if(lookup[key] or self.currentActivity == activity) then return false end
	queue[#queue + 1] = activity
	lookup[key] = activity
	--table.sort(queue, ByPriority) -- handle them in the order they come for now
	return true
end

function ActivityManager:ExecuteNext()
	local queue = self.queue
	for i = 1, #queue do
		local activity = queue[i]
		if(activity:CanExecute()) then
			activity:DoExecute()
			self:RemoveActivity(activity)
			self.currentActivity = activity
			return true
		end
	end
	return false
end

function ActivityManager:RemoveActivity(activity)
	self.lookup[activity:GetKey()] = nil
	for i = 1, #self.queue do
		if(self.queue[i]:GetKey() == activity:GetKey()) then -- TODO: we actually want to compare the object and not only the key. it's just a workaround to stop skipping empty pages
			table.remove(self.queue, i)
			break
		end
	end
end

function ActivityManager:GetActivity(key)
	return self.lookup[key]
end

function ActivityManager:CancelSale(listingIndex)
	local guildId = GetSelectedTradingHouseGuildId()
	if(guildId) then
		if(self:QueueActivity(CancelSaleOperation:New(self.tradingHouseWrapper, guildId, listingIndex))) then
			--d("CancelSale queued")
			self.tradingHouseWrapper.listingTab:SetListedItemPending(listingIndex)
			self:ExecuteNext()
		else
		--d("CancelSale already in queue")
		end
	end
end

function ActivityManager:RequestListings()
	local guildId = GetSelectedTradingHouseGuildId()
	if(guildId) then
		if(self:QueueActivity(RequestListingsOperation:New(self.tradingHouseWrapper, guildId))) then
			--d("RequestListings queued")
			self:ExecuteNext()
		else
		--d("RequestListings already in queue")
		end
	end
end

function ActivityManager:ExecuteSearch(navType, page)
	local activity = ExecuteSearchOperation:New(self.tradingHouseWrapper, navType, page)
	if(self:QueueActivity(activity)) then
		--d("ExecuteSearch queued")
		self:ExecuteNext()
	else
		local oldActivity = self:GetActivity(activity:GetKey()) or self.currentActivity
		if(oldActivity) then -- TODO find better solution
			oldActivity:SetFromOperation(activity)
		end
		--d("ExecuteSearch already in queue")
	end
end

function ActivityManager:ExecuteSearchPage(page)
	self:ExecuteSearch(ExecuteSearchOperation.JUMP_TO_PAGE, page)
end

function ActivityManager:ExecuteSearchPreviousPage()
	self:ExecuteSearch(ExecuteSearchOperation.PREVIOUS_PAGE)
end

function ActivityManager:ExecuteSearchNextPage()
	self:ExecuteSearch(ExecuteSearchOperation.NEXT_PAGE)
end

function ActivityManager:SwitchGuild()
	local guildId = GetSelectedTradingHouseGuildId()
	if(guildId) then
		if(self:QueueActivity(SwitchGuildOperation:New(self.tradingHouseWrapper, guildId))) then
			--d("SwitchGuild queued")
			self:ExecuteNext()
		else
		--d("SwitchGuild already in queue")
		end
	end
end
