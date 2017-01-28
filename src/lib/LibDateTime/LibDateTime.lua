local LIB_IDENTIFIER = "LibDateTime"
local lib = LibStub:NewLibrary(LIB_IDENTIFIER, 1)

if not lib then
    return	-- already loaded and no upgrade necessary
end

local function Log(message, ...)
    df("[%s] %s", LIB_IDENTIFIER, message:format(...))
end

local SECONDS_PER_MINUTE = 60
local SECONDS_PER_HOUR = SECONDS_PER_MINUTE * 60
local SECONDS_PER_DAY = SECONDS_PER_HOUR * 24
local SECONDS_PER_WEEK = SECONDS_PER_DAY * 7

local DAYS_PER_YEAR = 365
local DAYS_PER_LEAP_YEAR = 366
local DAYS_PER_YEAR_AVG = 365.25

local WEEKS_IN_YEAR = 52
local WEEKS_IN_LONG_YEAR = 53

local START_YEAR = 1970
-- 1970 is not a leap year, but 1968 is, so we are 2 * 0.25 days in
local LEAP_DAY_OFFSET = 0.5
-- for the other way around we only count only 1 average day
local REVERSE_LEAP_DAY_OFFSET = 0.25

local function InitializeDayAndMonthLookupTables(daysPerMonth)
    local monthForDay, startDayForMonth = {}, {}
    local startDay = 1
    for i = 1, #daysPerMonth do
        local nextStartDay = startDay + daysPerMonth[i]
        for j = startDay, nextStartDay - 1 do
            monthForDay[j] = i
        end
        startDayForMonth[i] = startDay
        startDay = nextStartDay
    end
    return monthForDay, startDayForMonth
end

local DAYS_PER_MONTH_REGULAR_YEAR = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
local DAYS_PER_MONTH_LEAP_YEAR = {31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
local MONTH_FOR_DAY_FOR_REGULAR_YEAR, START_DAYS_FOR_REGULAR_YEAR = InitializeDayAndMonthLookupTables(DAYS_PER_MONTH_REGULAR_YEAR)
local MONTH_FOR_DAY_FOR_LEAP_YEAR, START_DAYS_FOR_LEAP_YEAR = InitializeDayAndMonthLookupTables(DAYS_PER_MONTH_LEAP_YEAR)

local SUNDAY = 0
local WEDNESDAY = 3
local THURSDAY = 4
local ISO_SUNDAY = 7
local BASE_DAY_OF_WEEK = THURSDAY -- 1970-01-01 was a Thursday

local DATE_FORMAT = {
    ["iso"] = "%%Y-%%m-%%d",
    ["en"] = "%%m/%%d/%%y",
    ["de"] = "%%d.%%m.%%Y",
    ["fr"] = "%%d-%%m-%%Y",
    ["jp"] = "%%Y年%%m月%%d日",
    ["ru"] = "%%d.%%m.%%y",
}

local TIME_FORMAT = {
    ["iso"] = "%%H:%%M:%%S",
    ["en"] = "%%I:%%M:%%S %%p",
}

lib.FORMAT_ISO_DATE = "%Y-%m-%d" -- TODO remove?
lib.FORMAT_ISO_TIME = "%H:%M:%S"

local function GetDateFormatForCurrentLocale()
    local lang = GetCVar("language.2")
    return DATE_FORMAT[lang] or DATE_FORMAT["iso"]
end

local function GetTimeFormatForCurrentLocale()
    return TIME_FORMAT["iso"]
end

local function GetDateAndTimeFormatForCurrentLocale()
    return string.format("%s %s", GetDateFormatForCurrentLocale(), GetTimeFormatForCurrentLocale())
end

local mfloor = math.floor

local DateTime = ZO_Object:Subclass()
lib.DateTime = DateTime -- TODO

function DateTime:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function DateTime:Initialize(timestamp)
    self.timestamp = timestamp or GetTimeStamp()
    local timezone = lib:CalculateLocalTimeZone() -- TODO: timezone won't change -> calculate once in load?
    local localTimestamp = self.timestamp + timezone * SECONDS_PER_HOUR
    self.year, self.month, self.day, self.dayOfYear = lib:CalculateDate(localTimestamp)
    self.dayOfWeek = lib:CalculateDayOfWeek(localTimestamp)

    local seconds = localTimestamp % SECONDS_PER_DAY
    self.hour = mfloor(seconds / SECONDS_PER_HOUR)
    seconds = seconds % SECONDS_PER_HOUR
    self.minute = mfloor(seconds / SECONDS_PER_MINUTE)
    self.second = seconds % SECONDS_PER_MINUTE
end

function DateTime:GetTimeStamp()
    return self.timestamp
end

local function ToStringWithLeadingZero(value)
    if(value < 10) then
        return string.format("0%d", value)
    end
    return tostring(value)
end

function DateTime:Format(formattingString)
    local result = formattingString or "%c"

    local hour12 = self.hour % 12
    hour12 = (hour12 == 0 and 12 or hour12)
    local postfix = mfloor(self.hour / 12) > 0 and "PM" or "AM"

    local shortYear = tostring(self.year):sub(-2)

    result = result:gsub("%%c", GetDateAndTimeFormatForCurrentLocale())
    result = result:gsub("%%x", GetDateFormatForCurrentLocale())
    result = result:gsub("%%X", GetTimeFormatForCurrentLocale())
    result = result:gsub("%%d", ToStringWithLeadingZero(self.day))
    result = result:gsub("%%H", ToStringWithLeadingZero(self.hour))
    result = result:gsub("%%I", ToStringWithLeadingZero(hour12))
    result = result:gsub("%%M", ToStringWithLeadingZero(self.minute))
    result = result:gsub("%%m", ToStringWithLeadingZero(self.month))
    result = result:gsub("%%p", postfix)
    result = result:gsub("%%S", ToStringWithLeadingZero(self.second))
    result = result:gsub("%%w", self.dayOfWeek)
    result = result:gsub("%%Y", self.year)
    result = result:gsub("%%y", shortYear)
    result = result:gsub("%%", "%%")
    return result
end

function DateTime:GetUTCSecondOfDay()
    return self.timestamp % SECONDS_PER_DAY
end

function DateTime:GetDayOfWeek()
    return self.dayOfWeek
end

function DateTime:GetWeek()
    return mfloor(self.dayOfYear / 7) + 1
end

function DateTime:GetIsoDayOfWeek()
    if(self.dayOfWeek == SUNDAY) then
        return ISO_SUNDAY
    end
    return self.dayOfWeek
end

function DateTime:GetIsoWeek()
    local year = self.year
    local dayOfWeek = self:GetIsoDayOfWeek()
    local week = mfloor((self.dayOfYear - dayOfWeek + 10) / 7)
    if(week < 1) then 
        return lib:CalculateIsoWeekCount(year - 1), year - 1
    end
    if(week > lib:CalculateIsoWeekCount(year)) then
        return 1, year + 1
    end
    return week, year
end



function lib:CalculateDayOfWeek(timestamp)
    return (BASE_DAY_OF_WEEK + mfloor(timestamp / SECONDS_PER_DAY)) % 7
end

function lib:IsLeapYear(year)
    return year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0)
