local AGS = AwesomeGuildStore

local IsAtGuildKiosk = AGS.internal.IsAtGuildKiosk
local GetUnitGuildKioskOwnerInfo = AGS.internal.GetUnitGuildKioskOwnerInfo
local IsLocationVisible = AGS.internal.IsLocationVisible
local IsCurrentMapZoneMap = AGS.internal.IsCurrentMapZoneMap
local GetKioskNameFromInfoText = AGS.internal.GetKioskNameFromInfoText
local RegisterForEvent = AGS.internal.RegisterForEvent
local ShowGuildDetails = AGS.internal.ShowGuildDetails
local Print = AGS.internal.Print
local gettext = AGS.internal.gettext
local osdate = os.date

local KIOSK_ICON = "/esoui/art/icons/servicemappins/servicepin_guildkiosk.dds"
local VENDOR_ICON = "/esoui/art/icons/servicemappins/servicepin_vendor.dds"
local FENCE_ICON = "/esoui/art/icons/servicemappins/servicepin_fence.dds"
local THIEVES_GUILD_ICON = "/esoui/art/icons/servicemappins/servicepin_thievesguild.dds" -- already shows the guild trader in tooltip
local KIOSK_TOOLTIP_ICON = "/esoui/art/icons/servicetooltipicons/servicetooltipicon_guildkiosk.dds"

local PLAYER_UNIT_TAG = "player"
local INTERACT_UNIT_TAG = "interact"
local TARGET_UNIT_TAG = "reticleover"
local UPDATE_NAMESPACE = "AwesomeGuildStoreStoreLocationUpdate"
local UPDATE_INTERVAL = 0 -- we want to do it as fast as possible without producing a freeze
local REFRESH_HANDLE = "AwesomeGuildStoreTraderListRefresh"
local REFRESH_INTERVAL = 15000

local libGPS = LibStub("LibGPS2")
local LMP = LibStub("LibMapPing")

local menu = MAIN_MENU_KEYBOARD
local category = MENU_CATEGORY_GUILDS
local categoryInfo = menu.categoryInfo[category]
local sceneGroupName =  "guildsSceneGroup"
local sceneName = "AGS_guildTraders"

