local ICON_SIZE = "100%"
local categories = {}

for categoryIndex = 1, GetNumFurnitureCategories() do
    local categoryId = GetFurnitureCategoryId(categoryIndex)
    local categoryDisplayName, _, categoryAvailableInTradingHouse = GetFurnitureCategoryInfo(categoryId)
    if(categoryAvailableInTradingHouse) then
        local numSubcategories = GetNumFurnitureSubcategories(categoryIndex)
        if numSubcategories > 0 then
            local subcategories = {}
            local categoryIcon = GetFurnitureCategoryKeyboardIcons(categoryId)
            local categoryData = {
                id = categoryId,
                label = zo_iconTextFormat(categoryIcon, ICON_SIZE, ICON_SIZE, categoryDisplayName),
                values = subcategories,
            }

            for subcategoryIndex = 1, numSubcategories do
                local subcategoryId = GetFurnitureSubcategoryId(categoryIndex, subcategoryIndex)
                local subcategoryDisplayName, _, subcategoryAvailableInTradingHouse = GetFurnitureCategoryInfo(subcategoryId)
                if subcategoryAvailableInTradingHouse then
                    local fullName = string.format("%s > %s", categoryDisplayName, subcategoryDisplayName)
                    local data = {
                        parentId = categoryId,
                        id = subcategoryId,
                        label = subcategoryDisplayName,
                        fullLabel = zo_iconTextFormat(categoryIcon, ICON_SIZE, ICON_SIZE, fullName),
                        sortIndex = fullName,
                    }
                    subcategories[#subcategories + 1] = data
                end
            end

            if(#subcategories > 0) then
                categories[#categories + 1] = categoryData
            end
        end
    end
end

AwesomeGuildStore.data.FURNITURE_CATEGORIES = categories