ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
local file = LoadResourceFile(GetCurrentResourceName(), "./data.json")
local allplayerData = json.decode(file) or {}


ESX.RegisterServerCallback("mn-recycle:sever:checkPlayerData", function(source , callback)
    local src = source
    local user = ESX.GetPlayerFromId(src)
    if not (allplayerData[user.identifier]) then 
        allplayerData[user.identifier] = {
            identifier = user.identifier,
            totalPickups = 0,
            level = 1 ,
            level_percentage = 0
        }
    end

    callback(allplayerData[user.identifier])
    saveData()
end)


saveData = function()
    SaveResourceFile(GetCurrentResourceName(), "data.json", json.encode(allplayerData), -1)
end