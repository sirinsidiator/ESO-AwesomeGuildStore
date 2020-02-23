local AGS = AwesomeGuildStore

local CancelItemActivity = AGS.class.CancelItemActivity
local gettext = AGS.internal.gettext
local RegisterForEvent = AGS.internal.RegisterForEvent
local chat = AGS.internal.chat

local TRADING_HOUSE_SORT_LISTING_NAME = 1
local TRADING_HOUSE_SORT_LISTING_PRICE = 2
local TRADING_HOUSE_SORT_LISTING_TIME = 3
AGS.internal.TRADING_HOUSE_SORT_LISTING_NAME = TRADING_HOUSE_SORT_LISTING_NAME
AGS.internal.TRADING_HOUSE_SORT_LISTING_PRICE = TRADING_HOUSE_SORT_LISTING_PRICE
AGS.internal.TRADING_HOUSE_SORT_LISTING_TIME = TRADING_HOUSE_SORT_LISTING_TIME

local ascSortFunctions = {
    [TRADING_HOUSE_SORT_LISTING_NAME] = function(a, b) return a.data.name < b.data.name end,
    [TRADING_HOUSE_SORT_LISTING_PRICE] = function(a, b) return a.data.purchasePrice < b.data.purchasePrice end,
    [TRADING_HOUSE_SORT_LISTING_TIME] = function(a, b) return a.data.timeRemaining < b.data.timeRemaining end,
}

local descSortFunctions = {
    [TRADING_HOUSE_SORT_LISTING_NAME] = function(a, b) return a.data.name > b.data.name end,
    [TRADING_HOUSE_SORT_LISTING_PRICE] = function(a, b) return a.data.purchasePrice > b.data.purchasePrice end,
    [TRADING_HOUSE_SORT_LISTING_TIME] = function(a, b) return a.data.timeRemaining > b.data.timeRemaining end,
}

local ListingTabWrapper = ZO_Object:Subclass()
AGS.class.ListingTabWrapper = ListingTabWrapper

function ListingTabWrapper:New(saveData)
    local wrapper = ZO_Object.New(self)
    wrapper.saveData = saveData
    return wrapper
end

function ListingTabWrapper:RunInitialSetup(tradingHouseWrapper)
    self.tradingHouseWrapper = tradingHouseWrapper
    self:InitializeListingSortHeaders(tradingHouseWrapper)
    self:InitializeListingCount(tradingHouseWrapper)
    self:InitializeUnitPriceDisplay(tradingHouseWrapper)
    self:InitializeCancelSaleOperation(tradingHouseWrapper)
    self:InitializeRequestListingsOperation(tradingHouseWrapper)
    self:InitializeCancelNotification(tradingHouseWrapper)
    self:InitializeOverallPrice(tradingHouseWrapper)
end

local function PrepareSortHeader(container, name, key)
    local header = container:GetNamedChild(name)
    header.key = key
    header:SetMouseEnabled(true)
end

function ListingTabWrapper:InitializeListingSortHeaders(tradingHouseWrapper)
    local control = ZO_TradingHouse
    local sortHeadersControl = control:GetNamedChild("PostedItemsHeader")
    PrepareSortHeader(sortHeadersControl, "Name", TRADING_HOUSE_SORT_LISTING_NAME)
    PrepareSortHeader(sortHeadersControl, "Price", TRADING_HOUSE_SORT_LISTING_PRICE)
    PrepareSortHeader(sortHeadersControl, "TimeRemaining", TRADING_HOUSE_SORT_LISTING_TIME)

    local sortHeaders = ZO_SortHeaderGroup:New(sortHeadersControl, true)

    self.sortHeadersControl = sortHeadersControl
    self.sortHeaders = sortHeaders

    local function OnSortHeaderClicked(key, order)
        self:ChangeSort(key, order)
    end

    sortHeaders:RegisterCallback(ZO_SortHeaderGroup.HEADER_CLICKED, OnSortHeaderClicked)
    sortHeaders:AddHeadersFromContainer()
    self.currentSortKey = self.saveData.listingSortField
    self.currentSortOrder = self.saveData.listingSortOrder
    sortHeaders:SelectHeaderByKey(self.currentSortKey or TRADING_HOUSE_SORT_LISTING_TIME, ZO_SortHeaderGroup.SUPPRESS_CALLBACKS)
    if(not self.currentSortOrder) then -- call it a second time to invert the sort order
        sortHeaders:SelectHeaderByKey(self.currentSortKey or TRADING_HOUSE_SORT_LISTING_TIME, ZO_SortHeaderGroup.SUPPRESS_CALLBACKS)
    end

    local originalScrollListCommit = ZO_ScrollList_Commit
    local noop = function() end
    tradingHouseWrapper:Wrap("RebuildListingsScrollList", function(originalRebuildListingsScrollList, tradingHouse)
        ZO_ScrollList_Commit = noop
        originalRebuildListingsScrollList(tradingHouse)
        ZO_ScrollList_Commit = originalScrollListCommit
        self:UpdateResultList()
    end)
end

