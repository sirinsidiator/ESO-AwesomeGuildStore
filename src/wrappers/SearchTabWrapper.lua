local AGS = AwesomeGuildStore

local gettext = AGS.internal.gettext
local RegisterForEvent = AGS.internal.RegisterForEvent
local ToggleButton = AGS.class.ToggleButton
local GetItemLinkWritCount = AGS.internal.GetItemLinkWritCount
local chat = AGS.internal.chat
local logger = AGS.internal.logger
local AdjustLinkStyle = AGS.internal.AdjustLinkStyle

local FILTER_ID = AGS.data.FILTER_ID

local SearchTabWrapper = ZO_Object:Subclass()
AGS.class.SearchTabWrapper = SearchTabWrapper

local ACTION_LAYER_NAME = "AwesomeGuildStore"

function SearchTabWrapper:New(saveData)
    local wrapper = ZO_Object.New(self)
    wrapper.saveData = saveData
    return wrapper
end

function SearchTabWrapper:RunInitialSetup(tradingHouseWrapper)
    self:PrepareIngameControls(tradingHouseWrapper)
    self:InitializeFilters(tradingHouseWrapper)
    self:InitializePurchase(tradingHouseWrapper)
    self.tradingHouseWrapper = tradingHouseWrapper
end

function SearchTabWrapper:PrepareIngameControls(tradingHouseWrapper)
    local tradingHouse = tradingHouseWrapper.tradingHouse
    local browseItemsControl = tradingHouse.browseItemsLeftPane

    -- hide all built in filters
    browseItemsControl:GetNamedChild("GlobalFeatureArea"):SetHidden(true)
    browseItemsControl:GetNamedChild("CategoryListContainer"):SetHidden(true)
    tradingHouse.itemNameSearch:SetHidden(true)
    tradingHouse.itemNameSearchLabel:SetHidden(true)
    tradingHouse.itemNameSearchAutoComplete:SetHidden(true)
    tradingHouse.featureAreaControl:SetHidden(true)
    tradingHouse.subcategoryTabsControl:SetHidden(true)

    -- make sure they are not shown on tab switch
    local dummyControl = { SetHidden = function() end }
    tradingHouse.itemNameSearch = dummyControl
    tradingHouse.itemNameSearchLabel = dummyControl
    tradingHouse.itemNameSearchAutoComplete = dummyControl
    tradingHouse.featureAreaControl = dummyControl
    tradingHouse.subcategoryTabsControl = dummyControl

    -- reanchor controls to account for the free space from hiding things
    browseItemsControl:SetAnchor(TOPLEFT, tradingHouse.control, TOPLEFT, 0, 10)
end

