local AGS = AwesomeGuildStore

local SortOrderBase = ZO_Object:Subclass()
AGS.class.SortOrderBase = SortOrderBase

SortOrderBase.SORT_FIELD_TIME_LEFT = TRADING_HOUSE_SORT_EXPIRY_TIME
SortOrderBase.SORT_FIELD_PURCHASE_PRICE = TRADING_HOUSE_SORT_SALE_PRICE
SortOrderBase.SORT_FIELD_UNIT_PRICE = TRADING_HOUSE_SORT_SALE_PRICE_PER_UNIT

SortOrderBase.SORT_ORDER_UP = ZO_SORT_ORDER_UP
SortOrderBase.SORT_ORDER_DOWN = ZO_SORT_ORDER_DOWN

local VALUE_SEPARATOR = ","

local SORT_ORDER_TO_VALUE = {
    [SortOrderBase.SORT_ORDER_UP] = "1",
    [SortOrderBase.SORT_ORDER_DOWN] = "0",
}

local VALUE_TO_SORT_ORDER = {
    ["1"] = SortOrderBase.SORT_ORDER_UP,
    ["0"] = SortOrderBase.SORT_ORDER_DOWN,
}

function SortOrderBase:New(id, label, ...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function SortOrderBase:Initialize(id, label, sortFunction)
    self.id = id
    self.label = label

    self.serverKey = SortOrderBase.SORT_FIELD_TIME_LEFT
    self.serverDirection = SortOrderBase.SORT_ORDER_DOWN
    self.useLocalDirection = false

    self:ResetDirection()
    self.sortFunction = sortFunction
end

function SortOrderBase:GetId()
    return self.id
end

function SortOrderBase:GetLabel()
    return self.label
end

function SortOrderBase:SetDirection(direction)
    self.direction = direction
end

function SortOrderBase:ResetDirection()
    self.direction = SortOrderBase.SORT_ORDER_UP
end

function SortOrderBase:GetDirection()
    return self.direction
end

function SortOrderBase:IsDefaultDirection()
    return self.direction == SortOrderBase.SORT_ORDER_UP
end

function SortOrderBase:GetSortResult(data1, data2)
    if(self.direction == SortOrderBase.SORT_ORDER_UP) then
        return self.sortFunction(data1, data2)
    else
        return self.sortFunction(data2, data1)
    end
end

function SortOrderBase:ApplySortValues(request, localDirection)
    local direction
    if(self.useLocalDirection) then
        direction = localDirection
    else
        direction = self.serverDirection
    end
    request:SetSortOrder(self.serverKey, direction)
end

function SortOrderBase:Serialize(direction)
    return string.format("%d%s%s", self.id, VALUE_SEPARATOR, SORT_ORDER_TO_VALUE[direction])
end

function SortOrderBase.Deserialize(state)
    local id, direction = zo_strsplit(VALUE_SEPARATOR, state)
    id = tonumber(id)
    direction = VALUE_TO_SORT_ORDER[direction]
    return id, direction
end
