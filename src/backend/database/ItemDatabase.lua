local AGS = AwesomeGuildStore

local RegisterForEvent = AGS.internal.RegisterForEvent
local ItemData = AGS.class.ItemData
local AdjustLinkStyle = AGS.internal.AdjustLinkStyle
local ItemDatabaseGuildView = AGS.class.ItemDatabaseGuildView
local FilterBase = AGS.class.FilterBase

local ItemDatabase = ZO_Object:Subclass()
AGS.class.ItemDatabase = ItemDatabase

function ItemDatabase:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

-- need to do this as early as possible to avoid other addons hooking into it. if they do, they may break
local originalItemTooltipSetLink = ItemTooltip.SetLink
local SetTradingHouseItemHook = function() end -- do nothing until the database is initialized
ZO_PreHook(ItemTooltip, "SetTradingHouseItem", function(...)
    return SetTradingHouseItemHook(...)
end)

function ItemDatabase:Initialize(tradingHouseWrapper)
    self.tradingHouseWrapper = tradingHouseWrapper
    self.data = {}
    self.guildItemData = {}
    self.viewCache = {}
    self.itemIdToIndex = {}
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

    local function SetDirty()
        local guildId = GetSelectedTradingHouseGuildId()
        if(guildId) then
            self:GetItemView(guildId):MarkDirty()
        end
    end

    AGS:RegisterCallback(AGS.callback.FILTER_VALUE_CHANGED, SetDirty)
    AGS:RegisterCallback(AGS.callback.FILTER_ACTIVE_CHANGED, SetDirty)

    function SetTradingHouseItemHook(tooltip, tradingHouseIndex)
        local item = self:TryGetItemDataInCurrentGuildByUniqueId(tradingHouseIndex)
        if(item) then
            originalItemTooltipSetLink(tooltip, item.itemLink)
            return true
        end
    end
end

function ItemDatabase:Update(guildId, guildName, numItems)
    local data = self:GetOrCreateDataForGuild(guildId)
    ZO_ClearTable(self.itemIdToIndex)

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
        item:UpdateFromStore(i, guildId, guildName)

        local itemId = GetItemLinkItemId(item.itemLink)
        self.itemIdToIndex[itemId] = i
    end

    self:GetItemView(guildId):MarkDirty()

    AGS.internal:FireCallbacks(AGS.callback.ITEM_DATABASE_UPDATE, self, guildId, hasAnyResultAlreadyStored)
    return hasAnyResultAlreadyStored
end

function ItemDatabase:GetCurrentPageIndexForItemId(itemId)
    return self.itemIdToIndex[itemId]
end

function ItemDatabase:UpdateGuildSpecificItems(guildId, guildName)
    local data = self:GetOrCreateGuildItemDataForGuild(guildId)
    local count = GetNumGuildSpecificItems()
    if(count > 0) then
        for i = 1, count do
            local item = ItemData:New(i)
            item:UpdateFromGuildSpecificItem(i, guildId, guildName)
            data[i] = item
        end
        self:GetItemView(guildId):MarkDirty()

        AGS.internal:FireCallbacks(AGS.callback.ITEM_DATABASE_UPDATE, self, guildId)
    end

    return true, TRADING_HOUSE_RESULT_SUCCESS
end

function ItemDatabase:GetItemUniqueIdForSlotIndex(slotIndex)
    local itemUniqueId = select(9, self.originalGetTradingHouseSearchResultItemInfo(slotIndex))
    return itemUniqueId
end

function ItemDatabase:GetOrCreateDataForGuild(guildId)
    local data = self.data[guildId] or {}
    self.data[guildId] = data
    return data
end

function ItemDatabase:GetOrCreateGuildItemDataForGuild(guildId)
    local data = self.guildItemData[guildId] or {}
    self.guildItemData[guildId] = data
    return data
end

function ItemDatabase:HasGuildSpecificItems(guildId)
    return self.guildItemData[guildId] ~= nil
end

function ItemDatabase:TryGetItemDataInCurrentGuildByUniqueId(itemUniqueId)
    if(not itemUniqueId) then return end

    local guildId = GetSelectedTradingHouseGuildId()
    if(not guildId) then return end

    local data = self:GetOrCreateDataForGuild(guildId)
    return data[itemUniqueId], guildId
end

function ItemDatabase:Reset()
    ZO_ClearTable(self.data)
end

function ItemDatabase:GetItemView(guildId)
    local view = self.viewCache[guildId]
    if(not view) then
        view = ItemDatabaseGuildView:New(self, guildId)
        self.viewCache[guildId] = view
    end
    return view
end

function ItemDatabase:GetFilteredView(guildId, filterState)
    local view = self:GetItemView(guildId)
    local groups = filterState:GetGroups()
    local searchManager = self.tradingHouseWrapper.searchManager

    for i = 1, #groups do
        if(groups[i] ~= FilterBase.GROUP_NONE and groups[i] ~= FilterBase.GROUP_SORT) then
            view = view:GetSubView(searchManager, filterState, groups[i], filterState:GetSubcategory())
        end
    end

    return view
end
