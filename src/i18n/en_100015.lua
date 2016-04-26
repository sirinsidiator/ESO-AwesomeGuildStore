AwesomeGuildStore.Localization = {
	FILTER_CATEGORY_ALL = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_ALL),
	FILTER_CATEGORY_WEAPON = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_WEAPONS),
	FILTER_CATEGORY_ARMOR = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_ARMOR),
	FILTER_CATEGORY_CONSUMEABLE = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_CONSUMABLE),
	FILTER_CATEGORY_CRAFTING = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_CRAFTING),
	FILTER_CATEGORY_MISC = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_MISCELLANEOUS),

	FILTER_SUBCATEGORY_ALL = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_ALL),
	FILTER_SUBCATEGORY_ONEHANDED = GetString("SI_EQUIPTYPE", EQUIP_TYPE_ONE_HAND),
	FILTER_SUBCATEGORY_TWOHANDED = GetString("SI_EQUIPTYPE", EQUIP_TYPE_TWO_HAND),
	FILTER_SUBCATEGORY_BOW = GetString("SI_WEAPONTYPE", WEAPONTYPE_BOW),
	FILTER_SUBCATEGORY_DESTRUCTION_STAFF = zo_strformat(SI_SKILLS_TREE_NAME_FORMAT, GetSkillLineInfo(SKILL_TYPE_WEAPON, 5)),
	FILTER_SUBCATEGORY_RESTORATION_STAFF = zo_strformat(SI_SKILLS_TREE_NAME_FORMAT, GetSkillLineInfo(SKILL_TYPE_WEAPON, 6)),

	FILTER_SUBCATEGORY_HEAVYARMOR = GetString(SI_TRADING_HOUSE_BROWSE_ARMOR_TYPE_HEAVY),
	FILTER_SUBCATEGORY_MEDIUMARMOR = GetString(SI_TRADING_HOUSE_BROWSE_ARMOR_TYPE_MEDIUM),
	FILTER_SUBCATEGORY_LIGHTARMOR = GetString(SI_TRADING_HOUSE_BROWSE_ARMOR_TYPE_LIGHT),
	FILTER_SUBCATEGORY_SHIELD = GetString(SI_TRADING_HOUSE_BROWSE_ARMOR_TYPE_SHIELD),
	FILTER_SUBCATEGORY_JEWELRY = GetString(SI_GAMEPADITEMCATEGORY38),
	FILTER_SUBCATEGORY_COSTUME = GetString("SI_EQUIPTYPE", EQUIP_TYPE_COSTUME),

	FILTER_SUBCATEGORY_FOOD = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_FOOD)),
	FILTER_SUBCATEGORY_DRINK = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_DRINK)),
	FILTER_SUBCATEGORY_RECIPE = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_RECIPE)),
	FILTER_SUBCATEGORY_POTION = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_POTION)),
	FILTER_SUBCATEGORY_POISON = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_POISON)),
	FILTER_SUBCATEGORY_MOTIF = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_RACIAL_STYLE_MOTIF)),
	FILTER_SUBCATEGORY_CONTAINER = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_CONTAINER)),
	FILTER_SUBCATEGORY_REPAIR = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_AVA_REPAIR)),

	FILTER_SUBCATEGORY_BLACKSMITHING = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetCraftingSkillName(CRAFTING_TYPE_BLACKSMITHING)),
	FILTER_SUBCATEGORY_CLOTHING = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetCraftingSkillName(CRAFTING_TYPE_CLOTHIER)),
	FILTER_SUBCATEGORY_WOODWORKING = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetCraftingSkillName(CRAFTING_TYPE_WOODWORKING)),
	FILTER_SUBCATEGORY_ALCHEMY = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetCraftingSkillName(CRAFTING_TYPE_ALCHEMY)),
	FILTER_SUBCATEGORY_ENCHANTING = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetCraftingSkillName(CRAFTING_TYPE_ENCHANTING)),
	FILTER_SUBCATEGORY_PROVISIONING = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetCraftingSkillName(CRAFTING_TYPE_PROVISIONING)),
	FILTER_SUBCATEGORY_STYLE = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_STYLE_MATERIAL)),
	FILTER_SUBCATEGORY_WEAPONTRAIT = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_WEAPON_TRAIT)),
	FILTER_SUBCATEGORY_ARMORTRAIT = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_ARMOR_TRAIT)),

	FILTER_SUBCATEGORY_GLYPHS = GetString(SI_GAMEPADITEMCATEGORY13),
	FILTER_SUBCATEGORY_SOULGEMS = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_SOUL_GEM)),
	FILTER_SUBCATEGORY_SIEGE = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_SIEGE)),
	FILTER_SUBCATEGORY_BAIT = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_LURE)),
	FILTER_SUBCATEGORY_TOOLS = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_TOOL)),
	FILTER_SUBCATEGORY_TROPHY = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_TROPHY)),

	SUBFILTER_WEAPON_TRAIT_LABEL = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_WEAPON_TRAIT)),
	SUBFILTER_WEAPON_TRAIT_POWERED = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_WEAPON_POWERED),
	SUBFILTER_WEAPON_TRAIT_CHARGED = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_WEAPON_CHARGED),
	SUBFILTER_WEAPON_TRAIT_PRECISE = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_WEAPON_PRECISE),
	SUBFILTER_WEAPON_TRAIT_INFUSED = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_WEAPON_INFUSED),
	SUBFILTER_WEAPON_TRAIT_DEFENDING = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_WEAPON_DEFENDING),
	SUBFILTER_WEAPON_TRAIT_TRAINING = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_WEAPON_TRAINING),
	SUBFILTER_WEAPON_TRAIT_SHARPENED = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_WEAPON_SHARPENED),
	SUBFILTER_WEAPON_TRAIT_DECISIVE = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_WEAPON_DECISIVE),
	SUBFILTER_WEAPON_TRAIT_ORNATE = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_WEAPON_ORNATE),
	SUBFILTER_WEAPON_TRAIT_INTRICATE = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_WEAPON_INTRICATE),
	SUBFILTER_WEAPON_TRAIT_NIRNHONED = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_WEAPON_NIRNHONED),

	SUBFILTER_WEAPON_ENCHANTMENT_LABEL = "Weapon Enchantment",

	SUBFILTER_WEAPON_TYPE_LABEL = "Weapon Type",
	SUBFILTER_WEAPON_TYPE_AXE = GetString("SI_WEAPONTYPE", WEAPONTYPE_AXE),
	SUBFILTER_WEAPON_TYPE_HAMMER = GetString("SI_WEAPONTYPE", WEAPONTYPE_HAMMER),
	SUBFILTER_WEAPON_TYPE_SWORD = GetString("SI_WEAPONTYPE", WEAPONTYPE_SWORD),
	SUBFILTER_WEAPON_TYPE_DAGGER = GetString("SI_WEAPONTYPE", WEAPONTYPE_DAGGER),
	SUBFILTER_WEAPON_TYPE_TWO_HANDED_AXE = GetString("SI_WEAPONTYPE", WEAPONTYPE_TWO_HANDED_AXE),
	SUBFILTER_WEAPON_TYPE_TWO_HANDED_HAMMER = GetString("SI_WEAPONTYPE", WEAPONTYPE_TWO_HANDED_HAMMER),
	SUBFILTER_WEAPON_TYPE_TWO_HANDED_SWORD = GetString("SI_WEAPONTYPE", WEAPONTYPE_TWO_HANDED_SWORD),
	SUBFILTER_WEAPON_TYPE_FIRE = GetString("SI_WEAPONTYPE", WEAPONTYPE_FIRE_STAFF),
	SUBFILTER_WEAPON_TYPE_FROST = GetString("SI_WEAPONTYPE", WEAPONTYPE_FROST_STAFF),
	SUBFILTER_WEAPON_TYPE_LIGHTNING = GetString("SI_WEAPONTYPE", WEAPONTYPE_LIGHTNING_STAFF),

	SUBFILTER_ARMOR_TYPE_LABEL = "Armor Type",
	SUBFILTER_ARMOR_TYPE_HEAD = GetString("SI_EQUIPTYPE", EQUIP_TYPE_HEAD),
	SUBFILTER_ARMOR_TYPE_CHEST = GetString("SI_EQUIPTYPE", EQUIP_TYPE_CHEST),
	SUBFILTER_ARMOR_TYPE_SHOULDERS = GetString("SI_EQUIPTYPE", EQUIP_TYPE_SHOULDERS),
	SUBFILTER_ARMOR_TYPE_WAIST = GetString("SI_EQUIPTYPE", EQUIP_TYPE_WAIST),
	SUBFILTER_ARMOR_TYPE_LEGS = GetString("SI_EQUIPTYPE", EQUIP_TYPE_LEGS),
	SUBFILTER_ARMOR_TYPE_FEET = GetString("SI_EQUIPTYPE", EQUIP_TYPE_FEET),
	SUBFILTER_ARMOR_TYPE_HAND = GetString("SI_EQUIPTYPE", EQUIP_TYPE_HAND),

	SUBFILTER_ARMOR_ENCHANTMENT_LABEL = "Armor Enchantment",

	SUBFILTER_ARMOR_TRAIT_LABEL = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_ARMOR_TRAIT)),
	SUBFILTER_ARMOR_TRAIT_STURDY = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_STURDY),
	SUBFILTER_ARMOR_TRAIT_IMPENETRABLE = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE),
	SUBFILTER_ARMOR_TRAIT_REINFORCED = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_REINFORCED),
	SUBFILTER_ARMOR_TRAIT_WELLFITTED = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED),
	SUBFILTER_ARMOR_TRAIT_TRAINING = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_TRAINING),
	SUBFILTER_ARMOR_TRAIT_INFUSED = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_INFUSED),
	SUBFILTER_ARMOR_TRAIT_PROSPEROUS = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS),
	SUBFILTER_ARMOR_TRAIT_DIVINES = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_DIVINES),
	SUBFILTER_ARMOR_TRAIT_ORNATE = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_ORNATE),
	SUBFILTER_ARMOR_TRAIT_INTRICATE = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_INTRICATE),
	SUBFILTER_ARMOR_TRAIT_NIRNHONED = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_NIRNHONED),

	SUBFILTER_JEWELRY_TYPE_LABEL = "Jewelry Type",
	SUBFILTER_JEWELRY_TYPE_RING = GetString("SI_EQUIPTYPE", EQUIP_TYPE_RING),
	SUBFILTER_JEWELRY_TYPE_NECK = GetString("SI_EQUIPTYPE", EQUIP_TYPE_NECK),

	SUBFILTER_JEWELRY_TRAIT_LABEL = "Jewelry Trait",
	SUBFILTER_JEWELRY_TRAIT_HEALTHY = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_JEWELRY_HEALTHY),
	SUBFILTER_JEWELRY_TRAIT_ARCANE = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_JEWELRY_ARCANE),
	SUBFILTER_JEWELRY_TRAIT_ROBUST = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_JEWELRY_ROBUST),
	SUBFILTER_JEWELRY_TRAIT_ORNATE = GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_JEWELRY_ORNATE),

	SUBFILTER_JEWELRY_ENCHANTMENT_LABEL = "Jewelry Enchantment",

	SUBFILTER_MATERIAL_TYPE_LABEL = "Material Type",
	SUBFILTER_MATERIAL_BLACKSMITHING_RAWMATERIAL = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_BLACKSMITHING_RAW_MATERIAL)),
	SUBFILTER_MATERIAL_BLACKSMITHING_MATERIAL = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_BLACKSMITHING_MATERIAL)),
	SUBFILTER_MATERIAL_BLACKSMITHING_BOOSTER = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_BLACKSMITHING_BOOSTER)),
	SUBFILTER_MATERIAL_CLOTHING_RAWMATERIAL = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_CLOTHIER_RAW_MATERIAL)),
	SUBFILTER_MATERIAL_CLOTHING_MATERIAL = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_CLOTHIER_MATERIAL)),
	SUBFILTER_MATERIAL_CLOTHING_BOOSTER = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_CLOTHIER_BOOSTER)),
	SUBFILTER_MATERIAL_WOODWORKING_RAWMATERIAL = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_WOODWORKING_RAW_MATERIAL)),
	SUBFILTER_MATERIAL_WOODWORKING_MATERIAL = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_WOODWORKING_MATERIAL)),
	SUBFILTER_MATERIAL_WOODWORKING_BOOSTER = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_WOODWORKING_BOOSTER)),
	SUBFILTER_MATERIAL_STYLE_RAWMATERIAL = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_RAW_MATERIAL)),
	SUBFILTER_MATERIAL_STYLE_MATERIAL = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_STYLE_MATERIAL)),

	SUBFILTER_INGREDIENT_TYPE_LABEL = "Ingredient Type",
	SUBFILTER_INGREDIENT_TYPE_POTION_SOLVENT = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_POTION_BASE)),
	SUBFILTER_INGREDIENT_TYPE_POISON_SOLVENT = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_POISON_BASE)),
	SUBFILTER_INGREDIENT_TYPE_REAGENT = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_REAGENT)),

	SUBFILTER_RUNE_TYPE_LABEL = "Rune Type",
	SUBFILTER_RUNE_TYPE_ASPECT = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_ENCHANTING_RUNE_ASPECT)),
	SUBFILTER_RUNE_TYPE_ESSENCE = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_ENCHANTING_RUNE_ESSENCE)),
	SUBFILTER_RUNE_TYPE_POTENCY = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_ENCHANTING_RUNE_POTENCY)),

	SUBFILTER_GLYPH_TYPE_LABEL = "Glyph Type",
	SUBFILTER_GLYPH_TYPE_ARMOR = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_GLYPH_ARMOR)),
	SUBFILTER_GLYPH_TYPE_WEAPON = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_GLYPH_WEAPON)),
	SUBFILTER_GLYPH_TYPE_JEWELRY = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetString("SI_ITEMTYPE", ITEMTYPE_GLYPH_JEWELRY)),

	SUBFILTER_RECIPE_KNOWLEDGE_LABEL = "Recipe Knowledge",
	SUBFILTER_RECIPE_KNOWLEDGE_UNKNOWN = "Unknown Recipes",
	SUBFILTER_RECIPE_KNOWLEDGE_KNOWN = "Known Recipes",

	SUBFILTER_MOTIF_KNOWLEDGE_LABEL = "Motif Knowledge",
	SUBFILTER_MOTIF_KNOWLEDGE_UNKNOWN = "Unknown Motifs",
	SUBFILTER_MOTIF_KNOWLEDGE_KNOWN = "Known Motifs",

	SUBFILTER_TRAIT_KNOWLEDGE_LABEL = "Trait Knowledge",
	SUBFILTER_TRAIT_KNOWLEDGE_UNKNOWN = "Unknown Trait",
	SUBFILTER_TRAIT_KNOWLEDGE_KNOWN = "Known Trait",

	SUBFILTER_RUNE_KNOWLEDGE_LABEL = "Rune Knowledge",
	SUBFILTER_RUNE_KNOWLEDGE_UNKNOWN = "Unknown Rune",
	SUBFILTER_RUNE_KNOWLEDGE_KNOWN = "Known Rune",

	SUBFILTER_ITEM_STYLE_LABEL = GetString(SI_SMITHING_HEADER_STYLE),
	SUBFILTER_ITEM_STYLE_BRETON = zo_strformat("<<1>>", GetString("SI_ITEMSTYLE", ITEMSTYLE_RACIAL_BRETON)),
	SUBFILTER_ITEM_STYLE_REDGUARD = zo_strformat("<<1>>", GetString("SI_ITEMSTYLE", ITEMSTYLE_RACIAL_REDGUARD)),
	SUBFILTER_ITEM_STYLE_ORC = zo_strformat("<<1>>", GetString("SI_ITEMSTYLE", ITEMSTYLE_RACIAL_ORC)),
	SUBFILTER_ITEM_STYLE_DUNMER = zo_strformat("<<1>>", GetString("SI_ITEMSTYLE", ITEMSTYLE_RACIAL_DARK_ELF)),
	SUBFILTER_ITEM_STYLE_NORD = zo_strformat("<<1>>", GetString("SI_ITEMSTYLE", ITEMSTYLE_RACIAL_NORD)),
	SUBFILTER_ITEM_STYLE_ARGONIAN = zo_strformat("<<1>>", GetString("SI_ITEMSTYLE", ITEMSTYLE_RACIAL_ARGONIAN)),
	SUBFILTER_ITEM_STYLE_ALTMER = zo_strformat("<<1>>", GetString("SI_ITEMSTYLE", ITEMSTYLE_RACIAL_HIGH_ELF)),
	SUBFILTER_ITEM_STYLE_BOSMER = zo_strformat("<<1>>", GetString("SI_ITEMSTYLE", ITEMSTYLE_RACIAL_WOOD_ELF)),
	SUBFILTER_ITEM_STYLE_KHAJIIT = zo_strformat("<<1>>", GetString("SI_ITEMSTYLE", ITEMSTYLE_RACIAL_KHAJIIT)),
	SUBFILTER_ITEM_STYLE_IMPERIAL = zo_strformat("<<1>>", GetString("SI_ITEMSTYLE", ITEMSTYLE_RACIAL_IMPERIAL)),
	SUBFILTER_ITEM_STYLE_ANCIENT_ELF = zo_strformat("<<1>>", GetString("SI_ITEMSTYLE", ITEMSTYLE_AREA_ANCIENT_ELF)),
	SUBFILTER_ITEM_STYLE_PRIMAL = zo_strformat("<<1>>", GetString("SI_ITEMSTYLE", ITEMSTYLE_ENEMY_PRIMITIVE)),
	SUBFILTER_ITEM_STYLE_BARBARIC = zo_strformat("<<1>>", GetString("SI_ITEMSTYLE", ITEMSTYLE_AREA_REACH)),
	SUBFILTER_ITEM_STYLE_DAEDRIC = zo_strformat("<<1>>", GetString("SI_ITEMSTYLE", ITEMSTYLE_ENEMY_DAEDRIC)),
	SUBFILTER_ITEM_STYLE_DWEMER = zo_strformat("<<1>>", GetString("SI_ITEMSTYLE", ITEMSTYLE_AREA_DWEMER)),
	SUBFILTER_ITEM_STYLE_GLASS = zo_strformat("<<1>>", GetString("SI_ITEMSTYLE", ITEMSTYLE_GLASS)),
	SUBFILTER_ITEM_STYLE_XIVKYN = zo_strformat("<<1>>", GetString("SI_ITEMSTYLE", ITEMSTYLE_AREA_XIVKYN)),
	SUBFILTER_ITEM_STYLE_DAGGERFALL = zo_strformat("<<1>>", GetString("SI_ITEMSTYLE", ITEMSTYLE_ALLIANCE_DAGGERFALL)),
	SUBFILTER_ITEM_STYLE_EBONHEART = zo_strformat("<<1>>", GetString("SI_ITEMSTYLE", ITEMSTYLE_ALLIANCE_EBONHEART)),
	SUBFILTER_ITEM_STYLE_ALDMERI = zo_strformat("<<1>>", GetString("SI_ITEMSTYLE", ITEMSTYLE_ALLIANCE_ALDMERI)),
	SUBFILTER_ITEM_STYLE_AKAVIRI = zo_strformat("<<1>>", GetString("SI_ITEMSTYLE", ITEMSTYLE_AREA_AKAVIRI)),
	SUBFILTER_ITEM_STYLE_MERCENARY = zo_strformat("<<1>>", GetString("SI_ITEMSTYLE", ITEMSTYLE_UNDAUNTED)),
	SUBFILTER_ITEM_STYLE_ANCIENT_ORC = zo_strformat("<<1>>", GetString("SI_ITEMSTYLE", ITEMSTYLE_AREA_ANCIENT_ORC)),
	SUBFILTER_ITEM_STYLE_MALACATH = zo_strformat("<<1>>", GetString("SI_ITEMSTYLE", ITEMSTYLE_DEITY_MALACATH)),
	SUBFILTER_ITEM_STYLE_TRINIMAC = zo_strformat("<<1>>", GetString("SI_ITEMSTYLE", ITEMSTYLE_DEITY_TRINIMAC)),
	SUBFILTER_ITEM_STYLE_SOUL_SHRIVEN = zo_strformat("<<1>>", GetString("SI_ITEMSTYLE", ITEMSTYLE_AREA_SOUL_SHRIVEN)),
	SUBFILTER_ITEM_STYLE_OUTLAW = zo_strformat("<<1>>", GetString("SI_ITEMSTYLE", ITEMSTYLE_ORG_OUTLAW)),
	SUBFILTER_ITEM_STYLE_ABAHS_WATCH = zo_strformat("<<1>>", GetString("SI_ITEMSTYLE", ITEMSTYLE_ORG_ABAHS_WATCH)),
	SUBFILTER_ITEM_STYLE_THIEVES_GUILD = zo_strformat("<<1>>", GetString("SI_ITEMSTYLE", ITEMSTYLE_ORG_THIEVES_GUILD)),
	SUBFILTER_ITEM_STYLE_ASSASSINS = zo_strformat("<<1>>", GetString("SI_ITEMSTYLE", ITEMSTYLE_ORG_ASSASSINS)),
	SUBFILTER_ITEM_STYLE_OTHER = GetString(SI_TRADING_HOUSE_BROWSE_ITEM_TYPE_OTHER),

	SUBFILTER_ITEM_SET_LABEL = "Itemset",
	SUBFILTER_ITEM_SET_NORMAL = "Individual item",
	SUBFILTER_ITEM_SET_HAS_SET = "Set item",

	SUBFILTER_CRAFTING_LABEL = "Crafting",
	SUBFILTER_CRAFTING_IS_CRAFTED = "Crafted item",
	SUBFILTER_CRAFTING_IS_LOOT = "Looted item",

	SUBFILTER_RECIPE_IMPROVEMENT_LABEL = "Recipe Improvement",
	SUBFILTER_RECIPE_IMPROVEMENT_TOOLTIP = "Recipe Improvement <<1>> <<2>>",

	NORMAL_QUALITY_LABEL = GetString(SI_TRADING_HOUSE_BROWSE_QUALITY_NORMAL),
	MAGIC_QUALITY_LABEL = GetString(SI_TRADING_HOUSE_BROWSE_QUALITY_MAGIC),
	ARCANE_QUALITY_LABEL = GetString(SI_TRADING_HOUSE_BROWSE_QUALITY_ARCANE),
	ARTIFACT_QUALITY_LABEL = GetString(SI_TRADING_HOUSE_BROWSE_QUALITY_ARTIFACT),
	LEGENDARY_QUALITY_LABEL = GetString(SI_TRADING_HOUSE_BROWSE_QUALITY_LEGENDARY),

	START_SEARCH_LABEL = GetString(SI_TRADING_HOUSE_DO_SEARCH),
	AUTO_SEARCH_TOGGLE_LABEL = "Toggle Auto Search",
	SEARCH_PREVIOUS_PAGE_LABEL = "Show Previous Page",
	SEARCH_SHOW_MORE_LABEL = "Show More Results",
	RESET_ALL_FILTERS_LABEL = "Reset All Filters",
	RESET_FILTER_LABEL_TEMPLATE = "Reset %s Filter",

	CATEGORY_TITLE = "Category",
	SUBCATEGORY_TITLE = "Subcategory",

	PRICE_SELECTOR_TITLE = GetString(SI_TRADING_HOUSE_BROWSE_PRICE_RANGE_LABEL),

	LEVEL_SELECTOR_TITLE = GetString(SI_TRADING_HOUSE_BROWSE_LEVEL_RANGE_LABEL),
	CP_SELECTOR_TITLE = GetString(SI_TRADING_HOUSE_BROWSE_CHAMPION_POINTS_RANGE_LABEL),

	QUALITY_SELECTOR_TITLE = "Quality Range:",

	TEXT_FILTER_TITLE = "Text Filter:",
	TEXT_FILTER_TEXT = "Filter by text",
	TEXT_FILTER_ITEMCOUNT_TEMPLATE = GetString(SI_TRADING_HOUSE_RESULT_COUNT) .. " (<<2>>)",

	UNIT_PRICE_FILTER_TITLE = "Unit Price Filter:",

	WARNING_SUBFILTER_LIMIT = "Cannot filter for more than 8 at a time",

	SEARCH_LIBRARY_TOGGLE_LABEL = "Toggle Search Library",
	SEARCH_LIBRARY_HISTORY_LABEL = "History",
	SEARCH_LIBRARY_FAVORITES_LABEL = "Favorites",
	SEARCH_LIBRARY_FAVORITE_BUTTON_ADD_TOOLTIP = "Add to Favorites",
	SEARCH_LIBRARY_FAVORITE_BUTTON_REMOVE_TOOLTIP = "Remove from Favorites",
	SEARCH_LIBRARY_EDIT_LABEL_BUTTON_TOOLTIP = "Rename Entry",
	SEARCH_LIBRARY_DELETE_LABEL_BUTTON_TOOLTIP = "Remove from History",
	SEARCH_LIBRARY_MENU_OPEN_SETTINGS = "Open Addon Settings",
	SEARCH_LIBRARY_MENU_CLEAR_HISTORY = "Clear History",
	SEARCH_LIBRARY_MENU_CLEAR_FAVORITES = "Clear Favorites",
	SEARCH_LIBRARY_MENU_UNDO_ACTION = "Undo Last Action",
	SEARCH_LIBRARY_MENU_UNLOCK_WINDOW = "Unlock Window",
	SEARCH_LIBRARY_MENU_LOCK_WINDOW = "Lock Window",
	SEARCH_LIBRARY_MENU_RESET_WINDOW = "Reset Window",
	SEARCH_LIBRARY_MENU_CLOSE_WINDOW = "Close Window",
	SEARCH_LIBRARY_SORT_HEADER_NAME = "Name",
	SEARCH_LIBRARY_SORT_HEADER_SEARCHES = "Searches",

	TOOLTIP_LESS_THAN = "under ",
	TOOLTIP_GREATER_THAN = "over ",

	MAIL_AUGMENTATION_MESSAGE_BODY = "You sold <<2>> <<t:1>> to <<3>> for <<4>>.",
	MAIL_AUGMENTATION_INVOICE_SELL_VALUE = GetString(SI_TRADING_HOUSE_POSTING_PRICE_TOTAL):gsub(":", ""),
	MAIL_AUGMENTATION_INVOICE_LISTING_FEE = GetString(SI_TRADING_HOUSE_POSTING_LISTING_FEE),
	MAIL_AUGMENTATION_INVOICE_GUILD_BANK = GetString(SI_TRADING_HOUSE_POSTING_TH_CUT),
	MAIL_AUGMENTATION_INVOICE_COMMISSION = "Commission",
	MAIL_AUGMENTATION_INVOICE_LISTING_FEE_REFUND = GetString(SI_TRADING_HOUSE_POSTING_LISTING_FEE) .. " (refund)",
	MAIL_AUGMENTATION_INVOICE_PROFIT = GetString(SI_TRADING_HOUSE_POSTING_PROFIT),
	MAIL_AUGMENTATION_INVOICE_RECEIVED = GetString(SI_MAIL_READ_SENT_GOLD_LABEL):gsub(":", ""),
	MAIL_AUGMENTATION_REQUEST_DATA = "Load Details",

	SETTINGS_REQUIRES_RELOADUI_WARNING = "Only is applied after you reload the UI",
	SETTINGS_KEEP_FILTERS_ON_CLOSE_LABEL = "Remember filters between store visits",
	SETTINGS_KEEP_FILTERS_ON_CLOSE_DESCRIPTION = "Leaves the store filters set during a play session instead of clearing it when you close the guild store window and restores the last active state when the UI is loaded",
	SETTINGS_OLD_QUALITY_SELECTOR_BEHAVIOR_LABEL = "Use old quality selector behavior",
	SETTINGS_OLD_QUALITY_SELECTOR_BEHAVIOR_DESCRIPTION = "When enabled left and right click set lower and upper quality and double or shift click sets both to the same value",
	SETTINGS_DISPLAY_PER_UNIT_PRICE_LABEL = "Show per unit price in search results",
	SETTINGS_DISPLAY_PER_UNIT_PRICE_DESCRIPTION = "When enabled the results of a guild store search show the per unit price of a stack below the overall price",
	SETTINGS_SORT_WITHOUT_SEARCH_LABEL = "Select order without search",
	SETTINGS_SORT_WITHOUT_SEARCH_DESCRIPTION = "Allows you to change the sort order without triggering a new search. The currently shown results will only change after a manual search",
	SETTINGS_KEEP_SORTORDER_ON_CLOSE_LABEL = "Remember sort order",
	SETTINGS_KEEP_SORTORDER_ON_CLOSE_DESCRIPTION = "Leaves the store sort order set between play sessions instead of clearing it.",
	SETTINGS_LIST_WITH_SINGLE_CLICK_LABEL = "Single click item listing",
	SETTINGS_LIST_WITH_SINGLE_CLICK_DESCRIPTION = "Select items for sale with a single click in the sell tab.",
	SETTINGS_SHOW_SEARCH_LIBRARY_TOOLTIPS_LABEL = "Tooltips in Search Library",
	SETTINGS_SHOW_SEARCH_LIBRARY_TOOLTIPS_DESCRIPTION = "When active, a tooltip with details like level and quality is shown for each entry in the search library.",
	SETTINGS_SHOW_TRADER_TOOLTIPS_LABEL = "Trader Tooltips",
	SETTINGS_SHOW_TRADER_TOOLTIPS_DESCRIPTION = "Show the currently hired trader for a guild that you are a member of, when hovering over the name or an entry in the drop down menu",
	SETTINGS_AUTO_CLEAR_HISTORY_LABEL = "Auto clear history",
	SETTINGS_AUTO_CLEAR_HISTORY_DESCRIPTION = "Automatically deletes all history entries when you open the guild store for the first time in a game session. You can undo the deletion via the menu in the search library",
	SETTINGS_MAIL_AUGMENTATION_LABEL = "Mail augmentation",
	SETTINGS_MAIL_AUGMENTATION_DESCRIPTION = "Adds more detailed information about a transaction to an incoming Guild Store Mail if the data is available in the Guild Activity Log.",
	SETTINGS_MAIL_AUGMENTATION_INVOICE_LABEL = "Show invoice on mails",
	SETTINGS_MAIL_AUGMENTATION_INVOICE_DESCRIPTION = "Adds a detailed invoice to the mail which lists all deductions.",
	SETTINGS_PURCHASE_NOTIFICATION_LABEL = "Purchase notifications",
	SETTINGS_PURCHASE_NOTIFICATION_DESCRIPTION = "Shows a message in chat after you have purchased an item in a guild store",
	SETTINGS_CANCEL_NOTIFICATION_LABEL = "Cancel notifications",
	SETTINGS_CANCEL_NOTIFICATION_DESCRIPTION = "Shows a message in chat after you have cancelled an item listing from a guild store",
	SETTINGS_LISTED_NOTIFICATION_LABEL = "Listed item notifications",
	SETTINGS_LISTED_NOTIFICATION_DESCRIPTION = "Shows a message in chat after you have created a new item listing in a guild store",
	SETTINGS_DISABLE_CUSTOM_SELL_TAB_FILTER_LABEL = "Disable custom selltab filter",
	SETTINGS_DISABLE_CUSTOM_SELL_TAB_FILTER_DESCRIPTION = "Shows the ingame inventory filter instead of AGS own version when deactivated.",
	SETTINGS_SKIP_GUILD_KIOSK_DIALOG_LABEL = "Skip guild kiosk dialog",
	SETTINGS_SKIP_GUILD_KIOSK_DIALOG_DESCRIPTION = "When activated, the dialog at guild traders (not at banks) is skipped and the store opened automatically. This can be suppressed by holding the shift key when talking to a trader.",
	SETTINGS_SKIP_EMPTY_PAGES_LABEL = "Skip empty result pages",
	SETTINGS_SKIP_EMPTY_PAGES_DESCRIPTION = "When activated, pages that show no results due to local filters will automatically trigger a search for the next page. This can be suppressed by holding the ctrl key before the results are returned.",

	CONTROLS_SUPPRESS_LOCAL_FILTERS = "Suppress Local Filters",

	INVALID_STATE = "Invalid Store State.\nThis is a bug in the game and should be fixed soon.",

	LOCAL_FILTER_EXPLANATION_TOOLTIP = "This filter is local and only applies to the currently visible page",

	PURCHASE_NOTIFICATION = "You have bought <<1>>x <<t:2>> from <<3>> for <<4>> in <<5>>",
	CANCEL_NOTIFICATION = "You have cancelled your listing of <<1>>x <<t:2>> for <<3>> in <<4>>",
	LISTED_NOTIFICATION = "You have listed <<1>>x <<t:2>> for <<3>> in <<4>>",
}