function ListingTabWrapper:InitializeListingCount(tradingHouseWrapper)
    local tradingHouse = tradingHouseWrapper.tradingHouse
    self.listingControl = tradingHouse.currentListings
    self.infoControl = self.listingControl:GetParent()
    self.itemControl = self.infoControl:GetNamedChild("Item")
    self.postedItemsControl = tradingHouse.postedItemsHeader:GetParent()
end

function ListingTabWrapper:InitializeUnitPriceDisplay(tradingHouseWrapper)
    local PER_UNIT_PRICE_CURRENCY_OPTIONS = {
        showTooltips = false,
        iconSide = RIGHT,
    }
    local UNIT_PRICE_FONT = "/esoui/common/fonts/univers67.otf|14|soft-shadow-thin"
    local ITEM_LISTINGS_DATA_TYPE = 2

    local tradingHouse = tradingHouseWrapper.tradingHouse
    local dataType = tradingHouse.postedItemsList.dataTypes[ITEM_LISTINGS_DATA_TYPE]
    local originalSetupCallback = dataType.setupCallback

    dataType.setupCallback = function(rowControl, postedItem)
        originalSetupCallback(rowControl, postedItem)

        local sellPriceControl = rowControl:GetNamedChild("SellPrice")
        local perItemPrice = rowControl:GetNamedChild("SellPricePerItem")
        if(not perItemPrice) then
            local controlName = rowControl:GetName() .. "SellPricePerItem"
            perItemPrice = rowControl:CreateControl(controlName, CT_LABEL)
            perItemPrice:SetAnchor(TOPRIGHT, sellPriceControl, BOTTOMRIGHT, 0, 0)
            perItemPrice:SetFont(UNIT_PRICE_FONT)
        end

        if(postedItem.stackCount > 1) then
            ZO_CurrencyControl_SetSimpleCurrency(perItemPrice, postedItem.currencyType, postedItem.purchasePricePerUnit, PER_UNIT_PRICE_CURRENCY_OPTIONS, nil, false)
            perItemPrice:SetText("@" .. perItemPrice:GetText():gsub("|t.-:.-:", "|t12:12:"))
            perItemPrice:SetHidden(false)
            sellPriceControl:ClearAnchors()
            sellPriceControl:SetAnchor(RIGHT, rowControl, RIGHT, -140, -8)
            perItemPrice = nil
        end

        if(perItemPrice) then
            perItemPrice:SetHidden(true)
            sellPriceControl:ClearAnchors()
            sellPriceControl:SetAnchor(RIGHT, rowControl, RIGHT, -140, 0)
        end
    end
end

function ListingTabWrapper:InitializeCancelSaleOperation(tradingHouseWrapper)
    local activityManager = tradingHouseWrapper.activityManager

    local function DoCancelSale(listingIndex)
        if(activityManager:CancelItem(GetSelectedTradingHouseGuildId(), listingIndex)) then
            self:SetListedItemPending(listingIndex)
        end
    end

    tradingHouseWrapper:Wrap("ShowCancelListingConfirmation", function(originalShowCancelListingConfirmation, self, listingIndex)
        if(IsShiftKeyDown()) then
            DoCancelSale(listingIndex)
        else
            originalShowCancelListingConfirmation(self, listingIndex)
        end
    end)

    -- TODO remove this hack in favor of a better solution
    ZO_PreHook("ZO_Dialogs_RegisterCustomDialog", function(name, info)
        if(name == "CONFIRM_TRADING_HOUSE_CANCEL_LISTING") then
            info.buttons[1].callback = function(dialog)
                DoCancelSale(dialog.listingIndex)
                dialog.listingIndex = nil
            end
        end
    end)

    local originalZO_TradingHouse_CreateListingItemData = ZO_TradingHouse_CreateListingItemData
    ZO_TradingHouse_CreateListingItemData = function(index)
        local result = originalZO_TradingHouse_CreateListingItemData(index)
        if(result) then
            local guildId = GetSelectedTradingHouseGuildId()
            local key = CancelItemActivity.CreateKey(guildId, result.itemUniqueId)
            local operation = activityManager:GetActivity(key)
            if(operation) then
                result.cancelPending = true
            end
            return result
        end
    end

    local AquireLoadingIcon = AGS.class.LoadingIcon.Aquire
    local function SetCancelPending(rowControl, pending)
        local cancelButton = GetControl(rowControl, "CancelSale")
        cancelButton:SetHidden(false)
        if(pending) then
            if(not rowControl.loadingIcon) then
                local loadingIcon = AquireLoadingIcon()
                loadingIcon:SetParent(rowControl)
                loadingIcon:ClearAnchors()
                loadingIcon:SetAnchor(CENTER, cancelButton, CENTER, 0, 0)
                rowControl.loadingIcon = loadingIcon
            end
            cancelButton:SetHidden(true)
            rowControl.loadingIcon:Show()
        elseif(rowControl.loadingIcon) then
            rowControl.loadingIcon:Release()
            rowControl.loadingIcon = nil
        end
    end

    local ITEM_LISTINGS_DATA_TYPE = 2
    local rowType = tradingHouseWrapper.tradingHouse.postedItemsList.dataTypes[ITEM_LISTINGS_DATA_TYPE]
    local originalSetupCallback = rowType.setupCallback
    rowType.setupCallback = function(rowControl, postedItem)
        originalSetupCallback(rowControl, postedItem)
        SetCancelPending(rowControl, postedItem.cancelPending)
    end
