local RegisterForEvent = AwesomeGuildStore.RegisterForEvent

local TradingHouseWrapper = ZO_Object:Subclass()
AwesomeGuildStore.TradingHouseWrapper = TradingHouseWrapper

function TradingHouseWrapper:New(...)
	local wrapper = ZO_Object.New(self)
	wrapper:Initialize(...)
	return wrapper
end

function TradingHouseWrapper:Initialize(saveData)
	self.saveData = saveData
	local tradingHouse = TRADING_HOUSE
	self.tradingHouse = tradingHouse

	self.titleLabel = tradingHouse.m_control:GetNamedChild("TitleLabel")

	self.loadingOverlay = AwesomeGuildStore.LoadingOverlay:New("AwesomeGuildStoreLoading")
	local searchTab = AwesomeGuildStore.SearchTabWrapper:New(saveData)
	self.searchTab = searchTab
	local sellTab = AwesomeGuildStore.SellTabWrapper:New(saveData)
	self.sellTab = sellTab
	local listingTab = AwesomeGuildStore.ListingTabWrapper:New(saveData)
	self.listingTab = listingTab

	self:Wrap("OpenTradingHouse", function(originalOpenTradingHouse, ...)
		originalOpenTradingHouse(...)
		self:SetInterceptInventoryItemClicks(false)
		self:DisableSearchButton()
		self:DisableGuildSelector()
		self:HideLoadingOverlay()
		self:ResetSalesCategoryFilter()
	end)

	self:Wrap("RunInitialSetup", function(originalRunInitialSetup, ...)
		local tradingHouseManager = originalRunInitialSetup(...)
		tradingHouse.m_numItemsOnPage = 0

		CALLBACK_MANAGER:FireCallbacks(AwesomeGuildStore.BeforeInitialSetupCallbackName, self)
		searchTab:RunInitialSetup(self)
		sellTab:RunInitialSetup(self)
		listingTab:RunInitialSetup(self)

		self:InitializeGuildSelector()
		self:InitializeKeybindStripWrapper()
		self:InitializeSearchCooldown()
		CALLBACK_MANAGER:FireCallbacks(AwesomeGuildStore.AfterInitialSetupCallbackName, self)
		return tradingHouseManager
	end)

	self:PreHook("ClearSearchResults", function(self) self.m_numItemsOnPage = 0 end)

	local currentTab = searchTab
	self:Wrap("HandleTabSwitch", function(originalHandleTabSwitch, tradingHouse, tabData)
		currentTab:OnClose(self)
		originalHandleTabSwitch(tradingHouse, tabData)

		local mode = tabData.descriptor
		if(mode == ZO_TRADING_HOUSE_MODE_BROWSE) then
			currentTab = searchTab
		elseif(mode == ZO_TRADING_HOUSE_MODE_SELL) then
			currentTab = sellTab
		elseif(mode == ZO_TRADING_HOUSE_MODE_LISTINGS) then
			currentTab = listingTab
		end
		currentTab:OnOpen(self)
	end)

	RegisterForEvent(EVENT_CLOSE_TRADING_HOUSE, function()
		self:HideGuildSelector()
		currentTab:OnClose(self)
	end)
end

function TradingHouseWrapper:InitializeGuildSelector()
	self.guildSelector = AwesomeGuildStore.GuildSelector:New(self.saveData)
end

function TradingHouseWrapper:InitializeKeybindStripWrapper()
	self.keybindStrip = AwesomeGuildStore.KeybindStripWrapper:New(self.tradingHouse)
end

