ESX = nil


insideCentrum = false
localPlayerData  = nil    

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    ESX.TriggerServerCallback("mn-recycle:server:checkPlayerData", function(playerData)
        localPlayerData = playerData
    end)
end)

Citizen.CreateThread(function()
    while true do 
        Wait(3)
        local ped, coords = PlayerPedId(), GetEntityCoords(PlayerPedId())

        for k,v in pairs(MN.markers) do 
            local x,y,z = table.unpack(v.coords)
            local dist = #(vector3(x,y,z) - coords)


            if (dist < 10) then 
                DrawMarker(20,x,y,z - 0.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.3, 0.2, 147,112,219, 100, false, true, 2, true, nil, nil, false)
                
                if (dist < 1.5) then 
                    DrawScriptText(vector3(x,y,z), v.drawText)

                    if (IsControlJustReleased(0, v.key)) then 
                        TriggerEvent(v.trigger)
                    end
                end
            end
        end
    end
end)



RegisterNetEvent("mn-recycle:client:enter")
AddEventHandler("mn-recycle:client:enter", function()
    DoScreenFadeOut(200)
    while not IsScreenFadedOut() do
        Citizen.Wait(0)
    end
    local x,y,z,h = table.unpack(MN.insideLocation)
    SetEntityCoords(PlayerPedId(), x,y,z)
    SetEntityHeading(PlayerPedId(), h)
    Citizen.Wait(1000)
    DoScreenFadeIn(200)
    spawnObjects()
    startLoop()
    insideCentrum = true
end)


objects = {}

RegisterNetEvent("mn-recycle:client:leave")
AddEventHandler("mn-recycle:client:leave", function()
    DoScreenFadeOut(200)
    while not IsScreenFadedOut() do
        Citizen.Wait(0)
    end
    local x,y,z = table.unpack(MN.markers[1].coords)
    SetEntityCoords(PlayerPedId(), x,y,z)
    Citizen.Wait(1000)
    DoScreenFadeIn(200)
    removeObjects()
    insideCentrum = false
end)

RegisterNetEvent("mn-recycle:client:dashboard")
AddEventHandler("mn-recycle:client:dashboard", function()
    SetNuiFocus(true,true)
    print(ESX.DumpTable(localPlayerData))
    SendNUIMessage({
        action = 'open',
        playerData = localPlayerData,
        packagesDone = packagespicked,
        payoutperPackage = MN.payoutperPackage,
        levelConfig = MN.LevelSystem
    })
end)


RegisterNUICallback("close", function()
    SetNuiFocus(false, false)
end)

spawnObjects = function()
    while not HasModelLoaded(MN.boxObject) do 
        RequestModel(MN.boxObject)
        Wait(3)
    end

    for k,v in pairs(MN.pickupLocations) do 
        local x,y,z,h = table.unpack(v)
        local object = CreateObject(MN.boxObject, x, y, z, false, true, true)
        FreezeEntityPosition(object, true)
        table.insert(objects, object)
    end
end

removeObjects = function()
    for k,v in pairs(objects) do 
        DeleteEntity(v)
    end
end

