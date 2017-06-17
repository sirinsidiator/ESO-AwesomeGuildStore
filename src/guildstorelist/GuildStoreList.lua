local IsUnitGuildKiosk = AwesomeGuildStore.IsUnitGuildKiosk
local GetUnitGuildKioskOwner = AwesomeGuildStore.GetUnitGuildKioskOwner
local IsLocationVisible = AwesomeGuildStore.IsLocationVisible
local IsCurrentMapZoneMap = AwesomeGuildStore.IsCurrentMapZoneMap
local GetKioskName = AwesomeGuildStore.GetKioskName
local RegisterForEvent = AwesomeGuildStore.RegisterForEvent
local gettext = LibStub("LibGetText")("AwesomeGuildStore").gettext

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

local function UpdateSaveData(saveData)
    if(saveData.version == 1) then
        saveData.stores = AwesomeGuildStore.StoreList.UpdateStoreIds(saveData.stores)
        saveData.kiosks = AwesomeGuildStore.KioskList.UpdateStoreIds(saveData.kiosks)
        saveData.version = 2
    end
end

local function InitializeSaveData(saveData)
    if(not saveData.guildStoreList) then
        saveData.guildStoreList = {
            version = 2,
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
    local GetLastVisitLabel = AwesomeGuildStore.GetLastVisitLabel
    local guildTradersFragment = ZO_FadeSceneFragment:New(AwesomeGuildStoreGuildTraders, nil, 0)
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

    local window = AwesomeGuildStoreGuildTraders

    local headers = window:GetNamedChild("Headers")
    -- TRANSLATORS: sort header label for the list on the guild kiosk tab
    ZO_SortHeader_Initialize(headers:GetNamedChild("TraderName"), gettext("Trader"), "traderName", ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontGameLargeBold")
    -- TRANSLATORS: sort header label for the list on the guild kiosk tab
    ZO_SortHeader_Initialize(headers:GetNamedChild("Location"), gettext("Location"), "location", ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontGameLargeBold")
    -- TRANSLATORS: sort header label for the list on the guild kiosk tab
    ZO_SortHeader_Initialize(headers:GetNamedChild("Owner"), gettext("Guild"), "owner", ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontGameLargeBold")
    -- TRANSLATORS: sort header label for the list on the guild kiosk tab
    ZO_SortHeader_Initialize(headers:GetNamedChild("LastVisited"), gettext("Last Visited"), "lastVisited", ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontGameLargeBold")

    local traderList = AwesomeGuildStore.TraderListControl:New(window, storeList, kioskList, ownerList)
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

    local historyList = AwesomeGuildStore.OwnerHistoryControl:New(detailOwnerHistory, storeList, kioskList, ownerList)
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
            detailOwner:SetText(data.owner)
        end
        historyList:SetSelectedKiosk(data.traderName)
        historyList:RefreshData()
    end

    local LDT = LibStub("LibDateTime")
    local function GetExactLastVisitLabel(lastVisited)
        if(lastVisited) then
            local date = LDT:New(lastVisited)
            return date:Format("%Y-%m-%d %H:%M")
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

    -- TRANSLATORS: label for a context menu entry for a row on the guild kiosk tab
    local showDetailsLabel = gettext("Show Details")
    -- TRANSLATORS: label for a context menu entry for a row on the guild kiosk tab
    local showOnMapLabel = gettext("Show On Map")
    local function ShowTraderContextMenu(control)
        ClearMenu()

        AddCustomMenuItem(showDetailsLabel, function()
            SetSelectedDetails(ZO_ScrollList_GetData(control))
        end)

        AddCustomMenuItem(showOnMapLabel, function()
            ShowTraderOnMap(ZO_ScrollList_GetData(control))
        end)

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
        local text = GetExactLastVisitLabel(data.lastVisited)
        if(data.isMember) then
            -- TRANSLATORS: tooltip for the last visited field of a joined guild on the guild kiosk tab
            text = gettext("You are a member of this guild.")
        end
        SetTooltipText(InformationTooltip, text)
    end

    AwesomeGuildStore.GuildTraderRow_OnMouseUp = OnMouseUp
    AwesomeGuildStore.GuildTraderRow_OnMouseEnter = OnRowEnter
    AwesomeGuildStore.GuildTraderRow_OnMouseExit = OnRowExit
    AwesomeGuildStore.GuildTraderRowField_OnMouseEnter = OnRowFieldEnter
    AwesomeGuildStore.GuildTraderRowField_OnMouseExit = OnRowFieldExit
    AwesomeGuildStore.GuildTraderRowLastVisited_OnMouseEnter = OnLastVisitedEnter
    AwesomeGuildStore.GuildTraderRowLastVisited_OnMouseExit = OnRowFieldExit

    -- mouse handlers for the trader history

    local function OnHistoryMouseUp(control, button, upInside)
        if(upInside) then
        -- TODO select guild and show guild information scene
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

    AwesomeGuildStore.GuildTraderHistoryRow_OnMouseUp = OnHistoryMouseUp
    AwesomeGuildStore.GuildTraderHistoryRow_OnMouseEnter = OnHistoryRowEnter
    AwesomeGuildStore.GuildTraderHistoryRow_OnMouseExit = OnHistoryRowExit
    AwesomeGuildStore.GuildTraderHistoryRowWeek_OnMouseEnter = OnHistoryWeekEnter
    AwesomeGuildStore.GuildTraderHistoryRowWeek_OnMouseExit = OnHistoryRowFieldExit
    AwesomeGuildStore.GuildTraderHistoryRowOwner_OnMouseEnter = OnHistoryOwnerEnter
    AwesomeGuildStore.GuildTraderHistoryRowOwner_OnMouseExit = OnHistoryRowFieldExit

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

    AwesomeGuildStore.GuildTraderHistoryStatUpToDate_OnMouseEnter = OnUpToDateStatEnter
    AwesomeGuildStore.GuildTraderHistoryStatVisited_OnMouseEnter = OnVisitedStatEnter
    AwesomeGuildStore.GuildTraderHistoryStatOverall_OnMouseEnter = OnOverallStatEnter
    AwesomeGuildStore.GuildTraderHistoryStat_OnMouseExit = OnStatExit
    
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

    AwesomeGuildStore.GuildTraderDetailsLastVisited_OnMouseEnter = OnDetailsLastVisitedEnter
    AwesomeGuildStore.GuildTraderDetailsLastVisited_OnMouseExit = OnDetailsLastVisitedExit

    return guildTradersScene
end

local function IsUndergroundKiosk()
    return GetMapContentType() == MAP_CONTENT_DUNGEON
end

local IRREGULAR_TOOLTIP_HEADER = { -- TODO exceptions in other languages
    ["Orsinium Outlaw Refuge"] = "Orsinium Outlaws Refuge",
    ["Vivec City Outlaws Refuge"] = "Vivec Outlaws Refuge"
}

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
    local KioskData = AwesomeGuildStore.KioskData
    local StoreData = AwesomeGuildStore.StoreData

    local saveData = InitializeSaveData(globalSaveData)
    local lang = GetCVar("Language.2")
    if(not saveData.language) then
        saveData.language = lang
    end
    if(lang ~= saveData.language) then
        d("[AwesomeGuildStore] Cannot initialize guild trader list. Either clear all data in the settings or switch back to your original language.")
        return
    end

    local ownerList = AwesomeGuildStore.OwnerList:New(saveData.owners)
    local storeList = AwesomeGuildStore.StoreList:New(saveData.stores)
    local kioskList = AwesomeGuildStore.KioskList:New(saveData.kiosks)
    local guildTradersScene = InitializeStoreListWindow(saveData, kioskList, storeList, ownerList)
    AwesomeGuildStore.gsl = {
        ownerList = ownerList,
        storeList = storeList,
        kioskList = kioskList,
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
        local kioskName = GetUnitName(INTERACT_UNIT_TAG)
        if(IsUnitGuildKiosk(INTERACT_UNIT_TAG)) then
            UpdateKioskAndStore(kioskName, true)
            local _, guildName = GetCurrentTradingHouseGuildDetails()
            ownerList:SetCurrentOwner(kioskName, guildName)
        end
    end
    AwesomeGuildStore.CollectGuildKiosk = CollectGuildKiosk

    local targetUnitFrame = ZO_UnitFrames_GetUnitFrame(TARGET_UNIT_TAG)
    ZO_PreHook(targetUnitFrame.nameLabel, 'SetText', function()
        if(DoesUnitExist(TARGET_UNIT_TAG) and IsUnitGuildKiosk(TARGET_UNIT_TAG)) then
            local kioskName = GetUnitName(TARGET_UNIT_TAG)
            UpdateKioskAndStore(kioskName, false)

            local ownerName = GetUnitGuildKioskOwner(TARGET_UNIT_TAG)
            ownerList:SetCurrentOwner(kioskName, ownerName)
        end
    end)

    local function UpdateKioskMemberFlag(guildId)
        local kioskName = GetKioskName(guildId)
        if(kioskName) then
            local kiosk = kioskList:GetKiosk(kioskName)
            if(kiosk) then -- TODO find a way to create the entry when we have not visited the kiosk yet
                kiosk.isMember = true
                kioskList:SetKiosk(kiosk)
                local ownerName = GetGuildName(guildId)
                ownerList:SetCurrentOwner(kioskName, ownerName)
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
end
AwesomeGuildStore.InitializeGuildStoreList = InitializeGuildStoreList