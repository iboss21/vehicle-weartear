local Framework, QBCore, ESX = nil, nil, nil
local playerPed = PlayerPedId()
local currentVehicle = nil
local vehicleWear = {}
local isInitialized = false

-- Framework Detection and Initialization
Citizen.CreateThread(function()
    if Config.Framework == 'qb-core' then
        while QBCore == nil do
            TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
            Citizen.Wait(200)
        end
        Framework = QBCore
    elseif Config.Framework == 'esx' then
        while ESX == nil do
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
            Citizen.Wait(200)
        end
        Framework = ESX
    end
    
    isInitialized = true
    TriggerEvent('theluxempire-vehiclewear:client:initialized')
end)

-- Main Wear Simulation Loop
Citizen.CreateThread(function()
    while not isInitialized do Wait(100) end

    while true do
        Wait(Config.Performance.UpdateInterval)
        if Config.WearAndTear.EnabledByDefault then
            playerPed = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(playerPed, false)

            if vehicle and vehicle ~= 0 then
                local vehicleNetId = VehToNet(vehicle)
                local currentWear = vehicleWear[vehicleNetId] or 0.0

                -- Apply complex wear calculation
                currentWear = ApplyComplexWear(vehicle, currentWear)

                -- Update vehicle appearance and performance
                UpdateVehicleState(vehicle, currentWear)

                -- Store and sync wear data
                vehicleWear[vehicleNetId] = currentWear
                if (GetGameTimer() % Config.Performance.SyncInterval) == 0 then
                    TriggerServerEvent('theluxempire-vehiclewear:server:SyncWearData', vehicleNetId, currentWear)
                end

                -- Update UI if enabled
                if Config.UI.ShowWearBar then
                    UpdateWearUI(currentWear)
                end
            end
        end
    end
end)

function ApplyComplexWear(vehicle, currentWear)
    local wearIncrease = 0
    local vehClass = GetVehicleClass(vehicle)
    local classMultiplier = Config.VehicleClasses[vehClass].wearMultiplier

    -- Base wear
    wearIncrease = wearIncrease + Config.WearAndTear.WearRate.Default * classMultiplier

    -- Speed-based wear
    local speed = GetEntitySpeed(vehicle)
    wearIncrease = wearIncrease + (speed / 50) * Config.WearAndTear.WearRate.Racing

    -- Terrain-based wear
    local surfaceType = GetVehicleWheelSurfaceMaterial(vehicle, 1)
    if surfaceType == 4 or surfaceType == 1 then -- Dirt or sand
        wearIncrease = wearIncrease + Config.WearAndTear.WearRate.OffRoad
    end

    -- Weather-based wear
    if Config.WeatherImpact.Enable then
        local weather = GetPrevWeatherTypeHashName()
        if weather == `RAIN` then
            wearIncrease = wearIncrease * Config.WeatherImpact.RainWearIncrease
        elseif weather == `SNOW` then
            wearIncrease = wearIncrease * Config.WeatherImpact.SnowWearIncrease
        end
    end

    -- Time-based wear
    if Config.TimeBasedWear.Enable then
        local hour = GetClockHours()
        if hour >= 22 or hour <= 4 then
            wearIncrease = wearIncrease * Config.TimeBasedWear.NightWearMultiplier
        elseif (hour >= 7 and hour <= 9) or (hour >= 16 and hour <= 18) then
            wearIncrease = wearIncrease * Config.TimeBasedWear.RushHourWearMultiplier
        end
    end

    return math.min(currentWear + wearIncrease, Config.WearAndTear.MaxWear)
end

