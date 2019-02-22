local FILTER_ID = AwesomeGuildStore.data.FILTER_ID
local gettext = AwesomeGuildStore.internal.gettext

local MENU_LABEL_SELECT = gettext("Set Active")
local MENU_LABEL_RENAME = gettext("Change Label")
local MENU_LABEL_RESET = gettext("Reset Label")
local MENU_LABEL_MOVE_UP = gettext("Move Up")
local MENU_LABEL_MOVE_DOWN = gettext("Move Down")
local MENU_LABEL_REMOVE = gettext("Delete")

local RENAME_DIALOG = "AwesomeGuildStore_RenameSearchDialog"

local SEARCH_ENTRY = 1
local ADD_NEW_ENTRY = 2

local ROW_HEIGHT = 38

local ADD_NEW_LABEL = gettext("New Search")
local ADD_NEW_ICON = "EsoUI/Art/Progression/addpoints_up.dds"

local SearchList = ZO_Object:Subclass()
AwesomeGuildStore.SearchList = SearchList

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
        end)

        control:SetHandler("OnMouseExit", function()
            highlight.animation:PlayBackward()
        end)
    end

    local function SetupSearchRow(control)
        control.icon = control:GetNamedChild("Icon")
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
        local texture = search:GetIcon():format(isSelected and "down" or "up")
        local color = isSelected and ZO_SELECTED_TEXT or ZO_NORMAL_TEXT

        control.icon:SetTexture(texture)
        control.name:SetText(search:GetLabel())
        control.name:SetColor(color:UnpackRGBA())
        control.search = search
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

    AwesomeGuildStore:RegisterCallback(AwesomeGuildStore.callback.FILTER_VALUE_CHANGED, function(id)
        if(id ~= FILTER_ID.CATEGORY_FILTER) then return end
        list:RefreshVisible()
    end)

    self.toolTip = AwesomeGuildStore.SavedSearchTooltip:New()
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
        self.list:RefreshFilters()
        local scrollData = ZO_ScrollList_GetDataList(self.list.list)
        ZO_ScrollList_ScrollDataIntoView(self.list.list, #scrollData, nil, true)
        PlaySound("Click")
    end
end

function SearchList:HandleSetSearchActive(search)
    if(self.searchManager:SetActiveSearch(search)) then
        self.list:RefreshVisible()
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
    self.list:RefreshVisible()
    PlaySound("Click")
end

function SearchList:HandleMoveSearchToIndex(search, newIndex)
    if(self.searchManager:MoveSearch(search, newIndex)) then
        self.list:RefreshFilters()
        PlaySound("Click")
    end
end

function SearchList:HandleRemoveSearch(search)
    if(search:IsEnabled() and self.searchManager:RemoveSearch(search)) then
        self.list:RefreshFilters()
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
        AddCustomMenuItem(MENU_LABEL_RESET, function() return self:HandleResetLabel(search) end)
    end

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
