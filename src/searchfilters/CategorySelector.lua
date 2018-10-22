local gettext = LibStub("LibGetText")("AwesomeGuildStore").gettext
local FILTER_PRESETS = AwesomeGuildStore.FILTER_PRESETS
local SUBFILTER_PRESETS = AwesomeGuildStore.SUBFILTER_PRESETS

local MAJOR_BUTTON_SIZE = 46
local MINOR_BUTTON_SIZE = 32
local RESET_BUTTON_SIZE = 18
local RESET_BUTTON_TEXTURE = "EsoUI/Art/Buttons/decline_%s.dds"
local MOUSE_LEFT = 1

local RegisterForEvent = AwesomeGuildStore.RegisterForEvent
local ButtonGroup = AwesomeGuildStore.ButtonGroup
local ToggleButton = AwesomeGuildStore.ToggleButton
local SimpleIconButton = AwesomeGuildStore.SimpleIconButton
local CategorySubfilter = AwesomeGuildStore.CategorySubfilter

local CategorySelector = ZO_Object:Subclass()
AwesomeGuildStore.CategorySelector = CategorySelector

function CategorySelector:New(parent, name, searchTabWrapper, tradingHouseWrapper)
    local selector = ZO_Object.New(self)
    selector.callbackName = name .. "Changed"
    selector.type = 1
    selector.searchTabWrapper = searchTabWrapper

    parent:GetNamedChild("ItemCategory"):SetHidden(true)

    local container = parent:CreateControl(name .. "Container", CT_CONTROL)
    container:SetAnchor(TOPLEFT, parent:GetNamedChild("Header"), TOPRIGHT, 70, -10)
    container:SetResizeToFitDescendents(true)
    ZO_TradingHouseItemPane:SetAnchor(TOPLEFT, container, BOTTOMLEFT, -50, 20)

    selector.control = container
    selector.group = {}
    selector.subfilters = {}
    selector.category = ITEMFILTERTYPE_ALL
    selector.subcategory = {}

    local group = ButtonGroup:New(container, name .. "MainGroup", 0, 0)
    local label = group.control:CreateControl(name .. "Label", CT_LABEL)
    label:SetFont("ZoFontWinH4")
    label:SetModifyTextType(MODIFY_TEXT_TYPE_UPPERCASE)
    label:SetAnchor(TOPLEFT, group.control, TOPLEFT, 0, 13)
    group.label = label

    local divider = group.control:CreateControl(name .. "Divider", CT_TEXTURE)
    divider:SetDimensions(600, 4)
    divider:SetTexture("EsoUI/Art/Miscellaneous/centerscreen_topDivider.dds")
    divider:SetAnchor(TOPCENTER, group.control, TOPCENTER, 0, MAJOR_BUTTON_SIZE + 2)

    selector.mainGroup = group

    for category, preset in pairs(FILTER_PRESETS) do
        selector:CreateCategoryButton(group, category, preset)
        selector:CreateSubcategory(name, category, preset)
    end

    for subfilterId, preset in pairs(SUBFILTER_PRESETS) do
        -- TODO: this needs to disappear together with the presets
        -- instead we should instantiate and configure the filters directly
        if(preset.buttons or preset.class) then
            if(type(preset.class) == "string") then preset.class = AwesomeGuildStore[preset.class] end
            local class = preset.class or CategorySubfilter
            local subfilter = class:New(name .. "Subfilter" .. subfilterId, tradingHouseWrapper, preset)
            CALLBACK_MANAGER:RegisterCallback(subfilter.callbackName, function()
                selector:HandleChange()
            end)
            selector.subfilters[subfilterId] = subfilter
            searchTabWrapper.searchManager:RegisterFilter(subfilter)
        end
    end

    local function GetCurrentFilters()
        local filters = FILTER_PRESETS[selector.category].subcategories
        local subfilters
        local showTabards = false
        local subcategory = selector.subcategory[selector.category]
        if(subcategory) then
            if(filters[subcategory].showTabards) then showTabards = true end
            subfilters = filters[subcategory].subfilters
            filters = filters[subcategory].filters
        end
        return filters, subfilters, showTabards
    end

--    ZO_PreHook(TRADING_HOUSE.m_search, "InternalExecuteSearch", function(self)
--        local filters, subfilters, showTabards = GetCurrentFilters()
--        local filterArray = self.m_filters
--
--        for type, filterValues in pairs(filters) do
--            filterArray[type].values = ZO_ShallowTableCopy(filterValues) -- we have to copy them, otherwise they will be cleared on the next search
--        end
--
--        if(subfilters) then
--            for _, subfilterId in ipairs(subfilters) do
--                local subfilter = selector.subfilters[subfilterId]
--                if(subfilter) then
--                    subfilter:ApplyFilterValues(filterArray)
--                end
--            end
--        end
--    end)

    return selector
