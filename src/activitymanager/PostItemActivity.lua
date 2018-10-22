local AGS = AwesomeGuildStore

local ActivityBase = AGS.class.ActivityBase

local logger = AGS.internal.logger
local gettext = AGS.internal.gettext

local sformat = string.format


local PostItemActivity = ActivityBase:Subclass()
AGS.class.PostItemActivity = PostItemActivity

function PostItemActivity:New(...)
    return ActivityBase.New(self, ...)
end

function PostItemActivity:Initialize(tradingHouseWrapper, guildId, bagId, slotIndex, stackCount, price, uniqueId)
    local key = PostItemActivity.nextKey or PostItemActivity.CreateKey()
    PostItemActivity.nextKey = nil

    ActivityBase.Initialize(self, tradingHouseWrapper, key, ActivityBase.PRIORITY_HIGH, guildId)
    self.bagId = bagId
    self.slotIndex = slotIndex
    self.stackCount = stackCount
    self.price = price
    self.uniqueId = uniqueId
end

function PostItemActivity:Update()
    self.canExecute = self.guildSelection:IsAppliedGuildId(self.guildId) or (GetTradingHouseCooldownRemaining() == 0)
end

function PostItemActivity:DoExecute() -- TODO: make this method handle both regular and craft bag listings
    if(not self.guildSelection:ApplySelectedGuildId(self.guildId)) then
        logger:Warn(sformat("Could not select %s for post operation", GetGuildName(self.guildId)))
        return false
    end

    local uniqueId = GetItemUniqueId(self.bag, self.slotIndex)
    local _, stackCount = GetItemInfo(self.bagId, self.slotIndex)
    if(uniqueId ~= self.uniqueId or stackCount < self.stackCount) then
        logger:Warn(sformat("Inventory item doesn't match for post operation (%s => %s, %d => %d)", Id64ToString(uniqueId), Id64ToString(self.uniqueId), stackCount, self.stackCount))
        return false
    end

    RequestPostItemOnTradingHouse(self.bag, self.slotIndex, self.stackCount, self.price)
    return true
end

function PostItemActivity:GetErrorMessage()
    -- TRANSLATORS: error text shown to the user when an item could not be listed
    return gettext("Could not list item")
end

function PostItemActivity:GetLogEntry()
    if(not self.logEntry) then
        -- TRANSLATORS: log text shown to the user for each post item request. Placeholders are for the stackCount, itemLink, price and guild name respectively
        self.logEntry = zo_strformat(gettext("Post <<1>>x <<2>> for <<3>> to <<4>>"), self.stackCount, GetItemLink(self.bag, self.slotIndex), self.price, GetGuildName(self.guildId))
    end
    return self.logEntry
end

function PostItemActivity:GetType()
    return ActivityBase.ACTIVITY_TYPE_POST_ITEM
end

function PostItemActivity.CreateKey()
    -- post requests can always be queued, so we just generate random keys, yet we want to keep one until it really gets used to avoid problems
    if(not PostItemActivity.nextKey) then
        PostItemActivity.nextKey = sformat("%d_%d_%f", ActivityBase.ACTIVITY_TYPE_POST_ITEM, GetTimeStamp(), math.random())
    end
    return PostItemActivity.nextKey
end
