local HiredTraderTooltip = AwesomeGuildStore.HiredTraderTooltip

local GuildSelector = ZO_Object:Subclass()
AwesomeGuildStore.GuildSelector = GuildSelector

function GuildSelector:New(...)
    local selector = ZO_Object.New(self)
    selector:Initialize(...)
    return selector
end

function GuildSelector:Initialize(tradingHouseWrapper)
    self.tradingHouseWrapper = tradingHouseWrapper

    local tradingHouse = tradingHouseWrapper.tradingHouse

    local parent = tradingHouse.control:GetNamedChild("Title")
    local control = CreateControlFromVirtual("AwesomeGuildStoreGuildSelector", parent, "AwesomeGuildStoreGuildSelectorTemplate")
    self.titleLabel = parent:GetNamedChild("Label")
    self.titleLabel:SetModifyTextType(MODIFY_TEXT_TYPE_NONE)

    self.guildIdByMenuIndex = {}
    self.guildSelector = control -- TODO rename

    local comboBoxControl = GetControl(control, "ComboBox")
    self.comboBox = ZO_ComboBox_ObjectFromContainer(comboBoxControl)
    self.selectedItemText = GetControl(comboBoxControl, "SelectedItemText")
    self.selectedItemText.guildId = 0

    self:InitializeComboBox(comboBoxControl, self.comboBox)
    self:InitializeHiredTraderTooltip(comboBoxControl, self.comboBox)

    AwesomeGuildStore:RegisterCallback("AvailableGuildsChanged", function(guilds) -- TODO: test what happens when we fire this callback outside a trading house
        self:SetupGuildList(guilds)

        local hasGuilds = (#guilds > 0)
        self.guildSelector:SetHidden(not hasGuilds)
        self.titleLabel:SetHidden(hasGuilds)
    end)

    AwesomeGuildStore:RegisterCallback("SelectedGuildChanged", function(guildData)
        local focused = WINDOW_MANAGER:GetFocusControl()
        if(focused) then focused:LoseFocus() end

        self.selectedGuildData = guildData
        self.selectedItemText.guildId = guildData.guildId -- TODO
        self.comboBox:SetSelectedItem(guildData.guildName)
        self.traderTooltip:Update(self.selectedItemText)
        tradingHouse:UpdateForGuildChange() -- TODO: disable all the unnecessary stuff in there
    end)
end

function GuildSelector:InitializeComboBox(comboBoxControl, comboBox)
    local tradingHouse = self.tradingHouseWrapper.tradingHouse

    comboBox:SetSortsItems(false)
    comboBox:SetSelectedItemFont("ZoFontWindowTitle")
    comboBox:SetDropdownFont("ZoFontHeader2")
    comboBox:SetSpacing(8)

    comboBoxControl:SetHandler("OnMouseWheel", function(control, delta, ctrl, alt, shift)
        local currentData = self.selectedGuildData
        local newData = currentData
        local buyMode = tradingHouse:IsInSearchMode()

        repeat
            if(delta < 0) then
                newData = newData.next
            elseif(delta > 0) then
                newData = newData.previous
            end

            -- break out of the loop if the new guild can be used in the current mode
            -- TODO: remove this. just don't kick us out of the sell tab
            if(buyMode and newData.canBuy) then
                break
            elseif(not buyMode and newData.canSell) then
                break
            end
        until newData == currentData

        if(newData ~= currentData) then
            SelectTradingHouseGuildId(newData.guildId)
        end
    end)
end

function GuildSelector:InitializeHiredTraderTooltip(comboBoxControl, comboBox)
    local traderTooltip = HiredTraderTooltip:New(self.tradingHouseWrapper.saveData)
    local function GuildSelectorShowTooltip(control)
        traderTooltip:Show(control)
    end
    local function GuildSelectorHideTooltip(control)
        traderTooltip:Hide(control)
    end

    -- allow for tooltips on the drop down entries
    local function AddMenuItemCallback() -- TODO not working
        local entry = ZO_Menu.items[#ZO_Menu.items] -- fetch the last added entry
        local control = entry.item
        df("AddMenuItem(%d)", control.menuIndex)
        control.guildId = self.guildIdByMenuIndex[control.menuIndex] -- TODO find a better solution
        entry.onMouseEnter = control:GetHandler("OnMouseEnter")
        entry.onMouseExit = control:GetHandler("OnMouseExit")
        ZO_PreHookHandler(control, "OnMouseEnter", GuildSelectorShowTooltip)
        ZO_PreHookHandler(control, "OnMouseExit", GuildSelectorHideTooltip)
    end

    ZO_PreHook(comboBox, "ShowDropdownInternal", function(comboBox)
        d("show dropdown")
        SetAddMenuItemCallback(AddMenuItemCallback)
    end)

    ZO_PreHook(comboBox, "HideDropdownInternal", function(comboBox)
        d("hide dropdown")
        local entries = ZO_Menu.items
        for i = 1, #entries do
            local entry = entries[i]
            local control = entries[i].item
            control:SetHandler("OnMouseEnter", entry.onMouseEnter)
            control:SetHandler("OnMouseExit", entry.onMouseExit)
            control.guildId = nil
        end
    end)

    self.traderTooltip = traderTooltip

    self.selectedItemText:SetHandler("OnMouseEnter", GuildSelectorShowTooltip)
    self.selectedItemText:SetHandler("OnMouseExit", GuildSelectorHideTooltip)
end

local function OnSelectionChanged(comboBox, selectedName, selectedEntry)
    SelectTradingHouseGuildId(selectedEntry.data.guildId)
end

--local function ByGuildIdAsc(a, b)
--    return a.guildId < b.guildId
--end

function GuildSelector:SetupGuildList(guilds)
    local comboBox = self.comboBox
    comboBox:ClearItems()

    local entries = {}
    for i = 1, #guilds do
        local data = guilds[i]
        local entry = comboBox:CreateItemEntry(data.entryText, OnSelectionChanged)
        entry.data = data
        entries[#entries + 1] = entry
    end
    --    table.sort(entries, ByGuildIdAsc)

    comboBox:AddItems(entries)

    local guildIdByMenuIndex = self.guildIdByMenuIndex -- TODO this can be removed if we don't need to sort anyways
    for i = 1, #entries do
        local entry = entries[i]
        guildIdByMenuIndex[i] = entry.guildId
    end
end

function GuildSelector:Enable()
    self.comboBox:SetEnabled(true)
end

function GuildSelector:Disable()
    self.comboBox:SetEnabled(false)
end

function GuildSelector:Show()
    self.guildSelector:SetHidden(false)
end

function GuildSelector:Hide()
    self.guildSelector:SetHidden(true)
end