end

function lib:CalculateMonthAndDayFromDayOfYear(dayOfYear, isLeapYear)
    local monthForDay = isLeapYear and MONTH_FOR_DAY_FOR_LEAP_YEAR or MONTH_FOR_DAY_FOR_REGULAR_YEAR

    local month = monthForDay[dayOfYear]
    if(not month) then return end

    local startDayOfMonth = isLeapYear and START_DAYS_FOR_LEAP_YEAR or START_DAYS_FOR_REGULAR_YEAR
    local day = 1 + dayOfYear - startDayOfMonth[month]

    return month, day
end

-- calculate the full year, month and day for a timestamp after 1970-01-01
function lib:CalculateDate(timestamp)
    if(timestamp < 0) then return end

    local daysSince = mfloor(timestamp / SECONDS_PER_DAY)
    local yearsSince = mfloor((daysSince + LEAP_DAY_OFFSET) / DAYS_PER_YEAR_AVG)
    local leapYears = mfloor(yearsSince / 4 + REVERSE_LEAP_DAY_OFFSET) -- this approximation is fine for our use case
    daysSince = daysSince - yearsSince * DAYS_PER_YEAR - leapYears

    local year = START_YEAR + yearsSince
    local dayOfYear = 1 + daysSince
    local month, day = lib:CalculateMonthAndDayFromDayOfYear(dayOfYear, lib:IsLeapYear(year))
    if(not month) then return end

    return year, month, day, dayOfYear
end

function lib:CalculateLocalTimeZone()
    return (GetSecondsSinceMidnight() - GetTimeStamp() % SECONDS_PER_DAY) / SECONDS_PER_HOUR
end

