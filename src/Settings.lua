local function LoadSettings()
	local defaultData = {
		version = 11,
		lastGuildName = "",
		keepFiltersOnClose = true,
		oldQualitySelectorBehavior = false,
		displayPerUnitPrice = true,
		keepSortOrderOnClose = true,
		listWithSingleClick = true,
		sortWithoutSearch = false,
		showTraderTooltip = true,
		augementMails = true,
		mailAugmentationShowInvoice = false,
		purchaseNotification = true,
		sortField = TRADING_HOUSE_SORT_SALE_PRICE,
		sortOrder = ZO_SORT_ORDER_UP,
		listingSortField = TRADING_HOUSE_SORT_LISTING_TIME,
		listingSortOrder = ZO_SORT_ORDER_DOWN,
		disableCustomSellTabFilter = false,
		skipGuildKioskDialog = true,
		searchLibrary = {
			x = 980,
			y = -5,
			width = 730,
			height = 185,
			isActive = true,
			lastState = "1:-:-:-:-:-",
			searches = {},
			showTooltips = true,
			locked = true,
			autoClearHistory = false,
		}
	}

	local function CreateSettingsDialog(saveData)
		local L = AwesomeGuildStore.Localization
		local LAM = LibStub("LibAddonMenu-2.0")
		local panelData = {
			type = "panel",
			name = "Awesome Guild Store",
			author = "sirinsidiator",
			version = "VERSION_NUMBER",
			registerForRefresh = true,
			registerForDefaults = true
		}
		local panel = LAM:RegisterAddonPanel("AwesomeGuildStoreOptions", panelData)
		local optionsData = {}
		optionsData[#optionsData + 1] = {
			type = "checkbox",
			name = L["SETTINGS_KEEP_FILTERS_ON_CLOSE_LABEL"],
			tooltip = L["SETTINGS_KEEP_FILTERS_ON_CLOSE_DESCRIPTION"],
			getFunc = function() return saveData.keepFiltersOnClose end,
			setFunc = function(value) saveData.keepFiltersOnClose = value end,
			default = defaultData.keepFiltersOnClose
		}
		optionsData[#optionsData + 1] = {
			type = "checkbox",
			name = L["SETTINGS_OLD_QUALITY_SELECTOR_BEHAVIOR_LABEL"],
			tooltip = L["SETTINGS_OLD_QUALITY_SELECTOR_BEHAVIOR_DESCRIPTION"],
			getFunc = function() return saveData.oldQualitySelectorBehavior end,
			setFunc = function(value) saveData.oldQualitySelectorBehavior = value end,
			default = defaultData.oldQualitySelectorBehavior
		}
		optionsData[#optionsData + 1] = {
			type = "checkbox",
			name = L["SETTINGS_DISPLAY_PER_UNIT_PRICE_LABEL"],
			tooltip = L["SETTINGS_DISPLAY_PER_UNIT_PRICE_DESCRIPTION"],
			getFunc = function() return saveData.displayPerUnitPrice end,
			setFunc = function(value) saveData.displayPerUnitPrice = value end,
			default = defaultData.displayPerUnitPrice
		}
		optionsData[#optionsData + 1] = {
			type = "checkbox",
			name = L["SETTINGS_SORT_WITHOUT_SEARCH_LABEL"],
			tooltip = L["SETTINGS_SORT_WITHOUT_SEARCH_DESCRIPTION"],
			getFunc = function() return saveData.sortWithoutSearch end,
			setFunc = function(value) saveData.sortWithoutSearch = value end,
			default = defaultData.sortWithoutSearch
		}
		optionsData[#optionsData + 1] = {
			type = "checkbox",
			name = L["SETTINGS_KEEP_SORTORDER_ON_CLOSE_LABEL"],
			tooltip = L["SETTINGS_KEEP_SORTORDER_ON_CLOSE_DESCRIPTION"],
			getFunc = function() return saveData.keepSortOrderOnClose end,
			setFunc = function(value) saveData.keepSortOrderOnClose = value end,
			default = defaultData.keepSortOrderOnClose
		}
		optionsData[#optionsData + 1] = {
			type = "checkbox",
			name = L["SETTINGS_LIST_WITH_SINGLE_CLICK_LABEL"],
			tooltip = L["SETTINGS_LIST_WITH_SINGLE_CLICK_DESCRIPTION"],
			getFunc = function() return saveData.listWithSingleClick end,
			setFunc = function(value) saveData.listWithSingleClick = value end,
			default = defaultData.listWithSingleClick
		}
		optionsData[#optionsData + 1] = {
			type = "checkbox",
			name = L["SETTINGS_SHOW_SEARCH_LIBRARY_TOOLTIPS_LABEL"],
			tooltip = L["SETTINGS_SHOW_SEARCH_LIBRARY_TOOLTIPS_DESCRIPTION"],
			getFunc = function() return saveData.searchLibrary.showTooltips end,
			setFunc = function(value) saveData.searchLibrary.showTooltips = value end,
			default = defaultData.searchLibrary.showTooltips
		}
		optionsData[#optionsData + 1] = {
			type = "checkbox",
			name = L["SETTINGS_SHOW_TRADER_TOOLTIPS_LABEL"],
			tooltip = L["SETTINGS_SHOW_TRADER_TOOLTIPS_DESCRIPTION"],
			getFunc = function() return saveData.showTraderTooltip end,
			setFunc = function(value) saveData.showTraderTooltip = value end,
			default = defaultData.showTraderTooltip
		}
		optionsData[#optionsData + 1] = {
			type = "checkbox",
			name = L["SETTINGS_AUTO_CLEAR_HISTORY_LABEL"],
			tooltip = L["SETTINGS_AUTO_CLEAR_HISTORY_DESCRIPTION"],
			getFunc = function() return saveData.searchLibrary.autoClearHistory end,
			setFunc = function(value) saveData.searchLibrary.autoClearHistory = value end,
			default = defaultData.searchLibrary.autoClearHistory
		}
		optionsData[#optionsData + 1] = {
			type = "checkbox",
			name = L["SETTINGS_MAIL_AUGMENTATION_LABEL"],
			tooltip = L["SETTINGS_MAIL_AUGMENTATION_DESCRIPTION"],
			getFunc = function() return saveData.augementMails end,
			setFunc = function(value) saveData.augementMails = value end,
			default = defaultData.augementMails,
			warning = L["SETTINGS_REQUIRES_RELOADUI_WARNING"]
		}
		optionsData[#optionsData + 1] = {
			type = "checkbox",
			name = L["SETTINGS_MAIL_AUGMENTATION_INVOICE_LABEL"],
			tooltip = L["SETTINGS_MAIL_AUGMENTATION_INVOICE_DESCRIPTION"],
			getFunc = function() return saveData.mailAugmentationShowInvoice end,
			setFunc = function(value) saveData.mailAugmentationShowInvoice = value end,
			default = defaultData.mailAugmentationShowInvoice,
			disabled = function() return not saveData.augementMails end
		}
		optionsData[#optionsData + 1] = {
			type = "checkbox",
			name = L["SETTINGS_PURCHASE_NOTIFICATION_LABEL"],
			tooltip = L["SETTINGS_PURCHASE_NOTIFICATION_DESCRIPTION"],
			getFunc = function() return saveData.purchaseNotification end,
			setFunc = function(value) saveData.purchaseNotification = value end,
			default = defaultData.purchaseNotification,
		}
		optionsData[#optionsData + 1] = {
			type = "checkbox",
			name = L["SETTINGS_DISABLE_CUSTOM_SELL_TAB_FILTER_LABEL"],
			tooltip = L["SETTINGS_DISABLE_CUSTOM_SELL_TAB_FILTER_DESCRIPTION"],
			getFunc = function() return saveData.disableCustomSellTabFilter end,
			setFunc = function(value) saveData.disableCustomSellTabFilter = value end,
			default = defaultData.disableCustomSellTabFilter,
		}
		optionsData[#optionsData + 1] = {
			type = "checkbox",
			name = L["SETTINGS_SKIP_GUILD_KIOSK_DIALOG_LABEL"],
			tooltip = L["SETTINGS_SKIP_GUILD_KIOSK_DIALOG_DESCRIPTION"],
			getFunc = function() return saveData.skipGuildKioskDialog end,
			setFunc = function(value) saveData.skipGuildKioskDialog = value end,
			default = defaultData.skipGuildKioskDialog,
		}
		LAM:RegisterOptionControls("AwesomeGuildStoreOptions", optionsData)

		AwesomeGuildStore.OpenSettingsPanel = function()
			LAM:OpenToPanel(panel)
		end
	end

	local function UpgradeSettings(saveData)
		if(saveData.version == 1) then
			saveData.replaceQualityFilter = defaultData.replaceQualityFilter
			saveData.replaceLevelFilter = defaultData.replaceLevelFilter
			saveData.keepFiltersOnClose = defaultData.keepFiltersOnClose
			saveData.version = 2
		end
		if(saveData.version == 2) then
			saveData.replacePriceFilter = defaultData.replacePriceFilter
			saveData.version = 3
		end
		if(saveData.version == 3) then
			saveData.replaceCategoryFilter = defaultData.replaceCategoryFilter
			saveData.version = 4
		end
		if(saveData.version == 4) then
			saveData.lastState = defaultData.searchLibrary.lastState
			saveData.version = 5
		end
		if(saveData.version == 5) then
			saveData.searchLibrary = ZO_ShallowTableCopy(defaultData.searchLibrary)
			saveData.searchLibrary.lastState = saveData.lastState
			saveData.lastState = nil
			saveData.version = 6
		end
		if(saveData.version == 6) then
			saveData.oldQualitySelectorBehavior = defaultData.oldQualitySelectorBehavior
			saveData.version = 7
		end
		if(saveData.version == 7) then
			saveData.displayPerUnitPrice = defaultData.displayPerUnitPrice
			saveData.searchLibrary.width = defaultData.searchLibrary.width
			saveData.searchLibrary.height = defaultData.searchLibrary.height
			saveData.version = 8
		end
		if(saveData.version == 8) then
			--saveData.lastGuildName = nil -- reverted
			saveData.version = 9
		end
		if(saveData.version == 9) then
			saveData.lastGuildName = saveData.lastGuildName or defaultData.lastGuildName
			saveData.version = 10
		end
		if(saveData.version == 10) then
			saveData.keepSortOrderOnClose = defaultData.keepSortOrderOnClose
			saveData.sortField = defaultData.sortField
			saveData.sortOrder = defaultData.sortOrder
			saveData.listWithSingleClick = defaultData.listWithSingleClick
			saveData.searchLibrary.showTooltips = defaultData.searchLibrary.showTooltips
			saveData.sortWithoutSearch = defaultData.sortWithoutSearch
			saveData.showTraderTooltip = defaultData.showTraderTooltip
			saveData.searchLibrary.locked = defaultData.searchLibrary.locked
			saveData.searchLibrary.autoClearHistory = defaultData.searchLibrary.autoClearHistory
			saveData.version = 11
		end
		if(saveData.version == 11) then
			saveData.listingSortField = defaultData.listingSortField
			saveData.listingSortOrder = defaultData.listingSortOrder
			saveData.replaceCategoryFilter = nil
			saveData.replacePriceFilter = nil
			saveData.replaceQualityFilter = nil
			saveData.replaceLevelFilter = nil
			saveData.version = 12
		end
		if(saveData.version == 12) then
			saveData.augementMails = defaultData.augementMails
			saveData.version = 13
		end
		if(saveData.version == 13) then
			saveData.purchaseNotification = defaultData.purchaseNotification
			saveData.version = 14
		end
		if(saveData.version == 14) then
			saveData.skipGuildKioskDialog = defaultData.skipGuildKioskDialog
			saveData.version = 15
		end
	end

	AwesomeGuildStore_Data = AwesomeGuildStore_Data or {}
	local saveData = AwesomeGuildStore_Data[GetDisplayName()] or ZO_DeepTableCopy(defaultData)
	AwesomeGuildStore_Data[GetDisplayName()] = saveData
	AwesomeGuildStore.defaultData = defaultData

	UpgradeSettings(saveData)
	CreateSettingsDialog(saveData)

	return saveData
end

AwesomeGuildStore.LoadSettings = LoadSettings
