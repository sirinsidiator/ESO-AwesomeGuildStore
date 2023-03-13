local AGS = AwesomeGuildStore

local chat = AGS.internal.chat
local gettext = AGS.internal.gettext
local guildKioskWithoutNameCaption = GetString(SI_GUILD_TRADER_OWNERSHIP_HEADER)


AGS.internal.IsUnitGuildKiosk = IsUnitGuildKiosk -- TODO this is now an api function. get rid of this assignment


local guildKioskWithNamePattern = GetString(SI_GUILD_KIOSK_DISPLAY_CAPTION_WITH_OWNER):gsub("%(<<1>>%)", "%%((.+)%%)")

local function GetUnitGuildKioskOwnerInfo(unitTag)
    if IsUnitGuildKiosk(unitTag) then
        local guildId = GetUnitGuildKioskOwner(unitTag)
        local caption = GetUnitCaption(unitTag)
        if caption and caption ~= "" then
            return caption:match(guildKioskWithNamePattern), guildId
        elseif AGS.internal.guildIdMapping:HasGuildName(guildId) then
            return AGS.internal.guildIdMapping:GetGuildName(guildId), guildId
        end
    end
end

AGS.internal.GetUnitGuildKioskOwnerInfo = GetUnitGuildKioskOwnerInfo


local function IsCurrentMapZoneMap()
    return GetMapType() == MAPTYPE_ZONE and GetMapContentType() ~= MAP_CONTENT_DUNGEON
end

AGS.internal.IsCurrentMapZoneMap = IsCurrentMapZoneMap

local IRREGULAR_KIOSK_NAMES = {
    -- English
    ["Eafildil"] = "Rinedel",
    ["Zagh"] = "Zagh gro-Stugh",
    ["Jaflinna"] = "Jaflinna Snow-born",
    ["Var"] = "Var the Vague",
}

local CYRILLIC_LOWER_CASE = "абвгдежзийклмнопрстуфхцчшщъыьэюя"
local KIOSK_MATCH_FUNCTIONS = {
    ru = function(infoText)
        local parts = {zo_strsplit(" ", infoText)}
        local found = false
        for i = 1, #parts do
            if not found then
                local first = parts[i]:sub(1,2) -- we are looking at 2 byte wide chars
                found = (CYRILLIC_LOWER_CASE:find(first) ~= nil)
            end
            if found then parts[i] = nil end
        end
        return table.concat(parts, " ")
    end,
    zh = function(infoText)
        local kioskName = infoText:match("^.-的(.-)$")
        if not kioskName then
            kioskName = infoText:match("^(.-)在.-$")
        end
    end,
}

local DEFAULT_KIOSK_MATCH_FUNCTION = function(infoText)
    return infoText:match("^(.-) [%l ]+ .-$")
end

local matchKioskName = KIOSK_MATCH_FUNCTIONS[GetCVar("language.2")] or DEFAULT_KIOSK_MATCH_FUNCTION

local function GetKioskNameFromInfoText(infoText)
    if infoText then
        local kioskName = matchKioskName(infoText)
        if not kioskName or kioskName == "" then
            -- TRANSLATORS: chat text when a kiosk name could not be matched. <<1>> is replaced by the label on the home tab in the guild menu
            chat:Print(gettext("Warning: Could not match kiosk name: '<<1>>' -- please report this to the author", infoText))
            return
        end
        kioskName = zo_strformat("<<1>>", kioskName)
        return IRREGULAR_KIOSK_NAMES[kioskName] or kioskName
    end
end

AGS.internal.GetKioskNameFromInfoText = GetKioskNameFromInfoText


local function GetItemLinkWritVoucherCount(itemLink)
    local data = itemLink:match("|H.-:.-:(.-)|h.-|h")
    local rawVouchers = select(21, zo_strsplit(":", data))
    return tonumber(string.format("%.0f", (rawVouchers / 10000)))
end

AGS.internal.GetItemLinkWritVoucherCount = GetItemLinkWritVoucherCount


local function AdjustLinkStyle(link, linkStyle)
    link = link:gsub("^|H%d", "|H" .. (linkStyle or LINK_STYLE_DEFAULT))
    return link
end
AGS.internal.AdjustLinkStyle = AdjustLinkStyle


local function ClampValue(value, min, max)
    if value < min then
        return min
    elseif value > max then
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
AGS.internal.IsAtGuildKiosk = IsAtGuildKiosk


local GUILD_INFO_SCENE_NAME = "AGS_guildInfo"
local function ShowGuildDetails(guildId, closeCallback)
    GUILD_BROWSER_GUILD_INFO_KEYBOARD.closeCallback = closeCallback
    GUILD_BROWSER_GUILD_INFO_KEYBOARD:SetGuildToShow(guildId)
    SCENE_MANAGER:Show(GUILD_INFO_SCENE_NAME)
end
AGS.internal.GUILD_INFO_SCENE_NAME = GUILD_INFO_SCENE_NAME
AGS.internal.ShowGuildDetails = ShowGuildDetails

local TradingHouseStatus = {
    ["DISCONNECTING"] = "disconnecting",
    ["DISCONNECTED"] = "disconnected",
    ["CONNECTING"] = "connecting",
    ["CONNECTED"] = "connected",
}
AGS.internal.TradingHouseStatus = TradingHouseStatus

local function Noop()
-- do nothing
end
AGS.internal.Noop = Noop