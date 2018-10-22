local gettext = LibStub("LibGetText")("AwesomeGuildStore").gettext
local MinMaxRangeSlider = AwesomeGuildStore.MinMaxRangeSlider
local SimpleIconButton = AwesomeGuildStore.SimpleIconButton
local FilterBase = AwesomeGuildStore.FilterBase

local QualityFilter = FilterBase:Subclass()
AwesomeGuildStore.QualityFilter = QualityFilter

local BUTTON_SIZE = 36
local BUTTON_PADDING = 14
local BUTTON_OFFSET_Y = 12
local BUTTON_FOLDER = "AwesomeGuildStore/images/qualitybuttons/"
local MOUSE_LEFT = 1
local MOUSE_RIGHT = 2
local MOUSE_MIDDLE = 3
local MIN_QUALITY = 1
local MAX_QUALITY = 5
local QUALITY_LABEL = {
    GetString(SI_TRADING_HOUSE_BROWSE_QUALITY_NORMAL),
    GetString(SI_TRADING_HOUSE_BROWSE_QUALITY_MAGIC),
    GetString(SI_TRADING_HOUSE_BROWSE_QUALITY_ARCANE),
    GetString(SI_TRADING_HOUSE_BROWSE_QUALITY_ARTIFACT),
    GetString(SI_TRADING_HOUSE_BROWSE_QUALITY_LEGENDARY)
}
local LINE_SPACING = 4
local QUALITY_FILTER_TYPE_ID = 4

function QualityFilter:New(name, tradingHouseWrapper, ...)
    return FilterBase.New(self, QUALITY_FILTER_TYPE_ID, name, tradingHouseWrapper, ...)
end

function QualityFilter:Initialize(name, tradingHouseWrapper)
    self.isLocal = false
    self:InitializeControls(name, tradingHouseWrapper.tradingHouse, tradingHouseWrapper.saveData)
    self:InitializeHandlers(tradingHouseWrapper.tradingHouse)
end

function QualityFilter:InitializeControls(name, tradingHouse, saveData)
    local container = self.container

    -- hide the original filter
    tradingHouse.m_browseItems:GetNamedChild("Common"):GetNamedChild("Quality"):SetHidden(true)

    -- TRANSLATORS: title of the quality range filter in the left panel on the search tab
    self:SetLabel(gettext("Quality Range"))

    local slider = MinMaxRangeSlider:New("$(parent)Slider", container)
    slider:SetMinMax(MIN_QUALITY, MAX_QUALITY)
    slider:SetRangeValue(MIN_QUALITY, MAX_QUALITY)
    slider.control:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
    slider.control:SetAnchor(TOPRIGHT, container, TOPRIGHT, 0, 0)
    slider:UpdateVisuals()
    self.slider = slider

    local function SafeSetRangeValue(button, value)
        local min, max = slider:GetRangeValue()
        if(button == MOUSE_LEFT) then
            if(value > max) then slider:SetMaxValue(value) end
            slider:SetMinValue(value)
        elseif(button == MOUSE_RIGHT) then
            if(value < min) then slider:SetMinValue(value) end
            slider:SetMaxValue(value)
        elseif(button == MOUSE_MIDDLE) then
            slider:SetRangeValue(value, value)
        end
    end

    local width = container:GetWidth()
    local function CreateButtonControl(name, textureName, value)
        local button = SimpleIconButton:New(name, BUTTON_FOLDER .. textureName, BUTTON_SIZE, QUALITY_LABEL[value], container)
        button:SetMouseOverTexture(BUTTON_FOLDER .. "over.dds") -- we reuse the texture as it is the same for all quality buttons
        button.control:SetHandler("OnMouseDoubleClick", function(control, button)
            SafeSetRangeValue(MOUSE_MIDDLE, value)
        end)
        button.OnClick = function(self, mouseButton, ctrl, alt, shift)
            local oldBehavior = saveData.oldQualitySelectorBehavior
            local setBoth = (oldBehavior and shift) or (not oldBehavior and not shift)
            if(setBoth) then
                SafeSetRangeValue(MOUSE_MIDDLE, value)
            else
                SafeSetRangeValue(mouseButton, value)
            end
            return true
        end
        local spacing = (width + BUTTON_PADDING) / MAX_QUALITY
        button:SetAnchor(TOPLEFT, slider.control, TOPLEFT, spacing * (value - 1), LINE_SPACING + BUTTON_OFFSET_Y)
        return button
    end

    self.buttons = {}
    self.buttons[1] = CreateButtonControl("$(parent)NormalQualityButton", "normal_%s.dds", 1)
    self.buttons[2] = CreateButtonControl("$(parent)MagicQualityButton", "magic_%s.dds", 2)
    self.buttons[3] = CreateButtonControl("$(parent)ArcaneQualityButton", "arcane_%s.dds", 3)
    self.buttons[4] = CreateButtonControl("$(parent)ArtifactQualityButton", "artifact_%s.dds", 4)
    self.buttons[5] = CreateButtonControl("$(parent)LegendaryQualityButton", "legendary_%s.dds", 5)
