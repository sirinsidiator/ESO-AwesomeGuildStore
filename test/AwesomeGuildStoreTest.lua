TestAwesomeGuildStore = {}

local LOWER_LIMIT = 1
local UPPER_LIMIT = 2100000000
local values = { LOWER_LIMIT, 10, 50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000, 50000, 100000, UPPER_LIMIT }
local function ToNearestLinear(value)
	for i, range in ipairs(values) do
		if(i < #values and value < ((values[i + 1] + range) / 2)) then return i end
	end
	return #values
end

function TestAwesomeGuildStore:setUp()
end

function TestAwesomeGuildStore:testToLinear()
	assertEquals(ToNearestLinear(-1), 1)
	assertEquals(ToNearestLinear(0), 1)
	assertEquals(ToNearestLinear(1), 1)
	assertEquals(ToNearestLinear(5), 1)
	assertEquals(ToNearestLinear(6), 2)
	assertEquals(ToNearestLinear(10), 2)
	assertEquals(ToNearestLinear(29), 2)
	assertEquals(ToNearestLinear(30), 3)
	assertEquals(ToNearestLinear(50), 3)
	assertEquals(ToNearestLinear(74), 3)
	assertEquals(ToNearestLinear(75), 4)
	assertEquals(ToNearestLinear(100), 4)
	assertEquals(ToNearestLinear(100000), 24)
	assertEquals(ToNearestLinear(1e20), 25)
end
