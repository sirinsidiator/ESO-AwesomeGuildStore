local L = AwesomeGuildStore.Localization
local RegisterForEvent = AwesomeGuildStore.RegisterForEvent
local ToggleButton = AwesomeGuildStore.ToggleButton
local FILTER_PRESETS = AwesomeGuildStore.FILTER_PRESETS
local SUBFILTER_PRESETS = AwesomeGuildStore.SUBFILTER_PRESETS

local SEARCH_DATA_TYPE = 1
local HISTORY_LENGTH = 50
local SAVE_VERSION = 1
local SAVE_TEMPLATE = "%d:%s:%s:%s:%s:%s"

local SAVE_BUTTON_TEMPLATE = {
	name = "SaveButton",
	texture = "AwesomeGuildStore/images/favorite_%s.dds",
	size = 24,
	offsetX = 0,
	offsetY = 0
}

local EDIT_BUTTON_TEMPLATE = {
	name = "EditButton",
	texture = "EsoUI/Art/Buttons/edit_%s.dds",
	size = 24,
	offsetX = -24,
	offsetY = 0
}

local DELETE_BUTTON_TEMPLATE = {
	name = "DeleteButton",
	texture = "EsoUI/Art/Buttons/cancel_%s.dds",
	size = 24,
	offsetX = -48,
	offsetY = 0
}

local SearchLibrary = ZO_Object:Subclass()
AwesomeGuildStore.SearchLibrary = SearchLibrary

function SearchLibrary:New(saveData)
	local library = ZO_Object.New(self)
	library:Initialize(saveData)
	return library
end

function SearchLibrary:Initialize(saveData)
	self.saveData = saveData
	self.filter = {}
	self.currentState = {}

	self.control = AwesomeGuildStoreSearchLibrary
	local control = self.control
	control:SetMovable(not saveData.locked)
	control:SetResizeHandleSize(not saveData.locked and 5 or 0)
	control:SetHandler("OnMoveStop", function() self:SavePosition() end)
	local resizing = false
	control:SetHandler("OnResizeStart", function() resizing = true end)
	control:SetHandler("OnUpdate", function() if(resizing) then self:HandleResize() end end)
	control:SetHandler("OnResizeStop", function() self:HandleResize() self:SavePosition() resizing = false end)

	RegisterForEvent(EVENT_OPEN_TRADING_HOUSE, function()
		if(saveData.isActive and TRADING_HOUSE:IsInSearchMode()) then
			self:Show()
		end
	end)

	RegisterForEvent(EVENT_CLOSE_TRADING_HOUSE, function()
		self:Hide()
	end)

	ZO_PreHook(TRADING_HOUSE, "HandleTabSwitch", function(_, tabData)
		local mode = tabData.descriptor
		if(saveData.isActive and mode == ZO_TRADING_HOUSE_MODE_BROWSE) then
			self:Show()
		else
			self:Hide()
		end
	end)

	local parent = TRADING_HOUSE.m_browseItems
	local toggleButton = ToggleButton:New(parent, control:GetName() .. "ToggleButton", "EsoUI/Art/Journal/journal_tabIcon_loreLibrary_%s.dds", 0, 0, 28, 28, L["SEARCH_LIBRARY_TOGGLE_LABEL"])
	toggleButton.control:ClearAnchors()
	toggleButton.control:SetAnchor(TOPRIGHT, parent:GetNamedChild("Header"), TOPLEFT, 225, -2)
	if(saveData.isActive) then
		toggleButton:Press()
	end
	toggleButton.HandlePress = function()
		self:Show()
		saveData.isActive = true
		return true
	end
	toggleButton.HandleRelease = function()
		self:Hide()
		saveData.isActive = false
		return true
	end
	self.toggleButton = toggleButton

	ZO_PreHook(TRADING_HOUSE.m_search, "InternalExecuteSearch", function()
		self:AddHistoryEntry(self:Serialize())
		if(self:IsVisible()) then
			self:Refresh()
		end
	end)

	self.searchList = saveData.searches

	if(saveData.autoClearHistory) then
		self:ClearHistory()
	end

	self.toolTip = AwesomeGuildStore.SavedSearchTooltip:New()
	self:InitializeHistory()
	self:InitializeFavorites()
	self:InitializeEditBox()
	self:InitializeOptions()

	local favoriteCurrentButton = ToggleButton:New(parent, control:GetName() .. "FavoriteCurrentButton", "AwesomeGuildStore/images/favorite_%s.dds", 0, 0, 28, 28, L["SEARCH_LIBRARY_FAVORITE_BUTTON_ADD_TOOLTIP"])
	favoriteCurrentButton.control:ClearAnchors()
	favoriteCurrentButton.control:SetAnchor(LEFT, toggleButton.control, RIGHT, 0, 0)
	self.favoriteCurrentButton = favoriteCurrentButton
	self:UpdateFavoriteButtonState()

	favoriteCurrentButton.HandlePress = function(button, ignore)
		if(not ignore) then
			self:AddFavoriteEntry(saveData.lastState)
			self:RebuildFavorites()
		end
		favoriteCurrentButton:SetTooltipText(L["SEARCH_LIBRARY_FAVORITE_BUTTON_REMOVE_TOOLTIP"])
		return true
	end
	favoriteCurrentButton.HandleRelease = function(button, ignore)
		if(not ignore) then
			self:RemoveFavoriteEntry(saveData.lastState)
			self:RebuildFavorites()
		end
		favoriteCurrentButton:SetTooltipText(L["SEARCH_LIBRARY_FAVORITE_BUTTON_ADD_TOOLTIP"])
		return true
	end

	if(saveData.isActive) then
		self:Show()
	end
