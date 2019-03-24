local AGS = AwesomeGuildStore

local ActivityBase = AGS.class.ActivityBase
local RequestSearchActivity = AGS.class.RequestSearchActivity
local SortOrderBase = AGS.class.SortOrderBase

local logger = AGS.internal.logger
local gettext = AGS.internal.gettext

local Promise = LibPromises
local sformat = string.format

local FIRST_PAGE_INDEX = 0

local PreviewItemActivity = RequestSearchActivity:Subclass()
AGS.class.PreviewItemActivity = PreviewItemActivity

function PreviewItemActivity:New(...)
    return RequestSearchActivity.New(self, ...)
end

function PreviewItemActivity:Initialize(tradingHouseWrapper, guildId, itemId, itemData)
    local key = PreviewItemActivity.CreateKey(guildId, itemId)
    ActivityBase.Initialize(self, tradingHouseWrapper, key, ActivityBase.PRIORITY_HIGH, guildId)
    self.searchManager = tradingHouseWrapper.searchManager
    self.itemDatabase = tradingHouseWrapper.itemDatabase
    self.itemNameMatcher = tradingHouseWrapper.itemNameMatcher
    self.pendingGuildName = tradingHouseWrapper:GetTradingGuildName(guildId)
    self.itemData = itemData
    self.itemId = itemId
end

function PreviewItemActivity:Update()
    local index = self.itemDatabase:GetCurrentPageIndexForItemId(self.itemId)
    self.canExecute = (index ~= nil) or (GetTradingHouseCooldownRemaining() == 0)
end

function PreviewItemActivity:PrepareItemPageIndex()
    local index = self.itemDatabase:GetCurrentPageIndexForItemId(self.itemId)
    if(not index) then
        return self:RequestSearch()
    else
        local promise = Promise:New()
        promise:Resolve(self)
        return promise
    end
end

function PreviewItemActivity:RequestSearch(itemLink, hashes)
    if(not self.responsePromise) then
        self.responsePromise = Promise:New()

        local itemLink = self.itemData.itemLink
        local quality = GetItemLinkQuality(itemLink)
        local _, specializedItemType = GetItemLinkItemType(itemLink)
        ClearAllTradingHouseSearchTerms()
        SetTradingHouseFilterRange(TRADING_HOUSE_FILTER_TYPE_QUALITY, quality, quality)
        SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM, specializedItemType)

        self.itemNameMatcher:MatchItemLink(itemLink):Then(function(hashes)
            SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_NAME_HASH, unpack(hashes))
            ExecuteTradingHouseSearch(FIRST_PAGE_INDEX, SortOrderBase.SORT_FIELD_TIME_LEFT, SortOrderBase.SORT_ORDER_DOWN)
        end, function(code)
            self:SetState(ActivityBase.STATE_FAILED, ActivityBase.RESULT_PREVIEW_ITEM_NAME_MATCH_FAILED)
            self.nameMatchErrorCode = code
            self.responsePromise:Reject(self)
        end)
    end
    return self.responsePromise
end

function PreviewItemActivity:DoPreview()
    local promise = Promise:New()
    local tradingHouseIndex = self.itemDatabase:GetCurrentPageIndexForItemId(self.itemId)
    if(tradingHouseIndex) then
        if(not ITEM_PREVIEW_KEYBOARD:IsInteractionCameraPreviewEnabled()) then
            self.tradingHouse:TogglePreviewMode()
        end

        ITEM_PREVIEW_KEYBOARD:PreviewTradingHouseSearchResultAsFurniture(tradingHouseIndex)
        KEYBIND_STRIP:UpdateKeybindButtonGroup(self.tradingHouse.keybindStripDescriptor)

        self:SetState(ActivityBase.STATE_SUCCEEDED, ActivityBase.RESULT_PREVIEW_ITEM_ON_CURRENT_PAGE)
        promise:Resolve(self)
    else
        self:SetState(ActivityBase.STATE_FAILED, ActivityBase.RESULT_PREVIEW_ITEM_NO_LONGER_AVAILABLE)
        promise:Reject(self)
    end
    return promise
end

function PreviewItemActivity:DoExecute()
    return self:ApplyGuildId():Then(self.PrepareItemPageIndex):Then(self.DoPreview)
end

function PreviewItemActivity:GetErrorMessage()
    -- TRANSLATORS: error text shown to the user when the item preview item failed
    return gettext("Could not preview item")
end

function PreviewItemActivity:GetLogEntry()
    if(not self.logEntry) then
        -- TRANSLATORS: log text shown to the user for each item preview request. Placeholder is for the item link and guild name
        self.logEntry = gettext("Preview <<1>> in <<2>>", self.itemData.itemLink, self.pendingGuildName)
    end
    return self.logEntry
end

function PreviewItemActivity:HandleSearchResultsReceived(hasAnyResultAlreadyStored)
    logger:Debug("handle item preview results received")
end

function PreviewItemActivity:GetType()
    return ActivityBase.ACTIVITY_TYPE_PREVIEW_ITEM
end

function PreviewItemActivity.CreateKey(guildId, itemId)
    return sformat("%d_%d_%d", ActivityBase.ACTIVITY_TYPE_PREVIEW_ITEM, guildId, itemId)
end
