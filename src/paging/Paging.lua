local L = AwesomeGuildStore.Localization

local Paging = ZO_Object:Subclass()
AwesomeGuildStore.Paging = Paging

function Paging:New(...)
	local paging = ZO_Object.New(self)
	paging:Initialize(...)
	return paging
end

local function CreateButton(name, parent, label)
	local button = CreateControlFromVirtual(("AwesomeGuildStore%s"):format(name), parent, "ZO_DefaultTextButton")
	button:SetFont("ZoFontGame")
	button:SetText(label)
	button:SetWidth(30)
	return button
end

function Paging:Initialize(tradingHouseWrapper)
	local searchTab = tradingHouseWrapper.searchTab
	local tradingHouse = tradingHouseWrapper.tradingHouse
	local search = tradingHouse.m_search
	local navBar = tradingHouse.m_nagivationBar

	local input = CreateControlFromVirtual("AwesomeGuildStorePageInput", navBar, "AwesomeGuildStoreNameFilterTemplate")
	input:ClearAnchors()
	input:SetAnchor(TOP, navBar, TOP, 20, 2)
	input:SetWidth(40)
	local inputBox = input:GetNamedChild("Box")
	inputBox:SetMaxInputChars(3)
	inputBox:SetTextType(TEXT_TYPE_NUMERIC_UNSIGNED_INT)
	inputBox:SetText(3)
--	inputBox:SetHandler("OnFocusLost", function() inputBox:SetText(self.currentPage) end)
	inputBox:SetHandler("OnEscape", function() inputBox:SetText(self.currentPage) end)
	inputBox:SetHandler("OnEnter", function() 
		searchTab:Search(tonumber(inputBox:GetText()) - 1) 
		inputBox:LoseFocus()
	end)

	local pageButton2 = CreateButton("PageButton2", navBar, "2")
	pageButton2:SetAnchor(RIGHT, input, LEFT, 0, 0)
	pageButton2:SetHandler("OnClicked", function() searchTab:SearchPreviousPage() end)

	local pageButton1 = CreateButton("PageButton1", navBar, "1")
	pageButton1:SetAnchor(RIGHT, pageButton2, LEFT, 0, 0)
	pageButton1:SetHandler("OnClicked", function() searchTab:Search(self.currentPage - 2 - 1) end) -- page numbers start at 0, but we start at 1 for displaying

	local previousPageButton = tradingHouse.m_previousPage
	previousPageButton:SetText("<")
	previousPageButton:SetWidth(20)
	previousPageButton:ClearAnchors()
	previousPageButton:SetAnchor(RIGHT, pageButton1, LEFT, -5, 0)
	previousPageButton:SetHandler("OnClicked", function() searchTab:SearchPreviousPage() end)

	local firstPageButton = CreateButton("FirstPageButton", navBar, "<<")
	firstPageButton:SetAnchor(RIGHT, previousPageButton, LEFT, -5, 0)
	firstPageButton:SetHandler("OnClicked", function() searchTab:Search(0) end)

	local pageButton3 = CreateButton("PageButton3", navBar, "4")
	pageButton3:SetAnchor(LEFT, input, RIGHT, 0, 0)
	pageButton3:SetHandler("OnClicked", function() searchTab:SearchNextPage() end)

	local pageButton4 = CreateButton("PageButton4", navBar, "5")
	pageButton4:SetAnchor(LEFT, pageButton3, RIGHT, 0, 0)
	pageButton4:SetHandler("OnClicked", function() searchTab:Search(self.currentPage + 2 - 1) end)

	local nextPageButton = tradingHouse.m_nextPage
	nextPageButton:SetText(">")
	nextPageButton:SetWidth(20)
	nextPageButton:ClearAnchors()
	nextPageButton:SetAnchor(LEFT, pageButton4, RIGHT, 5, 0)
	nextPageButton:SetHandler("OnClicked", function() searchTab:SearchNextPage() end)

	local lastPageButton = CreateButton("LastPageButton", navBar, ">>")
	lastPageButton:SetAnchor(LEFT, nextPageButton, RIGHT, 5, 0)
	lastPageButton:SetHandler("OnClicked", function() searchTab:Search(self.maxPage - 1) end)

	self.firstPageButton = firstPageButton
	self.previousPageButton = previousPageButton
	self.pageButton1 = pageButton1
	self.pageButton2 = pageButton2
	self.input = input
	self.inputBox = inputBox
	self.pageButton3 = pageButton3
	self.pageButton4 = pageButton4
	self.nextPageButton = nextPageButton
	self.lastPageButton = lastPageButton

	self:Reset()

	tradingHouseWrapper:Wrap("UpdatePagingButtons", function(originalUpdatePagingButtons, tradingHouse)
		originalUpdatePagingButtons(tradingHouse)
		previousPageButton:SetEnabled(true)
		nextPageButton:SetEnabled(true)
		self.currentPage = tonumber(search.m_page) + 1
		if(tradingHouse.m_numItemsOnPage > 0) then
			self.maxPage = math.max(self.maxPage, self.currentPage)
		end
		self:Refresh()
	end)
	ZO_PreHook(search, "ResetPageData", function()
		self:Reset()
	end)
end

function Paging:Reset()
	self.currentPage = 1
	self.maxPage = 1
	self.previousPageButton:SetHidden(true)
	self.nextPageButton:SetHidden(true)
	self:Refresh()
end

function Paging:Refresh()
	local currentPage = self.currentPage
	local maxPage = self.maxPage
	self.firstPageButton:SetHidden(currentPage <= 1)
	self.pageButton1:SetText(currentPage - 2)
	self.pageButton1:SetHidden(currentPage <= 2)
	self.pageButton2:SetText(currentPage - 1)
	self.pageButton2:SetHidden(currentPage <= 1)
	self.inputBox:SetText(currentPage)
	self.input:SetHidden(currentPage <= 0)
	self.pageButton3:SetText(currentPage + 1)
	self.pageButton3:SetHidden(maxPage - currentPage < 1)
	self.pageButton4:SetText(currentPage + 2)
	self.pageButton4:SetHidden(maxPage - currentPage < 2)
	self.lastPageButton:SetHidden(maxPage <= currentPage)
end