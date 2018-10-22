local FilterFragment = AwesomeGuildStore.class.FilterFragment
local SimpleInputBox = AwesomeGuildStore.class.SimpleInputBox

local TextFilterFragment = FilterFragment:Subclass()
AwesomeGuildStore.class.TextFilterFragment = TextFilterFragment

function TextFilterFragment:New(...)
    return FilterFragment.New(self, ...)
end

function TextFilterFragment:Initialize(filter)
    FilterFragment.Initialize(self, filter)

    self:InitializeControls()
    self:InitializeHandlers()
end

function TextFilterFragment:InitializeControls()
    local container = self:GetContainer()

    local inputContainer = CreateControlFromVirtual("$(parent)Input", container, "AwesomeGuildStoreTextSearchInputTemplate")
    inputContainer:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 4)
    inputContainer:SetAnchor(TOPRIGHT, container, TOPRIGHT, 0, 4)

    self.input = SimpleInputBox:New(inputContainer:GetNamedChild("Input"))
end

function TextFilterFragment:InitializeHandlers()
    local input = self.input
    local fromCallback = false

    local function OnInputChanged(input)
        if(fromCallback) then return end
        self.filter:SetText(input:GetValue() or "")
    end

    local function OnFilterChanged(self, text)
        fromCallback = true
        input:SetValue(text)
        fromCallback = false
    end

    input.OnValueChanged = OnInputChanged
    self.OnValueChanged = OnFilterChanged
end

function TextFilterFragment:OnAttach(filterArea)
    local editGroup = filterArea:GetEditGroup()
    editGroup:InsertControl(self.input:GetEditControl())
end

function TextFilterFragment:OnDetach(filterArea)
    local editGroup = filterArea:GetEditGroup()
    editGroup:RemoveControl(self.input:GetEditControl())
end
