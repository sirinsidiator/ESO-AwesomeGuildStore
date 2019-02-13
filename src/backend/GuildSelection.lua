local RegisterForEvent = AwesomeGuildStore.RegisterForEvent

local logger = AwesomeGuildStore.internal.logger

local GuildSelection = ZO_Object:Subclass()
AwesomeGuildStore.class.GuildSelection = GuildSelection

function GuildSelection:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function GuildSelection:Initialize(tradingHouseWrapper)
    self.saveData = tradingHouseWrapper.saveData
    self.guilds = {}
    self.guildById = {}
    self.guildByName = {}

    self.originalGetSelectedTradingHouseGuildId = GetSelectedTradingHouseGuildId
    self.originalGetCurrentTradingHouseGuildDetails = GetCurrentTradingHouseGuildDetails
    self.originalSelectTradingHouseGuildId = SelectTradingHouseGuildId

    function GetSelectedTradingHouseGuildId()
        return self:GetSelectedGuildId()
    end

    function GetCurrentTradingHouseGuildDetails()
        if(not self.selectedGuildId) then
            return self.originalGetCurrentTradingHouseGuildDetails()
        end
        local data = self.guildById[self.selectedGuildId]
        return data.guildId, data.guildName, data.guildAlliance
    end

    function SelectTradingHouseGuildId(guildId)
        return self:SetSelectedGuildId(guildId)
    end

    -- apply guild id when necessary
    local function ApplySelectedGuildId()
        self:ApplySelectedGuildId()
    end
    ZO_PreHook("RequestPostItemOnTradingHouse", ApplySelectedGuildId)

    RegisterForEvent(EVENT_TRADING_HOUSE_STATUS_RECEIVED, function()
        self:UpdateGuildData()
        self:TryReselectLastGuildId()
    end)

    local function UpdateGuildData()
        self:UpdateGuildData()
    end
    RegisterForEvent(EVENT_GUILD_SELF_JOINED_GUILD, UpdateGuildData)
    RegisterForEvent(EVENT_GUILD_SELF_LEFT_GUILD, UpdateGuildData)
end

function GuildSelection:UpdateGuildData()
    local guilds = self.guilds
    local guildById = self.guildById
    local guildByName = self.guildByName

    ZO_ClearTable(guilds)
    ZO_ClearTable(guildById)
    ZO_ClearTable(guildByName)

    local guildCount = GetNumTradingHouseGuilds()
    local guildId = self.originalGetCurrentTradingHouseGuildDetails()
    if(guildCount > 1 and guildId > 0) then -- only then we are at a trading house with multiple guilds
        for i = 1, guildCount do
            local guildId, guildName, guildAlliance = GetTradingHouseGuildDetails(i)
            local iconPath = GetAllianceBannerIcon(guildAlliance)
            local entryText = iconPath and zo_iconTextFormat(iconPath, 36, 36, guildName) or guildName
            local guildData = {
                guildId = guildId,
                guildName = guildName,
                guildAlliance = guildAlliance,
                entryText = entryText,
                canBuy = CanBuyFromTradingHouse(guildId),
                canSell = CanSellOnTradingHouse(guildId),
            }
            guilds[i] = guildData
            guildById[guildId] = guildData
            guildByName[guildName] = guildData

            if(i > 1) then
                guildData.previous = guilds[i - 1]
                guildData.previous.next = guildData
            end
        end
        guilds[1].previous = guilds[guildCount]
        guilds[guildCount].next = guilds[1]
    end

    AwesomeGuildStore:FireCallbacks("AvailableGuildsChanged", guilds)
end

function GuildSelection:TryReselectLastGuildId()
    self.selectedGuildId = nil
    local lastGuild = self.guildByName[self.saveData.lastGuildName]
    if(lastGuild) then
        self:SetSelectedGuildId(lastGuild.guildId)
    end
end

function GuildSelection:SetSelectedGuildId(guildId)
    if(not guildId) then return false end
    if(guildId == self.selectedGuildId) then return true end

    local guildData = self.guildById[guildId]
    if(guildData) then
        self.selectedGuildId = guildId
        self.saveData.lastGuildName = guildData.guildName
        AwesomeGuildStore:FireCallbacks("SelectedGuildChanged", guildData)
        return true
    end
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
    if(not currentGuildId or currentGuildId == guildId) then return true end

    logger:Info(string.format("Set selected trading house guild to %s", tostring(guildId)))
    return self.originalSelectTradingHouseGuildId(guildId)
end