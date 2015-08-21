local L = AwesomeGuildStore.Localization
local HiredTraderTooltip = AwesomeGuildStore.HiredTraderTooltip

local GuildSelector = ZO_Object:Subclass()
AwesomeGuildStore.GuildSelector = GuildSelector

function GuildSelector:New(...)
	local selector = ZO_Object.New(self)
	selector:Initialize(...)
	return selector
end

function GuildSelector:Initialize(saveData)
	self.saveData = saveData

	local parent = TRADING_HOUSE.m_control:GetNamedChild("Title")
	local control = CreateControlFromVirtual("AwesomeGuildStoreGuildSelector", parent, "AwesomeGuildStoreGuildSelectorTemplate")

	self.guildSelector = control
	self.entryByGuildId = {}
	self.guildIdByIndex = {}
	self.selectedGuildId = 0

	local comboBoxControl = GetControl(control, "ComboBox")
	self.comboBox = ZO_ComboBox_ObjectFromContainer(comboBoxControl)
	self.selectedItemText = GetControl(comboBoxControl, "SelectedItemText")
	self.selectedItemText.guildId = 0

	self:InitializeComboBox(comboBoxControl, self.comboBox)
	self:InitializeHiredTraderTooltip(comboBoxControl, self.comboBox)

	ZO_PreHook(TRADING_HOUSE, "UpdateForGuildChange", function()
		self:UpdateSelectedGuild()
	end)

	local originalSelectTradingHouseGuildId = SelectTradingHouseGuildId
	SelectTradingHouseGuildId = function(guildId, skipUpdates, ...)
		local result = {originalSelectTradingHouseGuildId(guildId, ...)}
		if(skipUpdates ~= true) then
			self:UpdateSelectedGuild()
			local guildId, guildName = GetCurrentTradingHouseGuildDetails()
			if(guildId ~= 0) then
				self.saveData.lastGuildName = guildName
			end
		end
		return unpack(result)
	end
end

function GuildSelector:InitializeComboBox(comboBoxControl, comboBox)
	comboBox:SetSortsItems(false)
	comboBox:SetSelectedItemFont("ZoFontWindowTitle")
	comboBox:SetDropdownFont("ZoFontHeader2")
	comboBox:SetSpacing(8)
	comboBoxControl:SetHandler("OnMouseWheel", function(control, delta, ctrl, alt, shift)
		local selectedEntry = self.entryByGuildId[self.selectedGuildId]
		if(selectedEntry) then
			local newEntry = selectedEntry
			local sellMode = TRADING_HOUSE:IsInSellMode()

			repeat
				if(delta < 0) then
					newEntry = newEntry.next
				elseif(delta > 0) then
					newEntry = newEntry.prev
				end
			until not sellMode or newEntry.canSell or newEntry == selectedEntry

			if(newEntry ~= selectedEntry) then
				self:OnGuildChanged(comboBox, newEntry.name, newEntry)
			end
		end
	end)
end

function GuildSelector:InitializeHiredTraderTooltip(comboBoxControl, comboBox)
	local traderTooltip = HiredTraderTooltip:New(self.saveData)
	local function GuildSelectorShowTooltip(control)
		traderTooltip:Show(control)
	end
	local function GuildSelectorHideTooltip(control)
		traderTooltip:Hide(control)
	end

	-- allow for tooltips on the drop down entries
	local originalShow = comboBox.ShowDropdownInternal
	comboBox.ShowDropdownInternal = function(comboBox)
		originalShow(comboBox)
		local entries = ZO_Menu.items
		for i = 1, #entries do
			local entry = entries[i]
			local control = entries[i].item
			control.guildId = self.guildIdByIndex[i]
			entry.onMouseEnter = control:GetHandler("OnMouseEnter")
			entry.onMouseExit = control:GetHandler("OnMouseExit")
			ZO_PreHookHandler(control, "OnMouseEnter", GuildSelectorShowTooltip)
			ZO_PreHookHandler(control, "OnMouseExit", GuildSelectorHideTooltip)
		end
	end

	local originalHide = comboBox.HideDropdownInternal
	comboBox.HideDropdownInternal = function(self)
		local entries = ZO_Menu.items
		for i = 1, #entries do
			local entry = entries[i]
			local control = entries[i].item
			control:SetHandler("OnMouseEnter", entry.onMouseEnter)
			control:SetHandler("OnMouseExit", entry.onMouseExit)
			control.guildId = nil
		end
		originalHide(self)
	end

	self.traderTooltip = traderTooltip

	self.selectedItemText:SetHandler("OnMouseEnter", GuildSelectorShowTooltip)
	self.selectedItemText:SetHandler("OnMouseExit", GuildSelectorHideTooltip)
