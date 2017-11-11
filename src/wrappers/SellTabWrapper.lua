local gettext = LibStub("LibGetText")("AwesomeGuildStore").gettext
local RegisterForEvent = AwesomeGuildStore.RegisterForEvent
local UnregisterForEvent = AwesomeGuildStore.UnregisterForEvent
local Print = AwesomeGuildStore.Print
local ToggleButton = AwesomeGuildStore.ToggleButton
local ClearCallLater = AwesomeGuildStore.ClearCallLater
local GetItemLinkWritCount = AwesomeGuildStore.GetItemLinkWritCount

local SellTabWrapper = ZO_Object:Subclass()
AwesomeGuildStore.SellTabWrapper = SellTabWrapper

local iconMarkup = string.format("|t%u:%u:%s|t", 16, 16, "EsoUI/Art/currency/currency_gold.dds")
local POST_ITEM_PENDING_UPDATE_NAMESPACE = "AwesomeGuildStorePostPendingItemPendingUpdate"
local SUPPRESS_PRICE_PER_PIECE_UPDATE = true
local SKIP_UPDATE_SLIDER = true
local SLIDER_HEIGHT = 54
local LISTING_INPUT_BUTTON_SIZE = 24
local INVENTORY_BUTTON_SIZE = 64
local FULL_QUANTITY_TEXTURE = "EsoUI/Art/Inventory/inventory_tabIcon_all_%s.dds"
local LAST_SOLD_QUANTITY_TEXTURE = "EsoUI/Art/Campaign/campaign_tabIcon_history_%s.dds"
local DEFAULT_PRICE_TEXTURE = "EsoUI/Art/Bank/bank_tabIcon_gold_%s.dds"
local LAST_SELL_PRICE_TEXTURE = "EsoUI/Art/Campaign/campaign_tabIcon_history_%s.dds"
local AVERAGE_PRICE_TEXTURE = "EsoUI/Art/Guild/tabIcon_roster_%s.dds"
local INVENTORY_TEXTURE = "EsoUI/Art/Inventory/inventory_tabIcon_items_%s.dds"
local CRAFTING_BAG_TEXTURE = "EsoUI/Art/Inventory/inventory_tabIcon_Craftbag_%s.dds"

local function ShowSlider(self)
    self:SetHidden(false)
    self:SetHeight(SLIDER_HEIGHT)
end

local function HideSlider(self)
    self:SetHidden(true)
    self:SetHeight(0)
end

local function SetMinMax(self, minValue, maxValue)
    self.data.min = minValue
    self.data.max = maxValue
    self.minText:SetText(minValue)
    self.maxText:SetText(maxValue)
    self.slider:SetMinMax(minValue, maxValue)
end

local function CreateSlider(container, data, name)
    data.type = "slider"
    data.width = "half"
    data.min = 0
    data.max = 1
    data.autoSelect = true
    data.inputLocation = "right"

    local container = LAMCreateControl.slider(container, data, name)
    container:SetDimensions(203, SLIDER_HEIGHT)
    container.container:SetWidth(190)
    container.slider:SetAnchor(TOPRIGHT, nil, nil, -90)
    container.slidervalueBG:SetWidth(90)

    local slider = container.slider
    slider:SetHeight(16)

    container.Show = ShowSlider
    container.Hide = HideSlider
    container.SetMinMax = SetMinMax

    return container
end

local function MoveItem(sourceBag, sourceSlot, destBag, destSlot, stackCount)
    if IsProtectedFunction("RequestMoveItem") then
        CallSecureProtected("RequestMoveItem", sourceBag, sourceSlot, destBag, destSlot, stackCount)
    else
        RequestMoveItem(sourceBag, sourceSlot, destBag, destSlot, stackCount)
    end
end

local function GetMasterMerchantPrice(itemLink)
    if(not MasterMerchant) then return end

    local itemId = string.match(itemLink, '|H.-:item:(.-):')
    local itemData = MasterMerchant.makeIndexFromLink(itemLink)

    local postedStats = MasterMerchant:toolTipStats(tonumber(itemId), itemData)
    return postedStats.avgPrice
end

local function GetMasterMerchantLastUsedPrice(itemLink)
    if(not MasterMerchant) then return end

    local settings = MasterMerchant:ActiveSettings()
    if(not settings.pricingData) then return end

    local itemId = string.match(itemLink, '|H.-:item:(.-):')
    itemId = tonumber(itemId)
    if(not settings.pricingData[itemId]) then return end

    local itemIndex = MasterMerchant.makeIndexFromLink(itemLink)
    return settings.pricingData[itemId][itemIndex]
end

