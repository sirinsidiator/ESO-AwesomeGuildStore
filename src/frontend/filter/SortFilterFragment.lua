local AGS = AwesomeGuildStore

local FilterFragment = AGS.class.FilterFragment

local SortFilterFragment = FilterFragment:Subclass()
AGS.class.SortFilterFragment = SortFilterFragment

function SortFilterFragment:New(...)
    return FilterFragment.New(self, ...)
end

function SortFilterFragment:Initialize(filterId)
    FilterFragment.Initialize(self, filterId)

    self.sortOrderCount = 0
    self:InitializeControls()
    self:InitializeHandlers()
end

function SortFilterFragment:InitializeControls()
    local container = self:GetContainer()

    local combobox = CreateControlFromVirtual("$(parent)Dropdown", container, "ZO_ScrollableComboBox")
    local dropdown = ZO_ComboBox_ObjectFromContainer(combobox)
    combobox:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 4)
    combobox:SetAnchor(TOPRIGHT, container, TOPRIGHT, 0, 4)
    -- TODO: create a SimpleDropdownBox

    self.combobox = combobox
    self.dropdown = dropdown
end

function SortFilterFragment:InitializeHandlers()
    local dropdown = self.dropdown
    local fromCallback = false

    -- handle dropdown opening/closing so that the menu is not rendered as part of the filter area
    ZO_PreHook(dropdown, "ShowDropdownOnMouseUp", function() return self:OnShow() end)
    ZO_PreHook(dropdown, "HideDropdownInternal", function() return self:OnHide() end)
    self.combobox:SetHandler("OnEffectivelyHidden", function() return self:DoHide() end)

    local function OnInputChanged(sortOrder)
        if(fromCallback) then return end
        self.filter:SetCurrentSortOrder(sortOrder:GetId())
    end

    local function OnFilterChanged(self, sortOrder)
        fromCallback = true
        dropdown:SetSelectedItemText(sortOrder:GetLabel())
        fromCallback = false
    end

    dropdown.OnValueChanged = OnInputChanged
    self.OnValueChanged = OnFilterChanged
end

function SortFilterFragment:OnShow()
    local dropdown = self.dropdown
    if dropdown.m_lastParent ~= ZO_Menus then
        local newCount = self.filter:GetSortOrderCount()
        if(newCount ~= self.sortOrderCount) then
            self.sortOrderCount = newCount
            self:UpdateAvailableSortOrders()
        end
        dropdown.m_lastParent = dropdown.m_dropdown:GetParent()
        dropdown.m_dropdown:SetParent(ZO_Menus)
        ZO_Menus:BringWindowToTop()
    end
end

function SortFilterFragment:OnHide()
    local dropdown = self.dropdown
    if dropdown.m_lastParent then 
        dropdown.m_dropdown:SetParent(dropdown.m_lastParent)
        dropdown.m_lastParent = nil
    end
end

function SortFilterFragment:DoHide()
    local dropdown = self.dropdown
    if dropdown:IsDropdownVisible() then
        dropdown:HideDropdown()
    end
end

function SortFilterFragment:UpdateAvailableSortOrders()
    local dropdown = self.dropdown
    local filter = self.filter

    dropdown:ClearItems()

    local available = filter:GetAvailableSortOrders()
    for id, sortOrder in pairs(available) do
        dropdown:AddItem(ZO_ComboBox:CreateItemEntry(sortOrder:GetLabel(), function() dropdown.OnValueChanged(sortOrder) end), ZO_COMBOBOX_SUPRESS_UPDATE)
    end

    dropdown:UpdateItems()
    self:OnValueChanged(filter:GetCurrentSortOrder())
end

function SortFilterFragment:OnAttach(filterArea)
--    local editGroup = filterArea:GetEditGroup()
--    editGroup:InsertControl(self.input) -- TODO: make it tab-able and use arrow keys to quickly switch selection
end

function SortFilterFragment:OnDetach(filterArea)
--    local editGroup = filterArea:GetEditGroup()
--    editGroup:RemoveControl(self.input)
end

function SortFilterFragment:SetEnabled(enabled)
    FilterFragment.SetEnabled(self, enabled)
    self.dropdown:SetEnabled(enabled)
end
