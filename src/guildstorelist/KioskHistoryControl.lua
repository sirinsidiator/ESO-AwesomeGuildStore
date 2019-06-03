local AGS = AwesomeGuildStore

local gettext = AGS.internal.gettext
local LDT = LibDateTime
local osdate = os.date

local HISTORY_DATA = 1
local HISTORY_ROW_HEIGHT = 30
local HISTORY_ROW_TEMPLATE = "AwesomeGuildStoreKioskHistoryRow"

local SORT_KEY_WEEK = "week"
local SORT_KEY_TRADER = "trader"
local SORT_KEY_LOCATION = "location"

local KioskHistoryControl = ZO_SortFilterList:Subclass()
AGS.class.KioskHistoryControl = KioskHistoryControl

function KioskHistoryControl:New(...)
    return ZO_SortFilterList.New(self, ...)
end

function KioskHistoryControl:Initialize(...)
    ZO_SortFilterList.Initialize(self, ...)
    self:InitializeList(...)
end

function KioskHistoryControl:InitializeList(control, storeList, kioskList, ownerList)
    self.storeList = storeList
    self.kioskList = kioskList
    self.ownerList = ownerList
    self.masterList = {}

    self:SetAlternateRowBackgrounds(true)
    self:SetEmptyText(gettext("No history data stored."))

    -- call it twice to set the sort order to down
    self.sortHeaderGroup:SelectHeaderByKey(SORT_KEY_WEEK, ZO_SortHeaderGroup.SUPPRESS_CALLBACKS)
    self.sortHeaderGroup:SelectHeaderByKey(SORT_KEY_WEEK)

    ZO_ScrollList_AddDataType(self.list, HISTORY_DATA, HISTORY_ROW_TEMPLATE, HISTORY_ROW_HEIGHT, function(control, data)
        self:SetupRow(control, data)

        local name = GetControl(control, "Week")
        name:SetText(data.week)

        local trader = GetControl(control, "Trader")
        trader:SetText(data.kioskName or "-")

        local location = GetControl(control, "Location")
        location:SetText(data.locationLabel or "-")
    end)
    ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")

    local function SortHistory(listEntry1, listEntry2)
        local sortKey = self.currentSortKey

        local startTime1 = listEntry1.data.startTime
        local startTime2 = listEntry2.data.startTime
        local value1, value2
        if(sortKey == SORT_KEY_WEEK) then
            value1 = startTime1
            value2 = startTime2
        elseif(sortKey == SORT_KEY_TRADER) then
            value1 = listEntry1.data.kioskName
            value2 = listEntry2.data.kioskName
            if(value1 == value2) then
                value1 = startTime1
                value2 = startTime2
            end
        elseif(sortKey == SORT_KEY_LOCATION) then
            value1 = listEntry1.data.locationLabel
            value2 = listEntry2.data.locationLabel
            if(value1 == value2) then
                value1 = startTime1
                value2 = startTime2
            end
        else
            return false
        end

        if(self.currentSortOrder == ZO_SORT_ORDER_DOWN) then
            return value1 > value2
        else
            return value1 < value2
        end
    end

    self.SortHistory = SortHistory
end

function KioskHistoryControl:SetSelectedGuild(guild)
    self.selectedGuild = guild
end

function KioskHistoryControl:BuildMasterList()
    ZO_ClearNumericallyIndexedTable(self.masterList)
    if(not self.selectedGuild) then return end

    local ownerList = self.ownerList
    local kioskList = self.kioskList
    local storeList = self.storeList
    local GetZoneLabel = AGS.internal.GetZoneLabel
    local GetPoiLabel = AGS.internal.GetPoiLabel

    local guild = self.selectedGuild
    local minWeek, maxWeek = 300099, 0
    local weekWithKiosk = {}
    for yearAndWeek, kioskName in pairs(guild.history) do
        minWeek = math.min(minWeek, yearAndWeek)
        maxWeek = math.max(maxWeek, yearAndWeek)
        weekWithKiosk[yearAndWeek] = true

        local startTime, endTime = ownerList:GetStartAndEndForWeek(yearAndWeek)
        local isoYear, isoWeek = LDT:SeparateIsoWeekAndYear(yearAndWeek)
        local startTimeString = osdate("%F %H:%M", startTime)
        local endTimeString = osdate("%F %H:%M", endTime)
        local kiosk = kioskList:GetKiosk(kioskName)
        local store = storeList:GetStore(kiosk.storeIndex)
        assert(store ~= nil, kiosk.storeIndex)
        local zoneName = GetZoneLabel(store)
        local poi = GetPoiLabel(store)
        self.masterList[#self.masterList + 1] = {
            type = HISTORY_DATA,
            startTime = startTime,
            endTime = endTime,
            week = string.format("%dW%02d", isoYear, isoWeek),
            durationAndTime = string.format("%s - %s", startTimeString, endTimeString),
            kioskName = kioskName,
            locationLabel = string.format("%s - %s", zoneName, poi),
        }
    end

    local startWeek, endWeek, _
    for yearAndWeek = minWeek, maxWeek do -- TODO: handle year changes *secondsInWeek?
        if(not weekWithKiosk[yearAndWeek]) then
            if(not startWeek) then
                startWeek = yearAndWeek
            end
            endWeek = yearAndWeek
        else
            if(startWeek) then
                local startTime, endTime = ownerList:GetStartAndEndForWeek(startWeek)
                if(startWeek ~= endWeek) then
                    _, endTime = ownerList:GetStartAndEndForWeek(endWeek)
                end
                local isoYear, isoWeek = LDT:SeparateIsoWeekAndYear(startWeek)
                local startTimeString = osdate("%F %H:%M", startTime)
                local endTimeString = osdate("%F %H:%M", endTime)
                self.masterList[#self.masterList + 1] = {
                    type = HISTORY_DATA,
                    startTime = startTime,
                    endTime = endTime,
                    week = string.format("%dW%02d%s", isoYear, isoWeek, (startWeek ~= endWeek and "+" or "")),
                    durationAndTime = string.format("%s - %s", startTimeString, endTimeString),
                    kioskName = "-",
                    locationLabel = "-",
                }
                startWeek = nil
                endWeek = nil
            end
        end
    end
end

function KioskHistoryControl:GetKioskCount()
    return #self.masterList
end

function KioskHistoryControl:FilterScrollList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ClearNumericallyIndexedTable(scrollData)
    for i = 1, #self.masterList do
        local data = self.masterList[i]
        table.insert(scrollData, ZO_ScrollList_CreateDataEntry(HISTORY_DATA, data))
    end
end

function KioskHistoryControl:SortScrollList()
    if(self.currentSortKey ~= nil and self.currentSortOrder ~= nil) then
        local scrollData = ZO_ScrollList_GetDataList(self.list)
        if(self.currentSortKey) then
            table.sort(scrollData, self.SortHistory)
        end
    end

    self:RefreshVisible()
end

function KioskHistoryControl:ColorRow(control, data, mouseIsOver)
    local color = ZO_SECOND_CONTRAST_TEXT

    local week = GetControl(control, "Week")
    week:SetColor(color:UnpackRGBA())

    local trader = GetControl(control, "Trader")
    trader:SetColor(color:UnpackRGBA())

    local location = GetControl(control, "Location")
    location:SetColor(color:UnpackRGBA())
end