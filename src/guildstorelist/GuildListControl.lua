local AGS = AwesomeGuildStore

local gettext = AGS.internal.gettext

local TRADER_DATA = 1
local TRADER_ROW_HEIGHT = 30
local TRADER_ROW_TEMPLATE = "AwesomeGuildStoreGuildRow"
local REFRESH_FILTER_DELAY = 250

local KIOSK_NOT_VISITED_COLOR = ZO_ColorDef:New("666666")
local KIOSK_OUTDATED_COLOR = ZO_ColorDef:New("BCA09A")
local KIOSK_UP_TO_DATE_COLOR = ZO_ColorDef:New("A4C19E")

local SORT_KEY_GUILD = "guildName"
local SORT_KEY_KIOSK_COUNT = "kioskCount"
local SORT_KEY_KIOSK_COUNT_INV = "kioskCountInv" -- used for the tiebreaker
local SORT_KEY_LAST_ACTIVE = "lastActive"

local TIE_BREAKERS = {
    [SORT_KEY_GUILD] = {SORT_KEY_LAST_ACTIVE, SORT_KEY_KIOSK_COUNT_INV},
    [SORT_KEY_KIOSK_COUNT] = {SORT_KEY_LAST_ACTIVE, SORT_KEY_GUILD},
    [SORT_KEY_LAST_ACTIVE] = {SORT_KEY_KIOSK_COUNT_INV, SORT_KEY_GUILD},
}

local SORT_ORDER_DOWN = {
    [SORT_KEY_GUILD] = ZO_SORT_ORDER_DOWN,
    [SORT_KEY_KIOSK_COUNT] = ZO_SORT_ORDER_DOWN,
    [SORT_KEY_KIOSK_COUNT_INV] = ZO_SORT_ORDER_UP,
    [SORT_KEY_LAST_ACTIVE] = ZO_SORT_ORDER_DOWN,
}

local LTF = LibTextFilter
local LDT = LibDateTime

local GuildListControl = ZO_SortFilterList:Subclass()
AGS.class.GuildListControl = GuildListControl

function GuildListControl:New(...)
    return ZO_SortFilterList.New(self, ...)
end

function GuildListControl:Initialize(...)
    ZO_SortFilterList.Initialize(self, ...)
    self:InitializeList(...)
end

function GuildListControl:UpdateEmptyText()
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

function GuildListControl:InitializeList(control, storeList, kioskList, ownerList)
    self.storeList = storeList
    self.kioskList = kioskList
    self.ownerList = ownerList
    self.masterList = {}

    self:SetAlternateRowBackgrounds(true)
    self:UpdateEmptyText()
    self.sortHeaderGroup:SelectHeaderByKey(SORT_KEY_LAST_ACTIVE)

    ZO_ScrollList_AddDataType(self.list, TRADER_DATA, TRADER_ROW_TEMPLATE, TRADER_ROW_HEIGHT, function(control, data)
        self:SetupRow(control, data)

        local name = GetControl(control, "GuildName")
        name:SetText(data.guild.name)
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

        local value1, value2 = listEntry1.data[sortKey], listEntry2.data[sortKey]
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

function GuildListControl:OnSearchTextChanged()
    ZO_EditDefaultText_OnTextChanged(self.searchBox)

    if(self.refreshFilterHandle) then
        EVENT_MANAGER:UnregisterForUpdate("CallLaterFunction" .. self.refreshFilterHandle)
    end

    self.refreshFilterHandle = zo_callLater(function()
        self:RefreshFilters()
    end, REFRESH_FILTER_DELAY)
end

function GuildListControl:BuildMasterList()
    local storeList, kioskList, ownerList = self.storeList, self.kioskList, self.ownerList
    ZO_ClearNumericallyIndexedTable(self.masterList)
    self:UpdateEmptyText()

    local yearB, weekB = LDT:CalculateIsoWeekAndYear()

    local upToDateCount = 0
    local visitedCount = 0
    local overallCount = 0

    local haystack = {}
    local length = 0
    for _, guild in pairs(ownerList:GetAllGuilds()) do
        overallCount = overallCount + 1

        haystack[1] = guild.name
        length = 1
        for kiosk in pairs(guild.kiosks) do
            length = length + 1
            haystack[length] = kiosk
        end

        local yearA, weekA = LDT:SeparateIsoWeekAndYear(guild.lastVisitedWeek)
        local diff = LDT:CalculateIsoWeekDifference(yearA, weekA, yearB, weekB)

        self.masterList[#self.masterList + 1] = {
            type = TRADER_DATA,
            guild = guild,
            guildId = guild.id,
            guildName = guild.name,
            kioskCount = guild.numKiosks,
            kioskCountInv = guild.numKiosks,
            lastActive = diff,
            haystack = table.concat(haystack, " ", 1, length):lower(),
        }

        if(diff == 0) then
            upToDateCount = upToDateCount + 1
        end
        if(guild.numKiosks > 0) then
            visitedCount = visitedCount + 1
        end
    end

    self.upToDateCount = upToDateCount
    self.visitedCount = visitedCount
    self.overallCount = overallCount
    self:UpdateCounters()
end

function GuildListControl:UpdateCounters()
    self.upToDateValue:SetText(self.upToDateCount)
    self.visitedValue:SetText(self.visitedCount)
    self.overallValue:SetText(self.overallCount)
end

function GuildListControl:GenerateFilterFunction()
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

function GuildListControl:FilterScrollList()
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

function GuildListControl:GetFirstGuildEntryInList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    if(#scrollData > 0) then
        return ZO_ScrollList_GetDataEntryData(scrollData[1])
    end
end

function GuildListControl:GetGuildEntryInList(guild)
    for i = 1, #self.masterList do
        local data = self.masterList[i]
        if(data.guild == guild) then
            return data
        end
    end
end

function GuildListControl:SortScrollList()
    if(self.currentSortKey ~= nil and self.currentSortOrder ~= nil) then
        local scrollData = ZO_ScrollList_GetDataList(self.list)
        if(self.currentSortKey) then
            table.sort(scrollData, self.SortTraders)
        end
    end

    self:RefreshVisible()
end

function GuildListControl:ColorRow(control, data, mouseIsOver)
    local color = KIOSK_NOT_VISITED_COLOR
    if(data.guild.hasActiveTrader) then
        color = KIOSK_UP_TO_DATE_COLOR
    elseif(data.guild.numKiosks > 0) then
        color = KIOSK_OUTDATED_COLOR
    end

    local name = GetControl(control, "GuildName")
    name:SetColor(color:UnpackRGBA())
end