local hasDifferentQualities = {
    [ITEMTYPE_GLYPH_ARMOR] = true,
    [ITEMTYPE_GLYPH_JEWELRY] = true,
    [ITEMTYPE_GLYPH_WEAPON] = true,
    [ITEMTYPE_DRINK] = true,
    [ITEMTYPE_FOOD] = true,
}

-- itemId is basically what tells us that two items are the same thing,
-- but some types need additional data to determine if they are of the same strength (and value).
local function GetItemIdentifier(itemLink)
    local itemType = GetItemLinkItemType(itemLink)
    local data = {zo_strsplit(":", itemLink:match("|H(.-)|h.-|h"))}
    local itemId = data[3]
    local level = GetItemLinkRequiredLevel(itemLink)
    local cp = GetItemLinkRequiredChampionPoints(itemLink)
    if(itemType == ITEMTYPE_WEAPON or itemType == ITEMTYPE_ARMOR) then
        local trait = GetItemLinkTraitInfo(itemLink)
        return string.format("%s,%s,%d,%d,%d", itemId, data[4], trait, level, cp)
    elseif(itemType == ITEMTYPE_POISON or itemType == ITEMTYPE_POTION) then
        return string.format("%s,%d,%d,%s", itemId, level, cp, data[23])
    elseif(hasDifferentQualities[itemType]) then
        return string.format("%s,%s", itemId, data[4])
    else
        return itemId
    end
end

function SellTabWrapper:New(saveData)
    local wrapper = ZO_Object.New(self)
    wrapper:Initialize(saveData)
    return wrapper
end

function SellTabWrapper:Initialize(saveData)
    self.saveData = saveData
    self:ClearPendingItem()

    self.lastSoldStackCount = saveData.lastSoldStackCount or {}
    saveData.lastSoldStackCount = self.lastSoldStackCount
    self.lastSoldPricePerUnit = saveData.lastSoldPricePerUnit or {}
    saveData.lastSoldPricePerUnit = self.lastSoldPricePerUnit

    if(saveData.disableCustomSellTabFilter) then
        self.customFilterDisabled = true
    else
        self.customFilterDisabled = false
        local libCIF = LibStub:GetLibrary("libCommonInventoryFilters", LibStub.SILENT)
        libCIF:disableGuildStoreSellFilters()
    end
    self.currentInventoryFragment = INVENTORY_FRAGMENT
end

function SellTabWrapper:RunInitialSetup(tradingHouseWrapper)
    self:InitializeQuickListing(tradingHouseWrapper)
    self:InitializeListingInput(tradingHouseWrapper)
    self:InitializeListedNotification(tradingHouseWrapper)
    self:InitializeCraftingBag(tradingHouseWrapper)
end

function SellTabWrapper:InitializeQuickListing(tradingHouseWrapper)
    self.interceptInventoryItemClicks = false

    ZO_PreHook("ZO_InventorySlot_OnSlotClicked", function(inventorySlot, button)
        if(self.interceptInventoryItemClicks and self.saveData.listWithSingleClick and button == 1) then
            ZO_InventorySlot_DoPrimaryAction(inventorySlot)
            return true
        end
    end)
end

