local AGS = AwesomeGuildStore

local Print = AGS.internal.Print
local gettext = AGS.internal.gettext
local guildKioskWithoutNameCaption = GetString(SI_GUILD_TRADER_OWNERSHIP_HEADER)

local function IsUnitGuildKiosk(unitTag)
    local caption = GetUnitCaption(unitTag)
    if(caption) then
        return caption:find(guildKioskWithoutNameCaption) ~= nil
    end
    return false
end

AGS.internal.IsUnitGuildKiosk = IsUnitGuildKiosk


local guildKioskWithNamePattern = GetString(SI_GUILD_KIOSK_DISPLAY_CAPTION_WITH_OWNER):gsub("%(<<1>>%)", "%%((.+)%%)")

local function GetUnitGuildKioskOwner(unitTag)
    local caption = GetUnitCaption(unitTag)
    if(caption) then
        return GetUnitCaption(unitTag):match(guildKioskWithNamePattern)
    end
end

AGS.internal.GetUnitGuildKioskOwner = GetUnitGuildKioskOwner


local function IsLocationVisible(locationIndex)
    if(not IsMapLocationVisible(locationIndex)) then return false end
    local _, x, y = GetMapLocationIcon(locationIndex)
    if(x < 0 or x > 1 or y < 0 or y > 1) then return false end
    return true
end

AGS.internal.IsLocationVisible = IsLocationVisible


local function IsCurrentMapZoneMap()
    return GetMapType() == MAPTYPE_ZONE and GetMapContentType() ~= MAP_CONTENT_DUNGEON
end

AGS.internal.IsCurrentMapZoneMap = IsCurrentMapZoneMap


local function GetKioskName(guildId)
    local name = GetGuildOwnedKioskInfo(guildId)
    if(name) then
        local ownerName = GetGuildName(guildId)
        -- TRANSLATORS: patterns to match trader names from the label that is shown on the home tab in the guild menu
        local kioskName = name:match(gettext("(.-) in the .-")) or name:match(gettext("(.-) in .-")) or name:match(gettext("(.-) near .-")) or name:match(gettext("(.-) on .-"))
        if(not kioskName) then
            -- TRANSLATORS: chat text when a kiosk name could not be matched. <<1>> is replaced by the label on the home tab in the guild menu
            Print(gettext("Warning: Could not match kiosk name: '<<1>>' -- please report this to the author", name))
        end
        return kioskName
    end
end

AGS.internal.GetKioskName = GetKioskName


local function ClearCallLater(id)
    EVENT_MANAGER:UnregisterForUpdate("CallLaterFunction"..id)
end

AGS.internal.ClearCallLater = ClearCallLater


local function GetItemLinkWritCount(itemLink)
    local data = itemLink:match("|H.-:.-:(.-)|h.-|h")
    local writCount = select(21, zo_strsplit(":", data))
    return tonumber(string.format("%.0f", (writCount / 10000)))
end

AGS.internal.GetItemLinkWritCount = GetItemLinkWritCount


local function AdjustLinkStyle(link, linkStyle)
    link = link:gsub("^|H%d", "|H" .. (linkStyle or LINK_STYLE_DEFAULT))
    return link
end
AGS.internal.AdjustLinkStyle = AdjustLinkStyle


local function ClampValue(value, min, max)
    if(value < min) then
        return min
    elseif(value > max) then
        return max
    end
    return value
end
AGS.internal.ClampValue = ClampValue


local KIOSK_OPTION_INDEX = 1
local function IsAtGuildKiosk()
    local _, optionType = GetChatterOption(KIOSK_OPTION_INDEX)
    return optionType == CHATTER_START_TRADINGHOUSE
end
AGS.internal.KIOSK_OPTION_INDEX = KIOSK_OPTION_INDEX
AGS.internal.IsAtGuildKiosk = IsAtGuildKiosk
