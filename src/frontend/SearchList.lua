local AGS = AwesomeGuildStore

local FILTER_ID = AGS.data.FILTER_ID
local gettext = AGS.internal.gettext
local logger = AGS.internal.logger

local MENU_LABEL_SELECT = gettext("Set Active")
local MENU_LABEL_RENAME = gettext("Rename")
local MENU_LABEL_RESET_NAME = gettext("Reset Label")
local MENU_LABEL_RESET_STATE =  GetString(SI_TRADING_HOUSE_RESET_SEARCH)
local MENU_LABEL_ENABLE = gettext("Unlock")
local MENU_LABEL_DISABLE = gettext("Lock")
local MENU_LABEL_DUPLICATE = gettext("Duplicate")
local MENU_LABEL_MOVE_UP = gettext("Move Up")
local MENU_LABEL_MOVE_DOWN = gettext("Move Down")
local MENU_LABEL_REMOVE = gettext("Delete")

local RENAME_DIALOG = "AwesomeGuildStore_RenameSearchDialog"

local SEARCH_ENTRY = 1
local ADD_NEW_ENTRY = 2

local ROW_HEIGHT = 38

local ADD_NEW_LABEL = gettext("New Search")
local ADD_NEW_ICON = "EsoUI/Art/Progression/addpoints_up.dds"

local LOCKED_ICON = "EsoUI/Art/Miscellaneous/status_locked.dds"
local LOCKED_COLOR = ZO_ColorDef:New("BC4B1A")
local AUTOMATIC_ICON = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_submitFeedback.dds"
local AUTOMATIC_COLOR = ZO_ColorDef:New("1A82BA")

local r, g, b = ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB()
local LINE_FORMAT = "%s: |cFFFFFF%s"

local IGNORE_COOLDOWN = true

local SearchList = ZO_Object:Subclass()
AGS.class.SearchList = SearchList

