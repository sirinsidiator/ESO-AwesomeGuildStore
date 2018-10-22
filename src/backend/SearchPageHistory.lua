local AGS = AwesomeGuildStore

local FilterBase = AGS.class.FilterBase

local SearchPageHistory = ZO_Object:Subclass()
AGS.class.SearchPageHistory = SearchPageHistory

local REQUEST_NEWEST_KEY = "newest"
local REQUEST_NEWEST_THRESHOLD = 60

function SearchPageHistory:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function SearchPageHistory:Initialize()
    self.searches = {}
end

function SearchPageHistory:GetGuildSearches(guildName)
    local searches = self.searches
    if(not searches[guildName]) then
        searches[guildName] = {}
    end

    return searches[guildName]
end

function SearchPageHistory:CreateKeyFromFilterState(filterState) -- TODO: the filterState should offer some sort of hierarchical key
    local categoryState = filterState:GetGroupState(FilterBase.GROUP_CATEGORY) or ""
    local serverState = filterState:GetGroupState(FilterBase.GROUP_SERVER) or ""
    return string.format("%s-%s", categoryState, serverState)
end

function SearchPageHistory:ShouldRequestPage(guildName, filterState, page)
    local key = self:CreateKeyFromFilterState(filterState)
    local searches = self:GetGuildSearches(guildName)
    if(not searches[key]) then
        return true -- haven't searched any page yet
    elseif(searches[key] == true) then
        return false -- already reached the last page
    end
    return page > searches[key]
end

function SearchPageHistory:GetNextPage(guildName, filterState)
    local key = self:CreateKeyFromFilterState(filterState)
    local searches = self:GetGuildSearches(guildName)
    if(not searches[key]) then
        return 0 -- haven't searched any page yet
    elseif(searches[key] == true) then
        return false -- already reached the last page
    end
    return searches[key] + 1
end

function SearchPageHistory:SetHighestSearchedPage(guildName, filterState, page)
    local key = self:CreateKeyFromFilterState(filterState)
    local searches = self:GetGuildSearches(guildName)
    searches[key] = page
end

function SearchPageHistory:SetStateHasNoMorePages(guildName, filterState)
    local key = self:CreateKeyFromFilterState(filterState)
    local searches = self:GetGuildSearches(guildName)
    searches[key] = true
end

function SearchPageHistory:CanRequestNewest(guildName)
    local searches = self:GetGuildSearches(guildName)
    return GetTimeStamp() - (searches[REQUEST_NEWEST_KEY] or 0) > REQUEST_NEWEST_THRESHOLD
end

function SearchPageHistory:SetRequestNewest(guildName)
    local searches = self:GetGuildSearches(guildName)
    searches[REQUEST_NEWEST_KEY] = GetTimeStamp()
end
