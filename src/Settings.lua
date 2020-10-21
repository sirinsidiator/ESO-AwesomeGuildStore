local AGS = AwesomeGuildStore

local function LoadSettings()

    local gettext = AGS.internal.gettext

    local info = {
        fullVersion = "@FULL_VERSION_NUMBER@",
        version = "@VERSION_NUMBER@",
        build = "@BUILD_NUMBER@",
    }
    AGS.info = info

    local defaultData = {
        version = 26,
        listWithSingleClick = true,
        showTraderTooltip = true,
        augementMails = true,
        mailAugmentationShowInvoice = false,
        purchaseNotification = true,
        cancelNotification = true,
        listedNotification = false,
        listingSortField = AGS.internal.TRADING_HOUSE_SORT_LISTING_TIME,
        listingSortOrder = ZO_SORT_ORDER_DOWN,
        disableCustomSellTabFilter = false,
        skipGuildKioskDialog = true,
        hasTouchedAction = {},
        guildTraderListEnabled = true,
        minimizeChatOnOpen = true,
        preferredBankerStoreTab = ZO_TRADING_HOUSE_MODE_SELL
    }

    local function RepairSaveData(saveData)
        for key, value in pairs(defaultData) do
            if(saveData[key] == nil) then
                saveData[key] = value
            end
        end
    end

    local DONATION_URL = "https://www.esoui.com/downloads/info695-AwesomeGuildStore.html#donate"
    local function Donate()
        RequestOpenUnsafeURL(DONATION_URL)
    end
    AwesomeGuildStore.internal.Donate = Donate

    local function CreateSettingsDialog(saveData)
        local LAM = LibAddonMenu2
        local panelData = {
            type = "panel",
            name = "Awesome Guild Store",
            author = "sirinsidiator",
            version = info.fullVersion,
            website = "https://www.esoui.com/downloads/info695-AwesomeGuildStore.html",
            feedback = "https://www.esoui.com/portal.php?id=218&a=bugreport",
            donation = DONATION_URL,
            registerForRefresh = true,
            registerForDefaults = true
        }
        local panel = LAM:RegisterAddonPanel("AwesomeGuildStoreOptions", panelData)
        local optionsData = {}
        optionsData[#optionsData + 1] = {
            type = "checkbox",
            -- TRANSLATORS: label for an entry in the addon settings
            name = gettext("Minimize chat on open"),
            -- TRANSLATORS: tooltip text for an entry in the addon settings
            tooltip = gettext("When activated, the chat window will get minimized when visiting a trading house. This defaults to true since it is the new default behavior added by ZOS."),
            getFunc = function() return saveData.minimizeChatOnOpen end,
            setFunc = function(value)
                saveData.minimizeChatOnOpen = value
                if(value) then
                    TRADING_HOUSE_SCENE:AddFragment(MINIMIZE_CHAT_FRAGMENT)
                else
                    TRADING_HOUSE_SCENE:RemoveFragment(MINIMIZE_CHAT_FRAGMENT)
                end
            end,
            default = defaultData.minimizeChatOnOpen,
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
        if GetAPIVersion() < 100033 then -- TODO remove once it is live
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
        end
        optionsData[#optionsData + 1] = {
            type = "dropdown",
            -- TRANSLATORS: label for an entry in the addon settings
            name = gettext("Preferred banker store tab"),
            -- TRANSLATORS: tooltip text for an entry in the addon settings
            tooltip = gettext("Controls which tab should be opened first when visiting the guild store at a banker."),
            choices = {
                GetString(SI_TRADING_HOUSE_MODE_BROWSE),
                GetString(SI_TRADING_HOUSE_MODE_SELL),
                GetString(SI_TRADING_HOUSE_MODE_LISTINGS),
            },
            choicesValues = {
                ZO_TRADING_HOUSE_MODE_BROWSE,
                ZO_TRADING_HOUSE_MODE_SELL,
                ZO_TRADING_HOUSE_MODE_LISTINGS,
            },
            getFunc = function() return saveData.preferredBankerStoreTab end,
            setFunc = function(value) saveData.preferredBankerStoreTab = value end,
            default = defaultData.preferredBankerStoreTab,
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
            name = gettext("Enable guild trader list"),
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

        AGS.OpenSettingsPanel = function()
            LAM:OpenToPanel(panel)
        end
    end

    local function UpgradeSettings(saveData)
        if(saveData.version <= 5) then
            saveData.lastState = nil
            saveData.version = 6
        end
        if(saveData.version <= 11) then
            saveData.replaceCategoryFilter = nil
            saveData.replacePriceFilter = nil
            saveData.replaceQualityFilter = nil
            saveData.replaceLevelFilter = nil
            saveData.version = 12
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
        if(saveData.version <= 23) then
            saveData.keepFiltersOnClose = nil
            saveData.oldQualitySelectorBehavior = nil
            saveData.displayPerUnitPrice = nil
            saveData.keepSortOrderOnClose = nil
            saveData.sortWithoutSearch = nil
            saveData.sortField = nil
            saveData.sortOrder = nil
            saveData.autoSearch = nil
            saveData.skipEmptyPages = nil
            saveData.searchLibrary = nil
            saveData.resetFiltersOnExit = nil
            saveData.keepPurchasedResultsInList = nil
            saveData.guildTraderListEnabled = true
            saveData.version = 24
        end
        if(saveData.version <= 24) then
            saveData.lastGuildName = nil
            saveData.preferredBankerStoreTab = defaultData.preferredBankerStoreTab
            saveData.version = 25
        end
        if(saveData.version <= 25) then
            saveData.shortMessagePrefix = nil
            saveData.version = 26
        end
    end

    AwesomeGuildStore_Data = AwesomeGuildStore_Data or {}
    local name = GetDisplayName()
    local world = GetWorldName()
    local key = world .. name

    -- migrate old data
    if(not AwesomeGuildStore_Data[key] and AwesomeGuildStore_Data[name]) then
        AwesomeGuildStore_Data[key] = AwesomeGuildStore_Data[name]
        AwesomeGuildStore_Data[name] = nil
    end

    AwesomeGuildStore_Data.guilds = AwesomeGuildStore_Data.guilds or {}
    AGS.internal.guildIdMapping = AGS.class.GuildIdMapping:New(AwesomeGuildStore_Data.guilds, world)

    local saveData = AwesomeGuildStore_Data[key] or ZO_DeepTableCopy(defaultData)
    AwesomeGuildStore_Data[key] = saveData
    AGS.data.DEFAULT_SETTINGS = defaultData

    UpgradeSettings(saveData)
    RepairSaveData(saveData)

    CreateSettingsDialog(saveData)

    return saveData
end

AGS.internal.LoadSettings = LoadSettings