function SellTabWrapper:InitializeListingInput(tradingHouseWrapper)
    local tradingHouse = tradingHouseWrapper.tradingHouse
    self.tradingHouse = tradingHouse

    local container = tradingHouse.m_postItems:GetNamedChild("FormInvoice")
    container.data = {} -- required for LAM
    self.sellPriceControl = container:GetNamedChild("SellPrice")

    local quantitySlider = CreateSlider(container, {
        name = zo_strformat(GetString(SI_TRADING_HOUSE_POSTING_QUANTITY)) .. ":",
        getFunc = function() return self.currentStackCount end,
        setFunc = function(value)
            self:SetQuantity(value, SKIP_UPDATE_SLIDER)
        end,
        decimals = 0,
    }, "AwesomeGuildStoreFormInvoiceQuantitySlider")
    quantitySlider:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
    self.quantitySlider = quantitySlider

    -- TRANSLATORS: tooltip text for the quantity selection buttons on the sell tab
    local fullQuantityButtonLabel = gettext("Select Full Quantity")
    local fullQuantityButton = ToggleButton:New(quantitySlider, "$(parent)FullQuantityButton", FULL_QUANTITY_TEXTURE, 0, 0, LISTING_INPUT_BUTTON_SIZE, LISTING_INPUT_BUTTON_SIZE, fullQuantityButtonLabel)
    fullQuantityButton.control:ClearAnchors()
    fullQuantityButton.control:SetAnchor(TOPRIGHT, quantitySlider, TOPRIGHT, 0, 0)
    fullQuantityButton.HandlePress = function(button)
        self:SetQuantity(self.pendingStackCount)
    end

    -- TRANSLATORS: tooltip text for the quantity selection buttons on the sell tab
    local lastSoldQuantityButtonLabel = gettext("Select Last Sold Quantity")
    local lastSoldQuantityButton = ToggleButton:New(quantitySlider, "$(parent)LastSoldQuantityButton", LAST_SOLD_QUANTITY_TEXTURE, 0, 0, LISTING_INPUT_BUTTON_SIZE, LISTING_INPUT_BUTTON_SIZE, lastSoldQuantityButtonLabel)
    lastSoldQuantityButton.control:ClearAnchors()
    lastSoldQuantityButton.control:SetAnchor(RIGHT, fullQuantityButton.control, LEFT, 0, 0)
    lastSoldQuantityButton.HandlePress = function(button)
        local lastSoldQuantity = self.lastSoldStackCount[self.pendingItemIdentifier]
        if(lastSoldQuantity) then
            if(lastSoldQuantity > self.pendingStackCount) then
                lastSoldQuantity = self.pendingStackCount
            end
            self:SetQuantity(lastSoldQuantity)
        end
    end

    local ppuSlider = CreateSlider(container, {
        -- TRANSLATORS: title text for the unit price selection on the sell tab
        name = gettext("Unit Price:"),
        getFunc = function() return tonumber(string.format("%.2f", self.currentPricePerUnit)) end,
        setFunc = function(value) self:SetUnitPrice(value, SKIP_UPDATE_SLIDER) end,
        decimals = 2,
        clampInput = false
    }, "AwesomeGuildStoreFormInvoicePPUSlider")
    ppuSlider:SetAnchor(TOPLEFT, quantitySlider, BOTTOMLEFT, 0, 10)
    self.ppuSlider = ppuSlider

    local buttonContainer = container:CreateControl("AwesomeGuildStoreFormInvoicePriceButtons", CT_CONTROL)
    buttonContainer:SetAnchor(TOPRIGHT, ppuSlider, TOPRIGHT, 0, 0)
    buttonContainer:SetHeight(LISTING_INPUT_BUTTON_SIZE)
    buttonContainer:SetDrawLayer(DL_OVERLAY) -- otherwise it is not in front of the total price label and won't work properly
    buttonContainer:SetDrawLevel(1)
    self.priceButtonContainer = buttonContainer

    -- TRANSLATORS: tooltip text for the unit price selection buttons on the sell tab
    local defaultPriceButtonLabel = gettext("Select Default Price")
    local defaultPriceButton = ToggleButton:New(buttonContainer, "$(parent)DefaultPriceButton", DEFAULT_PRICE_TEXTURE, 0, 0, LISTING_INPUT_BUTTON_SIZE, LISTING_INPUT_BUTTON_SIZE, defaultPriceButtonLabel)
    defaultPriceButton.control:ClearAnchors()
    defaultPriceButton.control:SetAnchor(TOPRIGHT, buttonContainer, TOPRIGHT, 0, 0)
    defaultPriceButton.HandlePress = function(button)
        self:SetUnitPrice(self.pendingSellPrice * 3)
    end

    -- TRANSLATORS: tooltip text for the unit price selection buttons on the sell tab
    local lastSellPriceButtonLabel = gettext("Select Last Sell Price")
    local lastSellPriceButton = ToggleButton:New(buttonContainer, "$(parent)LastSellPriceButton", LAST_SELL_PRICE_TEXTURE, 0, 0, LISTING_INPUT_BUTTON_SIZE, LISTING_INPUT_BUTTON_SIZE, lastSellPriceButtonLabel)
    lastSellPriceButton.control:ClearAnchors()
    lastSellPriceButton.control:SetAnchor(RIGHT, defaultPriceButton.control, LEFT, 0, 0)
    lastSellPriceButton.HandlePress = function(button)
        local lastSoldPricePerUnit = self.lastSoldPricePerUnit[self.pendingItemIdentifier] or GetMasterMerchantLastUsedPrice(self.pendingItemLink)
        if(lastSoldPricePerUnit) then
            self:SetUnitPrice(lastSoldPricePerUnit)
        end
    end

    if(MasterMerchant) then
        -- TRANSLATORS: tooltip text for the unit price selection buttons on the sell tab
        local averagePriceButtonLabel = gettext("Select Master Merchant Price")
        local averagePriceButton = ToggleButton:New(buttonContainer, "$(parent)AveragePriceButton", AVERAGE_PRICE_TEXTURE, 0, 0, LISTING_INPUT_BUTTON_SIZE, LISTING_INPUT_BUTTON_SIZE, averagePriceButtonLabel)
        averagePriceButton.control:ClearAnchors()
        averagePriceButton.control:SetAnchor(RIGHT, lastSellPriceButton.control, LEFT, 0, 0)
        averagePriceButton.HandlePress = function(button)
            local mmPrice = GetMasterMerchantPrice(self.pendingItemLink)
            if(mmPrice) then
                self:SetUnitPrice(mmPrice)
            end
        end
    end

    local priceLabel = tradingHouse.m_postItems:GetNamedChild("FormInvoiceSellPriceLabel")
    priceLabel:ClearAnchors()
    priceLabel:SetAnchor(TOPLEFT, ppuSlider, BOTTOMLEFT, 0, 20)

    local bg = tradingHouse.m_pendingItemBG
    bg:ClearAnchors()
    bg:SetAnchor(TOPRIGHT, tradingHouse.m_postItems, TOPRIGHT, 0, 0)

    local highlight = bg:GetNamedChild("ItemHighlight")
    highlight:ClearAnchors()
    highlight:SetAnchor(TOPRIGHT, bg, TOPRIGHT, 10, -18)

    local invoice = tradingHouse.m_invoice
    local profitLabel = invoice:GetNamedChild("ProfitLabel")
    local profitWarning = CreateControlFromVirtual("$(parent)ProfitWarning", invoice, "ZO_HelpIcon")
    profitWarning:SetAnchor(RIGHT, profitLabel, LEFT, -3, 0)
    profitWarning:SetTexture("EsoUI/Art/Miscellaneous/ESO_Icon_Warning.dds")
    profitWarning:SetHidden(true)
    -- TRANSLATORS: tooltip text for the profit warning icon on the sell tab
    ZO_HelpIcon_Initialize(profitWarning, gettext("Profit is below vendor price. You'll get more out of selling this item to a merchant."), RIGHT)
    self.profitWarning = profitWarning

    tradingHouseWrapper:PreHook("SetPendingPostPrice", function(tradingHouse, gold, skipPricePerPieceUpdate)
        self.currentSellPrice = gold
        if(not skipPricePerPieceUpdate and self.pendingStackCount > 0) then
            self:SetUnitPrice(gold / (self.currentStackCount + 1e-9))
        end
    end)
