local AGS = AwesomeGuildStore

local ItemData = AwesomeGuildStore.ItemData
local ActivityBase = AwesomeGuildStore.class.ActivityBase

local SORT_ORDER_ID = AGS.data.SORT_ORDER_ID

local gettext = AGS.internal.gettext


local SILENT = true
local NO_RESELCT = true
local SEARCH_RESULTS_DATA_TYPE = 1
local GUILD_SPECIFIC_ITEM_DATA_TYPE = 3
local CAN_UPDATE_RESULT = {
    [SEARCH_RESULTS_DATA_TYPE] = true,
}

local SearchResultListWrapper = ZO_Object:Subclass()
AGS.class.SearchResultListWrapper = SearchResultListWrapper

function SearchResultListWrapper:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

-- the search result list is very old and doesn't follow the expected name scheme
-- in order to use it with ZO_SortFilterList, we create a proxy that takes care of the differences
local function CreateProxyControl(resultList)
    local itemPane =  resultList:GetParent()
    return {
        GetNamedChild = function(self, suffix)
            if(suffix == "List") then
                return resultList
            end
        end,
        SetHandler = function(self, handlerName, handlerFunc) return itemPane:SetHandler(handlerName, handlerFunc) end,
        GetHandler = function(self, handlerName) return itemPane:GetHandler(handlerName) end
    }
end

