local L = AwesomeGuildStore.Localization
local RegisterForEvent = AwesomeGuildStore.RegisterForEvent
local UnregisterForEvent = AwesomeGuildStore.UnregisterForEvent
local ToggleButton = AwesomeGuildStore.ToggleButton

local SellTabWrapper = ZO_Object:Subclass()
AwesomeGuildStore.SellTabWrapper = SellTabWrapper

local iconMarkup = string.format("|t%u:%u:%s|t", 16, 16, "EsoUI/Art/currency/currency_gold.dds")
local SUPPRESS_PRICE_PER_PIECE_UPDATE = true

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

function SellTabWrapper:UpdateListing()
    local tradingHouse = self.tradingHouse
    local price = math.ceil(self.currentStackCount * self.currentPricePerUnit)
    ZO_ItemSlot_SetupSlot(tradingHouse.m_pendingItem, self.currentStackCount, self.pendingIcon)
    tradingHouse:SetPendingPostPrice(price, SUPPRESS_PRICE_PER_PIECE_UPDATE)
end

function SellTabWrapper:SetQuantity(value, skipUpdateSlider)
    self.currentStackCount = math.max(1, math.min(self.pendingStackCount, value))
    if(not skipUpdateSlider) then self.quantitySlider:UpdateValue() end
    self:UpdateListing()
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

local SLIDER_HEIGHT = 54

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

    local container = LAMCreateControl.slider(container, data, name)
    container:SetDimensions(203, SLIDER_HEIGHT)
    container.container:SetWidth(190)

    --    slider.minText:SetHidden(true)
    --    slider.maxText:SetHidden(true)

    local slider = container.slider
    slider:SetAnchor(TOPRIGHT, nil, nil, -60)
    slider:SetHeight(16)

    local input = container.slidervalueBG
    input:ClearAnchors()
    input:SetAnchor(LEFT, slider, RIGHT, 5, 0)
    input:SetDimensions(60, 26)

    local inputBox = container.slidervalue
    inputBox:SetFont("ZoFontGameLarge")
    inputBox:SetHandler("OnEnter", function(self)
        self:LoseFocus()
    end)
    inputBox:SetHandler("OnTextChanged", function(self)
        data.setFunc(tonumber(self:GetText()))
        slider:SetValue(data.getFunc())
    end)
    inputBox:SetHandler("OnFocusGained", function(self)
        self:SelectAll()
    end)

    container.Show = ShowSlider
    container.Hide = HideSlider
    container.SetMinMax = SetMinMax

    return container
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
    local data = {zo_strsplit(":", itemLink)}
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

