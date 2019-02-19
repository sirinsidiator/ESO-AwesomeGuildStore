local AGS = AwesomeGuildStore

AGS.callback.BEFORE_INITIAL_SETUP = "BeforeInitialSetup"
AGS.callback.AFTER_INITIAL_SETUP = "AfterInitialSetup"
AGS.callback.AFTER_FILTER_SETUP = "AfterFilterSetup"

AGS.callback.STORE_TAB_CHANGED = "StoreTabChanged"
AGS.callback.GUILD_SELECTION_CHANGED = "SelectedGuildChanged"
AGS.callback.AVAILABLE_GUILDS_CHANGED = "AvailableGuildsChanged"
AGS.callback.SELECTED_SEARCH_CHANGED = "SelectedSearchChanged"
AGS.callback.ITEM_DATABASE_UPDATE = "ItemDatabaseUpdated"
AGS.callback.CURRENT_ACTIVITY_CHANGED = "CurrentActivityChanged"

AGS.callback.FILTER_UPDATE = "FilterUpdate"
AGS.callback.FILTER_VALUE_CHANGED = "FilterValueChanged"
AGS.callback.FILTER_ACTIVE_CHANGED = "FilterActiveChanged"

AGS.callback.ITEM_PURCHASED = "ItemPurchased"
AGS.callback.ITEM_CANCELLED = "ItemCancelled"
AGS.callback.ITEM_POSTED = "ItemPosted"