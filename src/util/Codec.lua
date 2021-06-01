local dict = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
local dictLen = #dict
local fDict = {}
local rDict = {}
dict:gsub(".", function(c) rDict[c] = #fDict table.insert(fDict, c) end)

local DEFAULT_SEPARATOR = ":"

local EncodeBase64, DecodeBase64
do
    -- based on http://lua-users.org/wiki/BaseSixtyFour
    local BASE64_SUFFIX = { "", "==", "=" }
    local BASE64_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local BASE64_INVALID_CHARACTER_PATTERN = string.format("[^%s=]", BASE64_CHARACTERS)

    local encodeTemp = {}
    local function CharacterToBinary(input)
        local output = ""
        local byte = input:byte()
        for i = 8, 1, -1 do
            encodeTemp[9 - i] = byte % 2 ^ i - byte % 2 ^ (i - 1) > 0 and "1" or "0"
        end
        return table.concat(encodeTemp, "")
    end

    local function BinaryToBase64(input)
        if(#input < 6) then return "" end
        local c = 0
        for i = 1, 6 do
            c = c + (input:sub(i, i) == "1" and 2 ^ (6 - i) or 0)
        end
        return BASE64_CHARACTERS:sub(c + 1, c + 1)
    end

    function EncodeBase64(value)
        return (value:gsub(".", CharacterToBinary) .. "0000"):gsub("%d%d%d?%d?%d?%d?", BinaryToBase64) .. BASE64_SUFFIX[#value % 3 + 1]
    end

    local decodeTemp = {}
    local function Base64ToBinary(input)
        if(input == "=") then return "" end
        local byte = BASE64_CHARACTERS:find(input) - 1
        for i = 6, 1, -1 do
            decodeTemp[7 - i] = byte % 2 ^ i - byte % 2 ^ (i - 1) > 0 and "1" or "0"
        end
        return table.concat(decodeTemp, "")
    end

    local function BinaryToCharacter(input)
        if (#input ~= 8) then return "" end
        local c = 0
        for i = 1, 8 do
            c = c + (input:sub(i, i) == "1" and 2 ^ (8 - i) or 0)
        end
        return string.char(c)
    end

    function DecodeBase64(value)
        value = value:gsub(BASE64_INVALID_CHARACTER_PATTERN, "")
        return (value:gsub(".", Base64ToBinary):gsub("%d%d%d?%d?%d?%d?%d?%d?", BinaryToCharacter))
    end
end

local encoders = {
    ["string"] = function(value)
        return tostring(value)
    end,
    ["boolean"] = function(value)
        if(not value) then return "" end
        return "1"
    end,
    ["number"] = function(value)
        if(value == 0) then return "" end
        return tostring(value)
    end,
    ["integer"] = function(value)
        if(value == 0) then return "" end
        local result, sign = "", ""
        if(value < 0) then
            sign = "-"
            value = -value
        end
        value = math.floor(value)
        repeat
            result = fDict[(value % dictLen) + 1] .. result
            value = math.floor(value / dictLen)
        until value == 0
        return sign .. result
    end,
    ["base64"] = EncodeBase64
}

local decoders = {
    ["string"] = function(value)
        if(not value or value == "") then return "" end
        return tostring(value) or ""
    end,
    ["boolean"] = function(value)
        if(not value or value == "" or value == "0") then return false end
        return true
    end,
    ["number"] = function(value)
        if(not value or value == "") then return 0 end
        return tonumber(value) or 0
    end,
    ["integer"] = function(value)
        if(not value or value == "") then return 0 end
        local result, i, sign, error = 0, 0, 1, false
        if(value:sub(1, 1) == "-") then
            value = value:sub(2)
            sign = -1
        end
        string.reverse(value):gsub(".", function(c)
            if(error) then return end
            if(not rDict[c]) then error = true return end
            result = result + rDict[c] * math.pow(dictLen, i)
            i = i + 1
        end)
        if(error) then return 0 end
        return result * sign
    end,
    ["base64"] = DecodeBase64
}

local VARTYPES = {
    ["string"] = "string",
    ["boolean"] = "boolean",
    ["number"] = "number",
    ["integer"] = "number",
    ["base64"] = "string",
}

local function EncodeValue(inputType, value)
    local actualType = type(value)
    local expectedType = VARTYPES[inputType]
    assert(actualType == expectedType, string.format("expected type '%s', got '%s'", expectedType, actualType))
    return encoders[inputType](value)
end

local function DecodeValue(type, value)
    return decoders[type](value)
end

local function EncodeData(data, type, separator)
    for i = 1, #data do
        data[i] = EncodeValue(type[i], data[i])
    end
    return table.concat(data, separator or DEFAULT_SEPARATOR)
end

local function DecodeData(encodedString, format, separator)
    local type, version
    local data = {}
    separator = separator or DEFAULT_SEPARATOR
    for value in (encodedString .. separator):gmatch("(.-)" .. separator) do
        if(not type) then
            version = DecodeValue("integer", value)
            type = format[version]
            if(not type) then return end
            data[#data + 1] = version
        else
            data[#data + 1] = DecodeValue(type[#data + 1], value)
        end
    end
    return data, version
end

local MAX_SAVE_DATA_LENGTH = 1999 -- buffer length used by ZOS
local function WriteToSavedVariable(t, key, value)
    local output = value
    local byteLength = #value
    if(byteLength > MAX_SAVE_DATA_LENGTH) then
        output = {}
        local startPos = 1
        local endPos = startPos + MAX_SAVE_DATA_LENGTH - 1
        while startPos <= byteLength do
            output[#output + 1] = value:sub(startPos, endPos)
            startPos = endPos + 1
            endPos = startPos + MAX_SAVE_DATA_LENGTH - 1
        end
    end
    t[key] = output
end

local function ReadFromSavedVariable(t, key, defaultValue)
    local value = t[key] or defaultValue
    if(type(value) == "table") then
        return table.concat(value, "")
    end
    return value
end

local AGS = AwesomeGuildStore

AGS.internal.EncodeValue = EncodeValue
AGS.internal.DecodeValue = DecodeValue
AGS.internal.EncodeData = EncodeData
AGS.internal.DecodeData = DecodeData
AGS.internal.WriteToSavedVariable = WriteToSavedVariable
AGS.internal.ReadFromSavedVariable = ReadFromSavedVariable
