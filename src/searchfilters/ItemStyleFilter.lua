local gettext = LibStub("LibGetText")("AwesomeGuildStore").gettext
local FilterBase = AwesomeGuildStore.FilterBase

local OLD_FILTER_VALUE_CONVERSION = {
    ITEMSTYLE_RACIAL_BRETON,
    ITEMSTYLE_RACIAL_REDGUARD,
    ITEMSTYLE_RACIAL_ORC,
    ITEMSTYLE_RACIAL_DARK_ELF,
    ITEMSTYLE_RACIAL_NORD,
    ITEMSTYLE_RACIAL_ARGONIAN,
    ITEMSTYLE_RACIAL_HIGH_ELF,
    ITEMSTYLE_RACIAL_WOOD_ELF,
    ITEMSTYLE_RACIAL_KHAJIIT,
    ITEMSTYLE_RACIAL_IMPERIAL,
    ITEMSTYLE_AREA_ANCIENT_ELF,
    ITEMSTYLE_ENEMY_PRIMITIVE,
    ITEMSTYLE_AREA_REACH,
    ITEMSTYLE_ENEMY_DAEDRIC,
    ITEMSTYLE_AREA_DWEMER,
    ITEMSTYLE_GLASS,
    ITEMSTYLE_AREA_XIVKYN,
    ITEMSTYLE_ALLIANCE_DAGGERFALL,
    ITEMSTYLE_ALLIANCE_EBONHEART,
    ITEMSTYLE_ALLIANCE_ALDMERI,
    ITEMSTYLE_AREA_AKAVIRI,
    ITEMSTYLE_UNDAUNTED,
    ITEMSTYLE_AREA_ANCIENT_ORC,
    ITEMSTYLE_DEITY_MALACATH,
    ITEMSTYLE_DEITY_TRINIMAC,
    ITEMSTYLE_AREA_SOUL_SHRIVEN,
    ITEMSTYLE_ORG_OUTLAW,
    ITEMSTYLE_ORG_ABAHS_WATCH,
    ITEMSTYLE_ORG_THIEVES_GUILD,
    ITEMSTYLE_ORG_ASSASSINS,
    ITEMSTYLE_ENEMY_DROMOTHRA,
    ITEMSTYLE_DEITY_AKATOSH,
    ITEMSTYLE_ORG_DARK_BROTHERHOOD,
    ITEMSTYLE_ENEMY_MINOTAUR,
    {
        ITEMSTYLE_UNIQUE,
        ITEMSTYLE_ENEMY_BANDIT,
        ITEMSTYLE_RAIDS_CRAGLORN,
        ITEMSTYLE_ENEMY_DRAUGR,
        ITEMSTYLE_ENEMY_MAORMER,
        ITEMSTYLE_AREA_YOKUDAN,
        ITEMSTYLE_UNIVERSAL,
        ITEMSTYLE_AREA_REACH_WINTER,
        ITEMSTYLE_ORG_WORM_CULT,
        ITEMSTYLE_EBONY,
        ITEMSTYLE_HOLIDAY_SKINCHANGER,
        ITEMSTYLE_ORG_MORAG_TONG,
        ITEMSTYLE_AREA_RA_GADA,
        ITEMSTYLE_ORG_REDORAN,
        ITEMSTYLE_ORG_HLAALU,
        ITEMSTYLE_ORG_ORDINATOR,
        ITEMSTYLE_ORG_TELVANNI,
        ITEMSTYLE_ORG_BUOYANT_ARMIGER,
        ITEMSTYLE_HOLIDAY_FROSTCASTER,
        ITEMSTYLE_AREA_ASHLANDER,
        ITEMSTYLE_ORG_WORM_CULT,
        ITEMSTYLE_ENEMY_SILKEN_RING,
        ITEMSTYLE_ENEMY_MAZZATUN,
        ITEMSTYLE_HOLIDAY_GRIM_HARLEQUIN,
        ITEMSTYLE_HOLIDAY_HOLLOWJACK,
    }
}

local NEXT_UNASSIGNED_STYLE_ID = 60
local STYLE_ENTRY = 1
local FILTER_ARGS_LIMIT = 24
local BASE_HEIGHT = 50
local ROW_HEIGHT = 24
local MAX_LIST_ROWS = 5
local SUPPRESS_UPDATE = true
local ARRAY_SEPARATOR = ":"
local r, g, b = ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB()

