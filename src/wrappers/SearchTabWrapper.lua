local L = AwesomeGuildStore.Localization

local SearchTabWrapper = ZO_Object:Subclass()
AwesomeGuildStore.SearchTabWrapper = SearchTabWrapper

function SearchTabWrapper:New(saveData)
	local wrapper = ZO_Object.New(self)
	wrapper.saveData = saveData
	return wrapper
end

function SearchTabWrapper:RunInitialSetup(tradingHouseWrapper)
	self:InitializeFilters(tradingHouseWrapper)
	self:InitializeButtons(tradingHouseWrapper)
	self:InitializeSearchSortHeaders(tradingHouseWrapper)
	self:InitializeNavigation(tradingHouseWrapper)
	self:InitializeUnitPriceDisplay(tradingHouseWrapper)
end

function SearchTabWrapper:InitializeFilters(tradingHouseWrapper)
	local categoryFilter, priceSelector, levelSelector, qualitySelector, nameFilter
	local saveData = self.saveData
	local tradingHouse = tradingHouseWrapper.tradingHouse

	local browseItemsControl = tradingHouse.m_browseItems
	local common = browseItemsControl:GetNamedChild("Common")

	local searchLibrary = AwesomeGuildStore.SearchLibrary:New(saveData.searchLibrary)

	if(saveData.replaceCategoryFilter) then
		local header = browseItemsControl:GetNamedChild("Header")
		header:ClearAnchors()
		header:SetAnchor(TOPLEFT, common:GetParent(), TOPLEFT, 0, -43)

		browseItemsControl:GetNamedChild("ItemCategory"):SetHidden(true)
		categoryFilter = AwesomeGuildStore.CategorySelector:New(browseItemsControl, "AwesomeGuildStoreItemCategory")
		categoryFilter.control:ClearAnchors()
		categoryFilter.control:SetAnchor(TOPLEFT, header, TOPRIGHT, 70, -10)

		local itemPane = ZO_TradingHouse:GetNamedChild("ItemPane")
		itemPane:SetAnchor(TOPLEFT, categoryFilter.control, BOTTOMLEFT, 0, 20)

		searchLibrary:RegisterFilter(categoryFilter)

		common:ClearAnchors()
		common:SetAnchor(TOPLEFT, common:GetParent(), TOPLEFT, 0, -10)
		common:SetAnchor(TOPRIGHT, common:GetParent(), TOPRIGHT, 0, -10)
	end

	if(saveData.replacePriceFilter) then
		priceSelector = AwesomeGuildStore.PriceSelector:New(common, "AwesomeGuildStorePriceRange")
		priceSelector.slider.control:ClearAnchors()
		priceSelector.slider.control:SetAnchor(TOPLEFT, common:GetNamedChild("PriceRangeLabel"), BOTTOMLEFT, 0, 5)
		local minPrice = common:GetNamedChild("MinPrice")
		minPrice:ClearAnchors()
		minPrice:SetAnchor(TOPLEFT, priceSelector.slider.control, BOTTOMLEFT, 0, 5)

		searchLibrary:RegisterFilter(priceSelector)
	end

	if(saveData.replaceLevelFilter) then
		levelSelector = AwesomeGuildStore.LevelSelector:New(common, "AwesomeGuildStoreLevelRange")
		local minPrice = common:GetNamedChild("MinPrice")
		local minLevel = common:GetNamedChild("MinLevel")
		local levelRangeLabel = common:GetNamedChild("LevelRangeLabel")
		local levelRangeToggle = common:GetNamedChild("LevelRangeToggle")

		levelRangeLabel:ClearAnchors()
		levelRangeLabel:SetAnchor(TOPLEFT, minPrice, BOTTOMLEFT, 0, 10)

		levelSelector.slider.control:ClearAnchors()
		levelSelector.slider.control:SetAnchor(TOPLEFT, levelRangeLabel, BOTTOMLEFT, 0, 5)

		levelRangeToggle:ClearAnchors()
		levelRangeToggle:SetAnchor(TOPLEFT, levelSelector.slider.control, BOTTOMLEFT, 0, 5)

		minLevel:ClearAnchors()
		minLevel:SetAnchor(LEFT, levelRangeToggle, RIGHT, 0, 0)

		searchLibrary:RegisterFilter(levelSelector)
	end

	if(saveData.replaceQualityFilter) then
		qualitySelector = AwesomeGuildStore.QualitySelector:New(common, "AwesomeGuildStoreQualityButtons", saveData)
		qualitySelector.control:ClearAnchors()
		local parent = saveData.replaceLevelFilter and common:GetNamedChild("LevelRangeToggle") or common:GetNamedChild("MinLevel")
		qualitySelector.control:SetAnchor(TOPLEFT, parent, BOTTOMLEFT, 0, 10)

		local qualityControl = common:GetNamedChild("Quality")
		qualityControl:ClearAnchors()
		qualityControl:SetAnchor(TOPLEFT, common, TOPLEFT, 0, 350)
		qualityControl:SetHidden(true)

		searchLibrary:RegisterFilter(qualitySelector)
	elseif(saveData.replaceLevelFilter) then
		local qualityControl = common:GetNamedChild("Quality")
		qualityControl:ClearAnchors()
		qualityControl:SetAnchor(TOPLEFT, common:GetNamedChild("LevelRangeToggle"), BOTTOMLEFT, 0, 10)
	end

	nameFilter = AwesomeGuildStore.ItemNameQuickFilter:New(ZO_TradingHouseItemPaneSearchSortBy, "AwesomeGuildStoreNameFilterInput", 90, 2)
	searchLibrary:RegisterFilter(nameFilter)

	if(saveData.keepFiltersOnClose) then
		searchLibrary:Deserialize(saveData.searchLibrary.lastState)
	end
	searchLibrary:Serialize()

	self.categoryFilter = categoryFilter
	self.priceSelector = priceSelector
	self.levelSelector = levelSelector
	self.qualitySelector = qualitySelector
	self.nameFilter = nameFilter
