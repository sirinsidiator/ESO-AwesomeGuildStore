local gettext = LibStub("LibGetText")("AwesomeGuildStore").gettext
local RegisterForEvent = AwesomeGuildStore.RegisterForEvent
local ToggleButton = AwesomeGuildStore.ToggleButton
local ClearCallLater = AwesomeGuildStore.ClearCallLater
local GetItemLinkWritCount = AwesomeGuildStore.GetItemLinkWritCount
local Print = AwesomeGuildStore.Print
local AdjustLinkStyle = AwesomeGuildStore.AdjustLinkStyle

local SearchTabWrapper = ZO_Object:Subclass()
AwesomeGuildStore.SearchTabWrapper = SearchTabWrapper

local ACTION_LAYER_NAME = "AwesomeGuildStore"
local FILTER_PANEL_WIDTH = 220
local MISSING_ICON = "/esoui/art/icons/icon_missing.dds"
local PURCHASED_BG_TEXTURE = "EsoUI/Art/Miscellaneous/listItem_highlight.dds"
local PURCHASED_VERTEX_COORDS = {0, 1, 0, 0.625}
local DEFAULT_BG_TEXTURE = "EsoUI/Art/Miscellaneous/listItem_backdrop.dds"
local DEFAULT_VERTEX_COORDS = {0, 1, 0, 0.8125}
local PURCHASED_TEXTURE = "EsoUI/Art/hud/gamepad/gp_radialicon_accept_down.dds"
local SOLDOUT_TEXTURE = "EsoUI/Art/hud/gamepad/gp_radialicon_cancel_down.dds"

function SearchTabWrapper:New(saveData)
    local wrapper = ZO_Object.New(self)
    wrapper.saveData = saveData
    return wrapper
end

local iconMarkup = string.format("|t%u:%u:%s|t", 16, 16, "EsoUI/Art/currency/currency_gold.dds")
function SearchTabWrapper:RunInitialSetup(tradingHouseWrapper)
    self:PrepareIngameControls(tradingHouseWrapper)
    self:InitializeFilters(tradingHouseWrapper)
    self:InitializeButtons(tradingHouseWrapper)
    self:InitializeNavigation(tradingHouseWrapper)
    self:InitializeUnitPriceDisplay(tradingHouseWrapper)
    self:InitializeSearchResultMasterList(tradingHouseWrapper)
    self:InitializeKeybinds(tradingHouseWrapper)
    zo_callLater(function()
        self:RefreshFilterDimensions() -- call this after the layout has been updated
        --TODO: self.categoryFilter:UpdateSubfilterVisibility() -- fix inpage filters not working on first visit
    end, 1)
    self.tradingHouseWrapper = tradingHouseWrapper

    local saveData = self.saveData
    --    CALLBACK_MANAGER:RegisterCallback("AwesomeGuildStore_SearchLibraryEntry_Selected", function(entry)
    --        if(saveData.autoSearch) then
    --            self.fromSearchLibrary = true
    --            tradingHouseWrapper.tradingHouse:ClearSearchResults()
    --            self:Search()
    --        end
    --    end)
end

local function SortByFilterPriority(a, b)
    if(a.priority == b.priority) then
        return a.type < b.type
    end
    return b.priority < a.priority
end

function SearchTabWrapper:RequestUpdateFilterAnchors()
    if(self.updateFilterAnchorRequest) then
        ClearCallLater(self.updateFilterAnchorRequest)
    end
    self.updateFilterAnchorRequest = zo_callLater(function()
        self.updateFilterAnchorRequest = nil
        self:UpdateFilterAnchors()
    end, 10)
end

function SearchTabWrapper:UpdateFilterAnchors()
    local filters = self.searchManager:GetActiveFilters()
    table.sort(filters, SortByFilterPriority)

    local previousChild = self.filterAreaScrollChild
    for i = 1, #filters do
        local isFirst = (i == 1)
        local filterContainer = filters[i]:GetControl()
        filterContainer:ClearAnchors()
        filterContainer:SetAnchor(TOPLEFT, previousChild, isFirst and TOPLEFT or BOTTOMLEFT, 0, isFirst and 0 or 10)
        previousChild = filterContainer
    end
end

local function HandleFilterChanged(self)
    if(not self.fromSearchLibrary) then
        self:CancelSearch()
    end
end

local function RequestHandleFilterChanged(self)
    if(self.fireChangeCallback) then
        ClearCallLater(self.fireChangeCallback)
    end
    self.fireChangeCallback = zo_callLater(function()
        self.handleChangeCallback = nil
        HandleFilterChanged(self)
    end, 10)