end

function SearchLibrary:UpdateFavoriteButtonState()
	local currentEntry = self:GetEntry(self.saveData.lastState, true)
	if(currentEntry and currentEntry.favorite) then
		self.favoriteCurrentButton:Press(true)
		self.favoriteCurrentButton:SetTooltipText(L["SEARCH_LIBRARY_FAVORITE_BUTTON_REMOVE_TOOLTIP"])
	else
		self.favoriteCurrentButton:Release(true)
		self.favoriteCurrentButton:SetTooltipText(L["SEARCH_LIBRARY_FAVORITE_BUTTON_ADD_TOOLTIP"])
	end
end

function SearchLibrary:InitializeOptions()
	local optionsControl = self.control:GetNamedChild("Options")
	optionsControl:SetHandler("OnClicked", function(control)
		ClearMenu()

		AddMenuItem(L["SEARCH_LIBRARY_MENU_OPEN_SETTINGS"], AwesomeGuildStore.OpenSettingsPanel)
		AddMenuItem(L["SEARCH_LIBRARY_MENU_CLEAR_HISTORY"], function()
			self:ClearHistory()
			self:Refresh()
		end)
		AddMenuItem(L["SEARCH_LIBRARY_MENU_CLEAR_FAVORITES"], function()
			self:ClearFavorites()
			self:Refresh()
		end)
		if(self.undo) then
			AddMenuItem(L["SEARCH_LIBRARY_MENU_UNDO_ACTION"], function()
				if(self.undo) then
					self.undo()
					self:Refresh()
				end
			end)
		end
		if(self:IsLocked()) then
			AddMenuItem(L["SEARCH_LIBRARY_MENU_UNLOCK_WINDOW"], function() self:Unlock() end)
		else
			AddMenuItem(L["SEARCH_LIBRARY_MENU_LOCK_WINDOW"], function() self:Lock() end)
			AddMenuItem(L["SEARCH_LIBRARY_MENU_RESET_WINDOW"], function() self:ResetPosition() end)
		end
		AddMenuItem(L["SEARCH_LIBRARY_MENU_CLOSE_WINDOW"], function() self.toggleButton:Release() end)

		ShowMenu(optionsControl)
	end)
	self.optionsControl = optionsControl
end

function SearchLibrary:InitializeEditBox()
	self.editControl = self.control:GetNamedChild("LabelEdit")
	local editBox = self.editControl:GetNamedChild("Box")
	editBox:SetHandler("OnFocusLost", function() self.hideEditBoxHandle = zo_callLater(function() self:HideEditBox() end, 100) end)
	editBox:SetHandler("OnEnter", function() self:HideEditBox() self:SaveEditBoxChanges() end)
	editBox:SetHandler("OnEscape", function() self:HideEditBox() end)
