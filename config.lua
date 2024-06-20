Config = {}

Config.Framework = 'QBCore'        -- 'QBCore' or 'ESX'

Config.WearAndTear = {
    EnabledByDefault = true,
    WearRate         = 0.0005,     -- Rate of wear per tick (10 seconds)
    MaxWear          = 100.0,      -- Maximum wear level
    RepairCost       = 10,         -- Cost per wear point to repair
    DirtMultiplier   = 15.0,       -- How much dirt increases with wear
    PerformanceImpact = 0.2,       -- Max percentage reduction in top speed due to wear
}

Config.Maintenance = {
    MechanicJob     = 'mechanic', -- Job that can repair vehicles (adjust for your server)
    RepairLocations = {           -- Example repair locations (replace with your own)
        {x = -211.87, y = -1324.77, z = 30.89},  -- Benny's
        {x = 482.09, y = -1314.08, z = 29.21}   -- Los Santos Customs
    },
    RepairDistance  = 10.0,       -- Distance player must be to repair
}

Config.Notifications = {
    Enabled     = true,
    Position    = 'top',   -- 'top', 'bottom', 'left', 'right'
}

Config.Commands = {
    Repair   = 'repairvehicle',
}
