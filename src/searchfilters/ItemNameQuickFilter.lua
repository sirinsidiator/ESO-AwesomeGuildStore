local L = AwesomeGuildStore.Localization

local RESET_BUTTON_SIZE = 18
local RESET_BUTTON_TEXTURE = "EsoUI/Art/Buttons/decline_%s.dds"
local ITEM_NAME_FILTER_DATA_TYPE = 1

local ItemNameQuickFilter = ZO_Object:Subclass()
AwesomeGuildStore.ItemNameQuickFilter = ItemNameQuickFilter

function ItemNameQuickFilter:New(parent, name, x, y)
	local filter = ZO_Object.New(self)
	filter:Initialize(parent, name, x, y)
	return filter
end

function ItemNameQuickFilter:Initialize(parent, name, x, y)
	self.callbackName = name .. "Changed"
	self.type = 5

	local input = CreateControlFromVirtual(name, parent, "AwesomeGuildStoreNameFilterTemplate")
	input:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)

	local resetButton = AwesomeGuildStore.SimpleIconButton:New(name .. "ResetButton", RESET_BUTTON_TEXTURE, RESET_BUTTON_SIZE, L["ITEM_NAME_QUICK_FILTER_RESET"])
	resetButton:SetAnchor(TOPRIGHT, input, TOPRIGHT, -5, 5)
	resetButton:SetHidden(true)
	resetButton.OnClick = function(_, mouseButton, ctrl, alt, shift)
		if(mouseButton == 1) then
			self:Reset()
		end
	end

	local inputBox = input:GetNamedChild("Box")
	ZO_EditDefaultText_Initialize(inputBox, L["ITEM_NAME_QUICK_FILTER_TEXT"])
	inputBox:SetHandler("OnTextChanged", function(control)
		self:HandleChange()
		ZO_EditDefaultText_OnTextChanged(inputBox)
		resetButton:SetHidden(inputBox:GetText() == "")
		TRADING_HOUSE:RebuildSearchResultsPage()
	end)
	self.inputBox = inputBox

	self:InitializeFilterFunction()
end

function ItemNameQuickFilter:InitializeFilterFunction()
	ZO_PreHook(TRADING_HOUSE, "ClearSearchResults", function(self) self.m_numItemsOnPage = 0 end)

	local OriginalRebuildSearchResultsPage = TRADING_HOUSE.RebuildSearchResultsPage
	local OriginalGetTradingHouseSearchResultItemInfo = GetTradingHouseSearchResultItemInfo

	local nameFilter = ZO_StringSearch:New()
	nameFilter:AddProcessor(ITEM_NAME_FILTER_DATA_TYPE, function(stringSearch, data, searchTerm, cache)
		searchTerm = searchTerm:lower()
		if(zo_plainstrfind(data.name:lower(), searchTerm) or zo_plainstrfind(data.setName:lower(), searchTerm) or (data.isSetItem and zo_plainstrfind("set", searchTerm))) then
			return true
		end
	end)

	local inputBox = self.inputBox
	local data = { name = "", setName = "", isSetItem = false, type = ITEM_NAME_FILTER_DATA_TYPE }
	local searchTerm, itemCount, filteredItemCount

	local FakeGetTradingHouseSearchResultItemInfo = function(index)
		local icon, name, quality, stackCount, sellerName, timeRemaining, purchasePrice = OriginalGetTradingHouseSearchResultItemInfo(index)
		if(name ~= "" and stackCount > 0) then
			itemCount = itemCount + 1
			data.name = name

			local itemLink = GetTradingHouseSearchResultItemLink(index, LINK_STYLE_DEFAULT)
			local isSetItem, setName = GetItemLinkSetInfo(itemLink)
			data.setName = setName
			data.isSetItem = isSetItem

			if(nameFilter:IsMatch(searchTerm, data)) then
				filteredItemCount = filteredItemCount + 1
				return icon, name, quality, stackCount, sellerName, timeRemaining, purchasePrice
			end
		end
		return nil, "", nil, 0
	end
	TRADING_HOUSE.RebuildSearchResultsPage = function(self)
		searchTerm = inputBox:GetText()

		if(searchTerm ~= "") then
			itemCount, filteredItemCount = 0, 0
			GetTradingHouseSearchResultItemInfo = FakeGetTradingHouseSearchResultItemInfo
		end

		OriginalRebuildSearchResultsPage(self)

		if(searchTerm ~= "") then
			GetTradingHouseSearchResultItemInfo = OriginalGetTradingHouseSearchResultItemInfo
			self.m_resultCount:SetText(zo_strformat(L["ITEM_NAME_QUICK_FILTER_ITEMCOUNT_TEMPLATE"], itemCount, filteredItemCount))

			local shouldHide = (filteredItemCount ~= 0 or self.m_search:HasPreviousPage() or self.m_search:HasNextPage())
			self.m_noItemsLabel:SetHidden(shouldHide)
		end
	end
end

function ItemNameQuickFilter:HandleChange()
	if(not self.fireChangeCallback) then
		self.fireChangeCallback = zo_callLater(function()
			self.fireChangeCallback = nil
			CALLBACK_MANAGER:FireCallbacks(self.callbackName, self)
		end, 100)
	end
end

function ItemNameQuickFilter:Reset()
	self.inputBox:SetText("")
end

function ItemNameQuickFilter:Serialize()
	return self.inputBox:GetText()
end

function ItemNameQuickFilter:Deserialize(searchterm)
	self.inputBox:SetText(searchterm)
end
