local LIB_IDENTIFIER = "LibDateTime"

assert(not _G[LIB_IDENTIFIER], LIB_IDENTIFIER .. " is already loaded")

local lib = {}
_G[LIB_IDENTIFIER] = lib

local SECONDS_PER_MINUTE = 60
local SECONDS_PER_HOUR = SECONDS_PER_MINUTE * 60
local SECONDS_PER_DAY = SECONDS_PER_HOUR * 24
local SECONDS_PER_WEEK = SECONDS_PER_DAY * 7

local WEEKS_IN_YEAR = 52
local WEEKS_IN_LONG_YEAR = 53

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

local WEDNESDAY = 3
local THURSDAY = 4

local TIMEZONE_OFFSET_HOURS = 0
local TIMEZONE_OFFSET_MINUTES = 0
local TIMEZONE_OFFSET_SECONDS = 0
local TIMEZONE_OFFSET = 0

local mfloor = math.floor
-- see http://www.cplusplus.com/reference/ctime/strftime/
local osdate = os.date
local ostime = os.time

local temp = {}

function lib:SetTimezoneOffset(hours, minutes, seconds)
    TIMEZONE_OFFSET_HOURS = hours or tonumber(osdate("%H", 0))
    TIMEZONE_OFFSET_MINUTES = minutes or tonumber(osdate("%M", 0))
    TIMEZONE_OFFSET_SECONDS = seconds or tonumber(osdate("%S", 0))
    TIMEZONE_OFFSET = TIMEZONE_OFFSET_HOURS * SECONDS_PER_HOUR + TIMEZONE_OFFSET_MINUTES * SECONDS_PER_MINUTE + TIMEZONE_OFFSET_SECONDS
end
lib:SetTimezoneOffset()

function lib:IsLeapYear(year)
    return year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0)
end

function lib:CalculateMonthAndDayFromDayOfYear(year, dayOfYear)
    local isLeapYear = lib:IsLeapYear(year)
    local monthForDay = isLeapYear and MONTH_FOR_DAY_FOR_LEAP_YEAR or MONTH_FOR_DAY_FOR_REGULAR_YEAR

    local month = monthForDay[dayOfYear]
    if(not month) then return end

    local startDayOfMonth = isLeapYear and START_DAYS_FOR_LEAP_YEAR or START_DAYS_FOR_REGULAR_YEAR
    local day = 1 + dayOfYear - startDayOfMonth[month]

    return month, day
end

-- returns the unix timestamp for the given input
function lib:CalculateTimeStamp(year, month, day, hour, minute, second)
    ZO_ClearTable(temp)
    temp.year = year or 1970
    temp.month = month or 1
    temp.day = day or 1
    temp.hour = (hour or 0) + TIMEZONE_OFFSET_HOURS
    temp.minute = (minute or 0) + TIMEZONE_OFFSET_MINUTES
    temp.sec = (second or 0) + TIMEZONE_OFFSET_SECONDS
    return ostime(temp)
end

-- any regular year starting on a Thursday and any leap year starting on a Wednesday is a long year
function lib:CalculateIsoWeekCount(year)
    local timestamp = lib:CalculateTimeStamp(year) -- timestamp of first day of the year
    local dayOfWeek = tonumber(osdate("%w", timestamp))
    local longYearStartDay = THURSDAY
    if(lib:IsLeapYear(year)) then
        longYearStartDay = WEDNESDAY
    end
    if(dayOfWeek == longYearStartDay) then
        return WEEKS_IN_LONG_YEAR
    end
    return WEEKS_IN_YEAR
end

function lib:CalculateIsoWeekAndYear(timestamp)
    return tonumber(osdate("%Y", timestamp)), tonumber(osdate("%V", timestamp))
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

function lib:CalculateWeekOffset(timestamp)
    return mfloor((ostime() - timestamp) / SECONDS_PER_WEEK)
end

function lib:GetTraderWeek(weekOffset) -- TODO update usecases
    local _, endTime = GetGuildKioskCycleTimes()
    weekOffset = weekOffset or 0
    if(GetTimeStamp() >= endTime) then weekOffset = weekOffset + 1 end -- GetGuildKioskCycleTimes does not update until the next login when the trader change happens
    endTime = endTime + weekOffset * SECONDS_PER_WEEK
    local startTime = endTime - SECONDS_PER_WEEK

    -- we add a few days because ISO week starts on Monday so the majority of days would be in the wrong week with trader change happening on Sunday
    local isoWeekTime = startTime + SECONDS_PER_DAY * 2 -- TODO: separate this into GetIsoTraderWeek(weekOffset)?
    local year, week = lib:CalculateIsoWeekAndYear(isoWeekTime)
    return lib:CombineIsoWeekAndYear(year, week), startTime, endTime
end

function lib:IsInTraderWeek(timestamp, yearAndWeek) -- TODO
    local weekOffset = 0
    if(yearAndWeek) then
        local yearA, weekA = lib:CalculateIsoWeekAndYear()
        local yearB, weekB = lib:SeparateIsoWeekAndYear(yearAndWeek)
        weekOffset = lib:CalculateIsoWeekDifference(yearA, weekA, yearB, weekB)
    end

    local _, startTime, endTime = lib:GetTraderWeek(weekOffset)
    return not (timestamp < startTime or timestamp >= endTime)
end
