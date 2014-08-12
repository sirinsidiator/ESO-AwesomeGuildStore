require('luaunit')

local function getAddonName()
	local name
	for line in io.lines(".project") do
		name = line:match("^\t<name>(.+)</name>")
		if(name) then
			return name
		end
	end
	print("Could not find addon name.")
	return nil
end

local function importAddonFiles()
	for line in io.lines("src/" .. getAddonName() .. ".txt") do
		if(not line:find("^%s*##") and line:find("\.lua")) then
			require(line:match("^%s*(.+)\.lua"))
		end
	end
end

local function mockGlobals()
	function GetWindowManager()
		return {}
	end
	function GetEventManager()
		return { RegisterForEvent = function() end }
	end
end

mockGlobals()
require('esoui.libraries.globals.globalvars')
require('esoui.libraries.utility.baseobject')
require('esoui.libraries.utility.zo_tableutils')
require('esoui.ingamelocalization.localizegeneratedstrings')
importAddonFiles()

require('AwesomeGuildStoreTest')

---- Control test output:
lu = LuaUnit
-- lu:setOutputType( "NIL" )
-- lu:setOutputType( "TAP" )
lu:setVerbosity( 1 )
os.exit( lu:run() )
