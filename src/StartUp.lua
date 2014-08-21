local ADDON_NAME = "AwesomeGuildStore"
AwesomeGuildStore = {}

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

local defaultData = {
	version = 3,
	lastGuildName = "",
	replaceCategoryFilter = true,
	replacePriceFilter = true,
	replaceQualityFilter = true,
	replaceLevelFilter = true,
	keepFiltersOnClose = true
}

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
	end
end

local function InitializeGuildSelector(lastGuildId)
	comboBox:ClearItems()
	entryByGuildId = {}

	local selectedEntry

	for i = 1, GetNumTradingHouseGuilds() do
		local guildId, guildName, guildAlliance = GetTradingHouseGuildDetails(i)
		local entryText = zo_iconTextFormat(GetAllianceBannerIcon(guildAlliance), 24, 24, guildName)
		local entry = comboBox:CreateItemEntry(entryText, OnGuildChanged)
		entry.guildId = guildId
		entry.selectedText = guildName
		comboBox:AddItem(entry)
		if(not selectedEntry or (lastGuildId and guildId == lastGuildId)) then
			selectedEntry = entry
		end
		entryByGuildId[guildId] = entry
	end

	OnGuildChanged(comboBox, selectedEntry.name, selectedEntry)
end

local function InitializeFilters(control)
	if(filtersInitialized) then return end

	local common = control:GetNamedChild("Common")

	if(saveData.replaceCategoryFilter) then
		local header = control:GetNamedChild("Header")
		control:GetNamedChild("ItemCategory"):SetHidden(true)
		categoryFilter = AwesomeGuildStore.CategorySelector:New(control, ADDON_NAME .. "ItemCategory")
		categoryFilter.control:ClearAnchors()
		categoryFilter.control:SetAnchor(TOPLEFT, header, TOPRIGHT, 70, -20)

		local itemPane = ZO_TradingHouse:GetNamedChild("ItemPane")
		itemPane:SetAnchor(TOPLEFT, categoryFilter.control, BOTTOMLEFT, 0, 20)
	end

	if(saveData.replacePriceFilter) then
		priceSelector = AwesomeGuildStore.PriceSelector:New(common, ADDON_NAME .. "PriceRange")
		priceSelector.slider.control:ClearAnchors()
		priceSelector.slider.control:SetAnchor(TOPLEFT, common:GetNamedChild("PriceRangeLabel"), BOTTOMLEFT, 0, 5)
		local minPrice = common:GetNamedChild("MinPrice")
		minPrice:ClearAnchors()
		minPrice:SetAnchor(TOPLEFT, priceSelector.slider.control, BOTTOMLEFT, 0, 5)
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
	end

	if(saveData.replaceQualityFilter) then
		qualitySelector = AwesomeGuildStore.QualitySelector:New(common, ADDON_NAME .. "QualityButtons")
		qualitySelector.control:ClearAnchors()
		local parent = levelSelector and common:GetNamedChild("LevelRangeToggle") or common:GetNamedChild("MinLevel")
		qualitySelector.control:SetAnchor(TOPLEFT, parent, BOTTOMLEFT, 0, 10)

		local qualityControl = common:GetNamedChild("Quality")
		qualityControl:ClearAnchors()
		qualityControl:SetAnchor(TOPLEFT, common, TOPLEFT, 0, 350)
		qualityControl:SetHidden(true)
	elseif(saveData.replaceLevelFilter) then
		local qualityControl = common:GetNamedChild("Quality")
		qualityControl:ClearAnchors()
		qualityControl:SetAnchor(TOPLEFT, common:GetNamedChild("LevelRangeToggle"), BOTTOMLEFT, 0, 10)
	end

	searchButton = CreateControlFromVirtual(ADDON_NAME .. "StartSearchButton", common, "ZO_DefaultButton")
	local parent = qualitySelector and qualitySelector.control or common
	searchButton:SetWidth(common:GetWidth())
	searchButton:SetAnchor(TOP, parent, BOTTOM, 0, 25)
	searchButton:SetText(L["START_SEARCH_LABEL"])
	searchButton:SetHandler("OnMouseUp",function(control, button, isInside)
		if(button == 1 and isInside) then
			if(TRADING_HOUSE:CanSearch()) then
				TRADING_HOUSE:DoSearch()
			end
		end
	end)

	ZO_PreHook("ExecuteTradingHouseSearch", function(self)
		searchButton:SetEnabled(false)
	end)

	RegisterForEvent(EVENT_TRADING_HOUSE_SEARCH_COOLDOWN_UPDATE, function(_, cooldownMilliseconds)
		if(cooldownMilliseconds ~= 0) then return end
		searchButton:SetEnabled(true)
	end)

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

	filtersInitialized = true
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
	_, saveData.lastGuildName = GetCurrentTradingHouseGuildDetails()
	return guildId
end

