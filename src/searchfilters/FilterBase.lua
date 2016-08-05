local L = AwesomeGuildStore.Localization
local SimpleIconButton = AwesomeGuildStore.SimpleIconButton

local FilterBase = ZO_Object:Subclass()
AwesomeGuildStore.FilterBase = FilterBase

local RESET_BUTTON_SIZE = 18
local RESET_BUTTON_TEXTURE = "EsoUI/Art/Buttons/decline_%s.dds"

function FilterBase:New(type, name, tradingHouseWrapper, ...)
    local filter = ZO_Object.New(self)
    filter:InitializeBase(type, name)
    filter:Initialize(name, tradingHouseWrapper, ...)
    return filter
end

function FilterBase:InitializeBase(type, name)
    self.isLocal = true -- set to false if it is not a local filter
    self.type = type
    self.callbackName = name .. "Changed"

    local container = WINDOW_MANAGER:CreateControl(name .. "Container", GuiRoot, CT_CONTROL)
    self.container = container

    local resetButton = SimpleIconButton:New(name .. "ResetButton", RESET_BUTTON_TEXTURE, RESET_BUTTON_SIZE)
    resetButton:SetAnchor(TOPRIGHT, container, TOPRIGHT, 0, 0)
    resetButton:SetHidden(true)
    resetButton.OnClick = function(control, mouseButton, ctrl, alt, shift)
        if(mouseButton == 1) then
            self:Reset()
        end
    end
    self.resetButton = resetButton
end

local localFilterLabelColor = ZO_ColorDef:New("A5D0FF")
local externalFilterLabelColor = ZO_ColorDef:New("FFA5A5")
local externalFilters = {
    [100] = "Master Merchant",
    [101] = "Master Merchant",
    [102] = "CookeryWiz",
}
function FilterBase:SetLabelControl(label)
    label:ClearAnchors()
    label:SetAnchor(TOPLEFT, self.container, TOPLEFT, 0, 0)
    label:SetAnchor(TOPRIGHT, self.container, TOPLRIGHT, -RESET_BUTTON_SIZE, 0)
    if(self.isLocal) then
        local provider = externalFilters[self.type]
        if(provider) then
            label:SetColor(externalFilterLabelColor:UnpackRGBA())
        else
            label:SetColor(localFilterLabelColor:UnpackRGBA())
        end
        label:SetMouseEnabled(true)
        label:SetHandler("OnMouseEnter", function()
            InitializeTooltip(InformationTooltip)
            InformationTooltip:ClearAnchors()
            InformationTooltip:SetOwner(label, BOTTOM, 5, 0)
            local text = L["LOCAL_FILTER_EXPLANATION_TOOLTIP"]
            if(provider) then
                text = string.format("%s\n\n%s", text, externalFilterLabelColor:Colorize(zo_strformat(L["EXTERNAL_FILTER_EXPLANATION_TOOLTIP"], provider)))
            end
            SetTooltipText(InformationTooltip, text)
        end)
        label:SetHandler("OnMouseExit", function()
            ClearTooltip(InformationTooltip)
        end)
    end
    self.label = label
end

-- the following functions are placeholders and can be overwritten
function FilterBase:Initialize(name, tradingHouseWrapper)
end

local function ClearCallLater(id)
    EVENT_MANAGER:UnregisterForUpdate("CallLaterFunction"..id)
end

function FilterBase:HandleChange()
    if(self.fireChangeCallback) then
        ClearCallLater(self.fireChangeCallback)
    end
    self.fireChangeCallback = zo_callLater(function()
        self.fireChangeCallback = nil
        CALLBACK_MANAGER:FireCallbacks(self.callbackName, self)
    end, 250)
    self.resetButton:SetHidden(self:IsDefault())
end

-- these functions are used by the search tab wrapper
function FilterBase:SetParent(parent)
    self.container:SetParent(parent)
end

function FilterBase:SetWidth(width)
    self.container:SetWidth(width)
end

function FilterBase:SetHidden(hidden)
    self.container:SetHidden(hidden)
end

-- the following functions are used for filtering items on a result page and should be overwritten where necessary

function FilterBase:BeforeRebuildSearchResultsPage(tradingHouseWrapper)
    return false
        --	return true when the filter actually has work to do
end

function FilterBase:FilterPageResult(index, icon, name, quality, stackCount, sellerName, timeRemaining, purchasePrice)
    return true -- if the item is visible
        -- the filtering will stop on the first filter that returns false and just hide the item then
end

function FilterBase:AfterRebuildSearchResultsPage(tradingHouseWrapper)
-- can be used for cleaning up
end

-- these functions are used by the reset button
function FilterBase:Reset()
end

function FilterBase:IsDefault()
end

-- these functions are used by the search history
function FilterBase:Serialize()
    return ""
end

function FilterBase:Deserialize(state)
end

function FilterBase:GetTooltipText(state)
    return {}
end
