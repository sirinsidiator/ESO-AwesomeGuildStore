local AGS = AwesomeGuildStore

local RegisterForEvent = AGS.internal.RegisterForEvent
local IsAtGuildKiosk = AGS.internal.IsAtGuildKiosk
local TradingHouseStatus = AGS.internal.TradingHouseStatus
local logger = AGS.internal.logger

local GuildSelection = ZO_InitializingObject:Subclass()
AGS.class.GuildSelection = GuildSelection

function GuildSelection:Initialize(tradingHouseWrapper)
    self.saveData = tradingHouseWrapper.saveData
    self.guilds = {}
    self.guildById = {}

    self.originalGetSelectedTradingHouseGuildId = GetSelectedTradingHouseGuildId
    self.originalGetCurrentTradingHouseGuildDetails = GetCurrentTradingHouseGuildDetails
    self.originalSelectTradingHouseGuildId = SelectTradingHouseGuildId

    function GetSelectedTradingHouseGuildId()
        return self:GetSelectedGuildId() or self.originalGetSelectedTradingHouseGuildId()
    end

    function GetCurrentTradingHouseGuildDetails()
        if not self.selectedGuildId or not self.guildById[self.selectedGuildId] then
            return self.originalGetCurrentTradingHouseGuildDetails()
        end
        local data = self.guildById[self.selectedGuildId]
        return data.guildId, data.guildName, data.guildAlliance
    end

    function SelectTradingHouseGuildId(guildId)
        return self:SetSelectedGuildId(guildId)
    end

    if tradingHouseWrapper:IsConnected() then
        self:OnConnectTradingHouse()
    end

    local function UpdateGuildData()
        if tradingHouseWrapper:IsConnected() then
            self:UpdateGuildData()
        end
    end
    RegisterForEvent(EVENT_GUILD_SELF_JOINED_GUILD, UpdateGuildData)
    RegisterForEvent(EVENT_GUILD_SELF_LEFT_GUILD, UpdateGuildData)
end

function GuildSelection:OnConnectTradingHouse()
    self:UpdateGuildData()
    self:TryReselectLastGuildId()
end

function GuildSelection:UpdateGuildData()
    local guilds = self.guilds
    local guildById = self.guildById

    ZO_ClearTable(guilds)
    ZO_ClearTable(guildById)

    local guildCount = GetNumTradingHouseGuilds()
    if guildCount > 0 then
        local guildIndexById = {}
        for guildIndex = 1, GetNumGuilds() do
            guildIndexById[GetGuildId(guildIndex)] = guildIndex
        end

        for i = 1, guildCount do
            local guildId, guildName, guildAlliance = GetTradingHouseGuildDetails(i)
            local iconPath = GetAllianceBannerIcon(guildAlliance)
            local entryText = iconPath and zo_iconTextFormat(iconPath, 36, 36, guildName) or guildName
            local guildData = {
                guildId = guildId,
                guildIndex = guildIndexById[guildId] or i,
                guildName = guildName,
                guildAlliance = guildAlliance,
                entryText = entryText,
                canBuy = CanBuyFromTradingHouse(guildId),
                canSell = CanSellOnTradingHouse(guildId),
            }
            guilds[i] = guildData
            guildById[guildId] = guildData

            if i > 1 then
                guildData.previous = guilds[i - 1]
                guildData.previous.next = guildData
            end
        end

        guilds[1].previous = guilds[guildCount]
        guilds[guildCount].next = guilds[1]
    end

    AGS.internal:FireCallbacks(AGS.callback.AVAILABLE_GUILDS_CHANGED, guilds)
end

function GuildSelection:TryReselectLastGuildId()
    self.selectedGuildId = nil
    local lastGuild = self.guildById[self.saveData.lastGuildId or -1]
    if lastGuild then
        self:SetSelectedGuildId(lastGuild.guildId)
    else
        local id = self.originalGetCurrentTradingHouseGuildDetails()
        self:SetSelectedGuildId(id)
    end
end

function GuildSelection:SetSelectedGuildId(guildId)
    if not guildId then return false end
    if guildId == self.selectedGuildId then return true end

    local guildData = self.guildById[guildId]
    if not guildData then return false end

    self.selectedGuildId = guildId
    if not IsAtGuildKiosk() then
        self.saveData.lastGuildId = guildId
    end
    AGS.internal:FireCallbacks(AGS.callback.GUILD_SELECTION_CHANGED, guildData)
    return true
end

function GuildSelection:GetSelectedGuildId()
    return self.selectedGuildId
end

function GuildSelection:GetSelectedGuildData()
    return self.guildById[self.selectedGuildId]
end

function GuildSelection:GetGuildData()
    return self.guilds
end

function GuildSelection:IsAppliedGuildId(guildId)
    return guildId == self.originalGetSelectedTradingHouseGuildId()
end

function GuildSelection:ApplySelectedGuildId(guildId)
    guildId = guildId or self.selectedGuildId
    local currentGuildId = self.originalGetSelectedTradingHouseGuildId()
    if currentGuildId == guildId then return true end

    logger:Debug("Set selected trading house guild to %s", tostring(guildId))
    return self.originalSelectTradingHouseGuildId(guildId)
end
