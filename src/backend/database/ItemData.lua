local AGS = AwesomeGuildStore

local GetItemLinkWritVoucherCount = AGS.internal.GetItemLinkWritVoucherCount

local SEARCH_RESULTS_DATA_TYPE = 1
local GUILD_SPECIFIC_ITEM_DATA_TYPE = 3

local ItemData = ZO_Object:Subclass()
AGS.class.ItemData = ItemData

local MISSING_ICON = "/esoui/art/icons/icon_missing.dds"
    local UNIT_PRICE_PRECISION = .01

function ItemData:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function ItemData:Initialize(itemUniqueId)
    self.itemUniqueId = itemUniqueId
    self.icon = MISSING_ICON
    self.name = ""
    self.quality = 0
    self.stackCount = 0
    self.sellerName = ""
    self.timeRemaining = 0
    self.purchasePrice = 0
    self.purchasePricePerUnit = 0
    self.currencyType = 0
    self.lastSeen = 0
    self.itemLink = ""
    self.guildName = ""
    self.guildId = -1
    self.purchased = false
    self.soldout = false
end

function ItemData:UpdateFromStore(slotIndex, guildId, guildName)
    local icon, itemName, quality, stackCount, sellerName, timeRemaining, price, currencyType, itemUniqueId, purchasePricePerUnit = GetTradingHouseSearchResultItemInfo(slotIndex)

    self.slotIndex = itemUniqueId
    self.icon = icon
    self.name = itemName
    self.quality = quality
    self.stackCount = stackCount
    self.sellerName = sellerName
    self.timeRemaining = timeRemaining
    self.purchasePrice = price
    self.purchasePricePerUnitRaw = purchasePricePerUnit
    self.purchasePricePerUnit = zo_roundToNearest(purchasePricePerUnit, UNIT_PRICE_PRECISION)
    self.currencyType = currencyType
    self.itemUniqueId = itemUniqueId
    self.guildName = guildName
    self.guildId = guildId
    self.lastSeen = GetTimeStamp()
    self.itemLink = GetTradingHouseSearchResultItemLink(slotIndex, LINK_STYLE_DEFAULT)
end

function ItemData:UpdateFromGuildSpecificItem(index, guildId, guildName)
    local icon, itemName, quality, stackCount, _, _, price, currencyType = GetGuildSpecificItemInfo(index)

    self.slotIndex = index
    self.icon = icon
    self.name = itemName
    self.quality = quality
    self.stackCount = stackCount
    self.sellerName = GetString(SI_GUILD_HERALDRY_SELLER_NAME)
    self.purchasePrice = price
    self.purchasePricePerUnit = price
    self.currencyType = currencyType
    self.guildName = guildName
    self.guildId = guildId
    self.itemLink = GetGuildSpecificItemLink(index, LINK_STYLE_DEFAULT)
    self.isGuildSpecificItem = true
end

function ItemData:GetStackCount()
    if(not self.effectiveStackCount) then
        local stackCount = self.stackCount
        local itemType = GetItemLinkItemType(self.itemLink)
        if(itemType == ITEMTYPE_MASTER_WRIT) then
            stackCount = stackCount * GetItemLinkWritVoucherCount(self.itemLink)
        end
        self.effectiveStackCount = stackCount
    end
    return self.effectiveStackCount
end

function ItemData:GetSetInfo()
    if(self.hasSet == nil) then
        local hasSet, setName = GetItemLinkSetInfo(self.itemLink)
        self.hasSet = hasSet
        self.setName = setName
    end
    return self.hasSet, self.setName
end

function ItemData:GetDataEntry()
    if(self.name == "" or self.stackCount == 0) then return end
    if(not self.dataEntry) then
        local type = self.isGuildSpecificItem and GUILD_SPECIFIC_ITEM_DATA_TYPE or SEARCH_RESULTS_DATA_TYPE
        ZO_ScrollList_CreateDataEntry(type, self)
        self:GetStackCount()
        self:GetSetInfo()
    end
    return self.dataEntry
end