function SellTabWrapper:InitializeListingInput(tradingHouseWrapper)
    local tradingHouse = tradingHouseWrapper.tradingHouse
    self.tradingHouse = tradingHouse
    local container = tradingHouse.m_postItems:GetNamedChild("FormInvoice")
    self.sellPriceControl = container:GetNamedChild("SellPrice")
    container.data = {} -- required for LAM

    local quantitySlider = CreateSlider(container, {
        name = L["SELL_QUANTITY_SLIDER_LABEL"],
        getFunc = function() return self.currentStackCount end,
        setFunc = function(value) self:SetQuantity(value, true) end,
    }, "AwesomeGuildStoreFormInvoiceQuantitySlider")
    quantitySlider:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
    self.quantitySlider = quantitySlider

    local LISTING_INPUT_BUTTON_SIZE = 24
    local FULL_QUANTITY_TEXTURE = "EsoUI/Art/Inventory/inventory_tabIcon_all_%s.dds"
    local LAST_SOLD_QUANTITY_TEXTURE = "EsoUI/Art/Campaign/campaign_tabIcon_history_%s.dds"
    local fullQuantityButton = ToggleButton:New(quantitySlider, "$(parent)FullQuantityButton", FULL_QUANTITY_TEXTURE, 0, 0, LISTING_INPUT_BUTTON_SIZE, LISTING_INPUT_BUTTON_SIZE, L["SELL_FULL_QUANTITY_BUTTON_LABEL"])
    fullQuantityButton.control:ClearAnchors()
    fullQuantityButton.control:SetAnchor(TOPRIGHT, quantitySlider, TOPRIGHT, 0, 0)
    fullQuantityButton.HandlePress = function(button)
        self:SetQuantity(self.pendingStackCount)
    end
    local lastSoldQuantityButton = ToggleButton:New(quantitySlider, "$(parent)LastSoldQuantityButton", LAST_SOLD_QUANTITY_TEXTURE, 0, 0, LISTING_INPUT_BUTTON_SIZE, LISTING_INPUT_BUTTON_SIZE, L["SELL_LAST_QUANTITY_BUTTON_LABEL"])
    lastSoldQuantityButton.control:ClearAnchors()
    lastSoldQuantityButton.control:SetAnchor(RIGHT, fullQuantityButton.control, LEFT, 0, 0)
    lastSoldQuantityButton.HandlePress = function(button)
        local lastSoldQuantity = self.lastSoldStackCount[self.pendingItemIdentifier]
        if(lastSoldQuantity) then
            self:SetQuantity(lastSoldQuantity)
        end
    end

    local ppuSlider = CreateSlider(container, {
        name = L["SELL_PPU_SLIDER_LABEL"],
        getFunc = function() return tonumber(string.format("%.2f", self.currentPricePerUnit)) end,
        setFunc = function(value) self:SetUnitPrice(value, true) end,
        decimals = 2,
    }, "AwesomeGuildStoreFormInvoicePPUSlider")
    ppuSlider:SetAnchor(TOPLEFT, quantitySlider, BOTTOMLEFT, 0, 10)
    self.ppuSlider = ppuSlider

    local DEFAULT_PRICE_TEXTURE = "EsoUI/Art/Bank/bank_tabIcon_gold_%s.dds"
    local LAST_SELL_PRICE_TEXTURE = "EsoUI/Art/Campaign/campaign_tabIcon_history_%s.dds"
    local AVERAGE_PRICE_TEXTURE = "EsoUI/Art/Guild/tabIcon_roster_%s.dds"

    local buttonContainer = container:CreateControl("AwesomeGuildStoreFormInvoicePriceButtons", CT_CONTROL)
    buttonContainer:SetAnchor(TOPRIGHT, ppuSlider, TOPRIGHT, 0, 0)
    buttonContainer:SetHeight(LISTING_INPUT_BUTTON_SIZE)
    buttonContainer:SetDrawLayer(DL_OVERLAY) -- otherwise it is not in front of the total price label and won't work properly
    buttonContainer:SetDrawLevel(1)
    self.priceButtonContainer = buttonContainer

    local defaultPriceButton = ToggleButton:New(buttonContainer, "$(parent)DefaultPriceButton", DEFAULT_PRICE_TEXTURE, 0, 0, LISTING_INPUT_BUTTON_SIZE, LISTING_INPUT_BUTTON_SIZE, L["SELL_DEFAULT_PRICE_BUTTON_LABEL"])
    defaultPriceButton.control:ClearAnchors()
    defaultPriceButton.control:SetAnchor(TOPRIGHT, buttonContainer, TOPRIGHT, 0, 0)
    defaultPriceButton.HandlePress = function(button)
        self:SetUnitPrice(self.pendingSellPrice * 3)
    end
    local lastSellPriceButton = ToggleButton:New(buttonContainer, "$(parent)LastSellPriceButton", LAST_SELL_PRICE_TEXTURE, 0, 0, LISTING_INPUT_BUTTON_SIZE, LISTING_INPUT_BUTTON_SIZE, L["SELL_LAST_PRICE_BUTTON_LABEL"])
    lastSellPriceButton.control:ClearAnchors()
    lastSellPriceButton.control:SetAnchor(RIGHT, defaultPriceButton.control, LEFT, 0, 0)
    lastSellPriceButton.HandlePress = function(button)
        local lastSoldPricePerUnit = self.lastSoldPricePerUnit[self.pendingItemIdentifier] or GetMasterMerchantLastUsedPrice(self.pendingItemLink)
        if(lastSoldPricePerUnit) then
            self:SetUnitPrice(lastSoldPricePerUnit)
        end
    end
    if(MasterMerchant) then
        local averagePriceButton = ToggleButton:New(buttonContainer, "$(parent)AveragePriceButton", AVERAGE_PRICE_TEXTURE, 0, 0, LISTING_INPUT_BUTTON_SIZE, LISTING_INPUT_BUTTON_SIZE, L["SELL_MM_PRICE_BUTTON_LABEL"])
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

    tradingHouseWrapper:PreHook("SetPendingPostPrice", function(tradingHouse, gold, skipPricePerPieceUpdate)
        self.currentSellPrice = gold
        if(not skipPricePerPieceUpdate and self.pendingStackCount > 0) then
            self:SetUnitPrice(gold / (self.currentStackCount + 1e-9))
        end
    end)
