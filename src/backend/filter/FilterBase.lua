local AGS = AwesomeGuildStore

local gettext = AGS.internal.gettext


local FilterBase = ZO_Object:Subclass()
AGS.class.FilterBase = FilterBase

FilterBase.GROUP_NONE = 1
FilterBase.GROUP_CATEGORY = 2
FilterBase.GROUP_SERVER = 3
FilterBase.GROUP_LOCAL = 4
FilterBase.GROUP_SORT = 5

function FilterBase:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

-- can be overwritten, but make sure to call FilterBase.Initialize(id, group, label)!
function FilterBase:Initialize(id, group, label)
    self.id = id
    self.group = group
    self.attached = false -- TODO: save which filters are attached
    self.pinned = true -- TODO: save which filters are pinned
    self.label = label
    self.enabledSubcategory = {}
    self.dirty = true -- flag can be used to detect filter changes and do lazy updates
end

function FilterBase:GetId()
    return self.id
end

function FilterBase:GetGroup()
    return self.group
end

function FilterBase:SetEnabledSubcategories(categories)
    self.enabledSubcategory = categories or self.enabledSubcategory
end

function FilterBase:CanFilter(subcategory)
    return self.enabledSubcategory[subcategory.id] == true
end

function FilterBase:Attach()
    self.attached = true
end

function FilterBase:Detach()
    self.attached = false
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

function FilterBase:GetLabel()
    return self.label
end

function FilterBase:GetTooltipText(...)
    return ""
end

function FilterBase:HandleChange(...)
    self.dirty = true
    AGS.internal:FireCallbacks(AGS.callback.FILTER_VALUE_CHANGED, self.id, ...)
end

function FilterBase:IsLocal()
    return true
end

function FilterBase:PrepareForSearch(...)
    -- this function can be used to prepare a server filter before it has to be applied
    -- when true is returned, the search will wait for a FILTER_PREPARED callback to fire for each filter that requires preparation
    return false
end

function FilterBase:ApplyToSearch(request)
-- this function can be used to manipulate the server filters
end

function FilterBase:GetValues()
-- returns the arguments for SetUpLocalFilter, PrepareForSearch and SetValues
end

function FilterBase:SetValues(...)
end

function FilterBase:SetFromItem(itemLink)
-- this function is used to set up the filter when looking for a specific item
end

function FilterBase:SetUpLocalFilter(...)
    --	return true when the filter actually has work to do
    return not self:IsDefault(...)
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

function FilterBase:IsDefault(...)
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