end

function SellTabWrapper:IsAboveVendorPrice()
    local _, _, currentProfit = GetTradingHousePostPriceInfo(self.currentSellPrice)
    local vendorProfit = self.pendingSellPrice * self.currentStackCount
    return currentProfit >= vendorProfit
end

function SellTabWrapper:InitializeCategoryFilter(tradingHouseWrapper)
    local postItems = tradingHouseWrapper.tradingHouse.m_postItems
    self.salesCategoryFilter = AwesomeGuildStore.SalesCategorySelector:New(postItems, "AwesomeGuildStoreSalesItemCategory")
end

function SellTabWrapper:InitializeCraftingBag(tradingHouseWrapper)
    local tradingHouse = tradingHouseWrapper.tradingHouse

    local container = tradingHouse.m_postItems:CreateControl("AwesomeGuildStoreSellTabButtons", CT_CONTROL)
    container:SetAnchor(BOTTOM, tradingHouse.m_postItems, TOP, 0, 10)
    container:SetDimensions(INVENTORY_BUTTON_SIZE * 2, INVENTORY_BUTTON_SIZE)
    local inventoryButton = ToggleButton:New(container, "$(parent)InventoryButton", INVENTORY_TEXTURE, 0, 0, INVENTORY_BUTTON_SIZE, INVENTORY_BUTTON_SIZE, zo_strformat(GetString(SI_INVENTORY_MENU_INVENTORY)), SOUNDS.MENU_BAR_CLICK)
    local craftbagButton = ToggleButton:New(container, "$(parent)CraftingBagButton", CRAFTING_BAG_TEXTURE, INVENTORY_BUTTON_SIZE, 0, INVENTORY_BUTTON_SIZE, INVENTORY_BUTTON_SIZE, zo_strformat(GetString(SI_GAMEPAD_INVENTORY_CRAFT_BAG_HEADER)), SOUNDS.MENU_BAR_CLICK)
    inventoryButton:Press()
    inventoryButton.HandlePress = function(button)
        if(not button:IsPressed()) then
            craftbagButton:Release(true)
            self:SetCurrentInventory(BAG_BACKPACK)
            return true
        end
    end
    inventoryButton.HandleRelease = function(button, doRelease) return doRelease end
    craftbagButton.HandlePress = function(button)
        if(not button:IsPressed()) then
            inventoryButton:Release(true)
            self:SetCurrentInventory(BAG_VIRTUAL)
            return true
        end
    end
    craftbagButton.HandleRelease = function(button, doRelease) return doRelease end

    local function TryInitiatingItemPost(inventorySlot)
        local bag, slot = ZO_Inventory_GetBagAndIndex(inventorySlot)
        self:SetPendingItemLockColor(ZO_ScrollList_GetData(inventorySlot:GetParent()))
        self:SetPendingItem(bag, slot)
        if(self.pendingStackCount > 0) then
            tradingHouse.m_pendingItemSlot = -1 -- set it to something so the trading house reacts correctly

            local pendingItem = tradingHouse.m_pendingItem
            ZO_Inventory_BindSlot(pendingItem, SLOT_TYPE_TRADING_HOUSE_POST_ITEM, slot, bag)
            self:UpdateListing()
            self.quantitySlider:UpdateValue()
            self.ppuSlider:UpdateValue()
            tradingHouse.m_pendingItemName:SetText(zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemName(bag, slot)))

            tradingHouse.m_pendingItemBG:SetHidden(false)
            tradingHouse.m_invoice:SetHidden(false)

            tradingHouse:SetPendingPostPrice(self.currentSellPrice)

            ZO_InventorySlot_HandleInventoryUpdate(pendingItem)
            ZO_InventorySlot_OnMouseEnter(inventorySlot)
        end
    end

    local oAddSlotAction = ZO_InventorySlotActions.AddSlotAction

    local currentInventorySlot
    ZO_PreHook("ZO_InventorySlot_DiscoverSlotActionsFromActionList", function(inventorySlot, slotActions) currentInventorySlot = inventorySlot end)

    -- prepare AddSlotAction in order to redirect the action
    ZO_InventorySlotActions.AddSlotAction = function(slotActions, actionStringId, actionCallback, actionType, visibilityFunction, options)
        if(actionStringId == SI_ITEM_ACTION_REMOVE_ITEMS_FROM_CRAFT_BAG and TRADING_HOUSE:IsAtTradingHouse()) then
            if(self:IsItemAlreadyBeingPosted(currentInventorySlot)) then
                actionStringId = SI_TRADING_HOUSE_REMOVE_PENDING_POST
                actionCallback = function()
                    self.tradingHouse:ClearPendingPost()
                    ZO_InventorySlot_OnMouseEnter(currentInventorySlot)
                end
            else
                actionStringId = SI_TRADING_HOUSE_ADD_ITEM_TO_LISTING
                actionCallback = function() TryInitiatingItemPost(currentInventorySlot) end
            end
            actionType = "primary"
        end
        return oAddSlotAction(slotActions, actionStringId, actionCallback, actionType, visibilityFunction, options)
    end

    RegisterForEvent(EVENT_TRADING_HOUSE_PENDING_ITEM_UPDATE, function(_, slotId, isPending)
        if(isPending) then
            self:SetPendingItem(BAG_BACKPACK, slotId)
            self:UpdateListing()
            self.quantitySlider:UpdateValue()
            self.ppuSlider:UpdateValue()
            if(self.pendingItemUpdateCallback) then
                self.pendingItemUpdateCallback(slotId)
            end
        end
    end)

    local Promise = LibStub("LibPromises")
    local TEMP_STACK_ERROR_INVALID_SELL_PRICE = 1
    local TEMP_STACK_ERROR_INVENTORY_FULL = 2
    local TEMP_STACK_ERROR_TIMEOUT_ON_SPLIT = 3
    local TEMP_STACK_ERROR_TIMEOUT_ON_SET_PENDING = 4
    local TEMP_STACK_ERROR_SLOT_DID_NOT_UPDATE = 4
    local TEMP_STACK_ERROR_MESSAGE = {}
    -- TRANSLATORS: error message when splitting a stack fails while trying to list an item on a store
    TEMP_STACK_ERROR_MESSAGE[TEMP_STACK_ERROR_INVALID_SELL_PRICE] = gettext("Failed to update listing price")
    TEMP_STACK_ERROR_MESSAGE[TEMP_STACK_ERROR_INVENTORY_FULL] = GetString(SI_INVENTORY_ERROR_INVENTORY_FULL)
    -- TRANSLATORS: error message when splitting a stack fails while trying to list an item on a store
    TEMP_STACK_ERROR_MESSAGE[TEMP_STACK_ERROR_TIMEOUT_ON_SPLIT] = gettext("Failed to split stack")
    -- TRANSLATORS: error message when splitting a stack fails while trying to list an item on a store
    TEMP_STACK_ERROR_MESSAGE[TEMP_STACK_ERROR_TIMEOUT_ON_SET_PENDING] = gettext("Failed to set stack pending")
    -- TRANSLATORS: error message when splitting a stack fails while trying to list an item on a store
    TEMP_STACK_ERROR_MESSAGE[TEMP_STACK_ERROR_SLOT_DID_NOT_UPDATE] = gettext("Failed to update pending slot")
    local TEMP_STACK_WATCHDOG_TIMEOUT = 5000

    local function CreateTempStack()
        local promise = Promise:New()
        if(self.currentSellPrice <= 0) then 
            promise:Reject(TEMP_STACK_ERROR_INVALID_SELL_PRICE)
        elseif(not self.tempSlot) then
            promise:Reject(TEMP_STACK_ERROR_INVENTORY_FULL)
        else
            local eventHandle, timeout

            local function CleanUp()
                UnregisterForEvent(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, eventHandle)
                ClearCallLater(timeout)
            end

            timeout = zo_callLater(function()
                CleanUp()
                promise:Reject(TEMP_STACK_ERROR_TIMEOUT_ON_SPLIT)
            end, TEMP_STACK_WATCHDOG_TIMEOUT)

            eventHandle = RegisterForEvent(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(_, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
                if(bagId == BAG_BACKPACK and slotId == self.tempSlot) then
                    CleanUp()
                    promise:Resolve()
                end
            end)

            MoveItem(self.pendingBagId, self.pendingSlotIndex, BAG_BACKPACK, self.tempSlot, self.currentStackCount)
        end
        return promise
    end

    local function SetTempStackPending()
        local promise = Promise:New()

        local eventHandle, timeout

        local function CleanUp()
            self.pendingItemUpdateCallback = nil
            ClearCallLater(timeout)
        end

        timeout = zo_callLater(function()
            CleanUp()
            promise:Reject(TEMP_STACK_ERROR_TIMEOUT_ON_SET_PENDING)
        end, TEMP_STACK_WATCHDOG_TIMEOUT)

        -- save the current data before it is cleared
        local sellPrice = self.currentSellPrice

        self.pendingItemUpdateCallback = function(slotId)
            CleanUp()
            tradingHouse:SetPendingPostPrice(sellPrice, SUPPRESS_PRICE_PER_PIECE_UPDATE)
            if(self.tempSlot ~= self.pendingSlotIndex) then
                promise:Reject(TEMP_STACK_ERROR_SLOT_DID_NOT_UPDATE)
            else
                promise:Resolve()
            end
        end

        SetPendingItemPost(BAG_BACKPACK, self.tempSlot, self.currentStackCount)
        return promise
    end

    local function UpdateLastSoldData()
        if(IsItemLinkStackable(self.pendingItemLink)) then
            self.lastSoldStackCount[self.pendingItemIdentifier] = self.currentStackCount
        end
        self.lastSoldPricePerUnit[self.pendingItemIdentifier] = self.currentPricePerUnit
    end

    tradingHouseWrapper:Wrap("PostPendingItem", function(originalPostPendingItem, tradingHouse)
        UpdateLastSoldData() -- update regardless of the outcome
        if(self.requiresTempSlot) then
            CreateTempStack():Then(SetTempStackPending):Then(function()
                 -- now we can post the item for real
                tradingHouse:PostPendingItem()
            end, function(error)
                local message = TEMP_STACK_ERROR_MESSAGE[error]
                if(message) then
                    ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, message)
                else
                    PlaySound(SOUNDS.NEGATIVE_CLICK)
                    Print("Could not create temporary stack", error)
                end
            end)
        else
            originalPostPendingItem(tradingHouse)
        end
    end)

    tradingHouseWrapper:PreHook("ClearPendingPost", function(tradingHouse)
        if(self.pendingBagId == BAG_BACKPACK) then SetPendingItemPost(BAG_BACKPACK, 0, 0) end

        self:ClearPendingItemLockColor()
        self:ClearPendingItem()

        tradingHouse.m_pendingItemSlot = nil
    end)
    self.tradingHouse = tradingHouse
