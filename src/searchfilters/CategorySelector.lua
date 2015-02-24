local L = AwesomeGuildStore.Localization
local FILTER_PRESETS = AwesomeGuildStore.FILTER_PRESETS
local SUBFILTER_PRESETS = AwesomeGuildStore.SUBFILTER_PRESETS

local MAJOR_BUTTON_SIZE = 46
local MINOR_BUTTON_SIZE = 32
local RESET_BUTTON_SIZE = 18
local RESET_BUTTON_TEXTURE = "EsoUI/Art/Buttons/decline_%s.dds"

local RegisterForEvent = AwesomeGuildStore.RegisterForEvent
local ButtonGroup = AwesomeGuildStore.ButtonGroup
local ToggleButton = AwesomeGuildStore.ToggleButton

local CategorySelector = ZO_Object:Subclass()
AwesomeGuildStore.CategorySelector = CategorySelector

function CategorySelector:New(parent, name)
	local selector = ZO_Object.New(self)
	selector.callbackName = name .. "Changed"
	selector.type = 1

	local container = parent:CreateControl(name .. "Container", CT_CONTROL)
	container:SetResizeToFitDescendents(true)
	selector.control = container
	selector.group = {}
	selector.subfilters = {}
	selector.category = ITEMFILTERTYPE_ALL
	selector.subcategory = {}

	local group = ButtonGroup:New(container, name .. "MainGroup", 0, 0)
	local label = group.control:CreateControl(name .. "Label", CT_LABEL)
	label:SetFont("ZoFontWinH4")
	label:SetModifyTextType(MODIFY_TEXT_TYPE_UPPERCASE)
	label:SetAnchor(TOPLEFT, group.control, TOPLEFT, 0, 13)
	group.label = label

	local divider = group.control:CreateControl(name .. "Divider", CT_TEXTURE)
	divider:SetDimensions(600, 4)
	divider:SetTexture("EsoUI/Art/Miscellaneous/centerscreen_topDivider.dds")
	divider:SetAnchor(TOPCENTER, group.control, TOPCENTER, 0, MAJOR_BUTTON_SIZE + 2)

	selector.mainGroup = group

	for category, preset in pairs(FILTER_PRESETS) do
		selector:CreateCategoryButton(group, category, preset)
		selector:CreateSubcategory(name, category, preset)
	end

	for subfilterId, preset in pairs(SUBFILTER_PRESETS) do
		selector.subfilters[subfilterId] = selector:CreateSubfilter(name .. "SubFilter" .. subfilterId, preset)
	end

	local function GetCurrentFilters()
		local filters = FILTER_PRESETS[selector.category].subcategories
		local subfilters
		local showTabards = false
		local subcategory = selector.subcategory[selector.category]
		if(subcategory) then
			if(filters[subcategory].showTabards) then showTabards = true end
			subfilters = filters[subcategory].subfilters
			filters = filters[subcategory].filters
		end
		return filters, subfilters, showTabards
	end

	ZO_PreHook(TRADING_HOUSE.m_search, "InternalExecuteSearch", function(self)
		local filters, subfilters, showTabards = GetCurrentFilters()

		for type, filterValues in pairs(filters) do
			self.m_filters[type].values = ZO_ShallowTableCopy(filterValues) -- we have to copy them, otherwise they will be cleared on the next search
		end

		if(subfilters) then
			for _, subfilterId in ipairs(subfilters) do
				local buttonGroup = selector.subfilters[subfilterId]
				if(buttonGroup) then
					local subfilterValues = {}
					for _, button in pairs(buttonGroup.buttons) do
						if(button:IsPressed()) then
							table.insert(subfilterValues, button.value)
						end
					end
					if(#subfilterValues > 0) then
						self.m_filters[buttonGroup.type].values = subfilterValues
					end
				end
			end
		end
	end)

	return selector
end

function CategorySelector:CreateSubfilter(name, subfilterPreset)
	if(not subfilterPreset.buttons) then return end
	local group = self:CreateSubfilterGroup(name .. "Group", subfilterPreset)
	group.label = group.control:CreateControl(name .. "Label", CT_LABEL)
	group.label:SetFont("ZoFontWinH4")
	group.label:SetText(subfilterPreset.label .. ":")
	group.label:SetAnchor(TOPLEFT, group.control, TOPLEFT, 0, 0)
	for index, buttonPreset in ipairs(subfilterPreset.buttons) do
		self:CreateSubfilterButton(group, index, buttonPreset, subfilterPreset)
	end

	local resetButton = CreateControlFromVirtual(name .. "ResetButton", group.control, "ZO_DefaultButton")
	resetButton:SetNormalTexture(RESET_BUTTON_TEXTURE:format("up"))
	resetButton:SetPressedTexture(RESET_BUTTON_TEXTURE:format("down"))
	resetButton:SetMouseOverTexture(RESET_BUTTON_TEXTURE:format("over"))
	resetButton:SetEndCapWidth(0)
	resetButton:SetDimensions(RESET_BUTTON_SIZE, RESET_BUTTON_SIZE)
	resetButton:SetAnchor(TOPRIGHT, group.label, TOPLEFT, 196, 0)
	resetButton:SetHidden(true)
	resetButton:SetHandler("OnMouseUp",function(control, button, isInside)
		if(button == 1 and isInside) then
			group:ReleaseAllButtons()
		end
	end)
	resetButton:SetHandler("OnMouseEnter", function()
		InitializeTooltip(InformationTooltip)
		InformationTooltip:ClearAnchors()
		InformationTooltip:SetOwner(resetButton, BOTTOM, 5, 0)
		SetTooltipText(InformationTooltip, L["RESET_FILTER_LABEL_TEMPLATE"]:format(subfilterPreset.label))
	end)
	resetButton:SetHandler("OnMouseExit", function()
		ClearTooltip(InformationTooltip)
	end)
	group.resetButton = resetButton

	return group
end

function CategorySelector:CreateSubfilterGroup(name, subfilterPreset)
	local parent = self.control:GetParent()
	local group = ButtonGroup:New(parent, name, 0, 0)
	group.control:ClearAnchors()
	group.control:SetAnchor(TOPLEFT, parent:GetNamedChild("Header"), BOTTOMLEFT, subfilterPreset.x, subfilterPreset.y + 260)
	group.control:SetHidden(true)
	group.type = subfilterPreset.filter
	return group
end

function CategorySelector:CreateSubfilterButton(group, index, buttonPreset, subfilterPreset)
	local x = subfilterPreset.size * (math.mod(index - 1, subfilterPreset.perRow))
	local y = 20 + subfilterPreset.size * math.floor((index - 1) / subfilterPreset.perRow)
	local button = ToggleButton:New(group.control, group.control:GetName() .. "Button" .. index, buttonPreset.texture, x, y, subfilterPreset.size, subfilterPreset.size, buttonPreset.label)
	button.HandlePress = function()
		group.resetButton:SetHidden(false)
		if(group.pressedButtonCount == 8) then
			ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, L["WARNING_SUBFILTER_LIMIT"])
			return false
		end
		self:HandleChange()
		return true
	end
	button.HandleRelease = function(control, fromGroup)
		group.resetButton:SetHidden(group.pressedButtonCount == 1)
		self:HandleChange()
		return true
	end
	button.value = buttonPreset.value
	button.index = index
	group:AddButton(button)
	return button
