local AGS = AwesomeGuildStore

local FilterFragment = AGS.class.FilterFragment
local SimpleInputBox = AGS.class.SimpleInputBox

local RegisterForEvent = AGS.internal.RegisterForEvent

local MIN_LETTERS = GetMinLettersInTradingHouseItemNameForCurrentLanguage()

local TextFilterFragment = FilterFragment:Subclass()
AGS.class.TextFilterFragment = TextFilterFragment

function TextFilterFragment:New(...)
    return FilterFragment.New(self, ...)
end

function TextFilterFragment:Initialize(filterId)
    FilterFragment.Initialize(self, filterId)

    self:InitializeControls()
    self:InitializeHandlers()
end

function TextFilterFragment:InitializeControls()
    local container = self:GetContainer()

    local inputContainer = CreateControlFromVirtual("$(parent)Input", container, "AwesomeGuildStoreTextSearchInputTemplate")
    inputContainer:SetAnchor(TOPLEFT, container, TOPLEFT, 5, 4)
    inputContainer:SetAnchor(TOPRIGHT, container, TOPRIGHT, -5, 4)

    local autoComplete = CreateControlFromVirtual("AwesomeGuildStoreTextSearchInputAutoComplete", ZO_TradingHouse, "ZO_TradingHouseNameSearchAutoComplete_Menu")
    autoComplete:SetClampedToScreen(false)
    autoComplete:SetAnchor(TOPLEFT, inputContainer, BOTTOMLEFT, 4, 10)

    self.input = SimpleInputBox:New(inputContainer:GetNamedChild("Input"))
    self.input:SetMaxInputChars(30000)

    self.nameSearchAutoComplete = ZO_TradingHouseNameSearchAutoComplete:New(autoComplete, self.input)
    RegisterForEvent(EVENT_MATCH_TRADING_HOUSE_ITEM_NAMES_COMPLETE, function(_, ...)
        self:OnNameMatchComplete(...)
    end)
end

function TextFilterFragment:InitializeHandlers()
    local input = self.input
    local fromCallback = false

    local function OnInputChanged(input, value)
        if(fromCallback) then return end
        self.filter:SetText(value)
    end

    local function OnTextChanged(input, text)
        self:CancelPendingNameMatch()
        if(self.filter:IsSearchTextLongEnough(text)) then
            self:StartNameMatch(text)
        end
    end

    local function OnFilterChanged(self, text)
        fromCallback = true
        input:SetValue(text)
        fromCallback = false
    end

    input.OnValueChanged = OnInputChanged
    input.OnTextChanged = OnTextChanged
    self.OnValueChanged = OnFilterChanged
end

function TextFilterFragment:OnAttach(filterArea)
    local editGroup = filterArea:GetEditGroup()
    editGroup:InsertControl(self.input)
end

function TextFilterFragment:OnDetach(filterArea)
    local editGroup = filterArea:GetEditGroup()
    editGroup:RemoveControl(self.input)
end

function TextFilterFragment:SetEnabled(enabled)
    FilterFragment.SetEnabled(self, enabled)
    self.input:SetEnabled(enabled)
end

function TextFilterFragment:StartNameMatch(text)
    ClearAllTradingHouseSearchTerms()
    self.pendingItemNameMatchId = MatchTradingHouseItemNames(text)
end

function TextFilterFragment:CancelPendingNameMatch()
    if self.pendingItemNameMatchId then
        CancelMatchTradingHouseItemNames(self.pendingItemNameMatchId)
        self.pendingItemNameMatchId = nil
    end
end

function TextFilterFragment:OnNameMatchComplete(id, numResults)
    if id == self.pendingItemNameMatchId then
        self.pendingItemNameMatchId = nil
        self.nameSearchAutoComplete:ShowListForNameSearch(id, numResults)
    end
end