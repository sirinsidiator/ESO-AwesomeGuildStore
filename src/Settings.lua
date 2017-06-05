local function LoadSettings()
    local gettext = LibStub("LibGetText")("AwesomeGuildStore").gettext
    local defaultData = {
        version = 21,
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
        cancelNotification = true,
        listedNotification = false,
        sortField = TRADING_HOUSE_SORT_SALE_PRICE,
        sortOrder = ZO_SORT_ORDER_UP,
        listingSortField = AwesomeGuildStore.TRADING_HOUSE_SORT_LISTING_TIME,
        listingSortOrder = ZO_SORT_ORDER_DOWN,
        disableCustomSellTabFilter = false,
        skipGuildKioskDialog = true,
        autoSearch = false,
        skipEmptyPages = false,
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
            favoritesSortField = "searches",
            favoritesSortOrder = ZO_SORT_ORDER_DOWN,
        },
        hasTouchedAction = {},
        guildTraderListEnabled = false,
    }

    local function CreateSettingsDialog(saveData)
        local LAM = LibStub("LibAddonMenu-2.0")
        local panelData = {
            type = "panel",
            name = "Awesome Guild Store",
            author = "sirinsidiator",
            version = "@VERSION_NUMBER@",
            website = "http://www.esoui.com/downloads/info695-AwesomeGuildStore.html",
            registerForRefresh = true,
            registerForDefaults = true
        }
        local panel = LAM:RegisterAddonPanel("AwesomeGuildStoreOptions", panelData)
        local optionsData = {}
        optionsData[#optionsData + 1] = {
            type = "checkbox",
            -- TRANSLATORS: label for an entry in the addon settings
            name = gettext("Use old quality selector behavior"),
            -- TRANSLATORS: tooltip text for an entry in the addon settings
            tooltip = gettext("When enabled left and right click set lower and upper quality and double or shift click sets both to the same value"),
            getFunc = function() return saveData.oldQualitySelectorBehavior end,
            setFunc = function(value) saveData.oldQualitySelectorBehavior = value end,
            default = defaultData.oldQualitySelectorBehavior
        }
        optionsData[#optionsData + 1] = {
            type = "checkbox",
            -- TRANSLATORS: label for an entry in the addon settings
            name = gettext("Show per unit price in search results"),
            -- TRANSLATORS: tooltip text for an entry in the addon settings
            tooltip = gettext("When enabled the results of a guild store search show the per unit price of a stack below the overall price"),
            getFunc = function() return saveData.displayPerUnitPrice end,
            setFunc = function(value) saveData.displayPerUnitPrice = value end,
            default = defaultData.displayPerUnitPrice
        }
        optionsData[#optionsData + 1] = {
            type = "checkbox",
            -- TRANSLATORS: label for an entry in the addon settings
            name = gettext("Select order without search"),
            -- TRANSLATORS: tooltip text for an entry in the addon settings
            tooltip = gettext("Allows you to change the sort order without triggering a new search. The currently shown results will only change after a manual search"),
            getFunc = function() return saveData.sortWithoutSearch end,
            setFunc = function(value) saveData.sortWithoutSearch = value end,
            default = defaultData.sortWithoutSearch
        }
        optionsData[#optionsData + 1] = {
            type = "checkbox",
            -- TRANSLATORS: label for an entry in the addon settings
            name = gettext("Remember sort order"),
            -- TRANSLATORS: tooltip text for an entry in the addon settings
            tooltip = gettext("Leaves the store sort order set between play sessions instead of clearing it."),
            getFunc = function() return saveData.keepSortOrderOnClose end,
            setFunc = function(value) saveData.keepSortOrderOnClose = value end,
            default = defaultData.keepSortOrderOnClose
        }
        optionsData[#optionsData + 1] = {
            type = "checkbox",
            -- TRANSLATORS: label for an entry in the addon settings
            name = gettext("Single click item listing"),
            -- TRANSLATORS: tooltip text for an entry in the addon settings
            tooltip = gettext("Select items for sale with a single click in the sell tab."),
            getFunc = function() return saveData.listWithSingleClick end,
            setFunc = function(value) saveData.listWithSingleClick = value end,
            default = defaultData.listWithSingleClick
        }
        optionsData[#optionsData + 1] = {
            type = "checkbox",
            -- TRANSLATORS: label for an entry in the addon settings
            name = gettext("Tooltips in Search Library"),
            -- TRANSLATORS: tooltip text for an entry in the addon settings
            tooltip = gettext("When active, a tooltip with details like level and quality is shown for each entry in the search library."),
            getFunc = function() return saveData.searchLibrary.showTooltips end,
            setFunc = function(value) saveData.searchLibrary.showTooltips = value end,
            default = defaultData.searchLibrary.showTooltips
        }
        optionsData[#optionsData + 1] = {
            type = "checkbox",
            -- TRANSLATORS: label for an entry in the addon settings
            name = gettext("Trader Tooltips"),
            -- TRANSLATORS: tooltip text for an entry in the addon settings
            tooltip = gettext("Show the currently hired trader for a guild that you are a member of, when hovering over the name or an entry in the drop down menu"),
            getFunc = function() return saveData.showTraderTooltip end,
            setFunc = function(value) saveData.showTraderTooltip = value end,
            default = defaultData.showTraderTooltip
        }
        optionsData[#optionsData + 1] = {
            type = "checkbox",
            -- TRANSLATORS: label for an entry in the addon settings
            name = gettext("Auto clear history"),
            -- TRANSLATORS: tooltip text for an entry in the addon settings
            tooltip = gettext("Automatically deletes all history entries when you open the guild store for the first time in a game session. You can undo the deletion via the menu in the search library"),
            getFunc = function() return saveData.searchLibrary.autoClearHistory end,
            setFunc = function(value) saveData.searchLibrary.autoClearHistory = value end,
            default = defaultData.searchLibrary.autoClearHistory
        }
        optionsData[#optionsData + 1] = {
            type = "checkbox",
            -- TRANSLATORS: label for an entry in the addon settings
            name = gettext("Mail augmentation"),
            -- TRANSLATORS: tooltip text for an entry in the addon settings
            tooltip = gettext("Adds more detailed information about a transaction to an incoming Guild Store Mail if the data is available in the Guild Activity Log."),
            getFunc = function() return saveData.augementMails end,
            setFunc = function(value) saveData.augementMails = value end,
            default = defaultData.augementMails,
            requiresReload = true
        }
        optionsData[#optionsData + 1] = {
            type = "checkbox",
            -- TRANSLATORS: label for an entry in the addon settings
            name = gettext("Show invoice on mails"),
            -- TRANSLATORS: tooltip text for an entry in the addon settings
            tooltip = gettext("Adds a detailed invoice to the mail which lists all deductions."),
            getFunc = function() return saveData.mailAugmentationShowInvoice end,
            setFunc = function(value) saveData.mailAugmentationShowInvoice = value end,
            default = defaultData.mailAugmentationShowInvoice,
            disabled = function() return not saveData.augementMails end
        }
        optionsData[#optionsData + 1] = {
            type = "checkbox",
            -- TRANSLATORS: label for an entry in the addon settings
            name = gettext("Purchase notifications"),
            -- TRANSLATORS: tooltip text for an entry in the addon settings
            tooltip = gettext("Shows a message in chat after you have purchased an item in a guild store"),
            getFunc = function() return saveData.purchaseNotification end,
            setFunc = function(value) saveData.purchaseNotification = value end,
            default = defaultData.purchaseNotification,
        }
        optionsData[#optionsData + 1] = {
            type = "checkbox",
            -- TRANSLATORS: label for an entry in the addon settings
            name = gettext("Cancel notifications"),
            -- TRANSLATORS: tooltip text for an entry in the addon settings
            tooltip = gettext("Shows a message in chat after you have cancelled an item listing from a guild store"),
            getFunc = function() return saveData.cancelNotification end,
            setFunc = function(value) saveData.cancelNotification = value end,
            default = defaultData.cancelNotification,
        }
        optionsData[#optionsData + 1] = {
            type = "checkbox",
            -- TRANSLATORS: label for an entry in the addon settings
            name = gettext("Listed item notifications"),
            -- TRANSLATORS: tooltip text for an entry in the addon settings
            tooltip = gettext("Shows a message in chat after you have created a new item listing in a guild store"),
            getFunc = function() return saveData.listedNotification end,
            setFunc = function(value) saveData.listedNotification = value end,
            default = defaultData.listedNotification,
        }
        optionsData[#optionsData + 1] = {
            type = "checkbox",
            -- TRANSLATORS: label for an entry in the addon settings
            name = gettext("Disable custom selltab filter"),
            -- TRANSLATORS: tooltip text for an entry in the addon settings
            tooltip = gettext("Shows the ingame inventory filter instead of AGS own version when deactivated."),
            getFunc = function() return saveData.disableCustomSellTabFilter end,
            setFunc = function(value) saveData.disableCustomSellTabFilter = value end,
            default = defaultData.disableCustomSellTabFilter,
            requiresReload = true
        }
        optionsData[#optionsData + 1] = {
            type = "checkbox",
            -- TRANSLATORS: label for an entry in the addon settings
            name = gettext("Skip guild kiosk dialog"),
            -- TRANSLATORS: tooltip text for an entry in the addon settings
            tooltip = gettext("When activated, the dialog at guild traders (not at banks) is skipped and the store opened automatically. This can be suppressed by holding the shift key when talking to a trader."),
            getFunc = function() return saveData.skipGuildKioskDialog end,
            setFunc = function(value) saveData.skipGuildKioskDialog = value end,
            default = defaultData.skipGuildKioskDialog,
        }
        optionsData[#optionsData + 1] = {
            type = "checkbox",
            -- TRANSLATORS: label for an entry in the addon settings
            name = gettext("Skip empty result pages"),
            -- TRANSLATORS: tooltip text for an entry in the addon settings
            tooltip = gettext("When activated, pages that show no results due to local filters will automatically trigger a search for the next page. This can be suppressed by holding the ctrl key before the results are returned."),
            getFunc = function() return saveData.skipEmptyPages end,
            setFunc = function(value) saveData.skipEmptyPages = value end,
            default = defaultData.skipEmptyPages,
        }
        optionsData[#optionsData + 1] = {
            type = "button",
            -- TRANSLATORS: label for an entry in the addon settings
            name = gettext("Clear sell price cache"),
            -- TRANSLATORS: tooltip text for an entry in the addon settings
            tooltip = gettext("Pressing this button will remove all stored quantity and price values for the sell tab from your save data. While Master Merchant is active, it will take the last sell price from there when selecting an item if no data was found in AwesomeGuildStore's own data"),
            -- TRANSLATORS: warning tooltip text for an entry in the addon settings
            warning = gettext("The data cannot be restored after you have confirmed the action"),
            isDangerous = true,
            func = function()
                if(saveData.lastSoldStackCount) then
                    ZO_ClearTable(saveData.lastSoldStackCount)
                end
                if(saveData.lastSoldPricePerUnit) then
                    ZO_ClearTable(saveData.lastSoldPricePerUnit)
                end
            end,
        }
        optionsData[#optionsData + 1] = {
            type = "checkbox",
            -- TRANSLATORS: label for an entry in the addon settings
            name = gettext("Enable guild trader list (BETA)"),
            -- TRANSLATORS: tooltip text for an entry in the addon settings
            tooltip = gettext("When activated, the guild menu will show a new tab with a list of all kiosks in Tamriel. The list will get updated with the owning guilds whenever you visit a kiosk."),
            requiresReload = true,
            getFunc = function() return saveData.guildTraderListEnabled end,
            setFunc = function(value) saveData.guildTraderListEnabled = value end,
            default = defaultData.guildTraderListEnabled,
        }
        optionsData[#optionsData + 1] = {
            type = "button",
            -- TRANSLATORS: label for an entry in the addon settings
            name = gettext("Clear guild trader list"),
            -- TRANSLATORS: tooltip text for an entry in the addon settings
            tooltip = gettext("Pressing this button will remove all stored data related to the guild trader list"),
            -- TRANSLATORS: warning tooltip text for an entry in the addon settings
            warning = gettext("The UI will reload and the data cannot be restored after you have confirmed the action"),
            disabled = function() return not saveData.guildTraderListEnabled end,
            isDangerous = true,
            func = function()
                if(saveData.guildStoreList) then
                    saveData.guildStoreList = nil
                    ReloadUI()
                end
            end,
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
        if(saveData.version <= 9) then
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
        if(saveData.version == 15) then
            saveData.cancelNotification = defaultData.cancelNotification
            saveData.listedNotification = defaultData.listedNotification
            saveData.version = 16
        end
        if(saveData.version == 16) then
            saveData.searchLibrary.favoritesSortField = defaultData.searchLibrary.favoritesSortField
            saveData.searchLibrary.favoritesSortOrder = defaultData.searchLibrary.favoritesSortOrder
            if(saveData.autoSearch == nil) then saveData.autoSearch = defaultData.autoSearch end
            saveData.skipEmptyPages = defaultData.skipEmptyPages
            saveData.version = 17
        end
        if(saveData.version <= 19) then
            local hasTouchedAction = {}
            if(saveData.hasUnboundAction) then
                for key in pairs(saveData.hasUnboundAction) do
                    hasTouchedAction[key] = true
                end
                saveData.hasUnboundAction = nil
            end
            if(not saveData.hasTouchedAction) then
                saveData.hasTouchedAction = hasTouchedAction
            end

            if(saveData.lastSoldStackCount) then
                local lastSoldStackCount = saveData.lastSoldStackCount
                for key in pairs(lastSoldStackCount) do
                    if(key:match("|h") ~= nil) then
                        lastSoldStackCount[key] = nil
                    end
                end
            end
            if(saveData.lastSoldPricePerUnit) then
                local lastSoldPricePerUnit = saveData.lastSoldPricePerUnit
                for key in pairs(lastSoldPricePerUnit) do
                    if(key:match("|h") ~= nil) then
                        lastSoldPricePerUnit[key] = nil
                    end
                end
            end
            saveData.version = 20
        end
        if(saveData.version == 20) then
            saveData.guildTraderListEnabled = defaultData.guildTraderListEnabled
            saveData.version = 21
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
