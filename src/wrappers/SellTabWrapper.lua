local AGS = AwesomeGuildStore

local gettext = AGS.internal.gettext
local RegisterForEvent = AGS.internal.RegisterForEvent
local UnregisterForEvent = AGS.internal.UnregisterForEvent
local chat = AGS.internal.chat
local ToggleButton = AGS.class.ToggleButton
local GetItemLinkWritCount = AGS.internal.GetItemLinkWritCount

local SellTabWrapper = ZO_Object:Subclass()
AGS.class.SellTabWrapper = SellTabWrapper

local POST_ITEM_PENDING_UPDATE_NAMESPACE = "AwesomeGuildStorePostPendingItemPendingUpdate"
local SUPPRESS_PRICE_PER_PIECE_UPDATE = true
local SKIP_UPDATE_SLIDER = true
local SKIP_MOUSE_ENTER = true
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

local function GetMasterMerchantPrice(itemLink)
    if(not MasterMerchant) then return end

    local postedStats = MasterMerchant:itemStats(itemLink, false)
    return postedStats.avgPrice
end

local function GetMasterMerchantLastUsedPrice(itemLink)
    if(not MasterMerchant) then return end

    local settings = MasterMerchant:ActiveSettings()
    if(not settings.pricingData) then return end

    local itemId = GetItemLinkItemId(itemLink)
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
    self.isOpen = false
    self:ClearPendingItem()

    self.lastSoldStackCount = saveData.lastSoldStackCount or {}
    saveData.lastSoldStackCount = self.lastSoldStackCount
    self.lastSoldPricePerUnit = saveData.lastSoldPricePerUnit or {}
    saveData.lastSoldPricePerUnit = self.lastSoldPricePerUnit

    self.currentInventoryFragment = INVENTORY_FRAGMENT
end

function SellTabWrapper:RunInitialSetup(tradingHouseWrapper)
    self:InitializeQuickListing(tradingHouseWrapper)
    self:InitializeListingInput(tradingHouseWrapper)
    self:InitializeListedNotification(tradingHouseWrapper)
    self:InitializeCraftingBag(tradingHouseWrapper)
end

function SellTabWrapper:InitializeQuickListing(tradingHouseWrapper)
    ZO_PreHook("ZO_InventorySlot_OnSlotClicked", function(inventorySlot, button)
        if(self.isOpen and self.saveData.listWithSingleClick and button == MOUSE_BUTTON_INDEX_LEFT and not self.suppressNextClick) then
            ZO_InventorySlot_DoPrimaryAction(inventorySlot)
            return true
        end
    end)
    RegisterForEvent(EVENT_GLOBAL_MOUSE_UP, function()
        self.suppressNextClick = false
    end)
end