local newStyles = {37, 38}
-- automatically fill in new styles if there are any
for styleId = NEXT_UNASSIGNED_STYLE_ID, GetHighestItemStyleId() do 
    newStyles[#newStyles + 1] = styleId
end

local STYLE_CATEGORIES = {
    {
        label = gettext("Racial"),
        styles = {1, 2, 3, 4, 5, 6, 7, 8, 9, 14, 15, 17, 19, 20, 22, 29, 30, 34},
    },
    {
        label = gettext("Uncommon"),
        styles = {10, 13, 16, 18, 21, 27, 28, 31, 32, 33, 35, 36, 39, 40, 44, 45, 56, 57},
    },
    {
        label = gettext("Organizations"),
        styles = {11, 12, 23, 24, 25, 26, 41, 46, 47, 49, 55},
    },
    {
        label = gettext("Events"),
        styles = {42, 53, 58, 59},
    },
    {
        label = gettext("Morrowind"),
        styles = {43, 48, 49, 50, 51, 52, 54},
    },
    {
        label = gettext("New"),
        styles = newStyles,
    },
}

local ItemStyleFilter = FilterBase:Subclass()
AwesomeGuildStore.ItemStyleFilter = ItemStyleFilter

function ItemStyleFilter:New(name, tradingHouseWrapper, subfilterPreset, ...)
    return FilterBase.New(self, subfilterPreset.type, name, tradingHouseWrapper, subfilterPreset, ...)
end

function ItemStyleFilter:Initialize(name, tradingHouseWrapper, subfilterPreset)
    self.preset = subfilterPreset
    local container = self.container

    local label = container:CreateControl("$(parent)Label", CT_LABEL)
    label:SetFont("ZoFontWinH4")
    label:SetText(subfilterPreset.label .. ":")
    self:SetLabelControl(label)

    local tooltipText = gettext("Reset <<1>> Filter", label:GetText():gsub(":", ""))
    self.resetButton:SetTooltipText(tooltipText)

    self.selectionCount = 0
    self.selectedStyles = {}

    local selectionList = CreateControlFromVirtual("$(parent)List", container, "ZO_ScrollList")
    selectionList:SetAnchor(TOPLEFT, label, BOTTOMLEFT, 0, 0)
    selectionList:SetAnchor(TOPRIGHT, label, BOTTOMRIGHT, 18, 0)

    local function InitializeRow(...)
        self:InitializeRow(...)
    end
    local function DestroyRow(...)
        self:DestroyRow(...)
    end
    ZO_ScrollList_Initialize(selectionList)
    ZO_ScrollList_AddDataType(selectionList, STYLE_ENTRY, "AwesomeGuildStoreStyleFilterRowTemplate", 24, InitializeRow, nil, nil, DestroyRow)
    ZO_ScrollList_AddResizeOnScreenResize(selectionList)
    self.selectionList = selectionList

    local addButton = CreateControlFromVirtual("$(parent)AddButton", container, "ZO_DefaultButton")
    addButton:SetText(gettext("Select Styles"))
    addButton:SetHandler("OnMouseUp",function(control, button, isInside)
        if(isInside) then
            self:ShowStyleSelectionMenu()
        end
    end)
    addButton:SetAnchor(TOPLEFT, selectionList, BOTTOMLEFT, 0, 4)
    addButton:SetAnchor(TOPRIGHT, selectionList, BOTTOMRIGHT, 0, 4)
end

function ItemStyleFilter:InitializeRow(rowControl, entry)
    local label = rowControl:GetNamedChild("Label")
    label:SetText(entry.label)

    local highlight = rowControl:GetNamedChild("Highlight")
    if not highlight.animation then
        highlight.animation = ANIMATION_MANAGER:CreateTimelineFromVirtual("ShowOnMouseOverLabelAnimation", highlight)
    end

    local function FadeIn()
        highlight.animation:PlayForward()
        InitializeTooltip(InformationTooltip)
        InformationTooltip:ClearAnchors()
        InformationTooltip:SetOwner(rowControl, RIGHT, -5, 0)
        -- TRANSLATORS: tooltip text for entries in the selected style list of the item style filter on the search tab 
        InformationTooltip:AddLine(gettext("Click to remove style"), "", r, g, b)
    end

    local function FadeOut()
        highlight.animation:PlayBackward()
        ClearTooltip(InformationTooltip)
    end

    rowControl:SetHandler("OnMouseEnter", FadeIn)
    rowControl:SetHandler("OnMouseExit", FadeOut)

    rowControl:SetHandler("OnMouseUp", function(control, button, isInside, ctrl, alt, shift, command)
        if(isInside and button == MOUSE_BUTTON_INDEX_LEFT) then
            self:RemoveStyleSelection(entry.style)
            PlaySound("Click")
        end
    end)
end

local function ByLabelAsc(a, b)
    return b.data.label > a.data.label
end

function ItemStyleFilter:UpdateSelectionList()
    local selectionList = self.selectionList
    local scrollData = ZO_ScrollList_GetDataList(selectionList)
    ZO_ScrollList_Clear(selectionList)

    for styleId, selected in pairs(self.selectedStyles) do
        if(selected) then
            scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(STYLE_ENTRY, {
                label = GetItemStyleName(styleId),
                style = styleId
            })
        end
    end
    table.sort(scrollData, ByLabelAsc)

    local listHeight = math.max(1, ROW_HEIGHT * math.min(self.selectionCount, MAX_LIST_ROWS))
    selectionList:SetHeight(listHeight)
    self.container:SetHeight(BASE_HEIGHT + listHeight)

    ZO_ScrollList_Commit(selectionList)
    self:HandleChange()
end

function ItemStyleFilter:DestroyRow(rowControl)
    local highlight = rowControl:GetNamedChild("Highlight")
    highlight.animation:PlayFromEnd(highlight.animation:GetDuration())
    ZO_ObjectPool_DefaultResetControl(rowControl)
end

function ItemStyleFilter:DeserializeOld(state)
    local subfilterValues = tonumber(state)
    local buttonValue = 0
    while subfilterValues > 0 do
        local isPressed = (math.mod(subfilterValues, 2) == 1)
        if(isPressed) then
            local selected = OLD_FILTER_VALUE_CONVERSION[buttonValue]
            if(type(selected) == "table") then
                for _, styleId in ipairs(selected) do
                    self:AddStyleSelection(styleId, SUPPRESS_UPDATE)
                end
            elseif(type(selected) == "number") then
                self:AddStyleSelection(selected, SUPPRESS_UPDATE)
            end
        end
        subfilterValues = math.floor(subfilterValues / 2)
        buttonValue = buttonValue + 1
    end
end

function ItemStyleFilter:Deserialize(state)
    if(not tonumber(state)) then -- new save data
        local selection = {zo_strsplit(ARRAY_SEPARATOR, state)}
        for i = 1, #selection do
            self:AddStyleSelection(tonumber(selection[i]), SUPPRESS_UPDATE)
        end
    else
        self:DeserializeOld(state)
    end
    self:UpdateSelectionList()
end

function ItemStyleFilter:Serialize()
    local selection = {}
    for styleId, selected in pairs(self.selectedStyles) do
        if(selected) then
            selection[#selection + 1] = styleId
        end
    end
    return table.concat(selection, ARRAY_SEPARATOR)
end

function ItemStyleFilter:Reset()
    self.selectionCount = 0
    ZO_ClearTable(self.selectedStyles)
    self:UpdateSelectionList()
end

function ItemStyleFilter:IsDefault()
    return (self.selectionCount == 0)
end

function ItemStyleFilter:ShowStyleSelectionMenu()
    ClearMenu()
    for _, category in ipairs(STYLE_CATEGORIES) do
        local entries = {}
        for _, styleId in ipairs(category.styles) do
            entries[#entries + 1] = {
                label = GetItemStyleName(styleId),
                callback = function() self:AddStyleSelection(styleId) end
            }
        end
        AddCustomSubMenuItem(category.label, entries)
    end

    ShowMenu()
end

function ItemStyleFilter:AddStyleSelection(styleId, suppressUpdate)
    if(self.selectionCount >= FILTER_ARGS_LIMIT) then
        local message = gettext("Cannot filter for more than %d at a time"):format(FILTER_ARGS_LIMIT)
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, message)
        return
    end
    if(not self.selectedStyles[styleId]) then
        self.selectionCount = self.selectionCount + 1
        self.selectedStyles[styleId] = true

        if(not suppressUpdate) then
            self:UpdateSelectionList()
        end
    end
end

function ItemStyleFilter:RemoveStyleSelection(styleId, suppressUpdate)
    if(self.selectedStyles[styleId]) then
        self.selectionCount = self.selectionCount - 1
        self.selectedStyles[styleId] = false

        if(not suppressUpdate) then
            self:UpdateSelectionList()
        end
    end
end

function ItemStyleFilter:ApplyFilterValues(filterArray)
-- do nothing here as we want to filter on the result page
end

function ItemStyleFilter:BeforeRebuildSearchResultsPage(tradingHouseWrapper)
    return self.selectionCount > 0
end

function ItemStyleFilter:FilterPageResult(index, icon, name, quality, stackCount, sellerName, timeRemaining, purchasePrice)
    local itemLink = GetTradingHouseSearchResultItemLink(index, LINK_STYLE_BRACKETS)
    local itemStyle = GetItemLinkItemStyle(itemLink)
    return self.selectedStyles[itemStyle]
end

function ItemStyleFilter:GetTooltipText(state)
    local lines = {}
    local styleNames = {}
    if(not tonumber(state)) then -- new save data
        local selection = {zo_strsplit(ARRAY_SEPARATOR, state)}
        for i = 1, #selection do
            styleNames[#styleNames + 1] = GetItemStyleName(tonumber(selection[i]))
        end
    else
        local subfilterValues = tonumber(state)
        local buttonValue = 0
        while subfilterValues > 0 do
            local isPressed = (math.mod(subfilterValues, 2) == 1)
            if(isPressed) then
                local selected = OLD_FILTER_VALUE_CONVERSION[buttonValue]
                if(type(selected) == "table") then
                    for _, styleId in ipairs(selected) do
                        styleNames[#styleNames + 1] = GetItemStyleName(styleId)
                    end
                elseif(type(selected) == "number") then
                    styleNames[#styleNames + 1] = GetItemStyleName(selected)
                end
            end
            subfilterValues = math.floor(subfilterValues / 2)
            buttonValue = buttonValue + 1
        end
    end
    if(#styleNames > 0) then
        table.sort(styleNames)
        lines[#lines + 1] = {
            label = self.preset.label,
            text = table.concat(styleNames, ", ")
        }
    end
    return lines
end