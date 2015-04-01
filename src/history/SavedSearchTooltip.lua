local L = AwesomeGuildStore.Localization
local RegisterForEvent = AwesomeGuildStore.RegisterForEvent
local FILTER_PRESETS = AwesomeGuildStore.FILTER_PRESETS
local SUBFILTER_PRESETS = AwesomeGuildStore.SUBFILTER_PRESETS
local QUALITY_LABEL = {L["NORMAL_QUALITY_LABEL"], L["MAGIC_QUALITY_LABEL"], L["ARCANE_QUALITY_LABEL"], L["ARTIFACT_QUALITY_LABEL"], L["LEGENDARY_QUALITY_LABEL"]}

local SavedSearchTooltip = ZO_Object:Subclass()
AwesomeGuildStore.SavedSearchTooltip = SavedSearchTooltip

local r, g, b = ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB()
local LINE_FORMAT = "%s: |cFFFFFF%s|r\n"

local function PrepareTooltip(parent)
	InitializeTooltip(InformationTooltip)
	InformationTooltip:ClearAnchors()
	InformationTooltip:SetOwner(parent, RIGHT, -5, 0)
end

local function AddHeader(text)
	InformationTooltip:AddLine(text, "ZoFontGameBold", r, g, b)
end

local function AddLine(text)
	InformationTooltip:AddLine(text, "", r, g, b)
end

local function GetFormattedPrice(price)
	return zo_strformat(SI_FORMAT_ICON_TEXT, ZO_CurrencyControl_FormatCurrency(price), zo_iconFormat("EsoUI/Art/currency/currency_gold.dds", 16, 16))
end

function SavedSearchTooltip:New()
	local tooltip = ZO_Object.New(self)
	tooltip:Initialize()
	return tooltip
end

function SavedSearchTooltip:Initialize()
	self.title = ""
	self.content = ""
end

function SavedSearchTooltip:SetTitle(title)
	self.title = title
end

function SavedSearchTooltip:AddLine(label, text)
	self.content = self.content .. LINE_FORMAT:format(label, text)
end

function SavedSearchTooltip:Commit(control)
	PrepareTooltip(control)
	AddHeader(self.title)
	AddLine(self.content:sub(0, -2))
end

function SavedSearchTooltip:Show(control, entry)
	local version, categoryState, priceState, levelState, qualityState, nameState = zo_strsplit(":", entry.state)
	if(version ~= "1") then return end

	self:Initialize()
	self:SetTitle(entry.label)

	-- category
	if(categoryState and categoryState ~= "-") then
		local values = {zo_strsplit(";", categoryState)}
		local category, subcategory
		for index, value in ipairs(values) do
			if(index == 1) then
				category = FILTER_PRESETS[tonumber(value)]
				if(category) then
					self:AddLine(L["CATEGORY_TITLE"], category.label)
				end
			elseif(index == 2 and category) then
				subcategory = category.subcategories[tonumber(value)]
				if(subcategory) then
					self:AddLine(L["SUBCATEGORY_TITLE"], subcategory.label)
				end
			elseif(subcategory) then
				local subfilterId, subfilterValues = zo_strsplit(",", value)
				local subfilterPreset = SUBFILTER_PRESETS[tonumber(subfilterId)]
				if(subfilterPreset) then
					subfilterValues = tonumber(subfilterValues)
					local value = 0
					local text = ""
					while subfilterValues > 0 do
						local isSelected = (math.mod(subfilterValues, 2) == 1)
						if(isSelected) then
							for index, button in ipairs(subfilterPreset.buttons) do
								if(value == index) then
									text = text .. button.label .. ", "
									break
								end
							end
						end
						subfilterValues = math.floor(subfilterValues / 2)
						value = value + 1
					end
					if(#text > 0) then
						self:AddLine(subfilterPreset.label, text:sub(0, -3))
					end
				end
			end
		end
	end

	-- price
	if(priceState and priceState ~= "-") then
		local minPrice, maxPrice = zo_strsplit(";", priceState)
		minPrice = tonumber(minPrice)
		maxPrice = tonumber(maxPrice)
		local priceText = ""
		if(minPrice and maxPrice) then
			priceText = GetFormattedPrice(minPrice) .. " - " .. GetFormattedPrice(maxPrice)
		elseif(minPrice) then
			priceText = L["TOOLTIP_GREATER_THAN"] .. GetFormattedPrice(minPrice)
		elseif(maxPrice) then
			priceText = L["TOOLTIP_LESS_THAN"] .. GetFormattedPrice(maxPrice)
		end

		if(priceText ~= "") then
			self:AddLine(L["PRICE_SELECTOR_TITLE"]:sub(0, -2), priceText)
		end
	end

	-- level
	if(levelState and levelState ~= "-") then
		local vr, minLevel, maxLevel = zo_strsplit(";", levelState)
		local isNormal = (vr == "0")
		minLevel = tonumber(minLevel)
		maxLevel = tonumber(maxLevel)
		if(minLevel or maxLevel) then
			local label = isNormal and L["LEVEL_SELECTOR_TITLE"] or L["VR_SELECTOR_TITLE"]
			local text = ("%d - %d"):format(minLevel or 1, maxLevel or (isNormal and 50 or 14))
			self:AddLine(label:sub(0, -2), text)
		end
	end

	-- quality
	if(qualityState and qualityState ~= "-") then
		local minQuality, maxQuality = zo_strsplit(";", qualityState)
		minQuality = tonumber(minQuality)
		maxQuality = tonumber(maxQuality)
		if(minQuality and maxQuality and not (minQuality == 1 and maxQuality == 5)) then
			local text = ""
			for i = minQuality, maxQuality do
				text = text .. QUALITY_LABEL[i] .. ", "
			end
			self:AddLine(L["QUALITY_SELECTOR_TITLE"]:sub(0, -2), text:sub(0, -3))
		end
	end

	if(nameState and nameState ~= "" and nameState ~= "-") then
		nameState = nameState:gsub("%.", ":")
		self:AddLine(L["ITEM_NAME_QUICK_FILTER_LABEL"]:sub(0, -2), nameState)
	end

	self:Commit(control)
end

function SavedSearchTooltip:Hide()
	ClearTooltip(InformationTooltip)
end
