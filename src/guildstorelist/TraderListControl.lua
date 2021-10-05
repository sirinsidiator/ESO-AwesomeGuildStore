local AGS = AwesomeGuildStore

local gettext = AGS.internal.gettext

local TRADER_DATA = 1
local TRADER_ROW_HEIGHT = 30
local TRADER_ROW_TEMPLATE = "AwesomeGuildStoreTraderRow"
local REFRESH_FILTER_DELAY = 250
local NO_OWNER = { name = "-" }

local KIOSK_NOT_VISITED_COLOR = ZO_ColorDef:New("666666")
local KIOSK_OUTDATED_COLOR = ZO_ColorDef:New("BCA09A")
local KIOSK_UP_TO_DATE_COLOR = ZO_ColorDef:New("A4C19E")

local SORT_KEY_LAST_VISITED = "lastVisited"
local SORT_KEY_LOCATION = "location"
local SORT_KEY_TRADER_NAME = "traderName"
local SORT_KEY_OWNER = "owner"

local TIE_BREAKERS = {
    [SORT_KEY_LAST_VISITED] = {SORT_KEY_LOCATION, SORT_KEY_TRADER_NAME, SORT_KEY_OWNER},
    [SORT_KEY_LOCATION] = {SORT_KEY_LAST_VISITED, SORT_KEY_TRADER_NAME, SORT_KEY_OWNER},
    [SORT_KEY_TRADER_NAME] = {SORT_KEY_LOCATION, SORT_KEY_LAST_VISITED, SORT_KEY_OWNER},
    [SORT_KEY_OWNER] = {SORT_KEY_LOCATION, SORT_KEY_LAST_VISITED, SORT_KEY_TRADER_NAME},
}

local SORT_ORDER_DOWN = {
    [SORT_KEY_LAST_VISITED] = ZO_SORT_ORDER_UP, -- inverted because we store timestamps but show time ago
    [SORT_KEY_LOCATION] = ZO_SORT_ORDER_DOWN,
    [SORT_KEY_TRADER_NAME] = ZO_SORT_ORDER_DOWN,
    [SORT_KEY_OWNER] = ZO_SORT_ORDER_DOWN,
}

local GET_SORT_VALUES = {
    [SORT_KEY_LAST_VISITED] = function(a, b) return a.data[SORT_KEY_LAST_VISITED], b.data[SORT_KEY_LAST_VISITED] end,
    [SORT_KEY_LOCATION] = function(a, b) return a.data[SORT_KEY_LOCATION], b.data[SORT_KEY_LOCATION] end,
    [SORT_KEY_TRADER_NAME] = function(a, b) return a.data[SORT_KEY_TRADER_NAME], b.data[SORT_KEY_TRADER_NAME] end,
    [SORT_KEY_OWNER] = function(a, b) return a.data[SORT_KEY_OWNER].name, b.data[SORT_KEY_OWNER].name end,
}

local LTF = LibTextFilter

local function GetLastVisitLabel(lastVisited)
    if(lastVisited) then
        local diff = GetDiffBetweenTimeStamps(GetTimeStamp(), lastVisited)
        return ZO_FormatDurationAgo(diff)
    else
        return "-"
    end
end
AGS.internal.GetLastVisitLabel = GetLastVisitLabel

local function GetZoneLabel(store)
    local zoneId = store.zoneId
    if zoneId == 1283 then
        -- Fargrave is a bit of a pain, since it contains 2 subzones on the main map and we actually get the less desired one from GetCurrentMapParentZoneIndices
        zoneId = 1282
    end
    local zoneIndex = GetZoneIndex(zoneId)
    return zo_strformat("<<1>>", GetZoneNameByIndex(zoneIndex))
end
AGS.internal.GetZoneLabel = GetZoneLabel

local function GetPoiLabel(store)
    local location = store.mapName
    if(store.onZoneMap) then
        local zoneIndex = GetZoneIndex(store.zoneId)
        location = GetPOIInfo(zoneIndex, store.wayshrineIndex)
    end
    return zo_strformat("<<t:1>>", location)
end
AGS.internal.GetPoiLabel = GetPoiLabel

local function GetLastVisited(kiosk)
    if(not kiosk) then
        return
    elseif(kiosk.isMember) then
        return kiosk.lastVisited * 10, kiosk.lastVisited -- small hack to get the entry to the top when sorting by time
    elseif(kiosk.lastVisited and kiosk.lastVisited > 0) then
        return kiosk.lastVisited
    end
end
AGS.internal.GetLastVisited = GetLastVisited

local TraderListControl = ZO_SortFilterList:Subclass()
AGS.class.TraderListControl = TraderListControl

function TraderListControl:New(...)
    return ZO_SortFilterList.New(self, ...)
end

