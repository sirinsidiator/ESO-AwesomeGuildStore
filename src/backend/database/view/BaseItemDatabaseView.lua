local AGS = AwesomeGuildStore

local BaseItemDatabaseView = ZO_Object:Subclass()
AGS.class.BaseItemDatabaseView = BaseItemDatabaseView

BaseItemDatabaseView.CLASS_BY_GROUP = {}

function BaseItemDatabaseView:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function BaseItemDatabaseView:Initialize()
    self.items = {}
    self.parent = nil
    self.children = {}
    self.dirty = true
end

function BaseItemDatabaseView:MarkDirty()
    self.dirty = true
    for _, child in pairs(self.children) do
        child:MarkDirty()
    end
end

function BaseItemDatabaseView:GetSubView(searchManager, filterState, group, subcategory)
    local groupState = filterState:GetGroupState(group)
    local subView = self.children[groupState]
    if(not subView) then
        local groupValues = filterState:GetGroupValues(group)
        local viewClass = BaseItemDatabaseView.CLASS_BY_GROUP[group]
        subView = viewClass:New(searchManager, groupValues, subcategory)
        subView.parent = self
        self.children[groupState] = subView
    end
    return subView
end

function BaseItemDatabaseView:UpdateItems()
    -- to be overwritten
end

function BaseItemDatabaseView:GetItems()
    if(self.dirty) then
        self:UpdateItems()
        self.dirty = false
    end
    return self.items
end
