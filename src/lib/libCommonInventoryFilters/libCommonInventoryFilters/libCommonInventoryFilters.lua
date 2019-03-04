local myNAME, myVERSION = "libCommonInventoryFilters", 1.30
LibCIF = LibCIF or {}
if not LibCIF then return end
local libCIF = LibCIF
libCIF.name     = myNAME
libCIF.version  = myVERSION

local playerInvSearchBox
local craftbagSearchBox
local bankSearchBox
local guildBankSearchBox
local guildBankSearchBoxOld
local backPackDefaultLayout
local backPackMenuBarLayout
local backPackBankLayout
local backPackGuildBankLayout
local backPackTradingHouseLayout
local backPackMailLayout
local backPackPlayerTradeLayout
local backPackStoreLayout
local backPackFenceLayout
local backPackLaunderLayout

local function enableGuildStoreSellFilters()
    local tradingHouseLayout = backPackTradingHouseLayout.layoutData

    if not tradingHouseLayout.hiddenFilters then
        tradingHouseLayout.hiddenFilters = {}
    end
    tradingHouseLayout.hiddenFilters[ITEMFILTERTYPE_QUEST] = true
    tradingHouseLayout.inventoryTopOffsetY = 45
    tradingHouseLayout.sortByOffsetY = 63
    tradingHouseLayout.backpackOffsetY = 96

    local originalFilter = tradingHouseLayout.additionalFilter
    if originalFilter then
        function tradingHouseLayout.additionalFilter(slot)
            return originalFilter(slot) and not IsItemBound(slot.bagId, slot.slotIndex)
        end
    else
        function tradingHouseLayout.additionalFilter(slot)
            return not IsItemBound(slot.bagId, slot.slotIndex)
        end
    end

    local tradingHouseHiddenColumns = { statValue = true, age = true }
    local zorgGetTabFilterInfo = PLAYER_INVENTORY.GetTabFilterInfo

    function PLAYER_INVENTORY:GetTabFilterInfo(inventoryType, tabControl)
        if libCIF._tradingHouseModeEnabled then
            local filterType, activeTabText = zorgGetTabFilterInfo(self, inventoryType, tabControl)
            return filterType, activeTabText, tradingHouseHiddenColumns
        else
            return zorgGetTabFilterInfo(self, inventoryType, tabControl)
        end
    end
end

--if the mouse is enabled, cycle its state to refresh the integrity of the control beneath it
local function SafeUpdateList(object, ...)
    local isMouseVisible = SCENE_MANAGER:IsInUIMode()
    if isMouseVisible then HideMouse() end
    object:UpdateList(...)
    if isMouseVisible then ShowMouse() end
end

local function fixSearchBoxBugs()
    -- http://www.esoui.com/forums/showthread.php?t=4551
    -- search box bug #1: stale searchData after swapping equipment
    SHARED_INVENTORY:RegisterCallback("SlotUpdated",
        function(bagId, slotIndex, slotData)
            if slotData and slotData.searchData then
                slotData.searchData.cached = false
                slotData.searchData.cache = nil
            end
        end)

    -- guild bank search box bug #2: wrong inventory updated
    guildBankSearchBoxOld:SetHandler("OnTextChanged",
        function(editBox)
            ZO_EditDefaultText_OnTextChanged(editBox)
            SafeUpdateList(PLAYER_INVENTORY, INVENTORY_GUILD_BANK)
        end)

    -- bank search box bug for deposit
    INVENTORY_FRAGMENT:RegisterCallback("StateChange",
        function(oldState, newState)
            if libCIF._searchBoxesDisabled then return false end
            if newState == SCENE_FRAGMENT_SHOWN then
                zo_callLater(function()
                    playerInvSearchBox:ClearAnchors()
                    playerInvSearchBox:SetAnchor(BOTTOMRIGHT, nil, TOPRIGHT, -15, -55)
                    playerInvSearchBox:SetHidden(false)
                end, 1) --if not delayed by 1 ms the searchbar will be hidden
            elseif newState == SCENE_FRAGMENT_HIDDEN then
                playerInvSearchBox:SetHidden(true)
            end
        end)

    -- guild bank search box bug #3: wrong search box cleared
    local guildBankScene = SCENE_MANAGER:GetScene("guildBank")
    guildBankScene:RegisterCallback("StateChange",
        function(oldState, newState)
            if newState == SCENE_HIDDEN then
                ZO_PlayerInventory_EndSearch(guildBankSearchBoxOld)
            end
        end)
