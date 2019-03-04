local LIB_IDENTIFIER = "LibDebugLogger"

assert(not _G[LIB_IDENTIFIER], LIB_IDENTIFIER .. " is already loaded")

local lib = {}
_G[LIB_IDENTIFIER] = lib

-- constants
local LOG_LEVEL_DEBUG = "D"
local LOG_LEVEL_INFO = "I"
local LOG_LEVEL_WARNING = "W"
local LOG_LEVEL_ERROR = "E"

-- these are not hard limits and we will only clean up once on UI load
local NUM_MAX_ENTRIES = 10000
local MAX_ENTRY_AGE = 24 * 3600 * 1000 -- one day

-- these are used during UI load before the saved settings become available
local STARTUP_LOG_TRACES = true
local STARTUP_LOG_LEVEL = LOG_LEVEL_DEBUG

local LOG_LEVEL_TO_NUMBER = {
    [LOG_LEVEL_DEBUG] = 1,
    [LOG_LEVEL_INFO] = 2,
    [LOG_LEVEL_WARNING] = 3,
    [LOG_LEVEL_ERROR] = 4,
}
local LOG_LEVEL_TO_STRING = {
    [LOG_LEVEL_DEBUG] = "debug",
    [LOG_LEVEL_INFO] = "info",
    [LOG_LEVEL_WARNING] =  "warning",
    [LOG_LEVEL_ERROR] = "error"
}
local STR_TO_LOG_LEVEL = {}
for level, str in pairs(LOG_LEVEL_TO_STRING) do
    STR_TO_LOG_LEVEL[str] = level
    STR_TO_LOG_LEVEL[string.lower(level)] = level
end

-- variables
local startTime = GetTimeStamp() * 1000 - GetGameTimeMilliseconds()
-- before the library is fully loaded we just store all logs in a temporary table
local log = {}
local temp = {}

local defaultSettings = {
    version = 1,
    logTraces = false, -- save a trace for each call to one of the Log functions
    minLogLevel = LOG_LEVEL_INFO, -- define which entries we will actually keep
}

-- this is what we use before the actual save data is loaded
local settings = ZO_ShallowTableCopy(defaultSettings)
settings.logTraces = STARTUP_LOG_TRACES
settings.minLogLevel = STARTUP_LOG_LEVEL

-- private functions
local function IsFormattingString(input)
    if(type(input) == "string" and input:find("%%%S")) then
        return true
    end
    return false
end

local function FormatTime(timestamp)
    return os.date("%F %T.%%03.0f %z", timestamp / 1000):format(timestamp % 1000)
end

local MAX_SAVE_DATA_LENGTH = 1999 -- buffer length used by ZOS
local function SplitLongStringIfNeeded(value)
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
    return output
end