end

function SearchLibrary:ShowEditBox(rowControl, entry)
	local editControl = self.editControl
	local editBox = editControl:GetNamedChild("Box")
	if(editBox.rowControl) then
		self:HideEditBox()
	end
	local nameControl = rowControl:GetNamedChild("Name")

	editControl:SetAnchor(LEFT, rowControl, LEFT, 0, 0)
	nameControl:SetHidden(true)
	editControl:SetHidden(false)

	editBox.rowControl = rowControl
	editBox.entry = entry
	editBox:SetText(entry.label)
	editBox:TakeFocus()

	ZO_ScrollList_SetLockScrolling(self.historyControl, true)
	ZO_ScrollList_SetLockScrolling(self.favoritesControl, true)
end

function SearchLibrary:HideEditBox()
	if(self.hideEditBoxHandle) then
		local name = "CallLaterFunction"..self.hideEditBoxHandle
		EVENT_MANAGER:UnregisterForUpdate(name)
		self.hideEditBoxHandle = nil
	end

	local editControl = self.editControl
	local editBox = editControl:GetNamedChild("Box")

	if(not editBox.rowControl) then return end
	local nameControl = editBox.rowControl:GetNamedChild("Name")
	editBox.rowControl.EditButton:Release(true)
	editBox.rowControl = nil

	editControl:SetHidden(true)
	nameControl:SetHidden(false)
	editControl:ClearAnchors()

	ZO_ScrollList_SetLockScrolling(self.historyControl, false)
	ZO_ScrollList_SetLockScrolling(self.favoritesControl, false)
end

function SearchLibrary:SaveEditBoxChanges()
	local editControl = self.editControl
	local editBox = editControl:GetNamedChild("Box")
	local entry = editBox.entry
	self:UpdateEntryLabel(entry.state, editBox:GetText())
	if(entry.favorite) then self:RebuildFavorites() end
	if(entry.history) then self:RebuildHistory() end
end

function SearchLibrary:RegisterFilter(filter)
	if(not filter or not filter.type or self.filter[filter.type]) then d("AwesomeGuildStore Error: cannot register filter with search library") return end
	self.filter[filter.type] = filter
	CALLBACK_MANAGER:RegisterCallback(filter.callbackName, function(filter)
		self.currentState[filter.type] = filter:Serialize()
		self:SaveCurrentState()
	end)
end

function SearchLibrary:Serialize()
	local state = self.currentState
	local filter = self.filter
	for i = 1, 5 do
		state[i] = filter[i] and filter[i]:Serialize() or "-"
	end

	return SAVE_TEMPLATE:format(SAVE_VERSION, state[1], state[2], state[3], state[4], state[5])
end

function SearchLibrary:Deserialize(state)
	local version, categoryState, priceState, levelState, qualityState, nameState = zo_strsplit(":", state)
	if(tonumber(version) == SAVE_VERSION) then
		local state = {categoryState, priceState, levelState, qualityState, nameState}
		local filter = self.filter
		for i = 1, 5 do
			if(filter[i] and state[i] ~= "-") then
				filter[i]:Deserialize(state[i])
			end
		end

		TRADING_HOUSE.m_searchAllowed = true
		TRADING_HOUSE:OnSearchCooldownUpdate(GetTradingHouseCooldownRemaining())
	end
end

function SearchLibrary:SaveCurrentState()
	local state = self.currentState
	self.saveData.lastState = SAVE_TEMPLATE:format(SAVE_VERSION, state[1] or "-", state[2] or "-", state[3] or "-", state[4] or "-", state[5] or "-")
	self:UpdateFavoriteButtonState()
end

local function GetRowButton(rowControl, template)
	local button = rowControl[template.name]
	if(not button) then
		button = ToggleButton:New(rowControl, rowControl:GetName() .. template.name, template.texture, 0, 0, template.size, template.size)
		button.control:ClearAnchors()
		button.control:SetAnchor(RIGHT, rowControl, RIGHT, template.offsetX, template.offsetY)
		button.animation = ANIMATION_MANAGER:CreateTimelineFromVirtual("ShowOnMouseOverLabelAnimation", button.control)
		rowControl[template.name] = button
	end
	return button
