local LOWER_LIMIT = 1
local UPPER_LIMIT = 2100000000
local values = { LOWER_LIMIT, 10, 50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000, 50000, 100000, UPPER_LIMIT }
local MIN_VALUE = 1
local MAX_VALUE = #values

local function ToNearestLinear(value)
	for i, range in ipairs(values) do
		if(i < MAX_VALUE and value < ((values[i + 1] + range) / 2)) then return i end
	end
	return MAX_VALUE
end

local PriceSelector = ZO_Object:Subclass()
AwesomeGuildStore.PriceSelector = PriceSelector

local MinMaxRangeSlider = AwesomeGuildStore.MinMaxRangeSlider

function PriceSelector:New(parent, name)
	local selector = ZO_Object.New(self)

	local setFromTextBox = false
	local minPriceBox = parent:GetNamedChild("MinPriceBox")
	local maxPriceBox = parent:GetNamedChild("MaxPriceBox")
	local slider = MinMaxRangeSlider:New(parent, name .. "PriceSlider", 0, 0, 195, 16)
	slider:SetMinMax(MIN_VALUE, MAX_VALUE)
	slider:SetMinRange(1)
	slider:SetRangeValue(MIN_VALUE, MAX_VALUE)
	selector.slider = slider

	local function ValueFromText(value, limit, old)
		if(value == "") then
			value = limit
		else
			value = ToNearestLinear(tonumber(value)) or old
		end
		return value
	end

	local function UpdateSliderFromTextBox()
		setFromTextBox = true
		local oldMin, oldMax = slider:GetRangeValue()
		local min = ValueFromText(minPriceBox:GetText(), MIN_VALUE, oldMin)
		local max = ValueFromText(maxPriceBox:GetText(), MAX_VALUE, oldMax)

		slider:SetRangeValue(min, max)
		setFromTextBox = false
	end

	local function UpdateTextBoxFromSlider()
		local min, max = slider:GetRangeValue()
		if(min == MIN_VALUE) then min = "" else min = values[min] end
		if(max == MAX_VALUE) then max = "" else max = values[max] end

		minPriceBox:SetText(min)
		maxPriceBox:SetText(max)
	end

	slider.OnValueChanged = function(self, min, max)
		if(setFromTextBox) then return end
		UpdateTextBoxFromSlider()
	end

	minPriceBox:SetHandler("OnTextChanged", UpdateSliderFromTextBox)
	maxPriceBox:SetHandler("OnTextChanged", UpdateSliderFromTextBox)
	UpdateTextBoxFromSlider()

	ZO_PreHook(TRADING_HOUSE.m_search, "InternalExecuteSearch", function(self)
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

	return selector
end

function PriceSelector:Reset()
	self.slider:SetMinMax(MIN_VALUE, MAX_VALUE)
	zo_callLater(function()
		self.slider:SetRangeValue(MIN_VALUE, MAX_VALUE)
	end, 1)
end
