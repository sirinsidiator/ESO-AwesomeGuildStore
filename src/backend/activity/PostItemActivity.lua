local AGS = AwesomeGuildStore

local ActivityBase = AGS.class.ActivityBase

local logger = AGS.internal.logger
local gettext = AGS.internal.gettext
local RegisterForEvent = AGS.internal.RegisterForEvent
local UnregisterForEvent = AGS.internal.UnregisterForEvent

local Promise = LibPromises
local sformat = string.format


local MOVE_ITEM_TIMEOUT = 10000

local STEP_BEGIN_EXECUTION = 1
local STEP_OPEN_BANK = 2
local STEP_MOVE_ITEM = 3
local STEP_CLOSE_BANK = 4
local STEP_SET_PENDING = 5
local STEP_POST_ITEM = 6
local STEP_FINALIZE_POSTING = 7

local STEP_TO_STRING = {
    [STEP_BEGIN_EXECUTION] = "STEP_BEGIN_EXECUTION",
    [STEP_OPEN_BANK] = "STEP_OPEN_BANK",
    [STEP_MOVE_ITEM] = "STEP_MOVE_ITEM",
    [STEP_CLOSE_BANK] = "STEP_CLOSE_BANK",
    [STEP_SET_PENDING] = "STEP_SET_PENDING",
    [STEP_POST_ITEM] = "STEP_POST_ITEM",
    [STEP_FINALIZE_POSTING] = "STEP_FINALIZE_POSTING",
}

local PostItemActivity = ActivityBase:Subclass()
AGS.class.PostItemActivity = PostItemActivity

function PostItemActivity:New(...)
    return ActivityBase.New(self, ...)
end

function PostItemActivity:Initialize(tradingHouseWrapper, guildId, bagId, slotIndex, stackCount, price)
    local key = PostItemActivity.nextKey or PostItemActivity.CreateKey()
    PostItemActivity.nextKey = nil

    ActivityBase.Initialize(self, tradingHouseWrapper, key, ActivityBase.PRIORITY_HIGH, guildId)
    self.bagId = bagId
    self.slotIndex = slotIndex
    self.stackCount = stackCount
    self.price = price
    self.itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
    self.interactionHelper = tradingHouseWrapper.interactionHelper
end

function PostItemActivity:Update()
    self.canExecute = self.tradingHouseWrapper:IsConnected() and self.guildSelection:IsAppliedGuildId(self.guildId) or (GetTradingHouseCooldownRemaining() == 0)
end

local function GetItemStackCount(bagId, slotIndex)
    local _, stackCount = GetItemInfo(bagId, slotIndex)
    return stackCount
end

function PostItemActivity:MoveItemIfNeeded()
    local promise = Promise:New()

    if self.bagId ~= BAG_BACKPACK or self.stackCount ~= GetItemStackCount(self.bagId, self.slotIndex) then
        if self.interactionHelper:IsBankBag(self.bagId) then
            promise = self:OpenBank():Then(self.DoMoveItem):Then(self.CloseBank)
        else
            promise = self:DoMoveItem()
        end
    else
        self.effectiveSlotIndex = self.slotIndex
        promise:Resolve(self)
    end

    return promise
end