function SellTabWrapper:InitializeListingInput(tradingHouseWrapper)
    local tradingHouse = tradingHouseWrapper.tradingHouse
    self.tradingHouse = tradingHouse

    local postItemPane = tradingHouse.postItemPane
    postItemPane:SetWidth(250)
    postItemPane:GetNamedChild("Form"):SetHeight(160)

    local listingFeeLabel = tradingHouse.invoice:GetNamedChild("ListingFeeLabel")
    tradingHouse.invoiceListingFee:ClearAnchors()
    tradingHouse.invoiceListingFee:SetAnchor(RIGHT, listingFeeLabel, RIGHT)
    local theirCutLabel = tradingHouse.invoice:GetNamedChild("TheirCutLabel")
    local listingFeeHelp = tradingHouse.invoice:GetNamedChild("ListingFeeHelp")
    theirCutLabel:SetAnchor(TOPLEFT, listingFeeLabel, BOTTOMLEFT, 0, 10)
    tradingHouse.invoiceTheirCut:ClearAnchors()
    tradingHouse.invoiceTheirCut:SetAnchor(RIGHT, theirCutLabel, RIGHT)
    local divider = tradingHouse.invoice:GetNamedChild("Divider")
    local theirCutHelp = tradingHouse.invoice:GetNamedChild("TheirCutHelp")
    theirCutHelp:SetAnchor(TOPLEFT, listingFeeHelp, BOTTOMLEFT, 0, 0)
    divider:SetAnchor(TOPLEFT, theirCutHelp, BOTTOMLEFT, -10, 0)
    local profitLabel = tradingHouse.invoice:GetNamedChild("ProfitLabel")
    profitLabel:SetAnchor(TOPLEFT, theirCutLabel, BOTTOMLEFT, 0, 10)
    tradingHouse.invoiceProfit:ClearAnchors()
    tradingHouse.invoiceProfit:SetAnchor(RIGHT, profitLabel, RIGHT)

    local container = tradingHouse.invoice
    container.data = {} -- required for LAM
    self.sellPriceControl = container:GetNamedChild("SellPrice")

    self.maxRepetitions = 0
    local repetitionSlider = CreateSlider(container, {
        -- TRANSLATORS: the label for the listing repetition slider on the sell tab
        name = gettext("Listings:"),
        getFunc = function() return self.currentRepetitions end,
        setFunc = function(value)
            self.currentRepetitions = value
        end,
        disabled = function()
            return self.maxRepetitions <= 1
        end,
        decimals = 0,
    }, "AwesomeGuildStoreFormInvoiceRepetitionSlider")
    repetitionSlider:SetAnchor(TOP, profitLabel, BOTTOM, 0, 20, ANCHOR_CONSTRAINS_Y)
    repetitionSlider:SetAnchor(LEFT, container, LEFT, 0, 0, ANCHOR_CONSTRAINS_X)
    self.repetitionSlider = repetitionSlider

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
        else
            lastSoldQuantity = 1
        end
        self:SetQuantity(lastSoldQuantity)
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

    local priceLabel = container:GetNamedChild("SellPriceLabel")
    priceLabel:ClearAnchors()
    priceLabel:SetAnchor(TOPLEFT, ppuSlider, BOTTOMLEFT, 0, 20)

    local bg = tradingHouse.pendingItemBG
    bg:ClearAnchors()
    bg:SetAnchor(TOPRIGHT, postItemPane, TOPRIGHT, 0, 0)

    local highlight = bg:GetNamedChild("ItemHighlight")
    highlight:ClearAnchors()
    highlight:SetAnchor(TOPRIGHT, bg, TOPRIGHT, 10, -18)

    local invoice = tradingHouse.invoice
    local profitLabel = tradingHouse.invoiceProfit
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

    tradingHouseWrapper:PreHook("OnPendingPostItemUpdated", function(tradingHouse, slotId, isPending)
        if(isPending) then
            tradingHouse:UpdateListingCounts()
            return true -- we handle that case ourselves
        end
    end)
end

function SellTabWrapper:IsAboveVendorPrice()
    local _, _, currentProfit = GetTradingHousePostPriceInfo(self.currentSellPrice)
    local vendorProfit = self.pendingSellPrice * self.currentStackCount
    return currentProfit >= vendorProfit
end

