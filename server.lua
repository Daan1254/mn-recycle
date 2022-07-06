ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
local file = LoadResourceFile(GetCurrentResourceName(), "./data.json")
local allplayerData = json.decode(file) or {}


ESX.RegisterServerCallback("mn-recycle:server:checkPlayerData", function(source , callback)
    local src = source
    local user = ESX.GetPlayerFromId(src)
    if not (allplayerData[user.identifier]) then 
        allplayerData[user.identifier] = {
            identifier = user.identifier,
            totalPickups = 0,
            level = 1,
            XP = 0
        }
    end

    callback(allplayerData[user.identifier])
    saveData()
end)

ESX.RegisterServerCallback("mn-recycle:server:yetoch", function(source, callback, packagespicked)
    local price = MN.payoutperPackage
    local src = source
    local user = ESX.GetPlayerFromId(src)
    if not (allplayerData[user.identifier]) then return end
    if (packagespicked < 1) then return end
    user.addAccountMoney('bank', (packagespicked * price))
end)

ESX.RegisterServerCallback("mn-recycle:server:yetoch2", function(source, callback, packagespicked)

    local src = source
    local user = ESX.GetPlayerFromId(src)
    if not (allplayerData[user.identifier]) then return end

    local rand = math.random(1, #MN.LevelSystem[allplayerData[user.identifier].level].itemsUnlock)


    user.addInventoryItem(MN.LevelSystem[allplayerData[user.identifier].level].itemsUnlock[rand].itemname, MN.LevelSystem[allplayerData[user.identifier].level].itemsUnlock[rand].count)
end)


ESX.RegisterServerCallback("mn-recycle:server:syncLocalPlayerdata", function(source, callback, localPlayerData)
    if not localPlayerData then return end
    allplayerData[ESX.GetPlayerFromId(source).identifier] = localPlayerData
    callback(allplayerData[ESX.GetPlayerFromId(source).identifier])
    saveData()
end)


saveData = function()
    SaveResourceFile(GetCurrentResourceName(), "data.json", json.encode(allplayerData), -1)
end