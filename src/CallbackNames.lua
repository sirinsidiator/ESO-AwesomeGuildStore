local AGS = AwesomeGuildStore

AGS.callback.BEFORE_INITIAL_SETUP = "BeforeInitialSetup"
AGS.callback.AFTER_INITIAL_SETUP = "AfterInitialSetup"
AGS.callback.AFTER_FILTER_SETUP = "AfterFilterSetup"

AGS.callback.TRADING_HOUSE_STATUS_CHANGED = "TradingHouseStatusChanged"
AGS.callback.STORE_TAB_CHANGED = "StoreTabChanged"
AGS.callback.GUILD_SELECTION_CHANGED = "SelectedGuildChanged"
AGS.callback.AVAILABLE_GUILDS_CHANGED = "AvailableGuildsChanged"
AGS.callback.SELECTED_SEARCH_CHANGED = "SelectedSearchChanged"
AGS.callback.SEARCH_LIST_CHANGED = "SearchChangedChanged"
AGS.callback.SEARCH_LOCK_STATE_CHANGED = "SearchLockStateChanged"
AGS.callback.ITEM_DATABASE_UPDATE = "ItemDatabaseUpdated"
AGS.callback.CURRENT_ACTIVITY_CHANGED = "CurrentActivityChanged"
AGS.callback.ACTIVITY_STATE_CHANGED = "ActivityStateChanged"
AGS.callback.SEARCH_RESULT_UPDATE = "SearchResultUpdate"
AGS.callback.SEARCH_RESULTS_RECEIVED = "SearchResultsReceived"

-- fires when a filter value has changed
-- filterId, ... (filter values)
AGS.callback.FILTER_VALUE_CHANGED = "FilterValueChanged"
-- fires when a filter is attached or detached
-- filter
AGS.callback.FILTER_ACTIVE_CHANGED = "FilterActiveChanged"
-- fires on the next frame after any filter has changed. In other words after all FILTER_VALUE_CHANGED and FILTER_ACTIVE_CHANGED callbacks have fired
-- activeFilters
AGS.callback.FILTER_UPDATE = "FilterUpdate"
AGS.callback.FILTER_PREPARED = "FilterPrepared"

AGS.callback.ITEM_PURCHASED = "ItemPurchased"
AGS.callback.ITEM_PURCHASE_FAILED = "ItemPurchaseFailed"
AGS.callback.ITEM_CANCELLED = "ItemCancelled"
AGS.callback.ITEM_POSTED = "ItemPosted"