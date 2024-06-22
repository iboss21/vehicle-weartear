local Framework, QBCore, ESX = nil, nil, nil
local playerPed = PlayerPedId()
local currentVehicle = nil
local vehicleWear = {}

-- Framework Detection (on resource start)
Citizen.CreateThread(function()
    while true do
        if GetResourceState('qb-core') == 'started' then
            QBCore = exports['qb-core']:GetCoreObject()
            Framework = QBCore 
            print("^2Vehicle Wear script is using QBCore^0")
            break 
        elseif GetResourceState('es_extended') == 'started' then
            ESX = exports["es_extended"]:getSharedObject()
            Framework = ESX
            print("^2Vehicle Wear script is using ESX^0")
            break 
        end
        Wait(100)
    end
end)


-- Wear Simulation Thread
Citizen.CreateThread(function()
    while Framework == nil do Wait(100) end
    while true do
        Wait(10000) -- Check wear every 10 seconds
        if Config.WearAndTear.EnabledByDefault then
            playerPed = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(playerPed, false)

            if vehicle and vehicle ~= 0 then
                local vehicleNetId = VehToNet(vehicle)
                local currentWear = vehicleWear[vehicleNetId] or 0.0

                -- Apply wear if engine is on or moving
                if IsVehicleEngineOn(vehicle) or GetEntitySpeed(vehicle) > 0 then
                    currentWear = currentWear + Config.WearAndTear.WearRate
                end

                -- Update visual appearance (dirt level)
                SetVehicleDirtLevel(vehicle, currentWear / Config.WearAndTear.MaxWear * Config.WearAndTear.DirtMultiplier)

                -- Update vehicle handling (top speed)
                local handling = GetVehicleHandling(vehicle)
                local fInitialDriveMaxFlatVel = handling["fInitialDriveMaxFlatVel"]
                local newMaxSpeed = fInitialDriveMaxFlatVel * (1.0 - currentWear / Config.WearAndTear.MaxWear * Config.WearAndTear.PerformanceImpact)
                SetVehicleHandlingField(vehicle, 'fInitialDriveMaxFlatVel', newMaxSpeed)

                -- Store wear level
                vehicleWear[vehicleNetId] = currentWear
            end
        end
    end
end)



-- Repair Command
RegisterCommand(Config.Commands.Repair, function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    local coords = GetEntityCoords(playerPed)

    if vehicle and vehicle ~= 0 then
        local vehicleNetId = VehToNet(vehicle)
        local currentWear = vehicleWear[vehicleNetId] or 0.0
        local closestRepair, closestDistance = nil, math.huge

        -- Find closest repair location
        for _, repairLoc in pairs(Config.Maintenance.RepairLocations) do
            local dist = #(coords - vector3(repairLoc.x, repairLoc.y, repairLoc.z))
            if dist < closestDistance then
                closestRepair, closestDistance = repairLoc, dist
            end
        end

        -- Check proximity and job
        if closestDistance <= Config.Maintenance.RepairDistance and (
            (Framework.__framework == 'QBCore' and QBCore.Functions.GetPlayerData().job.name == Config.Maintenance.MechanicJob) or
            (Framework.__framework == 'ESX' and ESX.PlayerData.job.name == Config.Maintenance.MechanicJob)
        ) then
            -- Calculate repair cost
            local repairCost = currentWear * Config.WearAndTear.RepairCost

            -- Trigger server-side repair event
            TriggerServerEvent('theluxempire-vehiclewear:server:RepairVehicle', vehicleNetId, repairCost) 
        else
            TriggerEvent(Framework.__framework == 'QBCore' and 'QBCore:Notify' or 'esx:showNotification', "You are not near a repair location or not authorized to repair!", 'error')
        end
    else
        TriggerEvent(Framework.__framework == 'QBCore' and 'QBCore:Notify' or 'esx:showNotification', "You are not in a vehicle!", 'error')
    end
end, false)


-- Vehicle Repaired Event (client-side)
RegisterNetEvent('theluxempire-vehiclewear:client:VehicleRepaired')
AddEventHandler('theluxempire-vehiclewear:client:VehicleRepaired', function(vehicleNetId)
    local vehicle = NetToVeh(vehicleNetId)
    vehicleWear[vehicleNetId] = 0.0
    SetVehicleDirtLevel(vehicle, 0.0)

    -- Optionally restore vehicle handling to default here
end)
