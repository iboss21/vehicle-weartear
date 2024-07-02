local Framework, QBCore, ESX = nil, nil, nil
local isInitialized = false

-- Framework Detection and Initialization
Citizen.CreateThread(function()
    if Config.Framework == 'qb-core' then
        QBCore = exports['qb-core']:GetCoreObject()
        Framework = QBCore
    elseif Config.Framework == 'esx' then
        ESX = exports["es_extended"]:getSharedObject()
        Framework = ESX
    end
    
    isInitialized = true
    print("Vehicle Wear script initialized with " .. Config.Framework)
end)

-- Vehicle Repair Event
RegisterServerEvent('theluxempire-vehiclewear:server:RepairVehicle')
AddEventHandler('theluxempire-vehiclewear:server:RepairVehicle', function(vehicleNetId, repairCost, repairTime)
    local src = source
    
    if not isInitialized then return end

    local Player = GetPlayer(src)
    if not Player then return end

    if CanAffordRepair(Player, repairCost) then
        -- Deduct money
        RemoveMoney(Player, repairCost)

        -- Start repair process
        TriggerClientEvent('theluxempire-vehiclewear:client:RepairProgress', src, repairTime)

        -- Wait for repair to complete
        Citizen.Wait(repairTime * 1000)

        -- Complete repair
        TriggerClientEvent('theluxempire-vehiclewear:client:VehicleRepaired', src, vehicleNetId)
        Notify(src, 'Vehicle repaired!', 'success')

        -- Log the repair
        LogRepair(src, vehicleNetId, repairCost)
    else
        Notify(src, 'Not enough money to repair!', 'error')
    end
end)

-- Sync Wear Data
RegisterServerEvent('theluxempire-vehiclewear:server:SyncWearData')
AddEventHandler('theluxempire-vehiclewear:server:SyncWearData', function(vehicleNetId, wearLevel)
    if Config.Database.SaveInterval > 0 then
        SaveVehicleWearToDatabase(vehicleNetId, wearLevel)
    end
end)

function GetPlayer(src)
    if Config.Framework == "qb-core" then
        return QBCore.Functions.GetPlayer(src)
    elseif Config.Framework == "esx" then
        return ESX.GetPlayerFromId(src)
    end
end

function CanAffordRepair(Player, cost)
    if Config.Framework == "qb-core" then
        return Player.PlayerData.money.cash >= cost
    elseif Config.Framework == "esx" then
        return Player.getMoney() >= cost
    end
end

function RemoveMoney(Player, amount)
    if Config.Framework == "qb-core" then
        Player.Functions.RemoveMoney('cash', amount, "vehicle-repair")
    elseif Config.Framework == "esx" then
        Player.removeMoney(amount)
    end
end

function Notify(src, message, type)
    if Config.Framework == "qb-core" then
        TriggerClientEvent('QBCore:Notify', src, message, type)
    elseif Config.Framework == "esx" then
        TriggerClientEvent('esx:showNotification', src, message)
    end
end

function LogRepair(src, vehicleNetId, cost)
    local Player = GetPlayer(src)
    local identifier = Player.identifier or Player.PlayerData.citizenid
    local logMessage = string.format("Player %s (ID: %s) repaired vehicle %s for $%d", 
        GetPlayerName(src), identifier, vehicleNetId, cost)
    
    if Config.Logging.EnableConsoleLogging then
        print(logMessage)
    end
    
    if Config.Logging.EnableFileLogging then
        -- Implement file logging here
    end
    
    if Config.Logging.EnableWebhookLogging then
        -- Implement webhook logging here
    end
end

function SaveVehicleWearToDatabase(vehicleNetId, wearLevel)
    if Config.Database.SaveInterval > 0 then
        MySQL.Async.execute('INSERT INTO ' .. Config.Database.TableName .. ' (vehicle_netid, wear_level) VALUES (@vehicleNetId, @wearLevel) ON DUPLICATE KEY UPDATE wear_level = @wearLevel', {
            ['@vehicleNetId'] = vehicleNetId,
            ['@wearLevel'] = wearLevel
        })
    end
end