function TraderListControl:Initialize(...)
    ZO_SortFilterList.Initialize(self, ...)
    self:InitializeList(...)
end

function TraderListControl:UpdateEmptyText()
    local emptyText
    if(self.storeList:IsEmpty()) then
        -- TRANSLATORS: placeholder text when the list on the guild kiosk tab is not yet initialized
        emptyText = gettext("Trader database is not initialized yet.")
    else
        -- TRANSLATORS: placeholder text when no entry on the list on the guild kiosk tab matches the text filter
        emptyText = gettext("No results match your filter text.")
    end

    if(not self.emptyRow) then
        self:SetEmptyText(emptyText)
    else
        GetControl(self.emptyRow, "Message"):SetText(emptyText)
    end
end

function TraderListControl:InitializeList(control, storeList, kioskList, ownerList)
    self.storeList = storeList
    self.kioskList = kioskList
    self.ownerList = ownerList
    self.masterList = {}

    self:SetAlternateRowBackgrounds(true)
    self:UpdateEmptyText()
    self.sortHeaderGroup:SelectHeaderByKey(SORT_KEY_LAST_VISITED)

    ZO_ScrollList_AddDataType(self.list, TRADER_DATA, TRADER_ROW_TEMPLATE, TRADER_ROW_HEIGHT, function(control, data)
        self:SetupRow(control, data)

        local name = GetControl(control, "TraderName")
        name:SetText(data.traderName)

        local location = GetControl(control, "Location")
        location:SetText(data.location)

        local owner = GetControl(control, "Owner")
        if(not data.isHired or not data.owner) then
            owner:SetText("-")
        else
            owner:SetText(data.owner.name)
        end

        local lastVisited = GetControl(control, "LastVisited")
        local lastVisitedLabel = GetLastVisitLabel(data.lastVisited)
        if(data.isMember) then
            -- TRANSLATORS: label for the last visited field of a joined guild on the guild kiosk tab
            lastVisitedLabel = gettext("joined")
        end
        lastVisited:SetText(lastVisitedLabel)
    end)
    ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")

    local function SortTraders(listEntry1, listEntry2, t)
        local sortKey = self.currentSortKey

        if(t) then
            sortKey = TIE_BREAKERS[sortKey][t]
            if(not sortKey) then return false end
            t = t + 1
        else
            t = 1
        end

        local value1, value2 = GET_SORT_VALUES[sortKey](listEntry1, listEntry2)
        if(value1 == value2 and type(value1) == type(value2)) then
            return SortTraders(listEntry1, listEntry2, t)
        elseif(self.currentSortOrder == SORT_ORDER_DOWN[sortKey]) then
            if(not value1) then return false end
            if(not value2) then return true end
            return value1 > value2
        else
            if(not value1) then return false end
            if(not value2) then return true end
            return value1 < value2
        end
    end

    self.SortTraders = SortTraders

    local utils = control:GetNamedChild("Utils")

    -- TRANSLATORS: label for the search box on the guild kiosk tab
    utils:GetNamedChild("SearchLabel"):SetText(gettext("Filter By:"))
    self.searchBox = utils:GetNamedChild("SearchBox")
    self.searchBox:SetHandler("OnTextChanged", function() self:OnSearchTextChanged() end)

    self.upToDateCount = 0
    self.visitedCount = 0
    self.overallCount = 0
    self.storeCount = 0

    self.upToDateValue = utils:GetNamedChild("UpToDateValue")
    self.visitedValue = utils:GetNamedChild("VisitedValue")
    self.overallValue = utils:GetNamedChild("OverallValue")

    -- TRANSLATORS: label on the guild kiosk tab showing how many kiosks the player has visited in the current trading week
    utils:GetNamedChild("UpToDateLabel"):SetText(gettext("Current:"))
    self.upToDateValue:SetText("-")
    -- TRANSLATORS: label on the guild kiosk tab showing how many kiosks the player has visited at all times
    utils:GetNamedChild("VisitedLabel"):SetText(gettext("Visited:"))
    self.visitedValue:SetText("-")
    -- TRANSLATORS: label on the guild kiosk tab showing how many kiosks there are in the game
    utils:GetNamedChild("OverallLabel"):SetText(gettext("Overall:"))
    self.overallValue:SetText("-")
end

function TraderListControl:OnSearchTextChanged()
    ZO_EditDefaultText_OnTextChanged(self.searchBox)

    if(self.refreshFilterHandle) then
        EVENT_MANAGER:UnregisterForUpdate("CallLaterFunction" .. self.refreshFilterHandle)
    end

    self.refreshFilterHandle = zo_callLater(function()
        self:RefreshFilters()
    end, REFRESH_FILTER_DELAY)
end