end

function GuildSelector:SetupGuildList()
	self:ReselectLastGuild()

	local OnGuildChanged = function(...) self:OnGuildChanged(...) end
	local comboBox = self.comboBox

	comboBox:ClearItems()
	local entryByGuildId = {}
	local entries = {}

	local selectedEntry
	for i = 1, GetNumTradingHouseGuilds() do
		local guildId, guildName, guildAlliance = GetTradingHouseGuildDetails(i)
		local iconPath = GetAllianceBannerIcon(guildAlliance)
		if(not iconPath or #iconPath == 0) then
			ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.GENERAL_ALERT_ERROR, L["INVALID_STATE"])
		end
		local entryText = iconPath and zo_iconTextFormat(iconPath, 36, 36, guildName) or guildName
		local entry = comboBox:CreateItemEntry(entryText, OnGuildChanged)
		entry.guildId = guildId
		entry.canSell = CanSellOnTradingHouse(guildId)
		table.insert(entries, entry)

		if((not selectedEntry) or (guildId == self.selectedGuildId)) then
			selectedEntry = entry
		end
		entryByGuildId[guildId] = entry
	end

	table.sort(entries, function(a, b) return a.guildId < b.guildId end)
	comboBox:AddItems(entries)

	local guildIdByIndex = {}
	local prevEntry = entries[#entries]
	for i = 1, #entries do
		local entry = entries[i]
		guildIdByIndex[i] = entry.guildId

		prevEntry.next = entry
		entry.prev = prevEntry
		prevEntry = entry
	end

	self.entryByGuildId = entryByGuildId
	self.guildIdByIndex = guildIdByIndex

	OnGuildChanged(comboBox, selectedEntry.name, selectedEntry)
end

function GuildSelector:ReselectLastGuild()
	local guildId, guildName = GetCurrentTradingHouseGuildDetails()
	if(self.saveData.lastGuildName and self.saveData.lastGuildName ~= guildName) then
		for i = 1, GetNumTradingHouseGuilds() do
			guildId, guildName = GetTradingHouseGuildDetails(i)
			if(guildName == self.saveData.lastGuildName) then
				SelectTradingHouseGuildId(guildId)
				break
			end
		end
	end
	self:UpdateSelectedGuild()
end

function GuildSelector:UpdateSelectedGuild()
	local guildId, guildName = GetCurrentTradingHouseGuildDetails()
	if(guildId and self.entryByGuildId[guildId]) then
		self.comboBox:SetSelectedItem(self.entryByGuildId[guildId].name)
	end
	self.selectedGuildId = guildId
	self.selectedItemText.guildId = guildId
end

function GuildSelector:OnGuildChanged(comboBox, selectedName, selectedEntry)
	if(SelectTradingHouseGuildId(selectedEntry.guildId)) then
		TRADING_HOUSE:UpdateForGuildChange()
		if(TRADING_HOUSE.m_currentMode == ZO_TRADING_HOUSE_MODE_LISTINGS) then
			TRADING_HOUSE:RequestListings()
		end
		self.traderTooltip:Update(self.selectedItemText)
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
