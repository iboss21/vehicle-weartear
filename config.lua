Config = {}
Config.Framework = 'QBCore' -- Set to 'ESX' if using ESX framework
Config.Commands = {
    Repair = 'repairvehicle'
}
Config.WearAndTear = {
    EnabledByDefault = true,
    WearRate = 0.005,    -- Adjust the wear rate (per 10 seconds)
    MaxWear = 1.0,       -- Maximum wear level before severe performance impact
    DirtMultiplier = 10.0,  -- Adjust how dirt scales with wear
    PerformanceImpact = 0.5, -- How much wear affects vehicle performance
    RepairCost = 100.0   -- Cost per wear unit to repair
}
Config.Maintenance = {
    MechanicJob = 'mechanic',  
    RepairLocations = {
        {x = -354.48, y = -135.17, z = 38.98} -- Add more repair locations as needed
    },
    RepairDistance = 10.0     -- Maximum distance from repair point for repair command
}