function SearchList:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function SearchList:Initialize(searchManager)
    self.searchManager = searchManager

    ZO_Dialogs_RegisterCustomDialog(RENAME_DIALOG, {
        title = {
            text = gettext("Rename Search"),
        },
        mainText = {
            text = gettext("Enter the new name for your search."),
        },
        editBox = {
            selectAll = true
        },
        buttons = {
            {
                requiresTextInput = true,
                text =      gettext("Save"),
                callback =  function(dialog)
                    local label = ZO_Dialogs_GetEditBoxText(dialog)
                    dialog.data:SetLabel(label)
                    dialog.data:SetAutomatic(false)
                    self.list:RefreshVisible()
                end,
            },
            {
                text =       SI_DIALOG_CANCEL,
                callback =  function(dialog) end,
            },
        }
    })

    local container = AwesomeGuildStoreSearchListContainer
    container:SetParent(ZO_TradingHouse)
    local list = ZO_SortFilterList:New(container)
    list:SetAutomaticallyColorRows(false)
    local scrollBar = GetControl(container, "ListScrollBar")
    scrollBar:SetHidden(true)
    ZO_PreHook(scrollBar, "SetHidden", function() return true end)
    self.list = list
    self.container = container

    local function SetupHighlight(control)
        local highlight = control:GetNamedChild("Highlight")
        highlight.animation = ANIMATION_MANAGER:CreateTimelineFromVirtual("ShowOnMouseOverLabelAnimation", highlight)

        control:SetHandler("OnMouseEnter", function()
            highlight.animation:PlayForward()
            if(control.search) then
                self:ShowTooltip(control)
            end
        end)

        control:SetHandler("OnMouseExit", function()
            highlight.animation:PlayBackward()
            if(control.search) then
                self:HideTooltip()
            end
        end)
    end

    local function SetupSearchRow(control)
        control.icon = control:GetNamedChild("Icon")
        control.status = control:GetNamedChild("Status")
        control.name = control:GetNamedChild("Name")

        SetupHighlight(control)

        control:SetHandler("OnMouseUp", function(control, button, isInside)
            if(isInside) then
                self:HandleClickSearchEntry(control, button, control.search)
            end
        end)
    end

    ZO_ScrollList_AddDataType(list.list, SEARCH_ENTRY, "AwesomeGuildStoreSearchListEntry", ROW_HEIGHT, function(control, search)
        list:SetupRow(control, search)

        if(not control.icon) then
            SetupSearchRow(control)
        end

        local isSelected = (search == searchManager:GetActiveSearch())
        local icons = search:GetIcons()
        local texture = isSelected and icons.down or icons.up
        local color = isSelected and ZO_SELECTED_TEXT or ZO_NORMAL_TEXT

        control.icon:SetTexture(texture)
        if not search:IsEnabled() then
            control.status:SetTexture(LOCKED_ICON)
            control.status:SetColor(LOCKED_COLOR:UnpackRGBA())
            control.status:SetHidden(false)
        elseif search:IsAutomatic() then
            control.status:SetTexture(AUTOMATIC_ICON)
            control.status:SetColor(AUTOMATIC_COLOR:UnpackRGBA())
            control.status:SetHidden(false)
        else
            control.status:SetHidden(true)
        end
        control.name:SetText(search:GetLabel())
        control.name:SetColor(color:UnpackRGBA())
        control.search = search

        control:SetHandler("OnMouseDoubleClick", function(control, button)
            if(button == MOUSE_BUTTON_INDEX_LEFT) then
                searchManager:RequestNewest(IGNORE_COOLDOWN)
            end
        end)
    end)

    ZO_ScrollList_AddDataType(list.list, ADD_NEW_ENTRY, "AwesomeGuildStoreSearchListEntry", ROW_HEIGHT, function(control, data)
        list:SetupRow(control, data)
        SetupHighlight(control)

        control:GetNamedChild("Icon"):SetTexture(ADD_NEW_ICON)
        control:GetNamedChild("Name"):SetText(ADD_NEW_LABEL)
        control:SetHandler("OnMouseUp", function(control, button, isInside)
            if(isInside and button == MOUSE_BUTTON_INDEX_LEFT) then
                self:HandleAddNewSearch()
            end
        end)
    end)

    local newSearchEntry = ZO_ScrollList_CreateDataEntry(ADD_NEW_ENTRY, {})

    function list:FilterScrollList()
        local scrollData = ZO_ScrollList_GetDataList(self.list)
        ZO_ClearNumericallyIndexedTable(scrollData)

        local searches = searchManager:GetSearches()
        for i = 1, #searches do
            scrollData[#scrollData + 1] = searches[i]:GetDataEntry(SEARCH_ENTRY)
        end

        scrollData[#scrollData + 1] = newSearchEntry
    end

    list:RefreshFilters()

    AGS:RegisterCallback(AGS.callback.FILTER_VALUE_CHANGED, function(id)
        if(id ~= FILTER_ID.CATEGORY_FILTER) then return end
        list:RefreshVisible()
    end)

    AGS:RegisterCallback(AGS.callback.SEARCH_LIST_CHANGED, function(requiresFullUpdate)
        if(requiresFullUpdate) then
            list:RefreshFilters()
        else
            list:RefreshVisible()
        end
    end)

    AGS:RegisterCallback(AGS.callback.SELECTED_SEARCH_CHANGED, function()
        list:RefreshVisible()
    end)
end

function SearchList:ShowTooltip(control)
    local search = control.search
    local searchManager = self.searchManager

    InitializeTooltip(InformationTooltip, control, RIGHT, -5, 0)
    InformationTooltip:AddLine(search:GetLabel(), "ZoFontGameBold", r, g, b)

    local filterState = search:GetFilterState()
    local filterValues = filterState:GetValues()

    local subcategory = filterState:GetSubcategory()
    local categoryFilter = searchManager:GetCategoryFilter()
    local text = string.format(LINE_FORMAT, categoryFilter:GetLabel(), categoryFilter:GetTooltipText(subcategory))
    InformationTooltip:AddLine(text, "", r, g, b)

    for i = 1, #filterValues do
        local id, values, state = unpack(filterValues[i])
        if(id ~= FILTER_ID.CATEGORY_FILTER) then
            local filter = searchManager:GetFilter(id)
            if(filter and (filter:IsPinned() or search:IsFilterActive(id)) and filter:CanFilter(subcategory)) then
                local text = string.format(LINE_FORMAT, filter:GetLabel(), filter:GetTooltipText(unpack(values)))
                InformationTooltip:AddLine(text, "", r, g, b)
            end
        end
    end
end

function SearchList:HideTooltip()
    ClearTooltip(InformationTooltip)
end

function SearchList:HandleClickSearchEntry(control, button, search)
    if(button == MOUSE_BUTTON_INDEX_LEFT) then
        self:HandleSetSearchActive(search)
    elseif(button == MOUSE_BUTTON_INDEX_MIDDLE) then
        self:HandleRemoveSearch(search)
    elseif(button == MOUSE_BUTTON_INDEX_RIGHT) then
        self:ShowContextMenu(control, search)
    end
end

function SearchList:HandleAddNewSearch()
    if(self.searchManager:SetActiveSearch(self.searchManager:AddSearch())) then
        local scrollData = ZO_ScrollList_GetDataList(self.list.list)
        ZO_ScrollList_ScrollDataIntoView(self.list.list, #scrollData, nil, true)
        PlaySound("Click")
    end
end

function SearchList:HandleSetSearchActive(search)
    if(self.searchManager:SetActiveSearch(search)) then
        PlaySound("Click")
    end
end

function SearchList:HandleRenameRequest(search)
    ZO_Dialogs_ShowDialog(RENAME_DIALOG, search, {
        initialEditText = search:GetLabel(),
    })
end

function SearchList:HandleResetLabel(search)
    search:ResetLabel()
    search:SetAutomatic(false)
    PlaySound("Click")
end

function SearchList:HandleResetState(search)
    search:Reset()
    PlaySound("Click")
end

function SearchList:HandleSetSearchEnabled(search, enabled)
    search:SetEnabled(enabled)
    search:SetAutomatic(false)
    PlaySound("Click")
    self.list:RefreshVisible()
    AGS.internal:FireCallbacks(AGS.callback.SEARCH_LOCK_STATE_CHANGED, search, search == self.searchManager:GetActiveSearch())
end

function SearchList:HandleDuplicateSearch(search)
    local saveData = ZO_ShallowTableCopy(search:GetSaveData())
    saveData.enabled = true
    saveData.automatic = nil
    local newSearch = self.searchManager:AddSearch(saveData)

    if(not self.searchManager:SetActiveSearch(newSearch)) then
        logger:Warn("Could not set duplicated search active")
    end

    local targetIndex = search:GetIndex() + 1
    if(newSearch:GetIndex() ~= targetIndex and not self.searchManager:MoveSearch(newSearch, targetIndex)) then
        logger:Warn("Could not move duplicated search")
    end

    PlaySound("Click")
end

function SearchList:HandleMoveSearchToIndex(search, newIndex)
    if(self.searchManager:MoveSearch(search, newIndex)) then
        PlaySound("Click")
    end
end

function SearchList:HandleRemoveSearch(search)
    if(search:IsEnabled() and self.searchManager:RemoveSearch(search)) then
        PlaySound("Click")
    end
end

function SearchList:ShowContextMenu(control, search)
    local index = search:GetIndex()
    local searches = self.searchManager:GetSearches()

    ClearMenu()

    if(search ~= self.searchManager:GetActiveSearch()) then
        AddCustomMenuItem(MENU_LABEL_SELECT, function() return self:HandleSetSearchActive(search) end)
    end

    AddCustomMenuItem(MENU_LABEL_RENAME, function() return self:HandleRenameRequest(search) end)

    if(search:HasCustomLabel()) then
        AddCustomMenuItem(MENU_LABEL_RESET_NAME, function() return self:HandleResetLabel(search) end)
    end

    if(search:IsEnabled()) then
        AddCustomMenuItem(MENU_LABEL_RESET_STATE, function() return self:HandleResetState(search) end)
        AddCustomMenuItem(MENU_LABEL_DISABLE, function() return self:HandleSetSearchEnabled(search, false) end)
    else
        AddCustomMenuItem(MENU_LABEL_ENABLE, function() return self:HandleSetSearchEnabled(search, true) end)
    end

    AddCustomMenuItem(MENU_LABEL_DUPLICATE, function() return self:HandleDuplicateSearch(search) end)

    if(index > 1) then
        AddCustomMenuItem(MENU_LABEL_MOVE_UP, function() return self:HandleMoveSearchToIndex(search, index - 1) end)
    end

    if(index < #searches) then
        AddCustomMenuItem(MENU_LABEL_MOVE_DOWN, function() return self:HandleMoveSearchToIndex(search, index + 1) end)
    end

    if(search:IsEnabled()) then
        AddCustomMenuItem(MENU_LABEL_REMOVE, function() return self:HandleRemoveSearch(search) end)
    end

    ShowMenu(control)
end

function SearchList:Refresh()
    self.list:RefreshFilters()
end

function SearchList:Show()
    self.container:SetHidden(false)
end

function SearchList:Hide()
    self.container:SetHidden(true)
end
