local gettext = LibStub("LibGetText")("AwesomeGuildStore").gettext
local MinMaxRangeSlider = AwesomeGuildStore.MinMaxRangeSlider
local FilterBase = AwesomeGuildStore.FilterBase
local GetItemLinkWritCount = AwesomeGuildStore.GetItemLinkWritCount

local UnitPriceFilter = FilterBase:Subclass()
AwesomeGuildStore.UnitPriceFilter = UnitPriceFilter

local LOWER_LIMIT = 0
local UPPER_LIMIT = 2100000000
local values = { LOWER_LIMIT, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 20, 25, 30, 35, 40, 45, 50, 100, 200, 300, 400, 500, 700, 800, 900, 1000, 2000, 3000, 4000, 5000, 10000, 50000, 100000, UPPER_LIMIT }
local MIN_VALUE = 0
local MAX_VALUE = #values
local MIN_RANGE = 1
local LINE_SPACING = 4
local UNIT_PRICE_FILTER_TYPE_ID = 6

function UnitPriceFilter:New(name, tradingHouseWrapper, ...)
    return FilterBase.New(self, UNIT_PRICE_FILTER_TYPE_ID, name, tradingHouseWrapper, ...)
end

function UnitPriceFilter:Initialize(name, tradingHouseWrapper)
    self:InitializeControls(name)
    self:InitializeHandlers(tradingHouseWrapper.tradingHouse)
end

function UnitPriceFilter:InitializeControls(name)
    local container = self.container

    -- TRANSLATORS: title of the unit price filter in the left panel on the search tab
    self:SetLabel(gettext("Unit Price Range"))

    local slider = MinMaxRangeSlider:New("$(parent)Slider", container)
    slider:SetMinMax(MIN_VALUE, MAX_VALUE)
    slider:SetMinRange(MIN_RANGE)
    slider:SetRangeValue(MIN_VALUE, MAX_VALUE)
    slider.control:ClearAnchors()
    slider.control:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
    slider.control:SetAnchor(TOPRIGHT, container, TOPRIGHT, 0, 0)
    slider:UpdateVisuals()
    self.slider = slider

    local inputContainer = CreateControlFromVirtual(name .. "Input", container, "AwesomeGuildStorePriceInputTemplate")
    inputContainer:SetAnchor(TOPLEFT, slider.control, BOTTOMLEFT, 0, LINE_SPACING)

    self.minPriceBox = inputContainer:GetNamedChild("MinPriceBox")
    self.minPriceBox:SetTextType(TEXT_TYPE_NUMERIC)
    self.maxPriceBox = inputContainer:GetNamedChild("MaxPriceBox")
    self.maxPriceBox:SetTextType(TEXT_TYPE_NUMERIC)
end

local function ToNearestLinear(value)
    for i, range in ipairs(values) do
        if(i < MAX_VALUE and value < ((values[i + 1] + range) / 2)) then return i end
    end
    return MAX_VALUE
end

local function ValueFromText(value, limit, old)
    if(value == "") then
        value = limit
    else
        value = ToNearestLinear(tonumber(value))
        if(value == nil) then value = old end
    end
    return value
end

local function PreventNegativeInput(textBox)
    local value = tonumber(textBox:GetText())
    if(not value) then textBox:SetText("") return true
    elseif(value < 0) then textBox:SetText(-value) return true end
    return false
end

