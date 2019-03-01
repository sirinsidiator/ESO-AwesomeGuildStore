local AGS = AwesomeGuildStore

local FilterBase = AGS.class.FilterBase

local FILTER_ID = AGS.data.FILTER_ID

local gettext = AGS.internal.gettext
local logger = AGS.internal.logger
local EncodeValue = AGS.internal.EncodeValue
local DecodeValue = AGS.internal.DecodeValue
local RegisterForEvent = AGS.internal.RegisterForEvent
local UnregisterForEvent = AGS.internal.UnregisterForEvent

local MakeExactSearchText = ZO_TradingHouseNameSearchFeature_Shared.MakeExactSearchText
local LTF = LibTextFilter
local MAX_NAME_HASHES = GetMaxTradingHouseFilterExactTerms(TRADING_HOUSE_FILTER_TYPE_NAME_HASH)
local MIN_LETTERS = GetMinLettersInTradingHouseItemNameForCurrentLanguage()

local TextFilter = FilterBase:Subclass()
AGS.class.TextFilter = TextFilter

function TextFilter:New(...)
    return FilterBase.New(self, ...)
end

function TextFilter:Initialize()
    -- TRANSLATORS: label of the text filter
    FilterBase.Initialize(self, FILTER_ID.TEXT_FILTER, FilterBase.GROUP_SERVER, gettext("Text Search"))
    self.text = ""
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

function TextFilter:SetFromItem(itemLink)
    self:SetText(MakeExactSearchText(zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(itemLink))))
end

function TextFilter:IsLocal()
    return false
end

function TextFilter:IsSearchTextLongEnough(input)
    local length = ZoUTF8StringLength(input)
    return length >= MIN_LETTERS
end

function TextFilter:PrepareForSearch()
    self.completedItemNameMatchId = nil
    if(self:IsDefault() or not self:IsSearchTextLongEnough(self.text)) then return false end

    local pendingId, eventHandle
    eventHandle = RegisterForEvent(EVENT_MATCH_TRADING_HOUSE_ITEM_NAMES_COMPLETE, function(_, id, numResults)
        if(pendingId == id) then
            UnregisterForEvent(EVENT_MATCH_TRADING_HOUSE_ITEM_NAMES_COMPLETE, eventHandle)
            self.completedItemNameMatchId = id
            AGS.internal:FireCallbacks(AGS.callback.FILTER_PREPARED, self)
        end
    end)
    pendingId = MatchTradingHouseItemNames(self.text)
    return true
end

function TextFilter:ApplyToSearch()
    if(not self.completedItemNameMatchId) then return end

    local numResults = GetNumMatchTradingHouseItemNamesResults(self.completedItemNameMatchId)
    if(not numResults or numResults == 0 or numResults > MAX_NAME_HASHES) then return end

    logger:Info("Apply %d name hashes to search", numResults)
    local hashes = {}
    for hashIndex = 1, numResults do
        local _, hash = GetMatchTradingHouseItemNamesResult(self.completedItemNameMatchId, hashIndex)
        hashes[hashIndex] = hash
    end
    SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_NAME_HASH, unpack(hashes))
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
    local isMatch, result = LTF:Filter(table.concat(haystack, "\n"):lower(), self.searchTerm)
    return isMatch
end

function TextFilter:CanFilter(subcategory)
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
