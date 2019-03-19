local AGS = AwesomeGuildStore

local gettext = AGS.internal.gettext

local ActivityBase = AGS.class.ActivityBase
local SimpleIconButton = AGS.class.SimpleIconButton

local ActivityWindow = ZO_SimpleSceneFragment:Subclass()
AGS.class.ActivityWindow = ActivityWindow

local REFRESH_INTERVAL_NAME = "AwesomeGuildStore_ActivityWindow_RefeshInterval"
local REFRESH_INTERVAL = 100
local NO_SORT_KEY = nil

local ACTIVITY_TO_STRING = {
    [ActivityBase.ACTIVITY_TYPE_REQUEST_SEARCH] = "ACTIVITY_TYPE_REQUEST_SEARCH",
    [ActivityBase.ACTIVITY_TYPE_REQUEST_NEWEST] = "ACTIVITY_TYPE_REQUEST_NEWEST",
    [ActivityBase.ACTIVITY_TYPE_REQUEST_LISTINGS] = "ACTIVITY_TYPE_REQUEST_LISTINGS",
    [ActivityBase.ACTIVITY_TYPE_PURCHASE_ITEM] = "ACTIVITY_TYPE_PURCHASE_ITEM",
    [ActivityBase.ACTIVITY_TYPE_POST_ITEM] = "ACTIVITY_TYPE_POST_ITEM",
    [ActivityBase.ACTIVITY_TYPE_CANCEL_ITEM] = "ACTIVITY_TYPE_CANCEL_ITEM",
}
local PRIORITY_TO_STRING = {
    [ActivityBase.PRIORITY_LOW] = "PRIORITY_LOW",
    [ActivityBase.PRIORITY_MEDIUM] = "PRIORITY_MEDIUM",
    [ActivityBase.PRIORITY_HIGH] = "PRIORITY_HIGH",
}

function ActivityWindow:New(...)
    return ZO_SimpleSceneFragment.New(self, ...) -- TODO: are we even using it as a scene fragment?
end