end

function SellTabWrapper:InitializeCategoryFilter(tradingHouseWrapper)
    local postItems = tradingHouseWrapper.tradingHouse.m_postItems
    self.salesCategoryFilter = AwesomeGuildStore.SalesCategorySelector:New(postItems, "AwesomeGuildStoreSalesItemCategory")
end

function SellTabWrapper:InitializeCraftingBag(tradingHouseWrapper)
    local tradingHouse = tradingHouseWrapper.tradingHouse

    -- create toggle buttons
    local INVENTORY_TEXTURE = "EsoUI/Art/Inventory/inventory_tabIcon_items_%s.dds"
    local CRAFTING_BAG_TEXTURE = "EsoUI/Art/Inventory/inventory_tabIcon_Craftbag_%s.dds"
    local INVENTORY_BUTTON_SIZE = 64
    local container = tradingHouse.m_postItems:CreateControl("AwesomeGuildStoreSellTabButtons", CT_CONTROL)
    container:SetAnchor(BOTTOM, tradingHouse.m_postItems, TOP, 0, 10)
    container:SetDimensions(INVENTORY_BUTTON_SIZE * 2, INVENTORY_BUTTON_SIZE)
    local inventoryButton = ToggleButton:New(container, "$(parent)InventoryButton", INVENTORY_TEXTURE, 0, 0, INVENTORY_BUTTON_SIZE, INVENTORY_BUTTON_SIZE, L["SELL_SELECT_INVENTORY_LABEL"])
    local craftbagButton = ToggleButton:New(container, "$(parent)CraftingBagButton", CRAFTING_BAG_TEXTURE, INVENTORY_BUTTON_SIZE, 0, INVENTORY_BUTTON_SIZE, INVENTORY_BUTTON_SIZE, L["SELL_SELECT_CRAFTING_BAG_LABEL"])
    inventoryButton:Press()
    inventoryButton.HandlePress = function(button)
        if(not button:IsPressed()) then
            craftbagButton:Release(true)
            self:SetCurrentInventory(BAG_BACKPACK)
            self:ClearPendingItem()
            return true
        end
    end
    inventoryButton.HandleRelease = function(button, doRelease) return doRelease end
    craftbagButton.HandlePress = function(button)
        if(not button:IsPressed()) then
            inventoryButton:Release(true)
            self:SetCurrentInventory(BAG_VIRTUAL)
            self:ClearPendingItem()
            return true
        end
    end
    craftbagButton.HandleRelease = function(button, doRelease) return doRelease end

    local function MoveItem(sourceBag, sourceSlot, destBag, destSlot, stackCount)
        if IsProtectedFunction("RequestMoveItem") then
            CallSecureProtected("RequestMoveItem", sourceBag, sourceSlot, destBag, destSlot, stackCount)
        else
            RequestMoveItem(sourceBag, sourceSlot, destBag, destSlot, stackCount)
        end
    end

    local function IsItemAlreadyBeingPosted(inventorySlot)
        if ZO_InventorySlot_GetType(inventorySlot) == SLOT_TYPE_TRADING_HOUSE_POST_ITEM then
            return self.pendingStackCount > 0
        end

        local bag, slot = ZO_Inventory_GetBagAndIndex(inventorySlot)
        return self.pendingStackCount > 0 and bag == self.pendingBagId and slot == self.pendingSlotIndex
    end

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
            if(IsItemAlreadyBeingPosted(currentInventorySlot)) then
                actionStringId = SI_TRADING_HOUSE_REMOVE_PENDING_POST
                actionCallback = function()
                    self:ClearPendingItem()
                    ZO_InventorySlot_OnMouseEnter(currentInventorySlot)
                end
            else
                actionStringId = SI_TRADING_HOUSE_ADD_ITEM_TO_LISTING
                actionCallback = function() TryInitiatingItemPost(currentInventorySlot) end
            end
            actionType = "primary"
        end
        oAddSlotAction(slotActions, actionStringId, actionCallback, actionType, visibilityFunction, options)
    end

    RegisterForEvent(EVENT_TRADING_HOUSE_PENDING_ITEM_UPDATE, function(_, slotId, isPending)
        if(isPending) then
            self:SetPendingItem(BAG_BACKPACK, slotId)
            self:UpdateListing()
            self.quantitySlider:UpdateValue()
            self.ppuSlider:UpdateValue()
        elseif(self.pendingBagId == BAG_BACKPACK) then
            self:ClearPendingItem()
        end
    end)

    local POST_ITEM_PENDING_UPDATE_NAMESPACE = "AwesomeGuildStorePostPendingItemPendingUpdate"
    tradingHouseWrapper:Wrap("PostPendingItem", function(originalPostPendingItem, tradingHouse)
        if(self.requiresTempSlot) then
            if(self.currentSellPrice <= 0) then return end
            local eventHandle
            eventHandle = RegisterForEvent(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(_, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
                if(bagId == BAG_BACKPACK and slotId == self.tempSlot) then
                    UnregisterForEvent(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, eventHandle)

                    local sellPrice = self.currentSellPrice -- save the current data before it is cleared
                    local pricePerUnit = self.currentPricePerUnit
                    local stackCount = self.currentStackCount
                    EVENT_MANAGER:RegisterForEvent(POST_ITEM_PENDING_UPDATE_NAMESPACE, EVENT_TRADING_HOUSE_PENDING_ITEM_UPDATE, function(_, slotId, isPending)
                        if(isPending) then
                            UnregisterForEvent(EVENT_TRADING_HOUSE_PENDING_ITEM_UPDATE, POST_ITEM_PENDING_UPDATE_NAMESPACE)
                            self.currentPricePerUnit = pricePerUnit -- no updates necessary as it is only used so the lastSold data is updated correctly
                            self.currentStackCount = stackCount
                            tradingHouse:SetPendingPostPrice(sellPrice, SUPPRESS_PRICE_PER_PIECE_UPDATE)
                            tradingHouse:PostPendingItem() -- call everything from the beginning - now with the real item
                        end
                    end)

                    SetPendingItemPost(bagId, slotId, self.currentStackCount)
                end
            end)

            if(self.tempSlot) then
                MoveItem(self.pendingBagId, self.pendingSlotIndex, BAG_BACKPACK, self.tempSlot, self.currentStackCount)
            else
                ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, SI_INVENTORY_ERROR_INVENTORY_FULL)
            end
        else
            if(IsItemLinkStackable(self.pendingItemLink)) then
                self.lastSoldStackCount[self.pendingItemIdentifier] = self.currentStackCount
            end
            self.lastSoldPricePerUnit[self.pendingItemIdentifier] = self.currentPricePerUnit
            originalPostPendingItem(tradingHouse)
        end
    end)

    RegisterForEvent(EVENT_TRADING_HOUSE_RESPONSE_RECEIVED, function(_, responseType, result)
        if(responseType == TRADING_HOUSE_RESULT_POST_PENDING and result == TRADING_HOUSE_RESULT_SUCCESS) then
            self:ClearPendingItem()
        end
    end)

    local lastGuildId
    ZO_PreHook("SelectTradingHouseGuildId", function(guildId)
        if(guildId ~= lastGuildId) then
            self:ClearPendingItem()
            lastGuildId = guildId
        end
    end)
