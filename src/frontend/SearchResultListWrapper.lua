local AGS = AwesomeGuildStore

local ActivityBase = AGS.class.ActivityBase

local SORT_ORDER_ID = AGS.data.SORT_ORDER_ID

local gettext = AGS.internal.gettext


local SILENT = true
local NO_RESELCT = true
local ENABLED_DESATURATION = 0
local DISABLED_DESATURATION = 1

local SEARCH_RESULTS_DATA_TYPE = 1
local GUILD_SPECIFIC_ITEM_DATA_TYPE = 3
local SHOW_MORE_DATA_TYPE = 4 -- watch out for changes in the vanilla UI

local SHOW_MORE_ROW_COLOR = ZO_ColorDef:New("50D35D")
local SHOW_MORE_DEFAULT_ALPHA = 0.5
local SHOW_MORE_HIGHLIGHT_ALPHA = 1
local IGNORE_RESULT_COUNT = true

local PURCHASED_BG_TEXTURE = "EsoUI/Art/Miscellaneous/listItem_highlight.dds"
local PURCHASED_VERTEX_COORDS = {0, 1, 0, 0.625}
local DEFAULT_BG_TEXTURE = "EsoUI/Art/Miscellaneous/listItem_backdrop.dds"
local DEFAULT_VERTEX_COORDS = {0, 1, 0, 0.8125}
local PURCHASED_TEXTURE = "EsoUI/Art/hud/gamepad/gp_radialicon_accept_down.dds"
local SOLDOUT_TEXTURE = "EsoUI/Art/hud/gamepad/gp_radialicon_cancel_down.dds"

local PER_UNIT_PRICE_CURRENCY_OPTIONS = {
    showTooltips = false,
    iconSide = RIGHT,
}

-- TRANSLATORS: Label for the row at the end of the search result list which triggers the search for more results
local SHOW_MORE_READY_LABEL = gettext("Show More Results")
-- TRANSLATORS: Label for the row at the end of the search result list when a search is already pending, but cannot start yet due to the request cooldown
local SHOW_MORE_COOLDOWN_LABEL = gettext("Waiting For Cooldown ...")
-- TRANSLATORS: Label for the row at the end of the search result list when a search is currently in progress
local SHOW_MORE_LOADING_LABEL = gettext("Requesting Results ...")
-- TRANSLATORS: Label for the result count below the search result list. First number indicates the visible results, second number the overall number of locally stored items for the current guild
local ITEM_COUNT_TEMPLATE = gettext("Items:|cffffff %d / %d")

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

function SearchResultListWrapper:Initialize(tradingHouseWrapper, searchManager)
    self.activityManager = tradingHouseWrapper.activityManager

    self:InitializeResultList(tradingHouseWrapper, searchManager)
    self:InitializeShowMoreRow(tradingHouseWrapper, searchManager)
    self:InitializeSortHeaders(tradingHouseWrapper, searchManager)


    local function UpdateResultTimes(rowControl, result) -- TODO move into tooltip
        local lastSeenDelta = GetTimeStamp() - result.lastSeen
        ZO_FormatDurationAgo(lastSeenDelta)
    end
end

