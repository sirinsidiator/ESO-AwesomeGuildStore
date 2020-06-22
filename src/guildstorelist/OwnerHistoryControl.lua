local AGS = AwesomeGuildStore

local gettext = AGS.internal.gettext
local LDT = LibDateTime
local osdate = os.date

local HISTORY_DATA = 1
local HISTORY_ROW_HEIGHT = 30
local HISTORY_ROW_TEMPLATE = "AwesomeGuildStoreTraderHistoryRow"

local SORT_KEY_WEEK = "week"
local SORT_KEY_OWNER = "owner"

local OwnerHistoryControl = ZO_SortFilterList:Subclass()
AGS.class.OwnerHistoryControl = OwnerHistoryControl

function OwnerHistoryControl:New(...)
    return ZO_SortFilterList.New(self, ...)
end

function OwnerHistoryControl:Initialize(...)
    ZO_SortFilterList.Initialize(self, ...)
    self:InitializeList(...)
end

function OwnerHistoryControl:InitializeList(control, storeList, kioskList, ownerList)
    self.storeList = storeList
    self.kioskList = kioskList
    self.ownerList = ownerList
    self.masterList = {}

    self:SetAlternateRowBackgrounds(true)
    -- TRANSLATORS: placeholder text when the history list of an entry on the guild kiosk tab is empty
    self:SetEmptyText(gettext("No history data stored."))

    -- call it twice to set the sort order to down
    self.sortHeaderGroup:SelectHeaderByKey(SORT_KEY_WEEK, ZO_SortHeaderGroup.SUPPRESS_CALLBACKS)
    self.sortHeaderGroup:SelectHeaderByKey(SORT_KEY_WEEK)

    ZO_ScrollList_AddDataType(self.list, HISTORY_DATA, HISTORY_ROW_TEMPLATE, HISTORY_ROW_HEIGHT, function(control, data)
        self:SetupRow(control, data)

        local name = GetControl(control, "Week")
        name:SetText(data.week)

        local owner = GetControl(control, "Owner")
        owner:SetText(data.owner.name or "-")
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
        elseif(sortKey == SORT_KEY_OWNER) then
            value1 = listEntry1.data.owner.name
            value2 = listEntry2.data.owner.name
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

function OwnerHistoryControl:SetSelectedKiosk(kioskName)
    self.selectedKioskName = kioskName
end

function OwnerHistoryControl:BuildMasterList()
    ZO_ClearNumericallyIndexedTable(self.masterList)
    if(not self.selectedKioskName) then return end

    local ownerList = self.ownerList
    local kioskName = self.selectedKioskName

    local history = ownerList:GetOwnerHistory(kioskName)
    for yearAndWeek, owner in pairs(history) do
        local startTime, endTime = ownerList:GetStartAndEndForWeek(yearAndWeek)
        local isoYear, isoWeek = LDT:SeparateIsoWeekAndYear(yearAndWeek)
        local startTimeString = osdate("%F %H:%M", startTime)
        local endTimeString = osdate("%F %H:%M", endTime)
        self.masterList[#self.masterList + 1] = {
            type = HISTORY_DATA,
            startTime = startTime,
            endTime = endTime,
            week = string.format("%dW%02d", isoYear, isoWeek),
            durationAndTime = string.format("%s - %s", startTimeString, endTimeString),
            owner = owner,
        }
    end
end

function OwnerHistoryControl:FilterScrollList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ClearNumericallyIndexedTable(scrollData)
    for i = 1, #self.masterList do
        local data = self.masterList[i]
        table.insert(scrollData, ZO_ScrollList_CreateDataEntry(HISTORY_DATA, data))
    end
end

function OwnerHistoryControl:SortScrollList()
    if(self.currentSortKey ~= nil and self.currentSortOrder ~= nil) then
        local scrollData = ZO_ScrollList_GetDataList(self.list)
        if(self.currentSortKey) then
            table.sort(scrollData, self.SortHistory)
        end
    end

    self:RefreshVisible()
end

function OwnerHistoryControl:ColorRow(control, data, mouseIsOver)
    local color = ZO_SECOND_CONTRAST_TEXT

    local week = GetControl(control, "Week")
    week:SetColor(color:UnpackRGBA())

    local owner = GetControl(control, "Owner")
    owner:SetColor(color:UnpackRGBA())
end