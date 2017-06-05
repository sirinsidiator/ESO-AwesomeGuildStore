local gettext = LibStub("LibGetText")("AwesomeGuildStore").gettext
local MinMaxRangeSlider = AwesomeGuildStore.MinMaxRangeSlider
local FilterBase = AwesomeGuildStore.FilterBase

local PriceFilter = FilterBase:Subclass()
AwesomeGuildStore.PriceFilter = PriceFilter

local LOWER_LIMIT = 1
local UPPER_LIMIT = 2100000000
local values = { LOWER_LIMIT, 10, 50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000, 50000, 100000, UPPER_LIMIT }
local MIN_VALUE = 1
local MAX_VALUE = #values
local LINE_SPACING = 4
local PRICE_FILTER_TYPE_ID = 2

function PriceFilter:New(name, tradingHouseWrapper, ...)
	return FilterBase.New(self, PRICE_FILTER_TYPE_ID, name, tradingHouseWrapper, ...)
end

function PriceFilter:Initialize(name, tradingHouseWrapper)
	self.isLocal = false
	self:InitializeControls(name, tradingHouseWrapper.tradingHouse)
	self:InitializeHandlers(tradingHouseWrapper.tradingHouse)
end

function PriceFilter:InitializeControls(name, tradingHouse)
	local common = tradingHouse.m_browseItems:GetNamedChild("Common")
	local container = self.container

	local priceRangeLabel = common:GetNamedChild("PriceRangeLabel")
	priceRangeLabel:SetParent(container)
	self:SetLabelControl(priceRangeLabel)

	local minPrice = common:GetNamedChild("MinPrice")
	minPrice:SetParent(container)

	local priceRangeDivider = common:GetNamedChild("PriceRangeDivider")
	priceRangeDivider:SetParent(container)

	local maxPrice = common:GetNamedChild("MaxPrice")
	maxPrice:SetParent(container)

	local slider = MinMaxRangeSlider:New(container, name .. "Slider")
	slider:SetMinMax(MIN_VALUE, MAX_VALUE)
	slider:SetMinRange(1)
	slider:SetRangeValue(MIN_VALUE, MAX_VALUE)
	slider.control:ClearAnchors()
	slider.control:SetAnchor(TOPLEFT, priceRangeLabel, BOTTOMLEFT, 0, LINE_SPACING)
	slider.control:SetAnchor(RIGHT, container, RIGHT, 0, 0)
	self.slider = slider

	minPrice:ClearAnchors()
	minPrice:SetAnchor(TOPLEFT, slider.control, BOTTOMLEFT, 0, LINE_SPACING)

	container:SetHeight(priceRangeLabel:GetHeight() + LINE_SPACING + slider.control:GetHeight() + LINE_SPACING + minPrice:GetHeight())

	self.minPriceBox = common:GetNamedChild("MinPriceBox")
	self.maxPriceBox = common:GetNamedChild("MaxPriceBox")

	local tooltipText = gettext("Reset <<1>> Filter", priceRangeLabel:GetText():gsub(":", ""))
	self.resetButton:SetTooltipText(tooltipText)
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
		value = ToNearestLinear(tonumber(value)) or old
	end
	return value
end

function PriceFilter:InitializeHandlers(tradingHouse)
	local minPriceBox = self.minPriceBox
	local maxPriceBox = self.maxPriceBox
	local slider = self.slider
	local setFromTextBox = false

	local function UpdateSliderFromTextBox()
		setFromTextBox = true
		local oldMin, oldMax = slider:GetRangeValue()
		local min = ValueFromText(minPriceBox:GetText(), MIN_VALUE, oldMin)
		local max = ValueFromText(maxPriceBox:GetText(), MAX_VALUE, oldMax)

		slider:SetRangeValue(min, max)
		setFromTextBox = false
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

	ZO_PreHook(tradingHouse.m_search, "InternalExecuteSearch", function(self)
		local min = minPriceBox:GetText()
		local max = maxPriceBox:GetText()
		if(min == "" and max == "") then return end
		if(min == "") then min = LOWER_LIMIT end
		if(max == "") then max = UPPER_LIMIT end
		min = tonumber(min)
		max = tonumber(max)
		if(min == max) then max = nil end

		self.m_filters[TRADING_HOUSE_FILTER_TYPE_PRICE].values = {min, max}
	end)

	UpdateTextBoxFromSlider()
end

function PriceFilter:SetWidth(width)
	self.container:SetWidth(width)
	self.slider:UpdateVisuals()
end

function PriceFilter:Reset()
	self.slider:SetMinMax(MIN_VALUE, MAX_VALUE)
	self.slider:SetRangeValue(MIN_VALUE, MAX_VALUE)
end

function PriceFilter:IsDefault()
	local min, max = self.slider:GetRangeValue()
	return (min == MIN_VALUE and max == MAX_VALUE)
end

function PriceFilter:Serialize()
	local min = tonumber(self.minPriceBox:GetText()) or "-"
	local max = tonumber(self.maxPriceBox:GetText()) or "-"
	return min .. ";" .. max
end

function PriceFilter:Deserialize(state)
	local min, max = zo_strsplit(";", state)
	min = tonumber(min) or LOWER_LIMIT
	max = tonumber(max) or UPPER_LIMIT
	self.minPriceBox:SetText(min <= LOWER_LIMIT and "" or min)
	self.maxPriceBox:SetText(max >= UPPER_LIMIT and "" or max)
end

local function GetFormattedPrice(price)
	return zo_strformat(SI_FORMAT_ICON_TEXT, ZO_CurrencyControl_FormatCurrency(price), zo_iconFormat("EsoUI/Art/currency/currency_gold.dds", 16, 16))
end

function PriceFilter:GetTooltipText(state)
	local minPrice, maxPrice = zo_strsplit(";", state)
	minPrice = tonumber(minPrice)
	maxPrice = tonumber(maxPrice)
	local priceText = ""
	if(minPrice and maxPrice) then
	   -- TRANSLATORS: tooltip format for search library entries with a range filter where min and max value have been set
		priceText = gettext("<<1>> - <<2>>", GetFormattedPrice(minPrice), GetFormattedPrice(maxPrice))
	elseif(minPrice) then
       -- TRANSLATORS: tooltip format for search library entries with a range filter where only the min value has been set
		priceText = gettext("over <<1>>", GetFormattedPrice(minPrice))
	elseif(maxPrice) then
       -- TRANSLATORS: tooltip format for search library entries with a range filter where only the max value has been set
		priceText = gettext("under <<1>>", GetFormattedPrice(maxPrice))
	end

	if(priceText ~= "") then
		return {{label = GetString(SI_TRADING_HOUSE_BROWSE_PRICE_RANGE_LABEL):sub(0, -2), text = priceText}}
	end
	return {}
end
