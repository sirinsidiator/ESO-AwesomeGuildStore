local HiredTraderTooltip = ZO_Object:Subclass()
AwesomeGuildStore.class.HiredTraderTooltip = HiredTraderTooltip

function HiredTraderTooltip:New(...)
    local tooltip = ZO_Object.New(self)
    tooltip:Initialize(...)
    return tooltip
end

function HiredTraderTooltip:Initialize(saveData)
    self.saveData = saveData
    self.traderIcon = CreateControlFromVirtual("AwesomeGuildStoreHiredTraderIcon", GuiRoot, "AwesomeGuildStoreTraderIconTemplate")
end

function HiredTraderTooltip:Show(control, guildId)
    if(not self.saveData.showTraderTooltip) then return end
    self.isShowing = true
    self:Update(control, guildId)
end

function HiredTraderTooltip:Hide()
    self.isShowing = false
    ClearTooltip(InformationTooltip) -- looks like this automatically hides the traderIcon
end

function HiredTraderTooltip:Update(control, guildId)
    if(self.isShowing) then
        local traderIcon = self.traderIcon
        local traderName = GetGuildOwnedKioskInfo(guildId)
        if(traderName) then
            traderIcon:SetAlpha(1)
            traderName = zo_strformat(SI_GUILD_HIRED_TRADER, traderName)
        else
            traderIcon:SetAlpha(0.2)
            traderName = GetString(SI_GUILD_NO_HIRED_TRADER)
        end
        traderIcon:ClearAnchors()
        traderIcon:SetHidden(false)

        local r, g, b = ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB()
        InitializeTooltip(InformationTooltip)
        InformationTooltip:ClearAnchors()
        InformationTooltip:SetOwner(control, RIGHT, -5, 0)
        InformationTooltip:AddLine(GetString(SI_GUILD_TRADER_OWNERSHIP_HEADER), "ZoFontGameBold", r, g, b)
        InformationTooltip:AddControl(traderIcon)
        traderIcon:SetAnchor(CENTER)
        InformationTooltip:AddLine(traderName, "", r, g, b)
    end
end
