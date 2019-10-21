local AGS = AwesomeGuildStore

local GuildIdMapping = ZO_Object:Subclass()
AGS.class.GuildIdMapping = GuildIdMapping

local UNRESOLVED_NAME = "GuildId%d"

function GuildIdMapping:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function GuildIdMapping:Initialize(saveData, world)
    if(not saveData[world]) then
        saveData[world] = {}
    end

    self.map = saveData[world]
    self.reverseMap = {}
    for id, name in pairs(self.map) do
        self.reverseMap[name] = id
    end
end

function GuildIdMapping:HasGuildName(guildId)
    return self.map[guildId] ~= nil
end

function GuildIdMapping:GetGuildName(guildId)
    return self.map[guildId] or UNRESOLVED_NAME:format(guildId)
end

function GuildIdMapping:GetGuildId(guildName)
    return self.reverseMap[guildName]
end

function GuildIdMapping:UpdateMapping(guildId, guildName)
    if(self.map[guildId]) then
        self.reverseMap[self.map[guildId]] = nil
    end
    self.map[guildId] = guildName
    self.reverseMap[guildName] = guildId
end