local function DoLog(level, tag, ...)
    local message = ""
    local count = select("#", ...)
    if(count > 0) then
        local handled = false
        if(IsFormattingString(select(1, ...))) then
            -- use pcall to try formatting the string, otherwise we may end up with an infinite error loop
            handled = pcall(function(...)
                message = string.format(...)
            end, ...)
        end

        if(not handled) then
            ZO_ClearTable(temp)
            for i = 1, select("#", ...) do
                temp[i] = tostring(select(i, ...))
            end
            message = table.concat(temp, " ")
        end
    end

    local now = startTime + GetGameTimeMilliseconds()
    local entry = {
        now,
        FormatTime(now),
        level,
        tag,
        SplitLongStringIfNeeded(message)
    }

    if(settings.logTraces) then
        entry[#entry + 1] = SplitLongStringIfNeeded(debug.traceback())
    end

    log[#log + 1] = entry
end

local function Log(level, tag, ...)
    if(not LOG_LEVEL_TO_NUMBER[level] or not LOG_LEVEL_TO_NUMBER[settings.minLogLevel] or LOG_LEVEL_TO_NUMBER[level] < LOG_LEVEL_TO_NUMBER[settings.minLogLevel]) then return end
    local handled, err = pcall(DoLog, level, tag, ...)
    if(not handled) then -- add a simple log that should hopefully never fail
        local message
        if(type(err) == "string") then
            message = string.sub(err, 1, MAX_SAVE_DATA_LENGTH)
        else
            message = "Could not create log entry"
        end
        log[#log + 1] = {
            startTime + GetGameTimeMilliseconds(),
            "-",
            LOG_LEVEL_ERROR,
            LIB_IDENTIFIER,
            message
        }
    end
end

local Logger = ZO_Object:Subclass()

function Logger:New(tag)
    local obj = ZO_Object.New(self)
    obj.tag = tag
    obj.enabled = true
    return obj
end

-- public api
lib.LOG_LEVEL_DEBUG = LOG_LEVEL_DEBUG
lib.LOG_LEVEL_INFO = LOG_LEVEL_INFO
lib.LOG_LEVEL_WARNING = LOG_LEVEL_WARNING
lib.LOG_LEVEL_ERROR = LOG_LEVEL_ERROR
lib.LOG_LEVEL_TO_STRING = LOG_LEVEL_TO_STRING
lib.STR_TO_LOG_LEVEL = STR_TO_LOG_LEVEL

--- Convenience method to create a new instance of the logger with a combined tag. Can be used to separate logs from different files.
--- @param tag - a string identifier that is appended to the tag of the parent, separated by a slash
--- @return a new logger instance with the combined tag
function Logger:Create(tag)
    return Logger:New(string.format("%s/%s", self.tag, tag))
end

--- setter to turn this logger of so it no longer adds anything to the log when one of its log methods is called.
--- @param enabled - boolean which turns logging on or off
function Logger:SetEnabled(enabled)
    self.enabled = enabled
end

--- method to log messages with the debug log level
--- @param ... - values to log, each of which will get passed through tostring, or string.format in case the first argument contains a formatting token
function Logger:Debug(...)
    if(not self.enabled) then return end
    return Log(LOG_LEVEL_DEBUG, self.tag, ...)
end

--- method to log messages with the info log level
--- @param ... - values to log, each of which will get passed through tostring, or string.format in case the first argument contains a formatting token
function Logger:Info(...)
    if(not self.enabled) then return end
    return Log(LOG_LEVEL_INFO, self.tag, ...)
end

--- method to log messages with the warning log level
--- @param ... - values to log, each of which will get passed through tostring, or string.format in case the first argument contains a formatting token
function Logger:Warn(...)
    if(not self.enabled) then return end
    return Log(LOG_LEVEL_WARNING, self.tag, ...)
end

--- method to log messages with the error log level
--- @param ... - values to log, each of which will get passed through tostring, or string.format in case the first argument contains a formatting token
function Logger:Error(...)
    if(not self.enabled) then return end
    return Log(LOG_LEVEL_ERROR, self.tag, ...)
end

--- @param tag - a string identifier that is used to identify entries made via this logger
--- @return a new logger instance with the passed tag
lib.Create = function(tag)
    return Logger:New(tag)
end

setmetatable(lib, { __call = function(_, tag) return lib.Create(tag) end })

-- initialization
local AddOnManager = GetAddOnManager()
local numAddons = AddOnManager:GetNumAddOns()
local numEnabledAddons = 0
local addOnInfo = {}
for i = 1, numAddons do
    local name, _, _, _, enabled = AddOnManager:GetAddOnInfo(i)
    local version = AddOnManager:GetAddOnVersion(i)
    local directory = AddOnManager:GetAddOnRootDirectoryPath(i)
    if(enabled) then
        addOnInfo[name] = string.format("Addon loaded: %s, AddOnVersion: %d, directory: '%s'", name, version, directory)
        numEnabledAddons = numEnabledAddons + 1
    end
end

local debugInfo = {
    GetDisplayName(),
    GetUnitName("player"),
    FormatTime(startTime),
    GetESOVersionString(),
    GetWorldName(),
    GetString("SI_PLATFORMSERVICETYPE", GetPlatformServiceType()),
    IsConsoleUI() and "gamepad" or "keyboard",
    IsESOPlusSubscriber() and "eso+" or "regular",
    GetCVar("language.2"),
    GetKeyboardLayout(),
    string.format("addon count: %d/%d", numEnabledAddons, numAddons),
    AddOnManager:GetLoadOutOfDateAddOns() and "allow outdated" or "block outdated",
}
Log(LOG_LEVEL_INFO, LIB_IDENTIFIER, "Initializing...\n" .. table.concat(debugInfo, "\n"))

EVENT_MANAGER:RegisterForEvent(LIB_IDENTIFIER, EVENT_LUA_ERROR, function(eventCode, errorString)
    if(errorString) then
        Log(LOG_LEVEL_ERROR, "Lua", errorString)
    end
end)

EVENT_MANAGER:RegisterForEvent(LIB_IDENTIFIER, EVENT_ADD_ON_LOADED, function(event, name)
    Log(LOG_LEVEL_INFO, LIB_IDENTIFIER, addOnInfo[name] or string.format("UI module loaded: %s", name))

    if(name == LIB_IDENTIFIER) then
        SLASH_COMMANDS["/debuglogger"] = function(params)
            local handled = false
            local command, arg = zo_strsplit(" ", params)
            command = string.lower(command)
            arg = string.lower(arg)

            if(command == "stack") then
                local logTraces = (arg == "on")
                df("[%s] %s stack trace logging", LIB_IDENTIFIER, logTraces and "enabled" or "disabled")
                settings.logTraces = logTraces
                handled = true
            elseif(command == "level") then
                local level = STR_TO_LOG_LEVEL[arg] or defaultSettings.minLogLevel
                df("[%s] set log level to %s", LIB_IDENTIFIER, LOG_LEVEL_TO_STRING[level])
                settings.minLogLevel = level
                handled = true
            elseif(command == "clear") then
                log = {}
                LibDebugLoggerLog = log
                df("[%s] log was emptied", LIB_IDENTIFIER)
                handled = true
            end

            if(not handled) then
                local out = {}
                out[#out + 1] = "/debuglogger <command> [argument]"
                out[#out + 1] = "- <stack>     [on/off]"
                out[#out + 1] = "-     Enables or disables the logging"
                out[#out + 1] = "- <level>     [d(ebug)/i(nfo)/w(arning)/e(rror)]"
                out[#out + 1] = "-     Sets the minimum level for logging"
                out[#out + 1] = "- <clear>     Deletes all log entries"
                out[#out + 1] = "-"
                out[#out + 1] = "- Example: /debuglogger stack on"
                d(table.concat(out, "\n"))
            end
        end

        if(LibDebugLoggerLog) then
            local startUpLog = log
            local oldLog = LibDebugLoggerLog
            log = {}

            -- we clean up old entries
            local startIndex = math.max(1, #oldLog + #startUpLog - NUM_MAX_ENTRIES)
            local minTime = startTime - MAX_ENTRY_AGE
            for i = startIndex, #oldLog do
                local entry = oldLog[i]
                if(entry[1] >= minTime) then
                    log[#log + 1] = entry
                end
            end

            -- and append the new ones to new table
            for i = 1, #startUpLog do
                log[#log + 1] = startUpLog[i]
            end
        end
        LibDebugLoggerLog = log

        Log(LOG_LEVEL_INFO, LIB_IDENTIFIER, "Initialization complete")

        -- we set this after the log entry above so it doesn't get filtered
        settings = LibDebugLoggerSettings or ZO_ShallowTableCopy(defaultSettings)
        LibDebugLoggerSettings = settings
    end
end)