function SellTabWrapper:InitializeCraftingBag(tradingHouseWrapper)
    local tradingHouse = tradingHouseWrapper.tradingHouse
    local postItemPane = tradingHouse.postItemPane

    local container = postItemPane:CreateControl("AwesomeGuildStoreSellTabButtons", CT_CONTROL)
    container:SetAnchor(BOTTOM, postItemPane, TOP, 0, 10)
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

    local function TryInitiatingItemPost(bag, index)
        self:UnsetPendingItem()

        PLAYER_INVENTORY:OnInventorySlotLocked(bag, index)
        self:SetPendingItem(bag, index)
        if(self.pendingStackCount > 0) then
            tradingHouse.pendingSaleIsValid = false
            tradingHouse.pendingItemSlot = -1 -- set it to something so the trading house reacts correctly

            local pendingItem = tradingHouse.pendingItem
            ZO_Inventory_BindSlot(pendingItem, SLOT_TYPE_TRADING_HOUSE_POST_ITEM, index, bag)
            self:UpdateListing()
            self.repetitionSlider:UpdateValue()
            self.ppuSlider:UpdateValue()
            tradingHouse.pendingItemName:SetText(zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemName(bag, index)))

            tradingHouse.pendingItemBG:SetHidden(false)
            tradingHouse.invoice:SetHidden(false)

            tradingHouse:SetPendingPostPrice(self.currentSellPrice)

            ZO_InventorySlot_HandleInventoryUpdate(pendingItem)
        end
    end

    -- hide the original context menu entries for adding and removing posts
    local suppressAction = true
    ZO_PreHook(ZO_InventorySlotActions, "AddSlotAction", function(self, labelId, callback)
        if(suppressAction and (labelId == SI_TRADING_HOUSE_ADD_ITEM_TO_LISTING or labelId == SI_TRADING_HOUSE_REMOVE_PENDING_POST)) then
            return true
        end
    end)

    -- instead add our own actions
    local function UpdateSlotActions(inventorySlot, slotActions)
        if(self.isOpen) then
            suppressAction = false
            if(self:IsItemAlreadyBeingPosted(inventorySlot)) then
                slotActions:AddCustomSlotAction(SI_TRADING_HOUSE_REMOVE_PENDING_POST, function()
                    self:UnsetPendingItem()
                    ZO_InventorySlot_OnMouseEnter(inventorySlot)
                end, "primary")
            elseif(inventorySlot.slotType ~= SLOT_TYPE_TRADING_HOUSE_POST_ITEM) then
                slotActions:AddCustomSlotAction(SI_TRADING_HOUSE_ADD_ITEM_TO_LISTING, function()
                    local bag, index = ZO_Inventory_GetBagAndIndex(inventorySlot)
                    TryInitiatingItemPost(bag, index)
                    ZO_InventorySlot_OnMouseEnter(inventorySlot)
                end, "primary")
            end

            if self.currentInventoryFragment == CRAFT_BAG_FRAGMENT then
                slotActions:AddCustomSlotAction(SI_TRADING_HOUSE_SEARCH_FROM_ITEM, function()
                    local bag, index = ZO_Inventory_GetBagAndIndex(inventorySlot)
                    local itemLink = GetItemLink(bag, index)
                    tradingHouse:SearchForItemLink(itemLink)
                end, "secondary")
            end
            suppressAction = true
        end
        return false
    end

    local LCM = LibCustomMenu
    LCM:RegisterContextMenu(UpdateSlotActions, LCM.CATEGORY_EARLY)
    LCM:RegisterKeyStripEnter(UpdateSlotActions, LCM.CATEGORY_EARLY)

    local function UpdateLastSoldData()
        if(IsItemLinkStackable(self.pendingItemLink)) then
            self.lastSoldStackCount[self.pendingItemIdentifier] = self.currentStackCount
        end
        self.lastSoldPricePerUnit[self.pendingItemIdentifier] = self.currentPricePerUnit
    end

    local activityManager = tradingHouseWrapper.activityManager

    -- we completely replace the original function with our own
    tradingHouse.PostPendingItem = function(tradingHouse)
        if(tradingHouse.pendingItemSlot and tradingHouse.pendingSaleIsValid) then
            UpdateLastSoldData() -- update regardless of the outcome
            local guildId = GetSelectedTradingHouseGuildId()
            local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(tradingHouse.pendingItem)

            for i = 1, self.currentRepetitions do
                activityManager:PostItem(guildId, bagId, slotIndex, self.currentStackCount, self.currentSellPrice)
            end
        end
    end

    tradingHouseWrapper:PreHook("ClearPendingPost", function(tradingHouse)
        self:ClearPendingItem()
    end)
    self.tradingHouse = tradingHouse

    local function HandleReceivedDrag(control, button)
        if(button == MOUSE_BUTTON_INDEX_LEFT) then
            ZO_InventorySlot_OnReceiveDrag(TRADING_HOUSE.pendingItem)
        end
    end
    postItemPane:SetMouseEnabled(true)
    postItemPane:SetHandler("OnReceiveDrag", HandleReceivedDrag)
    postItemPane:SetHandler("OnMouseUp", HandleReceivedDrag)
    tradingHouse.pendingItem:SetHandler("OnMouseUp", HandleReceivedDrag)

    -- this hack prevents the lock from disappearing when dragging an item from the regular inventory
    self.suppressNextInventorySlotEvent = false
    local function HandleSlotEvent()
        if(self.suppressNextInventorySlotEvent) then
            self.suppressNextInventorySlotEvent = false
            return true
        end
    end

    ZO_PreHook(PLAYER_INVENTORY, "OnInventorySlotLocked", HandleSlotEvent)
    ZO_PreHook(PLAYER_INVENTORY, "OnInventorySlotUnlocked", HandleSlotEvent)

    ZO_PreHook("ZO_InventorySlot_OnDragStart", function(inventorySlot)
        if(self.isOpen and GetCursorContentType() == MOUSE_CONTENT_EMPTY) then
            local inventorySlotButton = ZO_InventorySlot_GetInventorySlotComponents(inventorySlot)
            if(ZO_InventorySlot_GetStackCount(inventorySlotButton) > 0) then
                local bag, index = ZO_Inventory_GetBagAndIndex(inventorySlotButton)
                PLAYER_INVENTORY:OnInventorySlotLocked(bag, index)

                self.suppressNextInventorySlotEvent = (bag == BAG_BACKPACK)
                CallSecureProtected("PickupInventoryItem", bag, index)

                if(inventorySlotButton.slotType == SLOT_TYPE_TRADING_HOUSE_POST_ITEM) then
                    tradingHouse:OnPendingPostItemUpdated(0, false)
                end

                return true
            end
        end
    end)

    ZO_PreHook("ZO_InventorySlot_OnReceiveDrag", function(inventorySlot)
        if(self.isOpen and GetCursorContentType() ~= MOUSE_CONTENT_EMPTY) then
            local bag, index = GetCursorBagId(), GetCursorSlotIndex()

            if(inventorySlot.slotType == SLOT_TYPE_TRADING_HOUSE_POST_ITEM) then
                -- small hack so the quick click handler doesn't clear the item right away
                self.suppressNextClick = true

                TryInitiatingItemPost(bag, index)
            else
                PLAYER_INVENTORY:OnInventorySlotUnlocked(bag, index)
            end

            self.suppressNextInventorySlotEvent = (bag == BAG_BACKPACK)
            self.dragFinalized = true
            ClearCursor()
            return true
        end
    end)

    RegisterForEvent(EVENT_CURSOR_PICKUP, function(_, type, bag, index)
        if(self.isOpen) then
            self.dragFinalized = false
        end
    end)

    RegisterForEvent(EVENT_CURSOR_DROPPED, function(_, type, bag, index)
        if(self.isOpen and not self.dragFinalized) then
            self.dragFinalized = true
            local pendingBagId, pendingSlotIndex = ZO_Inventory_GetBagAndIndex(tradingHouse.pendingItem)
            self.suppressNextInventorySlotEvent = (bag == BAG_BACKPACK)
            if(bag ~= pendingBagId or index ~= pendingSlotIndex) then
                PLAYER_INVENTORY:OnInventorySlotUnlocked(bag, index)
            end
        end
    end)