function TraderListControl:BuildMasterList()
    local storeList, kioskList, ownerList = self.storeList, self.kioskList, self.ownerList
    ZO_ClearNumericallyIndexedTable(self.masterList)
    self:UpdateEmptyText()

    local upToDateCount = 0
    local visitedCount = 0
    local overallCount = 0
    local storeCount = 0

    local haystack = {}
    for storeIndex, store in pairs(storeList:GetAllStores()) do
        storeCount = storeCount + 1
        for _, traderName in ipairs(store.kiosks) do
            overallCount = overallCount + 1

            local kiosk = kioskList:GetKiosk(traderName)
            local lastVisited, realLastVisited = GetLastVisited(kiosk)
            local hasVisitedThisWeek = false

            if(lastVisited) then
                hasVisitedThisWeek = ownerList:IsTimeInCurrentWeek(lastVisited)
            end

            if(kiosk and kiosk.lastVisited and kiosk.lastVisited > 0) then
                visitedCount = visitedCount + 1
                if(hasVisitedThisWeek or kiosk.isMember) then
                    upToDateCount = upToDateCount + 1
                end
            end

            local zoneName = GetZoneLabel(store)
            local poi = GetPoiLabel(store)
            local owner = ownerList:GetLastKnownOwner(traderName)
            local isHired = true
            if(hasVisitedThisWeek and ownerList:GetCurrentOwner(traderName) == false) then
                isHired = false
            end
            haystack[1] = traderName
            haystack[2] = zoneName
            haystack[3] = poi
            if(owner) then haystack[4] = owner.name end
            self.masterList[#self.masterList + 1] = {
                type = TRADER_DATA,
                traderName = traderName,
                location = string.format("%s - %s", zoneName, poi),
                zone = zoneName,
                poi = poi,
                owner = owner or NO_OWNER,
                storeIndex = store.index,
                lastVisited = lastVisited,
                hasVisitedThisWeek = hasVisitedThisWeek,
                isHired = isHired,
                realLastVisited = realLastVisited,
                isMember = kiosk and kiosk.isMember,
                haystack = table.concat(haystack, " "):lower(),
            }
        end
    end

    self.upToDateCount = upToDateCount
    self.visitedCount = visitedCount
    self.overallCount = overallCount
    self.storeCount = storeCount
    self:UpdateCounters()
end

function TraderListControl:UpdateCounters()
    self.upToDateValue:SetText(self.upToDateCount)
    self.visitedValue:SetText(self.visitedCount)
    self.overallValue:SetText(self.overallCount)
end

function TraderListControl:GenerateFilterFunction()
    local searchTerm = self.searchBox:GetText()
    if(searchTerm ~= "") then
        searchTerm = searchTerm:lower()
        local tokens = LTF:Tokenize(searchTerm)
        local parsedTokens = LTF:Parse(tokens)
        return function(data)
            local isMatch, result = LTF:Evaluate(data.haystack, ZO_ShallowTableCopy(parsedTokens))
            return isMatch
        end
    end
    return function() return true end
end

function TraderListControl:FilterScrollList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ClearNumericallyIndexedTable(scrollData)

    local IsMatch = self:GenerateFilterFunction()

    for i = 1, #self.masterList do
        local data = self.masterList[i]
        if(IsMatch(data)) then
            table.insert(scrollData, ZO_ScrollList_CreateDataEntry(TRADER_DATA, data))
        end
    end
end

function TraderListControl:GetFirstKioskEntryInList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    if(#scrollData > 0) then
        return ZO_ScrollList_GetDataEntryData(scrollData[1])
    end
end

function TraderListControl:GetKioskEntryInList(kioskName)
    for i = 1, #self.masterList do
        local data = self.masterList[i]
        if(data.traderName == kioskName) then
            return data
        end
    end
end

function TraderListControl:SortScrollList()
    if(self.currentSortKey ~= nil and self.currentSortOrder ~= nil) then
        local scrollData = ZO_ScrollList_GetDataList(self.list)
        if(self.currentSortKey) then
            table.sort(scrollData, self.SortTraders)
        end
    end

    self:RefreshVisible()
end

function TraderListControl:ColorRow(control, data, mouseIsOver)
    local color = KIOSK_OUTDATED_COLOR
    if(not data.isMember and not data.lastVisited) then
        color = KIOSK_NOT_VISITED_COLOR
    elseif(data.isMember or data.hasVisitedThisWeek) then
        color = KIOSK_UP_TO_DATE_COLOR
    end

    local name = GetControl(control, "TraderName")
    name:SetColor(color:UnpackRGBA())

    local location = GetControl(control, "Location")
    location:SetColor(color:UnpackRGBA())

    local owner = GetControl(control, "Owner")
    owner:SetColor(color:UnpackRGBA())

    local lastVisited = GetControl(control, "LastVisited")
    lastVisited:SetColor(color:UnpackRGBA())
end
