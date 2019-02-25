local LoadingIcon = ZO_Object:Subclass()
AwesomeGuildStore.class.LoadingIcon = LoadingIcon

local function IconFactory(pool)
	return LoadingIcon:New("AwesomeGuildStoreLoadingIcon" .. pool:GetNextControlId())
end

local function ResetFunction(icon)
	icon:Hide()
	local control = icon.control
	control:SetParent(GuiRoot)
	control:ClearAnchors()
	icon.key = nil
end

LoadingIcon.iconPool = ZO_ObjectPool:New(IconFactory, ResetFunction)

function LoadingIcon.Aquire()
	local icon, key = LoadingIcon.iconPool:AcquireObject()
	icon.key = key
	return icon
end

function LoadingIcon:Release()
	LoadingIcon.iconPool:ReleaseObject(self.key)
end

function LoadingIcon:New(name)
	local object = ZO_Object.New(self)

	local control = CreateControlFromVirtual(name, GuiRoot, "AwesomeGuildStoreLoadingTemplate")
	control:SetHidden(true)
	object.animation = ANIMATION_MANAGER:CreateTimelineFromVirtual("LoadIconAnimation", control:GetNamedChild("Icon"))
	object.control = control

	return object
end

function LoadingIcon:SetParent(parent)
	local control = self.control
	control:SetParent(parent)
	control:SetDrawTier(parent:GetDrawTier())
	control:SetDrawLayer(parent:GetDrawLayer())
	control:SetDrawLevel(parent:GetDrawLevel() + 1)
	control:ClearAnchors()
	control:SetAnchor(CENTER, parent, CENTER, 0, 0)
end

function LoadingIcon:ClearAnchors()
	self.control:ClearAnchors()
end

function LoadingIcon:SetAnchor(point, target, relativePoint, offsetX, offsetY)
	self.control:SetAnchor(point, target, relativePoint, offsetX, offsetY)
end

function LoadingIcon:Show()
	self.animation:PlayForward()
	self.control:SetHidden(false)
end

function LoadingIcon:Hide()
	self.control:SetHidden(true)
	self.animation:Stop()
end

local LoadingOverlay = ZO_Object:Subclass()
AwesomeGuildStore.class.LoadingOverlay = LoadingOverlay

function LoadingOverlay:New(name)
	local overlay = ZO_Object.New(self)

	local control = WINDOW_MANAGER:CreateControl(name, GuiRoot, CT_BACKDROP)
	control:SetHidden(true)
	control:SetMouseEnabled(true)
	control:SetIntegralWrapping(true)
	control:SetCenterTexture("EsoUI/Art/ChatWindow/chat_BG_center.dds")
	control:SetEdgeTexture("EsoUI/Art/ChatWindow/chat_BG_edge.dds", 256, 256, 32)
	control:SetInsets(32, 32, -32, -32)
	local loadingIcon = LoadingIcon:New(name .. "Icon")
	loadingIcon:SetParent(control)

	overlay.control = control
	overlay.loadingIcon = loadingIcon

	return overlay
end

function LoadingOverlay:SetParent(parent)
	local control = self.control
	control:SetParent(parent)
	control:SetDrawTier(parent:GetDrawTier())
	control:SetDrawLayer(parent:GetDrawLayer())
	control:SetDrawLevel(parent:GetDrawLevel() + 1)
	control:ClearAnchors()
	control:SetAnchor(TOPLEFT, parent, TOPLEFT, -10, -10)
	control:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT, 10, 10)
end

function LoadingOverlay:Show()
	self.loadingIcon:Show()
	self.control:SetHidden(false)
end

function LoadingOverlay:Hide()
	self.control:SetHidden(true)
	self.loadingIcon:Hide()
end