local function InjectGuildMenuTab(sceneName, categoryName, iconPathTemplate)
    local contactsSceneGroup = SCENE_MANAGER:GetSceneGroup(sceneGroupName)
    contactsSceneGroup:AddScene(sceneName)

    local iconData = {
        categoryName = categoryName,
        descriptor = sceneName,
        normal = iconPathTemplate:format("up"),
        pressed = iconPathTemplate:format("down"),
        highlight = iconPathTemplate:format("over"),
    }

    local scene = menu:AddRawScene(sceneName, category, categoryInfo, sceneGroupName)
    local sceneGroupBarFragment = ZO_FadeSceneFragment:New(menu.sceneGroupBar, nil, 0)
    scene:AddFragment(sceneGroupBarFragment)

    local menuBarIconData = menu.sceneGroupInfo[sceneGroupName].menuBarIconData
    menuBarIconData[#menuBarIconData + 1] = iconData
end

local function IsStoreLocation(locationIndex)
    for tooltipLineIndex = 1, GetNumMapLocationTooltipLines(locationIndex) do
        if(IsMapLocationTooltipLineVisible(locationIndex, tooltipLineIndex)) then
            local tooltipIcon, traderName = GetMapLocationTooltipLineInfo(locationIndex, tooltipLineIndex)
            if(tooltipIcon == KIOSK_TOOLTIP_ICON) then
                return true
            end
        end
    end
    return false
end

local function FindNearestStoreLocation(x, y)
    local dmin = 1
    local index = 0
    for locationIndex = 1, GetNumMapLocations() do
        local icon, x_, y_ = GetMapLocationIcon(locationIndex)
        if(IsLocationVisible(locationIndex) and IsStoreLocation(locationIndex)) then
            local dx = x - x_
            local dy = y - y_
            local ds = dx * dx + dy * dy
            if(ds < dmin) then
                dmin = ds
                index = locationIndex
            end
        end
    end
    return index
end

local function BuildStoreIndex(mapName, locationIndex)
    mapName = mapName:match("(.-)^.-") or mapName
    return string.format("%s.%d", mapName, locationIndex)
end

local function GetUnitStoreIndex(unitTag)
    local x, y = GetMapPlayerPosition(unitTag)
    local locationIndex = FindNearestStoreLocation(x, y)
    local mapName = GetMapName()
    return BuildStoreIndex(mapName, locationIndex)
end

local IRREGULAR_TOOLTIP_HEADER = { -- TODO exceptions in other languages
    -- English
    ["Orsinium Outlaw Refuge"] = "Orsinium Outlaws Refuge",
    -- French
    ["refuge des hors-la-loi d'Orsinium"] = "refuge de hors-la-loi d'Orsinium",
    -- German
    ["Knurr'Kha-Unterschlupf"] = "Knurr'kha-Unterschlupf",
    ["Sturmfeste-Unterschlupf"] = "Sturmfeste-Unterschlupft",
    -- Japanese
    ["オルシニウム無法者の隠れ家"] = "オルシニウムの無法者の隠れ家",
    -- already fixed, but we keep them to correct the save data
    ["Vivec Outlaws Refuge"] = "Vivec City Outlaws Refuge",
}

local function UpdateStoreNames(saveData, oldName, newName)
    if(saveData.stores[oldName] and not saveData.stores[newName]) then
        saveData.stores[newName] = saveData.stores[oldName]:gsub(oldName, newName)
    end
    saveData.stores[oldName] = nil

    for traderName in pairs(saveData.kiosks) do
        saveData.kiosks[traderName] = saveData.kiosks[traderName]:gsub(oldName, newName)
    end
end

local function UpdateSaveData(saveData)
    if(saveData.version == 1) then
        saveData.stores = AGS.class.StoreList.UpdateStoreIds(saveData.stores)
        saveData.kiosks = AGS.class.KioskList.UpdateStoreIds(saveData.kiosks)
        saveData.version = 2
    end
    if(saveData.version < 5) then
        for oldName, newName in pairs(IRREGULAR_TOOLTIP_HEADER) do
            UpdateStoreNames(saveData, oldName, newName)
        end
        saveData.version = 5
    end
end

local function InitializeSaveData(saveData)
    if(not saveData.guildStoreList) then
        saveData.guildStoreList = {
            version = 3,
            owners = {},
            stores = {},
            kiosks = {},
        }
    else
        UpdateSaveData(saveData.guildStoreList)
    end
    return saveData.guildStoreList
end

local function FindNearestWayshrine(zoneIndex, x, y)
    local dmin = 1
    local index = 0
    for targetIndex = 1, GetNumPOIs(zoneIndex) do
        if IsPOIWayshrine(zoneIndex, targetIndex) then
            local x_, y_ = libGPS:LocalToGlobal(GetPOIMapInfo(zoneIndex, targetIndex))
            local dx = x - x_
            local dy = y - y_
            local ds = dx * dx + dy * dy
            if(ds < dmin) then
                dmin = ds
                index = targetIndex
            end
        end
    end
    return index, dmin
end

local function FindNearestWayshrineForEntrances(zoneIndex, entranceCoordinates)
    local dmin = 1
    local index = 0
    local entranceIndex = 0
    for i = 1, #entranceCoordinates do
        local x, y, locationIndex = unpack(entranceCoordinates[i])
        local targetIndex, ds = FindNearestWayshrine(zoneIndex, x, y)
        if(ds < dmin) then
            dmin = ds
            index = targetIndex
            entranceIndex = locationIndex
        end
    end
    return index, entranceIndex, dmin
end

local function GetKioskNamesFromLocationTooltip(locationIndex)
    local kiosks = {}
    for tooltipLineIndex = 1, GetNumMapLocationTooltipLines(locationIndex) do
        if(IsMapLocationTooltipLineVisible(locationIndex, tooltipLineIndex)) then
            local tooltipIcon, kioskName = GetMapLocationTooltipLineInfo(locationIndex, tooltipLineIndex)
            if(tooltipIcon == KIOSK_TOOLTIP_ICON) then
                kiosks[#kiosks + 1] = kioskName
            end
        end
    end
    return kiosks
end

local function InitializeStoreListWindow(saveData, kioskList, storeList, ownerList)
    local window = AwesomeGuildStoreGuildTraders

    local GetLastVisitLabel = AGS.internal.GetLastVisitLabel
    local guildTradersFragment = ZO_FadeSceneFragment:New(window, nil, 0)
    local guildTradersScene = ZO_Scene:New(sceneName, SCENE_MANAGER)
    -- we use the title fragment for the separator line and show the actual title via the guild scene tab system
    -- in order to prevent titles from other scenes to show up, we clear it with an empty string
    local emptyTitleFragment = ZO_SetTitleFragment:New("")

    guildTradersScene:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
    guildTradersScene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
    guildTradersScene:AddFragmentGroup(FRAGMENT_GROUP.PLAYER_PROGRESS_BAR_KEYBOARD_CURRENT)
    guildTradersScene:AddFragment(guildTradersFragment)
    guildTradersScene:AddFragment(TITLE_FRAGMENT)
    guildTradersScene:AddFragment(emptyTitleFragment)
    guildTradersScene:AddFragment(RIGHT_BG_FRAGMENT)
    guildTradersScene:AddFragment(FRAME_EMOTE_FRAGMENT_SOCIAL)

    InjectGuildMenuTab(sceneName, SI_GUILD_TRADER_OWNERSHIP_HEADER, "EsoUI/Art/Guild/guildHistory_indexIcon_guildStore_%s.dds")
    --    "\esoui\art\guild\guildhistory_indexicon_combat_up.dds"

    local headers = window:GetNamedChild("Headers")
    -- TRANSLATORS: sort header label for the list on the guild kiosk tab
    ZO_SortHeader_Initialize(headers:GetNamedChild("TraderName"), gettext("Trader"), "traderName", ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontGameLargeBold")
    -- TRANSLATORS: sort header label for the list on the guild kiosk tab
    ZO_SortHeader_Initialize(headers:GetNamedChild("Location"), gettext("Location"), "location", ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontGameLargeBold")
    -- TRANSLATORS: sort header label for the list on the guild kiosk tab
    ZO_SortHeader_Initialize(headers:GetNamedChild("Owner"), gettext("Guild"), "owner", ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontGameLargeBold")
    -- TRANSLATORS: sort header label for the list on the guild kiosk tab
    ZO_SortHeader_Initialize(headers:GetNamedChild("LastVisited"), gettext("Last Visited"), "lastVisited", ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontGameLargeBold")

    local traderList = AGS.class.TraderListControl:New(window, storeList, kioskList, ownerList)
    window.traderList = traderList

    local r, g, b = ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB()
    local function AddHeaderLines(tooltip, lines, alignment)
        for i = 1, #lines do
            tooltip:AddHeaderLine(lines[i], "ZoFontWinH5", i, alignment, r, g, b)
        end
    end

    local details = window:GetNamedChild("Details")
    local detailTraderName = details:GetNamedChild("TraderName")
    details:GetNamedChild("LastVisitedLabel"):SetText(gettext("Last Visited") .. ":")
    local detailLastVisited = details:GetNamedChild("LastVisitedValue")
    -- TRANSLATORS: label for the detail view on the guild kiosk tab
    details:GetNamedChild("ZoneLabel"):SetText(gettext("Zone") .. ":")
    local detailZone = details:GetNamedChild("ZoneValue")
    details:GetNamedChild("LocationLabel"):SetText(gettext("Location") .. ":")
    local detailLocation = details:GetNamedChild("LocationValue")
    details:GetNamedChild("OwnerLabel"):SetText(gettext("Guild") .. ":")
    local detailOwner = details:GetNamedChild("OwnerValue")
    details:GetNamedChild("HistoryLabel"):SetText(gettext("History") .. ":")
    local detailOwnerHistory = details:GetNamedChild("History")

    local historyHeaders = detailOwnerHistory:GetNamedChild("Headers")
    -- TRANSLATORS: sort header label for the history list on the guild kiosk tab
    ZO_SortHeader_Initialize(historyHeaders:GetNamedChild("Week"), gettext("Week"), "week", ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontGameLargeBold")
    ZO_SortHeader_Initialize(historyHeaders:GetNamedChild("Owner"), gettext("Guild"), "owner", ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontGameLargeBold")

    local historyList = AGS.class.OwnerHistoryControl:New(detailOwnerHistory, storeList, kioskList, ownerList)
    window.historyList = historyList

    local selectedTraderData, keybindStripDescriptor
    local function SetSelectedDetails(data)
        selectedTraderData = data
        KEYBIND_STRIP:UpdateKeybindButtonGroup(keybindStripDescriptor)
        detailTraderName:SetText(data.traderName)
        detailLastVisited:SetText(GetLastVisitLabel(data.realLastVisited or data.lastVisited))
        detailZone:SetText(data.zone)
        detailLocation:SetText(data.poi)
        if(not data.isHired or not data.owner) then
            detailOwner:SetText("-")
        else
            detailOwner:SetText(data.owner.name)
        end
        historyList:SetSelectedKiosk(data.traderName)
        historyList:RefreshData()
    end

    local function GetExactLastVisitLabel(lastVisited)
        if(lastVisited) then
            return osdate("%F %H:%M", lastVisited)
        else
            -- TRANSLATORS: text for the last visited field of an unvisited kiosk on the guild kiosk tab
            return gettext("never")
        end
    end

    local HEWS_BANE_ZONE_ID = 816
    local THE_RIFT_ZONE_ID = 103
    local function ShowTraderOnMap(data)
        local store = storeList:GetStore(data.storeIndex)
        local mapIndex = GetMapIndexByZoneId(store.zoneId)

        MAIN_MENU_KEYBOARD:ShowCategory(MENU_CATEGORY_MAP)

        if(not store.nearestEntranceIndex or store.mapName ~= GetMapName()) then
            SetMapToMapListIndex(mapIndex)
            if(not store.onZoneMap) then
                local x, y = libGPS:GlobalToLocal(store.x, store.y)
                -- some store coords are outside the click area
                if(store.zoneId == HEWS_BANE_ZONE_ID) then
                    x = x + 0.05
                elseif(store.zoneId == THE_RIFT_ZONE_ID) then
                    y = y - 0.02
                end
                ProcessMapClick(x, y)
            end
        else
            SetMapToPlayerLocation()
        end

        libGPS:SetPlayerChoseCurrentMap()
        CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")

        local x, y = libGPS:GlobalToLocal(store.x, store.y)
        zo_callLater(function() -- delay to give the worldmap time to get ready
            libGPS:PanToMapPosition(x, y)
        end, 200)
    end

    keybindStripDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_CENTER,
        {
            name = GetString(SI_QUEST_JOURNAL_SHOW_ON_MAP),
            keybind = "UI_SHORTCUT_SHOW_QUEST_ON_MAP",

            callback = function()
                ShowTraderOnMap(selectedTraderData)
            end,

            visible = function()
                if(selectedTraderData) then
                    return true
                end
                return false
            end
        },
    }

    local function RefreshTraderList()
        traderList:RefreshData()
        if(not selectedTraderData) then
            local data = traderList:GetFirstKioskEntryInList()
            if(data) then
                SetSelectedDetails(data)
            end
        end
    end
    guildTradersScene.RefreshTraderList = RefreshTraderList

    local function OpenListOnKiosk(kioskName)
        traderList:RefreshData()
        local data = traderList:GetKioskEntryInList(kioskName)
        if(data) then
            SetSelectedDetails(data)
        end
        MAIN_MENU_KEYBOARD:ShowScene(sceneName)
    end
    AGS.internal.OpenTraderListOnKiosk = OpenListOnKiosk

    local function RegisterListUpdate()
        EVENT_MANAGER:RegisterForUpdate(REFRESH_HANDLE, REFRESH_INTERVAL, RefreshTraderList)
    end

    local function UnregisterListUpdate()
        EVENT_MANAGER:UnregisterForUpdate(REFRESH_HANDLE)
    end

    guildTradersScene:RegisterCallback("StateChange", function(oldState, newState)
        if(newState == SCENE_SHOWING) then
            KEYBIND_STRIP:AddKeybindButtonGroup(keybindStripDescriptor)
            RefreshTraderList()
            RegisterListUpdate()
        elseif(newState == SCENE_HIDDEN) then
            KEYBIND_STRIP:RemoveKeybindButtonGroup(keybindStripDescriptor)
            UnregisterListUpdate()
        end
    end)

    local function GoBack()
        MAIN_MENU_KEYBOARD:ShowScene(sceneName)
    end

    -- TRANSLATORS: label for a context menu entry for a row on the guild kiosk tab
    local showDetailsLabel = gettext("Show Details")
    -- TRANSLATORS: label for a context menu entry for a row on the guild kiosk tab
    local showOnMapLabel = gettext("Show On Map")
    -- TRANSLATORS: label for a context menu entry for a row on the guild kiosk tab
    local showGuildDetailsLabel = gettext("Open Guild Info")
    local function ShowTraderContextMenu(control)
        ClearMenu()

        AddCustomMenuItem(showDetailsLabel, function()
            SetSelectedDetails(ZO_ScrollList_GetData(control))
        end)

        AddCustomMenuItem(showOnMapLabel, function()
            ShowTraderOnMap(ZO_ScrollList_GetData(control))
        end)

        local data = ZO_ScrollList_GetData(control)
        if(data.owner and data.owner.id) then
            AddCustomMenuItem(showGuildDetailsLabel, function()
                ShowGuildDetails(data.owner.id, GoBack)
            end)
        end

        ShowMenu()
    end

    -- mouse handlers for the trader list

    local function OnMouseUp(control, button, upInside)
        if(upInside) then
            if(button == MOUSE_BUTTON_INDEX_RIGHT) then
                ShowTraderContextMenu(control)
            else
                SetSelectedDetails(ZO_ScrollList_GetData(control))
            end
        end
    end

    local function OnRowEnter(control)
        traderList:EnterRow(control)
    end

    local function OnRowExit(control)
        traderList:ExitRow(control)
    end

    local function OnRowFieldEnter(control)
        InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0)
        SetTooltipText(InformationTooltip, control:GetText())
        OnRowEnter(control:GetParent())
    end

    local function OnRowFieldExit(control)
        ClearTooltip(InformationTooltip)
        OnRowExit(control:GetParent())
    end

    local function OnLastVisitedEnter(control)
        OnRowFieldEnter(control)
        InformationTooltip:ClearLines()
        local data = ZO_ScrollList_GetData(control:GetParent())
        local text
        if(data.isMember) then
            -- TRANSLATORS: tooltip for the last visited field of a joined guild on the guild kiosk tab
            text = gettext("You are a member of this guild.")
        else
            text = GetExactLastVisitLabel(data.lastVisited)
        end
        SetTooltipText(InformationTooltip, text)
    end

    AGS.internal.GuildTraderRow_OnMouseUp = OnMouseUp
    AGS.internal.GuildTraderRow_OnMouseEnter = OnRowEnter
    AGS.internal.GuildTraderRow_OnMouseExit = OnRowExit
    AGS.internal.GuildTraderRowField_OnMouseEnter = OnRowFieldEnter
    AGS.internal.GuildTraderRowField_OnMouseExit = OnRowFieldExit
    AGS.internal.GuildTraderRowLastVisited_OnMouseEnter = OnLastVisitedEnter
    AGS.internal.GuildTraderRowLastVisited_OnMouseExit = OnRowFieldExit

    -- mouse handlers for the trader history

    local function OnHistoryMouseUp(control, button, upInside)
        if(upInside) then
            local data = ZO_ScrollList_GetData(control)
            AGS.internal.OpenGuildListOnGuild(data.owner)
        end
    end

    local function OnHistoryRowEnter(control)
        historyList:EnterRow(control)
    end

    local function OnHistoryRowExit(control)
        historyList:ExitRow(control)
    end

    local function OnHistoryWeekEnter(control)
        InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0)
        local data = ZO_ScrollList_GetData(control:GetParent())
        SetTooltipText(InformationTooltip, data.durationAndTime)
        OnHistoryRowEnter(control:GetParent())
    end

    local function OnHistoryRowFieldExit(control)
        ClearTooltip(InformationTooltip)
        OnHistoryRowExit(control:GetParent())
    end

    local function OnHistoryOwnerEnter(control)
        InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0)
        SetTooltipText(InformationTooltip, control:GetText())
        OnHistoryRowEnter(control:GetParent())
    end

    AGS.internal.GuildTraderHistoryRow_OnMouseUp = OnHistoryMouseUp
    AGS.internal.GuildTraderHistoryRow_OnMouseEnter = OnHistoryRowEnter
    AGS.internal.GuildTraderHistoryRow_OnMouseExit = OnHistoryRowExit
    AGS.internal.GuildTraderHistoryRowWeek_OnMouseEnter = OnHistoryWeekEnter
    AGS.internal.GuildTraderHistoryRowWeek_OnMouseExit = OnHistoryRowFieldExit
    AGS.internal.GuildTraderHistoryRowOwner_OnMouseEnter = OnHistoryOwnerEnter
    AGS.internal.GuildTraderHistoryRowOwner_OnMouseExit = OnHistoryRowFieldExit

    -- mouse handlers for the stats
    local function OnUpToDateStatEnter(control)
        InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0)
        -- TRANSLATORS: tooltip text for the store stats on the guild kiosk tab. <<1>> is replaced with the kiosk count
        SetTooltipText(InformationTooltip, gettext("|cffffff<<1>>|r stores visited this week", traderList.upToDateCount))
    end

    local function OnVisitedStatEnter(control)
        InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0)
        -- TRANSLATORS: tooltip text for the store stats on the guild kiosk tab. <<1>> is replaced with the kiosk count
        SetTooltipText(InformationTooltip, gettext("|cffffff<<1>>|r stores visited all time", traderList.visitedCount))
    end

    local function OnOverallStatEnter(control)
        InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0)
        -- TRANSLATORS: tooltip text for the store stats on the guild kiosk tab. <<1>> is replaced with the kiosk count and <<2>> with the amount of distinct locations
        SetTooltipText(InformationTooltip, gettext("|cffffff<<1>>|r stores detected in |cffffff<<2>>|r locations", traderList.overallCount, traderList.storeCount))
    end

    local function OnStatExit(control)
        ClearTooltip(InformationTooltip)
    end

    AGS.internal.GuildTraderHistoryStatUpToDate_OnMouseEnter = OnUpToDateStatEnter
    AGS.internal.GuildTraderHistoryStatVisited_OnMouseEnter = OnVisitedStatEnter
    AGS.internal.GuildTraderHistoryStatOverall_OnMouseEnter = OnOverallStatEnter
    AGS.internal.GuildTraderHistoryStat_OnMouseExit = OnStatExit

    -- mouse handler for the details
    local function OnDetailsLastVisitedEnter(control)
        if(selectedTraderData) then
            InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0)
            local lastVisited = selectedTraderData.isMember and selectedTraderData.realLastVisited or selectedTraderData.lastVisited
            SetTooltipText(InformationTooltip, GetExactLastVisitLabel(lastVisited))
        end
    end

    local function OnDetailsLastVisitedExit(control)
        ClearTooltip(InformationTooltip)
    end

    AGS.internal.GuildTraderDetailsLastVisited_OnMouseEnter = OnDetailsLastVisitedEnter
    AGS.internal.GuildTraderDetailsLastVisited_OnMouseExit = OnDetailsLastVisitedExit

    return guildTradersScene
