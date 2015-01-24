local ADDON_NAME = "AwesomeGuildStore"
local DEFAULT_SEARCH_STATE = "1:-:-:-:-:-"

AwesomeGuildStore = {}
AwesomeGuildStore.DEFAULT_SEARCH_STATE = DEFAULT_SEARCH_STATE

local nextEventHandleIndex = 1

local function RegisterForEvent(event, callback)
	local eventHandleName = ADDON_NAME .. nextEventHandleIndex
	EVENT_MANAGER:RegisterForEvent(eventHandleName, event, callback)
	nextEventHandleIndex = nextEventHandleIndex + 1
	return eventHandleName
end

local function UnregisterForEvent(event, name)
	EVENT_MANAGER:UnregisterForEvent(name, event)
end

local function OnAddonLoaded(callback)
	local eventHandle = ""
	eventHandle = RegisterForEvent(EVENT_ADD_ON_LOADED, function(event, name)
		if(name ~= ADDON_NAME) then return end
		callback()
		UnregisterForEvent(event, name)
	end)
end

AwesomeGuildStore.RegisterForEvent = RegisterForEvent
-----------------------------------------------------------------------------------------

local L
local comboBox
local guildSelector
local entryByGuildId
local filtersInitialized
local saveData
local priceSelector
local levelSelector
local qualitySelector
local categoryFilter
local searchButton
local nameFilter
local searchLibrary
local salesCategoryFilter
local loadingBlocker

function AwesomeGuildStore.InitializeGuildSelector(control)
	local comboBoxControl = GetControl(control, "ComboBox")
	comboBox = ZO_ComboBox_ObjectFromContainer(comboBoxControl)
	comboBox:SetSortsItems(false)
	comboBox:SetSelectedItemFont("ZoFontWindowTitle")
	comboBox:SetDropdownFont("ZoFontHeader2")
	comboBox:SetSpacing(8)
	guildSelector = control
end

local function OnGuildChanged(comboBox, selectedName, selectedEntry)
	if(SelectTradingHouseGuildId(selectedEntry.guildId)) then
		TRADING_HOUSE:UpdateForGuildChange()
		if(TRADING_HOUSE.m_currentMode == "tradingHouseListings") then
			TRADING_HOUSE:RequestListings()
		end
	end
end

local function SortEntriesByGuildId(entryA, entryB)
	return entryA.guildId < entryB.guildId
end

local function InitializeGuildSelector(lastGuildId)
	comboBox:ClearItems()
	comboBox:SetSortsItems(false)
	entryByGuildId = {}
	local entries = {}

	local selectedEntry, firstEntry, prevEntry

	for i = 1, GetNumTradingHouseGuilds() do
		local guildId, guildName, guildAlliance = GetTradingHouseGuildDetails(i)
		local iconPath = GetAllianceBannerIcon(guildAlliance)
		if(iconPath == nil) then
			ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.GENERAL_ALERT_ERROR, L["INVALID_STATE"])
		end
		local entryText = iconPath and zo_iconTextFormat(iconPath, 36, 36, guildName) or guildName
		local entry = comboBox:CreateItemEntry(entryText, OnGuildChanged)
		entry.guildId = guildId
		entry.selectedText = guildName
		entry.canSell = CanSellOnTradingHouse(guildId)
		table.insert(entries, entry)

		if(not selectedEntry or (lastGuildId and guildId == lastGuildId)) then
			selectedEntry = entry
		end
		entryByGuildId[guildId] = entry

		if(prevEntry) then
			prevEntry.next = entry
			entry.prev = prevEntry
		end

		if(i == 1) then
			firstEntry = entry
		end
		prevEntry = entry
	end
	prevEntry.next = firstEntry
	firstEntry.prev = prevEntry

	table.sort(entries, SortEntriesByGuildId)
	comboBox:AddItems(entries)
	OnGuildChanged(comboBox, selectedEntry.name, selectedEntry)
