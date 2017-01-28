local dict = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
local dictLen = #dict
local fDict = {}
local rDict = {}
dict:gsub(".", function(c) rDict[c] = #fDict table.insert(fDict, c) end)

local DEFAULT_SEPARATOR = ":"

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
}

local decoders = {
    ["string"] = function(value)
        if(not value or value == "") then return "" end
        return tostring(value) or ""
    end,
    ["boolean"] = function(value)
        if(not value or value == "") then return false end
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
}

local VARTYPES = {
    ["string"] = "string",
    ["boolean"] = "boolean",
    ["number"] = "number",
    ["integer"] = "number",
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

AwesomeGuildStore.EncodeValue = EncodeValue
AwesomeGuildStore.DecodeValue = DecodeValue
AwesomeGuildStore.EncodeData = EncodeData
AwesomeGuildStore.DecodeData = DecodeData