-- Mechanic Job System
RegisterServerEvent('theluxempire-vehiclewear:server:AssignMechanicJob')
AddEventHandler('theluxempire-vehiclewear:server:AssignMechanicJob', function()
    local src = source
    local Player = GetPlayer(src)
    
    if not Player or not IsPlayerMechanic(Player) then return end

    -- Generate a repair job
    local repairJob = GenerateRepairJob()
    
    -- Assign job to player
    TriggerClientEvent('theluxempire-vehiclewear:client:ReceiveRepairJob', src, repairJob)
    
    -- Notify other mechanics
    NotifyOtherMechanics(src, repairJob)
end)

function IsPlayerMechanic(Player)
    if Config.Framework == "qb-core" then
        return Player.PlayerData.job.name == Config.Maintenance.MechanicJob
    elseif Config.Framework == "esx" then
        return Player.job.name == Config.Maintenance.MechanicJob
    end
end

function GenerateRepairJob()
    -- Generate a more complex repair job
    local repairTypes = {'Engine', 'Transmission', 'Suspension', 'Brakes', 'Body'}
    local selectedRepairs = {}
    
    for i = 1, math.random(1, 3) do
        table.insert(selectedRepairs, repairTypes[math.random(#repairTypes)])
    end
    
    return {
        vehicleModel = GetRandomVehicleModel(),
        repairs = selectedRepairs,
        reward = math.random(500, 1500) * Config.MechanicJob.RewardMultiplier,
        expiresIn = os.time() + Config.MechanicJob.JobCooldown
    }
end

function GetRandomVehicleModel()
    -- Implement logic to get a random vehicle model
    local vehicles = {'adder', 'zentorno', 'kuruma', 'buffalo'}
    return vehicles[math.random(#vehicles)]
end

function NotifyOtherMechanics(excludeSrc, job)
    local players = GetPlayers()
    for _, playerSrc in ipairs(players) do
        if tonumber(playerSrc) ~= excludeSrc then
            local Player = GetPlayer(playerSrc)
            if IsPlayerMechanic(Player) then
                TriggerClientEvent('theluxempire-vehiclewear:client:NewRepairJobAvailable', playerSrc, job)
            end
        end
    end
end

-- Initialize the script
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    print('The script "' .. resourceName .. '" has been started.')
    -- Perform any necessary initialization here, such as creating database tables
    InitializeDatabase()
end)

function InitializeDatabase()
    if Config.Database.SaveInterval > 0 then
        MySQL.Async.execute([[
            CREATE TABLE IF NOT EXISTS ]] .. Config.Database.TableName .. [[ (
                id INT AUTO_INCREMENT PRIMARY KEY,
                vehicle_netid VARCHAR(50) NOT NULL UNIQUE,
                wear_level FLOAT NOT NULL,
                last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP function InitializeDatabase()
    if Config.Database.SaveInterval > 0 then
        MySQL.Async.execute([[
            CREATE TABLE IF NOT EXISTS ]] .. Config.Database.TableName .. [[ (
                id INT AUTO_INCREMENT PRIMARY KEY,
                vehicle_netid VARCHAR(50) NOT NULL UNIQUE,
                wear_level FLOAT NOT NULL,
                last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
            )
        ]], {}, function(success)
            if success then
                print("Vehicle wear database table initialized successfully.")
            else
                print("Failed to initialize vehicle wear database table.")
            end
        end)
    end
end

-- Part Replacement System
RegisterServerEvent('theluxempire-vehiclewear:server:ReplacePart')
AddEventHandler('theluxempire-vehiclewear:server:ReplacePart', function(vehicleNetId, partType)
    local src = source
    local Player = GetPlayer(src)
    
    if not Player or not IsPlayerMechanic(Player) then return end
    
    local part = Config.PartReplacement.Parts[partType]
    if not part then
        Notify(src, 'Invalid part type!', 'error')
        return
    end
    
    if CanAffordRepair(Player, part.price) then
        RemoveMoney(Player, part.price)
        
        -- Trigger client-side part replacement
        TriggerClientEvent('theluxempire-vehiclewear:client:ReplacePart', src, vehicleNetId, partType, part.repairAmount, part.installTime)
        
        Notify(src, 'Part replacement started!', 'success')
        LogPartReplacement(src, vehicleNetId, partType, part.price)
    else
        Notify(src, 'Not enough money to replace this part!', 'error')
    end
end)

function LogPartReplacement(src, vehicleNetId, partType, cost)
    local Player = GetPlayer(src)
    local identifier = Player.identifier or Player.PlayerData.citizenid
    local logMessage = string.format("Player %s (ID: %s) replaced %s on vehicle %s for $%d", 
        GetPlayerName(src), identifier, partType, vehicleNetId, cost)
    
    if Config.Logging.EnableConsoleLogging then
        print(logMessage)
    end
    
    if Config.Logging.EnableFileLogging then
        -- Implement file logging here
    end
    
    if Config.Logging.EnableWebhookLogging then
        -- Implement webhook logging here
    end
end

-- Mechanic Tools Shop
RegisterServerEvent('theluxempire-vehiclewear:server:BuyMechanicTool')
AddEventHandler('theluxempire-vehiclewear:server:BuyMechanicTool', function(toolType)
    local src = source
    local Player = GetPlayer(src)
    
    if not Player or not IsPlayerMechanic(Player) then return end
    
    local tool = Config.MechanicTools[toolType]
    if not tool then
        Notify(src, 'Invalid tool type!', 'error')
        return
    end
    
    if CanAffordRepair(Player, tool.price) then
        RemoveMoney(Player, tool.price)
        GiveItem(Player, toolType, 1)
        Notify(src, 'You bought a ' .. tool.label .. '!', 'success')
        LogToolPurchase(src, toolType, tool.price)
    else
        Notify(src, 'Not enough money to buy this tool!', 'error')
    end
end)

function GiveItem(Player, itemName, amount)
    if Config.UseOxInventory then
        exports.ox_inventory:AddItem(Player.source, itemName, amount)
    else
        if Config.Framework == "qb-core" then
            Player.Functions.AddItem(itemName, amount)
        elseif Config.Framework == "esx" then
            Player.addInventoryItem(itemName, amount)
        end
    end
end

function LogToolPurchase(src, toolType, cost)
    local Player = GetPlayer(src)
    local identifier = Player.identifier or Player.PlayerData.citizenid
    local logMessage = string.format("Player %s (ID: %s) purchased tool %s for $%d", 
        GetPlayerName(src), identifier, toolType, cost)
    
    if Config.Logging.EnableConsoleLogging then
        print(logMessage)
    end
    
    if Config.Logging.EnableFileLogging then
        -- Implement file logging here
    end
    
    if Config.Logging.EnableWebhookLogging then
        -- Implement webhook logging here
    end
end

-- Periodic Wear Data Save
if Config.Database.SaveInterval > 0 then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(Config.Database.SaveInterval * 1000)
            SaveAllVehicleWearData()
        end
    end)
end

function SaveAllVehicleWearData()
    -- This function would be called periodically to save all vehicle wear data
    -- You'd need to implement a way to collect all current vehicle wear data
    -- For example, you could have clients periodically send their local wear data to the server
    -- Then, you'd save that data here
    print("Saving all vehicle wear data...")
    -- Implementation depends on how you're storing wear data server-side
end

-- Command to check server status
RegisterCommand('vehiclewearstatus', function(source, args, rawCommand)
    local src = source
    if source == 0 then -- Console
        PrintServerStatus()
    else
        local Player = GetPlayer(src)
        if Player and IsPlayerAdmin(Player) then
            TriggerClientEvent('chat:addMessage', src, {
                color = {255, 0, 0},
                multiline = true,
                args = {"Server", GetServerStatusString()}
            })
        else
            Notify(src, 'You do not have permission to use this command.', 'error')
        end
    end
end, false)

function PrintServerStatus()
    print(GetServerStatusString())
end

function GetServerStatusString()
    local status = "Vehicle Wear System Status:\n"
    status = status .. string.format("Framework: %s\n", Config.Framework)
    status = status .. string.format("Wear Enabled: %s\n", Config.WearAndTear.EnabledByDefault and "Yes" or "No")
    status = status .. string.format("Max Wear: %.2f\n", Config.WearAndTear.MaxWear)
    status = status .. string.format("Database Save Interval: %d seconds\n", Config.Database.SaveInterval)
    -- Add more status information as needed
    return status
end

function IsPlayerAdmin(Player)
    if Config.Framework == "qb-core" then
        return QBCore.Functions.HasPermission(Player.PlayerData.source, Config.AdminPermission)
    elseif Config.Framework == "esx" then
        return Player.getGroup() == 'admin' -- Adjust based on your ESX setup
    end
    return false
end

-- Initialize the script
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    print('The script "' .. resourceName .. '" has been started.')
    InitializeDatabase()
    -- Any other initialization can go here
end)