end

local function InitializeBaseRow(self, rowControl, entry, fadeFavorite)
	local nameControl = rowControl:GetNamedChild("Name")
	nameControl:SetText(entry.label)

	local saveButton = GetRowButton(rowControl, SAVE_BUTTON_TEMPLATE)
	saveButton.control:SetAlpha((entry.favorite and not fadeFavorite) and 1 or 0)
	saveButton:SetTooltipText(entry.favorite and L["SEARCH_LIBRARY_FAVORITE_BUTTON_REMOVE_TOOLTIP"] or L["SEARCH_LIBRARY_FAVORITE_BUTTON_ADD_TOOLTIP"])

	local editButton = GetRowButton(rowControl, EDIT_BUTTON_TEMPLATE)
	editButton.control:SetAlpha(0)
	editButton:SetTooltipText(L["SEARCH_LIBRARY_EDIT_LABEL_BUTTON_TOOLTIP"])

	local highlight = rowControl:GetNamedChild("Highlight")
	if not highlight.animation then
		highlight.animation = ANIMATION_MANAGER:CreateTimelineFromVirtual("ShowOnMouseOverLabelAnimation", highlight)
	end

	local function FadeIn()
		highlight.animation:PlayForward()
		editButton.animation:PlayForward()
		if(not entry.favorite or fadeFavorite) then
			saveButton.animation:PlayForward()
		end
		if(self.saveData.showTooltips) then
			self.toolTip:Show(rowControl, entry)
		end
	end

	local function FadeOut()
		highlight.animation:PlayBackward()
		editButton.animation:PlayBackward()
		if(not entry.favorite or fadeFavorite) then
			saveButton.animation:PlayBackward()
		end
		self.toolTip:Hide()
	end

	rowControl:SetHandler("OnMouseEnter", FadeIn)
	editButton.control:SetHandler("OnMouseEnter", function() rowControl:GetHandler("OnMouseEnter")() editButton.control.OnMouseEnter() end)
	saveButton.control:SetHandler("OnMouseEnter", function() rowControl:GetHandler("OnMouseEnter")() saveButton.control.OnMouseEnter() end)

	rowControl:SetHandler("OnMouseExit", FadeOut)
	editButton.control:SetHandler("OnMouseExit", function() rowControl:GetHandler("OnMouseExit")() editButton.control.OnMouseExit() end)
	saveButton.control:SetHandler("OnMouseExit", function() rowControl:GetHandler("OnMouseExit")() saveButton.control.OnMouseExit() end)

	rowControl:SetHandler("OnMouseUp", function(control, button, isInside)
		if(button == 1 and isInside) then
			self:Deserialize(entry.state)
			PlaySound("Click")
		end
	end)

	if(entry.favorite) then
		saveButton:Press()
	end

	editButton.HandlePress = function()
		self:ShowEditBox(rowControl, entry)
		return true
	end

	editButton.HandleRelease = function(button, fromEditBox)
		if(not fromEditBox) then
			self:HideEditBox()
			self:SaveEditBoxChanges()
		end
		return true
	end
end

local function ResetButton(button)
	button.HandlePress = nil
	button.HandleRelease = nil
	button:Release()
	button.control:SetHidden(false)
	button.animation:PlayFromEnd(button.animation:GetDuration())
	button.control:SetHandler("OnMouseEnter", button.control.OnMouseEnter)
	button.control:SetHandler("OnMouseExit", button.control.OnMouseExit)
end

local function DestroyBaseRow(rowControl)
	local highlight = rowControl:GetNamedChild("Highlight")
	highlight.animation:PlayFromEnd(highlight.animation:GetDuration())
	ResetButton(rowControl.SaveButton)
	ResetButton(rowControl.EditButton)
	ZO_ObjectPool_DefaultResetControl(rowControl)
end

