local Framework = exports[Config.Framework == 'QBCore' and 'qb-core' or 'es_extended']:getSharedObject()

local playerPed = PlayerPedId()
local currentVehicle = nil
local vehicleWear = {}

-- Thread to simulate wear and tear
Citizen.CreateThread(function()
    while true do
        Wait(10000) -- Check wear every 10 seconds
        if Config.WearAndTear.EnabledByDefault then
            playerPed = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(playerPed, false)
    
            if vehicle and vehicle ~= 0 then
                local vehicleNetId = VehToNet(vehicle)
                local currentWear = vehicleWear[vehicleNetId] or 0.0
    
                -- Apply wear
                if IsVehicleEngineOn(vehicle) or GetEntitySpeed(vehicle) > 0 then
                    currentWear = currentWear + Config.WearAndTear.WearRate
                end
    
                -- Update visual appearance
                SetVehicleDirtLevel(vehicle, currentWear / Config.WearAndTear.MaxWear * Config.WearAndTear.DirtMultiplier)
    
                -- Update vehicle handling
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


-- Command to repair vehicle
RegisterCommand(Config.Commands.Repair, function(source, args, rawCommand)
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    local coords = GetEntityCoords(playerPed)

    if vehicle and vehicle ~= 0 then
        local vehicleNetId = VehToNet(vehicle)
        local currentWear = vehicleWear[vehicleNetId] or 0.0
        local closestRepair, closestDistance = nil, math.huge
        
        -- find closest repair location
        for _, repairLoc in pairs(Config.Maintenance.RepairLocations) do
            local dist = #(coords - vector3(repairLoc.x, repairLoc.y, repairLoc.z))
            if dist < closestDistance then
                closestRepair, closestDistance = repairLoc, dist
            end
        end

        -- If close enough to repair location and has job permission
        if closestDistance <= Config.Maintenance.RepairDistance and (Config.Framework == 'QBCore' and QBCore.Functions.GetPlayerData().job.name == Config.Maintenance.MechanicJob or Config.Framework == 'ESX' and ESX.PlayerData.job.name == Config.Maintenance.MechanicJob) then
            -- Check money (adjust for ESX if needed)
            local hasEnoughMoney = false
            if Config.Framework == 'QBCore' then
                local Player = QBCore.Functions.GetPlayerData()
                hasEnoughMoney = Player.money.cash >= currentWear * Config.WearAndTear.RepairCost
            elseif Config.Framework == 'ESX' then
                hasEnoughMoney = ESX.PlayerData.money >= currentWear * Config.WearAndTear.RepairCost
            end

            if hasEnoughMoney then
                -- Trigger server-side repair event
                TriggerServerEvent('theluxempire-vehiclewear:server:RepairVehicle', vehicleNetId, currentWear * Config.WearAndTear.RepairCost)
            else
                TriggerEvent('QBCore:Notify', "Not enough money to repair!", 'error') 
            end
        else
            TriggerEvent('QBCore:Notify', "You are not near a repair location or not authorized to repair!", 'error') 
        end
    else
        TriggerEvent('QBCore:Notify', "You are not in a vehicle!", 'error') 
    end
end, false)
