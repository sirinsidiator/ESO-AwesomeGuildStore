local WrapFunction = AwesomeGuildStore.WrapFunction
local RegisterForEvent = AwesomeGuildStore.RegisterForEvent
local Print = AwesomeGuildStore.Print
local ActivityLogWrapper = ZO_Object:Subclass()
AwesomeGuildStore.ActivityLogWrapper = ActivityLogWrapper

function ActivityLogWrapper:New(...)
	local wrapper = ZO_Object.New(self)
	wrapper:Initialize(...)
	return wrapper
end

function ActivityLogWrapper:GetNumPurchaseEvents(guildId)
	return GetNumGuildEvents(guildId, GUILD_HISTORY_STORE)
end

function ActivityLogWrapper:GetPurchaseEvent(guildId, index)
	local eventType, secsSinceEvent, sellerName, buyerName, itemCount, itemLink, sellPrice, tax = GetGuildEventInfo(guildId, GUILD_HISTORY_STORE, index)
	local subcategory = ComputeGuildHistoryEventSubcategory(eventType, GUILD_HISTORY_STORE)
	if(subcategory == GUILD_HISTORY_STORE_PURCHASES) then
		return eventType, secsSinceEvent, sellerName, buyerName, itemCount, itemLink, sellPrice, tax
	end
end

function ActivityLogWrapper:GetMinMaxPurchaseEventTimes(guildId, startIndex)
	startIndex = math.max(1, startIndex or 1)
	local endIndex = self:GetNumPurchaseEvents(guildId)
	local oldest, newest = math.huge, 0
	for index = startIndex, endIndex do
		local eventType, secsSinceEvent = self:GetPurchaseEvent(guildId, index)
		if(eventType) then
			local time = ZO_NormalizeSecondsSince(secsSinceEvent)
			oldest = math.min(oldest, time)
			newest = math.max(newest, time)
		end
	end
	return oldest, newest, endIndex
end

function ActivityLogWrapper:Initialize()
	self:InitializeGuildState()

	RegisterForEvent(EVENT_GUILD_HISTORY_CATEGORY_UPDATED, function(_, guildId, category)
		if(category == GUILD_HISTORY_STORE) then
			local guildState = self.state[guildId]
			if(not guildState) then Print("guildState not correctly initialized. Please report this to the author.") return end
			local oldest, newest, endIndex = self:GetMinMaxPurchaseEventTimes(guildId, guildState.highestIndex)
			guildState.hasMore = DoesGuildHistoryCategoryHaveMoreEvents(guildId, category)
			guildState.highestIndex = endIndex
			guildState.oldest = oldest
			guildState.newest = newest
		end
	end)

	RegisterForEvent(EVENT_GUILD_SELF_JOINED_GUILD, function(_, guildId, guildName)
		self:InitializeGuildState()
	end)
	RegisterForEvent(EVENT_GUILD_SELF_LEFT_GUILD, function(_, guildId, guildName)
		self:InitializeGuildState()
	end)
end

function ActivityLogWrapper:InitializeGuildState()
	local state = {}
	for i = 1, GetNumGuilds() do
		local guildId = GetGuildId(i)
		local oldest, newest, endIndex = self:GetMinMaxPurchaseEventTimes(guildId)
		state[guildId] = {
			hasMore = DoesGuildHistoryCategoryHaveMoreEvents(guildId, GUILD_HISTORY_STORE),
			highestIndex = endIndex,
			oldest = oldest,
			newest = newest
		}
	end
	self.state = state
end

function ActivityLogWrapper:RequestNewest(guildId)
	if(RequestGuildHistoryCategoryNewest(guildId, GUILD_HISTORY_STORE)) then
		GUILD_HISTORY:IncrementRequestCount()
		return true
	end
	return false
end

function ActivityLogWrapper:RequestOlder(guildId)
	if(RequestGuildHistoryCategoryOlder(guildId, GUILD_HISTORY_STORE)) then
		GUILD_HISTORY:IncrementRequestCount()
		return true
	end
	return false
end

function ActivityLogWrapper:HandleReceivedData(guildId)
	local guildState = self.state[guildId]
end

function ActivityLogWrapper:RequestData(normalizedTime)
	local hasRequestedData = false
	for i = 1, GetNumGuilds() do
		local guildId = GetGuildId(i)
		local guildState = self.state[guildId]
		if(not guildState.initialized or normalizedTime > guildState.newest) then
			guildState.initialized = true
			if(self:RequestNewest(guildId)) then
				hasRequestedData = true
			end
		elseif(normalizedTime < guildState.oldest and guildState.hasMore) then
			if(self:RequestOlder(guildId)) then
				hasRequestedData = true
			end
		end
	end
	return hasRequestedData
end