end

local function ReselectLastGuild()
	local guildId, guildName = GetCurrentTradingHouseGuildDetails()
	if(saveData.lastGuildName and saveData.lastGuildName ~= guildName) then
		for i = 1, GetNumTradingHouseGuilds() do
			guildId, guildName = GetTradingHouseGuildDetails(i)
			if(guildName == saveData.lastGuildName) then
				if(SelectTradingHouseGuildId(guildId)) then
					TRADING_HOUSE:UpdateForGuildChange()
				end
				break
			end
		end
	end
	local _, guildName = GetCurrentTradingHouseGuildDetails()
	saveData.lastGuildName = guildName
	return guildId
end

function AwesomeGuildStore.GuildSelectorOnMouseWheel(control, delta, ctrl, alt, shift)
	local selectedEntry = entryByGuildId[GetSelectedTradingHouseGuildId()]
	if(selectedEntry) then
		local newEntry = selectedEntry
		local sellMode = TRADING_HOUSE:IsInPostMode()

		repeat
			if(delta < 0) then
				newEntry = newEntry.next
			elseif(delta > 0) then
				newEntry = newEntry.prev
			end
		until not sellMode or newEntry.canSell or newEntry == selectedEntry

		if(newEntry ~= selectedEntry) then
			OnGuildChanged(comboBox, newEntry.name, newEntry)
		end
	end
end

local function InitializeUnitPriceDisplay()
	local PER_UNIT_PRICE_CURRENCY_OPTIONS = {
		showTooltips = false,
		iconSide = RIGHT,
	}
	local UNIT_PRICE_FONT = "/esoui/common/fonts/univers67.otf|14|soft-shadow-thin"

	local dataType = TRADING_HOUSE.m_searchResultsList.dataTypes[1]
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
				ZO_CurrencyControl_SetSimpleCurrency(perItemPrice, result.currencyType, unitPrice, PER_UNIT_PRICE_CURRENCY_OPTIONS, nil, TRADING_HOUSE.m_playerMoney[result.currencyType] < result.purchasePrice)
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

