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

-----------------------------------------------------------------------------------------


--local function UpdateItems(searchResults)
--
--end

--local currentGuildIndex
--local currentStorePage
--
--local function Reset()
--	currentGuildIndex = 1
--	currentStorePage = 1
--end
--
--local function RequestNextPage()
--	if(GetTradingHouseCooldownRemaining() > 0) then zo_callLater(RequestNextPage, GetTradingHouseCooldownRemaining()) return end
--	local guildId = GetTradingHouseGuildDetails(currentGuildIndex)
--	if(CanBuyFromTradingHouse(guildId)) then
--		if(GetSelectedTradingHouseGuildId() ~= guildId) then
--			if(not SelectTradingHouseGuildId(guildId)) then d("error: could not select guild") return end
--		end
--		ClearAllTradingHouseSearchTerms()
--		ExecuteTradingHouseSearch(currentStorePage, TRADING_HOUSE_SORT_SALE_PRICE, true)
--	end
--end
--
--local function HandleSearchResults(eventCode, guildId, numItemsOnPage, currentPage, hasMorePages)
--	for i = 1, numItemsOnPage do
--		local icon, itemName, quality, stackCount, sellerName, timeRemaining, purchasePrice = GetTradingHouseSearchResultItemInfo(i)
--		--		local toolTip = CreateControl(string.format("ItemInfo_%d_%d_%d", guildId, currentPage, i), CT_TOOLTIP)
--		--		toolTip:SetTradingHouseItem(i)
--		local itemLink = GetTradingHouseSearchResultItemLink(i, LINK_STYLE_DEFAULT)
--	end
--
--	if(hasMorePages) then
--		currentStorePage = currentStorePage + 1
--		RequestNextPage()
--	elseif(currentGuildIndex < GetNumTradingHouseGuilds()) then
--		currentGuildIndex = currentGuildIndex + 1
--		currentStorePage = 1
--		RequestNextPage()
--	end
--end

local comboBox
local guildSelector
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

local entryByGuildId
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

--local pressedButton
--local function CreateButton(parent, name, textureName, x, y)
--	local button = parent:CreateControl(ADDON_NAME .. name, CT_BUTTON)
--	button:SetNormalTexture(textureName:format("up"))
--	button:SetPressedTexture(textureName:format("down"))
--	button:SetMouseOverTexture(textureName:format("over"))
--	button:SetHidden(false)
--	button:SetDimensions(50, 50)
--	button:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
--	button:SetHandler("OnMouseUp", function(control, button, isInside)
--		if(button == 1 and isInside) then
--			pressedButton:SetState(BSTATE_NORMAL)
--			control:SetState(BSTATE_PRESSED)
--			pressedButton = control
--		end
--	end)
--	return button
--end

--local filtersInitialized = false
--local function InitializeFilters(control)
--	if(filtersInitialized) then return end
--	--control:GetNamedChild("ItemCategory"):SetHidden(true)
--	local common = control:GetNamedChild("Common")
--	common:ClearAnchors()
--	common:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 320)
--
--	pressedButton = CreateButton(control, "NoFilterButton", "EsoUI/Art/Inventory/inventory_tabIcon_all_%s.dds", 0, 0)
--	pressedButton:SetState(BSTATE_PRESSED)
--	CreateButton(control, "WeaponFilterButton", "EsoUI/Art/Inventory/inventory_tabIcon_weapons_%s.dds", 0, 50)
--	CreateButton(control, "ArmorFilterButton", "EsoUI/Art/Inventory/inventory_tabIcon_armor_%s.dds", 0, 100)
--	CreateButton(control, "ConsumableFilterButton", "EsoUI/Art/Inventory/inventory_tabIcon_consumables_%s.dds", 0, 150)
--	CreateButton(control, "CraftingFilterButton", "EsoUI/Art/Inventory/inventory_tabIcon_crafting_%s.dds", 0, 200)
--	CreateButton(control, "MiscFilterButton", "EsoUI/Art/Inventory/inventory_tabIcon_misc_%s.dds", 0, 250)
--
--	filtersInitialized = true
--end

