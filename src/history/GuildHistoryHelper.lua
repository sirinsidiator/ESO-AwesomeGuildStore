local AGS = AwesomeGuildStore

local WrapFunction = AGS.internal.WrapFunction
local RegisterForEvent = AGS.internal.RegisterForEvent
local chat = AGS.internal.chat
local GuildHistoryHelper = ZO_Object:Subclass()
AGS.class.GuildHistoryHelper = GuildHistoryHelper

function GuildHistoryHelper:New(...)
    local wrapper = ZO_Object.New(self)
    wrapper:Initialize(...)
    return wrapper
end

function GuildHistoryHelper:GetNumPurchaseEvents(guildId)
    return GetNumGuildEvents(guildId, GUILD_HISTORY_STORE)
end

function GuildHistoryHelper:GetPurchaseEvent(guildId, index)
    local eventType, secsSinceEvent, sellerName, buyerName, itemCount, itemLink, sellPrice, tax = GetGuildEventInfo(guildId, GUILD_HISTORY_STORE, index)
    local subcategory = ComputeGuildHistoryEventSubcategory(eventType, GUILD_HISTORY_STORE)
    if(subcategory == GUILD_HISTORY_STORE_PURCHASES) then
        return eventType, secsSinceEvent, sellerName, buyerName, itemCount, itemLink, sellPrice, tax
    end
end

function GuildHistoryHelper:GetMinMaxPurchaseEventTimes(guildId, startIndex)
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

function GuildHistoryHelper:Initialize()
    self:InitializeGuildState()

    RegisterForEvent(EVENT_GUILD_HISTORY_CATEGORY_UPDATED, function(_, guildId, category)
        if(category == GUILD_HISTORY_STORE) then
            local guildState = self.state[guildId]
            if(not guildState) then chat:Print("guildState not correctly initialized. Please report this to the author.") return end
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

function GuildHistoryHelper:InitializeGuildState()
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

function GuildHistoryHelper:RequestNewest(guildId)
    if(RequestMoreGuildHistoryCategoryEvents(guildId, GUILD_HISTORY_STORE, true)) then
        return true
    end
    return false
end

function GuildHistoryHelper:RequestOlder(guildId)
    if(RequestMoreGuildHistoryCategoryEvents(guildId, GUILD_HISTORY_STORE, true)) then
        return true
    end
    return false
end

function GuildHistoryHelper:HandleReceivedData(guildId)
    local guildState = self.state[guildId]
end

function GuildHistoryHelper:RequestData(normalizedTime)
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
