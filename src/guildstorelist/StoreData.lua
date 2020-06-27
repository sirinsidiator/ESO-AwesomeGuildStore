local AGS = AwesomeGuildStore

local EncodeValue = AGS.internal.EncodeValue
local DecodeValue = AGS.internal.DecodeValue
local EncodeData = AGS.internal.EncodeData
local DecodeData = AGS.internal.DecodeData

local ARRAY_SEPARATOR = ";"
local COORD_MULTIPLICATOR = 100000
local V1 = 1
local V2 = 2
local DATA_FORMAT = {
    [V1] = {
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
    },
    [V2] = {
        "integer", -- version
        "integer", -- zoneId
        "string", -- mapName
        "integer", -- wayshrineIndex
        "integer", -- locationIndex
        "integer", -- x * COORD_MULTIPLICATOR
        "integer", -- y * COORD_MULTIPLICATOR
        "string", -- serializedKiosks
        "string", -- serializedEntranceIndices
        "integer", -- entranceMapId
        "boolean", -- confirmed
        "boolean", -- onZoneMap
        "integer", -- mapId
    }
}
local CURRENT_VERSION = V2
local CURRENT_DATA_FORMAT = DATA_FORMAT[CURRENT_VERSION]

local StoreData = ZO_Object:Subclass()
AGS.class.StoreData = StoreData

function StoreData:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function StoreData:Initialize()
    self.index = ""
    self.zoneId = 0
    self.mapId = 0
    self.mapName = "" -- TODO remove once we can get the map name from the mapId
    self.wayshrineIndex = 0
    self.locationIndex = 0
    self.x = 0
    self.y = 0
    self.kiosks = nil
    self.entranceMapId = nil
    self.entranceIndices = nil
    self.confirmed = false
    self.onZoneMap = false
end

function StoreData:HasValidCoordinates()
    return self.x ~= 0 or self.y ~= 0
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

local function SerializeEntranceMapId(entranceMapId)
    return entranceMapId or 0
end

local function DeserializeEntranceMapId(serializedEntranceMapId)
    if(serializedEntranceMapId ~= 0) then
        return serializedEntranceMapId
    end
    return nil
end

function StoreData:Serialize()
    local data = {
        CURRENT_VERSION,
        self.zoneId,
        self.mapName,
        self.wayshrineIndex,
        self.locationIndex,
        self.x * COORD_MULTIPLICATOR,
        self.y * COORD_MULTIPLICATOR,
        SerializeKiosks(self.kiosks),
        SerializeEntranceIndices(self.entranceIndices),
        SerializeEntranceMapId(self.entranceMapId),
        self.confirmed,
        self.onZoneMap,
        self.mapId
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
    if data[1] >= V2 then
        self.entranceMapId = DeserializeEntranceMapId(data[i])
    end
    i = i + 1
    self.confirmed = data[i]
    i = i + 1
    self.onZoneMap = data[i]
    i = i + 1
    self.mapId = data[i] or self.mapId
end