function lib:CalculateTimeStamp(year, month, day, hour, minute, second)
    local yearsSince = year - START_YEAR
    local timestamp = mfloor(yearsSince * DAYS_PER_YEAR_AVG + REVERSE_LEAP_DAY_OFFSET) * SECONDS_PER_DAY
    local isLeapYear = lib:IsLeapYear(year)
    local startDayOfMonth = isLeapYear and START_DAYS_FOR_LEAP_YEAR or START_DAYS_FOR_REGULAR_YEAR
    timestamp = timestamp + (startDayOfMonth[month or 1] - 1 + (day or 1) - 1) * SECONDS_PER_DAY
    timestamp = timestamp + (hour or 0) * SECONDS_PER_HOUR
    timestamp = timestamp + (minute or 0) * SECONDS_PER_MINUTE
    timestamp = timestamp + (second or 0)
    return timestamp
end

-- any regular year starting on a Thursday and any leap year starting on a Wednesday is a long year
function lib:CalculateIsoWeekCount(year)
    local timestamp = lib:CalculateTimeStamp(year) -- timestamp of first day of the year
    local dayOfWeek = lib:CalculateDayOfWeek(timestamp)
    local longYearStartDay = THURSDAY
    if(lib:IsLeapYear(year)) then
        longYearStartDay = WEDNESDAY
    end
    if(dayOfWeek == longYearStartDay) then
        return WEEKS_IN_LONG_YEAR
    end
    return WEEKS_IN_YEAR
end

function lib:CombineIsoWeekAndYear(year, week)
    return year * 100 + week
end

function lib:SeparateIsoWeekAndYear(yearAndWeek)
    local year = mfloor(yearAndWeek / 100)
    local week = yearAndWeek % 100
    return year, week
end

function lib:CalculateIsoWeekDifference(yearA, weekA, yearB, weekB)
    if(yearA == yearB) then
        return weekB - weekA
    elseif(yearA < yearB) then
        return -lib:CalculateIsoWeekDifference(yearB, weekB, yearA, weekA)
    else
        local weekDiff = -weekB
        for year = yearB, yearA - 1 do
            weekDiff = weekDiff + lib:CalculateIsoWeekCount(year)
        end
        return -(weekDiff + weekA)
    end
end

function lib:New(...)
    return DateTime:New(...)
end

local function GetStartTimeOfTraderWeek(date)
    local timeDiff = date:GetUTCSecondOfDay() - lib.TRADER_CHANGE_SECOND_OF_DAY
    local dayDiff = (date:GetDayOfWeek() - lib.TRADER_CHANGE_DAY_OF_WEEK) * SECONDS_PER_DAY
    return date:GetTimeStamp() - dayDiff - timeDiff
end

function lib:GetTraderWeek(weekOffset)
    local date = DateTime:New(GetTimeStamp() + (weekOffset or 0) * SECONDS_PER_WEEK)
    local startTime = DateTime:New(GetStartTimeOfTraderWeek(date))
    local endTime = DateTime:New(startTime:GetTimeStamp() + SECONDS_PER_WEEK)

    -- we add a few days because ISO week starts on Monday so the majority of days would be in the wrong week with trader change happening on Sunday
    local isoWeekTime = DateTime:New(startTime:GetTimeStamp() + SECONDS_PER_DAY * 2)
    local week, year = isoWeekTime:GetIsoWeek()
    return lib:CombineIsoWeekAndYear(year, week), startTime, endTime
end

function lib:IsInTraderWeek(date, weekOffset)
    local time = date:GetTimeStamp()
    local week = DateTime:New(GetTimeStamp() + (weekOffset or 0) * SECONDS_PER_WEEK)
    local startTime = GetStartTimeOfTraderWeek(week)
    if(time < startTime) then return false end
    local endTime = startTime + SECONDS_PER_WEEK
    if(time >= endTime) then return false end
    return true
end

local function Unload()
end

local SERVER_EU = "EU Megaserver"
local SERVER_NA = "NA Megaserver"
local SERVER_PTS = "PTS"
local SERVER_TRADER_CHANGE_OFFSET = { -- we don't support the old times before 2016-10-16 to keep it simple
    [SERVER_EU] = 19, -- EU: Sunday 19:00 UTC
    [SERVER_NA] = 25, -- NA: Monday 01:00 UTC
    [SERVER_PTS] = 36 -- PTS: Monday 12:00 UTC
}

local function Load()
    -- determine which server and locale we are on and load the appropriate tables/constants
    local offset = SERVER_TRADER_CHANGE_OFFSET[GetWorldName()] or 0
    lib.TRADER_CHANGE_SECOND_OF_DAY = (offset % 24) * SECONDS_PER_HOUR
    lib.TRADER_CHANGE_DAY_OF_WEEK = mfloor(offset / 24)

    lib.Unload = Unload
end

if(lib.Unload) then lib.Unload() end
Load()
