local L = AwesomeGuildStore.Localization
local RegisterForEvent = AwesomeGuildStore.RegisterForEvent
local ToggleButton = AwesomeGuildStore.ToggleButton
local FILTER_PRESETS = AwesomeGuildStore.FILTER_PRESETS
local SUBFILTER_PRESETS = AwesomeGuildStore.SUBFILTER_PRESETS

local BROWSE_ITEMS_MODE = "tradingHouseBrowse"
local SEARCH_DATA_TYPE = 1
local HISTORY_LENGTH = 50
local SAVE_VERSION = 1
local SAVE_TEMPLATE = "%d:%s:%s:%s:%s:%s"

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
	control:SetMovable(true)
	control:SetHandler("OnMoveStop", function() self:SavePosition() end)

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
		if(saveData.isActive and mode == BROWSE_ITEMS_MODE) then
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

	ZO_PreHook(TRADING_HOUSE.m_search, "InternalExecuteSearch", function()
		self:AddHistoryEntry(self:Serialize())
		if(self:IsVisible()) then
			self:Refresh()
		end
	end)

	self.searchList = saveData.searches
	self:InitializeHistory()
	self:InitializeFavorites()

	if(saveData.isActive) then
		self:Show()
	end
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
			if(filter[i] and state[i] ~= "-") then filter[i]:Deserialize(state[i]) end
		end
	end
end
--|H1:book:1053:shoplink:1:4;5;15,8:1;199:0;26;29:1;5:Odra|h|h

function SearchLibrary:SaveCurrentState()
	local state = self.currentState
	self.saveData.lastState = SAVE_TEMPLATE:format(SAVE_VERSION, state[1], state[2], state[3], state[4], state[5])
end

local function InitializeBaseRow(self, rowControl, entry, fadeFavorite)
	local nameControl = GetControl(rowControl, "Name")
	nameControl:SetText(entry.label)

	local saveButton = rowControl.saveButton
	if(not saveButton) then
		saveButton = ToggleButton:New(rowControl, rowControl:GetName() .. "SaveButton", "AwesomeGuildStore/images/favorite_%s.dds", 0, 0, 24, 24)
		saveButton.control:ClearAnchors()
		saveButton.control:SetAnchor(RIGHT, rowControl, RIGHT, 0, 0)
		saveButton.animation = ANIMATION_MANAGER:CreateTimelineFromVirtual("ShowOnMouseOverLabelAnimation", saveButton.control)
		rowControl.saveButton = saveButton
	end
	saveButton.control:SetAlpha((entry.favorite and not fadeFavorite) and 1 or 0)
	saveButton:SetTooltipText(entry.favorite and L["SEARCH_LIBRARY_FAVORITE_BUTTON_REMOVE_TOOLTIP"] or L["SEARCH_LIBRARY_FAVORITE_BUTTON_ADD_TOOLTIP"])

	local highlight = rowControl:GetNamedChild("Highlight")
	if not highlight.animation then
		highlight.animation = ANIMATION_MANAGER:CreateTimelineFromVirtual("ShowOnMouseOverLabelAnimation", highlight)
	end

	local function FadeIn()
		highlight.animation:PlayForward()
		if(not entry.favorite or fadeFavorite) then
			saveButton.animation:PlayForward()
		end
	end

	local function FadeOut()
		highlight.animation:PlayBackward()
		if(not entry.favorite or fadeFavorite) then
			saveButton.animation:PlayBackward()
		end
	end

	rowControl:SetHandler("OnMouseEnter", FadeIn)
	saveButton.control:SetHandler("OnMouseEnter", function() FadeIn() saveButton.control.OnMouseEnter() end)

	rowControl:SetHandler("OnMouseExit", FadeOut)
	saveButton.control:SetHandler("OnMouseExit", function() FadeOut() saveButton.control.OnMouseExit() end)

	rowControl:SetHandler("OnMouseUp", function(control, button, isInside)
		if(button == 1 and isInside) then
			self:Deserialize(entry.state)
			PlaySound("Click")
		end
	end)

	if(entry.favorite) then
		rowControl.saveButton:Press()
	end
end

local function DestroyBaseRow(rowControl)
	local highlight = rowControl:GetNamedChild("Highlight")
	highlight.animation:PlayFromEnd(highlight.animation:GetDuration())

	local saveButton = rowControl.saveButton
	saveButton.HandlePress = nil
	saveButton.HandleRelease = nil
	saveButton:Release()
	saveButton.control:SetHidden(false)
	saveButton.animation:PlayFromEnd(saveButton.animation:GetDuration())
	ZO_ObjectPool_DefaultResetControl(rowControl)
end

function SearchLibrary:InitializeHistory()
	self.control:GetNamedChild("HistoryLabel"):SetText(L["SEARCH_LIBRARY_HISTORY_LABEL"])
	local historyControl = self.control:GetNamedChild("History")
	self.historyControl = historyControl
	self.historyDirty = true

	local function InitializeHistoryRow(rowControl, entry)
		InitializeBaseRow(self, rowControl, entry, false)

		rowControl.saveButton.HandlePress = function()
			self:AddFavoriteEntry(entry.state)
			self:RebuildFavorites()
			entry.favorite = true
			rowControl.saveButton:SetTooltipText(L["SEARCH_LIBRARY_FAVORITE_BUTTON_REMOVE_TOOLTIP"])
			return true
		end

		rowControl.saveButton.HandleRelease = function()
			self:RemoveFavoriteEntry(entry.state)
			self:RebuildFavorites()
			entry.favorite = false
			rowControl.saveButton:SetTooltipText(L["SEARCH_LIBRARY_FAVORITE_BUTTON_ADD_TOOLTIP"])
			return true
		end
	end

	local function DestroyHistoryRow(rowControl)
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

		rowControl.saveButton:Press()

		rowControl.saveButton.HandleRelease = function()
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

	for i = HISTORY_LENGTH, #scrollData do
		self.SearchList[scrollData[i].state].history = false
		scrollData[i] = nil
	end
	self.historyDirty = false
end

function SearchLibrary:RebuildFavorites()
	if(not self.favoritesDirty) then return end
	RebuildScrollList(self.favoritesControl, self.searchList, SortBySearchCountDesc, FilterFavoriteEntires)
	self.favoritesDirty = false
end

function SearchLibrary:Refresh()
	self:RebuildHistory()
	self:RebuildFavorites()
	self:CleanUp()
end

function SearchLibrary:LoadPosition()
	self.control:ClearAnchors()
	self.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.saveData.x, self.saveData.y)
end

function SearchLibrary:SavePosition()
	self.saveData.x, self.saveData.y = self.control:GetScreenRect()
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