end

function SearchTabWrapper:InitializeButtons(tradingHouseWrapper)
	local saveData = self.saveData
	local tradingHouse = tradingHouseWrapper.tradingHouse

	local browseItemsControl = tradingHouse.m_browseItems
	local common = browseItemsControl:GetNamedChild("Common")

	local searchButton = CreateControlFromVirtual("AwesomeGuildStoreStartSearchButton", common, "ZO_DefaultButton")
	searchButton:SetWidth(common:GetWidth())
	if(saveData.replaceCategoryFilter) then
		searchButton:SetAnchor(TOP, common, BOTTOM, 0, 345)
	else
		local parent = saveData.replaceQualityFilter and self.qualitySelector.control or common
		searchButton:SetAnchor(TOP, parent, BOTTOM, 0, 25)
	end
	searchButton:SetText(L["START_SEARCH_LABEL"])
	searchButton:SetHandler("OnMouseUp",function(control, button, isInside)
		if(control:GetState() == BSTATE_NORMAL and button == 1 and isInside) then
			if(tradingHouse:CanSearch()) then
				tradingHouse:DoSearch()
			end
		end
	end)
	self.searchButton = searchButton

	local RESET_BUTTON_SIZE = 24
	local RESET_BUTTON_TEXTURE = "EsoUI/Art/Buttons/decline_%s.dds"

	local resetButton = AwesomeGuildStore.SimpleIconButton:New("AwesomeGuildStoreFilterResetButton", RESET_BUTTON_TEXTURE, RESET_BUTTON_SIZE, L["RESET_ALL_FILTERS_LABEL"])
	resetButton:SetAnchor(TOPRIGHT, browseItemsControl:GetNamedChild("Header"), TOPLEFT, 196, 0)
	resetButton.OnClick = function()
		local originalClearSearchResults = tradingHouse.ClearSearchResults
		tradingHouse.ClearSearchResults = function() end
		tradingHouse:ResetAllSearchData(true)
		tradingHouse.ClearSearchResults = originalClearSearchResults
	end

	tradingHouseWrapper:PreHook("ResetAllSearchData", function(tradingHouse, doReset)
		if(doReset or not saveData.keepFiltersOnClose) then
			if(self.categoryFilter) then self.categoryFilter:Reset() end
			if(self.priceSelector) then self.priceSelector:Reset() end
			if(self.levelSelector) then self.levelSelector:Reset() else
				tradingHouse.m_levelRangeFilterType = TRADING_HOUSE_FILTER_TYPE_LEVEL
				tradingHouse.m_levelRangeToggle:SetState(BSTATE_NORMAL, false)
				tradingHouse.m_levelRangeLabel:SetText(GetString(SI_TRADING_HOUSE_BROWSE_LEVEL_RANGE_LABEL))
			end
			if(self.qualitySelector) then self.qualitySelector:Reset() end
			if(self.nameFilter) then self.nameFilter:Reset() end
			saveData.lastState = DEFAULT_SEARCH_STATE
			if(doReset) then return end
		end
		tradingHouse:ClearSearchResults()
		if(not saveData.keepFiltersOnClose) then return end
		return true
	end)