local rand
packagespicked = 0
startLoop = function()
    rand = math.random(1, #MN.pickupLocations)
    Citizen.CreateThread(function()
        while true do 
            Wait(3)
            local ped , coords = PlayerPedId(), GetEntityCoords(PlayerPedId())
            if not rand then rand = math.random(1, #MN.pickupLocations) end

            local x,y,z,h = table.unpack(MN.pickupLocations[rand])
            local xc, yc, zc = table.unpack(MN.dropLocation)

            local dist = #(vector3(x,y,z) - coords)
            local distDropLocation = #(vector3(xc, yc, zc) - coords)

            if insideCentrum then 
                DisableControlAction(0, 21, true)
            else
                DisableControlAction(0, 21, false)
            end
            sleep = true
            if GetFollowPedCamViewMode() == 4 then FreezeEntityPosition(PlayerPedId(), true) else FreezeEntityPosition(PlayerPedId(), false) end
            if not (isHolding) then 
                DrawMarker(20,x,y,z + 3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.3, 0.2, 147,112,219, 100, false, true, 2, true, nil, nil, false)
                if (dist < 2.5) then 
                    DrawScriptText(vector3(x,y,z + 1), "[~g~E~w~] pakket oppakken")

                    if IsControlJustReleased(0, 38) then 
                        pickupPackage()
                    end
                end
            else
                DrawMarker(20,xc, yc, zc - 0.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.3, 0.2, 147,112,219, 100, false, true, 2, true, nil, nil, false)
                if (distDropLocation < 1.5) then 
                    DrawScriptText(vector3(xc, yc, zc), "[~g~E~w~] pakket droppen")

                    if IsControlJustReleased(0, 38) then 
                        dropPackage()
                        packagespicked = packagespicked + 1
                        localPlayerData.XP = localPlayerData.XP + MN.XPperPackage
                        if (MN.LevelSystem[localPlayerData.level + 1]) then
                            if (localPlayerData.XP >= MN.LevelSystem[localPlayerData.level + 1].XPneededToLevel) then 
                                localPlayerData.level = localPlayerData.level + 1
                            end
                        end
                        print(ESX.DumpTable(localPlayerData))
                        localPlayerData.totalPickups = localPlayerData.totalPickups + 1
                    end
                end
            end
            if not (insideCentrum) then return end
        end
    end)
end

local carryPackage


Citizen.CreateThread(function()
    while true do 
        Wait(5000)
        ESX.TriggerServerCallback("mn-recycle:server:syncLocalPlayerdata", function(data)
            localPlayerData = data
        end, localPlayerData)
    end
end)



pickupPackage = function()
    ESX.ShowNotification("~g~Breng het pakketje naar de rode deur!")
    isHolding = true
    local pos = GetEntityCoords(PlayerPedId(), true)
    RequestAnimDict("anim@heists@box_carry@")
    while (not HasAnimDictLoaded("anim@heists@box_carry@")) do
        Citizen.Wait(7)
    end
    TaskPlayAnim(PlayerPedId(), "anim@heists@box_carry@" ,"idle", 5.0, -1, -1, 50, 0, false, false, false)
    local model = GetHashKey("prop_cs_cardbox_01")
    RequestModel(model)
    while not HasModelLoaded(model) do Citizen.Wait(0) end
    local object = CreateObject(model, pos.x, pos.y, pos.z, true, true, true)
    AttachEntityToEntity(object, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.05, 0.1, -0.3, 300.0, 250.0, 20.0, true, true, false, true, 1, true)
    carryPackage = object
end

RegisterNUICallback("yetoch", function()
    print(packagespicked)
    ESX.TriggerServerCallback("mn-recycle:server:yetoch", function() 
    end,packagespicked)
    packagespicked = 0
end)


dropPackage = function()
    ESX.ShowNotification("~g~Goed gewerkt! ga verder met het volgende pakketje of cash uit bij de laptop!")

    ClearPedTasks(PlayerPedId())
    DetachEntity(carryPackage, true, true)
    DeleteObject(carryPackage)
    carryPackage = nil
    isHolding = false
    rand = nil
    ESX.TriggerServerCallback("mn-recycle:server:yetoch2")

end



AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    removeObjects()


    if (insideCentrum) then 
        leaveCentrum()
    end
end)


leaveCentrum = function()
    insideCentrum = false
    local x,y,z = table.unpack(MN.markers[1].coords)
    SetEntityCoords(PlayerPedId(), x,y,z)
end


RegisterCommand("oeps", function(source ,args)
    DoScreenFadeIn(200)

end)
  

function DrawScriptText(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords["x"], coords["y"], coords["z"])

    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)

    local factor = string.len(text) / 370

    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 65)
end