end


local function showSearchBoxes()
    -- new in 3.2: player inventory fragments set the search bar visible when the layout is applied
    backPackDefaultLayout.layoutData.useSearchBar = true
    backPackMenuBarLayout.layoutData.useSearchBar = true
    backPackMailLayout.layoutData.useSearchBar = true
    backPackPlayerTradeLayout.layoutData.useSearchBar = true
    backPackStoreLayout.layoutData.useSearchBar = true
    backPackFenceLayout.layoutData.useSearchBar = true
    backPackLaunderLayout.layoutData.useSearchBar = true

    -- re-anchoring is necessary because they overlap with sort headers
    playerInvSearchBox:ClearAnchors()
    playerInvSearchBox:SetAnchor(BOTTOMRIGHT, nil, TOPRIGHT, -15, -55)
    playerInvSearchBox:SetHidden(false)

    bankSearchBox:ClearAnchors()
    bankSearchBox:SetAnchor(BOTTOMRIGHT, nil, TOPRIGHT, -15, -55)
    bankSearchBox:SetWidth(playerInvSearchBox:GetWidth())
    bankSearchBox:SetHidden(false)

    guildBankSearchBox:ClearAnchors()
    guildBankSearchBox:SetAnchor(BOTTOMRIGHT, nil, TOPRIGHT, -15, -55)
    guildBankSearchBox:SetWidth(playerInvSearchBox:GetWidth())
    guildBankSearchBox:SetHidden(false)

    craftbagSearchBox:ClearAnchors()
    craftbagSearchBox:SetAnchor(BOTTOMRIGHT, nil, TOPRIGHT, -15, -55)
    craftbagSearchBox:SetWidth(playerInvSearchBox:GetWidth())
    craftbagSearchBox:SetHidden(false)
end