end

local function RebuildSearchResultsPage()
    TRADING_HOUSE:RebuildSearchResultsPage()
end

function SearchTabWrapper:AttachFilter(filter) -- TODO: remove
end

function SearchTabWrapper:DetachFilter(filter) -- TODO: remove
    if(self.searchManager:DetachFilter(filter.type)) then
        filter:SetHidden(true)
        filter:SetParent(GuiRoot)
        CALLBACK_MANAGER:UnregisterCallback(filter.callbackName, HandleFilterChanged)
        if(filter.isLocal) then
            CALLBACK_MANAGER:UnregisterCallback(filter.callbackName, RebuildSearchResultsPage)
        end

        self:RequestUpdateFilterAnchors()
end
end

function SearchTabWrapper:RefreshFilterDimensions() -- TODO remove
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

function SearchTabWrapper:UpdateItemsLabels(tradingHouse, itemCount, filteredItemCount)
    tradingHouse.resultCount:SetText(zo_strformat(GetString(SI_TRADING_HOUSE_RESULT_COUNT) .. " (<<2>>)", itemCount, filteredItemCount))
end

function SearchTabWrapper:InitializeFilters(tradingHouseWrapper)
    local saveData = self.saveData
    local tradingHouse = tradingHouseWrapper.tradingHouse

    local searchLibrary = AwesomeGuildStore.SearchLibrary:New(saveData.searchLibrary)
    self.searchLibrary = searchLibrary
    local searchManager = AwesomeGuildStore.SearchManager:New(tradingHouseWrapper, saveData.searchManager) -- TODO
    saveData.searchManager = searchManager:GetSaveData()
    self.searchManager = searchManager -- TODO: move to tradinghouse wrapper
    self.categorySelector = AwesomeGuildStore.class.CategorySelector:New(tradingHouse.itemPane, searchManager) -- TODO pass the category filter to it
    tradingHouse.searchSortHeadersControl:SetAnchor(TOPRIGHT, self.categorySelector:GetControl(), BOTTOMRIGHT)
    TRADING_HOUSE_SCENE:AddFragment(self.categorySelector) -- TODO is this the right place?

    self.filterArea = AwesomeGuildStore.FilterArea:New(tradingHouse.browseItemsLeftPane, searchManager)

    SLASH_COMMANDS["/ags"] = function(command) -- TODO remove
        if(command == "reset") then
            searchLibrary:ResetPosition()
            Print("Default search library position restored")
    end
    end

    searchManager:RegisterFilter(AwesomeGuildStore.class.ItemCategoryFilter:New())
    local category, subcategory = searchManager:GetCurrentCategories()
    self.categorySelector:Update(category, subcategory) -- TODO do this inside the selector

    local sortFilter = AwesomeGuildStore.class.SortFilter:New()
    sortFilter:RegisterSortOrder(AwesomeGuildStore.class.SortOrderTimeLeft:New(), true)
    sortFilter:RegisterSortOrder(AwesomeGuildStore.class.SortOrderLastSeen:New())
    sortFilter:RegisterSortOrder(AwesomeGuildStore.class.SortOrderPurchasePrice:New())
    sortFilter:RegisterSortOrder(AwesomeGuildStore.class.SortOrderUnitPrice:New())
    sortFilter:RegisterSortOrder(AwesomeGuildStore.class.SortOrderItemName:New())
    sortFilter:RegisterSortOrder(AwesomeGuildStore.class.SortOrderSellerName:New())
    sortFilter:RegisterSortOrder(AwesomeGuildStore.class.SortOrderSetName:New())
    sortFilter:RegisterSortOrder(AwesomeGuildStore.class.SortOrderItemQuality:New())
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.SortFilterFragment:New(sortFilter))
    searchManager:RegisterFilter(sortFilter)

    local priceFilter = AwesomeGuildStore.class.PriceFilter:New()
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.PriceRangeFilterFragment:New(priceFilter))
    searchManager:RegisterFilter(priceFilter)

    local levelFilter = AwesomeGuildStore.class.LevelFilter:New()
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.LevelRangeFilterFragment:New(levelFilter))
    searchManager:RegisterFilter(levelFilter)

    local unitPriceFilter = AwesomeGuildStore.class.UnitPriceFilter:New()
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.PriceRangeFilterFragment:New(unitPriceFilter))
    searchManager:RegisterFilter(unitPriceFilter)

    local qualityFilter = AwesomeGuildStore.class.QualityFilter:New()
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.QualityFilterFragment:New(qualityFilter))
    searchManager:RegisterFilter(qualityFilter)

    local textFilter = AwesomeGuildStore.class.TextFilter:New()
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.TextFilterFragment:New(textFilter))
    searchManager:RegisterFilter(textFilter)

    local itemStyleFilter = AwesomeGuildStore.class.ItemStyleFilter:New()
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.MultiCategoryFilterFragment:New(itemStyleFilter))
    searchManager:RegisterFilter(itemStyleFilter)

    local weaponTraitFilter = AwesomeGuildStore.class.GenericTradingHouseFilter:New(AwesomeGuildStore.data.WEAPON_TRAIT_FILTER)
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.MultiButtonFilterFragment:New(weaponTraitFilter))
    searchManager:RegisterFilter(weaponTraitFilter)

    local armorTraitFilter = AwesomeGuildStore.class.GenericTradingHouseFilter:New(AwesomeGuildStore.data.ARMOR_TRAIT_FILTER)
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.MultiButtonFilterFragment:New(armorTraitFilter))
    searchManager:RegisterFilter(armorTraitFilter)

    local jewelryTraitFilter = AwesomeGuildStore.class.GenericTradingHouseFilter:New(AwesomeGuildStore.data.JEWELRY_TRAIT_FILTER)
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.MultiButtonFilterFragment:New(jewelryTraitFilter))
    searchManager:RegisterFilter(jewelryTraitFilter)

    local weaponEnchantmentFilter = AwesomeGuildStore.class.GenericTradingHouseFilter:New(AwesomeGuildStore.data.WEAPON_ENCHANTMENT_FILTER)
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.MultiButtonFilterFragment:New(weaponEnchantmentFilter))
    searchManager:RegisterFilter(weaponEnchantmentFilter)

    local armorEnchantmentFilter = AwesomeGuildStore.class.GenericTradingHouseFilter:New(AwesomeGuildStore.data.ARMOR_ENCHANTMENT_FILTER)
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.MultiButtonFilterFragment:New(armorEnchantmentFilter))
    searchManager:RegisterFilter(armorEnchantmentFilter)

    local jewelryEnchantmentFilter = AwesomeGuildStore.class.GenericTradingHouseFilter:New(AwesomeGuildStore.data.JEWELRY_ENCHANTMENT_FILTER)
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.MultiButtonFilterFragment:New(jewelryEnchantmentFilter))
    searchManager:RegisterFilter(jewelryEnchantmentFilter)

    local oneHandedFilter = AwesomeGuildStore.class.GenericTradingHouseFilter:New(AwesomeGuildStore.data.ONE_HANDED_WEAPON_TYPE_FILTER)
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.MultiButtonFilterFragment:New(oneHandedFilter))
    searchManager:RegisterFilter(oneHandedFilter)

    local twoHandedFilter = AwesomeGuildStore.class.GenericTradingHouseFilter:New(AwesomeGuildStore.data.TWO_HANDED_WEAPON_TYPE_FILTER)
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.MultiButtonFilterFragment:New(twoHandedFilter))
    searchManager:RegisterFilter(twoHandedFilter)

    local staffFilter = AwesomeGuildStore.class.GenericTradingHouseFilter:New(AwesomeGuildStore.data.STAFF_WEAPON_TYPE_FILTER)
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.MultiButtonFilterFragment:New(staffFilter))
    searchManager:RegisterFilter(staffFilter)

    local armorTypeFilter = AwesomeGuildStore.class.GenericTradingHouseFilter:New(AwesomeGuildStore.data.ARMOR_EQUIP_TYPE_FILTER)
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.MultiButtonFilterFragment:New(armorTypeFilter))
    searchManager:RegisterFilter(armorTypeFilter)

    local blacksmithingMaterialTypeFilter = AwesomeGuildStore.class.GenericTradingHouseFilter:New(AwesomeGuildStore.data.BLACKSMITHING_MATERIAL_TYPE_FILTER)
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.MultiButtonFilterFragment:New(blacksmithingMaterialTypeFilter))
    searchManager:RegisterFilter(blacksmithingMaterialTypeFilter)

    local clothingMaterialTypeFilter = AwesomeGuildStore.class.GenericTradingHouseFilter:New(AwesomeGuildStore.data.CLOTHING_MATERIAL_TYPE_FILTER)
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.MultiButtonFilterFragment:New(clothingMaterialTypeFilter))
    searchManager:RegisterFilter(clothingMaterialTypeFilter)

    local woodworkingMaterialTypeFilter = AwesomeGuildStore.class.GenericTradingHouseFilter:New(AwesomeGuildStore.data.WOODWORKING_MATERIAL_TYPE_FILTER)
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.MultiButtonFilterFragment:New(woodworkingMaterialTypeFilter))
    searchManager:RegisterFilter(woodworkingMaterialTypeFilter)

    local styleMaterialTypeFilter = AwesomeGuildStore.class.GenericTradingHouseFilter:New(AwesomeGuildStore.data.STYLE_MATERIAL_TYPE_FILTER)
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.MultiButtonFilterFragment:New(styleMaterialTypeFilter))
    searchManager:RegisterFilter(styleMaterialTypeFilter)

    local alchemyMaterialTypeFilter = AwesomeGuildStore.class.GenericTradingHouseFilter:New(AwesomeGuildStore.data.ALCHEMY_MATERIAL_TYPE_FILTER)
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.MultiButtonFilterFragment:New(alchemyMaterialTypeFilter))
    searchManager:RegisterFilter(alchemyMaterialTypeFilter)

    local enchantingMaterialTypeFilter = AwesomeGuildStore.class.GenericTradingHouseFilter:New(AwesomeGuildStore.data.ENCHANTING_MATERIAL_TYPE_FILTER)
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.MultiButtonFilterFragment:New(enchantingMaterialTypeFilter))
    searchManager:RegisterFilter(enchantingMaterialTypeFilter)

    local provisioningMaterialTypeFilter = AwesomeGuildStore.class.GenericTradingHouseFilter:New(AwesomeGuildStore.data.PROVISIONING_MATERIAL_TYPE_FILTER)
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.MultiButtonFilterFragment:New(provisioningMaterialTypeFilter))
    searchManager:RegisterFilter(provisioningMaterialTypeFilter)

    local furnishingMaterialTypeFilter = AwesomeGuildStore.class.GenericTradingHouseFilter:New(AwesomeGuildStore.data.FURNISHING_MATERIAL_TYPE_FILTER)
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.MultiButtonFilterFragment:New(furnishingMaterialTypeFilter))
    searchManager:RegisterFilter(furnishingMaterialTypeFilter)

    local traitMaterialTypeFilter = AwesomeGuildStore.class.GenericTradingHouseFilter:New(AwesomeGuildStore.data.TRAIT_MATERIAL_TYPE_FILTER)
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.MultiButtonFilterFragment:New(traitMaterialTypeFilter))
    searchManager:RegisterFilter(traitMaterialTypeFilter)

    local jewelryMaterialTypeFilter = AwesomeGuildStore.class.GenericTradingHouseFilter:New(AwesomeGuildStore.data.JEWELRY_MATERIAL_TYPE_FILTER)
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.MultiButtonFilterFragment:New(jewelryMaterialTypeFilter))
    searchManager:RegisterFilter(jewelryMaterialTypeFilter)

    local glyphTypeFilter = AwesomeGuildStore.class.GenericTradingHouseFilter:New(AwesomeGuildStore.data.GLYPH_TYPE_FILTER)
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.MultiButtonFilterFragment:New(glyphTypeFilter))
    searchManager:RegisterFilter(glyphTypeFilter)

    local recipeTypeFilter = AwesomeGuildStore.class.GenericTradingHouseFilter:New(AwesomeGuildStore.data.RECIPE_TYPE_FILTER)
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.MultiButtonFilterFragment:New(recipeTypeFilter))
    searchManager:RegisterFilter(recipeTypeFilter)

    local drinkTypeFilter = AwesomeGuildStore.class.GenericTradingHouseFilter:New(AwesomeGuildStore.data.DRINK_TYPE_FILTER)
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.MultiButtonFilterFragment:New(drinkTypeFilter))
    searchManager:RegisterFilter(drinkTypeFilter)

    local foodTypeFilter = AwesomeGuildStore.class.GenericTradingHouseFilter:New(AwesomeGuildStore.data.FOOD_TYPE_FILTER)
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.MultiButtonFilterFragment:New(foodTypeFilter))
    searchManager:RegisterFilter(foodTypeFilter)

    local siegeTypeFilter = AwesomeGuildStore.class.GenericTradingHouseFilter:New(AwesomeGuildStore.data.SIEGE_TYPE_FILTER)
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.MultiButtonFilterFragment:New(siegeTypeFilter))
    searchManager:RegisterFilter(siegeTypeFilter)

    local trophyTypeFilter = AwesomeGuildStore.class.GenericTradingHouseFilter:New(AwesomeGuildStore.data.TROPHY_TYPE_FILTER)
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.MultiButtonFilterFragment:New(trophyTypeFilter))
    searchManager:RegisterFilter(trophyTypeFilter)

    local recipeKnowledgeFilter = AwesomeGuildStore.class.RecipeKnowledgeFilter:New()
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.MultiButtonFilterFragment:New(recipeKnowledgeFilter))
    searchManager:RegisterFilter(recipeKnowledgeFilter)

    local motifKnowledgeFilter = AwesomeGuildStore.class.MotifKnowledgeFilter:New()
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.MultiButtonFilterFragment:New(motifKnowledgeFilter))
    searchManager:RegisterFilter(motifKnowledgeFilter)

    local traitKnowledgeFilter = AwesomeGuildStore.class.TraitKnowledgeFilter:New()
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.MultiButtonFilterFragment:New(traitKnowledgeFilter))
    searchManager:RegisterFilter(traitKnowledgeFilter)

    local runeKnowledgeFilter = AwesomeGuildStore.class.RuneKnowledgeFilter:New()
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.MultiButtonFilterFragment:New(runeKnowledgeFilter))
    searchManager:RegisterFilter(runeKnowledgeFilter)

    local itemSetFilter = AwesomeGuildStore.class.ItemSetFilter:New()
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.MultiButtonFilterFragment:New(itemSetFilter))
    searchManager:RegisterFilter(itemSetFilter)

    local craftedItemFilter = AwesomeGuildStore.class.CraftedItemFilter:New()
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.MultiButtonFilterFragment:New(craftedItemFilter))
    searchManager:RegisterFilter(craftedItemFilter)

    local skillRequirementsFilter = AwesomeGuildStore.class.SkillRequirementsFilter:New()
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.MultiButtonFilterFragment:New(skillRequirementsFilter))
    searchManager:RegisterFilter(skillRequirementsFilter)

    local writTypeFilter = AwesomeGuildStore.class.GenericTradingHouseFilter:New(AwesomeGuildStore.data.MASTER_WRIT_TYPE_FILTER)
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.MultiButtonFilterFragment:New(writTypeFilter))
    searchManager:RegisterFilter(writTypeFilter)

    local writVoucherFilter = AwesomeGuildStore.class.WritVoucherFilter:New()
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.PriceRangeFilterFragment:New(writVoucherFilter))
    searchManager:RegisterFilter(writVoucherFilter)

    local furnitureCategoryFilter = AwesomeGuildStore.class.FurnitureCategoryFilter:New()
    self.filterArea:RegisterFilterFragment(AwesomeGuildStore.class.MultiCategoryFilterFragment:New(furnitureCategoryFilter))
    searchManager:RegisterFilter(furnitureCategoryFilter)

    AwesomeGuildStore:FireOnInitializeFiltersCallbacks(tradingHouseWrapper)

    self.searchResultList = AwesomeGuildStore.class.SearchResultListWrapper:New(tradingHouseWrapper, searchManager)
    searchManager:OnFiltersInitialized()
    self.filterArea:OnFiltersInitialized()

    if(saveData.keepFiltersOnClose) then
        searchLibrary:Deserialize(saveData.searchLibrary.lastState)
    end
    searchLibrary:Serialize()
