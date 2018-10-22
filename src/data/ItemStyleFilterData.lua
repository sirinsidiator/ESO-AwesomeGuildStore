local gettext = LibStub("LibGetText")("AwesomeGuildStore").gettext
local logger = AwesomeGuildStore.internal.logger

local NEXT_UNASSIGNED_STYLE_ID = 82
local ICON_SIZE = "100%"

local isValidStyleId = {}
for itemStyleIndex = 1, GetNumValidItemStyles() do
    local validItemStyleId = GetValidItemStyleId(itemStyleIndex)
    if(validItemStyleId > 0) then
        isValidStyleId[validItemStyleId] = true
    end
end

local newStyles = { 77, 78, 79, 80, 81 } -- TODO: remove 80
-- automatically fill in new styles if there are any
for styleId = NEXT_UNASSIGNED_STYLE_ID, GetHighestItemStyleId() do
    newStyles[#newStyles + 1] = styleId
end

local STYLE_CATEGORIES = {
    {
        label = gettext("Racial"),
        values = {1, 2, 3, 4, 5, 6, 7, 8, 9, 14, 15, 17, 19, 20, 22, 29, 30, 33, 34},
    },
    {
        label = gettext("Uncommon"), -- TODO: remove 10, 18, 32
        values = {10, 13, 16, 18, 21, 27, 28, 31, 32, 35, 36, 39, 40, 44, 45, 56, 57},
    },
    {
        label = gettext("Organizations"),
        values = {11, 12, 23, 24, 25, 26, 41, 46, 47},
    },
    {
        label = gettext("Events"),
        values = {38, 42, 53, 58, 59, 55},
    },
    {
        label = gettext("Morrowind"),
        values = {43, 54, 48, 49, 51, 50, 52, 61, 62, 65, 66, 69, 70},
    },
    {
        label = gettext("Summerset"), -- TODO: remove 37, 60, 67
        values = {37, 60, 67, 71, 72, 73, 74, 75},
    },
    {
        label = gettext("New"),
        values = newStyles,
    },
}

for _, category in ipairs(STYLE_CATEGORIES) do
    local validStyles = {}
    for _, styleId in ipairs(category.values) do
        if(isValidStyleId[styleId]) then
            local name = zo_strformat("<<1>>", GetItemStyleName(styleId))
            local icon = GetItemLinkIcon(GetItemStyleMaterialLink(styleId))
            local label = zo_iconTextFormat(icon, ICON_SIZE, ICON_SIZE, name)
            validStyles[#validStyles + 1] = {
                parent = category,
                id = styleId,
                label = label,
                fullLabel = label,
                sortIndex = name,
            }
        else
            logger:Debug(string.format("Detected use of invalid style id '%d' in category '%s'", styleId, category.label))
        end
        isValidStyleId[styleId] = nil
    end
    category.values = validStyles
end

for styleId in pairs(isValidStyleId) do
    logger:Debug(string.format("Detected unused style id '%d'", styleId))
end

AwesomeGuildStore.data.STYLE_CATEGORIES = STYLE_CATEGORIES
