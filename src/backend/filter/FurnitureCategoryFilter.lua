local AGS = AwesomeGuildStore

local FilterBase = AGS.class.FilterBase
local MultiChoiceFilterBase = AGS.class.MultiChoiceFilterBase

local FILTER_ID = AGS.data.FILTER_ID
local SUB_CATEGORY_ID = AGS.data.SUB_CATEGORY_ID
local FURNITURE_CATEGORIES = AGS.data.FURNITURE_CATEGORIES

local gettext = AGS.internal.gettext


local VALUE_INDEX = 1

local FurnitureCategoryFilter = MultiChoiceFilterBase:Subclass()
AGS.class.FurnitureCategoryFilter = FurnitureCategoryFilter

function FurnitureCategoryFilter:New(...)
    return MultiChoiceFilterBase.New(self, ...)
end

function FurnitureCategoryFilter:Initialize()
    MultiChoiceFilterBase.Initialize(self, FILTER_ID.FURNITURE_CATEGORY_FILTER, FilterBase.GROUP_LOCAL, FURNITURE_CATEGORIES)
    -- TRANSLATORS: label of the writ voucher filter
    self:SetLabel(gettext("Furnishing Category"))
    self:SetEnabledSubcategories({
        [SUB_CATEGORY_ID.FURNISHING_ALL] = true,
        [SUB_CATEGORY_ID.FURNISHING_CRAFTING_STATION] = true,
        [SUB_CATEGORY_ID.FURNISHING_LIGHT] = true,
        [SUB_CATEGORY_ID.FURNISHING_ORNAMENTAL] = true,
        [SUB_CATEGORY_ID.FURNISHING_SEATING] = true,
        [SUB_CATEGORY_ID.FURNISHING_TARGET_DUMMY] = true,
    })

    self.selectedCategoryId = nil
    self.selectedSubcategoryId = nil
end

function FurnitureCategoryFilter:FilterLocalResult(itemData)
    local dataId = GetItemLinkFurnitureDataId(itemData.itemLink)
    local categoryId, subcategoryId = GetFurnitureDataCategoryInfo(dataId)
    if(not subcategoryId) then return false end

    local value = self.valueById[subcategoryId]
    return self.localSelection[value]
end

function FurnitureCategoryFilter:GetSelectedCategoryIndicesForServer()
    if(self.dirty) then
        local selectedCategoryId, selectedSubcategoryId
        local firstValue = true
        for value, selected in pairs(self.selection) do
            if(selected) then
                local categoryId = value.parent.id
                if(firstValue) then
                    selectedCategoryId = categoryId
                    selectedSubcategoryId = value.id
                    firstValue = false
                elseif(selectedCategoryId and selectedCategoryId ~= categoryId) then
                    selectedCategoryId = nil
                    selectedSubcategoryId = nil
                    break
                else
                    selectedSubcategoryId = nil
                end
            end
        end

        self.selectedCategoryId = selectedCategoryId
        self.selectedSubcategoryId = selectedSubcategoryId
        self.dirty = false
    end

    return self.selectedCategoryId, self.selectedSubcategoryId
end

function FurnitureCategoryFilter:IsLocal()
    return false
end

function FurnitureCategoryFilter:ApplyToSearch(search)
    if(not self:IsAttached() or self:IsDefault()) then return end
    local categoryId, subcategoryId = self:GetSelectedCategoryIndicesForServer()
    search.m_filters[TRADING_HOUSE_FILTER_TYPE_FURNITURE_CATEGORY].values[VALUE_INDEX] = categoryId
    search.m_filters[TRADING_HOUSE_FILTER_TYPE_FURNITURE_SUBCATEGORY].values[VALUE_INDEX] = subcategoryId
end