end

function SearchTabWrapper:InitializeSearchSortHeaders(tradingHouseWrapper)
	local saveData = self.saveData
	local tradingHouse = tradingHouseWrapper.tradingHouse
	local search = tradingHouse.m_search

	search.InitializeOrderingData = function(self)
		if(saveData.keepSortOrderOnClose) then
			self.ResetOrderingData = function() end
			self.m_sortField = saveData.sortField
			self.m_sortOrder = saveData.sortOrder

			local sortHeader = tradingHouse.m_searchSortHeaders
			local oldEnabled = sortHeader.enabled
			sortHeader.enabled = true -- force it enabled for a bit, otherwise it won't update
			sortHeader:SelectHeaderByKey(self.m_sortField, ZO_SortHeaderGroup.SUPPRESS_CALLBACKS, true)
			if(not self.m_sortOrder) then -- call it a second time to invert the sort order
				sortHeader:SelectHeaderByKey(self.m_sortField, ZO_SortHeaderGroup.SUPPRESS_CALLBACKS)
			end
			sortHeader.enabled = oldEnabled
		else
			self.m_sortField = TRADING_HOUSE_SORT_SALE_PRICE
			self.m_sortOrder = ZO_SORT_ORDER_UP
		end
	end
	search:InitializeOrderingData()

	tradingHouseWrapper:PreHook("UpdateSortHeaders", function(self)
		if(self.m_numItemsOnPage == 0 or saveData.sortWithoutSearch) then
			self.m_searchSortHeaders:SetEnabled(true)
			return true
		end
	end)

	ZO_PreHook(search, "ChangeSort", function(self, sortKey, sortOrder)
		saveData.sortField = sortKey
		saveData.sortOrder = sortOrder
		if(tradingHouse.m_numItemsOnPage == 0 or saveData.sortWithoutSearch) then
			self:UpdateSortOption(sortKey, sortOrder)
			return true
		end
	end)
end

function SearchTabWrapper:InitializeNavigation(tradingHouseWrapper)
	local SHOW_MORE_DATA_TYPE = 4 -- watch out for changes in tradinghouse.lua
	local tradingHouse = tradingHouseWrapper.tradingHouse
	local search = tradingHouse.m_search

	local function IsReady()
		return GetTradingHouseCooldownRemaining() == 0
	end

	local showPreviousPageEntry =  {
		label = L["SEARCH_PREVIOUS_PAGE_LABEL"],
		callback = function() search:SearchPreviousPage() end,
		updateState = function(rowControl)
			rowControl:SetEnabled(IsReady())
		end
	}

	local showNextPageEntry =  {
		label = L["SEARCH_SHOW_MORE_LABEL"],
		callback = function() search:SearchNextPage() end,
		updateState = function(rowControl)
			rowControl:SetEnabled(IsReady())
		end
	}

	ZO_ScrollList_AddDataType(tradingHouse.m_searchResultsList, SHOW_MORE_DATA_TYPE, "AwesomeGuildStoreShowMoreRowTemplate", 32, function(rowControl, entry)
		local label = rowControl:GetNamedChild("Text")
		label:SetText(entry.label)
		rowControl.label = label

		local highlight = rowControl:GetNamedChild("Highlight")
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
				entry.callback()
			end
		end)

		rowControl.SetEnabled = function(self, enabled)
			rowControl.enabled = enabled
			highlight.animation:GetFirstAnimation():SetAlphaValues(0.5, enabled and 1 or 0.5)
			label:SetColor((enabled and ZO_NORMAL_TEXT or ZO_DEFAULT_DISABLED_COLOR):UnpackRGBA())
		end

		entry.updateState(rowControl)
		rowControl.entry = entry
		entry.rowControl = rowControl
	end, nil, nil, function(rowControl)
		rowControl.enabled = nil
		rowControl.label = nil
		rowControl.SetEnabled = nil
		rowControl.entry.rowControl = nil
		rowControl.entry = nil
		ZO_ObjectPool_DefaultResetControl(rowControl)
	end)

	tradingHouseWrapper:Wrap("RebuildSearchResultsPage", function(originalRebuildSearchResultsPage, self)
		originalRebuildSearchResultsPage(self)

		local hasPrev = search:HasPreviousPage()
		local hasNext = search:HasNextPage()
		if(hasPrev or hasNext) then
			local list = self.m_searchResultsList
			local scrollData = ZO_ScrollList_GetDataList(list)
			if(hasPrev) then
				table.insert(scrollData, 1, ZO_ScrollList_CreateDataEntry(SHOW_MORE_DATA_TYPE, showPreviousPageEntry))
			end
			if(hasNext) then
				scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(SHOW_MORE_DATA_TYPE, showNextPageEntry)
			end
			ZO_ScrollList_Commit(list)
		end
	end)

	local navBar = tradingHouse.m_nagivationBar
	local currentPageLabel = navBar:CreateControl("AwesomeGuildStoreCurrentPageLabel", CT_LABEL)
	currentPageLabel:SetAnchor(TOP, navBar, TOPCENTER, 0, 5)
	currentPageLabel:SetFont("ZoFontGameLarge")
	currentPageLabel:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())

	local function UpdatePageLabel(page, hasNextOrPrevious)
		page = tonumber(page) + 1
		currentPageLabel:SetText(page)
		currentPageLabel:SetHidden(page <= 0 or not hasNextOrPrevious)
	end

	tradingHouseWrapper:PreHook("UpdatePagingButtons", function(self)
		UpdatePageLabel(search.m_page, search:HasNextPage() or search:HasPreviousPage())
		if(showPreviousPageEntry.rowControl ~= nil) then showPreviousPageEntry.updateState(showPreviousPageEntry.rowControl) end
		if(showNextPageEntry.rowControl ~= nil) then showNextPageEntry.updateState(showNextPageEntry.rowControl) end
	end)
