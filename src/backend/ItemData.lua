local AGS = AwesomeGuildStore

local GetItemLinkWritVoucherCount = AGS.internal.GetItemLinkWritVoucherCount

local ItemData = ZO_Object:Subclass()
AwesomeGuildStore.ItemData = ItemData

local MISSING_ICON = "/esoui/art/icons/icon_missing.dds"

function ItemData:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function ItemData:Initialize(itemUniqueId, guildName)
    self.itemUniqueId = itemUniqueId
    self.icon = MISSING_ICON
    self.name = ""
    self.quality = 0
    self.stackCount = 0
    self.sellerName = ""
    self.timeRemaining = 0
    self.purchasePrice = 0
    self.unitPrice = nil
    self.currencyType = 0
    self.lastSeen = 0
    self.itemLink = ""
    self.guildName = ""
    self.purchased = false
    self.soldout = false
end

function ItemData:UpdateFromStore(slotIndex, guildName)
    local icon, itemName, quality, stackCount, sellerName, timeRemaining, price, currencyType, itemUniqueId = GetTradingHouseSearchResultItemInfo(slotIndex)

    if(price ~= self.purchasePrice or stackCount ~= self.stackCount) then
        self.unitPrice = nil
    end

    self.slotIndex = itemUniqueId
    self.icon = icon
    self.name = itemName
    self.quality = quality
    self.stackCount = stackCount
    self.sellerName = sellerName
    self.timeRemaining = timeRemaining
    self.purchasePrice = price
    self.currencyType = currencyType
    self.itemUniqueId = itemUniqueId
    self.guildName = guildName
    self.lastSeen = GetTimeStamp()
    self.itemLink = GetTradingHouseSearchResultItemLink(slotIndex, LINK_STYLE_DEFAULT)
end

function ItemData:UpdateFromGuildSpecificItem(index, guildName)
    local icon, itemName, quality, stackCount, _, _, price, currencyType = GetGuildSpecificItemInfo(index)

    if(price ~= self.purchasePrice or stackCount ~= self.stackCount) then
        self.unitPrice = nil
    end

    self.slotIndex = index
    self.icon = icon
    self.name = itemName
    self.quality = quality
    self.stackCount = stackCount
    self.sellerName = GetString(SI_GUILD_HERALDRY_SELLER_NAME)
    self.purchasePrice = price
    self.currencyType = currencyType
    self.guildName = guildName
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

function ItemData:GetUnitPrice()
    if(not self.unitPrice) then
        local stackCount = self:GetStackCount()
        if(stackCount > 1) then
            self.unitPrice = tonumber(string.format("%.2f", self.purchasePrice / stackCount))
        elseif(stackCount > 0) then
            self.unitPrice = self.purchasePrice
        end
    end
    return self.unitPrice
end

function ItemData:GetSetInfo()
    if(self.hasSet == nil) then
        local hasSet, setName = GetItemLinkSetInfo(self.itemLink)
        self.hasSet = hasSet
        self.setName = setName
    end
    return self.hasSet, self.setName
end

function ItemData:GetDataEntry(type)
    if(self.name == "" or self.stackCount == 0) then return end
    if(not self.dataEntry) then
        ZO_ScrollList_CreateDataEntry(type, self)
        self:GetStackCount()
        self:GetUnitPrice()
        self:GetSetInfo()
    else
        self.dataEntry.typeId = type
    end
    return self.dataEntry
end
