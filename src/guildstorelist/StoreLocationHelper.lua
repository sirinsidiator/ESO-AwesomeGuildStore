local AGS = AwesomeGuildStore

local StoreData = AGS.class.StoreData
local KioskData = AGS.class.KioskData
local IsCurrentMapZoneMap = AGS.internal.IsCurrentMapZoneMap
local logger = AGS.internal.logger

local pinManager = ZO_WorldMap_GetPinManager()
local panAndZoomManager = ZO_WorldMap_GetPanAndZoom()
local GPS = LibGPS3
local LMP = LibMapPing
local Promise = LibPromises

local UPDATE_NAMESPACE = "AwesomeGuildStoreStoreLocationUpdate"
local UPDATE_INTERVAL = 0 -- we want to do it as fast as possible without producing a freeze
local AFTER_SCAN_CLEANUP_DELAY = 500 -- give LibGPS and LibMapPing some time before unmuting the pings again
local SHOW_ON_MAP_DELAY = 200 -- delay to give the worldmap time to get ready

local FENCE_ICON = "/esoui/art/icons/servicemappins/servicepin_fence.dds"
local THIEVES_GUILD_ICON = "/esoui/art/icons/servicemappins/servicepin_thievesguild.dds" -- already shows the guild trader in tooltip
local KIOSK_ICON = "/esoui/art/icons/servicemappins/servicepin_guildkiosk.dds"
local VENDOR_ICON = "/esoui/art/icons/servicemappins/servicepin_vendor.dds"
local KIOSK_TOOLTIP_ICON = "/esoui/art/icons/servicetooltipicons/servicetooltipicon_guildkiosk.dds"

local PLAYER_UNIT_TAG = "player"
local TARGET_UNIT_TAG = "reticleover"

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

local SPECIAL_MAP_CLICK_TARGETS = { -- Some maps return 0/0 for all POIs under some circumstances
    [227] = { 0.5, 0.5 }, -- Betnikh - as long as we haven't been to the zone yet
    [1719] = { 0.56, 0.38 }, -- Western Skyrim - on first login with a char after the update
}

local FARGRAVE_CITY_DISTRICT_MAP_ID = 2035
local FARGRAVE_THE_BAZAAR_ID = 2136

local function IsCoordinateOutsideCurrentMap(x, y)
    return x <= 0 or x > 1 or y <= 0 or y > 1
end

local function IsUndergroundKiosk()
    if GetCurrentMapId() == FARGRAVE_THE_BAZAAR_ID then
        -- The Bazaar is a sub map of Fargrave City District, but has no entrance pins
        return false
    end
    return GetMapContentType() == MAP_CONTENT_DUNGEON
end

local function IsUndergroundTraderLocationIcon(icon)
    return (icon == FENCE_ICON or icon == THIEVES_GUILD_ICON)
end

local function IsTraderLocationIcon(icon)
    return (icon == KIOSK_ICON or icon == VENDOR_ICON or IsUndergroundTraderLocationIcon(icon))
end

local function GetPOICoordinates(zoneIndex, poiIndex)
    if IsPOIPublicDungeon(zoneIndex, poiIndex) or IsPOIGroupDungeon(zoneIndex, poiIndex) then return 0, 0 end

    local x, y = GetPOIMapInfo(zoneIndex, poiIndex)
    return x, y
end

local function GetMapLocationName(locationIndex)
    local name = zo_strformat("<<1>>", GetMapLocationTooltipHeader(locationIndex))
    return IRREGULAR_TOOLTIP_HEADER[name] or name
end

local function SafeGetMapName()
    local name = GetMapName()
    name = name:gsub("(%^.-)d(.-)$", "%1%2") -- filter the modifier "d" (prefixes the name with an article), as it would cause problems in German
    return zo_strformat("<<1>>", name) or "-unknown-"
end

local function BuildStoreIndex(mapName, locationIndex)
    return string.format("%s.%d", mapName, locationIndex)
end

local function GetStoreIndex(mapName, locationIndex)
    local icon, x, y = GetMapLocationIcon(locationIndex)
    if not IsTraderLocationIcon(icon) or IsCoordinateOutsideCurrentMap(x, y) then return end

    local storeIndex
    local isUnderground = IsUndergroundTraderLocationIcon(icon)

    if isUnderground then
        storeIndex = GetMapLocationName(locationIndex)
    else
        storeIndex = BuildStoreIndex(mapName, locationIndex)
    end

    return storeIndex, isUnderground
