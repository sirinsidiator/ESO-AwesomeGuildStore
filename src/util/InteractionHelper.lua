local AGS = AwesomeGuildStore

local ActivityBase = AGS.class.ActivityBase

local logger = AGS.internal.logger
local RegisterForEvent = AGS.internal.RegisterForEvent
local UnregisterForEvent = AGS.internal.UnregisterForEvent
local IsAtGuildKiosk = AGS.internal.IsAtGuildKiosk

local Promise = LibPromises

local KIOSK_OPTION_INDEX = AGS.internal.KIOSK_OPTION_INDEX
local OPERATION_TIMEOUT = 5000
local BANK_OPEN_WATCHDOG_INTERVAL = 100
local CLOSE_TRADINGHOUSE_WATCHDOG_NAME = "AGS_CloseBankWatchdog"
local function noop() end

local InteractionHelper = ZO_InitializingObject:Subclass()
AGS.class.InteractionHelper = InteractionHelper

function InteractionHelper:Initialize(tradingHouseWrapper, saveData)
    self.tradingHouseWrapper = tradingHouseWrapper
    self.wasBankOpened = false

    local INTERACT_WINDOW_SHOWN = "Shown"
    INTERACT_WINDOW:RegisterCallback(INTERACT_WINDOW_SHOWN, function()
        self:UpdateChatterIndices()
        if IsShiftKeyDown() or not saveData.skipGuildKioskDialog then return end
        if IsAtGuildKiosk() then
            SelectChatterOption(KIOSK_OPTION_INDEX)
        end
    end)

    ZO_PreHook(TRADING_HOUSE_SCENE, "OnSceneHidden", function()
        if self.wasBankOpened then
            self.wasBankOpened = false
            SelectChatterOption(1) -- go back to the bank interaction
            EVENT_MANAGER:RegisterForUpdate(CLOSE_TRADINGHOUSE_WATCHDOG_NAME, BANK_OPEN_WATCHDOG_INTERVAL, function()
                if GetInteractionType() == INTERACTION_BANK then
                    EVENT_MANAGER:UnregisterForUpdate(CLOSE_TRADINGHOUSE_WATCHDOG_NAME)
                    EndInteraction(INTERACTION_BANK)
                    tradingHouseWrapper.tradingHouse:CloseTradingHouse()
                    tradingHouseWrapper:OnCloseTradingHouse()
                end
            end)
            return true
        end
    end)
end

function InteractionHelper:UpdateChatterIndices()
    self.bankChatterIndex = -1
    self.tradingHouseChatterIndex = -1
    for i = 1, GetChatterOptionCount() do
        local _, optionType = GetChatterOption(i)
        if optionType == CHATTER_START_BANK then
            self.bankChatterIndex = i
        elseif optionType == CHATTER_START_TRADINGHOUSE then
            self.tradingHouseChatterIndex = i
        end
    end
end

function InteractionHelper:IsBankBag(bagId)
    return bagId == BAG_BANK or bagId == BAG_SUBSCRIBER_BANK
end

function InteractionHelper:IsBankAvailable()
    return self.bankChatterIndex > 0
end

function InteractionHelper:IsGuildStoreAvailable()
    return self.tradingHouseChatterIndex > 0
end

function InteractionHelper:OpenBank(activity)
    local promise = Promise:New()

    if not self:IsBankAvailable() then
        logger:Warn("Bank option is not available")
        activity:SetState(ActivityBase.STATE_FAILED, ActivityBase.ERROR_INVALID_STATE)
        promise:Reject(activity)
        return promise
    end

    local eventHandle, timeoutHandle

    local originalGetBankInventoryType = PLAYER_INVENTORY.GetBankInventoryType
    PLAYER_INVENTORY.GetBankInventoryType = noop
    local function CleanUp()
        activity.CleanUp = nil
        PLAYER_INVENTORY.GetBankInventoryType = originalGetBankInventoryType
        UnregisterForEvent(EVENT_OPEN_BANK, eventHandle)
        zo_removeCallLater(timeoutHandle)
        EVENT_MANAGER:UnregisterForUpdate(activity.key)
    end
    activity.CleanUp = CleanUp

    eventHandle = RegisterForEvent(EVENT_OPEN_BANK, function(_, bagId)
        CleanUp()
        if bagId == BAG_BANK then
            promise:Resolve(activity)
        else
            logger:Warn("Unexpected bank bag", bagId)
            activity:SetState(ActivityBase.STATE_FAILED, ActivityBase.ERROR_INVALID_STATE)
            promise:Reject(activity)
        end
    end)
    timeoutHandle = zo_callLater(function()
        CleanUp()
        activity:SetState(ActivityBase.STATE_FAILED, ActivityBase.ERROR_OPERATION_TIMEOUT)
        promise:Reject(activity)
    end, OPERATION_TIMEOUT)
    -- the event doesn't fire reliabely when we switch between bank and store repeatedly, so we have to poll
    EVENT_MANAGER:RegisterForUpdate(activity.key, BANK_OPEN_WATCHDOG_INTERVAL, function()
        if GetInteractionType() == INTERACTION_BANK then
            CleanUp()
            promise:Resolve(activity)
        end
    end)

    SelectChatterOption(self.bankChatterIndex)
    self.wasBankOpened = true
    return promise
end

function InteractionHelper:CloseBank(activity)
    local promise = Promise:New()

    if not self:IsGuildStoreAvailable() then
        logger:Warn("Guild store option is not available")
        activity:SetState(ActivityBase.STATE_FAILED, ActivityBase.ERROR_INVALID_STATE)
        promise:Reject(activity)
        return promise
    end

    local eventHandle, timeoutHandle

    local originalOpenTradingHouse = self.tradingHouseWrapper.tradingHouse.OpenTradingHouse
    self.tradingHouseWrapper.tradingHouse.OpenTradingHouse = noop
    local function CleanUp()
        activity.CleanUp = nil
        self.tradingHouseWrapper.tradingHouse.OpenTradingHouse = originalOpenTradingHouse
        UnregisterForEvent(EVENT_TRADING_HOUSE_STATUS_RECEIVED, eventHandle)
        zo_removeCallLater(timeoutHandle)
    end
    activity.CleanUp = CleanUp

    eventHandle = RegisterForEvent(EVENT_TRADING_HOUSE_STATUS_RECEIVED, function()
        CleanUp()
        promise:Resolve(activity)
    end)
    timeoutHandle = zo_callLater(function()
        CleanUp()
        activity:SetState(ActivityBase.STATE_FAILED, ActivityBase.ERROR_OPERATION_TIMEOUT)
        promise:Reject(activity)
    end, OPERATION_TIMEOUT)

    SelectChatterOption(self.tradingHouseChatterIndex)
    return promise
end