function SearchLibrary:InitializeHistory()
	self.control:GetNamedChild("HistoryLabel"):SetText(L["SEARCH_LIBRARY_HISTORY_LABEL"])
	local historyControl = self.control:GetNamedChild("History")
	self.historyControl = historyControl
	self.historyDirty = true

	local function InitializeHistoryRow(rowControl, entry)
		InitializeBaseRow(self, rowControl, entry, false)

		local deleteButton = GetRowButton(rowControl, DELETE_BUTTON_TEMPLATE)
		deleteButton.control:SetAlpha(0)
		deleteButton:SetTooltipText(L["SEARCH_LIBRARY_DELETE_LABEL_BUTTON_TOOLTIP"])

		ZO_PreHookHandler(rowControl, "OnMouseEnter", function()
			deleteButton.animation:PlayForward()
		end)
		ZO_PreHookHandler(rowControl, "OnMouseExit", function()
			deleteButton.animation:PlayBackward()
		end)
		deleteButton.control:SetHandler("OnMouseEnter", function() rowControl:GetHandler("OnMouseEnter")() deleteButton.control.OnMouseEnter() deleteButton:Release(true) end)
		deleteButton.control:SetHandler("OnMouseExit", function() rowControl:GetHandler("OnMouseExit")() deleteButton.control.OnMouseExit() end)
		deleteButton.HandlePress = function(button, fromGroup)
			self:RemoveHistoryEntry(entry.state)
			self:Refresh()
			return true
		end
		deleteButton.HandleRelease = function(button, fromGroup)
			return fromGroup
		end

		rowControl.SaveButton.HandlePress = function()
			self:AddFavoriteEntry(entry.state)
			self:RebuildFavorites()
			entry.favorite = true
			rowControl.SaveButton:SetTooltipText(L["SEARCH_LIBRARY_FAVORITE_BUTTON_REMOVE_TOOLTIP"])
			return true
		end

		rowControl.SaveButton.HandleRelease = function()
			self:RemoveFavoriteEntry(entry.state)
			self:RebuildFavorites()
			entry.favorite = false
			rowControl.SaveButton:SetTooltipText(L["SEARCH_LIBRARY_FAVORITE_BUTTON_ADD_TOOLTIP"])
			return true
		end
	end

	local function DestroyHistoryRow(rowControl)
		ResetButton(rowControl.DeleteButton)
		DestroyBaseRow(rowControl)
	end

	ZO_ScrollList_Initialize(historyControl)
	ZO_ScrollList_AddDataType(historyControl, SEARCH_DATA_TYPE, "AwesomeGuildStoreSearchLibraryRowTemplate", 24, InitializeHistoryRow, nil, nil, DestroyHistoryRow)
	ZO_ScrollList_AddResizeOnScreenResize(historyControl)
end

function SearchLibrary:InitializeFavorites()
	self.control:GetNamedChild("FavoritesLabel"):SetText(L["SEARCH_LIBRARY_FAVORITES_LABEL"])
	local favoritesControl = self.control:GetNamedChild("Favorites")
	self.favoritesControl = favoritesControl
	self.favoritesDirty = true

	local function InitializeFavoritesRow(rowControl, entry)
		InitializeBaseRow(self, rowControl, entry, true)

		rowControl.SaveButton:Press()

		rowControl.SaveButton.HandleRelease = function()
			self:RemoveFavoriteEntry(entry.state)
			zo_callLater(function()
				self:Refresh()
			end, 50)
			return true
		end
	end

	local function DestroyFavoritesRow(rowControl)
		DestroyBaseRow(rowControl)
	end

	ZO_ScrollList_Initialize(favoritesControl)
	ZO_ScrollList_AddDataType(favoritesControl, SEARCH_DATA_TYPE, "AwesomeGuildStoreSearchLibraryRowTemplate", 24, InitializeFavoritesRow, nil, nil, DestroyFavoritesRow)
	ZO_ScrollList_AddResizeOnScreenResize(favoritesControl)
end

local function GetLabelFromState(state)
	local _, categoryState, _, _, _, nameFilter = zo_strsplit(":", state)
	local label = "category filter disabled"

	if(categoryState ~= "-") then
		local category, subcategory = zo_strsplit(";", categoryState)
		category = FILTER_PRESETS[tonumber(category)]
		label = category.label

		if(subcategory) then
			subcategory = category.subcategories[tonumber(subcategory)]
			label = label .. " > " .. subcategory.label
		end
	end

	if(nameFilter and nameFilter ~= "") then
		label = label .. ' > "' .. nameFilter .. '"'
	end

	return label
