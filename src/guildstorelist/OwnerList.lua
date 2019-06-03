local LDT = LibDateTime

local function SortDesc(a, b) return a > b end

local OwnerList = ZO_Object:Subclass()
AwesomeGuildStore.class.OwnerList = OwnerList

function OwnerList:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function OwnerList:AddTraderInfoToGuild(guildName, kiosk, week, isActive, guildId)
    local data
    if(guildId) then
        data = self.guildList[guildName] or self.guildList[guildId]
        self.guildList[guildName] = nil
    else
        data = self.guildList[guildName]
    end

    if(not data) then
        data = {
            id = guildId,
            name = guildName,
            kiosks = {},
            history = {},
            lastKiosk = nil,
            lastVisitedWeek = 0,
            numKiosks = 0,
            hasActiveTrader = false
        }
    end

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

    if(guildId) then
        self.guildList[guildId] = data
    else
        self.guildList[guildName] = data
    end
end

function OwnerList:Initialize(saveData, guildIdMapping)
    self.saveData = saveData
    self.guildIdMapping = guildIdMapping
    local weekOrder = {}
    self.guildList = {}
    local currentWeek = self:GetCurrentWeek()
    for week, traders in pairs(saveData) do
        weekOrder[#weekOrder + 1] = week
        for kiosk, guildNameOrId in pairs(traders) do
            if(guildNameOrId ~= false) then
                local guildId, guildName
                if(type(guildNameOrId) == "string") then
                    guildName = guildNameOrId
                    guildId = guildIdMapping:GetGuildId(guildNameOrId)
                    if(guildId) then
                        traders[kiosk] = guildId
                    end
                else
                    guildId = guildNameOrId
                    guildName = guildIdMapping:GetGuildName(guildId)
                end
                self:AddTraderInfoToGuild(guildName, kiosk, week, currentWeek == week, guildId)
            end
        end
    end
    table.sort(weekOrder, SortDesc)
    self.weekOrder = weekOrder
end

function OwnerList:GetCurrentWeek() -- TODO use LDT directly?
    local currentYearAndWeek = LDT:GetTraderWeek()
    return currentYearAndWeek
end

function OwnerList:IsTimeInCurrentWeek(time) -- TODO use LDT directly?
    return LDT:IsInTraderWeek(time)
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

function OwnerList:SetCurrentOwner(kioskName, guildName, guildId)
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
        if(guildId) then
            weekData[kioskName] = guildId
            self.guildIdMapping:UpdateMapping(guildId, guildName)
        else
            weekData[kioskName] = guildName
        end
        self:AddTraderInfoToGuild(guildName, kioskName, week, true, guildId)
    end
    self.saveData[week] = weekData
end

function OwnerList:ResolveOwner(owner)
    if(type(owner) == "number") then
        return self.guildIdMapping:GetGuildName(owner)
    end
    return owner
end

function OwnerList:GetCurrentOwner(kioskName)
    local week = self:GetCurrentWeek()
    local weekData = self:GetDataForWeek(week)
    return self:ResolveOwner(weekData[kioskName])
end

function OwnerList:GetLastKnownOwner(kioskName)
    for _, week in ipairs(self.weekOrder) do
        local weekData = self:GetDataForWeek(week)
        if(weekData[kioskName]) then
            return self:ResolveOwner(weekData[kioskName])
        end
    end
end

function OwnerList:GetOwnerHistory(kioskName)
    local history = {}
    for _, week in ipairs(self.weekOrder) do
        local weekData = self:GetDataForWeek(week)
        if(weekData[kioskName]) then
            history[week] = self:ResolveOwner(weekData[kioskName])
        end
    end
    return history
end

function OwnerList:GetAllGuilds()
    return self.guildList
end

function OwnerList:GetGuildData(guildNameOrId)
    return self.guildList[guildNameOrId]
end