end

function SellTabWrapper:ClearPendingItem()
    self.pendingIcon, self.pendingStackCount, self.pendingSellPrice = "", 0, 0
    self.pendingBagId, self.pendingSlotIndex, self.requiresTempSlot = 0, 0, false
    self.currentStackCount, self.currentPricePerUnit, self.currentSellPrice = 0, 0, 0
    self.pendingItemLink, self.pendingItemIdentifier, self.isMasterWrit = "", "", false
end

function SellTabWrapper:IsItemAlreadyBeingPosted(inventorySlot)
    if ZO_InventorySlot_GetType(inventorySlot) == SLOT_TYPE_TRADING_HOUSE_POST_ITEM then
        return self.pendingStackCount > 0
    end

    local bag, slot = ZO_Inventory_GetBagAndIndex(inventorySlot)
    return self.pendingStackCount > 0 and bag == self.pendingBagId and slot == self.pendingSlotIndex
end

function SellTabWrapper:UpdateListing()
    local tradingHouse = self.tradingHouse
    local price = math.ceil(self.currentStackCount * self.currentPricePerUnit)
    ZO_ItemSlot_SetupSlot(tradingHouse.m_pendingItem, self.currentStackCount, self.pendingIcon)
    tradingHouse:SetPendingPostPrice(price, SUPPRESS_PRICE_PER_PIECE_UPDATE)
    self.profitWarning:SetHidden(self:IsAboveVendorPrice())
