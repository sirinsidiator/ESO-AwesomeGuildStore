local LIB_IDENTIFIER = "LibPromises"

assert(not _G[LIB_IDENTIFIER], LIB_IDENTIFIER .. " is already loaded")

local lib = {}
_G[LIB_IDENTIFIER] = lib

local STATE_PENDING = 1
local STATE_FULFILLED = 2
local STATE_REJECTED = 3
local STATE_STRING = {
    [STATE_PENDING] = "STATE_PENDING",
    [STATE_FULFILLED] = "STATE_FULFILLED",
    [STATE_REJECTED] = "STATE_REJECTED",
}

local Promise = ZO_Object:Subclass()

local function IsPromise(obj)
    return getmetatable(obj) == Promise
end

local function IsCallable(func)
    return type(func) == "function" or type((getmetatable(func) or {}).__call) == "function"
end

local function IsThenable(table)
    return type(table) == "table" and table.Then and IsCallable(table.Then)
end

local Resolve

local function ResolveThenable(promise, x)
    local wasCalled = false
    local success, e = pcall(function()
        return x:Then(function(y)
            if(not wasCalled) then
                wasCalled = true
                Resolve(promise, y)
            end
        end, function(r)
            if(not wasCalled) then
                wasCalled = true
                promise:Reject(r)
            end
        end)
    end)
    if(not success and not wasCalled) then promise:Reject(e) return end
end

function Resolve(promise, x)
    if(promise == x) then promise:Reject("TypeError: Tried to pass promise to itself") return end
    if(IsPromise(x)) then
        x:Then(function(value)
            Resolve(promise, value)
        end, function(reason)
            promise:Reject(reason)
        end)
    elseif(IsCallable(x)) then
        ResolveThenable(promise, { Then = x })
    elseif(type(x) == "table") then
        local success, e = pcall(IsThenable, x)
        if(not success) then
            promise:Reject(e)
        elseif(e) then
            ResolveThenable(promise, x)
        else
            promise:Resolve(x)
        end
    else
        promise:Resolve(x)
    end
end

local function ExecuteLater(func, value)
    zo_callLater(function()
        func(value)
    end, 0)
end

local function ExecuteAllLater(functions, value)
    for i = 1, #functions do
        ExecuteLater(functions[i], value)
    end
end

local function ClearAll(functions)
    for i = 1, #functions do
        functions[i] = nil
    end
end

local function SanitizeError(err)
    -- Lua5.1 error() converts numeric arguments to string and prepends the line info
    -- TODO: check behavior inside ESO and write some simple tests for it
    if(type(err) == "string") then
        local x = err:match("lua:%d+: (%d+)$")
        if(x and tonumber(x)) then
            return tonumber(x)
        end
    end
    return err
end

local function GetNumArgsAndArgs(...)
    return select("#", ...), ...
end

local function WrapCall(callback, promise, nextPromise)
    return function()
        local count, x -- we need to distinguish between nil and no return value
        local success, e = pcall(function()
            count, x = GetNumArgsAndArgs(callback(promise.value))
        end)
        if(not success) then
            nextPromise:Reject(SanitizeError(e))
        elseif(count > 0) then
            Resolve(nextPromise, x)
        end
    end
end

local function FlushAllCallbacks(self)
    if(self.state == STATE_FULFILLED) then
        ExecuteAllLater(self.fulfilled, self.value)
    elseif(self.state == STATE_REJECTED) then
        ExecuteAllLater(self.rejected, self.value)
    end

    if(self.state ~= STATE_PENDING) then
        ClearAll(self.fulfilled)
        ClearAll(self.rejected)
    end
end

local next = 1
function Promise:New()
    local obj = ZO_Object.New(self)
    obj.name = string.format("Promise%d", next)
    next = next + 1
    obj.state = STATE_PENDING
    obj.fulfilled = {}
    obj.rejected = {}
    return obj
end

function Promise:Then(OnFulfilled, OnRejected)
    local nextPromise = Promise:New()

    if(IsCallable(OnFulfilled)) then
        self.fulfilled[#self.fulfilled + 1] = WrapCall(OnFulfilled, self, nextPromise)
    else
        self.fulfilled[#self.fulfilled + 1] = function(value) nextPromise:Resolve(value) end
    end

    if(IsCallable(OnRejected)) then
        self.rejected[#self.rejected + 1] = WrapCall(OnRejected, self, nextPromise)
    else
        self.rejected[#self.rejected + 1] = function(value) nextPromise:Reject(value) end
    end

    if(self.state ~= STATE_PENDING) then
        FlushAllCallbacks(self)
    end

    return nextPromise
end

function Promise:Resolve(value)
    if(self.state == STATE_PENDING) then
        self.value = value
        self.state = STATE_FULFILLED
        FlushAllCallbacks(self)
    end
end

function Promise:Reject(reason)
    if(self.state == STATE_PENDING) then
        self.value = reason
        self.state = STATE_REJECTED
        FlushAllCallbacks(self)
    end
end

function Promise:ToString(name)
    name = name or self.name or "Promise"
    local stateString = STATE_STRING[self.state]
    local numFulfilled = #self.fulfilled
    local numRejected = #self.rejected
    return string.format("%s(%s, #f: %d, #r: %d)", name, stateString, numFulfilled, numRejected)
end

function lib:New()
    return Promise:New()
end