local function CreateSettingsDialog()
	local LAM = LibStub("LibAddonMenu-2.0")
	local panelData = {
		type = "panel",
		name = "Awesome Guild Store",
		registerForDefaults = true
	}
	LAM:RegisterAddonPanel("AwesomeGuildStoreOptions", panelData)
	local optionsData = {
		[1] = {
			type = "checkbox",
			name = L["SETTINGS_REPLACE_CATEGORY_FILTER_LABEL"],
			tooltip = L["SETTINGS_REPLACE_CATEGORY_FILTER_DESCRIPTION"],
			getFunc = function() return saveData.replaceCategoryFilter end,
			setFunc = function(value) saveData.replaceCategoryFilter = value end,
			warning = L["SETTINGS_REQUIRES_RELOADUI_WARNING"],
			default = defaultData.replaceCategoryFilter
		},
		[2] = {
			type = "checkbox",
			name = L["SETTINGS_REPLACE_PRICE_FILTER_LABEL"],
			tooltip = L["SETTINGS_REPLACE_PRICE_FILTER_DESCRIPTION"],
			getFunc = function() return saveData.replacePriceFilter end,
			setFunc = function(value) saveData.replacePriceFilter = value end,
			warning = L["SETTINGS_REQUIRES_RELOADUI_WARNING"],
			default = defaultData.replacePriceFilter
		},
		[3] = {
			type = "checkbox",
			name = L["SETTINGS_REPLACE_LEVEL_FILTER_LABEL"],
			tooltip = L["SETTINGS_REPLACE_LEVEL_FILTER_DESCRIPTION"],
			getFunc = function() return saveData.replaceLevelFilter end,
			setFunc = function(value) saveData.replaceLevelFilter = value end,
			warning = L["SETTINGS_REQUIRES_RELOADUI_WARNING"],
			default = defaultData.replaceLevelFilter
		},
		[4] = {
			type = "checkbox",
			name = L["SETTINGS_REPLACE_QUALITY_FILTER_LABEL"],
			tooltip = L["SETTINGS_REPLACE_QUALITY_FILTER_DESCRIPTION"],
			getFunc = function() return saveData.replaceQualityFilter end,
			setFunc = function(value) saveData.replaceQualityFilter = value end,
			warning = L["SETTINGS_REQUIRES_RELOADUI_WARNING"],
			default = defaultData.replaceQualityFilter
		},
		[5] = {
			type = "checkbox",
			name = L["SETTINGS_KEEP_FILTERS_ON_CLOSE_LABEL"],
			tooltip = L["SETTINGS_KEEP_FILTERS_ON_CLOSE_DESCRIPTION"],
			getFunc = function() return saveData.keepFiltersOnClose end,
			setFunc = function(value) saveData.keepFiltersOnClose = value end,
			default = defaultData.keepFiltersOnClose
		},
	}
	LAM:RegisterOptionControls("AwesomeGuildStoreOptions", optionsData)
end

OnAddonLoaded(function()
	AwesomeGuildStore_Data = AwesomeGuildStore_Data or {}
	saveData = AwesomeGuildStore_Data[GetDisplayName()] or ZO_ShallowTableCopy(defaultData)
	AwesomeGuildStore_Data[GetDisplayName()] = saveData

	L = AwesomeGuildStore.Localization

	if(saveData.version == 1) then
		saveData.replaceQualityFilter = true
		saveData.replaceLevelFilter = true
		saveData.keepFiltersOnClose = true
		saveData.version = 2
	end
	if(saveData.version == 2) then
		saveData.replacePriceFilter = true
		saveData.version = 3
	end
	if(saveData.version == 3) then
		saveData.replaceCategoryFilter = true
		saveData.version = 4
	end

	local title = TRADING_HOUSE.m_control:GetNamedChild("Title")
	local titleLabel = title:GetNamedChild("Label")
	CreateControlFromVirtual(ADDON_NAME .. "GuildSelector", title, ADDON_NAME .. "GuildSelectorTemplate")

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
		DisableKeybindStripSearchButton()
	end)

	RegisterForEvent(EVENT_TRADING_HOUSE_STATUS_RECEIVED, function()
		local guildId = GetSelectedTradingHouseGuildId()

		if(GetTradingHouseCooldownRemaining() == 0) then searchButton:SetEnabled(true) end
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

	ZO_PreHook(TRADING_HOUSE, "UpdateForGuildChange", function()
		DisableKeybindStripSearchButton()
		local guildId = GetSelectedTradingHouseGuildId()
		if(guildId) then
			local _, guildName = GetCurrentTradingHouseGuildDetails()
			if(entryByGuildId and entryByGuildId[guildId]) then
				comboBox:SetSelectedItem(entryByGuildId[guildId].name)
			end
			saveData.lastGuildName = guildName
		end
	end)


	local originalHandleTabSwitch = TRADING_HOUSE.HandleTabSwitch
	TRADING_HOUSE.HandleTabSwitch = function(self, tabData)
		originalHandleTabSwitch(self, tabData)
		local mode = tabData.descriptor
		if(mode == "tradingHouseBrowse") then
			InitializeFilters(self.m_browseItems)
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
			if(doReset) then return end
		end
		self:ClearSearchResults()
		if(not saveData.keepFiltersOnClose) then return end
		return true
	end)

	CreateSettingsDialog()
end)
