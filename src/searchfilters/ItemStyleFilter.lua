local L = AwesomeGuildStore.Localization
local CategorySubfilter = AwesomeGuildStore.CategorySubfilter

local ItemStyleFilter = CategorySubfilter:Subclass()
AwesomeGuildStore.ItemStyleFilter = ItemStyleFilter

local OTHER_STYLES
if(GetAPIVersion() == 100014) then
	OTHER_STYLES = {
		[ITEMSTYLE_NONE] = true,
		[ITEMSTYLE_UNIQUE] = true,
		[ITEMSTYLE_ORG_THIEVES_GUILD] = true,
		[ITEMSTYLE_ORG_DARK_BROTHERHOOD] = true,
		[ITEMSTYLE_ENEMY_BANDIT] = true,
		[ITEMSTYLE_RAIDS_CRAGLORN] = true,
		[ITEMSTYLE_ENEMY_DRAUGR] = true,
		[ITEMSTYLE_ENEMY_MAORMER] = true,
		[ITEMSTYLE_AREA_YOKUDAN] = true,
		[ITEMSTYLE_UNIVERSAL] = true,
		[ITEMSTYLE_AREA_REACH_WINTER] = true,
		[ITEMSTYLE_UNUSED0] = true, -- looks like they are not as unused as their name suggests
		[ITEMSTYLE_UNUSED1] = true,
		[ITEMSTYLE_UNUSED2] = true,
		[ITEMSTYLE_UNUSED3] = true,
		[ITEMSTYLE_UNUSED4] = true,
		[ITEMSTYLE_UNUSED5] = true,
		[ITEMSTYLE_UNUSED6] = true,
		[ITEMSTYLE_UNUSED7] = true,
		[ITEMSTYLE_UNUSED8] = true,
	}
else
	OTHER_STYLES = {
		[ITEMSTYLE_NONE] = true,
		[ITEMSTYLE_UNIQUE] = true,
		[ITEMSTYLE_ORG_DARK_BROTHERHOOD] = true,
		[ITEMSTYLE_DEITY_AKATOSH] = true,
		[ITEMSTYLE_AREA_REACH] = true,
		[ITEMSTYLE_ENEMY_BANDIT] = true,
		[ITEMSTYLE_RAIDS_CRAGLORN] = true,
		[ITEMSTYLE_ENEMY_DRAUGR] = true,
		[ITEMSTYLE_ENEMY_MAORMER] = true,
		[ITEMSTYLE_AREA_YOKUDAN] = true,
		[ITEMSTYLE_UNIVERSAL] = true,
		[ITEMSTYLE_AREA_REACH_WINTER] = true,
		[ITEMSTYLE_ORG_WORM_CULT] = true,
		[ITEMSTYLE_ENEMY_MINOTAUR] = true,
		[ITEMSTYLE_EBONY] = true,
		[ITEMSTYLE_ENEMY_SKINCHANGER] = true,
		[ITEMSTYLE_ORG_MORAG_TONG] = true,
		[ITEMSTYLE_AREA_RA_GADA] = true,
		[ITEMSTYLE_ENEMY_DROMOTHRA] = true,
		[ITEMSTYLE_UNUSED11] = true,
		[ITEMSTYLE_UNUSED12] = true,
		[ITEMSTYLE_UNUSED13] = true,
		[ITEMSTYLE_UNUSED14] = true,
		[ITEMSTYLE_UNUSED15] = true,
		[ITEMSTYLE_UNUSED16] = true,
		[ITEMSTYLE_UNUSED17] = true,
		[ITEMSTYLE_UNUSED18] = true,
		[ITEMSTYLE_UNUSED19] = true,
		[ITEMSTYLE_UNUSED20] = true,
		[ITEMSTYLE_UNUSED21] = true,
		[ITEMSTYLE_UNUSED22] = true,
	}
end
local OTHER_STYLE_VALUE = 99

function ItemStyleFilter:New(name, tradingHouseWrapper, subfilterPreset, ...)
	return CategorySubfilter.New(self, name, tradingHouseWrapper, subfilterPreset, ...)
end

function ItemStyleFilter:ApplyFilterValues(filterArray)
-- do nothing here as we want to filter on the result page
end

function ItemStyleFilter:BeforeRebuildSearchResultsPage(tradingHouseWrapper)
	self.selectedStyles = {}
	self.showOtherStyles = false
	local hasSelections = false

	local group = self.group
	for _, button in pairs(group.buttons) do
		if(button:IsPressed()) then
			if(button.value == OTHER_STYLE_VALUE) then
				self.showOtherStyles = true
			elseif(GetAPIVersion() == 100014 and button.value == ITEMSTYLE_RACIAL_IMPERIAL) then -- TODO
				self.selectedStyles[ITEMSTYLE_AREA_IMPERIAL] = true -- there are two different imperial styles. not idea what makes them different. NOTE: has been removed in 100015
			else
				self.selectedStyles[button.value] = true
			end
			hasSelections = true
		end
	end

	return hasSelections
end

function ItemStyleFilter:FilterPageResult(index, icon, name, quality, stackCount, sellerName, timeRemaining, purchasePrice)
	local itemLink = GetTradingHouseSearchResultItemLink(index, LINK_STYLE_BRACKETS)
	local itemStyle = GetItemLinkItemStyle(itemLink)
	return self.selectedStyles[itemStyle] or (self.showOtherStyles and OTHER_STYLES[itemStyle])
end
