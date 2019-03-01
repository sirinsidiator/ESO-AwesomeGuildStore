local AGS = AwesomeGuildStore

local FilterBase = AGS.class.FilterBase
local MultiChoiceFilterBase = AGS.class.MultiChoiceFilterBase

local GenericTradingHouseFilter = MultiChoiceFilterBase:Subclass()
AGS.class.GenericTradingHouseFilter = GenericTradingHouseFilter

function GenericTradingHouseFilter:New(...)
    return MultiChoiceFilterBase.New(self, ...)
end

function GenericTradingHouseFilter:Initialize(filterData)
    MultiChoiceFilterBase.Initialize(self, filterData.id, FilterBase.GROUP_SERVER, filterData.label, filterData.values)
    self:SetEnabledSubcategories(filterData.enabled)
    if(filterData.encoding) then
        self:SetEncoding(filterData.encoding)
    end
    self.filterType = filterData.type
    self.Unpack = filterData.unpack
    if(filterData.setFromItem) then
        self.SetFromItem = filterData.setFromItem
    end
end

function GenericTradingHouseFilter:FilterLocalResult(itemData)
    local id = self:Unpack(itemData)
    if(not id) then return false end
    local value = self.valueById[id]
    return self.localSelection[value]
end

function GenericTradingHouseFilter:IsLocal()
    return false
end

function GenericTradingHouseFilter:ApplyToSearch()
    if(not self.filterType or not self:IsAttached() or self:IsDefault()) then
        return
    end

    local values = {}
    for value, enabled in pairs(self.selection) do
        if(enabled) then
            values[#value + 1] = value.id
        end
    end
    SetTradingHouseFilter(self.filterType, unpack(values))
end