function ActivityWindow:Initialize(tradingHouseWrapper)
    local activityManager = tradingHouseWrapper.activityManager
    local tradingHouse = tradingHouseWrapper.tradingHouse

    local window = AwesomeGuildStoreActivityWindow -- TODO translate title
    self.window = window

    ZO_SimpleSceneFragment.Initialize(self, window)

    -- TODO: find a way around these 3 methods
    AGS.internal.OpenActivityWindow = function()
        self:ShowWindow()
    end

    AGS.internal.CloseActivityWindow = function()
        self:HideWindow()
    end

    AGS.internal.IsActivityWindowHidden = function()
        window:IsHidden()
    end

    local container = window:GetNamedChild("Container")

    local headers = container:GetNamedChild("Header")
    ZO_SortHeader_Initialize(headers:GetNamedChild("Time"), gettext("Time"), NO_SORT_KEY, ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontHeader")
    ZO_SortHeader_Initialize(headers:GetNamedChild("Message"), gettext("Message"), NO_SORT_KEY, ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontHeader")
    ZO_SortHeader_Initialize(headers:GetNamedChild("QueueTime"), gettext("Queued"), NO_SORT_KEY, ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontHeader")
    ZO_SortHeader_Initialize(headers:GetNamedChild("ExecutionTime"), gettext("Active"), NO_SORT_KEY, ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontHeader")

    local list = ZO_SortFilterList:New(container)
    list:SetAlternateRowBackgrounds(true)
    list:SetAutomaticallyColorRows(false)
    -- TRANSLATORS: Text when the activity list is empty
    list:SetEmptyText(gettext("No activities queued"))

    local TOOLTIP_LINE_TEMPLATE = "%s: |cFFFFFF%s|r"
    local function EnterRow(control)
        local data = ZO_ScrollList_GetData(control)
        local output = {}
        data:AddTooltipText(output)
        local text = table.concat(output, "\n")

        InitializeTooltip(InformationTooltip, control, LEFT, 0, 0)
        SetTooltipText(InformationTooltip, text)
        if(control.cancel) then
            control.cancel:SetHidden(false)
        end
        list:EnterRow(control)
    end

    local function ExitRow(control)
        ClearTooltip(InformationTooltip)
        if(control.cancel) then
            control.cancel:SetHidden(true)
        end
        list:ExitRow(control)
    end

    local QUEUED_DATA = 1
    local ACTIVE_DATA = 2
    local FINISHED_DATA = 3
    local function SetupBaseRow(control, data, icon, textColor, iconColor)
        list:SetupRow(control, data)

        control:SetHandler("OnMouseEnter", EnterRow)
        control:SetHandler("OnMouseExit", ExitRow)
        local iconControl = control:GetNamedChild("Icon")
        iconControl:SetTexture(icon)
        if(iconColor) then
            iconControl:SetColor(iconColor:UnpackRGBA())
        end

        local timestampControl = control:GetNamedChild("Timestamp")
        timestampControl:SetText(data:GetFormattedTime())
        timestampControl:SetColor(textColor:UnpackRGBA())

        local textControl = control:GetNamedChild("Text")
        textControl:SetText(data:GetLogEntry())
        textControl:SetColor(textColor:UnpackRGBA())

        local queueTime, executionTime = data:GetFormattedDuration()

        local queueTimeControl = control:GetNamedChild("QueueTime")
        queueTimeControl:SetText(queueTime)
        queueTimeControl:SetColor(textColor:UnpackRGBA())

        local executionTimeControl = control:GetNamedChild("ExecutionTime")
        executionTimeControl:SetText(executionTime)
        executionTimeControl:SetColor(textColor:UnpackRGBA())

        if(Zgoo) then
            control:SetHandler("OnMouseUp", function() Zgoo(data) end)
        end
    end

    local LOG_COLOR_QUEUED = ZO_ColorDef:New("3ABAFF")
    local LOG_COLOR_ACTIVE = ZO_ColorDef:New("FFFF3A")
    local LOG_COLOR_SUCCESS = ZO_ColorDef:New("A6FF3A")
    local LOG_COLOR_FAILURE= ZO_ColorDef:New("FF4B3A")
    local LOG_COLOR_CLEARED = ZO_DEFAULT_TEXT

    local LOG_ICON_QUEUED = "EsoUI/Art/Guild/tabIcon_history_up.dds"
    local LOG_ICON_ACTIVE = "EsoUI/Art/Miscellaneous/wait_icon.dds"
    local LOG_ICON_SUCCESS = "EsoUI/Art/hud/gamepad/gp_radialicon_accept_down.dds"
    local LOG_ICON_FAILURE = "EsoUI/Art/hud/gamepad/gp_radialicon_cancel_down.dds"
    ZO_ScrollList_AddDataType(list.list, QUEUED_DATA, "AwesomeGuildStoreActivityListQueuedRowTemplate", 24, function(control, data)
        SetupBaseRow(control, data, LOG_ICON_QUEUED, LOG_COLOR_QUEUED)
        if(not control.cancel) then
            local cancel = SimpleIconButton:New(control:GetNamedChild("Cancel"))
            cancel:SetTextureTemplate("EsoUI/Art/Buttons/cancel_%s.dds")
            cancel:SetClickHandler(MOUSE_BUTTON_INDEX_LEFT, function(button)
                local data = ZO_ScrollList_GetData(button.control:GetParent())
                activityManager:RemoveActivityByKey(data.key)
            end)
            cancel:SetHandler("OnMouseEnter", function(control) EnterRow(control:GetParent()) end)
            cancel:SetHandler("OnMouseExit", function(control) ExitRow(control:GetParent()) end)
            control.cancel = cancel
        end
    end)
    ZO_ScrollList_AddDataType(list.list, ACTIVE_DATA, "AwesomeGuildStoreActivityListRowTemplate", 24, function(control, data)
        SetupBaseRow(control, data, LOG_ICON_ACTIVE, LOG_COLOR_ACTIVE)
        if(not control.animation) then
            control.animation = ANIMATION_MANAGER:CreateTimelineFromVirtual("LoadIconAnimation", GetControl(control, "Icon"))
            control.animation:PlayForward()
        end
    end)
    ZO_ScrollList_AddDataType(list.list, FINISHED_DATA, "AwesomeGuildStoreActivityListRowTemplate", 24, function(control, data)
        local icon = LOG_ICON_FAILURE
        local color = LOG_COLOR_CLEARED
        if(data.state == ActivityBase.STATE_SUCCEEDED) then
            icon = LOG_ICON_SUCCESS
            color = LOG_COLOR_SUCCESS
        elseif(data.state == ActivityBase.STATE_FAILED) then
            color = LOG_COLOR_FAILURE
        end
        SetupBaseRow(control, data, icon, color, color)
    end)
    ZO_ScrollList_EnableHighlight(list.list, "ZO_ThinListHighlight")

    local function CreateEntry(activity, type)
        return ZO_ScrollList_CreateDataEntry(type, activity)
    end

    self.activitylog = {}
    function list.FilterScrollList(list)
        local scrollData = ZO_ScrollList_GetDataList(list.list)
        ZO_ClearNumericallyIndexedTable(scrollData)

        local queue = activityManager.queue
        for i = #queue, 1, -1 do
            scrollData[#scrollData + 1] = CreateEntry(queue[i], QUEUED_DATA)
        end

        if(activityManager.currentActivity) then
            scrollData[#scrollData + 1] = CreateEntry(activityManager.currentActivity, ACTIVE_DATA)
        end

        local log = self.activitylog
        for i = 1, #log do
            scrollData[#scrollData + 1] = CreateEntry(log[i], FINISHED_DATA)
        end
    end


    local function UpdateVisible(control, data)
        local queueTime, executionTime = data:GetFormattedDuration(true)

        local queueTimeControl = control:GetNamedChild("QueueTime")
        queueTimeControl:SetText(queueTime)

        local executionTimeControl = control:GetNamedChild("ExecutionTime")
        executionTimeControl:SetText(executionTime)
    end

    function list:RefreshVisible()
        ZO_ScrollList_RefreshVisible(self.list, nil, UpdateVisible)
    end

    self.refreshVisible = function()
        list:RefreshVisible()
    end

    self.list = list
end

function ActivityWindow:ShowWindow()
    self.window:SetHidden(false)
    self:Refresh()
    EVENT_MANAGER:RegisterForUpdate(REFRESH_INTERVAL_NAME, REFRESH_INTERVAL, self.refreshVisible)
end

function ActivityWindow:HideWindow()
    self.window:SetHidden(true)
    EVENT_MANAGER:UnregisterForUpdate(REFRESH_INTERVAL_NAME)
end

function ActivityWindow:ToggleWindow()
    if(self.window:IsHidden()) then
        self:ShowWindow()
    else
        self:HideWindow()
    end
end

function ActivityWindow:AddActivity(activity)
    table.insert(self.activitylog, 1, activity)
    if(#self.activitylog > 40) then -- TODO config value
        table.remove(self.activitylog)
    end
end

function ActivityWindow:Refresh()
    if(not self.window:IsHidden()) then
        self.list:RefreshFilters()
    end
end
