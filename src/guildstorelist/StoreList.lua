local AGS = AwesomeGuildStore

local StoreData = AGS.class.StoreData

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

function StoreList:Initialize(saveData)
    self.saveData = saveData
    self.store = {}
    self.confirmedKiosks = {}
    for storeIndex, serializedData in pairs(saveData) do
        local store = StoreData:New()
        store.index = storeIndex
        store:Deserialize(serializedData)
        self.store[storeIndex] = store
    end
end

function StoreList:InitializeConfirmedKiosks(kioskList)
    for _, kiosk in pairs(kioskList:GetAllKiosks()) do
        self:SetConfirmedKiosk(kiosk)
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