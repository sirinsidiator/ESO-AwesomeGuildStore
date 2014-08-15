local LevelSelector = ZO_Object:Subclass()
AwesomeGuildStore.LevelSelector = LevelSelector

local MinMaxRangeSlider = AwesomeGuildStore.MinMaxRangeSlider

function LevelSelector:New(parent, name)
	local selector = ZO_Object.New(self)

	local setFromTextBox = false
	local minLevelBox = parent:GetNamedChild("MinLevelBox")
	local maxLevelBox = parent:GetNamedChild("MaxLevelBox")
	local slider = MinMaxRangeSlider:New(parent, name .. "LevelSlider", 0, 0, 195, 16)
	slider:SetMinMax(1, 50)
	slider:SetMinRange(1)
	slider:SetRangeValue(1, 50)
	selector.slider = slider

	slider.OnValueChanged = function(self, min, max)
		if(setFromTextBox) then return end
		minLevelBox:SetText(min)
		maxLevelBox:SetText(max)
	end

	local function UpdateSliderFromTextBox()
		setFromTextBox = true
		local oldMin, oldMax = slider:GetRangeValue()
		local min = tonumber(minLevelBox:GetText()) or oldMin
		local max = tonumber(maxLevelBox:GetText()) or oldMax

		slider:SetRangeValue(min, max)
		setFromTextBox = false
	end

	local function UpdateTextBoxFromSlider()
		local min, max = slider:GetRangeValue()
		minLevelBox:SetText(min)
		maxLevelBox:SetText(max)
	end

	minLevelBox:SetHandler("OnTextChanged", UpdateSliderFromTextBox)
	maxLevelBox:SetHandler("OnTextChanged", UpdateSliderFromTextBox)
	minLevelBox:SetHandler("OnFocusLost", UpdateTextBoxFromSlider)
	maxLevelBox:SetHandler("OnFocusLost", UpdateTextBoxFromSlider)
	UpdateTextBoxFromSlider()

	ZO_PreHook(TRADING_HOUSE, "ToggleLevelRangeMode", function(self)
		if(self.m_levelRangeFilterType == TRADING_HOUSE_FILTER_TYPE_LEVEL) then
			slider:SetMinMax(1, 12)
		else
			slider:SetMinMax(1, 50)
		end
	end)

	return selector
end

function LevelSelector:Reset()
	self.slider:SetMinMax(1, 50)
	zo_callLater(function()
		self.slider:SetRangeValue(1, 50)
	end, 1)
end
