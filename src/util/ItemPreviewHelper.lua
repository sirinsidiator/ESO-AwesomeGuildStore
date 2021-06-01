local AGS = AwesomeGuildStore

local WrapFunction = AGS.internal.WrapFunction

local ItemPreviewHelper = ZO_Object:Subclass()
AGS.class.ItemPreviewHelper = ItemPreviewHelper

function ItemPreviewHelper:New(...)
    local helper = ZO_Object.New(self)
    helper:Initialize(...)
    return helper
end

function ItemPreviewHelper:Initialize(itemDatabase)
    self.itemDatabase = itemDatabase

    local previewTypeClass = ZO_ItemPreviewType_TradingHouseSearchResult
    ZO_PreHook(previewTypeClass, "SetStaticParameters", function(...) return self:SetStaticParameters(...) end)
    ZO_PreHook(previewTypeClass, "ResetStaticParameters", function(...) return self:ResetStaticParameters(...) end)
    ZO_PreHook(previewTypeClass, "Apply", function(...) return self:Apply(...) end)
    WrapFunction(previewTypeClass, "GetNumVariations", function(...) return self:GetNumVariations(...) end)
    WrapFunction(previewTypeClass, "GetVariationName", function(...) return self:GetVariationName(...) end)
end

function ItemPreviewHelper:SetStaticParameters(previewType, tradingHouseIndex)
    local item = self.itemDatabase:TryGetItemDataInCurrentGuildByUniqueId(tradingHouseIndex)
    if item then
        previewType.item = item
    end
end

function ItemPreviewHelper:ResetStaticParameters(previewType)
    previewType.item = nil
end

function ItemPreviewHelper:Apply(previewType, variationIndex)
    if previewType.item then
        -- ZOS has unlocked this function so AGS can preview items in the search results once more, after the previous method was removed in Version 6.3.
        -- While it may be possible to preview any itemlink, please make sure you only use it for items that can already be obtained in the game, otherwise ZOS will lock it again!
        PreviewItemLink(previewType.item.itemLink, variationIndex)
        return true
    end
end

function ItemPreviewHelper:GetNumVariations(originalFunc, previewType)
    if previewType.item then
        return GetNumItemLinkPreviewVariations(previewType.item.itemLink)
    end
    return originalFunc(previewType)
end

function ItemPreviewHelper:GetVariationName(originalFunc, previewType, variationIndex)
    if previewType.item then
        return GetItemLinkPreviewVariationDisplayName(previewType.item.itemLink, variationIndex)
    end
    return originalFunc(previewType)
end