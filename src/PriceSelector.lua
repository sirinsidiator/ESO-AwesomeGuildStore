local L = AwesomeGuildStore.Localization
local MinMaxRangeSlider = AwesomeGuildStore.MinMaxRangeSlider

local LOWER_LIMIT = 1
local UPPER_LIMIT = 2100000000
local values = { LOWER_LIMIT, 10, 50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000, 50000, 100000, UPPER_LIMIT }
local MIN_VALUE = 1
local MAX_VALUE = #values
local RESET_BUTTON_SIZE = 18
local RESET_BUTTON_TEXTURE = "EsoUI/Art/Buttons/decline_%s.dds"

local function ToNearestLinear(value)
	for i, range in ipairs(values) do
		if(i < MAX_VALUE and value < ((values[i + 1] + range) / 2)) then return i end
	end
	return MAX_VALUE
end

local PriceSelector = ZO_Object:Subclass()
AwesomeGuildStore.PriceSelector = PriceSelector

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
		selector.resetButton:SetHidden(selector:IsDefault())
		if(setFromTextBox) then return end
		UpdateTextBoxFromSlider()
	end

	minPriceBox:SetHandler("OnTextChanged", UpdateSliderFromTextBox)
	maxPriceBox:SetHandler("OnTextChanged", UpdateSliderFromTextBox)
	self.minPriceBox = minPriceBox
	self.maxPriceBox = maxPriceBox

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

	local priceRangeLabel = parent:GetNamedChild("PriceRangeLabel")
	local resetButton = CreateControlFromVirtual(name .. "ResetButton", parent, "ZO_DefaultButton")
	resetButton:SetNormalTexture(RESET_BUTTON_TEXTURE:format("up"))
	resetButton:SetPressedTexture(RESET_BUTTON_TEXTURE:format("down"))
	resetButton:SetMouseOverTexture(RESET_BUTTON_TEXTURE:format("over"))
	resetButton:SetEndCapWidth(0)
	resetButton:SetDimensions(RESET_BUTTON_SIZE, RESET_BUTTON_SIZE)
	resetButton:SetAnchor(TOPRIGHT, priceRangeLabel, TOPLEFT, 196, 0)
	resetButton:SetHidden(true)
	resetButton:SetHandler("OnMouseUp",function(control, button, isInside)
		if(button == 1 and isInside) then
			selector:Reset()
		end
	end)
	local text = L["RESET_FILTER_LABEL_TEMPLATE"]:format(priceRangeLabel:GetText():gsub(":", ""))
	resetButton:SetHandler("OnMouseEnter", function()
		InitializeTooltip(InformationTooltip)
		InformationTooltip:ClearAnchors()
		InformationTooltip:SetOwner(resetButton, BOTTOM, 5, 0)
		SetTooltipText(InformationTooltip, text)
	end)
	resetButton:SetHandler("OnMouseExit", function()
		ClearTooltip(InformationTooltip)
	end)
	selector.resetButton = resetButton

	UpdateTextBoxFromSlider()

	return selector
end

function PriceSelector:Reset()
	self.slider:SetMinMax(MIN_VALUE, MAX_VALUE)
	zo_callLater(function()
		self.slider:SetRangeValue(MIN_VALUE, MAX_VALUE)
	end, 1)
end

function PriceSelector:IsDefault()
	local min, max = self.slider:GetRangeValue()
	return (min == MIN_VALUE and max == MAX_VALUE)
end

function PriceSelector:Serialize()
	local min = tonumber(self.minPriceBox:GetText()) or "-"
	local max = tonumber(self.maxPriceBox:GetText()) or "-"
	return min .. ";" .. max
end

function PriceSelector:Deserialize(state)
	local min, max = zo_strsplit(";", state)
	min = tonumber(min) or LOWER_LIMIT
	max = tonumber(max) or UPPER_LIMIT
	self.minPriceBox:SetText(min <= LOWER_LIMIT and "" or min)
	self.maxPriceBox:SetText(max >= UPPER_LIMIT and "" or max)
end
