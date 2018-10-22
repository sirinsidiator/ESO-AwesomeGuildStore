local gettext = LibStub("LibGetText")("AwesomeGuildStore").gettext
local FilterBase = AwesomeGuildStore.FilterBase

local TextFilter = FilterBase:Subclass()
AwesomeGuildStore.TextFilter = TextFilter

local FILTER_ID = AwesomeGuildStore.data.FILTER_ID
local TEXT_FILTER_DATA_TYPE = 1
local MARGIN = 22

function TextFilter:New(name, tradingHouseWrapper, ...)
    return FilterBase.New(self, FILTER_ID.TEXT_FILTER, name, tradingHouseWrapper, ...)
end

function TextFilter:Initialize(name, tradingHouseWrapper)
    self:InitializeControls(name)
    self:InitializeHandlers(tradingHouseWrapper)
end

function TextFilter:InitializeControls(name)
    local container = self.container

    -- TRANSLATORS: title of the text filter in the left panel on the search tab
    self:SetLabel(gettext("Text Search"))

    local input = CreateControlFromVirtual(name .. "Input", container, "AwesomeGuildStoreNameFilterTemplate")
    input:ClearAnchors()
    input:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
    input:SetAnchor(TOPRIGHT, container, TOPRIGHT, 0, 0)
    local inputBox = input:GetNamedChild("Box")
    -- TRANSLATORS: placeholder text for the text filter input box
    ZO_EditDefaultText_Initialize(inputBox, gettext("Filter by text"))
    inputBox:SetMaxInputChars(250) -- TODO: reevaluate - we basically can save any amount if we want
    self.inputBox = inputBox
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
        self.searchTerm = searchTerm:lower()
        return true
    end
    return false
end

function TextFilter:FilterPageResult(index, icon, name, quality, stackCount, sellerName, timeRemaining, purchasePrice)
    local data = self.data
    local itemLink = GetTradingHouseSearchResultItemLink(index)
    local isSetItem, setName = GetItemLinkSetInfo(itemLink)

    local haystack, LTF = self.haystack, self.LTF
    haystack[1] = name
    haystack[2] = itemLink
    haystack[3] = setName
    local isMatch, result = LTF:Filter(table.concat(haystack, "\n"):lower(), self.searchTerm)
    return isMatch
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
        return {{label = self:GetLabel(), text = state}}
    end
    return {}
end
