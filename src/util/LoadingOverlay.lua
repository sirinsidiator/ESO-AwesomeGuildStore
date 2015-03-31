local LoadingOverlay = ZO_Object:Subclass()
AwesomeGuildStore.LoadingOverlay = LoadingOverlay

function LoadingOverlay:New(name)
	local overlay = ZO_Object.New(self)

	local control = WINDOW_MANAGER:CreateControl(name, GuiRoot, CT_BACKDROP)
	control:SetHidden(true)
	control:SetMouseEnabled(true)
	control:SetIntegralWrapping(true)
	control:SetCenterTexture("EsoUI/Art/ChatWindow/chat_BG_center.dds")
	control:SetEdgeTexture("EsoUI/Art/ChatWindow/chat_BG_edge.dds", 256, 256, 32)
	control:SetInsets(32, 32, -32, -32)
	local loadingIcon = CreateControlFromVirtual(name .. "Icon", control, "AwesomeGuildStoreLoadingTemplate")
	loadingIcon:SetAnchor(CENTER, control, CENTER, 0, 0)
	loadingIcon.animation = ANIMATION_MANAGER:CreateTimelineFromVirtual("LoadIconAnimation", loadingIcon:GetNamedChild("Icon"))

	overlay.control = control
	overlay.loadingAnimation = loadingIcon.animation

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
	self.loadingAnimation:PlayForward()
	self.control:SetHidden(false)
end

function LoadingOverlay:Hide()
	self.control:SetHidden(true)
	self.loadingAnimation:Stop()
end
