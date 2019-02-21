local FILTER_ID = AwesomeGuildStore.data.FILTER_ID

local SearchList = ZO_Object:Subclass()
AwesomeGuildStore.SearchList = SearchList

function SearchList:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function SearchList:Initialize(searchManager)
    self.searchManager = searchManager

    -- scroll list with drag and drop sort
    -- each entry is a button with tri-state logic
    -- last entry "new search" appends new entries to list
    local container = AwesomeGuildStoreSearchListContainer
    container:SetParent(ZO_TradingHouse)
    local list = ZO_SortFilterList:New(container)
    list:SetAutomaticallyColorRows(false)
    local scrollBar = GetControl(container, "ListScrollBar")
    scrollBar:SetHidden(true)
    ZO_PreHook(scrollBar, "SetHidden", function() return true end)
    self.list = list
    self.container = container

    local newSearchIndex = 1
    local SEARCH_ENTRY = 1
    local function SetupRow(control, data)
        list:SetupRow(control, data)

        local isSelected = data.id == searchManager:GetActiveSearch():GetId()

        local iconControl = control:GetNamedChild("Icon")
        iconControl:SetTexture(data.icon:format(isSelected and "down" or "up"))

        local nameControl = control:GetNamedChild("Name")
        nameControl:SetText(data.label)
        local color = isSelected and ZO_SELECTED_TEXT or ZO_NORMAL_TEXT
        nameControl:SetColor(color:UnpackRGBA())

        -- TODO: find a better way to show the highlight (check how inventory works)
        local highlight = control:GetNamedChild("Highlight")
        if not highlight.animation then
            highlight.animation = ANIMATION_MANAGER:CreateTimelineFromVirtual("ShowOnMouseOverLabelAnimation", highlight)
        end

        local function FadeIn()
            highlight.animation:PlayForward()
            if(data.state) then
                self.toolTip:Show(control, data, AwesomeGuildStore.main.searchTab.searchLibrary.filterByType) -- TODO
            end
        end

        local function FadeOut()
            highlight.animation:PlayBackward()
            self.toolTip:Hide()
        end

        control:SetHandler("OnMouseEnter", FadeIn)
        control:SetHandler("OnMouseExit", FadeOut)
        control:SetHandler("OnMouseUp", function(control, button, isInside)
            if(button == MOUSE_BUTTON_INDEX_LEFT and isInside) then
                local id = data.id
                if(not id) then
                    id = searchManager:AddSearch():GetId()
                    self.list:RefreshFilters()
                    ZO_ScrollList_ScrollDataIntoView(self.list.list, newSearchIndex, nil, true)
                end
                searchManager:SetActiveSearch(id)
                self.list:RefreshVisible()
                PlaySound("Click")
            elseif(button == MOUSE_BUTTON_INDEX_MIDDLE and isInside) then
                if(data.id) then
                    searchManager:RemoveSearch(data.id)
                    self.list:RefreshFilters()
                    PlaySound("Click") -- TODO: select a different search, or clear results if none are left
                end
            end
        end)
    end
    ZO_ScrollList_AddDataType(list.list, SEARCH_ENTRY, "AwesomeGuildStoreSearchListEntry", 38, SetupRow)

    function list:FilterScrollList()
        local scrollData = ZO_ScrollList_GetDataList(self.list)
        ZO_ClearNumericallyIndexedTable(scrollData)

        local searches = searchManager:GetSearches()
        for i = 1, #searches do
            scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(SEARCH_ENTRY, searches[i]:CreateDataEntry())
        end

        -- TODO: add outside of the scrolling?
        scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(SEARCH_ENTRY, {
            label = "New Search",
            icon = "EsoUI/Art/Progression/addpoints_up.dds"
        })
        newSearchIndex = #scrollData
    end

    list:RefreshFilters()

    AwesomeGuildStore:RegisterCallback(AwesomeGuildStore.callback.FILTER_VALUE_CHANGED, function(id)
        if(id ~= FILTER_ID.CATEGORY_FILTER) then return end
        list:RefreshFilters() -- TODO: use RefreshVisible instead, since we just need to adjust label and icon
    end)

    self.toolTip = AwesomeGuildStore.SavedSearchTooltip:New()
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
