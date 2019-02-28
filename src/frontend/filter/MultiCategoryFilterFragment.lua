local AGS = AwesomeGuildStore

local FilterFragment = AGS.class.FilterFragment
local gettext = AGS.internal.gettext

local DATA_TYPE_ID = 1
local ROW_TEMPLATE = "AwesomeGuildStoreMultiCategoryFilterRowTemplate"
local ROW_HEIGHT = 24
local MAX_LIST_ROWS = 5
local ENABLED_DESATURATION = 0
local DISABLED_DESATURATION = 1

-- TRANSLATORS: tooltip text for removing entries in the list of a multi category filter on the search tab
local REMOVE_TOOLTIP_TEXT = gettext("Click to remove")

local function BySortIndexAsc(a, b)
    return b.data.sortIndex > a.data.sortIndex
end

local function FadeIn(rowControl)
    rowControl.animation:PlayForward()
    InitializeTooltip(InformationTooltip, rowControl, RIGHT, -5, 0)
    SetTooltipText(InformationTooltip, REMOVE_TOOLTIP_TEXT)
end

local function FadeOut(rowControl)
    rowControl.animation:PlayBackward()
    ClearTooltip(InformationTooltip)
end

local MultiCategoryFilterFragment = FilterFragment:Subclass()
AGS.class.MultiCategoryFilterFragment = MultiCategoryFilterFragment

function MultiCategoryFilterFragment:New(...)
    return FilterFragment.New(self, ...)
end

function MultiCategoryFilterFragment:Initialize(filterId)
    FilterFragment.Initialize(self, filterId)

    self.enabled = true
    self.entryCache = {}
    self.menuCache = {}
    self:InitializeControls()
    self:InitializeHandlers()
end

function MultiCategoryFilterFragment:InitializeControls()
    local container = self:GetContainer()

    local selectionList = CreateControlFromVirtual("$(parent)List", container, "ZO_ScrollList")
    selectionList:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
    selectionList:SetAnchor(TOPRIGHT, container, TOPRIGHT, 0, 0)

    ZO_ScrollList_Initialize(selectionList)
    ZO_ScrollList_AddDataType(selectionList, DATA_TYPE_ID, ROW_TEMPLATE, ROW_HEIGHT, function(...)
        return self:InitializeRow(...)
    end, nil, nil, function(...)
        return self:DestroyRow(...)
    end)
    ZO_ScrollList_AddResizeOnScreenResize(selectionList)
    self.selectionList = selectionList

    local addButton = CreateControlFromVirtual("$(parent)AddButton", container, "ZO_DefaultButton") -- TODO: button style
    -- TRANSLATORS: label of button to add more values to the multi category filter
    addButton:SetText(gettext("Add More"))
    addButton:SetAnchor(TOPLEFT, selectionList, BOTTOMLEFT, 0, 4)
    addButton:SetAnchor(TOPRIGHT, selectionList, BOTTOMRIGHT, 0, 4)
    self.addButton = addButton
end

function MultiCategoryFilterFragment:InitializeRow(rowControl, entry)
    local label = rowControl:GetNamedChild("Label")
    label:SetText(entry.label)

    if(not rowControl.animation) then
        local highlight = rowControl:GetNamedChild("Highlight")
        rowControl.animation = ANIMATION_MANAGER:CreateTimelineFromVirtual("ShowOnMouseOverLabelAnimation", highlight)
        rowControl:SetHandler("OnMouseEnter", FadeIn)
        rowControl:SetHandler("OnMouseExit", FadeOut)
    end

    rowControl:SetHandler("OnMouseUp", function(control, button, isInside, ctrl, alt, shift, command)
        if(isInside and button == MOUSE_BUTTON_INDEX_LEFT) then
            self.filter:SetSelected(entry.value, false)
            PlaySound("Click")
        end
    end)

    local enabled = self.enabled
    rowControl:SetMouseEnabled(enabled)
    label:SetDesaturation(enabled and ENABLED_DESATURATION or DISABLED_DESATURATION)
end

function MultiCategoryFilterFragment:DestroyRow(rowControl)
    rowControl.animation:PlayFromEnd(rowControl.animation:GetDuration())
    ZO_ObjectPool_DefaultResetControl(rowControl)
end

function MultiCategoryFilterFragment:InitializeHandlers()
    self.addButton:SetHandler("OnMouseUp", function(control, button, isInside)
        if(isInside) then
            self:ShowSelectionMenu()
        end
    end)

    self.OnValueChanged = function(self, selection)
        return self:UpdateSelectionList(selection)
    end
end

function MultiCategoryFilterFragment:ShowSelectionMenu()
    ClearMenu()
    for _, category in ipairs(self.filter:GetRawValues()) do
        local entries = {}
        for _, value in ipairs(category.values) do
            entries[#entries + 1] = self:GetCheckboxMenuItem(value)
        end
        AddCustomSubMenuItem(category.label, entries)
    end

    ShowMenu()
end

function MultiCategoryFilterFragment:GetCheckboxMenuItem(value)
    if(not self.menuCache[value]) then
        self.menuCache[value] = {
            label = value.label,
            callback = function(checked)
                self.filter:SetSelected(value, checked)
            end,
            checked = function() return self.filter:IsSelected(value) end,
            itemType = MENU_ADD_OPTION_CHECKBOX,
        }
    end
    return self.menuCache[value]
end

function MultiCategoryFilterFragment:UpdateSelectionList(selection)
    local selectionList = self.selectionList

    local scrollData = ZO_ScrollList_GetDataList(selectionList)
    ZO_ScrollList_Clear(selectionList)

    for value, selected in pairs(selection) do
        if(selected) then
            scrollData[#scrollData + 1] = self:GetDataEntry(value)
        end
    end
    table.sort(scrollData, BySortIndexAsc)

    local count = self.filter:GetSelectionCount()
    local listHeight = math.max(1, ROW_HEIGHT * math.min(count, MAX_LIST_ROWS))
    selectionList:SetHeight(listHeight)

    ZO_ScrollList_Commit(selectionList)
end

function MultiCategoryFilterFragment:GetDataEntry(value)
    if(not self.entryCache[value]) then
        self.entryCache[value] = ZO_ScrollList_CreateDataEntry(DATA_TYPE_ID, {
            sortIndex = value.sortIndex,
            label = value.fullLabel,
            value = value,
        })
    end
    return self.entryCache[value]
end

function MultiCategoryFilterFragment:SetEnabled(enabled)
    FilterFragment.SetEnabled(self, enabled)
    self.enabled = enabled
    self.addButton:SetEnabled(enabled)
    self.addButton:SetMouseEnabled(enabled)
    ZO_ScrollList_RefreshVisible(self.selectionList)
end