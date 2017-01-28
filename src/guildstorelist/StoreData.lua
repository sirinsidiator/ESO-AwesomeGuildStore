local EncodeValue = AwesomeGuildStore.EncodeValue
local DecodeValue = AwesomeGuildStore.DecodeValue
local EncodeData = AwesomeGuildStore.EncodeData
local DecodeData = AwesomeGuildStore.DecodeData

local ARRAY_SEPARATOR = ";"
local COORD_MULTIPLICATOR = 100000
local DATA_FORMAT = {
    [1] = {
        "integer", -- version
        "integer", -- zoneId
        "string", -- mapName
        "integer", -- wayshrineIndex
        "integer", -- locationIndex
        "integer", -- x * COORD_MULTIPLICATOR
        "integer", -- y * COORD_MULTIPLICATOR
        "string", -- serializedKiosks
        "string", -- serializedEntranceIndices
        "integer", -- nearestEntranceIndex
        "boolean", -- confirmed
        "boolean", -- onZoneMap
    }
}
local VERSION = 1
local CURRENT_DATA_FORMAT = DATA_FORMAT[VERSION]

local StoreData = ZO_Object:Subclass()
AwesomeGuildStore.StoreData = StoreData

function StoreData:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function StoreData:Initialize()
    self.index = ""
    self.zoneId = 0
    self.mapName = ""
    self.wayshrineIndex = 0
    self.locationIndex = 0
    self.x = -1
    self.y = -1
    self.kiosks = nil
    self.entranceIndices = nil
    self.nearestEntranceIndex = nil
    self.confirmed = false
    self.onZoneMap = false
end

local function SerializeKiosks(kiosks)
    return table.concat(kiosks, ARRAY_SEPARATOR)
end

local function DeserializeKiosks(serializedKiosks)
    return {zo_strsplit(ARRAY_SEPARATOR, serializedKiosks)}
end

local function SerializeEntranceIndices(entranceIndices)
    local indices = {}
    if(entranceIndices) then
        for i = 1, #entranceIndices do
            indices[i] = EncodeValue("integer", entranceIndices[i])
        end
    end
    return table.concat(indices, ARRAY_SEPARATOR)
end

local function DeserializeEntranceIndices(serializedEntranceIndices)
    local indices = {zo_strsplit(ARRAY_SEPARATOR, serializedEntranceIndices)}
    for i = 1, #indices do
        indices[i] = DecodeValue("integer", indices[i])
    end
    return indices
end

local function SerializeNearestEntranceIndex(nearestEntranceIndex)
    return nearestEntranceIndex or 0
end

local function DeserializeNearestEntranceIndex(serializedNearestEntranceIndex)
    if(serializedNearestEntranceIndex ~= 0) then
        return serializedNearestEntranceIndex
    end
    return nil
end

function StoreData:Serialize()
    local data = {
        VERSION,
        self.zoneId,
        self.mapName,
        self.wayshrineIndex,
        self.locationIndex,
        self.x * COORD_MULTIPLICATOR,
        self.y * COORD_MULTIPLICATOR,
        SerializeKiosks(self.kiosks),
        SerializeEntranceIndices(self.entranceIndices),
        SerializeNearestEntranceIndex(self.nearestEntranceIndex),
        self.confirmed,
        self.onZoneMap
    }
    return EncodeData(data, CURRENT_DATA_FORMAT)
end

function StoreData:Deserialize(serializedData)
    local data = DecodeData(serializedData, DATA_FORMAT)
    local i = 2 -- starts with version on 1
    self.zoneId = data[i]
    i = i + 1
    self.mapName = data[i]
    i = i + 1
    self.wayshrineIndex = data[i]
    i = i + 1
    self.locationIndex = data[i]
    i = i + 1
    self.x = data[i] / COORD_MULTIPLICATOR
    i = i + 1
    self.y = data[i] / COORD_MULTIPLICATOR
    i = i + 1
    self.kiosks = DeserializeKiosks(data[i])
    i = i + 1
    self.entranceIndices = DeserializeEntranceIndices(data[i])
    i = i + 1
    self.nearestEntranceIndex = DeserializeNearestEntranceIndex(data[i])
    i = i + 1
    self.confirmed = data[i]
    i = i + 1
    self.onZoneMap = data[i]
end