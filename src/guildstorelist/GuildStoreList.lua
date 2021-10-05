local AGS = AwesomeGuildStore

local StoreLocationHelper = AGS.class.StoreLocationHelper
local IsAtGuildKiosk = AGS.internal.IsAtGuildKiosk
local GetUnitGuildKioskOwnerInfo = AGS.internal.GetUnitGuildKioskOwnerInfo
local GetKioskNameFromInfoText = AGS.internal.GetKioskNameFromInfoText
local RegisterForEvent = AGS.internal.RegisterForEvent
local ShowGuildDetails = AGS.internal.ShowGuildDetails
local chat = AGS.internal.chat
local logger = AGS.internal.logger
local gettext = AGS.internal.gettext
local osdate = os.date

local INTERACT_UNIT_TAG = "interact"
local TARGET_UNIT_TAG = "reticleover"
local REFRESH_HANDLE = "AwesomeGuildStoreTraderListRefresh"
local REFRESH_INTERVAL = 15000

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

local function UpdateStoreNames(saveData, oldName, newName)
    if(saveData.stores[oldName] and not saveData.stores[newName]) then
        saveData.stores[newName] = saveData.stores[oldName]:gsub(oldName, newName)
    end
    saveData.stores[oldName] = nil

    for traderName in pairs(saveData.kiosks) do
        saveData.kiosks[traderName] = saveData.kiosks[traderName]:gsub(oldName, newName)
    end
end

local function RemoveInvalidKiosks(saveData)
    local weeksWithOwner = {}
    for kioskName in pairs(saveData.kiosks) do
        weeksWithOwner[kioskName] = 0
    end
    for week, owners in pairs(saveData.owners) do
        for kioskName, owner in pairs(owners) do
            if owner ~= false then
                weeksWithOwner[kioskName] = (weeksWithOwner[kioskName] or 0) + 1
            end
        end
    end

    for kioskName, count in pairs(weeksWithOwner) do
        if count == 0 then
            logger:Warn("Remove invalid kiosk entry '%s' (no owners)", kioskName)
            saveData.kiosks[kioskName] = nil
            for week, owners in pairs(saveData.owners) do
                owners[kioskName] = nil
            end
        end
    end
end