end

function SellTabWrapper:SetQuantity(value, skipUpdateSlider)
    self.currentStackCount = math.max(1, math.min(self.pendingStackCount, value))
    if(not skipUpdateSlider) then self.quantitySlider:UpdateValue() end
    self:UpdateListing()
    self:UpdateTempSlot()
end

function SellTabWrapper:GetQuantity()
    return self.currentStackCount
end

function SellTabWrapper:SetUnitPrice(value, skipUpdateSlider)
    self.currentPricePerUnit = math.max(0, value)
    if(not skipUpdateSlider) then self.ppuSlider:UpdateValue() end
    self:UpdateListing()
end

function SellTabWrapper:GetUnitPrice()
    return self.currentPricePerUnit
end

function SellTabWrapper:UpdateTempSlot()
    self.requiresTempSlot = (not self.isMasterWrit) and (self.currentStackCount ~= self.pendingStackCount or self.pendingBagId ~= BAG_BACKPACK)
    if(self.requiresTempSlot) then
        self.tempSlot = FindFirstEmptySlotInBag(BAG_BACKPACK)
        if(not self.tempSlot) then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, SI_INVENTORY_ERROR_INVENTORY_FULL)
        end
    end
end

function SellTabWrapper:SetPendingItemLockColor(slot)
    self:ClearPendingItemLockColor()
    slot.locked = true
    if(slot.slotControl) then
        ZO_PlayerInventorySlot_SetupUsableAndLockedColor(slot.slotControl, slot.meetsUsageRequirement, slot.locked)
    end
    self.pendingInventorySlot = slot
