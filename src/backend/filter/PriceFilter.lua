local AGS = AwesomeGuildStore

local FilterBase = AGS.class.FilterBase
local ValueRangeFilterBase = AGS.class.ValueRangeFilterBase

local FILTER_ID = AGS.data.FILTER_ID

local gettext = AGS.internal.gettext

local TRADING_HOUSE_FILTER_TYPE_PRICE = TRADING_HOUSE_FILTER_TYPE_PRICE


local MIN_VALUE = 1
local MAX_VALUE = 2100000000
local MIN_INDEX = 1
local MAX_INDEX = 2

local PriceFilter = ValueRangeFilterBase:Subclass()
AGS.class.PriceFilter = PriceFilter

function PriceFilter:New(...)
    return ValueRangeFilterBase.New(self, ...)
end

function PriceFilter:Initialize()
    ValueRangeFilterBase.Initialize(self, FILTER_ID.PRICE_FILTER, FilterBase.GROUP_SERVER, {
        -- TRANSLATORS: label of the price filter
        label = gettext("Price Range"),
        currency = CURT_MONEY,
        min = MIN_VALUE,
        max = MAX_VALUE,
        precision = 0,
        steps = { MIN_VALUE, 10, 50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000, 50000, 100000, MAX_VALUE },
    })
end

function PriceFilter:IsLocal()
    return false
end

function PriceFilter:ApplyToSearch(search)
    if(not self:IsAttached() or self:IsDefault()) then return end
    local filterValues = search.m_filters[TRADING_HOUSE_FILTER_TYPE_PRICE].values
    filterValues[MIN_INDEX] = self.min
    filterValues[MAX_INDEX] = self.max
end

function PriceFilter:FilterLocalResult(itemData)
    if(self.localMin and itemData.purchasePrice < self.localMin) then
        return false
    elseif(self.localMax and itemData.purchasePrice > self.localMax) then
        return false
    end
    return true
end

function PriceFilter:CanAttach()
    return true
end