end

function ListingTabWrapper:SetListedItemPending(index)
    local list = self.tradingHouseWrapper.tradingHouse.postedItemsList
    local scrollData = ZO_ScrollList_GetDataList(list)
    for i = 1, #scrollData do
        local data = ZO_ScrollList_GetDataEntryData(scrollData[i])
        if(data.slotIndex == index) then
            data.cancelPending = true
            ZO_ScrollList_RefreshVisible(list)
            return
        end
    end
end

function ListingTabWrapper:InitializeRequestListingsOperation(tradingHouseWrapper)
    local activityManager = tradingHouseWrapper.activityManager
    tradingHouseWrapper.tradingHouse.RequestListings = function()
        local guildId = GetSelectedTradingHouseGuildId()
        activityManager:RequestListings(guildId)
    end
end

function ListingTabWrapper:InitializeCancelNotification(tradingHouseWrapper)
    local saveData = self.saveData

    AGS:RegisterCallback(AGS.callback.ITEM_CANCELLED, function(guildId, itemLink, price, stackCount)
        if(not saveData.cancelNotification) then return end

        local guildName = GetGuildName(guildId)
        price = ZO_Currency_FormatPlatform(CURT_MONEY, price, ZO_CURRENCY_FORMAT_AMOUNT_ICON)

        -- TRANSLATORS: chat message when an item listing is cancelled on the listing tab. <<1>> is replaced with the item count, <<t:2>> with the item link, <<3>> with the price and <<4>> with the guild store name. e.g. You have cancelled your listing of 1x [Rosin] for 5000g in Imperial Trading Company
        local cancelMessage = gettext("You have cancelled your listing of <<1>>x <<t:2>> for <<3>> in <<4>>", stackCount, itemLink, price, guildName)
        chat:Print(cancelMessage)
    end)
end

function ListingTabWrapper:InitializeOverallPrice(tradingHouseWrapper)
    local listingPriceSumControl = self.postedItemsControl:CreateControl("AwesomeGuildStoreListingPriceSum", CT_LABEL)
    listingPriceSumControl:SetFont("ZoFontWinH4")
    listingPriceSumControl:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
    listingPriceSumControl:SetAnchor(TOPRIGHT, self.postedItemsControl, TOPRIGHT, -165, -47)
    -- TRANSLATORS: the overall price of all listed items in a store on the listing tab. <<1>> is replaced by the price
    listingPriceSumControl:SetText(gettext("Overall Price: <<1>>", "|cffffff-|r"))
    listingPriceSumControl:SetHidden(true)
    self.listingPriceSumControl = listingPriceSumControl

    tradingHouseWrapper:PreHook("RebuildListingsScrollList", function(tradingHouse)
        self:RefreshListingPriceSumDisplay(tradingHouse)
    end)
end

function ListingTabWrapper:RefreshListingPriceSumDisplay(tradingHouse)
    local sum = 0
    for i = 1, GetNumTradingHouseListings() do
        local _, _, _, _, _, _, price = GetTradingHouseListingItemInfo(i)
        sum = sum + price
    end

    sum = zo_strformat("|cffffff<<1>>|r", ZO_Currency_FormatPlatform(CURT_MONEY, sum, ZO_CURRENCY_FORMAT_AMOUNT_ICON))
    self.listingPriceSumControl:SetText(gettext("Overall Price: <<1>>", sum))
    tradingHouse:UpdateListingCounts()
end

function ListingTabWrapper:ChangeSort(key, order)
    self.currentSortKey = key
    self.currentSortOrder = order
    self.saveData.listingSortField = key
    self.saveData.listingSortOrder = order
    self:UpdateResultList()
end

function ListingTabWrapper:UpdateResultList()
    local list = TRADING_HOUSE.postedItemsList
    local scrollData = ZO_ScrollList_GetDataList(list)
    local sortFunctions = self.currentSortOrder and ascSortFunctions or descSortFunctions
    table.sort(scrollData, sortFunctions[self.currentSortKey or TRADING_HOUSE_SORT_LISTING_TIME])
    ZO_ScrollList_Commit(list)
end

function ListingTabWrapper:OnOpen(tradingHouseWrapper)
    self.listingControl:SetParent(self.postedItemsControl)
    self.listingControl:ClearAnchors()
    self.listingControl:SetAnchor(TOPLEFT, self.postedItemsControl, TOPLEFT, 55, -47)
    self.listingPriceSumControl:SetHidden(false)
    tradingHouseWrapper:SetLoadingOverlayParent(ZO_TradingHousePostedItemsList)
end

function ListingTabWrapper:OnClose(tradingHouseWrapper)
    self.listingControl:SetParent(self.infoControl)
    self.listingControl:ClearAnchors()
    self.listingControl:SetAnchor(TOP, self.itemControl, BOTTOM, 0, 15)
    self.listingPriceSumControl:SetHidden(true)
end