end

function SellTabWrapper:ClearPendingItemLockColor()
    if(self.pendingInventorySlot) then
        local slot = self.pendingInventorySlot
        slot.locked = false
        if(slot.slotControl) then
            ZO_PlayerInventorySlot_SetupUsableAndLockedColor(slot.slotControl, slot.meetsUsageRequirement, slot.locked)
        end
        self.pendingInventorySlot = nil
    end
end

local function IsMasterWrit(bagId, slotIndex)
    local itemType = GetItemType(bagId, slotIndex)
    return itemType == ITEMTYPE_MASTER_WRIT
end

function SellTabWrapper:SetPendingItem(bagId, slotIndex)
    local icon, stackCount, sellPrice = GetItemInfo(bagId, slotIndex)
    if(stackCount > 0) then
        local _, maxStackSize = GetSlotStackSize(bagId, slotIndex)
        self.pendingIcon, self.pendingStackCount, self.pendingSellPrice = icon, math.min(maxStackSize, stackCount), sellPrice
        self.pendingBagId, self.pendingSlotIndex = bagId, slotIndex
        self.pendingItemLink = GetItemLink(bagId, slotIndex)
        self.pendingItemIdentifier = GetItemIdentifier(self.pendingItemLink)

        self.isMasterWrit = IsMasterWrit(bagId, slotIndex)
        if(self.isMasterWrit) then
            self.currentStackCount = GetItemLinkWritCount(self.pendingItemLink) * self.pendingStackCount
        else
            self.currentStackCount = self.lastSoldStackCount[self.pendingItemIdentifier] or self.pendingStackCount
            if(self.currentStackCount > self.pendingStackCount) then
                self.currentStackCount = self.pendingStackCount
            end
        end
        self.currentPricePerUnit = self.lastSoldPricePerUnit[self.pendingItemIdentifier]
        if(not self.currentPricePerUnit) then
            self.currentPricePerUnit = GetMasterMerchantLastUsedPrice(self.pendingItemLink) or GetMasterMerchantPrice(self.pendingItemLink) or (sellPrice * 3)
            if(self.isMasterWrit) then
                self.currentPricePerUnit = self.currentPricePerUnit / self.currentStackCount
            end
        end
        self.currentSellPrice = self.currentPricePerUnit * self.currentStackCount

        self:UpdateTempSlot()

        self.ppuSlider:SetMinMax(0, math.max(math.ceil(self.currentPricePerUnit * 3), 100))
        self.priceButtonContainer:ClearAnchors()
        if(self.pendingStackCount > 1) then
            self.quantitySlider:SetMinMax(1, self.pendingStackCount)
            self.quantitySlider:Show()
            self.ppuSlider:Show()
            self.priceButtonContainer:SetAnchor(TOPRIGHT, self.ppuSlider, TOPRIGHT, 0, 0)
        elseif(self.isMasterWrit) then
            self.quantitySlider:Hide()
            self.ppuSlider:Show()
            self.priceButtonContainer:SetAnchor(TOPRIGHT, self.ppuSlider, TOPRIGHT, 0, 0)
        else
            self.quantitySlider:Hide()
            self.ppuSlider:Hide()
            self.priceButtonContainer:SetAnchor(BOTTOMRIGHT, self.sellPriceControl, TOPRIGHT, 0, 0)
        end
    end