local function InitializeFilters(control)
	if(filtersInitialized) then return end
	TRADING_HOUSE.m_numItemsOnPage = 0

	searchLibrary = AwesomeGuildStore.SearchLibrary:New(saveData.searchLibrary)

	local common = control:GetNamedChild("Common")

	if(saveData.replaceCategoryFilter) then
		local header = control:GetNamedChild("Header")
		header:ClearAnchors()
		header:SetAnchor(TOPLEFT, common:GetParent(), TOPLEFT, 0, -43)

		control:GetNamedChild("ItemCategory"):SetHidden(true)
		categoryFilter = AwesomeGuildStore.CategorySelector:New(control, ADDON_NAME .. "ItemCategory")
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
		priceSelector = AwesomeGuildStore.PriceSelector:New(common, ADDON_NAME .. "PriceRange")
		priceSelector.slider.control:ClearAnchors()
		priceSelector.slider.control:SetAnchor(TOPLEFT, common:GetNamedChild("PriceRangeLabel"), BOTTOMLEFT, 0, 5)
		local minPrice = common:GetNamedChild("MinPrice")
		minPrice:ClearAnchors()
		minPrice:SetAnchor(TOPLEFT, priceSelector.slider.control, BOTTOMLEFT, 0, 5)

		searchLibrary:RegisterFilter(priceSelector)
	end

	if(saveData.replaceLevelFilter) then
		levelSelector = AwesomeGuildStore.LevelSelector:New(common, ADDON_NAME .. "LevelRange")
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
		qualitySelector = AwesomeGuildStore.QualitySelector:New(common, ADDON_NAME .. "QualityButtons", saveData)
		qualitySelector.control:ClearAnchors()
		local parent = levelSelector and common:GetNamedChild("LevelRangeToggle") or common:GetNamedChild("MinLevel")
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

	searchButton = CreateControlFromVirtual(ADDON_NAME .. "StartSearchButton", common, "ZO_DefaultButton")
	searchButton:SetWidth(common:GetWidth())
	if(categoryFilter) then
		searchButton:SetAnchor(TOP, common, BOTTOM, 0, 345)
	else
		local parent = qualitySelector and qualitySelector.control or common
		searchButton:SetAnchor(TOP, parent, BOTTOM, 0, 25)
	end
	searchButton:SetText(L["START_SEARCH_LABEL"])
	searchButton:SetHandler("OnMouseUp",function(control, button, isInside)
		if(control:GetState() == BSTATE_NORMAL and button == 1 and isInside) then
			if(TRADING_HOUSE:CanSearch()) then
				TRADING_HOUSE:DoSearch()
			end
		end
	end)

	loadingBlocker = ZO_TradingHouseItemPaneSearchResults:CreateControl(ADDON_NAME .. "Loading", CT_BACKDROP)
	loadingBlocker:SetAnchor(TOPLEFT, ZO_TradingHouseItemPaneSearchResults, TOPLEFT, -10, -10)
	loadingBlocker:SetAnchor(BOTTOMRIGHT, ZO_TradingHouseItemPaneSearchResults, BOTTOMRIGHT, 10, 10)
	loadingBlocker:SetHidden(true)
	loadingBlocker:SetMouseEnabled(true)
	loadingBlocker:SetDrawLayer(1)
	loadingBlocker:SetIntegralWrapping(true)
	loadingBlocker:SetCenterTexture("EsoUI/Art/ChatWindow/chat_BG_center.dds")
	loadingBlocker:SetEdgeTexture("EsoUI/Art/ChatWindow/chat_BG_edge.dds", 256, 256, 32)
	loadingBlocker:SetInsets(32, 32, -32, -32)
	local loadingIcon = CreateControlFromVirtual(ADDON_NAME .. "LoadingIcon", control, "AwesomeGuildStoreLoadingTemplate")
	loadingIcon:SetParent(loadingBlocker)
	loadingIcon:SetAnchor(CENTER, loadingBlocker, CENTER, 0, 0)
	loadingIcon.animation = ANIMATION_MANAGER:CreateTimelineFromVirtual("LoadIconAnimation", loadingIcon:GetNamedChild("Icon"))

	ZO_PreHook("ExecuteTradingHouseSearch", function(self)
		searchButton:SetEnabled(false)
		comboBox:SetEnabled(false)
		loadingBlocker:SetHidden(false)
		loadingIcon.animation:PlayForward()
	end)

	local function HideLoadingOverlay()
		loadingBlocker:SetHidden(true)
		loadingIcon.animation:Stop()
	end

	RegisterForEvent(EVENT_TRADING_HOUSE_SEARCH_COOLDOWN_UPDATE, function(_, cooldownMilliseconds)
		if(cooldownMilliseconds ~= 0) then return end
		searchButton:SetEnabled(true)
		comboBox:SetEnabled(true)
		TRADING_HOUSE.m_searchAllowed = true
		TRADING_HOUSE:OnSearchCooldownUpdate(cooldownMilliseconds)
		HideLoadingOverlay()
	end)

	RegisterForEvent(EVENT_TRADING_HOUSE_SEARCH_RESULTS_RECEIVED, HideLoadingOverlay)
	RegisterForEvent(EVENT_TRADING_HOUSE_OPERATION_TIME_OUT, HideLoadingOverlay)
	RegisterForEvent(EVENT_TRADING_HOUSE_STATUS_RECEIVED, HideLoadingOverlay)

	local RESET_BUTTON_SIZE = 24
	local RESET_BUTTON_TEXTURE = "EsoUI/Art/Buttons/decline_%s.dds"

	local resetButton = CreateControlFromVirtual(ADDON_NAME .. "FilterResetButton", control, "ZO_DefaultButton")
	resetButton:SetNormalTexture(RESET_BUTTON_TEXTURE:format("up"))
	resetButton:SetPressedTexture(RESET_BUTTON_TEXTURE:format("down"))
	resetButton:SetMouseOverTexture(RESET_BUTTON_TEXTURE:format("over"))
	resetButton:SetEndCapWidth(0)
	resetButton:SetDimensions(RESET_BUTTON_SIZE, RESET_BUTTON_SIZE)
	resetButton:SetAnchor(TOPRIGHT, control:GetNamedChild("Header"), TOPLEFT, 196, 0)
	resetButton:SetHandler("OnMouseUp",function(control, button, isInside)
		if(button == 1 and isInside) then
			local originalClearSearchResults = TRADING_HOUSE.ClearSearchResults
			TRADING_HOUSE.ClearSearchResults = function() end
			TRADING_HOUSE:ResetAllSearchData(true)
			TRADING_HOUSE.ClearSearchResults = originalClearSearchResults
		end
	end)
	resetButton:SetHandler("OnMouseEnter", function()
		InitializeTooltip(InformationTooltip)
		InformationTooltip:ClearAnchors()
		InformationTooltip:SetOwner(resetButton, BOTTOM, 5, 0)
		SetTooltipText(InformationTooltip, L["RESET_ALL_FILTERS_LABEL"])
	end)
	resetButton:SetHandler("OnMouseExit", function()
		ClearTooltip(InformationTooltip)
	end)

	nameFilter = AwesomeGuildStore.ItemNameQuickFilter:New(ZO_TradingHouseItemPaneSearchSortBy, ADDON_NAME .. "NameFilterInput", 90, 2)
	searchLibrary:RegisterFilter(nameFilter)

	if(saveData.keepFiltersOnClose) then
		searchLibrary:Deserialize(saveData.searchLibrary.lastState)
	end
	searchLibrary:Serialize()

	local SHOW_MORE_DATA_TYPE = 4 -- watch out for changes in tradinghouse.lua
	local UpdateShowMoreRow = nil

	ZO_ScrollList_AddDataType(TRADING_HOUSE.m_searchResultsList, SHOW_MORE_DATA_TYPE, "AwesomeGuildStoreShowMoreRowTemplate", 32, function(rowControl, entry)
		local label = rowControl:GetNamedChild("Text")
		label:SetText(L["SEARCH_SHOW_MORE_LABEL"])
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
				TRADING_HOUSE.m_search:SearchNextPage()
			end
		end)

		rowControl.SetEnabled = function(self, enabled)
			rowControl.enabled = enabled
			highlight.animation:GetFirstAnimation():SetAlphaValues(0.5, enabled and 1 or 0.5)
			label:SetColor((enabled and ZO_NORMAL_TEXT or ZO_DEFAULT_DISABLED_COLOR):UnpackRGBA())
		end

		UpdateShowMoreRow = function()
			rowControl:SetHidden(not TRADING_HOUSE.m_search:HasNextPage())
			rowControl:SetEnabled(GetTradingHouseCooldownRemaining() == 0)
		end
		UpdateShowMoreRow()
	end, nil, nil, function(rowControl)
		rowControl.enabled = nil
		rowControl.label = nil
		rowControl.SetEnabled = nil
		ZO_ObjectPool_DefaultResetControl(rowControl)
		UpdateShowMoreRow = nil
	end)

	local originalRebuildSearchResultsPage = TRADING_HOUSE.RebuildSearchResultsPage
	TRADING_HOUSE.RebuildSearchResultsPage = function(self)
		originalRebuildSearchResultsPage(self)

		if(self.m_search:HasNextPage()) then
			local list = self.m_searchResultsList
			local scrollData = ZO_ScrollList_GetDataList(list)
			scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(SHOW_MORE_DATA_TYPE, {})
			ZO_ScrollList_Commit(list)
		end
	end

	local navBar = TRADING_HOUSE.m_nagivationBar
	local currentPageLabel = navBar:CreateControl(ADDON_NAME .. "CurrentPageLabel", CT_LABEL)
	currentPageLabel:SetAnchor(TOP, navBar, TOPCENTER, 0, 5)
	currentPageLabel:SetFont("ZoFontGameLarge")
	currentPageLabel:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())

	local function UpdatePageLabel(page, hasNextOrPrevious)
		page = tonumber(page) + 1
		currentPageLabel:SetText(page)
		currentPageLabel:SetHidden(page <= 0 or not hasNextOrPrevious)
	end

	ZO_PreHook(TRADING_HOUSE, "UpdatePagingButtons", function(self)
		local search = self.m_search
		UpdatePageLabel(search.m_page, search:HasNextPage() or search:HasPreviousPage())
		if(not UpdateShowMoreRow) then return end
		UpdateShowMoreRow()
	end)

	filtersInitialized = true

	InitializeUnitPriceDisplay()
