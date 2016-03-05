local L = AwesomeGuildStore.Localization
local FilterBase = AwesomeGuildStore.FilterBase

local TextFilter = FilterBase:Subclass()
AwesomeGuildStore.TextFilter = TextFilter

local TEXT_FILTER_DATA_TYPE = 1
local TEXT_FILTER_TYPE_ID = 5
local MARGIN = 22

function TextFilter:New(name, tradingHouseWrapper, ...)
	return FilterBase.New(self, TEXT_FILTER_TYPE_ID, name, tradingHouseWrapper, ...)
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
	self:SetLabelControl(label)

	local input = CreateControlFromVirtual(name .. "Input", container, "AwesomeGuildStoreNameFilterTemplate")
	input:ClearAnchors()
	input:SetAnchor(BOTTOMLEFT, container, BOTTOMLEFT, 0, 0)
	input:SetAnchor(BOTTOMRIGHT, container, BOTTOMRIGHT, 0, 0)
	local inputBox = input:GetNamedChild("Box")
	ZO_EditDefaultText_Initialize(inputBox, L["TEXT_FILTER_TEXT"])
	inputBox:SetMaxInputChars(250)
	self.inputBox = inputBox

	container:SetHeight(22 + 4 + 28)

	local tooltipText = L["RESET_FILTER_LABEL_TEMPLATE"]:format(label:GetText():gsub(":", ""))
	self.resetButton:SetTooltipText(tooltipText)
end

function TextFilter:InitializeHandlers(tradingHouseWrapper)
	local tradingHouse = tradingHouseWrapper.tradingHouse
	local inputBox = self.inputBox
	inputBox:SetHandler("OnTextChanged", function(control)
		ZO_EditDefaultText_OnTextChanged(inputBox)
		self:HandleChange()
	end)
	self.LTF = LibStub("LibTextFilter")
	self.haystack = {}
end

function TextFilter:BeforeRebuildSearchResultsPage(tradingHouseWrapper)
	local searchTerm = self.inputBox:GetText()
	if(searchTerm ~= "") then
		self.searchTerm = searchTerm:lower():gsub("|h(.-)|h(.-)|h", "|H%1|h%2|h") -- need to fix links after we put everything to lowercase
		return true
	end
	return false
end

function TextFilter:FilterPageResult(index, icon, name, quality, stackCount, sellerName, timeRemaining, purchasePrice)
	local data = self.data
	local itemLink = GetTradingHouseSearchResultItemLink(index)
	local isSetItem, setName = GetItemLinkSetInfo(itemLink)

	local haystack, LTF = self.haystack, self.LTF
	haystack[1] = name:lower()
	haystack[2] = itemLink
	haystack[3] = setName:lower()
	for i = 1, #haystack do
		local isMatch, result = LTF:Filter(haystack[i], self.searchTerm)
		if(isMatch) then
			return true
		end
	end
	return false
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