function SearchTabWrapper:InitializeFilters(tradingHouseWrapper)
    local saveData = self.saveData
    local tradingHouse = tradingHouseWrapper.tradingHouse
    local searchManager = tradingHouseWrapper.searchManager
    self.searchManager = searchManager

    self.categorySelector = AGS.class.CategorySelector:New(tradingHouse.itemPane, searchManager) -- TODO pass the category filter to it
    local selectorControl = self.categorySelector:GetControl()
    tradingHouse.searchSortHeadersControl:SetAnchor(TOPRIGHT, selectorControl, BOTTOMRIGHT)
    tradingHouse.searchSortHeadersControl:SetAnchor(TOPLEFT, selectorControl, BOTTOMLEFT)

    self.filterArea = AGS.class.FilterArea:New(tradingHouse.browseItemsLeftPane, searchManager)

    local categoryFilter = AGS.class.ItemCategoryFilter:New()
    searchManager:RegisterFilter(categoryFilter)
    searchManager:SetCategoryFilter(categoryFilter)
    local category, subcategory = searchManager:GetCurrentCategories()
    self.categorySelector:Update(category, subcategory) -- TODO do this inside the selector

    local sortFilter = AGS.class.SortFilter:New()
    searchManager:SetSortFilter(sortFilter)
    AGS:RegisterFilter(sortFilter)
    AGS:RegisterFilterFragment(AGS.class.SortFilterFragment:New(FILTER_ID.SORT_ORDER))
    AGS:RegisterSortOrder(AGS.class.SortOrderUnitPrice:New())
    AGS:RegisterSortOrder(AGS.class.SortOrderTimeLeft:New())
    AGS:RegisterSortOrder(AGS.class.SortOrderPurchasePrice:New())
    AGS:RegisterSortOrder(AGS.class.SortOrderItemName:New())
    AGS:RegisterSortOrder(AGS.class.SortOrderSellerName:New())
    AGS:RegisterSortOrder(AGS.class.SortOrderSetName:New())
    AGS:RegisterSortOrder(AGS.class.SortOrderItemQuality:New())

    AGS:RegisterFilter(AGS.class.PriceFilter:New())
    AGS:RegisterFilterFragment(AGS.class.PriceRangeFilterFragment:New(FILTER_ID.PRICE_FILTER))

    AGS:RegisterFilter(AGS.class.LevelFilter:New())
    AGS:RegisterFilterFragment(AGS.class.LevelRangeFilterFragment:New(FILTER_ID.LEVEL_FILTER))

    AGS:RegisterFilter(AGS.class.UnitPriceFilter:New())
    AGS:RegisterFilterFragment(AGS.class.PriceRangeFilterFragment:New(FILTER_ID.UNIT_PRICE_FILTER))

    AGS:RegisterFilter(AGS.class.QualityFilter:New())
    AGS:RegisterFilterFragment(AGS.class.QualityFilterFragment:New(FILTER_ID.QUALITY_FILTER))

    AGS:RegisterFilter(AGS.class.TextFilter:New())
    AGS:RegisterFilterFragment(AGS.class.TextFilterFragment:New(FILTER_ID.TEXT_FILTER))

    AGS:RegisterFilter(AGS.class.ItemStyleFilter:New())
    AGS:RegisterFilterFragment(AGS.class.MultiCategoryFilterFragment:New(FILTER_ID.ITEM_STYLE_FILTER))

    local filterData = AGS.data.WEAPON_TRAIT_FILTER
    AGS:RegisterFilter(AGS.class.GenericTradingHouseFilter:New(filterData))
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(filterData.id))

    filterData = AGS.data.ARMOR_TRAIT_FILTER
    AGS:RegisterFilter(AGS.class.GenericTradingHouseFilter:New(filterData))
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(filterData.id))

    filterData = AGS.data.JEWELRY_TRAIT_FILTER
    AGS:RegisterFilter(AGS.class.GenericTradingHouseFilter:New(filterData))
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(filterData.id))

    filterData = AGS.data.COMPANION_WEAPON_TRAIT_FILTER
    AGS:RegisterFilter(AGS.class.GenericTradingHouseFilter:New(filterData))
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(filterData.id))

    filterData = AGS.data.COMPANION_ARMOR_TRAIT_FILTER
    AGS:RegisterFilter(AGS.class.GenericTradingHouseFilter:New(filterData))
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(filterData.id))

    filterData = AGS.data.COMPANION_JEWELRY_TRAIT_FILTER
    AGS:RegisterFilter(AGS.class.GenericTradingHouseFilter:New(filterData))
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(filterData.id))

    filterData = AGS.data.WEAPON_ENCHANTMENT_FILTER
    AGS:RegisterFilter(AGS.class.GenericTradingHouseFilter:New(filterData))
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(filterData.id))

    filterData = AGS.data.ARMOR_ENCHANTMENT_FILTER
    AGS:RegisterFilter(AGS.class.GenericTradingHouseFilter:New(filterData))
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(filterData.id))

    filterData = AGS.data.JEWELRY_ENCHANTMENT_FILTER
    AGS:RegisterFilter(AGS.class.GenericTradingHouseFilter:New(filterData))
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(filterData.id))

    filterData = AGS.data.ONE_HANDED_WEAPON_TYPE_FILTER
    AGS:RegisterFilter(AGS.class.GenericTradingHouseFilter:New(filterData))
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(filterData.id))

    filterData = AGS.data.TWO_HANDED_WEAPON_TYPE_FILTER
    AGS:RegisterFilter(AGS.class.GenericTradingHouseFilter:New(filterData))
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(filterData.id))

    filterData = AGS.data.STAFF_WEAPON_TYPE_FILTER
    AGS:RegisterFilter(AGS.class.GenericTradingHouseFilter:New(filterData))
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(filterData.id))

    filterData = AGS.data.ARMOR_EQUIP_TYPE_FILTER
    AGS:RegisterFilter(AGS.class.GenericTradingHouseFilter:New(filterData))
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(filterData.id))

    filterData = AGS.data.BLACKSMITHING_MATERIAL_TYPE_FILTER
    AGS:RegisterFilter(AGS.class.GenericTradingHouseFilter:New(filterData))
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(filterData.id))

    filterData = AGS.data.CLOTHING_MATERIAL_TYPE_FILTER
    AGS:RegisterFilter(AGS.class.GenericTradingHouseFilter:New(filterData))
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(filterData.id))

    filterData = AGS.data.WOODWORKING_MATERIAL_TYPE_FILTER
    AGS:RegisterFilter(AGS.class.GenericTradingHouseFilter:New(filterData))
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(filterData.id))

    filterData = AGS.data.STYLE_MATERIAL_TYPE_FILTER
    AGS:RegisterFilter(AGS.class.GenericTradingHouseFilter:New(filterData))
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(filterData.id))

    filterData = AGS.data.ALCHEMY_MATERIAL_TYPE_FILTER
    AGS:RegisterFilter(AGS.class.GenericTradingHouseFilter:New(filterData))
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(filterData.id))

    filterData = AGS.data.ENCHANTING_MATERIAL_TYPE_FILTER
    AGS:RegisterFilter(AGS.class.GenericTradingHouseFilter:New(filterData))
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(filterData.id))

    filterData = AGS.data.PROVISIONING_MATERIAL_TYPE_FILTER
    AGS:RegisterFilter(AGS.class.GenericTradingHouseFilter:New(filterData))
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(filterData.id))

    filterData = AGS.data.FURNISHING_MATERIAL_TYPE_FILTER
    AGS:RegisterFilter(AGS.class.GenericTradingHouseFilter:New(filterData))
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(filterData.id))

    filterData = AGS.data.TRAIT_MATERIAL_TYPE_FILTER
    AGS:RegisterFilter(AGS.class.GenericTradingHouseFilter:New(filterData))
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(filterData.id))

    filterData = AGS.data.JEWELRY_MATERIAL_TYPE_FILTER
    AGS:RegisterFilter(AGS.class.GenericTradingHouseFilter:New(filterData))
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(filterData.id))

    filterData = AGS.data.GLYPH_TYPE_FILTER
    AGS:RegisterFilter(AGS.class.GenericTradingHouseFilter:New(filterData))
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(filterData.id))

    filterData = AGS.data.RECIPE_TYPE_FILTER
    AGS:RegisterFilter(AGS.class.GenericTradingHouseFilter:New(filterData))
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(filterData.id))

    filterData = AGS.data.DRINK_TYPE_FILTER
    AGS:RegisterFilter(AGS.class.GenericTradingHouseFilter:New(filterData))
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(filterData.id))

    filterData = AGS.data.FOOD_TYPE_FILTER
    AGS:RegisterFilter(AGS.class.GenericTradingHouseFilter:New(filterData))
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(filterData.id))

    filterData = AGS.data.SIEGE_TYPE_FILTER
    AGS:RegisterFilter(AGS.class.GenericTradingHouseFilter:New(filterData))
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(filterData.id))

    filterData = AGS.data.CONSUMABLE_TROPHY_TYPE_FILTER
    AGS:RegisterFilter(AGS.class.GenericTradingHouseFilter:New(filterData))
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(filterData.id))

    filterData = AGS.data.MISC_TROPHY_TYPE_FILTER
    AGS:RegisterFilter(AGS.class.GenericTradingHouseFilter:New(filterData))
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(filterData.id))

    AGS:RegisterFilter(AGS.class.RecipeKnowledgeFilter:New())
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(FILTER_ID.RECIPE_KNOWLEDGE_FILTER))

    AGS:RegisterFilter(AGS.class.MotifKnowledgeFilter:New())
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(FILTER_ID.MOTIF_KNOWLEDGE_FILTER))

    AGS:RegisterFilter(AGS.class.TraitKnowledgeFilter:New())
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(FILTER_ID.TRAIT_KNOWLEDGE_FILTER))

    AGS:RegisterFilter(AGS.class.RuneKnowledgeFilter:New())
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(FILTER_ID.RUNE_KNOWLEDGE_FILTER))

    AGS:RegisterFilter(AGS.class.ItemSetFilter:New())
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(FILTER_ID.ITEM_SET_FILTER))

    AGS:RegisterFilter(AGS.class.CraftedItemFilter:New())
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(FILTER_ID.ITEM_CRAFTED_FILTER))

    AGS:RegisterFilter(AGS.class.SkillRequirementsFilter:New())
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(FILTER_ID.SKILL_REQUIREMENTS_FILTER))

    filterData = AGS.data.MASTER_WRIT_TYPE_FILTER
    AGS:RegisterFilter(AGS.class.GenericTradingHouseFilter:New(filterData))
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(filterData.id))

    AGS:RegisterFilter(AGS.class.WritVoucherFilter:New())
    AGS:RegisterFilterFragment(AGS.class.PriceRangeFilterFragment:New(FILTER_ID.MASTER_WRIT_VOUCHER_FILTER))

    AGS:RegisterFilter(AGS.class.FurnitureCategoryFilter:New())
    AGS:RegisterFilterFragment(AGS.class.MultiCategoryFilterFragment:New(FILTER_ID.FURNITURE_CATEGORY_FILTER))

    AGS:RegisterFilter(AGS.class.CollectibleOwnershipFilter:New())
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(FILTER_ID.COLLECTIBLE_OWNERSHIP_FILTER))

    AGS.internal:FireCallbacks(AGS.callback.AFTER_FILTER_SETUP, tradingHouseWrapper)

    self.searchResultList = AGS.class.SearchResultListWrapper:New(tradingHouseWrapper, searchManager)
    searchManager:OnFiltersInitialized()
    self.filterArea:OnFiltersInitialized()

    self.searchList = AGS.class.SearchList:New(searchManager)