end

function SellTabWrapper:InitializeListedNotification(tradingHouseWrapper)
    local saveData = self.saveData
    local listedMessage = ""
    tradingHouseWrapper:Wrap("PostPendingItem", function(originalPostPendingItem, self)
        if(self.m_pendingItemSlot and self.m_pendingSaleIsValid) then
            local count = ZO_InventorySlot_GetStackCount(self.m_pendingItem)
            local price = zo_strformat("<<1>> <<2>>", ZO_CurrencyControl_FormatCurrency(self.m_invoiceSellPrice.sellPrice or 0), iconMarkup)
            local _, guildName = GetCurrentTradingHouseGuildDetails()
            local itemLink = GetItemLink(BAG_BACKPACK, self.m_pendingItemSlot)

            -- TRANSLATORS: chat message when a item is listed on a store. <<1>> is replaced with the item count, <<t:2>> with the item link, <<3>> with the price and <<4>> with the guild store name. e.g. You have listed 1x [Rosin] for 5000g in Imperial Trading Company
            listedMessage = gettext("You have listed <<1>>x <<t:2>> for <<3>> in <<4>>", count, itemLink, price, guildName)
        end
        originalPostPendingItem(self)
    end)

    RegisterForEvent(EVENT_TRADING_HOUSE_RESPONSE_RECEIVED, function(_, responseType, result)
        if(responseType == TRADING_HOUSE_RESULT_POST_PENDING and result == TRADING_HOUSE_RESULT_SUCCESS) then
            self.tradingHouse:ClearPendingPost()
            if(saveData.listedNotification and listedMessage ~= "") then
                Print(listedMessage)
                listedMessage = ""
            end
        end
    end)
end

function SellTabWrapper:SetInterceptInventoryItemClicks(enabled)
    self.interceptInventoryItemClicks = enabled
end

function SellTabWrapper:ResetSalesCategoryFilter()
    if(self.salesCategoryFilter) then
        self.salesCategoryFilter:Reset()
    end
end

function SellTabWrapper:SetCurrentInventory(bagId)
    self.tradingHouse:ClearPendingPost()
    SCENE_MANAGER:RemoveFragment(self.currentInventoryFragment)
    if(bagId == BAG_BACKPACK) then
        self.currentInventoryFragment = INVENTORY_FRAGMENT
        ZO_PlayerInventoryInfoBar:SetParent(ZO_PlayerInventory)
        if(self.salesCategoryFilter) then
            self.salesCategoryFilter:RefreshLayout()
            self.salesCategoryFilter:Show()
        end
    elseif(bagId == BAG_VIRTUAL) then
        self.currentInventoryFragment = CRAFT_BAG_FRAGMENT
        ZO_PlayerInventoryInfoBar:SetParent(ZO_CraftBag)
        if(self.salesCategoryFilter) then
            self.salesCategoryFilter:Hide()
            self.salesCategoryFilter:SetBasicLayout()
        end
    end
    SCENE_MANAGER:AddFragment(self.currentInventoryFragment)
end

function SellTabWrapper:OnOpen(tradingHouseWrapper)
    if(not self.salesCategoryFilter and not self.customFilterDisabled) then
        self:InitializeCategoryFilter(tradingHouseWrapper)
    end
    if(self.salesCategoryFilter) then
        self.salesCategoryFilter:RefreshLayout()
    end
    self.interceptInventoryItemClicks = true
    if(self.currentInventoryFragment == CRAFT_BAG_FRAGMENT) then
        ZO_PlayerInventoryInfoBar:SetParent(ZO_CraftBag)
        SCENE_MANAGER:RemoveFragment(INVENTORY_FRAGMENT)
        SCENE_MANAGER:AddFragment(CRAFT_BAG_FRAGMENT)
    end
end

function SellTabWrapper:OnClose(tradingHouseWrapper)
    self.interceptInventoryItemClicks = false
    if(self.currentInventoryFragment == CRAFT_BAG_FRAGMENT) then
        ZO_PlayerInventoryInfoBar:SetParent(ZO_PlayerInventory)
        SCENE_MANAGER:RemoveFragment(CRAFT_BAG_FRAGMENT)
    end
end
