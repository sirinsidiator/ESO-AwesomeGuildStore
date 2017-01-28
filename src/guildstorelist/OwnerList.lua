local LDT = LibStub("LibDateTime")

local function SortDesc(a, b) return a > b end

local OwnerList = ZO_Object:Subclass()
AwesomeGuildStore.OwnerList = OwnerList

function OwnerList:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function OwnerList:Initialize(saveData)
    self.saveData = saveData
    local weekOrder = {}
    for week in pairs(saveData) do
        weekOrder[#weekOrder + 1] = week
    end
    table.sort(weekOrder, SortDesc)
    self.weekOrder = weekOrder
end

function OwnerList:GetCurrentWeek()
    local week, year = LDT:New():GetIsoWeek()
    return LDT:CombineIsoWeekAndYear(year, week)
end

function OwnerList:IsTimeInCurrentWeek(time)
    return LDT:IsInTraderWeek(LDT:New(time))
end

function OwnerList:GetStartAndEndForWeek(yearAndWeek)
    local weekA, yearA = LDT:New():GetIsoWeek()
    local yearB, weekB = LDT:SeparateIsoWeekAndYear(yearAndWeek)
    local weekOffset = LDT:CalculateIsoWeekDifference(yearA, weekA, yearB, weekB)
    local _, startTime, endTime = LDT:GetTraderWeek(weekOffset)
    return startTime, endTime
end

function OwnerList:HasDataForWeek(week)
    return self.saveData[week] ~= nil
end

function OwnerList:GetDataForWeek(week)
    return self.saveData[week] or {}
end

function OwnerList:SetCurrentOwner(kioskName, guildName)
    local week = self:GetCurrentWeek()
    if(not self:HasDataForWeek(week)) then
        self.weekOrder[#self.weekOrder + 1] = week
        table.sort(self.weekOrder, SortDesc)
    end
    local weekData = self:GetDataForWeek(week)
    if(not guildName and not weekData[kioskName]) then
        -- set entry to false when the trader is not hired
        weekData[kioskName] = false
    elseif(guildName) then
        weekData[kioskName] = guildName
    end
    self.saveData[week] = weekData
end

function OwnerList:GetCurrentOwner(kioskName)
    local week = self:GetCurrentWeek()
    local weekData = self:GetDataForWeek(week)
    return weekData[kioskName]
end

function OwnerList:GetLastKnownOwner(kioskName)
    for _, week in ipairs(self.weekOrder) do
        local weekData = self:GetDataForWeek(week)
        if(weekData[kioskName]) then
            return weekData[kioskName]
        end
    end
end

function OwnerList:GetOwnerHistory(kioskName)
    local history = {}
    for _, week in ipairs(self.weekOrder) do
        local weekData = self:GetDataForWeek(week)
        if(weekData[kioskName]) then
            history[week] = weekData[kioskName]
        end
    end
    return history
end