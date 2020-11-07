local AGS = AwesomeGuildStore

local ShowGuildDetails = AGS.internal.ShowGuildDetails
local gettext = AGS.internal.gettext
local osdate = os.date

local REFRESH_HANDLE = "AwesomeGuildStoreListRefresh"
local REFRESH_INTERVAL = 15000

local libGPS = LibGPS2
local LDT = LibDateTime

local menu = MAIN_MENU_KEYBOARD
local category = MENU_CATEGORY_GUILDS
local categoryInfo = menu.categoryInfo[category]
local sceneGroupName =  "guildsSceneGroup"
local sceneName = "AGS_guilds"

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

local function InitializeGuildList(saveData, kioskList, storeList, ownerList)
    local window = AwesomeGuildStoreGuilds

    local GetLastVisitLabel = AGS.internal.GetLastVisitLabel
    local GetZoneLabel = AGS.internal.GetZoneLabel
    local GetPoiLabel = AGS.internal.GetPoiLabel
    local GetLastVisited = AGS.internal.GetLastVisited
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

    InjectGuildMenuTab(sceneName, SI_GUILD_TRADER_OWNERSHIP_HEADER, "EsoUI/Art/Guild/guildHistory_indexIcon_combat_%s.dds")

    local headers = window:GetNamedChild("Headers")
    ZO_SortHeader_InitializeArrowHeader(headers:GetNamedChild("LastActive"), "lastActive", ZO_SORT_ORDER_UP)
    -- TRANSLATORS: sort header tooltip for the list on the guild kiosk tab
    ZO_SortHeader_SetTooltip(headers:GetNamedChild("LastActive"), gettext("Number of weeks since last seen on a trader"))
    ZO_SortHeader_InitializeArrowHeader(headers:GetNamedChild("KioskCount"), "kioskCount", ZO_SORT_ORDER_UP)
    -- TRANSLATORS: sort header tooltip for the list on the guild kiosk tab
    ZO_SortHeader_SetTooltip(headers:GetNamedChild("KioskCount"), gettext("Number of weeks with a kiosk"))
    -- TRANSLATORS: sort header label for the list on the guild kiosk tab
    ZO_SortHeader_Initialize(headers:GetNamedChild("GuildName"), gettext("Guild"), "guildName", ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontGameLargeBold")

    local guildList = AGS.class.GuildListControl:New(window, storeList, kioskList, ownerList)
    window.guildList = guildList

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
    details:GetNamedChild("KioskCountLabel"):SetText(gettext("Weeks w/ kiosk") .. ":")
    local detailKioskCount = details:GetNamedChild("KioskCountValue")
    details:GetNamedChild("HistoryLabel"):SetText(gettext("History") .. ":")
    local detailOwnerHistory = details:GetNamedChild("History")

    local historyHeaders = detailOwnerHistory:GetNamedChild("Headers")
    -- TRANSLATORS: sort header label for the history list on the guild kiosk tab
    ZO_SortHeader_Initialize(historyHeaders:GetNamedChild("Week"), gettext("Week"), "week", ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontGameLargeBold")
    ZO_SortHeader_Initialize(historyHeaders:GetNamedChild("Trader"), gettext("Trader"), "trader", ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontGameLargeBold")
    ZO_SortHeader_Initialize(historyHeaders:GetNamedChild("Location"), gettext("Location"), "location", ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontGameLargeBold")

    local historyList = AGS.class.KioskHistoryControl:New(detailOwnerHistory, storeList, kioskList, ownerList)
    window.historyList = historyList

    -- TRANSLATORS: label for a context menu entry for a row on the guild kiosk tab
    local showDetailsLabel = gettext("Show Details")
    -- TRANSLATORS: label for a context menu entry for a row on the guild kiosk tab
    local showGuildDetailsLabel = gettext("Open Guild Info")

    local selectedTraderData
    local function GoBack()
        MAIN_MENU_KEYBOARD:ShowScene(sceneName)
    end

    local keybindStripDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_CENTER,
        {
            name = showDetailsLabel,
            keybind = "UI_SHORTCUT_PRIMARY",

            callback = function()
                AGS.internal.OpenTraderListOnKiosk(selectedTraderData.guild.lastKiosk)
            end,

            visible = function()
                if(selectedTraderData and selectedTraderData.guild and selectedTraderData.guild.lastKiosk) then
                    return true
                end
                return false
            end
        },
        {
            name = showGuildDetailsLabel,
            keybind = "UI_SHORTCUT_SECONDARY",

            callback = function()
                ShowGuildDetails(selectedTraderData.guildId, GoBack)
            end,

            visible = function()
                if(selectedTraderData and selectedTraderData.guildId) then
                    return true
                end
                return false
            end
        },
    }

    local detailsGuildInfoButton = AGS.class.SimpleIconButton:New(details:GetNamedChild("GuildInfoButton"))
    detailsGuildInfoButton:SetSize(48)
    detailsGuildInfoButton:SetTextureTemplate("EsoUI/Art/SkillsAdvisor/advisor_tabIcon_tutorial_%s.dds")
    -- TRANSLATORS: tooltip text for the open guild info button in the detail view on the guild kiosk tab
    detailsGuildInfoButton:SetTooltipText(gettext("Open Guild Info"))
    detailsGuildInfoButton:SetClickHandler(MOUSE_BUTTON_INDEX_LEFT, function()
        if(selectedTraderData) then
            ShowGuildDetails(selectedTraderData.guild.id, GoBack)
        end
    end)

    local function SetSelectedDetails(data)
        selectedTraderData = data
        KEYBIND_STRIP:UpdateKeybindButtonGroup(keybindStripDescriptor)

        local guild = data.guild
        detailTraderName:SetText(guild.name)
        detailsGuildInfoButton:SetHidden(not guild.id)
        historyList:SetSelectedGuild(guild)
        historyList:RefreshData()
        detailKioskCount:SetText(historyList:GetKioskCount())

        local kiosk = data.guild.lastKiosk and kioskList:GetKiosk(data.guild.lastKiosk)
        if(kiosk) then
            local store = storeList:GetStore(kiosk.storeIndex)

            if(not data.lastVisitedLabel) then
                if(guild.hasActiveTrader) then
                    local lastVisited, realLastVisited = GetLastVisited(kiosk)
                    data.lastVisitedLabel = GetLastVisitLabel(realLastVisited or lastVisited)
                elseif(guild.lastVisitedWeek ~= 0) then
                    local yearA, weekA = LDT:SeparateIsoWeekAndYear(guild.lastVisitedWeek)
                    local yearB, weekB = LDT:CalculateIsoWeekAndYear()
                    local diff = LDT:CalculateIsoWeekDifference(yearA, weekA, yearB, weekB)
                    -- TRANSLATORS: text for the last visited label in the guild list detail view. $d is a placeholder for the number of weeks
                    data.lastVisitedLabel = zo_strformat(gettext("<<1[this week/1 week ago/$d weeks ago]>>"), diff)
                else
                    data.lastVisitedLabel = "-"
                end
                data.zoneName = GetZoneLabel(store)
                data.poi = GetPoiLabel(store)
            end
            detailLastVisited:SetText(data.lastVisitedLabel) -- TODO: set color based on guild.hasActiveTrader
            detailZone:SetText(data.zoneName)
            detailLocation:SetText(data.poi)
        else
            detailLastVisited:SetText("-")
            detailZone:SetText("-")
            detailLocation:SetText("-")
        end
    end

    local function GetExactLastVisitLabel(lastVisited)
        if(lastVisited) then
            return osdate("%F %H:%M", lastVisited)
        else
            -- TRANSLATORS: text for the last visited field of an unvisited kiosk on the guild kiosk tab
            return gettext("never")
        end
    end

    local function RefreshTraderList()
        AGS.internal.logger:Verbose("RefreshTraderList - Guilds")
        guildList:RefreshData()
        if(not selectedTraderData) then
            local data = guildList:GetFirstGuildEntryInList()
            if(data) then
                SetSelectedDetails(data)
            end
        end
    end
    guildTradersScene.RefreshTraderList = RefreshTraderList

    local function OpenListOnGuild(guild)
        guildList:RefreshData()
        local data = guildList:GetGuildEntryInList(guild)
        if(data) then
            SetSelectedDetails(data)
        end
        MAIN_MENU_KEYBOARD:ShowScene(sceneName)
    end
    AGS.internal.OpenGuildListOnGuild = OpenListOnGuild

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

    -- mouse handlers for the guild list

    local function OnMouseUp(control, button, upInside)
        if(upInside) then
            if(button == MOUSE_BUTTON_INDEX_RIGHT) then
            --ShowTraderContextMenu(control)
            else
                SetSelectedDetails(ZO_ScrollList_GetData(control))
            end
        end
    end

    local function OnRowEnter(control)
        guildList:EnterRow(control)
    end

    local function OnRowExit(control)
        guildList:ExitRow(control)
    end

    local function OnRowFieldEnter(control)
        if(control:WasTruncated()) then
            InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0)
            SetTooltipText(InformationTooltip, control:GetText())
        end
        OnRowEnter(control:GetParent())
    end

    local function OnRowFieldExit(control)
        ClearTooltip(InformationTooltip)
        OnRowExit(control:GetParent())
    end

    AGS.internal.GuildRow_OnMouseUp = OnMouseUp
    AGS.internal.GuildRow_OnMouseEnter = OnRowEnter
    AGS.internal.GuildRow_OnMouseExit = OnRowExit
    AGS.internal.GuildRowField_OnMouseEnter = OnRowFieldEnter
    AGS.internal.GuildRowField_OnMouseExit = OnRowFieldExit

    -- mouse handlers for the trader history

    local function OnHistoryMouseUp(control, button, upInside)
        if(upInside) then
            local data = ZO_ScrollList_GetData(control)
            AGS.internal.OpenTraderListOnKiosk(data.kioskName)
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

    local function OnHistoryTraderEnter(control)
        if(control:WasTruncated()) then
            InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0)
            SetTooltipText(InformationTooltip, control:GetText())
        end
        OnHistoryRowEnter(control:GetParent())
    end

    AGS.internal.GuildKioskHistoryRow_OnMouseUp = OnHistoryMouseUp
    AGS.internal.GuildKioskHistoryRow_OnMouseEnter = OnHistoryRowEnter
    AGS.internal.GuildKioskHistoryRow_OnMouseExit = OnHistoryRowExit
    AGS.internal.GuildKioskHistoryRowWeek_OnMouseEnter = OnHistoryWeekEnter
    AGS.internal.GuildKioskHistoryRowWeek_OnMouseExit = OnHistoryRowFieldExit
    AGS.internal.GuildKioskHistoryRowTrader_OnMouseEnter = OnHistoryTraderEnter
    AGS.internal.GuildKioskHistoryRowTrader_OnMouseExit = OnHistoryRowFieldExit
    AGS.internal.GuildKioskHistoryRowLocation_OnMouseEnter = OnHistoryTraderEnter
    AGS.internal.GuildKioskHistoryRowLocation_OnMouseExit = OnHistoryRowFieldExit

    -- mouse handlers for the stats
    local function OnUpToDateStatEnter(control)
        InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0)
        -- TRANSLATORS: tooltip text for the store stats on the guild kiosk tab. <<1>> is replaced with the kiosk count
        SetTooltipText(InformationTooltip, gettext("|cffffff<<1>>|r guilds visited this week", guildList.upToDateCount))
    end

    local function OnVisitedStatEnter(control)
        InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0)
        -- TRANSLATORS: tooltip text for the store stats on the guild kiosk tab. <<1>> is replaced with the kiosk count
        SetTooltipText(InformationTooltip, gettext("|cffffff<<1>>|r guilds visited all time", guildList.visitedCount))
    end

    local function OnOverallStatEnter(control)
        InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0)
        -- TRANSLATORS: tooltip text for the store stats on the guild kiosk tab. <<1>> is replaced with the overall guild count
        SetTooltipText(InformationTooltip, gettext("|cffffff<<1>>|r guilds stored", guildList.overallCount))
    end

    local function OnStatExit(control)
        ClearTooltip(InformationTooltip)
    end

    AGS.internal.GuildKioskHistoryStatUpToDate_OnMouseEnter = OnUpToDateStatEnter
    AGS.internal.GuildKioskHistoryStatVisited_OnMouseEnter = OnVisitedStatEnter
    AGS.internal.GuildKioskHistoryStatOverall_OnMouseEnter = OnOverallStatEnter
    AGS.internal.GuildKioskHistoryStat_OnMouseExit = OnStatExit

    return guildTradersScene
end
AGS.internal.InitializeGuildList = InitializeGuildList
