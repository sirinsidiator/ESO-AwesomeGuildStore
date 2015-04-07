local L = AwesomeGuildStore.Localization
local FilterBase = AwesomeGuildStore.FilterBase

local TextFilter = FilterBase:Subclass()
AwesomeGuildStore.TextFilter = TextFilter

local TEXT_FILTER_DATA_TYPE = 1
local LINE_SPACING = 4
local MARGIN = 20
local TEXT_FITLER_TYPE_ID = 5

function TextFilter:New(name, tradingHouseWrapper, ...)
	return FilterBase.New(self, TEXT_FITLER_TYPE_ID, name, tradingHouseWrapper, ...)
end

function TextFilter:Initialize(name, tradingHouseWrapper)
	self:InitializeControls(name)
	self:InitializeHandlers(tradingHouseWrapper)
end

function TextFilter:InitializeControls(name)
	local container = self.container

	local label = container:CreateControl(name .. "Label", CT_LABEL)
	label:SetFont("ZoFontWinH4")
	label:SetText(L["TEXT_FILTER_TITLE"])
	label:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
	label:SetAnchor(TOPRIGHT, container, TOPRIGHT, 0, 0)

	local input = CreateControlFromVirtual(name .. "Input", container, "AwesomeGuildStoreNameFilterTemplate")
	input:SetAnchor(TOPLEFT, label, BOTTOMLEFT, 0, LINE_SPACING)
	input:SetAnchor(TOPRIGHT, label, BOTTOMRIGHT, 0, LINE_SPACING)
	local inputBox = input:GetNamedChild("Box")
	ZO_EditDefaultText_Initialize(inputBox, L["TEXT_FILTER_TEXT"])
	inputBox:SetMaxInputChars(250)
	self.inputBox = inputBox

	container:SetHeight(label:GetHeight() + LINE_SPACING + input:GetHeight() + MARGIN)

	local tooltipText = L["RESET_FILTER_LABEL_TEMPLATE"]:format(label:GetText():gsub(":", ""))
	self.resetButton:SetTooltipText(tooltipText)
end

function TextFilter:InitializeHandlers(tradingHouseWrapper)
	local tradingHouse = tradingHouseWrapper.tradingHouse
	local inputBox = self.inputBox
	inputBox:SetHandler("OnTextChanged", function(control)
		ZO_EditDefaultText_OnTextChanged(inputBox)
		self:HandleChange()
		tradingHouse:RebuildSearchResultsPage()
	end)

	local nameFilter = ZO_StringSearch:New()
	nameFilter:AddProcessor(TEXT_FILTER_DATA_TYPE, function(stringSearch, data, searchTerm, cache)
		searchTerm = searchTerm:lower()
		if(zo_plainstrfind(data.name:lower(), searchTerm) or zo_plainstrfind(data.setName:lower(), searchTerm) or (data.isSetItem and zo_plainstrfind("set", searchTerm))) then
			return true
		end
	end)

	local data = { name = "", setName = "", isSetItem = false, itemLinkData = "", type = TEXT_FILTER_DATA_TYPE }
	local itemCount, filteredItemCount, isMatch

	local OriginalGetTradingHouseSearchResultItemInfo = GetTradingHouseSearchResultItemInfo
	local FakeGetTradingHouseSearchResultItemInfo = function(index)
		local icon, name, quality, stackCount, sellerName, timeRemaining, purchasePrice = OriginalGetTradingHouseSearchResultItemInfo(index)
		if(name ~= "" and stackCount > 0) then
			itemCount = itemCount + 1
			data.name = name

			local itemLink = GetTradingHouseSearchResultItemLink(index, LINK_STYLE_BRACKETS)
			local isSetItem, setName = GetItemLinkSetInfo(itemLink)
			local _, itemLinkData = itemLink:match("|H(.-):(.-)|h(.-)|h")
			data.setName = setName
			data.isSetItem = isSetItem
			data.itemLinkData = itemLinkData

			if(isMatch(data)) then
				filteredItemCount = filteredItemCount + 1
				return icon, name, quality, stackCount, sellerName, timeRemaining, purchasePrice
			end
		end
		return nil, "", nil, 0
	end

	tradingHouseWrapper:Wrap("RebuildSearchResultsPage", function(originalRebuildSearchResultsPage, self, ...)
		local searchTerm = inputBox:GetText()

		if(searchTerm ~= "") then
			local terms = {zo_strsplit("+", searchTerm)}
			for i = 1, #terms do
				local term = terms[i]
				local _, itemLinkData = term:match("|H(.-):(.-)|h(.-)|h")
				if(itemLinkData and itemLinkData ~= "") then -- prepare itemLinks beforehand for better performance
					terms[i] = itemLinkData
				end
			end
			isMatch = function(data)
				for i = 1, #terms do
					local term = terms[i]
					if(term == data.itemLinkData or nameFilter:IsMatch(term, data)) then return true end
				end
			end
			itemCount, filteredItemCount = 0, 0
			GetTradingHouseSearchResultItemInfo = FakeGetTradingHouseSearchResultItemInfo
		end

		originalRebuildSearchResultsPage(self, ...)

		if(searchTerm ~= "") then
			GetTradingHouseSearchResultItemInfo = OriginalGetTradingHouseSearchResultItemInfo
			self.m_resultCount:SetText(zo_strformat(L["TEXT_FILTER_ITEMCOUNT_TEMPLATE"], itemCount, filteredItemCount))

			local shouldHide = (filteredItemCount ~= 0 or self.m_search:HasPreviousPage() or self.m_search:HasNextPage())
			self.m_noItemsLabel:SetHidden(shouldHide)
		end
	end)
end

function TextFilter:Reset()
	self.inputBox:SetText("")
end

function TextFilter:IsDefault()
	local inputBox = self.inputBox
	return (inputBox:GetText() == "")
end

function TextFilter:Serialize()
	return self.inputBox:GetText()
end

function TextFilter:Deserialize(searchterm)
	if(not searchterm) then searchterm = "" end
	self.inputBox:SetText(searchterm)
end

function TextFilter:GetTooltipText(state)
	if(state and state ~= "") then
		return {{label = L["TEXT_FILTER_TITLE"]:sub(0, -2), text = state}}
	end
	return {}
end
