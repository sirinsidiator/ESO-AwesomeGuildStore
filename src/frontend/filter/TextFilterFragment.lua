local AGS = AwesomeGuildStore

local FilterFragment = AGS.class.FilterFragment
local SimpleInputBox = AGS.class.SimpleInputBox

local logger = AGS.internal.logger
local RegisterForEvent = AGS.internal.RegisterForEvent

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
end

function TextFilterFragment:InitializeHandlers()
    local input = self.input
    local fromCallback = false

    local function OnInputChanged(input, value)
        if(fromCallback) then return end
        self.filter:SetText(value)
    end

    local function HandleResult(result)
        self.nameSearchAutoComplete:ShowListForNameSearch(result.id, result.count)
    end

    local function HandleError(errorCode)
        self.nameSearchAutoComplete:ShowListForNameSearch(nil, 0)
    end

    local function OnTextChanged(input, text)
        self.filter.matcher:MatchText(text):Then(HandleResult, HandleError)
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