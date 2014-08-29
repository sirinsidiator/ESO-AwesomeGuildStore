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
	function GetSkillLineInfo() end
	function GetCraftingSkillName() end
	function LocalizeString() end
	
	ITEMFILTERTYPE_ALL = 1
	ITEMFILTERTYPE_WEAPONS = 2
	ITEMFILTERTYPE_ARMOR = 3
	ITEMFILTERTYPE_CONSUMABLE = 4
	ITEMFILTERTYPE_CRAFTING = 5
	ITEMFILTERTYPE_MISCELLANEOUS = 6
	
	TRADING_HOUSE_FILTER_TYPE_EQUIP = 1
	TRADING_HOUSE_FILTER_TYPE_WEAPON = 2
	TRADING_HOUSE_FILTER_TYPE_ARMOR = 3
	TRADING_HOUSE_FILTER_TYPE_ITEM = 4
end

mockGlobals()
require('esoui.libraries.globals.localization')
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
