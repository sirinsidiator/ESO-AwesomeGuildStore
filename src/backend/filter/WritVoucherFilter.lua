local AGS = AwesomeGuildStore

local FilterBase = AGS.class.FilterBase
local ValueRangeFilterBase = AGS.class.ValueRangeFilterBase

local FILTER_ID = AGS.data.FILTER_ID
local SUB_CATEGORY_ID = AGS.data.SUB_CATEGORY_ID

local gettext = AGS.internal.gettext
local GetItemLinkWritVoucherCount = AGS.internal.GetItemLinkWritVoucherCount


local MIN_VALUE = 0
local MAX_VALUE = 10000

local WritVoucherFilter = ValueRangeFilterBase:Subclass()
AGS.class.WritVoucherFilter = WritVoucherFilter

function WritVoucherFilter:New(...)
    return ValueRangeFilterBase.New(self, ...)
end

function WritVoucherFilter:Initialize()
    ValueRangeFilterBase.Initialize(self, FILTER_ID.MASTER_WRIT_VOUCHER_FILTER, FilterBase.GROUP_LOCAL, {
        -- TRANSLATORS: label of the writ voucher filter
        label = gettext("Writ Voucher Range"),
        currency = CURT_WRIT_VOUCHERS,
        min = MIN_VALUE,
        max = MAX_VALUE,
        precision = 0,
        steps = { MIN_VALUE, 2, 4, 6, 8, 10, 20, 30, 40, 50, 100, 200, 300, 400, MAX_VALUE },
        enabled = {
            [SUB_CATEGORY_ID.CONSUMABLE_WRIT] = true,
        }
    })
end

function WritVoucherFilter:FilterLocalResult(itemData)
    local vouchers = GetItemLinkWritVoucherCount(itemData.itemLink)
    if(self.localMin and vouchers < self.localMin) then
        return false
    elseif(self.localMax and vouchers > self.localMax) then
        return false
    end
    return true
end

function WritVoucherFilter:IsLocal()
    return true
end