local resetButtonInitialized = false
local function InitializeResetButton(control)
	if(resetButtonInitialized) then return end
	local common = control:GetNamedChild("Common")
	local resetButton = CreateControlFromVirtual(ADDON_NAME .. "FilterResetButton", common, "ZO_DefaultButton")
	resetButton:SetAnchor(TOP, common, TOP, 0, 200)
	resetButton:SetText("reset")
	resetButton:SetHandler("OnMouseUp",function(control, button, isInside)
		if(button == 1 and isInside) then
			local originalClearSearchResults = TRADING_HOUSE.ClearSearchResults
			TRADING_HOUSE.ClearSearchResults = function() end
			TRADING_HOUSE:ResetAllSearchData(true)
			TRADING_HOUSE.ClearSearchResults = originalClearSearchResults
		end
	end)

	resetButtonInitialized = true
end

local saveData
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

OnAddonLoaded(function()
	AwesomeGuildStore_Data = AwesomeGuildStore_Data or {}
	saveData = AwesomeGuildStore_Data[GetDisplayName()] or { version = 1 }
	AwesomeGuildStore_Data[GetDisplayName()] = saveData

	local title = TRADING_HOUSE.m_control:GetNamedChild("Title")
	local titleLabel = title:GetNamedChild("Label")
	CreateControlFromVirtual(ADDON_NAME .. "GuildSelector", title, ADDON_NAME .. "GuildSelectorTemplate")

	RegisterForEvent(EVENT_TRADING_HOUSE_STATUS_RECEIVED, function()
		local guildId = GetSelectedTradingHouseGuildId()

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
			InitializeResetButton(self.m_browseItems)
			--				InitializeFilters(self.m_browseItems)
		end
	end

	ZO_PreHook(TRADING_HOUSE, "ResetAllSearchData", function(self, doReset)
		if(doReset) then
			self.m_levelRangeFilterType = TRADING_HOUSE_FILTER_TYPE_LEVEL
			self.m_levelRangeToggle:SetState(BSTATE_NORMAL, false)
			self.m_levelRangeLabel:SetText(GetString(SI_TRADING_HOUSE_BROWSE_LEVEL_RANGE_LABEL))
			return
		end
		self:ClearSearchResults()
		return true
	end)

	--	titleLabel:ClearAnchors()
	--	titleLabel:SetAnchor(LEFT, title, LEFT, 100, 0)
	--	titleLabel:SetDimensions(350, 50)
	--	titleLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
	--RegisterForEvent(EVENT_TRADING_HOUSE_SEARCH_RESULTS_RECEIVED, HandleSearchResults)

	-- TODO: map inventory categories to store categories
	-- all items

	-- weapons
	-- -- restoration staff
	-- -- ## SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_EQUIP, EQUIP_TYPE_TWO_HAND)
	-- -- ## SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_WEAPON, WEAPONTYPE_HEALING_STAFF)

	-- -- destruction staff
	-- -- ## SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_EQUIP, EQUIP_TYPE_TWO_HAND)
	-- -- all
	-- -- ## SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_WEAPON, WEAPONTYPE_FIRE_STAFF)
	-- -- ## SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_WEAPON, WEAPONTYPE_FROST_STAFF)
	-- -- ## SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_WEAPON, WEAPONTYPE_LIGHTNING_STAFF)
	-- -- fire
	-- -- ## SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_WEAPON, WEAPONTYPE_FIRE_STAFF)
	-- -- frost
	-- -- ## SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_WEAPON, WEAPONTYPE_FROST_STAFF)
	-- -- lightning
	-- -- ## SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_WEAPON, WEAPONTYPE_LIGHTNING_STAFF)

	-- -- bow
	-- -- ## SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_EQUIP, EQUIP_TYPE_TWO_HAND)
	-- -- ## SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_WEAPON, WEAPONTYPE_BOW)

	-- -- two handed
	-- -- ## SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_EQUIP, EQUIP_TYPE_TWO_HAND)
	-- -- all
	-- -- ## SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_WEAPON, WEAPONTYPE_TWO_HANDED_AXE)
	-- -- ## SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_WEAPON, WEAPONTYPE_TWO_HANDED_SWORD)
	-- -- ## SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_WEAPON, WEAPONTYPE_TWO_HANDED_HAMMER)
	-- -- axe
	-- -- ## SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_WEAPON, WEAPONTYPE_TWO_HANDED_AXE)
	-- -- hammer
	-- -- ## SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_WEAPON, WEAPONTYPE_TWO_HANDED_HAMMER)
	-- -- sword
	-- -- ## SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_WEAPON, WEAPONTYPE_TWO_HANDED_SWORD)

	-- -- one handed
	-- -- ## SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_EQUIP, EQUIP_TYPE_ONE_HAND)
	-- -- all
	-- -- ## SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_WEAPON, WEAPONTYPE_AXE)
	-- -- ## SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_WEAPON, WEAPONTYPE_HAMMER)
	-- -- ## SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_WEAPON, WEAPONTYPE_SWORD)
	-- -- ## SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_WEAPON, WEAPONTYPE_DAGGER)
	-- -- axe
	-- -- ## SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_WEAPON, WEAPONTYPE_AXE)
	-- -- hammer
	-- -- ## SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_WEAPON, WEAPONTYPE_HAMMER)
	-- -- sword
	-- -- ## SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_WEAPON, WEAPONTYPE_SWORD)
	-- -- dagger
	-- -- ## SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_WEAPON, WEAPONTYPE_DAGGER)

	-- -- all
	-- -- ## SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_EQUIP, EQUIP_TYPE_ONE_HAND)
	-- -- ## SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_EQUIP, EQUIP_TYPE_TWO_HAND)

	-- apparel
	-- misc
	-- -- ## SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_EQUIP, EQUIP_TYPE_COSTUME)
	-- jewelry -- filter all/ring/neck
	-- -- all
	-- -- ## SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_EQUIP, EQUIP_TYPE_NECK)
	-- -- ## SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_EQUIP, EQUIP_TYPE_RING)
	-- -- neck
	-- -- ## SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_EQUIP, EQUIP_TYPE_NECK)
	-- -- ring
	-- -- ## SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_EQUIP, EQUIP_TYPE_RING)
	-- shield
	-- -- ## SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_EQUIP, EQUIP_TYPE_OFF_HAND)
	-- -- ## SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_WEAPON, WEAPONTYPE_SHIELD)
	-- light -- filter all/head/chest/shoulders/hand/waist/legs/feet
	-- TRADING_HOUSE_FILTER_TYPE_ARMOR
	-- medium -- filter all/head/chest/shoulders/hand/waist/legs/feet
	-- heavy -- filter all/head/chest/shoulders/hand/waist/legs/feet
	-- all -- EQUIP_TYPE_HEAD, EQUIP_TYPE_CHEST, EQUIP_TYPE_SHOULDERS, EQUIP_TYPE_WAIST, EQUIP_TYPE_LEGS, EQUIP_TYPE_FEET, EQUIP_TYPE_HAND

	-- consumeable
	-- repair
	-- container
	-- motif
	-- poison
	-- potion
	-- recipe
	-- drink
	-- food
	-- all
	-- crafting
	-- armor trait
	-- weapon trait
	-- style
	-- provisioning
	-- enchanting -- filter all/aspect/essence/potency
	-- alchemy
	-- woodworking
	-- clothier
	-- blacksmithing
	-- all
	-- misc
	-- trophy
	-- trash
	-- bait
	-- siege
	-- soulgem
	-- armor glyph
	-- jewelry glyph
	-- weapon glyph
	-- all

	--        SI_TRADING_HOUSE_BROWSE_ALL_ITEMS,
	--        SI_TRADING_HOUSE_BROWSE_ITEM_TYPE_WEAPON,
	--        SI_TRADING_HOUSE_BROWSE_ITEM_TYPE_APPAREL,
	--        SI_TRADING_HOUSE_BROWSE_ITEM_TYPE_GLYPHS_AND_GEMS,
	--        SI_TRADING_HOUSE_BROWSE_ITEM_TYPE_CRAFTING,
	--        SI_TRADING_HOUSE_BROWSE_ITEM_TYPE_GUILD_ITEMS,
	--        SI_TRADING_HOUSE_BROWSE_ITEM_TYPE_FOOD_AND_POTIONS,
	--        SI_TRADING_HOUSE_BROWSE_ITEM_TYPE_OTHER,
end)
