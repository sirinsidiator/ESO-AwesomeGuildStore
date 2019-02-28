local AGS = AwesomeGuildStore

local MinMaxRangeSlider = AGS.class.MinMaxRangeSlider
local ValueRangeFilterFragmentBase = AGS.class.ValueRangeFilterFragmentBase
local SimpleInputBox = AGS.class.SimpleInputBox

local ENABLED_DESATURATION = 0
local DISABLED_DESATURATION = 1

local PriceRangeFilterFragment = ValueRangeFilterFragmentBase:Subclass()
AGS.class.PriceRangeFilterFragment = PriceRangeFilterFragment

function PriceRangeFilterFragment:New(...)
    return ValueRangeFilterFragmentBase.New(self, ...)
end

function PriceRangeFilterFragment:Initialize(filterId)
    ValueRangeFilterFragmentBase.Initialize(self, filterId)

    local container = self:GetContainer()
    local config = self.filter:GetConfig()
    self.min = config.min
    self.max = config.max
    self.steps = config.steps

    local inputContainer = CreateControlFromVirtual("$(parent)Input", container, "AwesomeGuildStorePriceInputTemplate")
    inputContainer:SetAnchor(TOPLEFT, self.slider.control, BOTTOMLEFT, 0, 4)

    local minPrice = self:SetupInputBox(inputContainer, "MinPriceInput", config)
    local maxPrice = self:SetupInputBox(inputContainer, "MaxPriceInput", config)

    local function OnInputChanged(input)
        if(self.fromFilter) then return end
        local min, max = self:GetInputValues()
        self.filter:SetValues(min, max)
    end
    minPrice.OnValueChanged = OnInputChanged
    maxPrice.OnValueChanged = OnInputChanged

    local currencyIcon = ZO_Currency_GetKeyboardCurrencyIcon(config.currency)
    self.minPriceCurrency = inputContainer:GetNamedChild("MinPriceCurrency")
    self.maxPriceCurrency = inputContainer:GetNamedChild("MaxPriceCurrency")
    self.minPriceCurrency:SetTexture(currencyIcon)
    self.maxPriceCurrency:SetTexture(currencyIcon)

    self.minPrice = minPrice
    self.maxPrice = maxPrice
end

function PriceRangeFilterFragment:SetupInputBox(inputContainer, name, config)
    local input = SimpleInputBox:New(inputContainer:GetNamedChild(name))
    input:SetType(SimpleInputBox.INPUT_TYPE_NUMERIC)
    input:SetTextAlign(SimpleInputBox.TEXT_ALIGN_RIGHT)
    input:SetPrecision(config.precision)
    input:SetMin(config.min)
    input:SetMax(config.max)
    return input
end

function PriceRangeFilterFragment:ToNearestValue(value)
    return self.steps[value]
end

function PriceRangeFilterFragment:ToNearestStep(value)
    local steps = self.steps
    local maxValue = #steps
    for i = 1, maxValue - 1 do
        if(value < (steps[i] + steps[i + 1]) / 2) then
            return i
        end
    end
    return maxValue
end

function PriceRangeFilterFragment:OnValueChanged(min, max)
    self.fromFilter = true
    self.slider:SetRangeValue(self:ToNearestStep(min), self:ToNearestStep(max))

    if(max == self.max) then max = nil end
    if(not max and min == self.min) then min = nil end
    self:SetInputValues(min, max)

    self.fromFilter = false
end

function PriceRangeFilterFragment:GetInputValues()
    local min = self.minPrice:GetValue()
    local max = self.maxPrice:GetValue()
    return min, max
end

function PriceRangeFilterFragment:SetInputValues(min, max)
    self.minPrice:SetValue(min)
    self.maxPrice:SetValue(max)
end

function PriceRangeFilterFragment:OnAttach(filterArea)
    local editGroup = filterArea:GetEditGroup()
    editGroup:InsertControl(self.minPrice)
    editGroup:InsertControl(self.maxPrice)
end

function PriceRangeFilterFragment:OnDetach(filterArea)
    local editGroup = filterArea:GetEditGroup()
    editGroup:RemoveControl(self.minPrice)
    editGroup:RemoveControl(self.maxPrice)
end

function PriceRangeFilterFragment:SetEnabled(enabled)
    ValueRangeFilterFragmentBase.SetEnabled(self, enabled)
    self.minPrice:SetEnabled(enabled)
    self.maxPrice:SetEnabled(enabled)
    local desaturation = enabled and ENABLED_DESATURATION or DISABLED_DESATURATION
    self.minPriceCurrency:SetDesaturation(desaturation)
    self.maxPriceCurrency:SetDesaturation(desaturation)
end