end

function SellTabWrapper:UpdateTempSlot()
    self.requiresTempSlot = (self.currentStackCount ~= self.pendingStackCount or self.pendingBagId ~= BAG_BACKPACK)
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

function SellTabWrapper:SetPendingItem(bagId, slotIndex)
    local icon, stackCount, sellPrice = GetItemInfo(bagId, slotIndex)
    if(stackCount > 0) then
        local _, maxStackSize = GetSlotStackSize(bagId, slotIndex)
        self.pendingIcon, self.pendingStackCount, self.pendingSellPrice = icon, math.min(maxStackSize, stackCount), sellPrice
        self.pendingBagId, self.pendingSlotIndex = bagId, slotIndex
        self.pendingItemLink = GetItemLink(bagId, slotIndex)
        self.pendingItemIdentifier = GetItemIdentifier(self.pendingItemLink)
        self:UpdateTempSlot()

        self.currentStackCount = self.lastSoldStackCount[self.pendingItemIdentifier] or self.pendingStackCount
        self.currentPricePerUnit = self.lastSoldPricePerUnit[self.pendingItemIdentifier] or GetMasterMerchantLastUsedPrice(self.pendingItemLink) or GetMasterMerchantPrice(self.pendingItemLink) or (sellPrice * 3)
        self.currentSellPrice = self.currentPricePerUnit * self.currentStackCount

        self.ppuSlider:SetMinMax(0, math.max(math.ceil(self.currentPricePerUnit * 3), 100))
        self.priceButtonContainer:ClearAnchors()
        if(self.pendingStackCount > 1) then
            self.quantitySlider:SetMinMax(1, self.pendingStackCount)
            self.quantitySlider:Show()
            self.ppuSlider:Show()
            self.priceButtonContainer:SetAnchor(TOPRIGHT, self.ppuSlider, TOPRIGHT, 0, 0)
        else
            self.quantitySlider:Hide()
            self.ppuSlider:Hide()
            self.priceButtonContainer:SetAnchor(BOTTOMRIGHT, self.sellPriceControl, TOPRIGHT, 0, 0)
        end
    end
