local gettext = LibStub("LibGetText")("AwesomeGuildStore").gettext

local FilterFragment = ZO_SimpleSceneFragment:Subclass()
AwesomeGuildStore.class.FilterFragment = FilterFragment

function FilterFragment:New(...)
    return ZO_SimpleSceneFragment.New(self, ...)
end

function FilterFragment:Initialize(filter)
    self.filter = filter
    local control = CreateControlFromVirtual("AwesomeGuildStoreFilterFragment", GuiRoot, "AwesomeGuildStoreFilterFragmentTemplate", filter:GetId())
    control.fragment = self
    ZO_SimpleSceneFragment.Initialize(self, control)
    self.label = self:SetupChildControl("Label")
    self.reset = self:SetupChildControl("Reset")
    self.content = self:SetupChildControl("Content")
    self.attached = false

    self:SetLabelText(filter:GetLabel())

    AwesomeGuildStore:RegisterCallback("FilterValueChanged", function(id, ...)
        if(id ~= self.filter:GetId()) then return end
        self:OnValueChanged(...)
        self.reset:SetHidden(self.filter:IsDefault())
    end)
end

function FilterFragment:OnValueChanged(...)
-- this function is called when the backend broadcasts a change and should be overwritten
end

function FilterFragment:SetupChildControl(name)
    local child = self.control:GetNamedChild(name)
    child.fragment = self
    return child
end

function FilterFragment:GetId() -- TODO
    return self.filter.id
end

function FilterFragment:Attach(filterArea)
    self:OnAttach(filterArea)
    self.attached = true
end

function FilterFragment:Detach(filterArea)
    self:OnDetach(filterArea)
    self.attached = false
end

function FilterFragment:OnAttach(filterArea)
end

function FilterFragment:OnDetach(filterArea)
end

function FilterFragment:IsAttached()
    return self.attached
end

function FilterFragment:SetLabelText(text)
    self.label:SetText(text .. ":")

    -- TRANSLATORS: tooltip text for the reset filter buttons. will automatically insert the filter title (e.g. "Reset Weapon Type Filter")
    local tooltipText = gettext("Reset <<1>> Filter", text)

    self.reset:SetHandler("OnMouseEnter", function()
        InitializeTooltip(InformationTooltip, self.reset, BOTTOM, 5, 0)
        SetTooltipText(InformationTooltip, tooltipText)
    end)

    self.reset:SetHandler("OnMouseExit", function()
        ClearTooltip(InformationTooltip)
    end)
end

function FilterFragment:SetResetHidden(hidden)
    self.reset:SetHidden(hidden)
end

function FilterFragment:GetContainer()
    return self.content
end

function FilterFragment:Reset()
    self.filter:Reset()
end

function FilterFragment:IsDefault()
    return self.filter:IsDefault()
end

function FilterFragment:ShowMenu()
    if(false) then -- disabled for now
        ClearMenu()
        if(self.filter:IsPinned()) then
            -- TRANSLATORS: menu text for unpinning a filter from the filter area
            AddCustomMenuItem(gettext("Unpin Filter"), function()
                self.filter:SetPinned(false)
            end)
        else
            -- TRANSLATORS: menu text for removing a filter from the filter area
            AddCustomMenuItem(gettext("Remove Filter"), function()
                local activeSearch = self.filter.searchManager:GetActiveSearch() -- TODO
                activeSearch:SetFilterActive(self.filter, false)
            end)
            -- TRANSLATORS: menu text for pinning a filter to the filter area
            AddCustomMenuItem(gettext("Pin Filter"), function()
                self.filter:SetPinned(true)
            end)
        end
        ShowMenu()
    end
end