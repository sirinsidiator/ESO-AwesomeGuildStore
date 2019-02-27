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

function EditControlGroup:OnTabPressed(index)
    local newIndex = index

    local direction = (IsShiftKeyDown() and -1 or 1)
    local lastIndex = #self.controls
    while true do
        newIndex = newIndex + direction
        if newIndex < 1 then
            newIndex = lastIndex
        elseif newIndex > lastIndex then
            newIndex = 1
        end

        if(newIndex == index or self.controls[newIndex]:IsEnabled()) then
            break
        end
    end

    self.controls[newIndex]:TakeFocus()
end

function EditControlGroup:InsertControl(control, position)
    if(control:GetEditControlGroupIndex()) then return false end

    if(not position) then position = #self.controls + 1 end
    table.insert(self.controls, position, control)
    control:SetHandler("OnTab", function()
        return self:OnTabPressed(control:GetEditControlGroupIndex())
    end)
    self:UpdateIndices()
    return true
end

function EditControlGroup:RemoveControl(control)
    local groupIndex = control:GetEditControlGroupIndex()
    if(self.controls[groupIndex] ~= control) then return false end

    table.remove(self.controls, groupIndex)
    control:SetEditControlGroupIndex(nil)
    control:SetHandler("OnTab", nil)
    self:UpdateIndices()
    return true
end

function EditControlGroup:Clear()
    for i = 1, #self.controls do
        local control = self.controls[i]
        control:SetEditControlGroupIndex(nil)
        control:SetHandler("OnTab", nil)
        self.controls[i] = nil
    end
end

function EditControlGroup:UpdateIndices()
    for i = 1, #self.controls do
        self.controls[i]:SetEditControlGroupIndex(i)
    end
end