end

function CategorySelector:UpdateSubfilterVisibility()
	local subfilters = FILTER_PRESETS[self.category].subcategories
	local subcategory = self.subcategory[self.category]
	if(subcategory) then subfilters = subfilters[subcategory].subfilters end

	for _, subfilter in pairs(self.subfilters) do
		subfilter.control:SetHidden(true)
	end
	if(subfilters) then
		for _, subfilterId in ipairs(subfilters) do
			if(self.subfilters[subfilterId]) then
				self.subfilters[subfilterId].control:SetHidden(false)
			end
		end
	end
end

function CategorySelector:CreateSubcategory(name, category, categoryPreset)
	if(#categoryPreset.subcategories == 0) then return end
	local group = self:CreateSubcategoryGroup(name .. categoryPreset.name .. "Group", category)
	for subcategory, preset in pairs(categoryPreset.subcategories) do
		self:CreateSubcategoryButton(group, subcategory, preset)
	end
end

function CategorySelector:CreateCategoryButton(group, category, preset)
	local button = ToggleButton:New(group.control, group.control:GetName() .. preset.name .. "Button", preset.texture, 180 + MAJOR_BUTTON_SIZE * category, 0, MAJOR_BUTTON_SIZE, MAJOR_BUTTON_SIZE, preset.label)
	button.HandlePress = function()
		group:ReleaseAllButtons()
		self.category = category
		group.label:SetText(preset.label)
		if(self.group[category]) then
			self.group[category].control:SetHidden(false)
		end
		self:UpdateSubfilterVisibility()
		self:HandleChange()
		return true
	end
	button.HandleRelease = function(control, fromGroup)
		local subCategoryGroup = self.group[category]
		if(subCategoryGroup) then
			if(fromGroup) then
				subCategoryGroup.control:SetHidden(true)
			else
				subCategoryGroup.defaultButton:Press()
			end
		end
		return fromGroup
	end
	button.value = category
	if(preset.isDefault) then
		group.defaultButton = button
		button:Press()
	end
	group:AddButton(button)
	return button
end

function CategorySelector:CreateSubcategoryGroup(name, category)
	local group = ButtonGroup:New(self.control, name, 0, MAJOR_BUTTON_SIZE + 4)
	group.category = category

	local label = group.control:CreateControl(name .. "Label", CT_LABEL)
	label:SetFont("ZoFontWinH5")
	label:SetModifyTextType(MODIFY_TEXT_TYPE_UPPERCASE)
	label:SetAnchor(TOPLEFT, group.control, TOPLEFT, 0, 7)
	group.label = label

	local divider = group.control:CreateControl(name .. "Divider", CT_TEXTURE)
	divider:SetDimensions(500, 3)
	divider:SetTexture("EsoUI/Art/Miscellaneous/centerscreen_topDivider.dds")
	divider:SetAnchor(TOPCENTER, group.control, TOPCENTER, 50, MINOR_BUTTON_SIZE + 2)

	self.group[category] = group
	group.control:SetHidden(true)
	return group
end

local function ShowGuildSpecificItems()
	TRADING_HOUSE.m_noItemsLabel:SetHidden(true) -- hide the no items found message as we will show the tabard anyways
	TRADING_HOUSE:AddGuildSpecificItems(true) -- add the tabard whenever we change to the costume subcategory, because this function clears the search result
end

function CategorySelector:CreateSubcategoryButton(group, subcategory, preset)
	local button = ToggleButton:New(group.control, group.control:GetName() .. "SubcategoryButton" .. subcategory, preset.texture, 170 + MINOR_BUTTON_SIZE * subcategory, 0, MINOR_BUTTON_SIZE, MINOR_BUTTON_SIZE, preset.label)
	button.HandlePress = function()
		group:ReleaseAllButtons()
		group.label:SetText(preset.label)
		self.subcategory[group.category] = subcategory
		self:UpdateSubfilterVisibility()
		if(preset.showTabards) then
			ShowGuildSpecificItems()
		end
		self:HandleChange()
		return true
	end
	button.HandleRelease = function(control, fromGroup)
		if(not fromGroup and preset.showTabards) then
			ShowGuildSpecificItems()
		end
		return fromGroup
	end
	button.value = subcategory
	if(preset.isDefault) then
		group.defaultButton = button
		button:Press()
	end
	group:AddButton(button)
	return button
end

function CategorySelector:HandleChange()
	if(not self.fireChangeCallback) then
		self.fireChangeCallback = zo_callLater(function()
			self.fireChangeCallback = nil
			CALLBACK_MANAGER:FireCallbacks(self.callbackName, self)
		end, 100)
	end
end

function CategorySelector:Reset()
	self.mainGroup.defaultButton:Press()
	for _, group in pairs(self.group) do
		group.defaultButton:Press()
	end
	for _, subfilter in pairs(self.subfilters) do
		subfilter:ReleaseAllButtons()
	end
end

-- category[;subcategory[;(subfilterId,subfilterState)*]]
function CategorySelector:Serialize()
	local category = self.category
	local state = tostring(category)

	local subcategory = self.subcategory[category]
	if(subcategory) then
		state = state .. ";" .. tostring(subcategory)

		local subfilters = FILTER_PRESETS[category].subcategories[subcategory].subfilters
		if(subfilters) then
			for _, subfilterId in ipairs(subfilters) do
				local buttonGroup = self.subfilters[subfilterId]
				if(buttonGroup) then
					local subfilterValues = 0
					for _, button in pairs(buttonGroup.buttons) do
						if(button:IsPressed()) then
							subfilterValues = subfilterValues + math.pow(2, button.index)
						end
					end
					if(subfilterValues > 0) then
						state = state .. ";" .. tostring(subfilterId) .. "," .. tostring(subfilterValues)
					end
				end
			end
		end
	end

	return state
end

function CategorySelector:Deserialize(state)
	local values = {zo_strsplit(";", state)}

	for index, value in ipairs(values) do
		if(index == 1) then
			for _, button in pairs(self.mainGroup.buttons) do
				if(button.value == tonumber(value)) then button:Press() break end
			end
		elseif(index == 2) then
			for _, button in pairs(self.group[self.category].buttons) do
				if(button.value == tonumber(value)) then button:Press() break end
			end
			local filters = FILTER_PRESETS[self.category].subcategories
			local subcategory = self.subcategory[self.category]
			if(subcategory and filters[subcategory].subfilters) then
				for _, subfilterId in pairs(filters[subcategory].subfilters) do
					self.subfilters[subfilterId]:ReleaseAllButtons()
				end
			end
		else
			local subfilterId, subfilterValues = zo_strsplit(",", value)
			local buttonGroup = self.subfilters[tonumber(subfilterId)]
			assert(subfilterId and subfilterValues and buttonGroup)
			subfilterValues = tonumber(subfilterValues)
			local buttonValue = 0
			while subfilterValues > 0 do
				local isPressed = (math.mod(subfilterValues, 2) == 1)
				if(isPressed) then
					for _, button in pairs(buttonGroup.buttons) do
						if(buttonValue == button.index) then
							button:Press()
							break
						end
					end
				end
				subfilterValues = math.floor(subfilterValues / 2)
				buttonValue = buttonValue + 1
			end
		end
	end
end