function UpdateVehicleState(vehicle, wear)
    -- Update visual appearance
    SetVehicleDirtLevel(vehicle, wear / Config.WearAndTear.MaxWear * Config.WearAndTear.VisualImpact.DirtMultiplier)
    
    if wear > Config.WearAndTear.VisualImpact.ScratchThreshold then
        SetVehicleDamage(vehicle, 0.0, 0.0, 0.33, 200.0, 100.0, true)
    end
    
    if wear > Config.WearAndTear.VisualImpact.DentThreshold then
        SetVehicleDamage(vehicle, 0.0, 0.0, 0.66, 1000.0, 100.0, true)
    end

    -- Update vehicle performance
    local handling = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fInitialDriveMaxFlatVel')
    local newMaxSpeed = handling * (1.0 - wear / Config.WearAndTear.MaxWear * Config.WearAndTear.PerformanceImpact.Speed)
    SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fInitialDriveMaxFlatVel', newMaxSpeed)

    -- Additional performance impacts
    ModifyVehicleTopSpeed(vehicle, 1.0 - (wear / Config.WearAndTear.MaxWear * Config.WearAndTear.PerformanceImpact.Speed))
    SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fBrakeForce', GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fBrakeForce') * (1.0 - wear / Config.WearAndTear.MaxWear * Config.WearAndTear.PerformanceImpact.Braking))

    -- Advanced features
    if Config.AdvancedFeatures.EnableEngineStalling and wear > 80 then
        if math.random() < 0.1 then -- 10% chance of stalling
            SetVehicleEngineOn(vehicle, false, true, true)
        end
    end

    if Config.AdvancedFeatures.EnableTirePunctures and wear > 90 then
        if math.random() < 0.05 then -- 5% chance of tire puncture
            SetVehicleTyreBurst(vehicle, math.random(0, 3), true

    if Config.AdvancedFeatures.EnableTirePunctures and wear > 90 then
        if math.random() < 0.05 then -- 5% chance of tire puncture
            SetVehicleTyreBurst(vehicle, math.random(0, 3), true, 1000.0)
        end
    end

    if Config.AdvancedFeatures.EnableOverheating and wear > 70 then
        local temp = GetVehicleEngineTemperature(vehicle)
        SetVehicleEngineTemperature(vehicle, temp + (wear - 70) / 10)
    end

    if Config.AdvancedFeatures.EnableFuelConsumption then
        local fuel = GetVehicleFuelLevel(vehicle)
        SetVehicleFuelLevel(vehicle, fuel - (wear / 1000))
    end
end

function UpdateWearUI(wear)
    if Config.UI.EnableCustomUI then
        -- Trigger your custom UI event here
        TriggerEvent('theluxempire-vehiclewear:updateCustomUI', wear)
    else
        -- Use native UI
        DrawRect(Config.UI.WearBarPosition.x, Config.UI.WearBarPosition.y, 0.1, 0.02, 0, 0, 0, 150)
        DrawRect(Config.UI.WearBarPosition.x - (0.1 - wear / Config.WearAndTear.MaxWear * 0.1) / 2, Config.UI.WearBarPosition.y, wear / Config.WearAndTear.MaxWear * 0.1, 0.02, 255, 0, 0, 150)
    end
end

-- Repair Command
RegisterCommand(Config.Commands.Repair, function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    local coords = GetEntityCoords(playerPed)

    if vehicle and vehicle ~= 0 then
        local vehicleNetId = VehToNet(vehicle)
        local currentWear = vehicleWear[vehicleNetId] or 0.0
        local closestRepair = FindClosestRepairLocation(coords)

        if closestRepair and #(coords - closestRepair.coords) <= Config.Maintenance.RepairDistance and IsPlayerMechanic() then
            -- Calculate repair cost and time
            local repairCost = CalculateRepairCost(currentWear, vehicle)
            local repairTime = CalculateRepairTime(currentWear)

            -- Use ox_lib for menu if available
            if lib and lib.showContext then
                lib.showContext('repair_menu', {
                    title = 'Vehicle Repair',
                    options = {
                        {label = 'Repair Cost', description = ('$%d'):format(repairCost)},
                        {label = 'Repair Time', description = ('%d seconds'):format(repairTime)},
                        {label = 'Start Repair', serverEvent = 'theluxempire-vehiclewear:server:RepairVehicle', args = {vehicleNetId, repairCost, repairTime}}
                    }
                })
            else
                -- Fallback to default repair logic
                TriggerServerEvent('theluxempire-vehiclewear:server:RepairVehicle', vehicleNetId, repairCost, repairTime)
            end
        else
            Notify("You are not near a repair location or not authorized to repair!", 'error')
        end
    else
        Notify("You are not in a vehicle!", 'error')
    end
end, false)

function FindClosestRepairLocation(coords)
    local closestRepair, closestDistance = nil, math.huge
    for _, repairLoc in pairs(Config.Maintenance.RepairLocations) do
        local dist = #(coords - vector3(repairLoc.x, repairLoc.y, repairLoc.z))
        if dist < closestDistance then
            closestRepair, closestDistance = repairLoc, dist
        end
    end
    return closestRepair
end

function IsPlayerMechanic()
    if Config.Framework == 'qb-core' then
        return QBCore.Functions.GetPlayerData().job.name == Config.Maintenance.MechanicJob
    elseif Config.Framework == 'esx' then
        return ESX.GetPlayerData().job.name == Config.Maintenance.MechanicJob
    end
    return false
end

function CalculateRepairCost(wear, vehicle)
    local baseCost = Config.Maintenance.RepairCost.BasePrice + (wear * Config.Maintenance.RepairCost.PerWearPoint)
    local vehicleClass = GetVehicleClass(vehicle)
    if vehicleClass == 7 or vehicleClass == 8 then -- Super or Sports
        baseCost = baseCost * Config.Maintenance.RepairCost.LuxuryVehicleMultiplier
    end
    return math.floor(baseCost)
end

function CalculateRepairTime(wear)
    return math.min(Config.Maintenance.RepairTime.BaseTime + (wear * Config.Maintenance.RepairTime.PerWearPoint), Config.Maintenance.RepairTime.MaxTime)
end

function Notify(message, type)
    if Config.Notifications.UseCustomNotifications then
        -- Trigger your custom notification system here
        TriggerEvent('theluxempire-vehiclewear:customNotify', message, type)
    else
        if Config.Framework == 'qb-core' then
            QBCore.Functions.Notify(message, type)
        elseif Config.Framework == 'esx' then
            ESX.ShowNotification(message)
        end
    end
end

-- Vehicle Repaired Event
RegisterNetEvent('theluxempire-vehiclewear:client:VehicleRepaired')
AddEventHandler('theluxempire-vehiclewear:client:VehicleRepaired', function(vehicleNetId)
    local vehicle = NetToVeh(vehicleNetId)
    vehicleWear[vehicleNetId] = 0.0
    SetVehicleDirtLevel(vehicle, 0.0)
    SetVehicleEngineHealth(vehicle, 1000.0)
    SetVehicleBodyHealth(vehicle, 1000.0)
    SetVehicleDeformationFixed(vehicle)
    SetVehicleUndriveable(vehicle, false)

    -- Restore vehicle handling to default
    SetVehicleHandlingField(vehicle, 'CHandlingData', 'fInitialDriveMaxFlatVel', GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fInitialDriveMaxFlatVel'))
    SetVehicleHandlingField(vehicle, 'CHandlingData', 'fBrakeForce', GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fBrakeForce'))

    Notify("Vehicle has been fully repaired!", 'success')
end)

-- Repair Progress
RegisterNetEvent('theluxempire-vehiclewear:client:RepairProgress')
AddEventHandler('theluxempire-vehiclewear:client:RepairProgress', function(duration)
    if lib and lib.progressBar then
        lib.progressBar({
            duration = duration * 1000,
            label = 'Repairing vehicle...',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
            },
            anim = {
                dict = 'mini@repair',
                clip = 'fixing_a_ped'
            },
        })
    else
        -- Fallback progress display logic
        Notify("Repairing vehicle...", 'info')
        Citizen.Wait(duration * 1000)
        Notify("Repair completed!", 'success')
    end
end)

-- Initialize the script
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    print('The script "' .. resourceName .. '" has been started.')
    -- Perform any necessary initialization here
end)
