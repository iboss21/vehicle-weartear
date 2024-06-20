local Framework = exports[Config.Framework == 'QBCore' and 'qb-core' or 'es_extended']:getSharedObject()

RegisterServerEvent('theluxempire-vehiclewear:server:RepairVehicle')
AddEventHandler('theluxempire-vehiclewear:server:RepairVehicle', function(vehicleNetId, repairCost)
    local src = source
    local Player = Framework.Functions.GetPlayer(src)

    -- Check money (adjust for ESX if needed)
    if (Config.Framework == 'QBCore' and Player.Functions.RemoveMoney('cash', repairCost, "vehicle-repair")) or (Config.Framework == 'ESX' and Player.removeMoney(repairCost)) then
        TriggerClientEvent('theluxempire-vehiclewear:client:VehicleRepaired', src, vehicleNetId)
        TriggerEvent('QBCore:Notify', "Vehicle repaired!", 'success') 
    else
        TriggerEvent('QBCore:Notify', "Not enough money to repair!", 'error')
    end
end)

RegisterNetEvent('theluxempire-vehiclewear:client:VehicleRepaired')
AddEventHandler('theluxempire-vehiclewear:client:VehicleRepaired', function(vehicleNetId)
    local vehicle = NetToVeh(vehicleNetId)
    vehicleWear[vehicleNetId] = 0.0
    SetVehicleDirtLevel(vehicle, 0.0)
end)