end

OnAddonLoaded(function()
	saveData = AwesomeGuildStore.InitializeSettings()
	L = AwesomeGuildStore.Localization

	local title = TRADING_HOUSE.m_control:GetNamedChild("Title")
	local titleLabel = title:GetNamedChild("Label")
	CreateControlFromVirtual(ADDON_NAME .. "GuildSelector", title, ADDON_NAME .. "GuildSelectorTemplate")

	AwesomeGuildStore.toolTip = AwesomeGuildStore.SavedSearchTooltip:New()

	local isSearchDisabled = false
	local keybindButtonDescriptor, oldEnabled, oldCallback

	local function DisableKeybindStripSearchButton()
		local keybindStripButton = KEYBIND_STRIP.keybinds["UI_SHORTCUT_SECONDARY"]
		if(keybindStripButton and isSearchDisabled and not keybindButtonDescriptor) then
			keybindButtonDescriptor = keybindStripButton.keybindButtonDescriptor
			oldEnabled = keybindButtonDescriptor.enabled
			oldCallback = keybindButtonDescriptor.callback

			keybindButtonDescriptor.enabled = false
			keybindButtonDescriptor.callback = function() end
			KEYBIND_STRIP:UpdateKeybindButton(keybindButtonDescriptor)
		end
	end

	local function EnableKeybindStripSearchButton()
		if(keybindButtonDescriptor and isSearchDisabled) then
			keybindButtonDescriptor.enabled = oldEnabled
			keybindButtonDescriptor.callback = oldCallback
			KEYBIND_STRIP:UpdateKeybindButton(keybindButtonDescriptor)
			keybindButtonDescriptor = nil
		end
	end

	RegisterForEvent(EVENT_OPEN_TRADING_HOUSE, function()
		isSearchDisabled = true
		searchButton:SetEnabled(false)
		comboBox:SetEnabled(false)
		loadingBlocker:SetHidden(true)
		DisableKeybindStripSearchButton()
		if(salesCategoryFilter) then
			salesCategoryFilter:Reset()
		end
	end)

	RegisterForEvent(EVENT_TRADING_HOUSE_STATUS_RECEIVED, function()
		local guildId = GetSelectedTradingHouseGuildId()

		if(GetTradingHouseCooldownRemaining() == 0) then
			searchButton:SetEnabled(true)
			comboBox:SetEnabled(true)
		end
		EnableKeybindStripSearchButton()
		isSearchDisabled = false

		if not guildId then -- it's a trader when guildId is nil
			titleLabel:SetHidden(false)
			guildSelector:SetHidden(true)
		else
			guildId = ReselectLastGuild()
			InitializeGuildSelector(guildId)
			titleLabel:SetHidden(true)
			guildSelector:SetHidden(false)
		end
	end)

	RegisterForEvent(EVENT_CLOSE_TRADING_HOUSE, function()
		guildSelector:SetHidden(true)
	end)

	local function UpdateSelectedGuild()
		local guildId = GetSelectedTradingHouseGuildId()
		if(guildId and entryByGuildId and entryByGuildId[guildId]) then
			comboBox:SetSelectedItem(entryByGuildId[guildId].name)
		end
		local _, guildName = GetCurrentTradingHouseGuildDetails()
		saveData.lastGuildName = guildName
	end

	ZO_PreHook(TRADING_HOUSE, "UpdateForGuildChange", function()
		DisableKeybindStripSearchButton()
		UpdateSelectedGuild()
	end)

	local originalSelectTradingHouseGuildId = SelectTradingHouseGuildId
	SelectTradingHouseGuildId = function(...)
		local result = {originalSelectTradingHouseGuildId(...)}
		UpdateSelectedGuild()
		return unpack(result)
	end

	ZO_PreHook(TRADING_HOUSE, "OnListingsRequestSuccess", function()
		TRADING_HOUSE:UpdateListingCounts()
	end)

	local listingControl, infoControl, itemControl, postedItemsControl

	local originalHandleTabSwitch = TRADING_HOUSE.HandleTabSwitch
	TRADING_HOUSE.HandleTabSwitch = function(self, tabData)
		originalHandleTabSwitch(self, tabData)

		if(not listingControl) then
			listingControl = TRADING_HOUSE.m_currentListings
			infoControl = listingControl:GetParent()
			itemControl = infoControl:GetNamedChild("Item")
			postedItemsControl = TRADING_HOUSE.m_postedItemsHeader:GetParent()
		end

		local mode = tabData.descriptor

		listingControl:ClearAnchors()
		if(mode == "tradingHouseListings") then
			listingControl:SetParent(postedItemsControl)
			listingControl:SetAnchor(TOPLEFT, postedItemsControl, TOPLEFT, 55, -47)
		else
			listingControl:SetParent(infoControl)
			listingControl:SetAnchor(TOP, itemControl, BOTTOM, 0, 15)
		end

		if(mode == "tradingHouseBrowse") then
			InitializeFilters(self.m_browseItems)
			TRADING_HOUSE.m_searchAllowed = true
			TRADING_HOUSE:OnSearchCooldownUpdate(GetTradingHouseCooldownRemaining())
		elseif(mode == "tradingHouseSell") then
			if(not salesCategoryFilter) then
				salesCategoryFilter = AwesomeGuildStore.SalesCategorySelector:New(TRADING_HOUSE.m_postItems, ADDON_NAME .. "SalesItemCategory")
				salesCategoryFilter.control:ClearAnchors()
				salesCategoryFilter.control:SetAnchor(TOPLEFT, TRADING_HOUSE.m_postItems, TOPRIGHT, 70, -53)
			else
				salesCategoryFilter:Refresh()
			end
		end
	end

	ZO_PreHook(TRADING_HOUSE, "ResetAllSearchData", function(self, doReset)
		if(doReset or not saveData.keepFiltersOnClose) then
			if(categoryFilter) then categoryFilter:Reset() end
			if(priceSelector) then priceSelector:Reset() end
			if(levelSelector) then levelSelector:Reset() else
				self.m_levelRangeFilterType = TRADING_HOUSE_FILTER_TYPE_LEVEL
				self.m_levelRangeToggle:SetState(BSTATE_NORMAL, false)
				self.m_levelRangeLabel:SetText(GetString(SI_TRADING_HOUSE_BROWSE_LEVEL_RANGE_LABEL))
			end
			if(qualitySelector) then qualitySelector:Reset() end
			if(nameFilter) then nameFilter:Reset() end
			saveData.lastState = DEFAULT_SEARCH_STATE
			if(doReset) then return end
		end
		self:ClearSearchResults()
		if(not saveData.keepFiltersOnClose) then return end
		return true
	end)
end)
