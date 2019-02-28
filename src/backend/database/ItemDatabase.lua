local AGS = AwesomeGuildStore

local RegisterForEvent = AGS.internal.RegisterForEvent
local ItemData = AGS.class.ItemData
local AdjustLinkStyle = AGS.internal.AdjustLinkStyle
local ItemDatabaseGuildView = AGS.class.ItemDatabaseGuildView
local FilterBase = AGS.class.FilterBase

local FILTER_ID = AGS.data.FILTER_ID

local ItemDatabase = ZO_Object:Subclass()
AGS.class.ItemDatabase = ItemDatabase

function ItemDatabase:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function ItemDatabase:Initialize(tradingHouseWrapper)
    self.tradingHouseWrapper = tradingHouseWrapper
    self.data = {}
    self.guildItemData = {}
    self.viewCache = {}
    self.dirty = true

    self.originalGetTradingHouseSearchResultItemInfo = GetTradingHouseSearchResultItemInfo
    GetTradingHouseSearchResultItemInfo = function(slotIndex)
        local item = self:TryGetItemDataInCurrentGuildByUniqueId(slotIndex)
        if(item) then
            return item.icon, item.name, item.quality, item.stackCount, item.sellerName, item.timeRemaining, item.purchasePrice, item.currencyType, item.itemUniqueId, item.purchasePricePerUnitRaw
        end

        return self.originalGetTradingHouseSearchResultItemInfo(slotIndex)
    end

    self.originalGetTradingHouseSearchResultItemLink = GetTradingHouseSearchResultItemLink
    GetTradingHouseSearchResultItemLink = function(slotIndex, linkStyle)
        local item = self:TryGetItemDataInCurrentGuildByUniqueId(slotIndex)
        if(item) then
            return AdjustLinkStyle(item.itemLink, linkStyle)
        end

        return self.originalGetTradingHouseSearchResultItemLink(slotIndex, linkStyle)
    end

    ZO_PreHook(ItemTooltip, "SetTradingHouseItem", function(tooltip, tradingHouseIndex)
        local item = self:TryGetItemDataInCurrentGuildByUniqueId(tradingHouseIndex)
        if(item) then
            tooltip:SetLink(item.itemLink)
            return true
        end
    end)

    local function SetDirty()
        local guildName = select(2, GetCurrentTradingHouseGuildDetails())
        self:GetItemView(guildName):MarkDirty()
    end

    AGS:RegisterCallback(AGS.callback.FILTER_VALUE_CHANGED, SetDirty)
    AGS:RegisterCallback(AGS.callback.FILTER_ACTIVE_CHANGED, SetDirty)
end

function ItemDatabase:Update(guildName, numItems)
    local data = self:GetOrCreateDataForGuild(guildName)

    local hasAnyResultAlreadyStored = false
    for i = 1, numItems do
        local itemUniqueId = self:GetItemUniqueIdForSlotIndex(i)
        local item = data[itemUniqueId]
        if(item) then
            hasAnyResultAlreadyStored = true
        else
            item = ItemData:New(itemUniqueId)
        end
        data[itemUniqueId] = item
        item:UpdateFromStore(i, guildName)
    end

    self:GetItemView(guildName):MarkDirty()

    AGS.internal:FireCallbacks(AGS.callback.ITEM_DATABASE_UPDATE, self, guildName, hasAnyResultAlreadyStored)
    return hasAnyResultAlreadyStored
end

function ItemDatabase:UpdateGuildSpecificItems(guildId, guildName)
    if(guildId and guildId > 0) then
        local data = self:GetOrCreateGuildItemDataForGuild(guildName)

        local count = GetNumGuildSpecificItems()
        if(count > 0) then
            for i = 1, count do
                local item = ItemData:New(i, guildName)
                item:UpdateFromGuildSpecificItem(i)
                data[i] = item
            end
            self:GetItemView(guildName):MarkDirty()
        end

        AGS.internal:FireCallbacks(AGS.callback.ITEM_DATABASE_UPDATE, self, guildName)
        return true, TRADING_HOUSE_RESULT_SUCCESS
    end
    return false, TRADING_HOUSE_RESULT_NOT_A_MEMBER
end

function ItemDatabase:GetItemUniqueIdForSlotIndex(slotIndex)
    local itemUniqueId = select(9, self.originalGetTradingHouseSearchResultItemInfo(slotIndex))
    return itemUniqueId
end

function ItemDatabase:GetOrCreateDataForGuild(guildName)
    if(not guildName) then return {} end
    local data = self.data[guildName] or {}
    self.data[guildName] = data
    return data
end

function ItemDatabase:GetOrCreateGuildItemDataForGuild(guildName)
    if(not guildName) then return {} end
    local data = self.guildItemData[guildName] or {}
    self.guildItemData[guildName] = data
    return data
end

function ItemDatabase:HasGuildSpecificItems(guildName)
    return self.guildItemData[guildName] ~= nil
end

function ItemDatabase:TryGetItemDataInCurrentGuildByUniqueId(itemUniqueId)
    if(not itemUniqueId) then return end

    local guildId, guildName = GetCurrentTradingHouseGuildDetails()
    local data = self:GetOrCreateDataForGuild(guildName)
    return data[itemUniqueId], guildId
end

function ItemDatabase:Reset()
    ZO_ClearTable(self.data)
end

function ItemDatabase:GetItemView(guildName)
    local view = self.viewCache[guildName]
    if(not view) then
        view = ItemDatabaseGuildView:New(self, guildName)
        self.viewCache[guildName] = view
    end
    return view
end

function ItemDatabase:GetFilteredView(guildName, filterState)
    local view = self:GetItemView(guildName)
    local groups = filterState:GetGroups()
    local searchManager = self.tradingHouseWrapper.searchManager

    for i = 1, #groups do
        if(groups[i] ~= FilterBase.GROUP_NONE) then
            view = view:GetSubView(searchManager, filterState, groups[i], filterState:GetFilterValues(FILTER_ID.CATEGORY_FILTER))
        end
    end

    return view
end