function UnitPriceFilter:InitializeHandlers(tradingHouse)
    local minPriceBox = self.minPriceBox
    local maxPriceBox = self.maxPriceBox
    local slider = self.slider
    local setFromTextBox = false

    local function UpdateSliderFromTextBox()
        if(not setFromTextBox) then
            setFromTextBox = true
            PreventNegativeInput(minPriceBox)
            PreventNegativeInput(maxPriceBox)

            local oldMin, oldMax = slider:GetRangeValue()
            local min = ValueFromText(minPriceBox:GetText(), MIN_VALUE, oldMin)
            local max = ValueFromText(maxPriceBox:GetText(), MAX_VALUE, oldMax)

            slider:SetRangeValue(min, max)
            setFromTextBox = false
        end
    end

    minPriceBox:SetHandler("OnTextChanged", UpdateSliderFromTextBox)
    maxPriceBox:SetHandler("OnTextChanged", UpdateSliderFromTextBox)

    local function UpdateTextBoxFromSlider()
        local min, max = slider:GetRangeValue()
        if(min == MIN_VALUE) then min = "" else min = values[min] end
        if(max == MAX_VALUE) then max = "" else max = values[max] end

        minPriceBox:SetText(min)
        maxPriceBox:SetText(max)
    end

    slider.OnValueChanged = function(slider, min, max)
        self:HandleChange()
        if(setFromTextBox) then return end
        UpdateTextBoxFromSlider()
    end

    UpdateTextBoxFromSlider()
end

function UnitPriceFilter:BeforeRebuildSearchResultsPage(tradingHouseWrapper)
    local min = self.minPriceBox:GetText()
    local max = self.maxPriceBox:GetText()

    if(min == "" and max == "") then
        self.min, self.max = nil, nil
        return false
    end

    if(min == "") then min = LOWER_LIMIT end
    if(max == "") then max = UPPER_LIMIT end
    self.min, self.max = tonumber(min), tonumber(max)

    return true
end

function UnitPriceFilter:FilterPageResult(index, icon, name, quality, stackCount, sellerName, timeRemaining, purchasePrice)
    local itemLink = GetTradingHouseSearchResultItemLink(index)
    local itemType = GetItemLinkItemType(itemLink)
    if(itemType == ITEMTYPE_MASTER_WRIT) then
        stackCount = GetItemLinkWritCount(itemLink)
    end
    local unitPrice = purchasePrice / stackCount
    return not (unitPrice < self.min or unitPrice > self.max)
end

function UnitPriceFilter:SetWidth(width)
    self.container:SetWidth(width)
    self.slider:UpdateVisuals()
end

function UnitPriceFilter:Reset()
    self.slider:SetMinMax(MIN_VALUE, MAX_VALUE)
    self.slider:SetRangeValue(MIN_VALUE, MAX_VALUE)
end

function UnitPriceFilter:IsDefault()
    local min, max = self.slider:GetRangeValue()
    return (min == MIN_VALUE and max == MAX_VALUE)
end

function UnitPriceFilter:Serialize()
    local min = tonumber(self.minPriceBox:GetText()) or "-"
    local max = tonumber(self.maxPriceBox:GetText()) or "-"
    return min .. ";" .. max
end

function UnitPriceFilter:Deserialize(state)
    local min, max = zo_strsplit(";", state)
    min = tonumber(min) or LOWER_LIMIT
    max = tonumber(max) or UPPER_LIMIT
    self.minPriceBox:SetText(min <= LOWER_LIMIT and "" or min)
    self.maxPriceBox:SetText(max >= UPPER_LIMIT and "" or max)
end

local function GetFormattedPrice(price)
    return zo_strformat(SI_FORMAT_ICON_TEXT, ZO_CurrencyControl_FormatCurrency(price), zo_iconFormat("EsoUI/Art/currency/currency_gold.dds", 16, 16))
end

function UnitPriceFilter:GetTooltipText(state)
    local minPrice, maxPrice = zo_strsplit(";", state)
    minPrice = tonumber(minPrice)
    maxPrice = tonumber(maxPrice)
    local priceText = ""
    if(minPrice and maxPrice) then
        priceText = gettext("<<1>> - <<2>>", GetFormattedPrice(minPrice), GetFormattedPrice(maxPrice))
    elseif(minPrice) then
        priceText = gettext("over <<1>>", GetFormattedPrice(minPrice))
    elseif(maxPrice) then
        priceText = gettext("under <<1>>", GetFormattedPrice(maxPrice))
    end

    if(priceText ~= "") then
        return {{label = self:GetLabel(), text = priceText}}
    end
    return {}
end
