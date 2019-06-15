local AGS = AwesomeGuildStore

local BaseItemDatabaseView = AGS.class.BaseItemDatabaseView

local ItemDatabaseGuildView = BaseItemDatabaseView:Subclass()
AGS.class.ItemDatabaseGuildView = ItemDatabaseGuildView

function ItemDatabaseGuildView:New(...)
    return BaseItemDatabaseView.New(self, ...)
end

function ItemDatabaseGuildView:Initialize(itemDatabase, guildId)
    BaseItemDatabaseView.Initialize(self)
    self.itemDatabase = itemDatabase
    self.guildId = guildId
end

function ItemDatabaseGuildView:UpdateItems()
    local itemDatabase = self.itemDatabase
    local guildId = self.guildId
    local items = self.items
    ZO_ClearNumericallyIndexedTable(items)

    if(itemDatabase:HasGuildSpecificItems(guildId)) then
        local guildItemData = itemDatabase:GetOrCreateGuildItemDataForGuild(guildId)
        for i = 1, #guildItemData do
            items[i] = guildItemData[i]
        end
    end

    local data = itemDatabase:GetOrCreateDataForGuild(guildId)
    for _, item in pairs(data) do
        items[#items + 1] = item
    end
end
