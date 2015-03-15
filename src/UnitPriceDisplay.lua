local PER_UNIT_PRICE_CURRENCY_OPTIONS = {
	showTooltips = false,
	iconSide = RIGHT,
}
local UNIT_PRICE_FONT = "/esoui/common/fonts/univers67.otf|14|soft-shadow-thin"
local SEARCH_RESULTS_DATA_TYPE = 1

function AwesomeGuildStore.InitializeUnitPriceDisplay(saveData)
	local dataType = TRADING_HOUSE.m_searchResultsList.dataTypes[SEARCH_RESULTS_DATA_TYPE]
	local originalSetupCallback = dataType.setupCallback

	dataType.setupCallback = function(rowControl, result)
		originalSetupCallback(rowControl, result)

		local sellPriceControl = rowControl:GetNamedChild("SellPrice")
		local perItemPrice = rowControl:GetNamedChild("SellPricePerItem")
		if(saveData.displayPerUnitPrice) then
			if(not perItemPrice) then
				local controlName = rowControl:GetName() .. "SellPricePerItem"
				perItemPrice = rowControl:CreateControl(controlName, CT_LABEL)
				perItemPrice:SetAnchor(TOPRIGHT, sellPriceControl, BOTTOMRIGHT, 0, 0)
				perItemPrice:SetFont(UNIT_PRICE_FONT)
			end

			if(result.stackCount > 1) then
				local unitPrice = tonumber(string.format("%.2f", result.purchasePrice / result.stackCount))
				ZO_CurrencyControl_SetSimpleCurrency(perItemPrice, result.currencyType, unitPrice, PER_UNIT_PRICE_CURRENCY_OPTIONS, nil, TRADING_HOUSE.m_playerMoney[result.currencyType] < result.purchasePrice)
				perItemPrice:SetText("@" .. perItemPrice:GetText():gsub("|t.-:.-:", "|t12:12:"))
				perItemPrice:SetHidden(false)
				sellPriceControl:ClearAnchors()
				sellPriceControl:SetAnchor(RIGHT, rowControl, RIGHT, -5, -8)
				perItemPrice = nil
			end
		end

		if(perItemPrice) then
			perItemPrice:SetHidden(true)
			sellPriceControl:ClearAnchors()
			sellPriceControl:SetAnchor(RIGHT, rowControl, RIGHT, -5, 0)
		end
	end
end
