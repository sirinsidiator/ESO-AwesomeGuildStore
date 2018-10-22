local SimpleIconButton = AwesomeGuildStore.class.SimpleIconButton

local FILTER_ID = AwesomeGuildStore.data.FILTER_ID
local CATEGORY_MAPPING = AwesomeGuildStore.data.CATEGORY_MAPPING
local CATEGORY_DEFINITION = AwesomeGuildStore.data.CATEGORY_DEFINITION
local SUB_CATEGORY_DEFINITION = AwesomeGuildStore.data.SUB_CATEGORY_DEFINITION
local CATEGORY_BUTTON_SIZE = 46
local SUB_CATEGORY_BUTTON_SIZE = 32
local PRESSED = true
local DISABLED = true

local CategorySelector = ZO_SimpleSceneFragment:Subclass()
AwesomeGuildStore.class.CategorySelector = CategorySelector

function CategorySelector:New(...)
    return ZO_SimpleSceneFragment.New(self, ...)
end

function CategorySelector:Initialize(parent, searchManager)
    self.searchManager = searchManager
    local control = CreateControlFromVirtual("AwesomeGuildStoreSearchCategorySelector", parent, "AwesomeGuildStoreCategorySelectorTemplate")
    control.fragment = self
    ZO_SimpleSceneFragment.Initialize(self, control)
    self.categoryContainer = control:GetNamedChild("MainCategories")
    self.subcategoryRow = control:GetNamedChild("SubCategoryRow")
    self.subcategoryContainer = self.subcategoryRow:GetNamedChild("Categories")
    self.categoryLabel = control:GetNamedChild("Label")
    self.subcategoryLabel = self.subcategoryRow:GetNamedChild("Label")

    self.categoryButtons = {}
    self.subcategoryButtons = {}
    self.categoryButtonsById = {}
    self.subcategoryButtonsById = {}
    local categoryButtons = self.categoryButtons
    local subcategoryButtons = self.subcategoryButtons
    local categoryButtonsById = self.categoryButtonsById
    local subcategoryButtonsById = self.subcategoryButtonsById

    local categoryCount = #CATEGORY_MAPPING
    local subcategoryCount = 0
    for i = categoryCount, 1, -1 do -- TODO: simplify
        local mapping = CATEGORY_MAPPING[i]
        local category = CATEGORY_DEFINITION[mapping.category]
        local button = self:CreateCategoryButton(self.categoryContainer, i, CATEGORY_BUTTON_SIZE, categoryButtons[i + 1])
        self:ApplyCategory(button, category)
        button:SetClickHandler(MOUSE_BUTTON_INDEX_LEFT, function(button)
            return searchManager:SelectCategory(category)
        end)
        button.subcategories = mapping.subcategories
        categoryButtons[i] = button
        categoryButtonsById[category.id] = button
        subcategoryCount = math.max(subcategoryCount, #mapping.subcategories)
    end

    for i = subcategoryCount, 1, -1 do
        local button = self:CreateCategoryButton(self.subcategoryContainer, i, SUB_CATEGORY_BUTTON_SIZE, subcategoryButtons[i + 1])
        button:SetHidden(true)
        button:SetClickHandler(MOUSE_BUTTON_INDEX_LEFT, function(button)
            return searchManager:SelectSubcategory(SUB_CATEGORY_DEFINITION[button.category])
        end)
        subcategoryButtons[i] = button
    end

    for i = 1, categoryCount do
        local mapping = CATEGORY_MAPPING[i]
        for j = 1, #mapping.subcategories do
            subcategoryButtonsById[mapping.subcategories[j]] = subcategoryButtons[j]
        end
    end

    AwesomeGuildStore:RegisterCallback("FilterValueChanged", function(id, category, subcategory)
        if(id ~= FILTER_ID.CATEGORY_FILTER) then return end
        self:Update(category, subcategory)
    end)
end

function CategorySelector:GetControl()
    return self.control
end

function CategorySelector:CreateCategoryButton(parent, index, size, previousButton)
    local button = SimpleIconButton:New("$(parent)Category", parent, index)
    button:SetSize(size)
    button:SetClickSound(SOUNDS.MENU_BAR_CLICK)
    if(previousButton) then
        button:SetAnchor(RIGHT, previousButton:GetControl(), LEFT, 0, 0)
    else
        button:SetAnchor(RIGHT, parent, RIGHT, 0, 0)
    end
    return button
end

function CategorySelector:ApplyCategory(button, category)
    button:SetTextureTemplate(category.icon)
    button:SetTooltipText(category.label)
    button.category = category.id
end

function CategorySelector:UpdateButtonState(button, oldButton)
    if(oldButton) then oldButton:SetState(not PRESSED) end
    button:SetState(PRESSED)
    return button
end

function CategorySelector:Update(category, subcategory)
    self.categoryLabel:SetText(category.label)
    self.selectedCategoryButton = self:UpdateButtonState(self.categoryButtonsById[category.id], self.selectedCategoryButton)

    self.subcategoryLabel:SetText(subcategory.label)
    self.selectedSubcategoryButton = self:UpdateButtonState(self.subcategoryButtonsById[subcategory.id], self.selectedSubcategoryButton)

    local subcategories = self.selectedCategoryButton.subcategories
    if(#subcategories > 1) then
        local buttons = self.subcategoryButtons
        for i = 1, #buttons do
            local button = buttons[i]
            if(subcategories[i]) then
                self:ApplyCategory(button, SUB_CATEGORY_DEFINITION[subcategories[i]])
                button:SetHidden(false)
            else
                button:SetHidden(true)
            end
        end
        self.subcategoryRow:SetHidden(false)
    else
        self.subcategoryRow:SetHidden(true)
    end
end
