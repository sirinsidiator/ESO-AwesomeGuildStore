local L = AwesomeGuildStore.Localization
local RegisterForEvent = AwesomeGuildStore.RegisterForEvent
local FILTER_PRESETS = AwesomeGuildStore.FILTER_PRESETS
local SUBFILTER_PRESETS = AwesomeGuildStore.SUBFILTER_PRESETS

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

local function TryReadDataV1(self, state, filterByType)
	local version, categoryState, priceState, levelState, qualityState, nameState = zo_strsplit(":", state)

	if(version ~= "1") then return end
	-- category
	if(categoryState and categoryState ~= "-") then
		local lines = filterByType[1]:GetTooltipText(categoryState)
		for i = 1, #lines do
			self:AddLine(lines[i].label, lines[i].text)
		end
	end

	-- price
	if(priceState and priceState ~= "-") then
		local lines = filterByType[2]:GetTooltipText(priceState)
		for i = 1, #lines do
			self:AddLine(lines[i].label, lines[i].text)
		end
	end

	-- level
	if(levelState and levelState ~= "-") then
		local lines = filterByType[3]:GetTooltipText(levelState)
		for i = 1, #lines do
			self:AddLine(lines[i].label, lines[i].text)
		end
	end

	-- quality
	if(qualityState and qualityState ~= "-") then
		local lines = filterByType[4]:GetTooltipText(qualityState)
		for i = 1, #lines do
			self:AddLine(lines[i].label, lines[i].text)
		end
	end

	if(nameState and nameState ~= "" and nameState ~= "-") then
		local lines = filterByType[5]:GetTooltipText(nameState)
		for i = 1, #lines do
			self:AddLine(lines[i].label, lines[i].text)
		end
	end
end

function SavedSearchTooltip:Show(control, entry, filterByType)
	self:Initialize()
	self:SetTitle(entry.label)

	local states = {zo_strsplit("%", entry.state)}
	local version = tonumber(states[1])
	if(version >= 2) then
		for i = 2, #states do
			local type, data = zo_strsplit("#", states[i])
			local filter = filterByType[tonumber(type)]
			if(filter) then
				local lines = filter:GetTooltipText(data, version)
				for i = 1, #lines do
					self:AddLine(lines[i].label, lines[i].text)
				end
			end
		end
	else
		TryReadDataV1(self, entry.state, filterByType)
	end

	self:Commit(control)
end

function SavedSearchTooltip:Hide()
	ClearTooltip(InformationTooltip)
end
