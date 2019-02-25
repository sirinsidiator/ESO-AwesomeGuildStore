local AGS = AwesomeGuildStore

local gettext = AGS.internal.gettext


local FilterBase = ZO_Object:Subclass()
AGS.class.FilterBase = FilterBase

FilterBase.GROUP_NONE = 1
FilterBase.GROUP_CATEGORY = 2
FilterBase.GROUP_SERVER = 3
FilterBase.GROUP_LOCAL = 4

function FilterBase:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

-- can be overwritten, but make sure to call FilterBase.Initialize(id, group)!
function FilterBase:Initialize(id, group)
    self.id = id
    self.group = group
    self.searchManager = nil
    self.attached = false -- TODO: save which filters are attached
    self.pinned = true -- TODO: save which filters are pinned
    self.label = "undefined"
    self.enabledSubcategory = {}
    self.dirty = true -- flag can be used to detect filter changes and do lazy updates
end

function FilterBase:GetId()
    return self.id
end

function FilterBase:GetGroup()
    return self.group
end

function FilterBase:SetSearchManager(searchManager)
    self.searchManager = searchManager
end

function FilterBase:SetEnabledSubcategories(categories)
    self.enabledSubcategory = categories or self.enabledSubcategory
end

function FilterBase:CanAttach(subcategory)
    return self.enabledSubcategory[subcategory.id] == true
end

function FilterBase:Attach()
    self:OnAttached()
    self.attached = true
end

function FilterBase:Detach()
    self:OnDetached()
    self.attached = false
end

function FilterBase:OnAttached()
-- can be used for setup up when the filter is added to the panel
end

function FilterBase:OnDetached()
-- can be used for cleaning up when the filter is removed from the panel
end

function FilterBase:IsAttached()
    return self.attached
end

function FilterBase:IsPinned()
    return self.pinned
end

function FilterBase:SetPinned(pinned)
    self.pinned = pinned
end

function FilterBase:SetLabel(label)
    self.label = label
end

function FilterBase:GetLabel()
    return self.label
end

function FilterBase:GetTooltipText(...)
    return ""
end

function FilterBase:HandleChange(...)
    self.dirty = true
    AGS.internal:FireCallbacks(AGS.callback.FILTER_VALUE_CHANGED, self.id, ...)
    if(self.searchManager) then
        self.searchManager:RequestFilterUpdate()
    end
end

function FilterBase:IsLocal()
    return true
end

function FilterBase:ApplyToSearch()
-- this function can be used to manipulate the server filters
end

function FilterBase:GetValues()
-- returns the arguments for SetUpLocalFilter and SetValues
end

function FilterBase:SetValues(...)
end

function FilterBase:SetUpLocalFilter(...)
    --	return true when the filter actually has work to do
    return not self:IsDefault()
end

function FilterBase:FilterLocalResult(itemData)
    -- the filtering will stop on the first filter that returns false and just hide the item then
    return true -- if the item is visible
end

function FilterBase:TearDownLocalFilter()
-- can be used for cleaning up
end

-- these functions are used by the reset button
function FilterBase:Reset()
end

function FilterBase:IsDefault()
    return true
end

-- these functions are used by the search manager
function FilterBase:Serialize(...)
    return ""
end

function FilterBase:Deserialize(state)
    -- returns the arguments for SetUpLocalFilter, SetValues and Serialize
    return nil
end