function TradingHouseWrapper:InitializeSearchCooldown()
	ZO_PreHook("ExecuteTradingHouseSearch", function()
		self:DisableSearchButton()
		self:DisableGuildSelector()
		self:ShowLoadingOverlay()
	end)

	local tradingHouse = self.tradingHouse
	RegisterForEvent(EVENT_TRADING_HOUSE_SEARCH_COOLDOWN_UPDATE, function(_, cooldownMilliseconds)
		if(cooldownMilliseconds ~= 0) then return end
		tradingHouse.m_searchAllowed = true
		self:EnableSearchButton()
		self:EnableGuildSelector()
		tradingHouse:OnSearchCooldownUpdate(cooldownMilliseconds)
		self:HideLoadingOverlay()
	end)

	RegisterForEvent(EVENT_TRADING_HOUSE_STATUS_RECEIVED, function()
		if(GetTradingHouseCooldownRemaining() == 0) then
			self:EnableSearchButton()
			self:EnableGuildSelector()
			self:HideLoadingOverlay()
		end

		if(not GetSelectedTradingHouseGuildId()) then -- it's a trader when guildId is nil
			self:ShowTitleLabel()
			self:HideGuildSelector()
		else
			self:HideTitleLabel()
			self:SetupGuildSelector()
			self:ShowGuildSelector()
		end
	end)

	local function HideLoadingOverlay()
		self:HideLoadingOverlay()
	end
	RegisterForEvent(EVENT_TRADING_HOUSE_SEARCH_RESULTS_RECEIVED, HideLoadingOverlay)
	RegisterForEvent(EVENT_TRADING_HOUSE_OPERATION_TIME_OUT, HideLoadingOverlay)
end

function TradingHouseWrapper:SetInterceptInventoryItemClicks(enabled)
	self.sellTab:SetInterceptInventoryItemClicks(enabled)
end

function TradingHouseWrapper:ResetSalesCategoryFilter()
	self.sellTab:ResetSalesCategoryFilter()
end

function TradingHouseWrapper:ShowTitleLabel()
	self.titleLabel:SetHidden(false)
end

function TradingHouseWrapper:HideTitleLabel()
	self.titleLabel:SetHidden(true)
end

function TradingHouseWrapper:SetLoadingOverlayParent(parent)
	self.loadingOverlay:SetParent(parent)
end

function TradingHouseWrapper:ShowLoadingOverlay()
	self.loadingOverlay:Show()
end

function TradingHouseWrapper:HideLoadingOverlay()
	self.loadingOverlay:Hide()
end

function TradingHouseWrapper:EnableSearchButton()
	self.searchTab:EnableSearchButton()
	self.keybindStrip:EnableSearch()
end

function TradingHouseWrapper:DisableSearchButton()
	self.searchTab:DisableSearchButton()
	self.keybindStrip:DisableSearch()
end

function TradingHouseWrapper:EnableGuildSelector()
	self.guildSelector:Enable()
end

function TradingHouseWrapper:DisableGuildSelector()
	self.guildSelector:Disable()
end

function TradingHouseWrapper:ShowGuildSelector()
	self.guildSelector:Show()
end

function TradingHouseWrapper:HideGuildSelector()
	self.guildSelector:Hide()
end

function TradingHouseWrapper:SetupGuildSelector()
	self.guildSelector:SetupGuildList()
end

function TradingHouseWrapper:RegisterFilter(filter)
	self.searchTab.searchLibrary:RegisterFilter(filter)
end

function TradingHouseWrapper:AttachFilter(filter)
	self.searchTab:AttachFilter(filter)
end

function TradingHouseWrapper:DetachFilter(filter)
	self.searchTab:DetachFilter(filter)
end

function TradingHouseWrapper:AttachButton(button)
	self.searchTab:AttachButton(button)
end

function TradingHouseWrapper:DetachButton(button)
	self.searchTab:DetachButton(button)
end

function TradingHouseWrapper:PreHook(methodName, call)
	ZO_PreHook(self.tradingHouse, methodName, call)
end

function TradingHouseWrapper:Wrap(methodName, call)
	local tradingHouse = self.tradingHouse
	local originalFunction = tradingHouse[methodName]
	if((originalFunction ~= nil) and (type(originalFunction) == "function")) then
		tradingHouse[methodName] = function(...)
			return call(originalFunction, ...)
		end
	end
end