local function onPlayerActivated(eventCode)
    EVENT_MANAGER:UnregisterForEvent(myNAME, eventCode)

    --Controls for the search box anchors
    playerInvSearchBox              = ZO_PlayerInventorySearch
    craftbagSearchBox               = ZO_CraftBagSearch
    bankSearchBox                   = ZO_PlayerBankSearch
    guildBankSearchBox              = ZO_GuildBankSearch
    guildBankSearchBoxOld           = ZO_GuildBankSearchBox
    --Backpack layout of fragments
    backPackDefaultLayout           = BACKPACK_DEFAULT_LAYOUT_FRAGMENT
    backPackMenuBarLayout           = BACKPACK_MENU_BAR_LAYOUT_FRAGMENT
    backPackBankLayout              = BACKPACK_BANK_LAYOUT_FRAGMENT
    backPackGuildBankLayout         = BACKPACK_GUILD_BANK_LAYOUT_FRAGMENT
    backPackTradingHouseLayout      = BACKPACK_TRADING_HOUSE_LAYOUT_FRAGMENT
    backPackMailLayout              = BACKPACK_MAIL_LAYOUT_FRAGMENT
    backPackPlayerTradeLayout       = BACKPACK_PLAYER_TRADE_LAYOUT_FRAGMENT
    backPackStoreLayout             = BACKPACK_STORE_LAYOUT_FRAGMENT
    backPackFenceLayout             = BACKPACK_FENCE_LAYOUT_FRAGMENT
    backPackLaunderLayout           = BACKPACK_LAUNDER_LAYOUT_FRAGMENT
    --Fix the errors in the search boxes
    fixSearchBoxBugs()
    --Show the search boxes
    if not libCIF._searchBoxesDisabled then
        showSearchBoxes()
    end
    --AwesomeGuildStore (and others) flag to disable the search filters at the trading house "inventory fragment"
    if not libCIF._guildStoreSellFiltersDisabled then
        -- note that this sets trading house layout offsets, so it
        -- has to be done before they are shifted
        enableGuildStoreSellFilters()
    end
    --Move the search boxes on their fragment layout
    local shiftY = libCIF._backpackLayoutShiftY
    if shiftY then
        local function doShift(layoutData)
            layoutData.sortByOffsetY = layoutData.sortByOffsetY + shiftY
            layoutData.backpackOffsetY = layoutData.backpackOffsetY + shiftY
        end
        doShift(backPackMenuBarLayout.layoutData)
        doShift(backPackBankLayout.layoutData)
        doShift(backPackTradingHouseLayout.layoutData)
        doShift(backPackMailLayout.layoutData)
        doShift(backPackPlayerTradeLayout.layoutData)
        doShift(backPackStoreLayout.layoutData)
        doShift(backPackFenceLayout.layoutData)
        doShift(backPackLaunderLayout.layoutData)
        doShift(backPackGuildBankLayout.layoutData)
    end

    -- ZO_InventoryManager:SetTradingHouseModeEnabled has been removed in 3.2
    -- from now on we have to listen to the scene state change and do the following:
    --  1) saves/restores the current filter
    --      - or would, if the filter wasn't reset in ApplyBackpackLayout
    --      - this simply doesn't work
    --  2) shows the search box and hides the filters tab, or vice versa
    --      - we want to show or hide them according to add-on requirements
    --        specified during start-up
    local savedPlayerInventorySearchBoxAnchor = {false}
    local savedCraftBagSearchBoxAnchor = {false}

    local layoutData = backPackTradingHouseLayout.layoutData
    local function SetTradingHouseModeEnabled(enabled)
        libCIF._tradingHouseModeEnabled = enabled

        if enabled then
            layoutData.useSearchBar = true
            layoutData.hideTabBar = false
            craftbagSearchBox:SetHidden(false)

            -- move search box if custom sell filters are enabled (AwesomeGuildStore)
            if libCIF._guildStoreSellFiltersDisabled then
                if(not savedPlayerInventorySearchBoxAnchor[1]) then
                    savedPlayerInventorySearchBoxAnchor = {playerInvSearchBox:GetAnchor(0)}
                    playerInvSearchBox:ClearAnchors()
                    playerInvSearchBox:SetAnchor(TOPLEFT, ZO_SharedRightPanelBackground, TOPLEFT, 16, 11)
                end
                if(not savedCraftBagSearchBoxAnchor[1]) then
                    savedCraftBagSearchBoxAnchor = {craftbagSearchBox:GetAnchor(0)}
                    craftbagSearchBox:ClearAnchors()
                    craftbagSearchBox:SetAnchor(BOTTOMLEFT, nil, TOPLEFT, 36, -8)
                end
            end
        else
            layoutData.useSearchBar = libCIF._searchBoxesDisabled
            layoutData.hideTabBar = libCIF._guildStoreSellFiltersDisabled
            craftbagSearchBox:SetHidden(libCIF._searchBoxesDisabled)

            -- restore original search box position (FilterIt)
            if savedPlayerInventorySearchBoxAnchor[1] then
                playerInvSearchBox:ClearAnchors()
                playerInvSearchBox:SetAnchor(unpack(savedPlayerInventorySearchBoxAnchor, 2))
                savedPlayerInventorySearchBoxAnchor[1] = false
            end
            if savedCraftBagSearchBoxAnchor[1] then
                craftbagSearchBox:ClearAnchors()
                craftbagSearchBox:SetAnchor(unpack(savedCraftBagSearchBoxAnchor, 2))
                savedCraftBagSearchBoxAnchor[1] = false
            end
        end
    end
    --Trading house scene change
    local function SceneStateChange(oldState, newState)
        if newState == SCENE_SHOWING then
            SetTradingHouseModeEnabled(true)
        elseif newState == SCENE_HIDING then
            SetTradingHouseModeEnabled(false)
        end
    end
    TRADING_HOUSE_SCENE:RegisterCallback("StateChange",  SceneStateChange)
end

-- shift backpack sort headers and item list down (shiftY > 0) or up (shiftY < 0)
-- add-ons should only call this from their EVENT_ADD_ON_LOADED handler
function libCIF:addBackpackLayoutShiftY(shiftY)
    libCIF._backpackLayoutShiftY = (libCIF._backpackLayoutShiftY or 0) + shiftY
end

-- tell libCIF to skip enabling inventory filters on guild store sell tab
-- add-ons should only call this from their EVENT_ADD_ON_LOADED handler
function libCIF:disableGuildStoreSellFilters()
    libCIF._guildStoreSellFiltersDisabled = true
end

-- tell libCIF to skip showing inventory search boxes outside guild store sell tab
-- add-ons should only call this from their EVENT_ADD_ON_LOADED handler
function libCIF:disableSearchBoxes()
    libCIF._searchBoxesDisabled = true
end

EVENT_MANAGER:UnregisterForEvent(myNAME, EVENT_PLAYER_ACTIVATED)
EVENT_MANAGER:RegisterForEvent(myNAME, EVENT_PLAYER_ACTIVATED, onPlayerActivated)
