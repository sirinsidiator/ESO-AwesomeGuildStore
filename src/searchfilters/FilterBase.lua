local gettext = LibStub("LibGetText")("AwesomeGuildStore").gettext
local SimpleIconButton = AwesomeGuildStore.SimpleIconButton
local ClearCallLater = AwesomeGuildStore.ClearCallLater

local FilterBase = ZO_Object:Subclass()
AwesomeGuildStore.FilterBase = FilterBase

local LOCAL_FILTER_COLOR = ZO_ColorDef:New("A5D0FF")
local EXTERNAL_FILTER_COLOR = ZO_ColorDef:New("FFA5A5")

local EXTERNAL_FILTER_PROVIDER = {
    [100] = "Master Merchant",
    [101] = "Master Merchant",
    [102] = "CookeryWiz",
    [103] = "WritWorthy",
}

function FilterBase:New(type, name, tradingHouseWrapper, ...)
    local filter = ZO_Object.New(self)
    filter:InitializeBase(type, name)
    filter:Initialize(name, tradingHouseWrapper, ...)
    return filter
end

function FilterBase:GetType()
    return self.type
end

function FilterBase:InitializeBase(type, name)
    self.isLocal = true -- set to false if it is not a local filter
    self.type = type
    self.priority = 0
    self.callbackName = name .. "Changed"
    self.isAttached = false
    self.isActive = false

    self.fragment = AwesomeGuildStore.class.FilterFragment:New(self) -- TODO
    local container = self.fragment:GetContainer()
    self.container = container
end

function FilterBase:SetSearchManager(searchManager)
    self.searchManager = searchManager
end

function FilterBase:GetFragment()
    return self.fragment
end

function FilterBase:InitializeProvider()
    if(self.color) then return end
    self.priority = 3
    if(self.isLocal) then
        self.priority = 2
    end
    self.provider = EXTERNAL_FILTER_PROVIDER[self.type]
    if(self.provider) then
        self.priority = self.priority - 1
        self.color = EXTERNAL_FILTER_COLOR
    else
        self.color = LOCAL_FILTER_COLOR
    end
end

function FilterBase:SetLabel(label)
    self.fragment:SetLabelText(label)
    self.label = label
end

function FilterBase:GetLabel()
    return self.label
end

function FilterBase:SetResetHidden(hidden)
    self.fragment:SetResetHidden(hidden)
end

function FilterBase:SetLabelControl(label)
    self:InitializeProvider()
    label:ClearAnchors()
    if(self.isLocal) then
        label:SetColor(self.color:UnpackRGBA())
        label:SetMouseEnabled(true)
        label:SetHandler("OnMouseEnter", function()
            InitializeTooltip(InformationTooltip)
            InformationTooltip:ClearAnchors()
            InformationTooltip:SetOwner(label, BOTTOM, 5, 0)
            -- TRANSLATORS: tooltip text explaining the type of a filter in the left panel on the search tab
            local text = gettext("This filter is local and only applies to the currently visible page")
            if(self.provider) then
                -- TRANSLATORS: tooltip text explaining the type of a filter in the left panel on the search tab. <<1>> is replaced with an addon name
                text = string.format("%s\n\n%s", text, EXTERNAL_FILTER_COLOR:Colorize(gettext("This filter is provided by <<1>>", self.provider)))
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

function FilterBase:HandleChange()
    if(self.searchManager) then
        self.searchManager:RequestFilterUpdate()
    end
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

function FilterBase:GetControl()
    return self.container
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

function FilterBase:Attach()
    self:OnAttached()
    self.isAttached = true
end

function FilterBase:Detach()
    self:OnDetached()
    self.isAttached = false
end

function FilterBase:OnAttached()
-- can be used for setup up when the filter is added to the panel
end

function FilterBase:OnDetached()
-- can be used for cleaning up when the filter is removed from the panel
end

function FilterBase:IsAttached()
    return self.isAttached
end

function FilterBase:CanAttach()
    return true -- TODO check which category and subcategory is active
end

function FilterBase:SetActive(active)
    self.isActive = active
end

function FilterBase:IsActive()
    return self.isActive
end