function PostItemActivity:DoMoveItem()
    local promise = Promise:New()

    self.step = STEP_MOVE_ITEM
    self.effectiveSlotIndex = FindFirstEmptySlotInBag(BAG_BACKPACK)

    local eventHandle, timeoutHandle

    local function CleanUp()
        self.CleanUp = nil
        UnregisterForEvent(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, eventHandle)
        zo_removeCallLater(timeoutHandle)
    end
    self.CleanUp = CleanUp

    eventHandle = RegisterForEvent(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(_, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
        if bagId == BAG_BACKPACK and slotId == self.effectiveSlotIndex then
            CleanUp()
            promise:Resolve(self)
        end
    end)
    timeoutHandle = zo_callLater(function()
        CleanUp()
        self:SetState(ActivityBase.STATE_FAILED, ActivityBase.ERROR_OPERATION_TIMEOUT)
        promise:Reject(self)
    end, MOVE_ITEM_TIMEOUT)

    CallSecureProtected("RequestMoveItem", self.bagId, self.slotIndex, BAG_BACKPACK, self.effectiveSlotIndex, self.stackCount)
    return promise
end

function PostItemActivity:OpenBank()
    self.step = STEP_OPEN_BANK
    return self.interactionHelper:OpenBank(self)
end

function PostItemActivity:CloseBank()
    self.step = STEP_CLOSE_BANK
    return self.interactionHelper:CloseBank(self)
end

function PostItemActivity:IsClosingBank()
    return self.step == STEP_CLOSE_BANK
end

function PostItemActivity:SetPending()
    local promise = Promise:New()
    self.responsePromise = promise
    self.step = STEP_SET_PENDING

    local eventHandle
    eventHandle = RegisterForEvent(EVENT_TRADING_HOUSE_PENDING_ITEM_UPDATE, function(_, slotId, isPending)
        if isPending and slotId == self.effectiveSlotIndex then
            UnregisterForEvent(EVENT_TRADING_HOUSE_PENDING_ITEM_UPDATE, eventHandle)
            promise:Resolve(self)
        end
    end)

    SetPendingItemPost(BAG_BACKPACK, self.effectiveSlotIndex, self.stackCount)

    return promise
end

function PostItemActivity:PostItem()
    self.step = STEP_POST_ITEM
    self.responsePromise = Promise:New()
    RequestPostItemOnTradingHouse(BAG_BACKPACK, self.effectiveSlotIndex, self.stackCount, self.price)
    return self.responsePromise
end

function PostItemActivity:FinalizePosting()
    local promise = Promise:New()
    self.step = STEP_FINALIZE_POSTING

    AGS.internal:FireCallbacks(AGS.callback.ITEM_POSTED, self.guildId, self.itemLink, self.price, self.stackCount)
    promise:Resolve(self)

    return promise
end

function PostItemActivity:DoExecute()
    logger:Debug("Execute PostItemActivity")
    self.step = STEP_BEGIN_EXECUTION
    return self:ApplyGuildId():Then(self.MoveItemIfNeeded):Then(self.SetPending):Then(self.PostItem):Then(self.FinalizePosting)
end

function PostItemActivity:GetErrorMessage()
    -- TRANSLATORS: error text shown to the user when an item could not be listed
    return gettext("Could not list item")
end

function PostItemActivity:GetLogEntry()
    if not self.logEntry then
        local price = ZO_Currency_FormatPlatform(CURT_MONEY, self.price, ZO_CURRENCY_FORMAT_AMOUNT_ICON)
        -- TRANSLATORS: log text shown to the user for each post item request. Placeholders are for the stackCount, itemLink, price and guild name respectively
        self.logEntry = gettext("Post <<1>>x <<2>> for <<3>> to <<4>>", self.stackCount, self.itemLink, price, GetGuildName(self.guildId))
    end
    return self.logEntry
end

function PostItemActivity:AddTooltipText(output)
    ActivityBase.AddTooltipText(self, output)
    if self.step then -- TODO translate
        output[#output + 1] = ActivityBase.TOOLTIP_LINE_TEMPLATE:format("Step", STEP_TO_STRING[self.step])
    end
end

function PostItemActivity:GetType()
    return ActivityBase.ACTIVITY_TYPE_POST_ITEM
end

function PostItemActivity.CreateKey()
    -- post requests can always be queued, so we just generate random keys, yet we want to keep one until it really gets used to avoid problems
    if not PostItemActivity.nextKey then
        PostItemActivity.nextKey = sformat("%d_%d_%f", ActivityBase.ACTIVITY_TYPE_POST_ITEM, GetTimeStamp(), math.random())
    end
    return PostItemActivity.nextKey
end