end

function SellTabWrapper:ClearPendingItem()
    self.pendingTotalStackCount = 0
    self.pendingIcon, self.pendingStackCount, self.pendingSellPrice = "", 0, 0
    self.pendingBagId, self.pendingSlotIndex, self.currentRepetitions = 0, 0, 0
    self.currentStackCount, self.currentPricePerUnit, self.currentSellPrice = 0, 0, 0
    self.pendingItemLink, self.pendingItemIdentifier, self.isMasterWrit = "", "", false
end

function SellTabWrapper:UnsetPendingItem()
    local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(self.tradingHouse.pendingItem)
    PLAYER_INVENTORY:OnInventorySlotUnlocked(bagId, slotIndex)
    self.tradingHouse:OnPendingPostItemUpdated(0, false)
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
    ZO_ItemSlot_SetupSlot(tradingHouse.pendingItem, self.currentStackCount, self.pendingIcon)
    tradingHouse:SetPendingPostPrice(price, SUPPRESS_PRICE_PER_PIECE_UPDATE)
    self.profitWarning:SetHidden(self:IsAboveVendorPrice())
end

function SellTabWrapper:SetQuantity(value, skipUpdateSlider)
    self.currentStackCount = math.max(1, math.min(self.pendingStackCount, value))
    if(not skipUpdateSlider) then self.quantitySlider:UpdateValue() end
    self:UpdateListing()
    self:UpdateRepetitions()
end

function SellTabWrapper:UpdateRepetitions(reset)
    local current, max = GetTradingHouseListingCounts()
    self.maxRepetitions = math.min(max - current, math.floor(self.pendingTotalStackCount / self.currentStackCount))

    if(reset) then
        self.currentRepetitions = 1
    else
        self.currentRepetitions = math.min(self.currentRepetitions, self.maxRepetitions)
    end

    self.repetitionSlider:UpdateValue()
    self.repetitionSlider:SetMinMax(1, self.maxRepetitions)
    self.repetitionSlider:UpdateDisabled()
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

local function IsMasterWrit(bagId, slotIndex)
    local itemType = GetItemType(bagId, slotIndex)
    return itemType == ITEMTYPE_MASTER_WRIT
end