end

function SellTabWrapper:ClearPendingItem()
    if(self.pendingBagId == BAG_BACKPACK) then SetPendingItemPost(BAG_BACKPACK, 0, 0) end

    self:ClearPendingItemLockColor()

    self.pendingIcon, self.pendingStackCount, self.pendingSellPrice = "", 0, 0
    self.pendingBagId, self.pendingSlotIndex, self.requiresTempSlot = 0, 0, false
    self.currentStackCount, self.currentPricePerUnit, self.currentSellPrice = 0, 0, 0
    self.pendingItemLink, self.pendingItemIdentifier = "", ""

    local tradingHouse = self.tradingHouse
    if(tradingHouse) then
        tradingHouse.m_pendingItemSlot = nil
        tradingHouse:ClearPendingPost()
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

            listedMessage = zo_strformat(L["LISTED_NOTIFICATION"], count, itemLink, price, guildName)
        end
        originalPostPendingItem(self)
    end)

    RegisterForEvent(EVENT_TRADING_HOUSE_RESPONSE_RECEIVED, function(_, responseType, result)
        if(responseType == TRADING_HOUSE_RESULT_POST_PENDING and result == TRADING_HOUSE_RESULT_SUCCESS) then
            if(saveData.listedNotification and listedMessage ~= "") then
                df("[AwesomeGuildStore] %s", listedMessage)
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
