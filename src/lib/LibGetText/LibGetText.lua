local LIB_IDENTIFIER = "LibGetText"

assert(not _G[LIB_IDENTIFIER], LIB_IDENTIFIER .. " is already loaded")

local lib = {
    instance = {},
}
_G[LIB_IDENTIFIER] = lib

local Dictionary = ZO_Object:Subclass()

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

local function GetInstance(_, addon)
    if(not lib.instance[addon]) then
        lib.instance[addon] = Dictionary:New()
    end
    return lib.instance[addon]
end

setmetatable(lib, { __call = GetInstance })
