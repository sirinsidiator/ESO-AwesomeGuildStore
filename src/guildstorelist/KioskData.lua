local AGS = AwesomeGuildStore

local EncodeData = AGS.internal.EncodeData
local DecodeData = AGS.internal.DecodeData

local COORD_MULTIPLICATOR = 100000
local DATA_FORMAT = {
    [1] = {
        "integer", -- version
        "integer", -- x * COORD_MULTIPLICATOR
        "integer", -- y * COORD_MULTIPLICATOR
        "string", -- storeIndex
        "integer", -- lastVisited
    }
}
local VERSION = 1
local CURRENT_DATA_FORMAT = DATA_FORMAT[VERSION]

local KioskData = ZO_Object:Subclass()
AGS.class.KioskData = KioskData

function KioskData:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function KioskData:Initialize()
    self.name = ""
    self.storeIndex = ""
    self.x = 0
    self.y = 0
    self.lastVisited = 0
end

function KioskData:HasValidCoordinates()
    return self.x ~= 0 or self.y ~= 0
end

function KioskData:Serialize()
    local data = {
        VERSION,
        self.x * COORD_MULTIPLICATOR,
        self.y * COORD_MULTIPLICATOR,
        self.storeIndex,
        self.lastVisited
    }
    return EncodeData(data, CURRENT_DATA_FORMAT)
end

function KioskData:Deserialize(serializedData)
    local data = DecodeData(serializedData, DATA_FORMAT)
    local i = 2 -- starts with version on 1
    self.x = data[i] / COORD_MULTIPLICATOR
    i = i + 1
    self.y = data[i] / COORD_MULTIPLICATOR
    i = i + 1
    self.storeIndex = data[i]
    i = i + 1
    self.lastVisited = data[i]
end