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
			loaded_chunk = assert(loadfile("./src/" .. line:match("^%s*(.+\.lua)")))
			loaded_chunk()
		end
	end
end

local function mockGlobals()
	function GetAnimationManager()
		return {}
	end
	function GetWindowManager()
		return {
			CreateControlFromVirtual = function()
				LAMAddonPanelsMenuScrollChild = {
					SetResizeToFitPadding = function() end
				}
				return {
					ClearAnchors = function() end,
					SetAnchor = function() end,
					SetHeight = function() end,
					SetWidth = function() end,
					SetHandler = function() end,
				}
			end,
			CreateControl = function()
				return {
					SetAnchorFill = function() end,
					SetEdgeTexture = function() end,
					SetCenterColor = function() end,
				}
			end
		}
	end
	function GetCVar()
		return 0
	end
	function GetEventManager()
		return { RegisterForEvent = function() end }
	end
	function GetInterfaceColor()
		return ""
	end
	function GetString() return "" end
	ZO_OptionsWindowResetToDefaultButton = {}
	controlPanelName = {}
	function ZO_OptionsWindow_AddUserPanel() end
	function ZO_OptionsWindow_InitializeControl() end
end

mockGlobals()
require('esoui.libraries.globals.globalvars')
require('esoui.libraries.globals.globalapi')
require('esoui.libraries.utility.baseobject')
require('esoui.libraries.utility.zo_tableutils')
require('esoui.libraries.utility.zo_hook')
require('esoui.ingamelocalization.localizegeneratedstrings')
importAddonFiles()

require('AwesomeGuildStoreTest')

---- Control test output:
lu = LuaUnit
-- lu:setOutputType( "NIL" )
-- lu:setOutputType( "TAP" )
lu:setVerbosity( 1 )
os.exit( lu:run() )
