local ActivityBase = ZO_Object:Subclass()
AwesomeGuildStore.ActivityBase = ActivityBase

ActivityBase.ACTIVITY_TYPE_CANCEL_SALE = 1
ActivityBase.ACTIVITY_TYPE_REQUEST_LISTINGS = 2
ActivityBase.ACTIVITY_TYPE_POST_ITEM = 3
ActivityBase.ACTIVITY_TYPE_PURCHASE_ITEM = 4
ActivityBase.ACTIVITY_TYPE_EXECUTE_SEARCH = 5
ActivityBase.ACTIVITY_TYPE_SWITCH_GUILD = 6

function ActivityBase:New(tradingHouseWrapper, ...)
	local selector = ZO_Object.New(self)
	selector.tradingHouseWrapper = tradingHouseWrapper
	selector:Initialize(...)
	return selector
end

function ActivityBase:Initialize()
end

local lastGuildId = 1

function ActivityBase:PushTradingHouseGuildId(guildId)
	--df("PushTradingHouseGuildId(%d)", guildId)
	lastGuildId = GetSelectedTradingHouseGuildId()
	SelectTradingHouseGuildId(guildId, true)
end

function ActivityBase:PopTradingHouseGuildId()
	--df("PopTradingHouseGuildId(%d)", lastGuildId)
	SelectTradingHouseGuildId(lastGuildId, true)
end

function ActivityBase:CanExecute()
	return false
end

function ActivityBase:DoExecute()
end

function ActivityBase:GetKey()
	return ""
end
