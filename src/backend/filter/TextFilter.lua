local AGS = AwesomeGuildStore

local FilterBase = AGS.class.FilterBase

local FILTER_ID = AGS.data.FILTER_ID

local gettext = AGS.internal.gettext
local EncodeValue = AGS.internal.EncodeValue
local DecodeValue = AGS.internal.DecodeValue


local TextFilter = FilterBase:Subclass()
AGS.class.TextFilter = TextFilter

function TextFilter:New(...)
    return FilterBase.New(self, ...)
end

function TextFilter:Initialize()
    FilterBase.Initialize(self, FILTER_ID.TEXT_FILTER, FilterBase.GROUP_LOCAL)
    -- TRANSLATORS: label of the text filter
    self:SetLabel(gettext("Text Search"))
    self.text = ""
    self.LTF = LibStub("LibTextFilter")
    self.haystack = {}
end

function TextFilter:SetText(text) -- TODO filter input and only allow ascii?
    local changed = (text ~= self.text)
    self.text = text

    if(changed) then
        self:HandleChange(text)
    end
end

function TextFilter:GetText()
    return self.text
end

function TextFilter:Reset()
    self:SetText("")
end

function TextFilter:IsDefault()
    return self.text == ""
end

function TextFilter:GetValues()
    return self.text
end

function TextFilter:SetValues(text)
    self:SetText(text)
end

function TextFilter:SetUpLocalFilter(searchTerm)
    if(searchTerm ~= "") then
        self.searchTerm = searchTerm:lower()
        return true
    end
    return false
end

function TextFilter:FilterLocalResult(itemData)
    local itemLink = itemData.itemLink
    local _, setName = GetItemLinkSetInfo(itemLink)

    local haystack = self.haystack
    haystack[1] = itemData.name
    haystack[2] = itemLink
    haystack[3] = setName
    local isMatch, result = self.LTF:Filter(table.concat(haystack, "\n"):lower(), self.searchTerm)
    return isMatch
end

function TextFilter:CanAttach(subcategory)
    return true
end

function TextFilter:Serialize(text)
    return EncodeValue("base64", text)
end

function TextFilter:Deserialize(state)
    return DecodeValue("base64", state)
end

function TextFilter:GetTooltipText(text)
    return text
end