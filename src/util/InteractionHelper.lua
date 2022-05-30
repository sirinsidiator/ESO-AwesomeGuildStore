local AGS = AwesomeGuildStore

local ActivityBase = AGS.class.ActivityBase

local logger = AGS.internal.logger
local RegisterForEvent = AGS.internal.RegisterForEvent
local UnregisterForEvent = AGS.internal.UnregisterForEvent
local IsAtGuildKiosk = AGS.internal.IsAtGuildKiosk
local TradingHouseStatus = AGS.internal.TradingHouseStatus

local Promise = LibPromises

local OPERATION_TIMEOUT = 5000
local WATCHDOG_INTERVAL = 50
local CLOSE_TRADINGHOUSE_WATCHDOG_NAME = "AGS_CloseBankWatchdog"
local UPDATE_HANDLE_PREFIX = "AGS_Interaction_"

local InteractionHelper = ZO_InitializingObject:Subclass()
AGS.class.InteractionHelper = InteractionHelper

function InteractionHelper:Initialize(tradingHouseWrapper, saveData)
    self.tradingHouseWrapper = tradingHouseWrapper
    self.wasBankOpened = false
    self.suppressBankScene = false
    self.status = TradingHouseStatus.DISCONNECTED

    local INTERACT_WINDOW_SHOWN = "Shown"
    INTERACT_WINDOW:RegisterCallback(INTERACT_WINDOW_SHOWN, function()
        self:UpdateChatterIndices()
        if IsShiftKeyDown() or not saveData.skipGuildKioskDialog then return end
        if IsAtGuildKiosk() then
            SelectChatterOption(self.tradingHouseChatterIndex)
        end
    end)

    ZO_PreHook("EndInteraction", function(type)
        if type == INTERACTION_CONVERSATION and self.status == TradingHouseStatus.CONNECTING then
            -- it seems to somehow interfere with opening the trading house interaction, 
            -- but not always, so we have to prevent it for more reliability
            return true
        end
    end)

    ZO_PreHook(TRADING_HOUSE_SCENE, "OnSceneHidden", function()
        return true -- we handle ending interactions ourselves
    end)

    ZO_PreHook(ZO_InventoryManager, "GetBankInventoryType", function()
        if self.suppressBankScene then
            return true
        end
    end)

    SecurePostHook("SelectChatterOption", function(index)
        if index == self.tradingHouseChatterIndex then
            tradingHouseWrapper:OnBeforeOpenTradingHouse()
        end
    end)

end

function InteractionHelper:EndInteraction()
    if self.wasBankOpened then
        self.wasBankOpened = false
        SelectChatterOption(self.bankChatterIndex)
        EVENT_MANAGER:RegisterForUpdate(CLOSE_TRADINGHOUSE_WATCHDOG_NAME, WATCHDOG_INTERVAL, function()
            if GetInteractionType() == INTERACTION_BANK then
                EVENT_MANAGER:UnregisterForUpdate(CLOSE_TRADINGHOUSE_WATCHDOG_NAME)
                EndInteraction(INTERACTION_BANK)
                EndInteraction(INTERACTION_TRADINGHOUSE)
            end
        end)
    else
        EndInteraction(INTERACTION_TRADINGHOUSE)
    end
end

function InteractionHelper:SetStatus(status)
    local oldStatus = self.status
    self.status = status
    logger:Verbose("TRADING_HOUSE_STATUS_CHANGED", status, oldStatus)
    AGS.internal:FireCallbacks(AGS.callback.TRADING_HOUSE_STATUS_CHANGED, status, oldStatus)
end

function InteractionHelper:IsConnected()
    return self.status == TradingHouseStatus.CONNECTED
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
    local updateHandle = UPDATE_HANDLE_PREFIX .. activity.key

    local function CleanUp()
        activity.CleanUp = nil
        self.suppressBankScene = false
        UnregisterForEvent(EVENT_OPEN_BANK, eventHandle)
        zo_removeCallLater(timeoutHandle)
        EVENT_MANAGER:UnregisterForUpdate(updateHandle)
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
    -- there are situations where we have the correct type available in the update early and the event still fires afterwards
    -- we need to wait one interval for that to work correctly
    local hasWaited = false
    EVENT_MANAGER:RegisterForUpdate(updateHandle, WATCHDOG_INTERVAL, function()
        if GetInteractionType() == INTERACTION_BANK then
            if hasWaited then
                CleanUp()
                promise:Resolve(activity)
            else
                hasWaited = true
            end
        end
    end)

    self.wasBankOpened = true
    self.suppressBankScene = true
    SelectChatterOption(self.bankChatterIndex)
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

    local function CleanUp()
        activity.CleanUp = nil
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