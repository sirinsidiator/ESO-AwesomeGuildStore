local AGS = AwesomeGuildStore

local BaseItemDatabaseView = AGS.class.BaseItemDatabaseView

local ItemDatabaseGuildView = BaseItemDatabaseView:Subclass()
AGS.class.ItemDatabaseGuildView = ItemDatabaseGuildView

function ItemDatabaseGuildView:New(...)
    return BaseItemDatabaseView.New(self, ...)
end

function ItemDatabaseGuildView:Initialize(itemDatabase, guildName)
    BaseItemDatabaseView.Initialize(self)
    self.itemDatabase = itemDatabase
    self.guildName = guildName
end

function ItemDatabaseGuildView:UpdateItems()
    local itemDatabase = self.itemDatabase
    local guildName = self.guildName
    local items = self.items
    ZO_ClearNumericallyIndexedTable(items)

    if(itemDatabase:HasGuildSpecificItems(guildName)) then
        local guildItemData = itemDatabase:GetOrCreateGuildItemDataForGuild(guildName)
        for i = 1, #guildItemData do
            items[i] = guildItemData[i]
        end
    end

    local data = itemDatabase:GetOrCreateDataForGuild(guildName)
    for _, item in pairs(data) do
        items[#items + 1] = item
    end
end
