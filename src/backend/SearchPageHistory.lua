local AGS = AwesomeGuildStore

local FilterBase = AGS.class.FilterBase

local SearchPageHistory = ZO_InitializingObject:Subclass()
AGS.class.SearchPageHistory = SearchPageHistory

local REQUEST_NEWEST_KEY = "newest"
local REQUEST_NEWEST_THRESHOLD = 120 -- TODO move into config file

function SearchPageHistory:Initialize()
    self.searches = {}
end

function SearchPageHistory:GetGuildSearches(guildId)
    local searches = self.searches
    if not searches[guildId] then
        searches[guildId] = {}
    end

    return searches[guildId]
end

function SearchPageHistory:CreateKeyFromFilterState(filterState) -- TODO: the filterState should offer some sort of hierarchical key
    local sortState = filterState:GetGroupState(FilterBase.GROUP_SORT) or ""
    local categoryState = filterState:GetGroupState(FilterBase.GROUP_CATEGORY) or ""
    local serverState = filterState:GetGroupState(FilterBase.GROUP_SERVER) or ""
    return string.format("%s;%s;%s", sortState, categoryState, serverState)
end

function SearchPageHistory:ShouldRequestPage(guildId, filterState, page)
    if guildId == nil then return false end

    local key = self:CreateKeyFromFilterState(filterState)
    local searches = self:GetGuildSearches(guildId)
    if not searches[key] then
        return true -- haven't searched any page yet
    elseif searches[key] == true then
        return false -- already reached the last page
    end
    return page > searches[key]
end

function SearchPageHistory:GetNextPage(guildId, filterState)
    if guildId == nil then return 0 end

    local key = self:CreateKeyFromFilterState(filterState)
    local searches = self:GetGuildSearches(guildId)
    if not searches[key] then
        return 0 -- haven't searched any page yet
    elseif searches[key] == true then
        return false -- already reached the last page
    end
    return searches[key] + 1
end

function SearchPageHistory:SetHighestSearchedPage(guildId, filterState, page)
    if guildId == nil then return end
    local key = self:CreateKeyFromFilterState(filterState)
    local searches = self:GetGuildSearches(guildId)
    searches[key] = page
end

function SearchPageHistory:SetStateHasNoMorePages(guildId, filterState)
    if guildId == nil then return end
    local key = self:CreateKeyFromFilterState(filterState)
    local searches = self:GetGuildSearches(guildId)
    searches[key] = true
end

function SearchPageHistory:CanRequestNewest(guildId)
    if guildId == nil then return false, 0 end
    local searches = self:GetGuildSearches(guildId)
    local lastRequestTime = 0
    if searches[REQUEST_NEWEST_KEY] then
        if searches[REQUEST_NEWEST_KEY].page > 0 then
            return true, 0
        end
        lastRequestTime = searches[REQUEST_NEWEST_KEY].time
    end
    local delta = GetTimeStamp() - lastRequestTime
    return delta >= REQUEST_NEWEST_THRESHOLD, math.max(0, math.min(REQUEST_NEWEST_THRESHOLD, REQUEST_NEWEST_THRESHOLD - delta))
end

function SearchPageHistory:SetRequestNewest(guildId, nextPage)
    if guildId == nil then return end
    local searches = self:GetGuildSearches(guildId)
    local data = searches[REQUEST_NEWEST_KEY]
    if not data then
        data = {}
        nextPage = 0
    end
    data.time = GetTimeStamp()
    data.page = nextPage
    searches[REQUEST_NEWEST_KEY] = data
end

function SearchPageHistory:ResetRequestNewestCooldown(guildId)
    if guildId == nil then return end
    local searches = self:GetGuildSearches(guildId)
    local data = searches[REQUEST_NEWEST_KEY]
    if data then
        data.time = 0
    end
end

function SearchPageHistory:GetNextRequestNewestPage(guildId)
    if guildId == nil then return 0 end
    local searches = self:GetGuildSearches(guildId)
    if searches[REQUEST_NEWEST_KEY] then
        return searches[REQUEST_NEWEST_KEY].page
    end
    return 0
end
