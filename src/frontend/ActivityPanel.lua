local AGS = AwesomeGuildStore

local gettext = AGS.internal.gettext

local ActivityBase = AGS.class.ActivityBase
local SimpleIconButton = AGS.class.SimpleIconButton

local ActivityPanel = ZO_SimpleSceneFragment:Subclass()
AGS.class.ActivityPanel = ActivityPanel

local PRESSED = true
local DISABLED = true

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

function ActivityPanel:New(...)
    return ZO_SimpleSceneFragment.New(self, ...)
end

function ActivityPanel:Initialize(tradingHouseWrapper)
    local activityManager = tradingHouseWrapper.activityManager
    local tradingHouse = tradingHouseWrapper.tradingHouse

    local window = AwesomeGuildStoreActivityWindow

    local control = CreateControlFromVirtual("AwesomeGuildStoreActivityStatusLine", tradingHouse.control, "AwesomeGuildStoreActivityStatusLineTemplate")
    control.fragment = self
    ZO_SimpleSceneFragment.Initialize(self, control)

    AGS:RegisterCallback(AGS.callback.STORE_TAB_CHANGED, function(oldTab, newTab)
        if(newTab == tradingHouseWrapper.searchTab) then
            control:SetAnchor(TOPLEFT, tradingHouse.resultCount, BOTTOMLEFT, -37, 0)
            control:SetAnchor(RIGHT, tradingHouseWrapper.footer, LEFT, 0, 0, ANCHOR_CONSTRAINS_X)
        elseif(newTab == tradingHouseWrapper.sellTab) then
            control:SetAnchor(TOPLEFT, tradingHouse.control, BOTTOMLEFT, 0, -11)
            control:SetAnchor(RIGHT, ZO_PlayerInventory, LEFT, 0, 0, ANCHOR_CONSTRAINS_X)
        else
            control:SetAnchor(TOPLEFT, tradingHouse.control, BOTTOMLEFT, 0, -11)
            control:SetAnchor(RIGHT, tradingHouseWrapper.footer, LEFT, 0, 0, ANCHOR_CONSTRAINS_X)
        end
    end)

    self.loadingSpinner = self.control:GetNamedChild("Loading")
    self.statusText = self.control:GetNamedChild("Status")

    self.loadingAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("LoadIconAnimation", self.loadingSpinner)

    -- TRANSLATORS: Tooltip text when hovering over the activity status line
    local MORE_INFO_TEXT = gettext("Click for more information")
    control:SetHandler("OnMouseEnter", function()
        InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0)
        SetTooltipText(InformationTooltip, self.statusText:GetText())
        SetTooltipText(InformationTooltip, MORE_INFO_TEXT)
    end)

    control:SetHandler("OnMouseExit", function()
        ClearTooltip(InformationTooltip)
    end)

    control:SetHandler("OnMouseUp", function()
        window:SetHidden(not window:IsHidden())
    end)

    AGS.internal.CloseActivityWindow = function()
        window:SetHidden(true)
    end

    local container = window:GetNamedChild("Container")
    local list = ZO_SortFilterList:New(container)
    list:SetAlternateRowBackgrounds(true)
    list:SetAutomaticallyColorRows(false)
    list:SetEmptyText("No activities queued") -- TODO translate

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

        local textControl = control:GetNamedChild("Text")
        textControl:SetText(data:GetLogEntry())
        textControl:SetColor(textColor:UnpackRGBA())
        -- TODO set tooltip with additional details (status, created time, update time, etc)
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
    self.list = list
end

function ActivityPanel:ShowLoading()
    self.loadingAnimation:PlayForward()
    self.loadingSpinner:SetHidden(false)
end

function ActivityPanel:HideLoading()
    self.loadingSpinner:SetHidden(true)
    self.loadingAnimation:Stop()
end

function ActivityPanel:SetStatusText(text)
    self.statusText:SetText(text)
end

function ActivityPanel:AddActivity(activity)
    table.insert(self.activitylog, 1, activity)
    if(#self.activitylog > 40) then -- TODO config value
        table.remove(self.activitylog)
    end
end

function ActivityPanel:Refresh()
    self.list:RefreshFilters()
end