end

function SearchTabWrapper:InitializeUnitPriceDisplay(tradingHouseWrapper)
	local PER_UNIT_PRICE_CURRENCY_OPTIONS = {
		showTooltips = false,
		iconSide = RIGHT,
	}
	local UNIT_PRICE_FONT = "/esoui/common/fonts/univers67.otf|14|soft-shadow-thin"
	local SEARCH_RESULTS_DATA_TYPE = 1

	local saveData = self.saveData
	local tradingHouse = tradingHouseWrapper.tradingHouse
	local dataType = tradingHouse.m_searchResultsList.dataTypes[SEARCH_RESULTS_DATA_TYPE]
	local originalSetupCallback = dataType.setupCallback

	dataType.setupCallback = function(rowControl, result)
		originalSetupCallback(rowControl, result)

		local sellPriceControl = rowControl:GetNamedChild("SellPrice")
		local perItemPrice = rowControl:GetNamedChild("SellPricePerItem")
		if(saveData.displayPerUnitPrice) then
			if(not perItemPrice) then
				local controlName = rowControl:GetName() .. "SellPricePerItem"
				perItemPrice = rowControl:CreateControl(controlName, CT_LABEL)
				perItemPrice:SetAnchor(TOPRIGHT, sellPriceControl, BOTTOMRIGHT, 0, 0)
				perItemPrice:SetFont(UNIT_PRICE_FONT)
			end

			if(result.stackCount > 1) then
				local unitPrice = tonumber(string.format("%.2f", result.purchasePrice / result.stackCount))
				ZO_CurrencyControl_SetSimpleCurrency(perItemPrice, result.currencyType, unitPrice, PER_UNIT_PRICE_CURRENCY_OPTIONS, nil, tradingHouse.m_playerMoney[result.currencyType] < result.purchasePrice)
				perItemPrice:SetText("@" .. perItemPrice:GetText():gsub("|t.-:.-:", "|t12:12:"))
				perItemPrice:SetHidden(false)
				sellPriceControl:ClearAnchors()
				sellPriceControl:SetAnchor(RIGHT, rowControl, RIGHT, -5, -8)
				perItemPrice = nil
			end
		end

		if(perItemPrice) then
			perItemPrice:SetHidden(true)
			sellPriceControl:ClearAnchors()
			sellPriceControl:SetAnchor(RIGHT, rowControl, RIGHT, -5, 0)
		end
	end
end

function SearchTabWrapper:EnableSearchButton()
	self.searchButton:SetEnabled(true)
end

function SearchTabWrapper:DisableSearchButton()
	self.searchButton:SetEnabled(false)
end

function SearchTabWrapper:OnOpen(tradingHouseWrapper)
	local tradingHouse = tradingHouseWrapper.tradingHouse
	tradingHouseWrapper:SetLoadingOverlayParent(ZO_TradingHouseItemPaneSearchResults)
	tradingHouse.m_searchAllowed = true
	tradingHouse:OnSearchCooldownUpdate(GetTradingHouseCooldownRemaining())
end

function SearchTabWrapper:OnClose(tradingHouseWrapper)
end