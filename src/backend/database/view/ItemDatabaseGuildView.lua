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
    df("update items for %s", self.guildName)
    local items = self.items
    ZO_ClearNumericallyIndexedTable(items)

    local data = self.itemDatabase:GetOrCreateDataForGuild(self.guildName)
    for _, item in pairs(data) do
        items[#items + 1] = item
    end
    -- TODO: add guild specific items -> maybe in the database itself?
end