end

function SearchLibrary:GetEntry(state, skipCreate)
	local entry = self.searchList[state]
	if(not entry and not skipCreate) then
		entry = {
			state = state,
			label = GetLabelFromState(state),
			lastSearchTime = 0,
			searchCount = 0,
			history = false,
			favorite = false
		}
		self.searchList[state] = entry
	end
	return entry
end

function SearchLibrary:CleanUp()
	for state, entry in pairs(self.searchList) do
		if(not entry.history and not entry.favorite) then
			self.searchList[state] = nil
		end
	end
end

function SearchLibrary:AddHistoryEntry(state)
	local entry = self:GetEntry(state)
	entry.searchCount = entry.searchCount + 1
	entry.lastSearchTime = GetTimeStamp()
	entry.history = true
	self.historyDirty = true
end

function SearchLibrary:RemoveHistoryEntry(state)
	local entry = self:GetEntry(state, true)
	if(entry) then
		entry.history = false
		self.historyDirty = true
		self.undo = function()
			entry.history = true
			self.searchList[entry.state] = entry
			self.historyDirty = true
			self.undo = nil
		end
	end
end

function SearchLibrary:ClearHistory()
	local removedEntries = {}
	for state, entry in pairs(self.searchList) do
		if(entry.history) then
			removedEntries[#removedEntries + 1] = entry
			entry.history = false
			self.historyDirty = true
		end
	end

	if(#removedEntries > 0) then
		self.undo = function()
			for i = 1, #removedEntries do
				local entry = removedEntries[i]
				entry.history = true
				self.searchList[entry.state] = entry
			end
			self.historyDirty = true
			self.undo = nil
		end
	end
end

function SearchLibrary:AddFavoriteEntry(state)
	local entry = self:GetEntry(state)
	entry.favorite = true
	if(entry.history) then
		self.historyDirty = true
	end
	self.favoritesDirty = true
end

function SearchLibrary:RemoveFavoriteEntry(state)
	local entry = self:GetEntry(state, true)
	if(entry) then
		entry.favorite = false
		if(entry.history) then
			self.historyDirty = true
		end
		self.favoritesDirty = true

		self.undo = function()
			entry.favorite = true
			self.searchList[entry.state] = entry
			if(entry.history) then
				self.historyDirty = true
			end
			self.favoritesDirty = true
			self.undo = nil
		end
	end
end

function SearchLibrary:ClearFavorites()
	local removedEntries = {}
	for state, entry in pairs(self.searchList) do
		if(entry.favorite) then
			removedEntries[#removedEntries + 1] = entry
			entry.favorite = false
			if(entry.history) then
				self.historyDirty = true
			end
			self.favoritesDirty = true
		end
	end

	if(#removedEntries > 0) then
		self.undo = function()
			for i = 1, #removedEntries do
				local entry = removedEntries[i]
				entry.favorite = true
				if(entry.history) then
					self.historyDirty = true
				end
				self.searchList[entry.state] = entry
			end
			self.favoritesDirty = true
			self.undo = nil
		end
	end
end

function SearchLibrary:UpdateEntryLabel(state, label)
	local entry = self:GetEntry(state)
	if(entry) then
		entry.label = label
		if(entry.history) then
			self.historyDirty = true
		end
		if(entry.favorite) then
			self.favoritesDirty = true
		end
	end
end

local function SortByTimeDesc(entryA, entryB)
	return entryA.data.lastSearchTime > entryB.data.lastSearchTime
end

local function SortBySearchCountDesc(entryA, entryB)
	return entryA.data.searchCount > entryB.data.searchCount
end

local function FilterHistoryEntires(entry)
	return entry.history
end

local function FilterFavoriteEntires(entry)
	return entry.favorite
end

local function RebuildScrollList(listControl, dataList, sortFunction, filterFunction)
	local scrollData = ZO_ScrollList_GetDataList(listControl)
	ZO_ScrollList_Clear(listControl)
	ZO_ScrollList_ResetToTop(listControl)

	for _, entry in pairs(dataList) do
		if(filterFunction(entry)) then
			scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(SEARCH_DATA_TYPE, ZO_ShallowTableCopy(entry)) -- have to copy this, or it will mess with our save data, fill the disk and crash eso
		end
	end

	table.sort(scrollData, sortFunction)

	ZO_ScrollList_Commit(listControl)

	return scrollData
end

function SearchLibrary:RebuildHistory()
	if(not self.historyDirty) then return end
	local scrollData = RebuildScrollList(self.historyControl, self.searchList, SortByTimeDesc, FilterHistoryEntires)

	for i = HISTORY_LENGTH + 1, #scrollData do
		local entry = self:GetEntry(scrollData[i].data.state, true)
		if(entry) then
			entry.history = false
		end
	end

	self.historyDirty = false
end

function SearchLibrary:RebuildFavorites()
	if(not self.favoritesDirty) then return end
	RebuildScrollList(self.favoritesControl, self.searchList, SortBySearchCountDesc, FilterFavoriteEntires)
	self:UpdateFavoriteButtonState()
	self.favoritesDirty = false
end

function SearchLibrary:Refresh()
	self:RebuildHistory()
	self:RebuildFavorites()
	self:CleanUp()
end

function SearchLibrary:LoadPosition()
	local control, saveData = self.control, self.saveData
	control:ClearAnchors()
	control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, saveData.x, saveData.y)
	control:SetDimensions(saveData.width, saveData.height)
	self:HandleResize()
end

function SearchLibrary:SavePosition()
	local control, saveData = self.control, self.saveData
	saveData.x, saveData.y = control:GetScreenRect()
	saveData.width, saveData.height = control:GetDimensions()
end

function SearchLibrary:ResetPosition()
	local control, saveData, defaultData = self.control, self.saveData, AwesomeGuildStore.defaultData.searchLibrary
	saveData.x, saveData.y = defaultData.x, defaultData.y
	saveData.width, saveData.height = defaultData.width, defaultData.height
	self:LoadPosition()
end

local BORDER_WIDTH_HORIZONTAL = 25
local BORDER_WIDTH_VERTICAL = 10
local LABEL_HEIGHT = 23
local LABEL_MARGIN = 7
local EDIT_CONTROLS_WIDTH = 90

local function SetScrollListDimensions(control, width, height)
	control:SetWidth(width)
	ZO_ScrollList_SetHeight(control, height)
	ZO_ScrollList_Commit(control)
end

function SearchLibrary:HandleResize()
	local control = self.control
	local width, height = control:GetDimensions()
	local columnWidth = (width - BORDER_WIDTH_HORIZONTAL * 3) / 2
	local columnHeight = height - (BORDER_WIDTH_VERTICAL * 2 + LABEL_HEIGHT + LABEL_MARGIN)

	control:GetNamedChild("HistoryLabel"):SetWidth(columnWidth)
	control:GetNamedChild("FavoritesLabel"):SetWidth(columnWidth)
	control:GetNamedChild("LabelEdit"):SetWidth(columnWidth - EDIT_CONTROLS_WIDTH)
	SetScrollListDimensions(self.historyControl, columnWidth, columnHeight)
	SetScrollListDimensions(self.favoritesControl, columnWidth, columnHeight)
end

function SearchLibrary:Show()
	self:LoadPosition()
	self:Refresh()
	self.control:SetHidden(false)
end

function SearchLibrary:Hide()
	self.control:SetHidden(true)
end

function SearchLibrary:IsVisible()
	return not (self.control:IsHidden())
end

function SearchLibrary:Toggle()
	if(self:IsVisible()) then
		self:Hide()
	else
		self:Show()
	end
end

function SearchLibrary:Lock()
	self.saveData.locked = true
	self.control:SetMovable(false)
	self.control:SetResizeHandleSize(0)
end

function SearchLibrary:Unlock()
	self.saveData.locked = false
	self.control:SetMovable(true)
	self.control:SetResizeHandleSize(5)
end

function SearchLibrary:IsLocked()
	return self.saveData.locked
end
