local AGS = AwesomeGuildStore

local StoreData = AGS.class.StoreData
local logger = AGS.internal.logger

local StoreList = ZO_Object:Subclass()
AGS.class.StoreList = StoreList

function StoreList:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function StoreList.UpdateStoreIds(saveData)
    local newSaveData = {}
    for storeIndex, serializedData in pairs(saveData) do
        local newIndex = storeIndex:gsub("(.-)^.-%.(.-)", "%1.%2")
        newSaveData[newIndex] = serializedData
    end
    return newSaveData
end

function StoreList:Initialize(saveData, kioskList)
    self.saveData = saveData
    self.store = {}
    self.confirmedKiosks = {}
    local invalid = {}
    for storeIndex, serializedData in pairs(saveData) do
        local store = StoreData:New()
        store.index = storeIndex
        store:Deserialize(serializedData)
        self.store[storeIndex] = store
        if not store.kiosks or #store.kiosks == 0 then
            logger:Warn("Mark store entry '%s' for removal (no kiosks)", storeIndex)
            invalid[#invalid + 1] = storeIndex
        else
            if store.confirmed then
                for i = 1, #store.kiosks do
                    if not kioskList:HasKiosk(store.kiosks[i]) then
                        logger:Warn("Mark store entry '%s' as unconfirmed (invalid kiosk)", storeIndex)
                        store.confirmed = false
                        break
                    end
                end
            end
        end
    end
    for i = 1, #invalid do
        local storeIndex = invalid[i]
        saveData[storeIndex] = nil
        self.store[storeIndex] = nil
    end
end

function StoreList:InitializeConfirmedKiosks(kioskList)
    local invalidKiosks = {}
    for _, kiosk in pairs(kioskList:GetAllKiosks()) do
        self:SetConfirmedKiosk(kiosk)
        if not self.store[kiosk.storeIndex] then
            logger:Warn("Mark kiosk with invalid storeIndex", kiosk.name, kiosk.storeIndex)
            invalidKiosks[kiosk.name] = kiosk
        end
    end

    for storeIndex, store in pairs(self.store) do
        for i = 1, #store.kiosks do
            local kiosk = invalidKiosks[store.kiosks[i]]
            if kiosk then
                logger:Info("Update invalid storeIndex on kiosk", kiosk.name)
                kiosk.storeIndex = storeIndex
                kioskList:SetKiosk(kiosk)
                invalidKiosks[kiosk.name] = nil
            end
        end
    end

    for kioskName, kiosk in pairs(invalidKiosks) do
        logger:Warn("Could not fix invalid storeIndex on kiosk", kioskName)
    end
end

function StoreList:SetConfirmedKiosk(kiosk)
    local confirmedKiosks = self.confirmedKiosks
    local kiosks = confirmedKiosks[kiosk.storeIndex] or {}
    confirmedKiosks[kiosk.storeIndex] = kiosks
    kiosks[kiosk.name] = true

    local store = self.store[kiosk.storeIndex]
    if(store and not store.confirmed and #store.kiosks == NonContiguousCount(kiosks)) then
        local newKiosks = {}
        for kioskName in pairs(kiosks) do
            newKiosks[#newKiosks + 1] = kioskName
        end
        store.kiosks = newKiosks
        store.confirmed = true
        self:SetStore(store)
    end
end

function StoreList:HasConfirmedKiosk(store, kiosk)
    local kiosks = self.confirmedKiosks[store.index]
    return kiosks ~= nil and kiosks[kiosk.name]
end

function StoreList:HasStore(storeIndex)
    return self.store[storeIndex] ~= nil
end

function StoreList:GetStore(storeIndex)
    return self.store[storeIndex]
end

function StoreList:GetAllStores()
    return self.store
end

function StoreList:IsEmpty()
    return next(self.store) == nil
end

function StoreList:SetStore(store)
    self.store[store.index] = store
    self.saveData[store.index] = store:Serialize()
end