end

local function IsUndergroundKiosk()
    return GetMapContentType() == MAP_CONTENT_DUNGEON
end

local function GetMapLocationName(locationIndex)
    local name = GetMapLocationTooltipHeader(locationIndex)
    return IRREGULAR_TOOLTIP_HEADER[name] or name
end

local function GetLocationEntranceIndices(mapName)
    local entranceIndices, entranceCoordinates = {}, {}
    for locationIndex = 1, GetNumMapLocations() do
        if(mapName == GetMapLocationName(locationIndex)) then
            local _, x, y = GetMapLocationIcon(locationIndex)
            local gx, gy = libGPS:LocalToGlobal(x, y)
            entranceIndices[#entranceIndices + 1] = locationIndex
            entranceCoordinates[#entranceCoordinates + 1] = {x, y, locationIndex}
        end
    end

    assert(#entranceIndices > 0, string.format("Could not match current map (%s) to entrance pins", mapName))
    return entranceIndices, entranceCoordinates
end

local function IsUndergroundTraderLocationIcon(icon)
    return (icon == FENCE_ICON or icon == THIEVES_GUILD_ICON)
end

local function IsTraderLocationIcon(icon)
    return (icon == KIOSK_ICON or icon == VENDOR_ICON or IsUndergroundTraderLocationIcon(icon))
end

local function InitializeGuildStoreList(globalSaveData)
    local KioskData = AGS.class.KioskData
    local StoreData = AGS.class.StoreData

    local saveData = InitializeSaveData(globalSaveData)
    local lang = GetCVar("Language.2")
    if(not saveData.language) then
        saveData.language = lang
    end
    if(lang ~= saveData.language) then
        Print("Cannot initialize guild trader list. Either clear all data in the settings or switch back to your original language.")
        return
    end

    local guildIdMapping = AGS.internal.guildIdMapping
    local ownerList = AGS.class.OwnerList:New(saveData.owners, guildIdMapping)
    local storeList = AGS.class.StoreList:New(saveData.stores)
    local kioskList = AGS.class.KioskList:New(saveData.kiosks)
    local guildTradersScene = InitializeStoreListWindow(saveData, kioskList, storeList, ownerList)
    local guildList = AGS.internal.InitializeGuildList(saveData, kioskList, storeList, ownerList)
    AGS.internal.storeList = { -- we inject it there for now so we can debug it - until we find a better place
        ownerList = ownerList,
        storeList = storeList,
        kioskList = kioskList,
        guildList = guildList
    }

    local function CollectStoresOnMap(mapName, mapIndex, zoneIndex, x, y)
        for locationIndex = 1, GetNumMapLocations() do
            if(IsLocationVisible(locationIndex)) then
                local icon, lx, ly = GetMapLocationIcon(locationIndex)
                if(IsTraderLocationIcon(icon)) then
                    local isUnderground = IsUndergroundTraderLocationIcon(icon)
                    local storeIndex

                    if(isUnderground) then
                        storeIndex = GetMapLocationName(locationIndex)
                    else
                        storeIndex = BuildStoreIndex(mapName, locationIndex)
                    end

                    local store = storeList:GetStore(storeIndex)

                    if(not store) then
                        local kiosks = GetKioskNamesFromLocationTooltip(locationIndex)
                        if(isUnderground and #kiosks == 0) then
                            kiosks[#kiosks + 1] = "-"
                        end

                        if(#kiosks > 0) then
                            store = StoreData:New()
                            store.index = storeIndex
                            if(not isUnderground) then
                                store.locationIndex = locationIndex
                                store.mapName = mapName
                            else
                                store.mapName = storeIndex
                            end

                            store.kiosks = kiosks
                            local onZoneMap = IsCurrentMapZoneMap()
                            store.zoneId = GetZoneId(zoneIndex)

                            if(isUnderground) then
                                local entranceIndices, entranceCoordinates = GetLocationEntranceIndices(storeIndex)
                                store.entranceIndices = entranceIndices

                                SetMapToMapListIndex(mapIndex)
                                store.wayshrineIndex, store.nearestEntranceIndex = FindNearestWayshrineForEntrances(zoneIndex, entranceCoordinates)
                                ProcessMapClick(x, y)

                                local _, ex, ey = GetMapLocationIcon(store.nearestEntranceIndex)
                                local gx, gy = libGPS:LocalToGlobal(ex, ey)
                                store.x = gx
                                store.y = gy
                            else
                                local gx, gy = libGPS:LocalToGlobal(lx, ly)
                                store.wayshrineIndex = FindNearestWayshrine(zoneIndex, gx, gy)
                                store.x = gx
                                store.y = gy
                                store.onZoneMap = onZoneMap
                            end

                            storeList:SetStore(store)
                        end
                    end
                end
            end
        end
    end

    local currentVersion = GetAPIVersion()
    if(storeList:IsEmpty() or not saveData.lastScannedVersion or saveData.lastScannedVersion < currentVersion) then
        local visitedMaps = {}
        local mapIndex, numMaps = 1, GetNumMaps()

        -- LibGPS and LMP get thrown off by the amount of rapid map changes and will produce ping sounds,
        -- this should be fixed in these libraries, but for now we just mute them here
        LMP:MutePing(MAP_PIN_TYPE_PLAYER_WAYPOINT)
        local function DoCollectStores()
            SetMapToMapListIndex(mapIndex)
            local zoneIndex = GetCurrentMapZoneIndex()
            if(zoneIndex and GetMapContentType() ~= MAP_CONTENT_AVA) then
                local mapName = GetMapName()
                CollectStoresOnMap(mapName, mapIndex, zoneIndex)
                visitedMaps[mapName] = true

                for poiIndex = 1, GetNumPOIs(zoneIndex) do
                    local name = GetPOIInfo(zoneIndex, poiIndex)
                    local x, y = GetPOIMapInfo(zoneIndex, poiIndex)
                    if(not IsPOIPublicDungeon(zoneIndex, poiIndex) and not IsPOIGroupDungeon(zoneIndex, poiIndex) and WouldProcessMapClick(x, y)) then
                        ProcessMapClick(x, y)
                        mapName = GetMapName()
                        if(not visitedMaps[mapName]) then
                            CollectStoresOnMap(mapName, mapIndex, zoneIndex, x, y)
                            visitedMaps[mapName] = true
                        end
                        SetMapToMapListIndex(mapIndex)
                    end
                end
            end

            mapIndex = mapIndex + 1
            if(mapIndex > numMaps) then
                zo_callLater(function()
                    LMP:UnmutePing(MAP_PIN_TYPE_PLAYER_WAYPOINT)
                end, 500)
                storeList:InitializeConfirmedKiosks(kioskList)
                EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAMESPACE)
                saveData.lastScannedVersion = currentVersion
            end
        end
        EVENT_MANAGER:RegisterForUpdate(UPDATE_NAMESPACE, UPDATE_INTERVAL, DoCollectStores)
    else
        storeList:InitializeConfirmedKiosks(kioskList)
    end

    local function SetMapToParentMap()
        if(GetMapTileTexture() == "Art/maps/vvardenfell/vvardenfelloutlawrefuge_base_0.dds") then
            -- when zooming out on the Vivec Outlaws Refuge map, we end up on the Vvardenfell map instead of Vivec City and cannot match the entrance pins
            -- TODO: remove once ZOS fixes the incorrect link
            MapZoomOut()
            ProcessMapClick(0.476, 0.874)
        else
            MapZoomOut()
        end
    end

    local function UpdateKioskAndStore(kioskName, isInteracting)
        SetMapToPlayerLocation()
        local x, y = GetMapPlayerPosition(PLAYER_UNIT_TAG) -- "interact" coordinates are identical for all traders in one spot
        local locationIndex = FindNearestStoreLocation(x, y)
        local mapName = GetMapName()
        local isUnderground = IsUndergroundKiosk()
        local storeIndex

        if(isUnderground) then
            storeIndex = mapName:match("(.-)^.-") or mapName
        else
            storeIndex = BuildStoreIndex(mapName, locationIndex)
        end

        local kiosk = kioskList:GetKiosk(kioskName)
        local store = storeList:GetStore(storeIndex)

        if(not kiosk) then
            kiosk = KioskData:New()
            kiosk.name = kioskName
            kiosk.storeIndex = storeIndex

            storeList:SetConfirmedKiosk(kiosk)
        end
        if(isInteracting and not (kiosk.x ~= -1 or kiosk.y ~= -1)) then
            local gx, gy = libGPS:LocalToGlobal(x, y)
            kiosk.x = gx
            kiosk.y = gy
        end
        kiosk.lastVisited = GetTimeStamp()
        kioskList:SetKiosk(kiosk)

        if(not store) then
            store = StoreData:New()
            store.index = storeIndex
            store.mapName = mapName
            store.locationIndex = locationIndex
            store.kiosks = GetKioskNamesFromLocationTooltip(locationIndex)

            local onZoneMap = IsCurrentMapZoneMap()
            local mapIndex, zoneIndex = libGPS:GetCurrentMapParentZoneIndices()
            store.zoneId = GetZoneId(zoneIndex)

            SetMapToPlayerLocation()
            if(isUnderground) then
                SetMapToParentMap()
                local entranceIndices, entranceCoordinates = GetLocationEntranceIndices(storeIndex)
                store.entranceIndices = entranceIndices

                SetMapToMapListIndex(mapIndex)
                store.wayshrineIndex, store.nearestEntranceIndex = FindNearestWayshrineForEntrances(zoneIndex, entranceCoordinates)

                local _, ex, ey = GetMapLocationIcon(store.nearestEntranceIndex)
                local gx, gy = libGPS:LocalToGlobal(ex, ey)
                store.x = gx
                store.y = gy
            else
                local gx, gy = libGPS:LocalToGlobal(x, y)
                store.wayshrineIndex = FindNearestWayshrine(zoneIndex, gx, gy)
                store.x = gx
                store.y = gy
                store.onZoneMap = onZoneMap
            end

            storeList:SetStore(store)
        end

        if(not storeList:HasConfirmedKiosk(store, kiosk)) then
            storeList:SetConfirmedKiosk(kiosk)
        end
    end

    local function CollectGuildKiosk()
        if(IsAtGuildKiosk()) then
            local kioskName = GetUnitName(INTERACT_UNIT_TAG)
            local guildId, guildName = GetCurrentTradingHouseGuildDetails()
            UpdateKioskAndStore(kioskName, true)
            ownerList:SetCurrentOwner(kioskName, guildName, guildId)
        end
    end
    AGS.internal.CollectGuildKiosk = CollectGuildKiosk

    local REFRESH_TRESHOLD = 1 -- seconds
    local lastCheck = {}

    local function RefreshKioskOwner()
        if(DoesUnitExist(TARGET_UNIT_TAG) and IsUnitGuildKiosk(TARGET_UNIT_TAG)) then
            local kioskName = GetUnitName(TARGET_UNIT_TAG)
            local now = GetGameTimeSeconds()
            if(lastCheck[kioskName] and (now - lastCheck[kioskName]) < REFRESH_TRESHOLD) then return end
            lastCheck[kioskName] = now

            UpdateKioskAndStore(kioskName, false)

            local ownerName, guildId = GetUnitGuildKioskOwnerInfo(TARGET_UNIT_TAG)
            ownerList:SetCurrentOwner(kioskName, ownerName, guildId)
        end
    end

    local targetUnitFrame = ZO_UnitFrames_GetUnitFrame(TARGET_UNIT_TAG)
    ZO_PreHook(targetUnitFrame.nameLabel, 'SetText', RefreshKioskOwner)
    RegisterForEvent(EVENT_GUILD_NAME_AVAILABLE, RefreshKioskOwner)
    local handle = RegisterForEvent(EVENT_GUILD_ID_CHANGED, RefreshKioskOwner)
    EVENT_MANAGER:AddFilterForEvent(handle, EVENT_GUILD_ID_CHANGED, REGISTER_FILTER_UNIT_TAG, TARGET_UNIT_TAG)

    local function UpdateKioskMemberFlag(guildId)
        local infoText = GetGuildOwnedKioskInfo(guildId)
        local kioskName = GetKioskNameFromInfoText(infoText)
        if(kioskName) then
            local kiosk = kioskList:GetKiosk(kioskName)
            if(kiosk) then -- TODO find a way to create the entry when we have not visited the kiosk yet
                kiosk.isMember = true
                kioskList:SetKiosk(kiosk)
                local ownerName = GetGuildName(guildId)
                ownerList:SetCurrentOwner(kioskName, ownerName, guildId)
            end
        else
            local guildData = ownerList:GetGuildData(guildId)
            if(guildData and ownerList:GetCurrentOwner(guildData.lastKiosk) == nil) then
                ownerList:SetCurrentOwner(guildData.lastKiosk)
            end
        end
    end

    local function UnsetAllKioskMemberFlags()
        local kiosks = kioskList:GetAllKiosks()
        for _, kiosk in pairs(kiosks) do
            kiosk.isMember = false
        end
    end

    local function UpdateAllKioskMemberFlags()
        UnsetAllKioskMemberFlags()
        for i = 1, GetNumGuilds() do
            local guildId = GetGuildId(i)
            UpdateKioskMemberFlag(guildId)
        end
        if(guildTradersScene:IsShowing()) then
            guildTradersScene.RefreshTraderList()
        end
    end

    UpdateAllKioskMemberFlags()
    RegisterForEvent(EVENT_GUILD_SELF_JOINED_GUILD, UpdateAllKioskMemberFlags)
    RegisterForEvent(EVENT_GUILD_SELF_LEFT_GUILD, UpdateAllKioskMemberFlags)
    RegisterForEvent(EVENT_GUILD_TRADER_HIRED_UPDATED, UpdateAllKioskMemberFlags)

    local NO_TRADER_TEXT = GetString(SI_GUILD_FINDER_GUILD_INFO_DEFAULT_ATTRIBUTE_VALUE)

    local function OnGuildDataReady(guildId, skipRefresh)
        local guildMetaData = GUILD_BROWSER_MANAGER:GetGuildData(guildId)
        if(guildMetaData.guildName == "") then return end -- guild info was unavailable
        if(guildMetaData.guildTraderText and guildMetaData.guildTraderText ~= NO_TRADER_TEXT) then
            local kioskName = GetKioskNameFromInfoText(guildMetaData.guildTraderText)
            if(kioskName) then
                local kiosk = kioskList:GetKiosk(kioskName)
                if(kiosk) then -- TODO find a way to create the entry when we have not visited the kiosk yet
                    kiosk.lastVisited = GetTimeStamp()
                    kioskList:SetKiosk(kiosk)
                    ownerList:SetCurrentOwner(kioskName, guildMetaData.guildName, guildId)
                end
            end
        else
            local guildData = ownerList:GetGuildData(guildId)
            AGS.internal.logger:Debug(guildId, guildData, guildData and ownerList:GetCurrentOwner(guildData.lastKiosk))
            if(guildData and ownerList:GetCurrentOwner(guildData.lastKiosk) == nil) then
                ownerList:SetCurrentOwner(guildData.lastKiosk)
            end
        end

        if(not skipRefresh and guildTradersScene:IsShowing()) then
            guildTradersScene.RefreshTraderList()
        end
    end

    local function OnGuildFinderSearchResultsReady()
        for _, guildId in GUILD_BROWSER_MANAGER:CurrentFoundGuildsListIterator() do
            OnGuildDataReady(guildId, true)
        end
        if(guildTradersScene:IsShowing()) then
            guildTradersScene.RefreshTraderList()
        end
    end
    GUILD_BROWSER_MANAGER:RegisterCallback("OnGuildDataReady", OnGuildDataReady)
    GUILD_BROWSER_MANAGER:RegisterCallback("OnGuildFinderSearchResultsReady", OnGuildFinderSearchResultsReady)
end
AGS.internal.InitializeGuildStoreList = InitializeGuildStoreList
