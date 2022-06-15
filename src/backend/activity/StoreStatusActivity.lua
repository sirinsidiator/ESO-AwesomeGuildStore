local AGS = AwesomeGuildStore

local ActivityBase = AGS.class.ActivityBase

local logger = AGS.internal.logger
local gettext = AGS.internal.gettext
local RegisterForEvent = AGS.internal.RegisterForEvent
local UnregisterForEvent = AGS.internal.UnregisterForEvent
local TradingHouseStatus = AGS.internal.TradingHouseStatus

local Promise = LibPromises
local sformat = string.format

local StoreStatusActivity = ActivityBase:Subclass()
AGS.class.StoreStatusActivity = StoreStatusActivity

function StoreStatusActivity:New(...)
    return ActivityBase.New(self, ...)
end

function StoreStatusActivity:Initialize(tradingHouseWrapper)
    local key = StoreStatusActivity.CreateKey()
    ActivityBase.Initialize(self, tradingHouseWrapper, key, ActivityBase.PRIORITY_HIGH)
    self.canExecute = true
    self.interactionHelper = tradingHouseWrapper.interactionHelper
end

function StoreStatusActivity:DoExecute()
    logger:Debug("Execute StoreStatusActivity")
    self.canExecute = false
    self.interactionHelper:SetStatus(TradingHouseStatus.CONNECTING)
    return self:WaitForStatus():Then(self.WaitForInitialSetup):Then(self.HandleStatusReceived)
end

function StoreStatusActivity:WaitForStatus()
    local promise = Promise:New()

    local eventHandle

    local function CleanUp()
        self.CleanUp = nil
        UnregisterForEvent(EVENT_TRADING_HOUSE_STATUS_RECEIVED, eventHandle)
    end
    self.CleanUp = CleanUp

    eventHandle = RegisterForEvent(EVENT_TRADING_HOUSE_STATUS_RECEIVED, function()
        CleanUp()
        promise:Resolve(self)
    end)
    self:SetState(ActivityBase.STATE_AWAITING_RESPONSE)

    return promise
end

function StoreStatusActivity:WaitForInitialSetup()
    local promise = Promise:New()

    if not self.tradingHouseWrapper.initialized then
        local onInit

        local function CleanUp()
            self.CleanUp = nil
            AGS:UnregisterCallback(AGS.callback.AFTER_INITIAL_SETUP, onInit)
        end
        self.CleanUp = CleanUp

        onInit = function()
            CleanUp()
            self:SetState(ActivityBase.STATE_SUCCEEDED)
            promise:Resolve(self)
        end
        AGS:RegisterCallback(AGS.callback.AFTER_INITIAL_SETUP, onInit)
    else
        self:SetState(ActivityBase.STATE_SUCCEEDED)
        promise:Resolve(self)
    end

    return promise
end

function StoreStatusActivity:HandleStatusReceived()
    local promise = Promise:New()
    self.interactionHelper:SetStatus(TradingHouseStatus.CONNECTED)
    promise:Resolve(self)
    return promise
end

function StoreStatusActivity:GetErrorMessage()
    -- TRANSLATORS: error text shown to the user when the trading house failed to initialize
    return gettext("Store initialization failed")
end

function StoreStatusActivity:GetLogEntry()
    if not self.logEntry then
        -- TRANSLATORS: log text shown to the user for the initial wait for the trading house status
        self.logEntry = gettext("Wait for trading house status")
    end
    return self.logEntry
end

function StoreStatusActivity:GetType()
    return ActivityBase.ACTIVITY_TYPE_STORE_STATE
end

function StoreStatusActivity.CreateKey()
    return sformat("%d", ActivityBase.ACTIVITY_TYPE_STORE_STATE)
end