end

local function IsOnStoreMap(store)
    if store.mapId == 0 then -- TODO get rid of this in the future
        return store.mapName == SafeGetMapName()
    end
    return store.mapId == GetCurrentMapId()
end

local function TrySetMapToMapListIndex(mapIndex)
    if SetMapToMapListIndex(mapIndex) ~= SET_MAP_RESULT_FAILED then
        return true
    end
    logger:Warn("Could not set map to mapIndex", mapIndex)
    return false
end

local function TrySetMapToMapId(mapId)
    if SetMapToMapId(mapId) ~= SET_MAP_RESULT_FAILED then
        return true
    end
    logger:Warn("Could not set map to mapId", mapId)
    return false
end

local function TrySetMapToPlayerLocation()
    if SetMapToPlayerLocation() ~= SET_MAP_RESULT_FAILED then
        return true
    end
    logger:Warn("Could not set map to player location")
    return false
end

local function TryProcessMapClick(x, y, silent)
    if x == 0 and y == 0 then
        logger:Warn("Tried to click invalid coordinates")
        return false
    end
    if not WouldProcessMapClick(x, y) then
        -- if the exact spot doesn't work, just try a few points around it
        for i = 0, 7 do
            local a = math.pi * i / 4
            local nx = x + math.cos(a) * 0.05
            local ny = y + math.sin(a) * 0.05
            if not WouldProcessMapClick(x, y) then
                x, y = nx, ny
                break
            end
        end
    end
    if ProcessMapClick(x, y) ~= SET_MAP_RESULT_FAILED then
        return true
    end
    if not silent then logger:Warn("Could not process map click") end
    return false
end

local function TrySetMapToParentMap()
    if not TrySetMapToPlayerLocation() then return false end
    if MapZoomOut() ~= SET_MAP_RESULT_MAP_CHANGED then
        logger:Warn("Could not zoom map out")
        return false
    end

    if GetCurrentMapId() == 1245 then
        -- when zooming out on the Vivec Outlaws Refuge map, we end up on the Vvardenfell map instead of Vivec City and cannot match the entrance pins
        -- TODO: remove once ZOS fixes the incorrect link
        if ProcessMapClick(0.476, 0.874) == SET_MAP_RESULT_FAILED or GetCurrentMapId() ~= 1287 then
            logger:Warn("Could not open Vivec City map")
            return false
        end
    end
    return true
end

local function TryOpenStoreMap(store)
    if not IsOnStoreMap(store) then
        TrySetMapToPlayerLocation()
    end

    if not IsOnStoreMap(store) then
        local mapIndex = GetMapIndexByZoneId(store.zoneId)
        TrySetMapToMapListIndex(mapIndex)

        if not store.onZoneMap then
            local x, y = GPS:GlobalToLocal(store.x, store.y)
            TryProcessMapClick(x, y)
        end
    end

    return IsOnStoreMap(store)
end

