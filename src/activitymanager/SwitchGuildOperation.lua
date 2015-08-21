local ActivityBase = AwesomeGuildStore.ActivityBase

local SwitchGuildOperation = ActivityBase:Subclass()
AwesomeGuildStore.SwitchGuildOperation = SwitchGuildOperation

function SwitchGuildOperation:New(...)
	return ActivityBase.New(self, ...)
end

function SwitchGuildOperation:Initialize(guildId)
	self.priority = 0
	self.type = ActivityBase.ACTIVITY_TYPE_SWITCH_GUILD
	self.guildId = guildId
end

function SwitchGuildOperation:CanExecute()
	return self.tradingHouseWrapper.tradingHouse:CanDoCommonOperation() and GetSelectedTradingHouseGuildId() ~= nil
end

function SwitchGuildOperation:DoExecute()
	SelectTradingHouseGuildId(self.guildId)
end

function SwitchGuildOperation:GetKey()
	return string.format("%d_%d", self.type, self.guildId)
end