function SearchResultListWrapper:InitializeResultList(tradingHouseWrapper, searchManager)
    local tradingHouse = tradingHouseWrapper.tradingHouse
    local itemDatabase = tradingHouseWrapper.itemDatabase
    local sortFilter = searchManager:GetSortFilter()
    local resultCount = tradingHouse.resultCount

    local list = ZO_SortFilterList:New(CreateProxyControl(tradingHouse.searchResultsList))
    list.emptyRow = tradingHouse.searchResultsMessageLabel

    function list:FilterScrollList()
        local scrollData = ZO_ScrollList_GetDataList(self.list)
        ZO_ClearNumericallyIndexedTable(scrollData)

        local searchResults = searchManager:GetSearchResults()
        for i = 1, #searchResults do
            scrollData[i] = searchResults[i]:GetDataEntry()
        end

        if(#searchResults > 0 and searchManager:HasMorePages()) then
            scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(SHOW_MORE_DATA_TYPE, {})
        end

        local guildId = GetSelectedTradingHouseGuildId()
        local items = itemDatabase:GetItemView(guildId):GetItems()
        resultCount:SetHidden(false)
        resultCount:SetText(ITEM_COUNT_TEMPLATE:format(#searchResults, #items))
    end

    function list:SortScrollList() -- TODO should this also happen in the database?
        local scrollData = ZO_ScrollList_GetDataList(self.list)
        sortFilter:SortLocalResults(scrollData)
    end

    local function Noop()
    -- do nothing
    end

    tradingHouse.RebuildSearchResultsPage = Noop
    tradingHouse.ClearSearchResults = Noop
    tradingHouse.OnSearchStateChanged = Noop

    self.list = list

    AGS:RegisterCallback(AGS.callback.SEARCH_RESULT_UPDATE, function(searchResults, hasMore)
        list:RefreshFilters()
    end)

    local function AdjustRowLayout(rowControl)
        local sellPriceControl = rowControl:GetNamedChild("SellPrice")
        sellPriceControl:ClearAnchors()

        local perItemPrice = rowControl:GetNamedChild("SellPricePerUnit")
        perItemPrice:ClearAnchors()
        perItemPrice:SetAnchor(TOPRIGHT, sellPriceControl, BOTTOMRIGHT, 0, 0)

        local nameControl = rowControl:GetNamedChild("Name")
        nameControl:SetWidth(310)
        nameControl:SetMaxLineCount(1)
        nameControl:ClearAnchors()
        nameControl:SetAnchor(LEFT, nil, LEFT, ZO_TRADING_HOUSE_SEARCH_RESULT_ITEM_ICON_MAX_WIDTH, -10)

        rowControl:GetNamedChild("TraitInfo"):SetAnchor(LEFT, nameControl, RIGHT, 0, 10)

        local sellerName = rowControl:CreateControl("$(parent)SellerName", CT_LABEL)
        sellerName:SetAnchor(TOPLEFT, nameControl, BOTTOMLEFT, 10, 0)
        sellerName:SetFont("ZoFontWinT2")
        sellerName:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())

        local timeRemaining = rowControl:GetNamedChild("TimeRemaining")
        timeRemaining:SetAnchor(LEFT, nil, LEFT, 410, 0)

        rowControl.sellPriceControl = sellPriceControl
        rowControl.perItemPrice = perItemPrice
        rowControl.sellerName = sellerName
    end

    local function SetSellerName(rowControl, result)
        -- TRANSLATORS: Seller name label in the search result list
        rowControl.sellerName:SetText(gettext("Seller:|cffffff <<1>>", result.sellerName))
    end

    local searchResultDataType = ZO_ScrollList_GetDataTypeTable(list.list, SEARCH_RESULTS_DATA_TYPE)
    local originalSearchResultSetupCallback = searchResultDataType.setupCallback
    searchResultDataType.setupCallback = function(rowControl, result)
        originalSearchResultSetupCallback(rowControl, result)
        if(not rowControl.__AGS_INIT) then
            AdjustRowLayout(rowControl)
            rowControl.__AGS_INIT = true
        end

        SetSellerName(rowControl, result)

        local perItemPrice = rowControl.perItemPrice
        local sellPriceControl = rowControl.sellPriceControl
        sellPriceControl:ClearAnchors()
        local offset = 0
        local hidden = true
        if(result:GetStackCount() > 1) then
            ZO_CurrencyControl_SetSimpleCurrency(rowControl.perItemPrice, result.currencyType, result.purchasePricePerUnit, PER_UNIT_PRICE_CURRENCY_OPTIONS, nil, tradingHouse.playerMoney[result.currencyType] < result.purchasePrice)
            perItemPrice:SetText("@" .. perItemPrice:GetText():gsub("|t.-:.-:", "|t14:14:"))
            perItemPrice:SetFont("ZoFontWinT2")
            perItemPrice:SetHidden(false)
            offset = -10
            hidden = false
        end
        perItemPrice:SetHidden(hidden)
        sellPriceControl:SetAnchor(RIGHT, rowControl, RIGHT, -5, offset)

        local background = rowControl:GetNamedChild("Bg")
        local timeRemaining = rowControl:GetNamedChild("TimeRemaining")
        if(result.purchased) then
            background:SetTexture(PURCHASED_BG_TEXTURE)
            background:SetTextureCoords(unpack(PURCHASED_VERTEX_COORDS))
            background:SetColor(ZO_ColorDef:New("aa00ff00"):UnpackRGBA())
            timeRemaining:SetText("|c00ff00" .. zo_iconFormatInheritColor(PURCHASED_TEXTURE, 40, 40))
        elseif(result.soldout) then
            background:SetTexture(PURCHASED_BG_TEXTURE)
            background:SetTextureCoords(unpack(PURCHASED_VERTEX_COORDS))
            background:SetColor(ZO_ColorDef:New("aaff0000"):UnpackRGBA())
            timeRemaining:SetText("|cff0000" .. zo_iconFormatInheritColor(SOLDOUT_TEXTURE, 40, 40))
        else
            background:SetColor(1,1,1,1)
            background:SetTexture(DEFAULT_BG_TEXTURE)
            background:SetTextureCoords(unpack(DEFAULT_VERTEX_COORDS))
        end
    end

    local guildItemDataType = ZO_ScrollList_GetDataTypeTable(list.list, GUILD_SPECIFIC_ITEM_DATA_TYPE)
    local originalGuildItemSetupCallback = guildItemDataType.setupCallback
    guildItemDataType.setupCallback = function(rowControl, result)
        originalGuildItemSetupCallback(rowControl, result)
        if(not rowControl.__AGS_INIT) then
            AdjustRowLayout(rowControl)
            rowControl.perItemPrice:SetHidden(true)
            rowControl.sellPriceControl:SetAnchor(RIGHT, rowControl, RIGHT, -5, 0)
            rowControl.__AGS_INIT = true
        end

        SetSellerName(rowControl, result)
    end
end

function SearchResultListWrapper:InitializeShowMoreRow(tradingHouseWrapper, searchManager)
    local tradingHouse = tradingHouseWrapper.tradingHouse

    local function SetupShowMoreRow(rowControl, entry)
        local highlight = rowControl:GetNamedChild("Highlight")
        highlight:SetColor(SHOW_MORE_ROW_COLOR:UnpackRGB())
        highlight:SetAlpha(SHOW_MORE_DEFAULT_ALPHA)

        highlight.animation = ANIMATION_MANAGER:CreateTimelineFromVirtual("ShowOnMouseOverLabelAnimation", highlight)
        local alphaAnimation = highlight.animation:GetFirstAnimation()
        alphaAnimation:SetAlphaValues(SHOW_MORE_DEFAULT_ALPHA, SHOW_MORE_HIGHLIGHT_ALPHA)

        rowControl:SetHandler("OnMouseEnter", function()
            highlight.animation:PlayForward()
        end)

        rowControl:SetHandler("OnMouseExit", function()
            highlight.animation:PlayBackward()
        end)

        rowControl:SetHandler("OnMouseUp", function(control, button, isInside)
            if(rowControl.enabled and button == MOUSE_BUTTON_INDEX_LEFT and isInside) then
                PlaySound("Click")
                if(searchManager:RequestSearch(IGNORE_RESULT_COUNT)) then
                    PlaySound(SOUNDS.TRADING_HOUSE_SEARCH_INITIATED)
                    self:UpdateShowMoreRowState()
                end
            end
        end)

        local label = rowControl:GetNamedChild("Text")
        rowControl.label = label

        rowControl.SetEnabled = function(self, enabled)
            rowControl.enabled = enabled
            highlight.animation:GetFirstAnimation():SetAlphaValues(SHOW_MORE_DEFAULT_ALPHA, enabled and SHOW_MORE_HIGHLIGHT_ALPHA or SHOW_MORE_DEFAULT_ALPHA)
            label:SetColor((enabled and ZO_NORMAL_TEXT or ZO_DEFAULT_DISABLED_COLOR):UnpackRGBA())
        end
    end

    ZO_ScrollList_AddDataType(tradingHouse.searchResultsList, SHOW_MORE_DATA_TYPE, "AwesomeGuildStoreShowMoreRowTemplate", 32, function(rowControl, entry)
        if(not rowControl.label) then
            SetupShowMoreRow(rowControl, entry)
        end
        rowControl.entry = entry
        entry.rowControl = rowControl
        self.showMoreEntry = rowControl
        self:UpdateShowMoreRowState()
    end, nil, nil, function(rowControl)
        self.showMoreEntry = nil
        rowControl.entry.rowControl = nil
        rowControl.entry = nil
        ZO_ObjectPool_DefaultResetControl(rowControl)
    end)

    local searchResultsMessageLabel = tradingHouse.searchResultsMessageLabel
    AGS:RegisterCallback(AGS.callback.CURRENT_ACTIVITY_CHANGED, function(activity)
        if(self.showMoreEntry) then
            self:UpdateShowMoreRowState()
        end

        local hasSearchActivity = false
        if(activity and activity:GetType() == ActivityBase.ACTIVITY_TYPE_REQUEST_SEARCH) then
            hasSearchActivity = true
        else
            local searchActivities = self.activityManager:GetActivitiesByType(ActivityBase.ACTIVITY_TYPE_REQUEST_SEARCH)
            hasSearchActivity = (#searchActivities > 0)
        end

        if(searchManager:GetNumVisibleResults() == 0) then
            searchResultsMessageLabel:SetHidden(false)
            if(hasSearchActivity) then
                searchResultsMessageLabel:SetText(GetString("SI_TRADINGHOUSESEARCHSTATE", TRADING_HOUSE_SEARCH_STATE_WAITING))
            else
                searchResultsMessageLabel:SetText(GetString("SI_TRADINGHOUSESEARCHOUTCOME", TRADING_HOUSE_SEARCH_OUTCOME_NO_RESULTS))
            end
        else
            searchResultsMessageLabel:SetHidden(true)
            searchResultsMessageLabel:SetText("")
        end
    end)
end

function SearchResultListWrapper:InitializeSortHeaders(tradingHouseWrapper, searchManager)
    local tradingHouse = tradingHouseWrapper.tradingHouse
    local sortFilter = searchManager:GetSortFilter()

    local sortHeaderGroup = tradingHouse.searchSortHeaders
    sortHeaderGroup:UnregisterAllCallbacks(ZO_SortHeaderGroup.HEADER_CLICKED)

    tradingHouse.UpdateSortHeaders = function() end -- not needed anymore since we sort locally
    sortHeaderGroup:SetEnabled(true)

    local nameHeader = sortHeaderGroup.headerContainer:GetNamedChild("Name")
    nameHeader:SetWidth(340)
    nameHeader:SetMouseEnabled(true)
    ZO_SortHeader_Initialize(nameHeader, GetString(SI_TRADING_HOUSE_COLUMN_ITEM), SORT_ORDER_ID.ITEM_NAME_ORDER, ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontHeader")
    sortHeaderGroup:AddHeader(nameHeader)

    -- move unit and total price headers close together and put a separator inbetween
    local unitPriceHeader = sortHeaderGroup.headerContainer:GetNamedChild("PricePerUnit")
    local priceHeader = sortHeaderGroup.headerContainer:GetNamedChild("Price")
    priceHeader:ClearAnchors()
    priceHeader:SetAnchor(RIGHT, nil, RIGHT, -30, 0, ANCHOR_CONSTRAINS_X)
    priceHeader:SetAnchor(TOP, nameHeader, TOP, 0, 0, ANCHOR_CONSTRAINS_Y)
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
    unitPriceHeader:SetAnchor(RIGHT, priceHeader, LEFT, -20, 0, ANCHOR_CONSTRAINS_X)
    unitPriceHeader:SetAnchor(TOP, nameHeader, TOP, 0, 0, ANCHOR_CONSTRAINS_Y)
    unitPriceHeader:SetWidth(nil)
    unitPriceHeader:SetResizeToFitDescendents(true)
    local unitPriceHeaderLabel = unitPriceHeader:GetNamedChild("Name")
    unitPriceHeaderLabel:ClearAnchors()
    unitPriceHeaderLabel:SetAnchor(RIGHT)

    -- need to anchor the time remaining header to the unit price header, otherwise it will overlap in Russian
    local timeRemainingHeader = sortHeaderGroup.headerContainer:GetNamedChild("TimeRemaining")
    timeRemainingHeader:ClearAnchors()
    timeRemainingHeader:SetAnchor(RIGHT, unitPriceHeader, LEFT, -20, 0, ANCHOR_CONSTRAINS_X)
    timeRemainingHeader:SetAnchor(TOP, nameHeader, TOP, 0, 0, ANCHOR_CONSTRAINS_Y)

    local customHeader = CreateControlFromVirtual("$(parent)Custom", nameHeader:GetParent(), "ZO_SortHeaderIcon")
    local customHeaderIcon = customHeader:GetNamedChild("Icon")
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

    self.list.sortHeaderGroup = sortHeaderGroup
    self.customHeader = customHeader
    self.customHeaderIcon = customHeaderIcon

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

    AGS:RegisterCallback(AGS.callback.SEARCH_LOCK_STATE_CHANGED, function(search, isActiveSearch)
        if(not isActiveSearch) then return end
        self:SetHeaderEnabled(search:IsEnabled())
    end)

    AGS:RegisterCallback(AGS.callback.SELECTED_SEARCH_CHANGED, function(search)
        self:SetHeaderEnabled(search:IsEnabled())
    end)
end

function SearchResultListWrapper:UpdateShowMoreRowState()
    if(not self.showMoreEntry) then return end
    local showMoreEntry = self.showMoreEntry
    local activityManager = self.activityManager
    -- TODO consolidate into one function together with the keybind strip handler
    local label = showMoreEntry.label
    local activity = activityManager:GetCurrentActivity()
    local text
    local inProgress = true
    if(activity and activity:GetType() == ActivityBase.ACTIVITY_TYPE_REQUEST_SEARCH) then
        text = SHOW_MORE_LOADING_LABEL
    else
        local searchActivities = activityManager:GetActivitiesByType(ActivityBase.ACTIVITY_TYPE_REQUEST_SEARCH)
        if(#searchActivities > 0) then
            text = SHOW_MORE_COOLDOWN_LABEL
        else
            text = SHOW_MORE_READY_LABEL
            inProgress = false
        end
    end
    label:SetText(text)
    showMoreEntry:SetEnabled(not inProgress)
end

function SearchResultListWrapper:RefreshVisible()
    ZO_ScrollList_RefreshVisible(self.list.list)
end

function SearchResultListWrapper:SetHeaderEnabled(enabled)
    self.list.sortHeaderGroup:SetEnabled(enabled)
    self.customHeader:SetMouseEnabled(enabled)
    self.customHeaderIcon:SetDesaturation(enabled and ENABLED_DESATURATION or DISABLED_DESATURATION)
end
