local L = AwesomeGuildStore.Localization
local FILTER_PRESETS = AwesomeGuildStore.FILTER_PRESETS

local MAJOR_BUTTON_SIZE = 46
local MINOR_BUTTON_SIZE = 32
local RESET_BUTTON_SIZE = 18
local RESET_BUTTON_TEXTURE = "EsoUI/Art/Buttons/decline_%s.dds"
local DEFAULT_LAYOUT = BACKPACK_TRADING_HOUSE_LAYOUT_FRAGMENT.layoutData

local RegisterForEvent = AwesomeGuildStore.RegisterForEvent
local ButtonGroup = AwesomeGuildStore.ButtonGroup
local ToggleButton = AwesomeGuildStore.ToggleButton

local SalesCategorySelector = ZO_Object:Subclass()
AwesomeGuildStore.SalesCategorySelector = SalesCategorySelector

local ALL_CRAFTING_PRESET = {
	label = L["FILTER_SUBCATEGORY_ALL"],
	texture = "EsoUI/Art/Inventory/inventory_tabIcon_all_%s.dds",
	isDefault = true,
	filters = {
		[TRADING_HOUSE_FILTER_TYPE_ITEM] = {
			ITEMTYPE_BLACKSMITHING_RAW_MATERIAL, ITEMTYPE_BLACKSMITHING_MATERIAL, ITEMTYPE_BLACKSMITHING_BOOSTER,
			ITEMTYPE_CLOTHIER_RAW_MATERIAL, ITEMTYPE_CLOTHIER_MATERIAL, ITEMTYPE_CLOTHIER_BOOSTER,
			ITEMTYPE_WOODWORKING_RAW_MATERIAL, ITEMTYPE_WOODWORKING_MATERIAL, ITEMTYPE_WOODWORKING_BOOSTER,
			ITEMTYPE_ALCHEMY_BASE, ITEMTYPE_REAGENT, ITEMTYPE_INGREDIENT,
			ITEMTYPE_ENCHANTING_RUNE_ASPECT, ITEMTYPE_ENCHANTING_RUNE_ESSENCE, ITEMTYPE_ENCHANTING_RUNE_POTENCY,
			ITEMTYPE_STYLE_MATERIAL, ITEMTYPE_WEAPON_TRAIT, ITEMTYPE_ARMOR_TRAIT,
		},
	},
	subfilters = {},
}

local ALL_ARMOR_FILTERS = {
	[TRADING_HOUSE_FILTER_TYPE_EQUIP] = {
		EQUIP_TYPE_HEAD, EQUIP_TYPE_CHEST, EQUIP_TYPE_SHOULDERS, EQUIP_TYPE_WAIST, EQUIP_TYPE_LEGS, EQUIP_TYPE_FEET, EQUIP_TYPE_HAND,
		EQUIP_TYPE_OFF_HAND, EQUIP_TYPE_RING, EQUIP_TYPE_NECK, EQUIP_TYPE_COSTUME
	}
}

function SalesCategorySelector:New(parent, name)
	local selector = ZO_Object.New(self)
	selector.callbackName = name .. "Changed"
	selector.type = 10

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

	local searchBoxControl = ZO_PlayerInventorySearchBox
	searchBoxControl:SetDrawLayer(3) -- make sure the text box is above the sort by name field
	local filterDividerControl = ZO_PlayerInventoryFilterDivider
	local sortByControl = ZO_PlayerInventorySortBy
	local wasFilterDividerHidden
	local function Activate()
		searchBoxControl:ClearAnchors()
		searchBoxControl:SetAnchor(TOPLEFT, sortByControl, TOPLEFT, 220, 3)
		wasFilterDividerHidden = filterDividerControl:IsHidden()
		filterDividerControl:SetHidden(true)
	end
	local function Deactivate()
		searchBoxControl:ClearAnchors()
		searchBoxControl:SetAnchor(TOPRIGHT, searchBoxControl:GetParent(), TOPRIGHT, -26, 68)
		filterDividerControl:SetHidden(wasFilterDividerHidden)
	end
	RegisterForEvent(EVENT_OPEN_TRADING_HOUSE, Activate)
	RegisterForEvent(EVENT_CLOSE_TRADING_HOUSE, Deactivate)
	Activate()

	return selector
end