end

function SearchTabWrapper:AttachButton(button) -- TODO remove
end

function SearchTabWrapper:DetachButton(button) -- TODO remove
end

function SearchTabWrapper:InitializeButtons(tradingHouseWrapper) -- TODO remove?
end

function SearchTabWrapper:InitializeNavigation(tradingHouseWrapper) -- TODO: remove
    local SHOW_MORE_DATA_TYPE = 4 -- watch out for changes in tradinghouse.lua
    local HAS_HIDDEN_DATA_TYPE = 5
    local tradingHouse = tradingHouseWrapper.tradingHouse
    local search = tradingHouse.m_search

    local showPreviousPageEntry =  {
        -- TRANSLATORS: Label for the row at the beginning of the search results which toggles the search of the previous page
        label = gettext("Show Previous Page"),
        callback = function() self:SearchPreviousPage() end,
        updateState = function(rowControl)
            rowControl:SetEnabled(true)
        end,
        color = ZO_ColorDef:New("F97431")
    }

    local showNextPageEntry =  {
        -- TRANSLATORS: Label for the row at the end of the search results which toggles the search of the next page
        label = gettext("Show More Results"),
        callback = function() self:SearchNextPage() end,
        updateState = function(rowControl)
            rowControl:SetEnabled(true)
        end,
        color = ZO_ColorDef:New("50D35D")
    }


    ZO_ScrollList_AddDataType(tradingHouse.searchResultsList, HAS_HIDDEN_DATA_TYPE, "AwesomeGuildStoreHasHiddenRowTemplate", 24, function(rowControl, entry)
        local label = rowControl:GetNamedChild("Text")
        -- TRANSLATORS: placeholder text when all search results are hidden by local filters
        label:SetText(gettext("All items are hidden by local filters."))
    end, nil, nil, function(rowControl)
        ZO_ObjectPool_DefaultResetControl(rowControl)
    end)
    -- TODO
    --    tradingHouseWrapper:Wrap("RebuildSearchResultsPage", function(originalRebuildSearchResultsPage, self)
    --        originalRebuildSearchResultsPage(self)
    --
    --        local hasPrev = search:HasPreviousPage()
    --        local hasNext = search:HasNextPage()
    --        if(hasPrev or hasNext) then
    --            local list = self.m_searchResultsList
    --            local scrollData = ZO_ScrollList_GetDataList(list)
    --            local isEmpty = (#scrollData == 0)
    --            if(hasPrev) then
    --                table.insert(scrollData, 1, ZO_ScrollList_CreateDataEntry(SHOW_MORE_DATA_TYPE, showPreviousPageEntry))
    --            end
    --            if(isEmpty) then
    --                scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(HAS_HIDDEN_DATA_TYPE, {})
    --            end
    --            if(hasNext) then
    --                scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(SHOW_MORE_DATA_TYPE, showNextPageEntry)
    --            end
    --            ZO_ScrollList_Commit(list)
    --        end
    --    end)

    --    self.paging = AwesomeGuildStore.Paging:New(tradingHouseWrapper)

    tradingHouseWrapper:Wrap("UpdatePagingButtons", function(originalUpdatePagingButtons, self)
        if(showPreviousPageEntry.rowControl ~= nil) then showPreviousPageEntry.updateState(showPreviousPageEntry.rowControl) end
        if(showNextPageEntry.rowControl ~= nil) then showNextPageEntry.updateState(showNextPageEntry.rowControl) end
        originalUpdatePagingButtons(self)
    end)
end

local PER_UNIT_PRICE_CURRENCY_OPTIONS = {
    showTooltips = false,
    iconSide = RIGHT,
}
local UNIT_PRICE_FONT = "/esoui/common/fonts/univers67.otf|14|soft-shadow-thin"
local SEARCH_RESULTS_DATA_TYPE = 1
local GUILD_SPECIFIC_ITEM_DATA_TYPE = 3

local function SetUnitPrice(tradingHouse, rowControl, sellPriceControl, perItemPrice, result, unitPrice)
    ZO_CurrencyControl_SetSimpleCurrency(perItemPrice, result.currencyType, unitPrice, PER_UNIT_PRICE_CURRENCY_OPTIONS, nil, tradingHouse.playerMoney[result.currencyType] < result.purchasePrice)
    perItemPrice:SetFont(UNIT_PRICE_FONT)
    perItemPrice:SetText("@" .. perItemPrice:GetText():gsub("|t.-:.-:", "|t12:12:"))
    perItemPrice:SetHidden(false)
    sellPriceControl:ClearAnchors()
    sellPriceControl:SetAnchor(RIGHT, rowControl, RIGHT, -5, -8)
end

function SearchTabWrapper:InitializeUnitPriceDisplay(tradingHouseWrapper)
    local saveData = self.saveData
    local tradingHouse = tradingHouseWrapper.tradingHouse
    local dataType = tradingHouse.searchResultsList.dataTypes[SEARCH_RESULTS_DATA_TYPE] -- TODO use ZO_ScrollList_GetDataTypeTable(self, typeId)
    local originalSetupCallback = dataType.setupCallback

    dataType.setupCallback = function(rowControl, result) -- TODO move into search result list wrapper
        originalSetupCallback(rowControl, result)

        local sellPriceControl = rowControl:GetNamedChild("SellPrice")
        local perItemPrice = rowControl:GetNamedChild("SellPricePerUnit")
        local shouldShow = false
        if(saveData.displayPerUnitPrice) then
            -- TODO is it showing by default?
            if(not perItemPrice.__AGS_INIT) then
                sellPriceControl:ClearAnchors()
                perItemPrice:ClearAnchors()
                perItemPrice:SetAnchor(TOPRIGHT, sellPriceControl, BOTTOMRIGHT, 0, 0)
                perItemPrice.__AGS_INIT = true
            end

            if(result:GetStackCount() > 1) then
                SetUnitPrice(tradingHouse, rowControl, sellPriceControl, perItemPrice, result, result.purchasePricePerUnit)
                shouldShow = true
            end
        end

        if(not shouldShow) then
            perItemPrice:SetHidden(true)
            sellPriceControl:ClearAnchors()
            sellPriceControl:SetAnchor(RIGHT, rowControl, RIGHT, -5, 0)
        end

        -- TODO
        local nameControl = rowControl:GetNamedChild("Name")
        nameControl:SetWidth(310)
        nameControl:SetMaxLineCount(1)

        nameControl:ClearAnchors() -- TODO should probably check if anchor really needs to change -> test performance impact
        local offsetY = 0
        local sellerName = rowControl:GetNamedChild("SellerName")
        if(saveData.displaySellerName or true) then -- TODO or sortOrder == sellerName
            offsetY = -8
            if(not sellerName) then
                sellerName = rowControl:CreateControl("$(parent)SellerName", CT_LABEL)
                sellerName:SetAnchor(TOPLEFT, nameControl, BOTTOMLEFT, 10, 0)
                sellerName:SetFont(UNIT_PRICE_FONT)
                sellerName:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
            end
            sellerName:SetText(gettext("Seller:|cffffff %s"):format(result.sellerName))
        elseif(sellerName) then
            sellerName:SetHidden(true)
            sellerName:SetText("")
        end
        nameControl:SetAnchor(LEFT, nil, LEFT, ZO_TRADING_HOUSE_SEARCH_RESULT_ITEM_ICON_MAX_WIDTH, offsetY)

        if(math.abs(result.purchasePrice / result:GetStackCount() - result.purchasePricePerUnitRaw) > 0.01) then -- TODO remove
            sellerName:SetColor(1, 0, 0, 1)
            sellerName:SetText("mismatch: ".. tostring(result.purchasePrice / result:GetStackCount() - result.purchasePricePerUnitRaw))
        else
            sellerName:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
        end

        local timeRemaining = rowControl:GetNamedChild("TimeRemaining")
        timeRemaining:SetAnchor(LEFT, nil, LEFT, 410, 0)

        local traitInfo = rowControl:GetNamedChild("TraitInfo")
        traitInfo:SetAnchor(LEFT, nil, LEFT, 380, 0)
        --        local lastSeen = rowControl:GetNamedChild("LastSeen")
        --        if(not lastSeen) then
        --            lastSeen = rowControl:CreateControl("$(parent)LastSeen", CT_LABEL)
        --            lastSeen:SetAnchor(TOPRIGHT, timeRemaining, BOTTOMRIGHT, 0, 0) -- TODO move timeRemaining up so everything is centered
        --            lastSeen:SetFont(UNIT_PRICE_FONT)
        --        end
        --        lastSeen:SetText(ZO_FormatDurationAgo(GetTimeStamp() - result.lastSeen))
    end
end

function SearchTabWrapper:PrintPurchaseMessageForEntry(entry)
    local count = entry.stackCount
    local seller = ZO_LinkHandler_CreateDisplayNameLink(entry.sellerName)
    local price = ZO_Currency_FormatPlatform(CURT_MONEY, entry.purchasePrice, ZO_CURRENCY_FORMAT_AMOUNT_ICON)
    local itemLink = AdjustLinkStyle(entry.itemLink, LINK_STYLE_BRACKETS)
    local guildName = entry.guildName
    -- TRANSLATORS: chat message when an item is bought from the store. <<1>> is replaced with the item count, <<t:2>> with the item link, <<3>> with the seller name, <<4>> with price and <<5>> with the guild store name. e.g. You have bought 1x [Rosin] from sirinsidiator for 5000g in Imperial Trading Company
    local message = gettext("You have bought <<1>>x <<t:2>> from <<3>> for <<4>> in <<5>>", count, itemLink, seller, price, guildName)
    Print(message)
end

function SearchTabWrapper:IsTradingHouseSearchResultPurchased(slotIndex) -- TODO: remove
    local entry = self.masterList[slotIndex]
    return (entry ~= nil) and entry.purchased
end

function SearchTabWrapper:GetTradingHouseSearchResultItemInfoAfterPurchase(slotIndex) -- TODO: remove
    self.returnPurchasedEntries = true
    local result = {GetTradingHouseSearchResultItemInfo(slotIndex)}
    self.returnPurchasedEntries = false
    return unpack(result)
end

function SearchTabWrapper:GetTradingHouseSearchResultItemLinkAfterPurchase(slotIndex, linkStyle) -- TODO: remove
    self.returnPurchasedEntries = true
    local link = GetTradingHouseSearchResultItemLink(slotIndex, linkStyle)
    self.returnPurchasedEntries = false
    return link
end

function SearchTabWrapper:InitializeSearchResultMasterList(tradingHouseWrapper) -- TODO: rename
    local test = AwesomeGuildStore.class.SearchHandler:New()
    self.searchList = AwesomeGuildStore.SearchList:New(self.searchManager) -- TODO
    self.masterList = {}
    self.numItemsOnPage = 0
    self.returnPurchasedEntries = false
    local saveData = self.saveData
    local tradingHouse = tradingHouseWrapper.tradingHouse
    local itemDatabase = tradingHouseWrapper.itemDatabase

    tradingHouse.control:UnregisterForEvent(EVENT_TRADING_HOUSE_CONFIRM_ITEM_PURCHASE)

    tradingHouseWrapper:Wrap("VerifyBuyItemAndShowErrors", function(originalVerifyBuyItemAndShowErrors, tradingHouse, inventorySlot)
        if(originalVerifyBuyItemAndShowErrors(tradingHouse, inventorySlot)) then
            local entry = ZO_ScrollList_GetData(inventorySlot:GetParent())
            if(not entry) then
                -- logger:Warn("no item for current inventorySlot")
                Zgoo(inventorySlot) -- TODO remove
                return false
            end

            if(entry.purchased) then
                -- TODO translation comment
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
            tradingHouseWrapper.activityManager:PurchaseItem(guildId, itemData)
        end
        dialog.buttons[2].callback = function()
        -- nothing to do here
        end

        ZO_Dialogs_ShowDialog = originalZO_Dialogs_ShowDialog
        ZO_Dialogs_ShowDialog("CONFIRM_TRADING_HOUSE_PURCHASE")
        tradingHouse.ConfirmPendingPurchase = originalConfirmPendingPurchase
    end)

    AwesomeGuildStore:RegisterCallback("ItemPurchased", function(itemData) -- TODO
        if(saveData.purchaseNotification) then
            self:PrintPurchaseMessageForEntry(itemData)
    end
    itemData.purchased = true
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

    local dataType = tradingHouse.searchResultsList.dataTypes[SEARCH_RESULTS_DATA_TYPE]
    local originalSetupCallback = dataType.setupCallback
    dataType.setupCallback = function(rowControl, result) -- TODO consolidate all of these hooks
        originalSetupCallback(rowControl, result)

        local background = rowControl:GetNamedChild("Bg")
        local timeRemaining = rowControl:GetNamedChild("TimeRemaining")
        --        local lastSeen = rowControl:GetNamedChild("LastSeen")
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
        --        lastSeen:SetHidden(result.purchased or result.soldout)
    end
end

function SearchTabWrapper:InitializeKeybinds(tradingHouseWrapper) -- TODO: remove
    function AwesomeGuildStore.SuppressLocalFilters(pressed)
        self.suppressLocalFilters = pressed
        TRADING_HOUSE:RebuildSearchResultsPage()
    end
end

function SearchTabWrapper:Search(page)
    self.searchManager:RequestSearch()
end

function SearchTabWrapper:SearchPreviousPage()
    self.searchManager:RequestSearch()
end

function SearchTabWrapper:SearchNextPage()
    self.searchManager:RequestSearch()
end

function SearchTabWrapper:CancelSearch()
    self.tradingHouseWrapper.activityManager:CancelSearch()
end

function SearchTabWrapper:OnOpen(tradingHouseWrapper)
    local tradingHouse = tradingHouseWrapper.tradingHouse
    self.categorySelector:GetControl():SetHidden(false)
    self.searchList:Show()
    -- tradingHouse.m_searchAllowed = true -- TODO is this still required?
    -- tradingHouse:OnSearchCooldownUpdate(GetTradingHouseCooldownRemaining()) -- TODO is this still required?
    -- AwesomeGuildStore:FireOnOpenSearchTabCallbacks(tradingHouseWrapper) -- TODO is this still required?
    PushActionLayerByName(ACTION_LAYER_NAME) -- TODO should this action layer only be active here or better in the whole trading house?
    self.isOpen = true
end

function SearchTabWrapper:OnClose(tradingHouseWrapper)
    self.searchList:Hide()
    self.categorySelector:GetControl():SetHidden(true)
    self.tradingHouseWrapper.activityManager:CancelSearch()
    self.tradingHouseWrapper.activityManager:CancelRequestNewest()
    RemoveActionLayerByName(ACTION_LAYER_NAME)

    self.isOpen = false
end
