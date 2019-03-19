local AGS = AwesomeGuildStore

local gettext = AGS.internal.gettext

local StatusLine = ZO_SimpleSceneFragment:Subclass()
AGS.class.StatusLine = StatusLine

function StatusLine:New(...)
    return ZO_SimpleSceneFragment.New(self, ...) -- TODO: are we even using it as a scene fragment?
end

function StatusLine:Initialize(tradingHouseWrapper)
    local activityManager = tradingHouseWrapper.activityManager
    local tradingHouse = tradingHouseWrapper.tradingHouse
    local activityWindow = tradingHouseWrapper.activityWindow

    local control = CreateControlFromVirtual("AwesomeGuildStoreActivityStatusLine", tradingHouse.control, "AwesomeGuildStoreActivityStatusLineTemplate")
    control.fragment = self
    ZO_SimpleSceneFragment.Initialize(self, control)

    AGS:RegisterCallback(AGS.callback.STORE_TAB_CHANGED, function(oldTab, newTab)
        if(newTab == tradingHouseWrapper.searchTab) then
            control:SetAnchor(TOPLEFT, tradingHouse.resultCount, BOTTOMLEFT, -37, -5)
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
        activityWindow:ToggleWindow()
    end)
end

function StatusLine:ShowLoading()
    self.loadingAnimation:PlayForward()
    self.loadingSpinner:SetHidden(false)
end

function StatusLine:HideLoading()
    self.loadingSpinner:SetHidden(true)
    self.loadingAnimation:Stop()
end

function StatusLine:SetStatusText(text)
    self.statusText:SetText(text)
end