function SalesCategorySelector:CreateSubcategory(name, category, categoryPreset)
	if(#categoryPreset.subcategories == 0) then return end
	local group = self:CreateSubcategoryGroup(name .. categoryPreset.name .. "Group", category)
	local isCrafting = nil
	if(category == ITEMFILTERTYPE_CRAFTING) then
		self:CreateSubcategoryButton(group, 0, ALL_CRAFTING_PRESET, true)
		isCrafting = true
	end
	for subcategory, preset in pairs(categoryPreset.subcategories) do
		self:CreateSubcategoryButton(group, subcategory, preset, isCrafting)
	end
end

function SalesCategorySelector:CreateCategoryButton(group, category, preset)
	local button = ToggleButton:New(group.control, group.control:GetName() .. preset.name .. "Button", preset.texture, 180 + MAJOR_BUTTON_SIZE * category, 0, MAJOR_BUTTON_SIZE, MAJOR_BUTTON_SIZE, preset.label)
	button.HandlePress = function()
		group:ReleaseAllButtons()
		self.category = category
		group.label:SetText(preset.label)
		if(self.group[category]) then
			self.group[category].control:SetHidden(false)
		end
		self:HandleChange()
		return true
	end
	button.HandleRelease = function(control, fromGroup)
		if(fromGroup) then
			if(self.group[category]) then
				self.group[category].control:SetHidden(true)
			end
			return true
		end
	end
	button.value = category
	if(preset.isDefault) then
		group.defaultButton = button
		button:Press()
	end
	group:AddButton(button)
	return button
end

function SalesCategorySelector:CreateSubcategoryGroup(name, category)
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

function SalesCategorySelector:CreateSubcategoryButton(group, subcategory, preset, isCrafting)
	local offset = 170 + (isCrafting and MINOR_BUTTON_SIZE or 0)
	local button = ToggleButton:New(group.control, group.control:GetName() .. "SubcategoryButton" .. subcategory, preset.texture, offset + MINOR_BUTTON_SIZE * subcategory, 0, MINOR_BUTTON_SIZE, MINOR_BUTTON_SIZE, preset.label)
	button.HandlePress = function()
		group:ReleaseAllButtons()
		group.label:SetText(preset.label)
		self.subcategory[group.category] = subcategory
		self:HandleChange()
		return true
	end
	button.HandleRelease = function(control, fromGroup)
		return fromGroup
	end
	button.value = subcategory
	if(preset.isDefault and ((not isCrafting) or (isCrafting and subcategory == 0))) then
		group.defaultButton = button
		button:Press()
	end
	group:AddButton(button)
	return button
end

local currentFilterValues = {}
local currentLayout = DEFAULT_LAYOUT

local function contains(haystack, needle)
	for _, value in pairs(haystack) do
		if(value == needle) then
			return true
		end
	end
	return false
end

local function SalesCategoryFilter(slot)
	if(slot.quality == ITEM_QUALITY_TRASH) then return false end
	local itemLink = GetItemLink(slot.bagId, slot.slotIndex)
	if(IsItemLinkBound(itemLink)) then return false end

	if(NonContiguousCount(currentFilterValues) == 0) then
		return true
	else
		local isValid = true
		for type, values in pairs(currentFilterValues) do
			if(type == TRADING_HOUSE_FILTER_TYPE_EQUIP) then
				isValid = isValid and contains(values, GetItemLinkEquipType(itemLink))
			elseif(type == TRADING_HOUSE_FILTER_TYPE_WEAPON) then
				isValid = isValid and contains(values, GetItemLinkWeaponType(itemLink))
			elseif(type == TRADING_HOUSE_FILTER_TYPE_ARMOR) then
				isValid = isValid and contains(values, GetItemLinkArmorType(itemLink))
			elseif(type == TRADING_HOUSE_FILTER_TYPE_ITEM) then
				isValid = isValid and contains(values, GetItemLinkItemType(itemLink))
			end
			if(not isValid) then break end
		end
		return isValid
	end
	return false
end

local BACKPACK_TRADING_HOUSE_LAYOUT_FRAGMENT_BASIC = ZO_BackpackLayoutFragment:New(
	{
		width = 670,
		backpackOffsetY = 145,
		sortByOffsetY = 114,
		sortByHeaderWidth = 690,
		sortByNameWidth = 382,
		hideAlliancePoints = true,
		additionalFilter = SalesCategoryFilter,
	})

local BACKPACK_TRADING_HOUSE_LAYOUT_FRAGMENT_ADVANCED = ZO_BackpackLayoutFragment:New(
	{
		width = 670,
		backpackOffsetY = 181,
		sortByOffsetY = 149,
		sortByHeaderWidth = 690,
		sortByNameWidth = 382,
		hideAlliancePoints = true,
		additionalFilter = SalesCategoryFilter,
	})

function SalesCategorySelector:HandleChange()
	local filters = FILTER_PRESETS[self.category].subcategories
	local subcategory = self.subcategory[self.category]
	currentLayout = BACKPACK_TRADING_HOUSE_LAYOUT_FRAGMENT_BASIC.layoutData
	if(subcategory) then
		if(self.category == ITEMFILTERTYPE_CRAFTING and subcategory == 0) then -- ugly special cases
			filters = ALL_CRAFTING_PRESET.filters
		elseif(self.category == ITEMFILTERTYPE_ARMOR and subcategory == 1) then
			filters = ALL_ARMOR_FILTERS
		else
			filters = filters[subcategory].filters
		end
		currentLayout = BACKPACK_TRADING_HOUSE_LAYOUT_FRAGMENT_ADVANCED.layoutData
	end
	if(filters ~= currentFilterValues) then
		currentFilterValues = filters
		self:Refresh()
	end

	if(not self.fireChangeCallback) then
		self.fireChangeCallback = zo_callLater(function()
			self.fireChangeCallback = nil
			CALLBACK_MANAGER:FireCallbacks(self.callbackName, self)
		end, 100)
	end
end

function SalesCategorySelector:Refresh()
	PLAYER_INVENTORY:ApplyBackpackLayout(DEFAULT_LAYOUT) -- need to force a refresh because we reuse fragments
	PLAYER_INVENTORY:ApplyBackpackLayout(currentLayout)
end


RegisterForEvent(EVENT_CLOSE_TRADING_HOUSE, function()
	PLAYER_INVENTORY:ApplyBackpackLayout(BACKPACK_DEFAULT_LAYOUT_FRAGMENT.layoutData) -- required to make guild bank and other inventories look normal when advanced filters is used
end)

function SalesCategorySelector:Reset()
	self.mainGroup.defaultButton:Press()
	for _, group in pairs(self.group) do
		group.defaultButton:Press()
	end
	for _, subfilter in pairs(self.subfilters) do
		subfilter:ReleaseAllButtons()
	end
end

-- category[;subcategory]
function SalesCategorySelector:Serialize()
	local category = self.category
	local state = tostring(category)

	local subcategory = self.subcategory[category]
	if(subcategory) then
		state = state .. ";" .. tostring(subcategory)
	end

	return state
end

function SalesCategorySelector:Deserialize(state)
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
		end
	end
	local category = self.category
end