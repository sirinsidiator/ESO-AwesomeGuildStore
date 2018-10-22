local EditControlGroup = ZO_Object:Subclass()
AwesomeGuildStore.class.EditControlGroup = EditControlGroup

function EditControlGroup:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function EditControlGroup:Initialize()
    self.controls = {}
end

function EditControlGroup:OnTabPressed(control)
    local index = control.editControlGroupIndex
    local newIndex = index + (IsShiftKeyDown() and -1 or 1)
    if newIndex < 1 then
        newIndex = #self.controls
    elseif newIndex > #self.controls then
        newIndex = 1
    end

    self.controls[newIndex]:TakeFocus()
end

function EditControlGroup:InsertControl(control, position)
    if(control.editControlGroupIndex) then return false end

    if(not position) then position = #self.controls + 1 end
    table.insert(self.controls, position, control)
    control:SetHandler("OnTab", function(control, ...)
        return self:OnTabPressed(control)
    end)
    self:UpdateIndices()
    return true
end

function EditControlGroup:RemoveControl(control)
    if(self.controls[control.editControlGroupIndex] ~= control) then return false end

    table.remove(self.controls, control.editControlGroupIndex)
    control.editControlGroupIndex = nil
    control:SetHandler("OnTab", nil)
    self:UpdateIndices()
    return true
end

function EditControlGroup:Clear()
    for i = 1, #self.controls do
        local control = self.controls[i]
        control.editControlGroupIndex = nil
        control:SetHandler("OnTab", nil)
        self.controls[i] = nil
    end
end

function EditControlGroup:UpdateIndices()
    for i = 1, #self.controls do
        self.controls[i].editControlGroupIndex = i
    end
end
