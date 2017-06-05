local CategorySubfilter = AwesomeGuildStore.CategorySubfilter

local ItemStyleFilter = CategorySubfilter:Subclass()
AwesomeGuildStore.ItemStyleFilter = ItemStyleFilter

local OTHER_STYLES = {
    [ITEMSTYLE_NONE] = true,
    [ITEMSTYLE_UNIQUE] = true,
    [ITEMSTYLE_ENEMY_BANDIT] = true,
    [ITEMSTYLE_RAIDS_CRAGLORN] = true,
    [ITEMSTYLE_ENEMY_DRAUGR] = true,
    [ITEMSTYLE_ENEMY_MAORMER] = true,
    [ITEMSTYLE_AREA_YOKUDAN] = true,
    [ITEMSTYLE_UNIVERSAL] = true,
    [ITEMSTYLE_AREA_REACH_WINTER] = true,
    [ITEMSTYLE_ORG_WORM_CULT] = true,
    [ITEMSTYLE_EBONY] = true,
    [ITEMSTYLE_HOLIDAY_SKINCHANGER] = true,
    [ITEMSTYLE_ORG_MORAG_TONG] = true,
    [ITEMSTYLE_AREA_RA_GADA] = true,
    [ITEMSTYLE_ORG_REDORAN] = true,
    [ITEMSTYLE_ORG_HLAALU] = true,
    [ITEMSTYLE_ORG_ORDINATOR] = true,
    [ITEMSTYLE_ORG_TELVANNI] = true,
    [ITEMSTYLE_ORG_BUOYANT_ARMIGER] = true,
    [ITEMSTYLE_HOLIDAY_FROSTCASTER] = true,
    [ITEMSTYLE_AREA_ASHLANDER] = true,
    [ITEMSTYLE_ORG_WORM_CULT] = true,
    [ITEMSTYLE_ENEMY_SILKEN_RING] = true,
    [ITEMSTYLE_ENEMY_MAZZATUN] = true,
    [ITEMSTYLE_HOLIDAY_GRIM_HARLEQUIN] = true,
    [ITEMSTYLE_HOLIDAY_HOLLOWJACK] = true,
}
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
