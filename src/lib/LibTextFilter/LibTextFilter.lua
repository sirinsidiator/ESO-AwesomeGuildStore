-- This libray is currently only for internal use and its API might change a lot between versions
local lib = LibStub:NewLibrary("LibTextFilter", 0.1)

if not lib then
	return	-- already loaded and no upgrade necessary
end

lib.RESULT_OK = 1
lib.RESULT_INVALID_ARGUMENT_COUNT = 2
lib.RESULT_INVALID_VALUE_COUNT = 3

local function PrintArray(array)
	if(#array > 0) then
		local output = {}
		for i = 1, #array do
			if(type(array[i]) == "table" and array[i].token) then
				output[i] = "'" .. array[i].token .. "'"
			elseif(type(array[i]) == "string") then
				output[i] = "\"" .. array[i] .. "\""
			else
				output[i] = tostring(array[i])
			end
		end
		return "{" .. table.concat(output, ", ") .. "}"
	else
		return "{}"
	end
end

local function PrintToken(token)
	if(type(token) == "table" and token.token ~= nil) then
		return "'" .. token.token .. "'"
	else
		return "'" .. tostring(token) .. "'"
	end
end

local function Convert(input, value)
	if(type(value) == "string") then
		local _, linkData = value:match("|H(.-):(.-)|h(.-)|h")
		if(linkData and linkData ~= "") then
			value = linkData
		end
		return (input:find(value) ~= nil)
	end
	return value
end

local function AndOperation(input, a, b)
	a = Convert(input, a)
	b = Convert(input, b)
	return (a and b)
end

local function OrOperation(input, a, b)
	a = Convert(input, a)
	b = Convert(input, b)
	return (a or b)
end

local function NotOperation(input, a)
	return not Convert(input, a)
end

local function LinkGeneralizationOperation(input, a)
	local _, linkData = a:match("|H(.-):(.-)|h(.-)|h")
	if(linkData and linkData ~= "") then
		local data = {zo_strsplit(":", linkData)}
		if(data[1] == "item") then
			a = table.concat({"|H0:", data[1], ":", data[2], "|h|h"})
		end
	end
	return a
end

local function Sanitize(value)
	return value:gsub("[-*+?^$().[%]%%]", "%%%0") -- escape meta characters
end

local OPERATORS = {
	[" "] = { precedence = 2, numArguments = 2, operation = AndOperation, defaultArgument = true },
	["&"] = { precedence = 2, numArguments = 2, operation = AndOperation, defaultArgument = true },
	["+"] = { precedence = 3, numArguments = 2, operation = OrOperation, defaultArgument = false },
	["/"] = { precedence = 3, numArguments = 2, operation = OrOperation, defaultArgument = false },
	["-"] = { precedence = 4, isLeftAssociative = false, numArguments = 1, operation = NotOperation },
	["!"] = { precedence = 4, isLeftAssociative = false, numArguments = 1, operation = NotOperation },
	["^"] = { precedence = 4, isLeftAssociative = false, numArguments = 1, operation = NotOperation },
	["~"] = { precedence = 5, isLeftAssociative = false, numArguments = 1, operation = LinkGeneralizationOperation },
	["*"] = { precedence = 5, isLeftAssociative = false, numArguments = 1, operation = LinkGeneralizationOperation },
	["("] = { isLeftParenthesis = true }, -- control operator
	[")"] = { isRightParenthesis = true }, -- control operator
	["\""] = {}, -- control operator, will be filtered before parsing
}
local OPERATOR_PATTERN = {}
for token, data in pairs(OPERATORS) do
	data.token = token
	OPERATOR_PATTERN[#OPERATOR_PATTERN + 1] = Sanitize(token)
end
OPERATOR_PATTERN = table.concat(OPERATOR_PATTERN, "")
local TOKEN_DUPLICATION_PATTERN = string.format("([%s])", OPERATOR_PATTERN)
local TOKEN_MATCHING_PATTERN = string.format("([%s])(.-)[%s]", OPERATOR_PATTERN, OPERATOR_PATTERN)
lib.OPERATORS = OPERATORS

function lib:Tokenize(input)
	input = " " .. input:gsub(TOKEN_DUPLICATION_PATTERN, "%1%1") .. " "
	local tokens = {}
	local inQuotes = false
	local lastTerm, lastOperator

	for operator, term in (input):gmatch(TOKEN_MATCHING_PATTERN) do
		--		print(string.format("'%s' '%s' tokens: %s", operator, term, PrintArray(tokens)))
		if(operator == "\"") then
			inQuotes = not inQuotes
			if(inQuotes) then
				lastTerm = term
			else
				if(lastTerm ~= "") then
					tokens[#tokens + 1] = lastOperator or " "
					tokens[#tokens + 1] = lastTerm
				end
				lastOperator = nil

				if(term ~= "") then
					tokens[#tokens + 1] = " "
					tokens[#tokens + 1] = term
				end
			end
		elseif(inQuotes) then -- collect all terms and operators
			lastTerm = lastTerm .. operator .. term
		else
			if(operator == "(" or operator == ")") then
				tokens[#tokens + 1] = lastOperator
				lastOperator = nil
				if(term == "") then
					tokens[#tokens + 1] = operator
					operator = nil
				end
			elseif(OPERATORS[operator].isLeftAssociative == false and not lastOperator and operator ~= "-") then
				lastOperator = " "
			end
			if(operator ~= nil) then
				if(term ~= "") then
					if(operator == "-" and #tokens > 0 and not lastOperator) then
						tokens[#tokens] = tokens[#tokens] .. operator .. term
					else
						if(OPERATORS[operator].isLeftAssociative == false) then
							tokens[#tokens + 1] = lastOperator
							lastOperator = nil
						end
						tokens[#tokens + 1] = operator
						tokens[#tokens + 1] = term
					end
				elseif(OPERATORS[operator].isLeftAssociative == false) then
					tokens[#tokens + 1] = lastOperator
					tokens[#tokens + 1] = operator
					lastOperator = nil
				else
					lastOperator = operator
				end
			end
		end
	end

	if(inQuotes) then
		tokens[#tokens + 1] = lastOperator
		if(lastTerm ~= "") then
			tokens[#tokens + 1] = lastTerm
		end
	elseif(lastOperator == "(" or lastOperator == ")") then
		tokens[#tokens + 1] = lastOperator
	end

	return tokens
end

function lib:Parse(tokens)
	local output, stack = {}, {}
	for i = 1, #tokens do
		local token = tokens[i]
		if(OPERATORS[token]) then
			local operator = OPERATORS[token]
			if(operator.isRightParenthesis) then
				while true do
					local popped = table.remove(stack)
					if(not popped or popped.isLeftParenthesis) then
						break
					else
						output[#output + 1] = popped
					end
				end
			elseif(operator.isLeftParenthesis) then
				stack[#stack + 1] = OPERATORS[token]
			elseif(stack[#stack]) then
				local top = stack[#stack]
				if(top.precedence ~= nil
					and ((operator.isLeftAssociative and operator.precedence <= top.precedence)
					or (not operator.isLeftAssociative and operator.precedence < top.precedence))) then
					output[#output + 1] = table.remove(stack)
				end
				stack[#stack + 1] = OPERATORS[token]
			else
				stack[#stack + 1] = OPERATORS[token]
			end
		else
			output[#output + 1] = token
		end
	end
	while true do
		local popped = table.remove(stack)
		if(not popped) then
			break
		elseif(popped.isLeftParenthesis or popped.isRightParenthesis) then
		--ignore misplaced parentheses
		else
			output[#output + 1] = popped
		end
	end
	return output
end

function lib:Evaluate(haystack, parsedTokens)
	local stack = {}
	if(parsedTokens[#parsedTokens].defaultArgument ~= nil) then -- this prevents the root operation from failing
		table.insert(parsedTokens, 1, parsedTokens[#parsedTokens].defaultArgument)
	end
	for i = 1, #parsedTokens do
		local current = parsedTokens[i]
		if(type(current) == "table" and current.operation ~= nil) then
			if(#stack < current.numArguments) then
				return false, lib.RESULT_INVALID_ARGUMENT_COUNT
			else
				local args = {}
				for j = 1, current.numArguments do
					args[#args + 1] = table.remove(stack)
				end
				stack[#stack + 1] = current.operation(haystack, unpack(args))
			end
		else
			stack[#stack + 1] = type(current) == "string" and Sanitize(current) or current
		end
	end

	if(#stack == 1) then
		return stack[1], lib.RESULT_OK
	else
		return false, lib.RESULT_INVALID_VALUE_COUNT
	end
end

function lib:Filter(haystack, needle)
	local tokens = self:Tokenize(needle)
	local parsedTokens = self:Parse(tokens)
	return self:Evaluate(haystack, parsedTokens)
end
