local L = AwesomeGuildStore.Localization
local guildKioskWithoutNameCaption = GetString(SI_GUILD_TRADER_OWNERSHIP_HEADER)

local function IsUnitGuildKiosk(unitTag)
    local caption = GetUnitCaption(unitTag)
    if(caption) then
        return caption:find(guildKioskWithoutNameCaption) ~= nil
    end
    return false
end

AwesomeGuildStore.IsUnitGuildKiosk = IsUnitGuildKiosk


local guildKioskWithNamePattern = GetString(SI_GUILD_KIOSK_DISPLAY_CAPTION_WITH_OWNER):gsub("%(<<1>>%)", "%%((.+)%%)")

local function GetUnitGuildKioskOwner(unitTag)
    local caption = GetUnitCaption(unitTag)
    if(caption) then
        return GetUnitCaption(unitTag):match(guildKioskWithNamePattern)
    end
end

AwesomeGuildStore.GetUnitGuildKioskOwner = GetUnitGuildKioskOwner


local function IsLocationVisible(locationIndex)
    if(not IsMapLocationVisible(locationIndex)) then return false end
    local _, x, y = GetMapLocationIcon(locationIndex)
    if(x < 0 or x > 1 or y < 0 or y > 1) then return false end
    return true
end

AwesomeGuildStore.IsLocationVisible = IsLocationVisible


local function IsCurrentMapZoneMap()
    return GetMapType() == MAPTYPE_ZONE and GetMapContentType() ~= MAP_CONTENT_DUNGEON
end

AwesomeGuildStore.IsCurrentMapZoneMap = IsCurrentMapZoneMap


local function GetKioskName(guildId)
    local name = GetGuildOwnedKioskInfo(guildId)
    if(name) then
        local ownerName = GetGuildName(guildId)
        local kioskName = name:match(L["KIOSK_INFO_NAME_MATCHING_PATTERN"]) or name:match(L["KIOSK_INFO_NAME_MATCHING_PATTERN2"])
        if(not kioskName) then
            df("[AwesomeGuildStore] Warning: Could not match kiosk name: '%s' -- please report this to the author", name)
        end
        return kioskName
    end
end

AwesomeGuildStore.GetKioskName = GetKioskName