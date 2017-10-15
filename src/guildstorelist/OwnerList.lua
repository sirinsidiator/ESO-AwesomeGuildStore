local LDT = LibStub("LibDateTime")

local function SortDesc(a, b) return a > b end

local OwnerList = ZO_Object:Subclass()
AwesomeGuildStore.OwnerList = OwnerList

function OwnerList:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function OwnerList:AddTraderInfoToGuild(guildName, kiosk, week, isActive)
    local data = self.guildList[guildName] or {
        name = guildName,
        kiosks = {},
        history = {},
        lastKiosk = nil,
        lastVisitedWeek = 0,
        numKiosks = 0,
        hasActiveTrader = false
    }
    data.kiosks[kiosk] = true
    data.history[week] = kiosk
    data.numKiosks = data.numKiosks + 1
    if(isActive) then
        data.hasActiveTrader = true
    end
    if(data.lastVisitedWeek < week) then
        data.lastKiosk = kiosk
        data.lastVisitedWeek = week
    end
    self.guildList[guildName] = data
end

function OwnerList:Initialize(saveData)
    self.saveData = saveData
    local weekOrder = {}
    self.guildList = {}
    local currentWeek = self:GetCurrentWeek()
    for week, traders in pairs(saveData) do
        weekOrder[#weekOrder + 1] = week
        for kiosk, guildName in pairs(traders) do
            if(guildName ~= false) then
                self:AddTraderInfoToGuild(guildName, kiosk, week, currentWeek == week)
            end
        end
    end
    table.sort(weekOrder, SortDesc)
    self.weekOrder = weekOrder
end

function OwnerList:GetCurrentWeek()
    local currentYearAndWeek = LDT:GetTraderWeek()
    return currentYearAndWeek
end

function OwnerList:IsTimeInCurrentWeek(time)
    return LDT:IsInTraderWeek(LDT:New(time))
end

function OwnerList:GetStartAndEndForWeek(yearAndWeek)
    local currentYearAndWeek = LDT:GetTraderWeek()
    local yearA, weekA = LDT:SeparateIsoWeekAndYear(currentYearAndWeek)
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
        self:AddTraderInfoToGuild(guildName, kioskName, week, true)
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

function OwnerList:GetAllGuilds()
    return self.guildList
end

function OwnerList:GetGuildData(guildName)
    return self.guildList[guildName]
end