end

function CategorySelector:SetSearchManager(searchManager)
    self.searchManager = searchManager
end

function CategorySelector:UpdateSubfilterVisibility()
    local categoryPreset = FILTER_PRESETS[self.category]
    local subcategoryPreset, subfilters
    local subcategory = self.subcategory[self.category]
    if(subcategory) then
        subcategoryPreset = categoryPreset.subcategories[subcategory]
        subfilters = subcategoryPreset.subfilters
    end

    local searchTab = self.searchTabWrapper
    if(searchTab.levelFilter) then
        searchTab:DetachFilter(searchTab.levelFilter)
        if(categoryPreset.hasLevelFilter or (subcategoryPreset and subcategoryPreset.hasLevelFilter)) then
            searchTab:AttachFilter(searchTab.levelFilter)
        end
    end

    for _, subfilter in pairs(self.subfilters) do
        searchTab:DetachFilter(subfilter)
    end
    if(subfilters) then
        for _, subfilterId in ipairs(subfilters) do
            local subfilter = self.subfilters[subfilterId]
            if(subfilter) then
                searchTab:AttachFilter(subfilter)
            end
        end
    end
end

function CategorySelector:CreateSubcategory(name, category, categoryPreset)
    if(#categoryPreset.subcategories == 0) then return end
    local group = self:CreateSubcategoryGroup(name .. categoryPreset.name .. "Group", category)
    for subcategory, preset in pairs(categoryPreset.subcategories) do
        if(not preset.hidden) then
            self:CreateSubcategoryButton(group, subcategory, preset)
        end
    end
end

function CategorySelector:CreateCategoryButton(group, category, preset)
    local button = ToggleButton:New(group.control, group.control:GetName() .. preset.name .. "Button", preset.texture, 180 + MAJOR_BUTTON_SIZE * preset.index, 0, MAJOR_BUTTON_SIZE, MAJOR_BUTTON_SIZE, preset.label, SOUNDS.MENU_BAR_CLICK)
    button.HandlePress = function()
        group:ReleaseAllButtons()
        self.category = category
        group.label:SetText(preset.label)
        if(self.group[category]) then
            self.group[category].control:SetHidden(false)
        end
        self:UpdateSubfilterVisibility()
        self:HandleChange()
        return true
    end
    button.HandleRelease = function(control, fromGroup)
        local subCategoryGroup = self.group[category]
        if(subCategoryGroup) then
            if(fromGroup) then
                subCategoryGroup.control:SetHidden(true)
            else
                subCategoryGroup.defaultButton:Press()
            end
        end
        return fromGroup
    end
    button.value = category
    if(preset.isDefault) then
        group.defaultButton = button
        button:Press()
    end
    group:AddButton(button)
    return button
end

function CategorySelector:CreateSubcategoryGroup(name, category)
    local group = ButtonGroup:New(self.control, name, 0, MAJOR_BUTTON_SIZE + 4)
    group.category = category

    local label = group.control:CreateControl(name .. "Label", CT_LABEL)
    label:SetFont("ZoFontWinH5")
    label:SetModifyTextType(MODIFY_TEXT_TYPE_UPPERCASE)
    label:SetAnchor(TOPLEFT, group.control, TOPLEFT, 0, 7)
    group.label = label

    local divider = group.control:CreateControl(name .. "Divider", CT_TEXTURE)
    divider:SetDimensions(500, 3)
    divider:SetTexture("EsoUI/Art/Miscellaneous/centerscreen_topDivider.dds")
    divider:SetAnchor(TOPCENTER, group.control, TOPCENTER, 50, MINOR_BUTTON_SIZE + 2)

    self.group[category] = group
    group.control:SetHidden(true)
    return group
end

local function ShowGuildSpecificItems()
	TRADING_HOUSE.noSearchItemsContainer:SetHidden(true) -- hide the no items found message as we will show the tabard anyways
    TRADING_HOUSE:AddGuildSpecificItems(true) -- add the tabard whenever we change to the costume subcategory, because this function clears the search result
end

function CategorySelector:CreateSubcategoryButton(group, subcategory, preset)
    local button = ToggleButton:New(group.control, group.control:GetName() .. "SubcategoryButton" .. subcategory, preset.texture, 170 + MINOR_BUTTON_SIZE * (preset.index or subcategory), 0, MINOR_BUTTON_SIZE, MINOR_BUTTON_SIZE, preset.label, SOUNDS.MENU_BAR_CLICK)
    button.HandlePress = function()
        group:ReleaseAllButtons()
        group.label:SetText(preset.label)
        self.subcategory[group.category] = subcategory
        self:UpdateSubfilterVisibility()
        if(preset.showTabards) then
            ShowGuildSpecificItems()
        end
        self:HandleChange()
        return true
    end
    button.HandleRelease = function(control, fromGroup)
        if(not fromGroup and preset.showTabards) then
            ShowGuildSpecificItems()
        end
        return fromGroup
    end
    button.value = subcategory
    if(preset.isDefault) then
        group.defaultButton = button
        button:Press()
    end
    group:AddButton(button)
    return button
end

function CategorySelector:HandleChange()
    if(not self.fireChangeCallback) then
        self.fireChangeCallback = zo_callLater(function()
            self.fireChangeCallback = nil
            CALLBACK_MANAGER:FireCallbacks(self.callbackName, self)
        end, 100)
    end
end

function CategorySelector:Reset()
    self.mainGroup.defaultButton:Press()
    for _, group in pairs(self.group) do
        group.defaultButton:Press()
    end
    for _, subfilter in pairs(self.subfilters) do
        subfilter:Reset()
    end
end

function CategorySelector:IsDefault()
    return false
end

-- category[;subcategory[;(subfilterId,subfilterState)*]]
function CategorySelector:Serialize()
    local category = self.category
    local state = tostring(category)

    local subcategory = self.subcategory[category]
    if(subcategory) then
        state = state .. ";" .. tostring(subcategory)

        local subfilters = FILTER_PRESETS[category].subcategories[subcategory].subfilters
        if(subfilters) then
            for _, subfilterId in ipairs(subfilters) do
                local subfilter = self.subfilters[subfilterId]
                if(subfilter and not subfilter:IsDefault()) then
                    local subfilterValues = subfilter:Serialize()
                    state = state .. ";" .. tostring(subfilterId) .. "," .. tostring(subfilterValues)
                end
            end
        end
    end

    return state
end

local function ConvertJewelryFilterState(values)
    values[1] = ITEMFILTERTYPE_JEWELRY
    values[2] = 1
    for index, value in ipairs(values) do
        if(index > 2) then
            local subfilterId, state = zo_strsplit(",", value)
            if(subfilterId == "17") then
                if(state == "2") then
                    values[2] = 2
                elseif(state == "4") then
                    values[2] = 3
                end
            end
        end
    end
end

function CategorySelector:Deserialize(state)
    local values = {zo_strsplit(";", state)}

    local category = tonumber(values[1])
    if(category == ITEMFILTERTYPE_ARMOR and values[2] == "6") then
        -- it's from the old jewelry subcategory
        ConvertJewelryFilterState(values)
    elseif(category == ITEMFILTERTYPE_CRAFTING and (values[2] == "8" or values[2] == "9")) then
        -- it's from one of the old trait material subcategories
        values[3] = (values[2] == "8") and "34,2" or "34,4"
        values[2] = 13
    end

    for index, value in ipairs(values) do
        if(index == 1) then
            for _, button in pairs(self.mainGroup.buttons) do
                if(button.value == tonumber(value)) then button:Press() break end
            end
        elseif(index == 2) then
            for _, button in pairs(self.group[self.category].buttons) do
                if(button.value == tonumber(value)) then button:Press() break end
            end
            local filters = FILTER_PRESETS[self.category].subcategories
            local subcategory = self.subcategory[self.category]
            if(subcategory and filters[subcategory].subfilters) then
                for _, subfilterId in pairs(filters[subcategory].subfilters) do
                    self.subfilters[subfilterId]:Reset()
                end
            end
        else
            local subfilterId, subfilterValues = zo_strsplit(",", value)
            local subfilter = self.subfilters[tonumber(subfilterId)]
            assert(subfilterId and subfilter)
            if(subfilterValues) then
                subfilter:Deserialize(subfilterValues)
            end
        end
    end
end

function CategorySelector:GetTooltipText(state)
    local values = {zo_strsplit(";", state)}

    local category, subcategory
    local lines = {}
    -- TRANSLATORS: label for the selected category in the search library entry tooltip
    local categoryTitle = gettext("Category")
    -- TRANSLATORS: label for the selected subcategory in the search library entry tooltip
    local subcategoryTitle = gettext("Subcategory")
    for index, value in ipairs(values) do
        if(index == 1) then
            category = FILTER_PRESETS[tonumber(value)]
            if(category) then
                lines[#lines + 1] = {label = categoryTitle, text = category.label}
            end
        elseif(index == 2 and category) then
            subcategory = category.subcategories[tonumber(value)]
            if(subcategory) then
                lines[#lines + 1] = {label = subcategoryTitle, text = subcategory.label}
            end
        elseif(subcategory) then
            local subfilterId, subfilterValues = zo_strsplit(",", value)
            local subfilter = self.subfilters[tonumber(subfilterId)]
            if(subfilter) then
                local subcategoryLines = subfilter:GetTooltipText(subfilterValues)
                for i=1, #subcategoryLines do
                    lines[#lines + 1] = subcategoryLines[i]
                end
            end
        end
    end
    return lines
end

function CategorySelector:CanAttach()
    return false
end