end

function QualityFilter:InitializeHandlers(tradingHouse)
    local slider = self.slider

    slider.OnValueChanged = function(slider, min, max)
        self:HandleChange()
    end

--    ZO_PreHook(TRADING_HOUSE.m_search, "InternalExecuteSearch", function(self)
--        local min, max = slider:GetRangeValue()
--        if min == MIN_QUALITY then min = ITEM_QUALITY_TRASH end
--        self.m_filters[TRADING_HOUSE_FILTER_TYPE_QUALITY].values = {min, max}
--    end)
end

function QualityFilter:BeforeRebuildSearchResultsPage(tradingHouseWrapper)
    local min, max = self.slider:GetRangeValue()

    if(min == MIN_QUALITY and max == "") then
        self.min, self.max = nil, nil
        return false
    end

    if min == MIN_QUALITY then min = ITEM_QUALITY_TRASH end
    self.min, self.max = min, max

    return true
end

function QualityFilter:FilterPageResult(index, icon, name, quality, stackCount, sellerName, timeRemaining, purchasePrice)
    local itemLink = GetTradingHouseSearchResultItemLink(index)
    local quality = GetItemLinkQuality(itemLink)
    return not (quality < self.min or quality > self.max)
end

function QualityFilter:SetWidth(width)
    self.container:SetWidth(width)
    self.slider:UpdateVisuals()

    local buttons = self.buttons
    local sliderControl = self.slider.control
    local spacing = (width + BUTTON_PADDING) / MAX_QUALITY
    for i = 1, #buttons do
        buttons[i]:SetAnchor(TOPLEFT, sliderControl, TOPLEFT, spacing * (i - 1), LINE_SPACING + BUTTON_OFFSET_Y)
    end
end

function QualityFilter:Reset()
    self.slider:SetRangeValue(MIN_QUALITY, MAX_QUALITY)
end

function QualityFilter:IsDefault()
    local min, max = self.slider:GetRangeValue()
    return (min == MIN_QUALITY and max == MAX_QUALITY)
end

function QualityFilter:Serialize()
    local min, max = self.slider:GetRangeValue()
    return tostring(min) .. ";" .. tostring(max)
end

function QualityFilter:Deserialize(state)
    local min, max = zo_strsplit(";", state)
    assert(min and max)
    self.slider:SetRangeValue(tonumber(min), tonumber(max))
end

function QualityFilter:GetTooltipText(state)
    local minQuality, maxQuality = zo_strsplit(";", state)
    minQuality = tonumber(minQuality)
    maxQuality = tonumber(maxQuality)
    if(minQuality and maxQuality and not (minQuality == 1 and maxQuality == 5)) then
        local text = ""
        for i = minQuality, maxQuality do
            local color = GetItemQualityColor(i)
            text = text .. color:Colorize(QUALITY_LABEL[i]) .. ", "
        end
        return {{label = self:GetLabel(), text = text:sub(0, -3)}}
    end
    return {}
end