function SellTabWrapper:SetPendingItem(bagId, slotIndex)
    local icon, stackCount, sellPrice = GetItemInfo(bagId, slotIndex)
    if(stackCount > 0) then
        local _, maxStackSize = GetSlotStackSize(bagId, slotIndex)
        self.pendingTotalStackCount = stackCount
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
        self:UpdateRepetitions(true)

        self.ppuSlider:SetMinMax(0, math.max(math.ceil(self.currentPricePerUnit * 3), 100))
        self.priceButtonContainer:ClearAnchors()
        if(self.pendingStackCount > 1) then
            self.repetitionSlider:Show()
            self.quantitySlider:SetMinMax(1, self.pendingStackCount)
            self.quantitySlider:UpdateValue()
            self.quantitySlider:Show()
            self.ppuSlider:UpdateValue()
            self.ppuSlider:Show()
            self.priceButtonContainer:SetAnchor(TOPRIGHT, self.ppuSlider, TOPRIGHT, 0, 0)
        elseif(self.isMasterWrit) then
            self.repetitionSlider:Hide()
            self.quantitySlider:Hide()
            self.ppuSlider:UpdateValue()
            self.ppuSlider:Show()
            self.priceButtonContainer:SetAnchor(TOPRIGHT, self.ppuSlider, TOPRIGHT, 0, 0)
        else
            self.repetitionSlider:Hide()
            self.quantitySlider:Hide()
            self.ppuSlider:Hide()
            self.priceButtonContainer:SetAnchor(BOTTOMRIGHT, self.sellPriceControl, TOPRIGHT, 0, 0)
        end
    end
end

function SellTabWrapper:InitializeListedNotification(tradingHouseWrapper)
    local saveData = self.saveData
    AGS:RegisterCallback(AGS.callback.ITEM_POSTED, function(guildId, itemLink, price, stackCount)
        if(saveData.listedNotification) then
            local guildName = GetGuildName(guildId)
            price = ZO_Currency_FormatPlatform(CURT_MONEY, price or 0, ZO_CURRENCY_FORMAT_AMOUNT_ICON)
            -- TRANSLATORS: chat message when a item is listed on a store. <<1>> is replaced with the item count, <<t:2>> with the item link, <<3>> with the price and <<4>> with the guild store name. e.g. You have listed 1x [Rosin] for 5000g in Imperial Trading Company
            local listedMessage = gettext("You have listed <<1>>x <<t:2>> for <<3>> in <<4>>", stackCount, itemLink, price, guildName)
            chat:Print(listedMessage)
        end
    end)
end

function SellTabWrapper:SetCurrentInventory(bagId)
    self:UnsetPendingItem()

    if(bagId == BAG_BACKPACK) then
        self.currentInventoryFragment = INVENTORY_FRAGMENT
    elseif(bagId == BAG_VIRTUAL) then
        self.currentInventoryFragment = CRAFT_BAG_FRAGMENT
    end
    self:UpdateFragments()
end

function SellTabWrapper:IsCraftBagActive()
    return self.currentInventoryFragment == CRAFT_BAG_FRAGMENT
end

function SellTabWrapper:UpdateFragments()
    SCENE_MANAGER:RemoveFragment(INVENTORY_FRAGMENT)
    SCENE_MANAGER:RemoveFragment(CRAFT_BAG_FRAGMENT)
    ZO_PlayerInventoryInfoBar:SetParent(self:IsCraftBagActive() and ZO_CraftBag or ZO_PlayerInventory)
    SCENE_MANAGER:AddFragment(self.currentInventoryFragment)
end

local function IsCraftBagItemSellableOnTradingHouse(slot)
    return not IsItemBound(slot.bagId, slot.slotIndex)
end

function SellTabWrapper:SetupCraftBag()
    -- no need to set the craft bag here, since UpdateFragments will be called right after OnOpen anyway
end

function SellTabWrapper:TeardownCraftBag()
    if(self.currentInventoryFragment == CRAFT_BAG_FRAGMENT) then
        ZO_PlayerInventoryInfoBar:SetParent(ZO_PlayerInventory)
        SCENE_MANAGER:RemoveFragment(CRAFT_BAG_FRAGMENT)
    end
end

function SellTabWrapper:OnOpen(tradingHouseWrapper)
    self:SetupCraftBag()
    self.isOpen = true
end

function SellTabWrapper:OnClose(tradingHouseWrapper)
    self:TeardownCraftBag()
    self:UnsetPendingItem()
    self.isOpen = false
    self.suppressNextInventorySlotEvent = false
    self.dragFinalized = true
end
