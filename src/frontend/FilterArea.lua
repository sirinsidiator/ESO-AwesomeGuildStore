local AGS = AwesomeGuildStore

local FILTER_ID = AGS.data.FILTER_ID

local FilterArea = ZO_Object:Subclass()
AGS.class.FilterArea = FilterArea

function FilterArea:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function FilterArea:Initialize(container, searchManager)
    self.searchManager = searchManager
    self.availableFragments = {}
    self.attachedFragments = {}
    self.scene = TRADING_HOUSE_SCENE

    local filterArea = CreateControlFromVirtual("AwesomeGuildStoreFilterArea", container, "ZO_ScrollContainer")
    filterArea:ClearAnchors()
    filterArea:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
    filterArea:SetAnchor(BOTTOMRIGHT, container, BOTTOMRIGHT, 16, 0) -- have to account for the 16px of the scroll bar
    self.filterArea = filterArea

    local filterAreaScrollChild = filterArea:GetNamedChild("ScrollChild")
    self.filterAreaScrollChild = filterAreaScrollChild

    local addFilterButton = CreateControlFromVirtual("AwesomeGuildStoreAddFilterButton", filterAreaScrollChild, "ZO_DefaultButton")
    addFilterButton:SetWidth(250)
    addFilterButton:SetText("Add Filter")
    addFilterButton:SetHandler("OnMouseUp",function(control, button, isInside)
        if(control:GetState() == BSTATE_NORMAL and button == MOUSE_BUTTON_INDEX_LEFT and isInside) then
            self:ShowFilterSelection()
        end
    end)
    self.addFilterButton = addFilterButton

    self.editControlGroup = AGS.class.EditControlGroup:New()
end

function FilterArea:OnFiltersInitialized()
    AGS:RegisterCallback(AGS.callback.FILTER_VALUE_CHANGED, function(id)
        if(id ~= FILTER_ID.CATEGORY_FILTER) then return end
        self:UpdateDisplayedFilters()
    end)
    AGS:RegisterCallback(AGS.callback.FILTER_ACTIVE_CHANGED, function(filter)
        self:UpdateDisplayedFilters()
    end)
    AGS:RegisterCallback(AGS.callback.SEARCH_LOCK_STATE_CHANGED, function(search, isActiveSearch)
        if(not isActiveSearch) then return end
        self:UpdateDisplayedFilters()
    end)
    AGS:RegisterCallback(AGS.callback.SELECTED_SEARCH_CHANGED, function(search)
        self:UpdateDisplayedFilters()
    end)
    self:UpdateDisplayedFilters()
end

function FilterArea:GetEditGroup()
    return self.editControlGroup
end

function FilterArea:RegisterFilterFragment(fragment)
    self.availableFragments[fragment:GetId()] = fragment
end

function FilterArea:AttachFilterFragment(fragment)
    self.scene:AddFragment(fragment)
    fragment.control:SetParent(self.filterAreaScrollChild)
    self.attachedFragments[#self.attachedFragments + 1] = fragment

    self:UpdateFilterAnchors()

    fragment:Attach(self)
    self:UpdateAddFilterButton()
end

function FilterArea:DetachFilterFragment(fragment)
    self.scene:RemoveFragment(fragment)
    fragment.control:ClearAnchors()

    local index
    for i = 1, #self.attachedFragments do
        if(self.attachedFragments[i] == fragment) then
            index = i
            break
        end
    end

    table.remove(self.attachedFragments, index)

    self:UpdateFilterAnchors()

    fragment:Detach(self)
    self:UpdateAddFilterButton()
end

local function ByFilterId(a, b)
    return a.filter.id < b.filter.id
end

function FilterArea:UpdateFilterAnchors()
    local attachedFragments = self.attachedFragments
    if(#attachedFragments == 0) then return end

    for i = 1, #attachedFragments do
        attachedFragments[i].control:ClearAnchors()
    end

    table.sort(self.attachedFragments, ByFilterId)

    local previous = attachedFragments[1].control
    previous:SetAnchor(TOPLEFT, self.filterAreaScrollChild, TOPLEFT)
    for i = 2, #attachedFragments do
        attachedFragments[i].control:SetAnchor(TOPLEFT, previous, BOTTOMLEFT, 0, 10)
        previous = attachedFragments[i].control 
    end
end

function FilterArea:UpdateAddFilterButton()
    local button = self.addFilterButton
    if(self:HasFiltersToAttach()) then
        button:ClearAnchors()
        if(#self.attachedFragments > 0) then
            button:SetAnchor(TOPLEFT, self.attachedFragments[#self.attachedFragments].control, BOTTOMLEFT, 0, 10)
        else
            button:SetAnchor(TOPLEFT, self.filterAreaScrollChild, TOPLEFT)
        end
        button:SetHidden(false)
    else
        button:SetHidden(true)
    end
end

function FilterArea:HasFiltersToAttach()
    local _, subcategory = self.searchManager:GetCurrentCategories()
    for id, fragment in pairs(self.availableFragments) do
        local filter = self.searchManager:GetFilter(id)
        if(filter and not fragment:IsAttached() and filter:CanFilter(subcategory)) then
            return true
        end
    end
    return false
end

function FilterArea:GetSortedFilters()
    -- TODO: create new base class for filters which can also be used for SortOrder and CategorySelector (or maybe just exclude these two since they are special?)
    local _, subcategory = self.searchManager:GetCurrentCategories()
    local filters = {} -- TODO create GetSortedFilters in searchManager
    for id, fragment in pairs(self.availableFragments) do
        local filter = self.searchManager:GetFilter(id)
        if(filter and not fragment:IsAttached() and filter:CanFilter(subcategory)) then
            filters[#filters + 1] = filter
        end
    end
   -- table.sort(filters, SortByFilterPriority) -- TODO move to searchManager and only do once after registerFilter was called
    return filters
end

function FilterArea:ShowFilterSelection()
    ClearMenu()
    local filters = self:GetSortedFilters()
    for i = 1, #filters do
        local filter = filters[i]
        AddCustomMenuItem(filter:GetLabel(), function()
            local activeSearch = self.searchManager:GetActiveSearch()
            activeSearch:SetFilterActive(filter, true)
        end)
    end
    ShowMenu()
end

function FilterArea:UpdateDisplayedFilters()
    local enabled = self.searchManager:GetActiveSearch():IsEnabled()
    for id, fragment in pairs(self.availableFragments) do
        local filter = self.searchManager:GetFilter(id)
        if(filter) then
            local filterAttached = filter:IsAttached()
            local fragementAttached = fragment:IsAttached()
            if(filterAttached and not fragementAttached) then
                self:AttachFilterFragment(fragment)
            elseif(not filterAttached and fragementAttached) then
                self:DetachFilterFragment(fragment)
            end

            if(filterAttached) then
                fragment:SetEnabled(enabled)
            end
        end
    end
end
