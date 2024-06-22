local Framework, QBCore, ESX = nil, nil, nil

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

RegisterServerEvent('theluxempire-vehiclewear:server:RepairVehicle')
AddEventHandler('theluxempire-vehiclewear:server:RepairVehicle', function(vehicleNetId, repairCost)
    local src = source
    
    if Framework ~= nil then
        local Player = Framework.Functions.GetPlayer(src)
    
        if Framework.__framework == "es_extended" then
            if Player.removeMoney(repairCost) then
                TriggerClientEvent('theluxempire-vehiclewear:client:VehicleRepaired', src, vehicleNetId)
                TriggerClientEvent('esx:showNotification', src, 'Vehicle repaired!')
            else
                TriggerClientEvent('esx:showNotification', src, 'Not enough money to repair!')
            end
        elseif Framework.__framework == "qb-core" then
            if Player.Functions.RemoveMoney('cash', repairCost, "vehicle-repair") then
                TriggerClientEvent('theluxempire-vehiclewear:client:VehicleRepaired', src, vehicleNetId)
                TriggerClientEvent('QBCore:Notify', src, "Vehicle repaired!", "success")
            else
                TriggerClientEvent('QBCore:Notify', src, "Not enough money to repair!", "error")
            end
        end
    end
end)