local function RemoveIncorrectFargraveStoreLocation(saveData)
    local FARGRAVE_CITY_DISTRICT_MAP_ID_PATTERN = ".+wP$" -- ends with encoded id 2035
    local storesToRemove = {}
    for locationIndex, storeData in pairs(saveData.stores) do
        if storeData:find(FARGRAVE_CITY_DISTRICT_MAP_ID_PATTERN) then
            storesToRemove[#storesToRemove + 1] = locationIndex
        end
    end

    for i = 1, #storesToRemove do
        logger:Warn("Remove incorrect store location entry '%s' for Fargrave", storesToRemove[i])
        saveData.stores[storesToRemove[i]] = nil
    end
end

local function UpdateSaveData(saveData)
    local requiresRescan = false
    if(saveData.version == 1) then
        saveData.stores = AGS.class.StoreList.UpdateStoreIds(saveData.stores)
        saveData.kiosks = AGS.class.KioskList.UpdateStoreIds(saveData.kiosks)
        saveData.version = 2
    end
    if(saveData.version < 5) then
        for oldName, newName in pairs(StoreLocationHelper.IRREGULAR_TOOLTIP_HEADER) do
            UpdateStoreNames(saveData, oldName, newName)
        end
        saveData.version = 5
    end
    if(saveData.version < 6) then
        RemoveInvalidKiosks(saveData)
        requiresRescan = true
        saveData.version = 6
    end
    if GetAPIVersion() >= 101032 then -- TODO run without check after update
        if(saveData.version < 7) then
            RemoveIncorrectFargraveStoreLocation(saveData)
            saveData.version = 7
            requiresRescan = true
        end
    end
    return requiresRescan
end

local function InitializeSaveData(saveData)
    local requiresRescan = false
    if(not saveData.guildStoreList) then
        saveData.guildStoreList = {
            version = 7,
            owners = {},
            stores = {},
            kiosks = {},
        }
    else
        requiresRescan = UpdateSaveData(saveData.guildStoreList)
    end
    return saveData.guildStoreList, requiresRescan
end

local function InitializeStoreListWindow(saveData, kioskList, storeList, ownerList, storeLocationHelper)
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

    local function ShowTraderOnMap(data)
        local kiosk = kioskList:GetKiosk(data.traderName)
        local store = storeList:GetStore(data.storeIndex)
        storeLocationHelper:ShowKioskOnMap(store, kiosk)
    end

    -- TRANSLATORS: label for a context menu entry for a row on the guild kiosk tab
    local showDetailsLabel = gettext("Show Details")
    local showOnMapLabel = GetString(SI_QUEST_JOURNAL_SHOW_ON_MAP)
    -- TRANSLATORS: label for a context menu entry for a row on the guild kiosk tab
    local showGuildDetailsLabel = gettext("Open Guild Info")

    local function GoBack()
        MAIN_MENU_KEYBOARD:ShowScene(sceneName)
    end

    keybindStripDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_CENTER,
        {
            name = showDetailsLabel,
            keybind = "UI_SHORTCUT_PRIMARY",

            callback = function()
                AGS.internal.OpenGuildListOnGuild(selectedTraderData.owner)
            end,

            visible = function()
                if(selectedTraderData and selectedTraderData.owner.name ~= "-") then
                    return true
                end
                return false
            end
        },
        {
            name = showOnMapLabel,
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
        {
            name = showGuildDetailsLabel,
            keybind = "UI_SHORTCUT_SECONDARY",

            callback = function()
                ShowGuildDetails(selectedTraderData.owner.id, GoBack)
            end,

            visible = function()
                if(selectedTraderData and selectedTraderData.owner and selectedTraderData.owner.id) then
                    return true
                end
                return false
            end
        },
    }

    local function RefreshTraderList()
        logger:Verbose("RefreshTraderList - Kiosks")
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

    local function ShowTraderContextMenu(control)
        ClearMenu()

        local data = ZO_ScrollList_GetData(control)
        if(data.owner.name ~= "-") then
            AddCustomMenuItem(showDetailsLabel, function()
                AGS.internal.OpenGuildListOnGuild(data.owner)
            end)
        end

        AddCustomMenuItem(showOnMapLabel, function()
            ShowTraderOnMap(ZO_ScrollList_GetData(control))
        end)

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

local function InitializeGuildStoreList(globalSaveData)
    local saveData, requiresRescan = InitializeSaveData(globalSaveData)
    local lang = GetCVar("Language.2")
    if(not saveData.language) then
        saveData.language = lang
    end
    if(lang ~= saveData.language) then
        chat:Print("Cannot initialize guild trader list. Either clear all data in the settings or switch back to your original language.")
        return
    end

    local guildIdMapping = AGS.internal.guildIdMapping
    local ownerList = AGS.class.OwnerList:New(saveData.owners, guildIdMapping)
    local kioskList = AGS.class.KioskList:New(saveData.kiosks)
    local storeList = AGS.class.StoreList:New(saveData.stores, kioskList)
    local storeLocationHelper = StoreLocationHelper:New(storeList, kioskList)
    local guildTradersScene = InitializeStoreListWindow(saveData, kioskList, storeList, ownerList, storeLocationHelper)
    local guildList = AGS.internal.InitializeGuildList(saveData, kioskList, storeList, ownerList)
    AGS.internal.storeList = { -- we inject it there for now so we can debug it - until we find a better place
        ownerList = ownerList,
        storeList = storeList,
        kioskList = kioskList,
        guildList = guildList,
        storeLocationHelper = storeLocationHelper
    }

    local function CollectGuildKiosk()
        if(IsAtGuildKiosk()) then
            local kioskName = GetUnitName(INTERACT_UNIT_TAG)
            local guildId, guildName = GetCurrentTradingHouseGuildDetails()
            storeLocationHelper:UpdateKioskAndStore(kioskName)
            ownerList:SetCurrentOwner(kioskName, guildName, guildId)
        end
    end
    AGS.internal.CollectGuildKiosk = CollectGuildKiosk

    local REFRESH_TRESHOLD = 5 -- seconds
    local lastCheck = {}

    local function RefreshKioskOwner()
        if(DoesUnitExist(TARGET_UNIT_TAG) and IsUnitGuildKiosk(TARGET_UNIT_TAG)) then
            local kioskName = GetUnitName(TARGET_UNIT_TAG)
            local now = GetGameTimeSeconds()
            if(lastCheck[kioskName] and (now - lastCheck[kioskName]) < REFRESH_TRESHOLD) then return end
            lastCheck[kioskName] = now

            local hasKioskData = kioskList:HasKiosk(kioskName)
            local ownerName, guildId = GetUnitGuildKioskOwnerInfo(TARGET_UNIT_TAG)
            if guildId or hasKioskData then -- prevent NPCs that aren't actual kiosks from entering the dataset
                storeLocationHelper:UpdateKioskAndStore(kioskName)
            end

            if hasKioskData then
                ownerList:SetCurrentOwner(kioskName, ownerName, guildId)
            end
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

    local currentVersion = GetAPIVersion()
    if(requiresRescan or storeList:IsEmpty() or not saveData.lastScannedVersion or saveData.lastScannedVersion < currentVersion) then
        storeLocationHelper:ScanAllMaps():Then(function()
            storeList:InitializeConfirmedKiosks(kioskList)
            UpdateAllKioskMemberFlags()
            saveData.lastScannedVersion = currentVersion
        end)
    else
        storeList:InitializeConfirmedKiosks(kioskList)
        UpdateAllKioskMemberFlags()
    end

    RegisterForEvent(EVENT_GUILD_SELF_JOINED_GUILD, UpdateAllKioskMemberFlags)
    RegisterForEvent(EVENT_GUILD_SELF_LEFT_GUILD, UpdateAllKioskMemberFlags)
    RegisterForEvent(EVENT_GUILD_TRADER_HIRED_UPDATED, UpdateAllKioskMemberFlags)

    local NO_TRADER_TEXT = GetString(SI_GUILD_FINDER_GUILD_INFO_DEFAULT_ATTRIBUTE_VALUE)

    local function OnGuildDataReady(guildId, skipRefresh)
        local guildMetaData = GUILD_BROWSER_MANAGER:GetGuildData(guildId)
        logger:Verbose("OnGuildDataReady", guildId, guildMetaData.guildName)
        if(guildMetaData.guildName == "") then return end -- guild info was unavailable
        logger:Verbose(guildMetaData.guildTraderText)
        if(guildMetaData.guildTraderText and guildMetaData.guildTraderText ~= NO_TRADER_TEXT) then
            local kioskName = GetKioskNameFromInfoText(guildMetaData.guildTraderText)
            logger:Verbose("Has trader", kioskName)
            if(kioskName) then
                local kiosk = kioskList:GetKiosk(kioskName)
                logger:Verbose(kiosk)
                if(kiosk) then -- TODO find a way to create the entry when we have not visited the kiosk yet
                    kiosk.lastVisited = GetTimeStamp()
                    kioskList:SetKiosk(kiosk)
                    ownerList:SetCurrentOwner(kioskName, guildMetaData.guildName, guildId)
                end
            end
        else
            logger:Verbose("no trader")
            local guildData = ownerList:GetGuildData(guildId)
            logger:Verbose(guildId, guildData, guildData and ownerList:GetCurrentOwner(guildData.lastKiosk))
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