local function GetKioskNamesFromLocationTooltip(locationIndex)
    local kiosks = {}
    for tooltipLineIndex = 1, GetNumMapLocationTooltipLines(locationIndex) do
        if IsMapLocationTooltipLineVisible(locationIndex, tooltipLineIndex) then
            local tooltipIcon, kioskName = GetMapLocationTooltipLineInfo(locationIndex, tooltipLineIndex)
            if tooltipIcon == KIOSK_TOOLTIP_ICON then
                kiosks[#kiosks + 1] = zo_strformat("<<1>>", kioskName)
            end
        end
    end
    return kiosks
end

local function IsStoreLocation(locationIndex)
    for tooltipLineIndex = 1, GetNumMapLocationTooltipLines(locationIndex) do
        if IsMapLocationTooltipLineVisible(locationIndex, tooltipLineIndex) then
            local tooltipIcon = GetMapLocationTooltipLineInfo(locationIndex, tooltipLineIndex)
            if tooltipIcon == KIOSK_TOOLTIP_ICON then
                return true
            end
        end
    end
    return false
end

local function GetGlobalCoordinatesForLocation(locationIndex)
    local _, lx, ly = GetMapLocationIcon(locationIndex)
    return GPS:LocalToGlobal(lx, ly)
end

local function GetLocationEntranceIndices(mapName, entranceMapId, entranceMapName)
    local entranceIndices, entranceCoordinates = {}, {}
    for locationIndex = 1, GetNumMapLocations() do
        if mapName == GetMapLocationName(locationIndex) then
            local x, y = GetGlobalCoordinatesForLocation(locationIndex)
            entranceIndices[#entranceIndices + 1] = locationIndex
            entranceCoordinates[#entranceCoordinates + 1] = {x, y, locationIndex}
        end
    end

    assert(#entranceIndices > 0, string.format("Could not match entrance pins for %s on %s (%d)", mapName, entranceMapName, entranceMapId))
    return entranceIndices, entranceCoordinates
end

local function FindNearestStoreLocation(x, y)
    local dmin = 1
    local locationIndex = 0
    for index = 1, GetNumMapLocations() do
        local icon, lx, ly = GetMapLocationIcon(index)
        if IsStoreLocation(index) then
            local dx = x - lx
            local dy = y - ly
            local ds = dx * dx + dy * dy
            if ds < dmin then
                dmin = ds
                locationIndex = index
            end
        end
    end
    return locationIndex, dmin
end

local function FindNearestWayshrine(zoneIndex, x, y)
    local dmin = 1
    local wayshrineIndex = 0
    for index = 1, GetNumPOIs(zoneIndex) do
        if IsPOIWayshrine(zoneIndex, index) then
            local wx, wy = GPS:LocalToGlobal(GetPOIMapInfo(zoneIndex, index))
            local dx = x - wx
            local dy = y - wy
            local ds = dx * dx + dy * dy
            if ds < dmin then
                dmin = ds
                wayshrineIndex = index
            end
        end
    end
    return wayshrineIndex, dmin
end

local function FindNearestWayshrineForEntrances(zoneIndex, entranceCoordinates)
    local dmin = 1
    local wayshrineIndex = 0
    local entranceX = 0
    local entranceY = 0
    for i = 1, #entranceCoordinates do
        local x, y = unpack(entranceCoordinates[i])
        local targetIndex, ds = FindNearestWayshrine(zoneIndex, x, y)
        if ds < dmin then
            dmin = ds
            wayshrineIndex = targetIndex
            entranceX = x
            entranceY = y
        end
    end
    return wayshrineIndex, entranceX, entranceY, dmin
end

local function FindNearestEntranceCoordinates(entranceIndices, x, y)
    logger:Verbose("FindNearestEntranceCoordinates")
    local dmin = 1
    local nx = 0
    local ny = 0
    for i = 1, #entranceIndices do
        local _, lx, ly = GetMapLocationIcon(entranceIndices[i])
        local dx = x - lx
        local dy = y - ly
        local ds = dx * dx + dy * dy
        if ds < dmin then
            logger:Verbose("new closest coordinates found")
            dmin = ds
            nx = lx
            ny = ly
        end
    end
    return nx, ny, dmin
end

local StoreLocationHelper = ZO_Object:Subclass()
AGS.class.StoreLocationHelper = StoreLocationHelper

StoreLocationHelper.IRREGULAR_TOOLTIP_HEADER = IRREGULAR_TOOLTIP_HEADER

function StoreLocationHelper:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function StoreLocationHelper:Initialize(storeList, kioskList)
    self.storeList = storeList
    self.kioskList = kioskList
end

function StoreLocationHelper:ScanAllMaps()
    logger:Info("Scan all maps for guild stores")
    local promise = Promise:New()
    local visitedMaps = {}
    local mapIndex, numMaps = 1, GetNumMaps()

    -- LibGPS and LMP get thrown off by the amount of rapid map changes and will produce ping sounds,
    -- this should be fixed in these libraries, but for now we just mute them here
    LMP:MutePing(MAP_PIN_TYPE_PLAYER_WAYPOINT)
    local function DoCollectStores()
        if TrySetMapToMapListIndex(mapIndex) then
            local zoneIndex = GetCurrentMapZoneIndex()
            if zoneIndex and GetMapType() == MAPTYPE_ZONE and GetMapContentType() ~= MAP_CONTENT_AVA then
                local mapName = SafeGetMapName()
                local mapId = GetCurrentMapId()
                self:CollectStoresOnCurrentMap(mapId, mapName, mapIndex, zoneIndex)
                visitedMaps[mapId] = true

                local pointsToClick = {}
                if SPECIAL_MAP_CLICK_TARGETS[mapId] then
                    pointsToClick[#pointsToClick + 1] = SPECIAL_MAP_CLICK_TARGETS[mapId]
                else
                    for poiIndex = 1, GetNumPOIs(zoneIndex) do
                        local x, y = GetPOICoordinates(zoneIndex, poiIndex)
                        if x ~= 0 or y ~= 0 then
                            pointsToClick[#pointsToClick + 1] = {x, y}
                        end
                    end
                end

                if #pointsToClick > 0 then
                    for i = 1, #pointsToClick do
                        local x, y = unpack(pointsToClick[i])
                        if TryProcessMapClick(x, y, true) then
                            mapId = GetCurrentMapId()
                            if not visitedMaps[mapId] then
                                visitedMaps[mapId] = true
                                mapName = SafeGetMapName()

                                local isFargraveCityDistrict = mapId == FARGRAVE_CITY_DISTRICT_MAP_ID
                                -- we only collect refuge kiosk on the Fargrave City District map and swap to
                                -- The Bazaar submap manually as it's not reachable by clicks

                                self:CollectStoresOnCurrentMap(mapId, mapName, mapIndex, zoneIndex, isFargraveCityDistrict)

                                if isFargraveCityDistrict and not visitedMaps[FARGRAVE_THE_BAZAAR_ID] and TrySetMapToMapId(FARGRAVE_THE_BAZAAR_ID) then
                                    visitedMaps[FARGRAVE_THE_BAZAAR_ID] = true
                                    mapName = SafeGetMapName()
                                    self:CollectStoresOnCurrentMap(FARGRAVE_THE_BAZAAR_ID, mapName, mapIndex, zoneIndex)
                                end
                            end
                            if not TrySetMapToMapListIndex(mapIndex) then break end
                        end
                    end
                else
                    logger:Warn("No points to click on %s - some locations kiosks may not get detected", mapName)
                end
            end
        end

        mapIndex = mapIndex + 1
        if mapIndex > numMaps then
            zo_callLater(function()
                LMP:UnmutePing(MAP_PIN_TYPE_PLAYER_WAYPOINT)
            end, AFTER_SCAN_CLEANUP_DELAY)
            EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAMESPACE)
            promise:Resolve(self)

            local kioskCount = 0
            local storeCount = 0
            for _, store in pairs(self.storeList:GetAllStores()) do
                kioskCount = kioskCount + #store.kiosks
                storeCount = storeCount + 1
            end
            logger:Info("Finished scanning all maps for kiosks - found %d kiosks in %d stores", kioskCount, storeCount)
        end
    end
    EVENT_MANAGER:RegisterForUpdate(UPDATE_NAMESPACE, UPDATE_INTERVAL, DoCollectStores)

    return promise
end

function StoreLocationHelper:CollectStoresOnCurrentMap(mapId, mapName, mapIndex, zoneIndex, ignoreRegularKiosks)
    logger:Debug("Collect guild stores on map", mapName)
    local zoneId = GetZoneId(zoneIndex)
    local needsWayshrine = {}
    local scannedStores = {}
    local storeCount, kioskCount = 0, 0

    local storeList = self.storeList
    for locationIndex = 1, GetNumMapLocations() do
        local storeIndex, isUnderground = GetStoreIndex(mapName, locationIndex)
        if storeIndex and not scannedStores[storeIndex] and not (ignoreRegularKiosks and not isUnderground) then
            scannedStores[storeIndex] = true
            local kiosks = GetKioskNamesFromLocationTooltip(locationIndex)
            if isUnderground and #kiosks == 0 then
                kiosks[#kiosks + 1] = "-"
            end

            if #kiosks > 0 then
                storeCount = storeCount + 1
                kioskCount = kioskCount + #kiosks

                local store = storeList:GetStore(storeIndex)
                if not store then
                    store = StoreData:New()
                    logger:Verbose("Creating data for", storeIndex)
                else
                    if store.kiosks and #store.kiosks ~= #kiosks then
                        logger:Warn("Number of kiosks has changed for", storeIndex)
                        store.confirmed = false
                    end
                    if (not isUnderground and store.mapId == 0) or (isUnderground and not store.entranceMapId) then
                        logger:Warn("Missing mapId for", storeIndex)
                        store.confirmed = false
                    end
                    if store.zoneId ~= zoneId then
                        logger:Warn("ZoneId has changed for", storeIndex)
                        store.confirmed = false
                    end
                    if not store:HasValidCoordinates() then
                        logger:Warn("No valid coordinates for", storeIndex)
                        store.confirmed = false
                    end
                end

                if not store.confirmed then
                    store.index = storeIndex
                    store.kiosks = kiosks
                    store.zoneId = zoneId
                    logger:Verbose("Collecting data for", storeIndex)

                    if isUnderground then
                        store.mapName = storeIndex
                        store.entranceMapId = mapId
                        local entranceIndices, entranceCoordinates = GetLocationEntranceIndices(store.mapName, store.entranceMapId, mapName)
                        store.entranceIndices = entranceIndices
                        needsWayshrine[#needsWayshrine + 1] = {store, entranceCoordinates}
                    else
                        store.mapName = mapName
                        store.mapId = mapId
                        store.locationIndex = locationIndex
                        store.x, store.y = GetGlobalCoordinatesForLocation(locationIndex)
                        store.wayshrineIndex = FindNearestWayshrine(zoneIndex, store.x, store.y)
                        store.onZoneMap = IsCurrentMapZoneMap()
                        storeList:SetStore(store)
                    end
                end
            end
        end
    end

    if #needsWayshrine > 0 and TrySetMapToMapListIndex(mapIndex) then
        for i = 1, #needsWayshrine do
            local store, entranceCoordinates = unpack(needsWayshrine[i])
            local wayshrineIndex, ex, ey = FindNearestWayshrineForEntrances(zoneIndex, entranceCoordinates)
            store.wayshrineIndex = wayshrineIndex
            store.x, store.y = ex, ey
            storeList:SetStore(store)
        end
    end
    if kioskCount > 0 then
        logger:Info("Found %d kiosks in %d stores on map %s", kioskCount, storeCount, mapName)
    end
end

function StoreLocationHelper:UpdateKioskAndStore(kioskName)
    GPS:PushCurrentMap()
    if not TrySetMapToPlayerLocation() then
        GPS:PopCurrentMap()
        return
    end

    local kioskList = self.kioskList
    local storeList = self.storeList

    local hasExactPosition = true
    local x, y = GetMapPlayerPosition(TARGET_UNIT_TAG)
    if x == 0 and y == 0 then
        x, y = GetMapPlayerPosition(PLAYER_UNIT_TAG)
        hasExactPosition = false
    end

    local locationIndex = FindNearestStoreLocation(x, y)
    local mapName = SafeGetMapName()
    local isUnderground = IsUndergroundKiosk()
    local storeIndex = isUnderground and mapName or BuildStoreIndex(mapName, locationIndex)

    local kiosk = kioskList:GetKiosk(kioskName)
    if not kiosk then
        logger:Verbose("Create new KioskData for", kioskName, storeIndex)
        kiosk = KioskData:New()
        kiosk.name = kioskName
        kiosk.storeIndex = storeIndex
        storeList:SetConfirmedKiosk(kiosk)
    end

    if hasExactPosition or not kiosk:HasValidCoordinates() then
        kiosk.x, kiosk.y = GPS:LocalToGlobal(x, y)
    end
    kiosk.lastVisited = GetTimeStamp()
    kioskList:SetKiosk(kiosk)

    local isNewStore = false
    local store = storeList:GetStore(storeIndex)
    if not store then
        logger:Verbose("Create new StoreData for", storeIndex)
        store = StoreData:New()
        store.index = storeIndex
        store.mapName = mapName
        store.locationIndex = locationIndex
        store.kiosks = GetKioskNamesFromLocationTooltip(locationIndex)
        isNewStore = true
    end

    if not isNewStore and (store.mapId == 0 or (isUnderground and not store.entranceMapId)) then
        logger:Warn("Missing mapIds for", storeIndex)
        store.confirmed = false
    end

    -- do this before we start switching to other maps
    if not store.confirmed or not store:HasValidCoordinates() then
        store.mapId = GetCurrentMapId()
        store.x, store.y = GetGlobalCoordinatesForLocation(locationIndex)
        if not isNewStore then
            logger:Verbose("Update coordinates for", storeIndex)
            storeList:SetStore(store)
        end
    end

    if isNewStore then
        local onZoneMap = IsCurrentMapZoneMap()
        local mapIndex, zoneIndex = GPS:GetCurrentMapParentZoneIndices()
        store.zoneId = GetZoneId(zoneIndex)

        if isUnderground then
            if not TrySetMapToParentMap() then
                GPS:PopCurrentMap()
                return
            end
            store.entranceMapId = GetCurrentMapId()
            local entranceIndices, entranceCoordinates = GetLocationEntranceIndices(storeIndex, store.entranceMapId, SafeGetMapName())
            store.entranceIndices = entranceIndices

            if not TrySetMapToMapListIndex(mapIndex) then
                GPS:PopCurrentMap()
                return
            end
            local wayshrineIndex, ex, ey = FindNearestWayshrineForEntrances(zoneIndex, entranceCoordinates)
            store.wayshrineIndex = wayshrineIndex
        else
            store.wayshrineIndex = FindNearestWayshrine(zoneIndex, store.x, store.y)
            store.onZoneMap = onZoneMap
        end

        storeList:SetStore(store)
    end

    if not storeList:HasConfirmedKiosk(store, kiosk) then
        storeList:SetConfirmedKiosk(kiosk)
    end

    GPS:PopCurrentMap()
end

function StoreLocationHelper:CalculatePingCoordinates(store, kiosk, isOnStoreMap)
    if not isOnStoreMap and store.entranceIndices and store.entranceMapId == GetCurrentMapId() then
        local x, y = GetMapPlayerPosition(PLAYER_UNIT_TAG)
        if IsCoordinateOutsideCurrentMap(x, y) then
            x, y = GetPOIMapInfo(GetZoneIndex(store.zoneId), store.wayshrineIndex)
        end
        logger:Verbose("return entrance coordinates")
        return FindNearestEntranceCoordinates(store.entranceIndices, x, y)
    elseif not kiosk then
        if isOnStoreMap and (store.locationIndex == 0 or not store:HasValidCoordinates()) then
            logger:Verbose("find and return store location")
            store.locationIndex = FindNearestStoreLocation(0.5, 0.5)
            store.kiosks = GetKioskNamesFromLocationTooltip(store.locationIndex)
            local _, lx, ly = GetMapLocationIcon(store.locationIndex)
            store.x, store.y = GPS:LocalToGlobal(lx, ly)
            store.mapId = GetCurrentMapId()
            self.storeList:SetStore(store)
            return lx, ly
        else
            logger:Verbose("return store coordinates")
            return GPS:GlobalToLocal(store.x, store.y)
        end
    else
        logger:Verbose("return kiosk coordinates")
        return GPS:GlobalToLocal(kiosk.x, kiosk.y)
    end
end

function StoreLocationHelper:ShowKioskOnMap(store, kiosk, secondTry)
    logger:Verbose("ShowKioskOnMap")
    if not store then return end

    if not secondTry then ZO_WorldMap_ShowWorldMap() end

    local isOnStoreMap = TryOpenStoreMap(store)
    local x, y = self:CalculatePingCoordinates(store, kiosk, isOnStoreMap)
    if x == 0 and y == 0 then
        logger:Warn("Could not calculate ping coordinates")
        return
    end

    local expectedMapId = GetCurrentMapId()
    GPS:SetPlayerChoseCurrentMap()
    CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")

    logger:Verbose("Wait for map to settle")
    zo_callLater(function()
        local actualMapId = GetCurrentMapId()
        if expectedMapId == actualMapId then
            logger:Verbose("Focus and ping kiosk")
            panAndZoomManager:PanToNormalizedPosition(x, y)
            pinManager:CreatePin(MAP_PIN_TYPE_AUTO_MAP_NAVIGATION_PING, "pings", x, y)
        else
            logger:Warn("Map has changed during wait time (expected: %d, actual: %d)", expectedMapId, actualMapId)
            if not secondTry then
                self:ShowKioskOnMap(store, kiosk, true)
            end
        end
    end, SHOW_ON_MAP_DELAY)
end