-- TODO: split up code and make into proper class
function SearchResultListWrapper:Initialize(tradingHouseWrapper, searchManager)
    local itemDatabase = tradingHouseWrapper.itemDatabase
    local tradingHouse = tradingHouseWrapper.tradingHouse
    local resultCount = tradingHouse.resultCount
    local sortFilter = searchManager:GetSortFilter()

    local list = ZO_SortFilterList:New(CreateProxyControl(tradingHouse.searchResultsList))
    list.emptyRow = tradingHouse.noSearchItemsContainer

    local sortHeaderGroup = tradingHouse.searchSortHeaders
    sortHeaderGroup:UnregisterAllCallbacks(ZO_SortHeaderGroup.HEADER_CLICKED)

    tradingHouse.UpdateSortHeaders = function() end -- not needed anymore since we sort locally
    sortHeaderGroup:SetEnabled(true)

    -- move unit and total price headers close together and put a separator inbetween
    local unitPriceHeader = sortHeaderGroup.headerContainer:GetNamedChild("PricePerUnit")
    local priceHeader = sortHeaderGroup.headerContainer:GetNamedChild("Price")
    priceHeader:ClearAnchors()
    priceHeader:SetAnchor(RIGHT, nil, RIGHT, -30)
    priceHeader:SetWidth(nil)
    priceHeader:SetResizeToFitDescendents(true)
    local priceHeaderLabel = priceHeader:GetNamedChild("Name")
    priceHeaderLabel:ClearAnchors()
    priceHeaderLabel:SetAnchor(RIGHT)

    local separator = priceHeader:CreateControl("$(parent)Separator", CT_LABEL)
    separator:SetText("/")
    separator:SetFont("ZoFontHeader")
    separator:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
    separator:SetAnchor(RIGHT, priceHeaderLabel, LEFT, -15)

    unitPriceHeader:ClearAnchors()
    unitPriceHeader:SetAnchor(RIGHT, priceHeader, LEFT, -20)
    unitPriceHeader:SetWidth(nil)
    unitPriceHeader:SetResizeToFitDescendents(true)
    local unitPriceHeaderLabel = unitPriceHeader:GetNamedChild("Name")
    unitPriceHeaderLabel:ClearAnchors()
    unitPriceHeaderLabel:SetAnchor(RIGHT)

    local nameHeader = sortHeaderGroup.headerContainer:GetNamedChild("Name")
    nameHeader:SetWidth(340)
    nameHeader:SetMouseEnabled(true)
    ZO_SortHeader_Initialize(nameHeader, GetString(SI_TRADING_HOUSE_COLUMN_ITEM), SORT_ORDER_ID.ITEM_NAME_ORDER, ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontHeader")
    sortHeaderGroup:AddHeader(nameHeader)

    local customHeader = CreateControlFromVirtual("$(parent)Custom", nameHeader:GetParent(), "ZO_SortHeaderIcon")
    customHeader:SetHidden(true)
    ZO_SortHeader_InitializeArrowHeader(customHeader, "custom", ZO_SORT_ORDER_UP)
    customHeader:SetAnchor(RIGHT, nameHeader, LEFT, -8, 0)
    customHeader:SetDimensions(32, 32)
    sortHeaderGroup:AddHeader(customHeader)

    sortHeaderGroup:ReplaceKey(TRADING_HOUSE_SORT_SALE_PRICE, SORT_ORDER_ID.PURCHASE_PRICE_ORDER)
    sortHeaderGroup:ReplaceKey(TRADING_HOUSE_SORT_SALE_PRICE_PER_UNIT, SORT_ORDER_ID.UNIT_PRICE_ORDER)
    sortHeaderGroup:ReplaceKey(TRADING_HOUSE_SORT_EXPIRY_TIME, SORT_ORDER_ID.TIME_LEFT_ORDER)

    sortHeaderGroup:RegisterCallback(ZO_SortHeaderGroup.HEADER_CLICKED, function(sortOrderId, direction)
        if(sortOrderId == "custom") then
            sortOrderId = sortFilter:GetCurrentSortOrder():GetId()
        end
        sortFilter:SetCurrentSortOrder(sortOrderId, direction)
    end)

    list.sortHeaderGroup = sortHeaderGroup

    AGS:RegisterCallback(AGS.callback.FILTER_VALUE_CHANGED, function(id, sortOrder)
        if(id ~= sortFilter:GetId()) then return end

        local header = sortHeaderGroup:HeaderForKey(sortOrder:GetId())
        if(not header) then
            header = customHeader
            ZO_SortHeader_SetTooltip(customHeader, sortOrder:GetLabel())
            customHeader:SetHidden(false)
        else
            customHeader:SetHidden(true)
        end
        sortHeaderGroup:OnHeaderClicked(header, SILENT, NO_RESELCT, sortOrder:GetDirection())
    end)

    local function UpdateResultTimes(rowControl, result) -- TODO remove
        if(not CAN_UPDATE_RESULT[result.dataEntry.typeId] or result.purchased or result.soldout) then return end

        local lastSeenDelta = GetTimeStamp() - result.lastSeen

        local timeRemaining = rowControl:GetNamedChild("TimeRemaining")
        timeRemaining:SetText(zo_strformat(SI_TRADING_HOUSE_BROWSE_ITEM_REMAINING_TIME, ZO_FormatTime(math.max(0, result.timeRemaining - lastSeenDelta), TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT_DESCRIPTIVE, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)))

--        local lastSeen = rowControl:GetNamedChild("LastSeen")
--        lastSeen:SetText(ZO_FormatDurationAgo(lastSeenDelta))
    end

--    function list:RefreshVisible()
--        ZO_ScrollList_RefreshVisible(self.list, nil, UpdateResultTimes)
--    end
--
--    list:SetUpdateInterval(10) -- seconds

    local filters = searchManager:GetActiveFilters()
    local activeFilters, numActiveFilters = {}, 0
    local function BeforeRebuildSearchResultsPage()
        numActiveFilters = 0
        for i = 1, #filters do
            local filter = filters[i]
            if(filter:BeforeRebuildSearchResultsPage(tradingHouseWrapper)) then
                numActiveFilters = numActiveFilters + 1
                activeFilters[numActiveFilters] = filter
            end
        end
        -- TODO: sort activeFilters by resource cost -> cheap filters come first
        return (numActiveFilters > 0)
    end

    local function AfterRebuildSearchResultsPage()
        for _, filter in pairs(filters) do
            filter:AfterRebuildSearchResultsPage(tradingHouseWrapper)
        end
    end

    local function FilterPageResult(result)
        if(not result or result.name == "" or result.stackCount == 0) then return false end
        for i = 1, numActiveFilters do
            if(not activeFilters[i]:FilterPageResult(result)) then
                return true
            end
        end
        return false
    end

    local guildSpecificItems = {}
    tradingHouseWrapper:PreHook("AddGuildSpecificItems", function() -- TODO: item database should handle them too - cycle through all guilds once on open
        ZO_ClearNumericallyIndexedTable(guildSpecificItems)
        local guildId = GetSelectedTradingHouseGuildId()
        if(guildId and guildId > 0) then
            local guildName = GetGuildName(guildId)
            for i = 1, GetNumGuildSpecificItems() do
                local item = ItemData:New(i, guildName)
                item:UpdateFromGuildSpecificItem(i)
                guildSpecificItems[#guildSpecificItems + 1] = item
            end
        end
        return true
    end)

    local function AddResultIfNecessary(scrollData, item, type, isFiltering)
        if(not isFiltering or not FilterPageResult(item)) then
            scrollData[#scrollData + 1] = item:GetDataEntry(type)
        end
    end

    -- TODO move
    local showMoreEntry
    local inProgress = false
    local searchManager = tradingHouseWrapper.searchTab.searchManager
    local activityManager = tradingHouseWrapper.activityManager
    local SHOW_MORE_DATA_TYPE = 4 -- watch out for changes in tradinghouse.lua
    ZO_ScrollList_AddDataType(tradingHouse.searchResultsList, SHOW_MORE_DATA_TYPE, "AwesomeGuildStoreShowMoreRowTemplate", 32, function(rowControl, entry)
        d("Setup Show More Row")
        
        local label = rowControl:GetNamedChild("Text")
        label:SetText(entry.label)
        rowControl.label = label

        local highlight = rowControl:GetNamedChild("Highlight")
        if(entry.color) then
            highlight:SetColor(entry.color:UnpackRGB())
            highlight:SetAlpha(0.5)
        end

        if not highlight.animation then
            highlight.animation = ANIMATION_MANAGER:CreateTimelineFromVirtual("ShowOnMouseOverLabelAnimation", highlight)
            local alphaAnimation = highlight.animation:GetFirstAnimation()
            alphaAnimation:SetAlphaValues(0.5, 1)
        end

        rowControl:SetHandler("OnMouseEnter", function()
            highlight.animation:PlayForward()
        end)

        rowControl:SetHandler("OnMouseExit", function()
            highlight.animation:PlayBackward()
        end)

        rowControl:SetHandler("OnMouseUp", function(control, button, isInside)
            if(rowControl.enabled and button == 1 and isInside) then
                PlaySound("Click")
                rowControl:SetEnabled(false)
                if(searchManager:RequestSearch(true)) then
                    label:SetText("waiting for cooldown ...") -- TODO
                else
                    list:RefreshFilters()
                end
            end
        end)

        rowControl.SetEnabled = function(self, enabled)
            rowControl.enabled = enabled
            highlight.animation:GetFirstAnimation():SetAlphaValues(0.5, enabled and 1 or 0.5)
            label:SetColor((enabled and ZO_NORMAL_TEXT or ZO_DEFAULT_DISABLED_COLOR):UnpackRGBA())
        end

        local activity = activityManager:GetCurrentActivity()
        if(activity and activity:GetType() == ActivityBase.ACTIVITY_TYPE_REQUEST_SEARCH) then
            inProgress = true
            label:SetText("loading results ...") -- TODO
        else
            local searchActivities = activityManager:GetActivitiesByType(ActivityBase.ACTIVITY_TYPE_REQUEST_SEARCH)
            if(#searchActivities > 0) then
                inProgress = true
                label:SetText("waiting for cooldown ...") -- TODO
            else
                inProgress = false
            end
        end
        rowControl:SetEnabled(not inProgress)

        rowControl.entry = entry
        entry.rowControl = rowControl
        showMoreEntry = rowControl
    end, nil, nil, function(rowControl)
        d("Cleanup Show More Row")
        showMoreEntry = nil
        rowControl.enabled = nil
        rowControl.label = nil
        rowControl.SetEnabled = nil
        rowControl.entry.rowControl = nil
        rowControl.entry = nil
        ZO_ObjectPool_DefaultResetControl(rowControl)
    end)

    AGS:RegisterCallback(AGS.callback.CURRENT_ACTIVITY_CHANGED, function(activity)
        if(showMoreEntry) then
            if(activity and activity:GetType() == ActivityBase.ACTIVITY_TYPE_REQUEST_SEARCH) then
                inProgress = true
                showMoreEntry.label:SetText("loading results ...") -- TODO
            elseif(inProgress and not activity) then
                inProgress = false
                showMoreEntry.label:SetText(showMoreEntry.entry.label)
            end
            showMoreEntry:SetEnabled(not inProgress)
        end
    end)

    local showNextPageEntry =  { -- TODO move into setup since we only have one entry now
        -- TRANSLATORS: Label for the row at the end of the search results which toggles the search of the next page
        label = gettext("Show More Results"),
        color = ZO_ColorDef:New("50D35D")
    }

    function list:FilterScrollList()
        local scrollData = ZO_ScrollList_GetDataList(self.list)
        ZO_ClearNumericallyIndexedTable(scrollData)

        local searchResults = searchManager:GetSearchResults()
        for i = 1, #searchResults do
            scrollData[i] = searchResults[i]:GetDataEntry(SEARCH_RESULTS_DATA_TYPE)
        end

        if(searchManager:HasMorePages()) then
            scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(SHOW_MORE_DATA_TYPE, showNextPageEntry)
        end

        local guildName = select(2, GetCurrentTradingHouseGuildDetails())
        local items = itemDatabase:GetItemView(guildName):GetItems()
        resultCount:SetHidden(false)
        resultCount:SetText(gettext("Items:|cffffff %d / %d"):format(#searchResults, #items))
    end

    function list:SortScrollList() -- TODO should this also happen in the database?
        local scrollData = ZO_ScrollList_GetDataList(self.list)
        sortFilter:SortLocalResults(scrollData)
    end

    local function DoRefreshResults()
        --list:RefreshFilters()
    end

    tradingHouse.RebuildSearchResultsPage = DoRefreshResults -- TODO noop
    tradingHouse.ClearSearchResults = DoRefreshResults -- TODO noop
--    AGS:RegisterCallback(AGS.callback.FILTER_UPDATE, DoRefreshResults)
--    AGS:RegisterCallback(AGS.callback.ITEM_DATABASE_UPDATE, DoRefreshResults)
    AGS:RegisterCallback(AGS.callback.SEARCH_RESULT_UPDATE, function(searchResults, hasMore)
        list:RefreshFilters()
    end)

    self.list = list
end

function SearchResultListWrapper:RefreshVisible()
    ZO_ScrollList_RefreshVisible(self.list.list)
end