end

function SearchTabWrapper:PrintPurchaseMessageForEntry(entry)
    local count = entry.stackCount
    local seller = ZO_LinkHandler_CreateDisplayNameLink(entry.sellerName)
    local price = ZO_Currency_FormatPlatform(CURT_MONEY, entry.purchasePrice, ZO_CURRENCY_FORMAT_AMOUNT_ICON)
    local itemLink = AdjustLinkStyle(entry.itemLink, LINK_STYLE_BRACKETS)
    local guildName = entry.guildName
    -- TRANSLATORS: chat message when an item is bought from the store. <<1>> is replaced with the item count, <<t:2>> with the item link, <<3>> with the seller name, <<4>> with price and <<5>> with the guild store name. e.g. You have bought 1x [Rosin] from sirinsidiator for 5000g in Imperial Trading Company
    local message = gettext("You have bought <<1>>x <<t:2>> from <<3>> for <<4>> in <<5>>", count, itemLink, seller, price, guildName)
    chat:Print(message)
end

function SearchTabWrapper:InitializePurchase(tradingHouseWrapper)
    local saveData = self.saveData
    local tradingHouse = tradingHouseWrapper.tradingHouse
    local itemDatabase = tradingHouseWrapper.itemDatabase

    tradingHouse.control:UnregisterForEvent(EVENT_TRADING_HOUSE_CONFIRM_ITEM_PURCHASE)

    tradingHouseWrapper:Wrap("VerifyBuyItemAndShowErrors", function(originalVerifyBuyItemAndShowErrors, tradingHouse, inventorySlot)
        if(ZO_InventorySlot_GetType(inventorySlot) == SLOT_TYPE_GUILD_SPECIFIC_ITEM) then
            return originalVerifyBuyItemAndShowErrors(tradingHouse, inventorySlot)
        end

        if(originalVerifyBuyItemAndShowErrors(tradingHouse, inventorySlot)) then
            local entry = ZO_ScrollList_GetData(inventorySlot:GetParent())
            if(not entry) then
                logger:Warn("No item for current inventorySlot")
                return false
            end

            if(entry.purchased) then
                -- TRANSLATORS: Alert message when they try to purchase an item which was already purchased by them earlier
                ZO_AlertNoSuppression(UI_ALERT_CATEGORY_ALERT, SOUNDS.PLAYER_ACTION_INSUFFICIENT_GOLD, gettext("Item is already in your possession."))
            else
                tradingHouse:ConfirmPendingPurchase(entry.itemUniqueId)
            end
        end
        return false -- always return false so SetPendingItemPurchase is not called in the inventoryslot.lua
    end)

    tradingHouseWrapper:Wrap("ConfirmPendingPurchase", function(originalConfirmPendingPurchase, tradingHouse, pendingPurchaseIndex)
        local originalZO_Dialogs_ShowDialog = ZO_Dialogs_ShowDialog
        ZO_Dialogs_ShowDialog = function() end
        originalConfirmPendingPurchase(tradingHouse, pendingPurchaseIndex)

        local dialog = ESO_Dialogs["CONFIRM_TRADING_HOUSE_PURCHASE"]
        dialog.buttons[1].callback = function(dialog)
            local itemData, guildId = itemDatabase:TryGetItemDataInCurrentGuildByUniqueId(dialog.purchaseIndex)
            if(itemData) then
                tradingHouseWrapper.activityManager:PurchaseItem(guildId, itemData)
            else
                logger:Warn("Item data missing on confirm purchase.", Id64ToString(dialog.purchaseIndex), guildId)
                -- TRANSLATORS: Alert message when the item data for the item id could not be found while confirming a purchase
                ZO_AlertNoSuppression(UI_ALERT_CATEGORY_ALERT, SOUNDS.PLAYER_ACTION_INSUFFICIENT_GOLD, gettext("Item not found in current guild."))
            end
        end
        dialog.buttons[2].callback = function()
        -- nothing to do here
        end

        ZO_Dialogs_ShowDialog = originalZO_Dialogs_ShowDialog
        ZO_Dialogs_ShowDialog("CONFIRM_TRADING_HOUSE_PURCHASE")
        tradingHouse.ConfirmPendingPurchase = originalConfirmPendingPurchase
    end)

    AGS:RegisterCallback(AGS.callback.ITEM_PURCHASED, function(itemData)
        if(saveData.purchaseNotification) then
            self:PrintPurchaseMessageForEntry(itemData)
        end
        itemData.purchased = true
        self.searchResultList:RefreshVisible()
    end)

    AGS:RegisterCallback(AGS.callback.ITEM_PURCHASE_FAILED, function(itemData)
        self.searchResultList:RefreshVisible()
    end)

    tradingHouseWrapper:Wrap("CanBuyItem", function(originalCanBuyItem, tradingHouse, inventorySlot)
        if(not originalCanBuyItem(tradingHouse, inventorySlot)) then
            return false
        end

        local entry = ZO_ScrollList_GetData(inventorySlot:GetParent())
        if(entry.purchased or entry.soldout) then
            return false
        end

        return true
    end)
end

function SearchTabWrapper:OnOpen(tradingHouseWrapper)
    local tradingHouse = tradingHouseWrapper.tradingHouse
    TRADING_HOUSE_SCENE:AddFragment(self.categorySelector)
    self.searchList:Show()
    PushActionLayerByName(ACTION_LAYER_NAME) -- TODO should this action layer only be active here or better in the whole trading house?
    self.isOpen = true
end

function SearchTabWrapper:OnClose(tradingHouseWrapper)
    self.searchList:Hide()
    TRADING_HOUSE_SCENE:RemoveFragment(self.categorySelector)
    self.tradingHouseWrapper.activityManager:CancelSearch()
    self.tradingHouseWrapper.activityManager:CancelRequestNewest()
    RemoveActionLayerByName(ACTION_LAYER_NAME)

    self.isOpen = false
end
