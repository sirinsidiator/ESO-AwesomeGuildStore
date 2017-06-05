local LIB_IDENTIFIER = "LibGetText"
local lib = LibStub:NewLibrary(LIB_IDENTIFIER, 1)

if not lib then
	return	-- already loaded and no upgrade necessary
end

local function Log(message, ...)
	df("[%s] %s", LIB_IDENTIFIER, message:format(...))
end

lib.instance = lib.instance or {}

if(not lib.Dictionary) then lib.Dictionary = ZO_Object:Subclass() end
local Dictionary = lib.Dictionary

function Dictionary:New()
    local object = ZO_Object.New(self)
    object.dict = {}
    object.settext = function(...)
        object:SetText(...)
    end
    object.gettext = function(...)
        return object:GetText(...)
    end
    return object
end

function Dictionary:GetText(text, ...)
    text = self.dict[text] or text

    if(select("#", ...) > 0) then
        return zo_strformat(text, ...)
    end

    return text
end

function Dictionary:SetText(text, translation)
    self.dict[text] = translation
end

local function GetInstance(addon)
    if(not lib.instance[addon]) then
        lib.instance[addon] = Dictionary:New()
    end
    return lib.instance[addon]
end

setmetatable(lib, { __call = GetInstance })

local function Unload()
end

local function Load()
	lib.Unload = Unload
end

if(lib.Unload) then lib.Unload() end
Load()