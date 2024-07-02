Config = {}

-- Framework Settings
Config.Framework = 'qb-core' -- 'qb-core' or 'esx'
Config.UseOxInventory = true

-- General Settings
Config.Debug = false
Config.UseMetric = true -- false for imperial

-- Wear and Tear
Config.WearAndTear = {
    EnabledByDefault = true,
    MaxWear = 100.0,
    WearRate = {
        Default = 0.01,
        OffRoad = 0.02,
        Racing = 0.03,
        Boat = 0.015,
        Aircraft = 0.005
    },
    PerformanceImpact = {
        Speed = 0.3,
        Acceleration = 0.25,
        Braking = 0.2,
        Handling = 0.15
    },
    VisualImpact = {
        DirtMultiplier = 10.0,
        ScratchThreshold = 50.0,
        DentThreshold = 75.0
    },
    EnvironmentalFactors = {
        RainWearMultiplier = 1.2,
        SnowWearMultiplier = 1.5,
        DesertWearMultiplier = 1.3,
        NightWearMultiplier = 1.1
    },
    ComponentWear = {
        Engine = 1.0,
        Transmission = 0.8,
        Brakes = 1.2,
        Suspension = 0.9,
        Body = 0.5
    }
}

-- Maintenance
Config.Maintenance = {
    RepairLocations = {
        {x = 731.74, y = -1088.95, z = 22.17, name = "LS Customs"},
        {x = -338.17, y = -136.54, z = 39.01, name = "Downtown LS Customs"},
        -- Add more locations as needed
    },
    RepairDistance = 10.0,
    MechanicJob = 'mechanic',
    RepairCost = {
        BasePrice = 500,
        PerWearPoint = 10,
        LuxuryVehicleMultiplier = 1.5
    },
    RepairTime = {
        BaseTime = 30, -- seconds
        PerWearPoint = 1, -- additional seconds per wear point
        MaxTime = 300 -- maximum repair time in seconds
    },
    RequiredTools = {
        'wrench',
        'screwdriver',
        'welding_torch'
    }
}

-- Vehicle Classes
Config.VehicleClasses = {
    [0] = {name = "Compacts", wearMultiplier = 1.0},
    [1] = {name = "Sedans", wearMultiplier = 1.1},
    [2] = {name = "SUVs", wearMultiplier = 1.2},
    [3] = {name = "Coupes", wearMultiplier = 1.0},
    [4] = {name = "Muscle", wearMultiplier = 1.3},
    [5] = {name = "Sports Classics", wearMultiplier = 1.1},
    [6] = {name = "Sports", wearMultiplier = 1.4},
    [7] = {name = "Super", wearMultiplier = 1.5},
    [8] = {name = "Motorcycles", wearMultiplier = 0.8},
    [9] = {name = "Off-road", wearMultiplier = 1.6},
    [10] = {name = "Industrial", wearMultiplier = 1.7},
    [11] = {name = "Utility", wearMultiplier = 1.5},
    [12] = {name = "Vans", wearMultiplier = 1.4},
    [13] = {name = "Cycles", wearMultiplier = 0.5},
    [14] = {name = "Boats", wearMultiplier = 1.2},
    [15] = {name = "Helicopters", wearMultiplier = 1.3},
    [16] = {name = "Planes", wearMultiplier = 1.4},
    [17] = {name = "Service", wearMultiplier = 1.2},
    [18] = {name = "Emergency", wearMultiplier = 1.1},
    [19] = {name = "Military", wearMultiplier = 1.3},
    [20] = {name = "Commercial", wearMultiplier = 1.6},
    [21] = {name = "Trains", wearMultiplier = 0.0}
}

-- Commands
Config.Commands = {
    CheckWear = 'checkvehiclewear',
    Repair = 'repairmyvehicle',
    AssignJob = 'assignrepairjob'
}

-- Notifications
Config.Notifications = {
    UseCustomNotifications = false, -- Set to true if using a custom notification system
    Position = 'top-right',
    Duration = 5000
}

-- Mechanic Tools Shop
Config.MechanicTools = {
    wrench = {price = 150, label = "Wrench"},
    screwdriver = {price = 50, label = "Screwdriver"},
    welding_torch = {price = 500, label = "Welding Torch"},
    diagnostic_tool = {price = 1000, label = "Diagnostic Tool"},
    jack = {price = 300, label = "Hydraulic Jack"},
    spray_paint = {price = 100, label = "Spray Paint"}
}

-- Part Replacement
Config.PartReplacement = {
    EnablePartSystem = true,
    Parts = {
        engine = {price = 5000, repairAmount = 50, installTime = 300},
        transmission = {price = 3000, repairAmount = 40, installTime = 240},
        brakes = {price = 1000, repairAmount = 30, installTime = 180},
        suspension = {price = 2000, repairAmount = 35, installTime = 210},
        tires = {price = 800, repairAmount = 25, installTime = 120}
    }
}

-- Mechanic Job
Config.MechanicJob = {
    EnableJobSystem = true,
    JobCooldown = 600, -- seconds
    MaxActiveJobs = 3,
    RewardMultiplier = 1.2 -- Multiplier for job rewards
}

-- Database
Config.Database = {
    SaveInterval = 300, -- seconds
    TableName = 'vehicle_wear'
}

-- UI Settings
Config.UI = {
    EnableCustomUI = false,
    ShowWearBar = true,
    WearBarPosition = {x = 0.9, y = 0.1},
    UseNativeUI = true
}

-- Weather Impact
Config.WeatherImpact = {
    Enable = true,
    RainWearIncrease = 0.2,
    SnowWearIncrease = 0.3,
    SandstormWearIncrease = 0.4
}

-- Time-based Wear
Config.TimeBasedWear = {
    Enable = true,
    NightWearMultiplier = 1.2, -- Increased wear at night
    RushHourWearMultiplier = 1.5 -- Increased wear during rush hours
}

-- Advanced Features
Config.AdvancedFeatures = {
    EnableEngineStalling = true,
    EnableTirePunctures = true,
    EnableOverheating = true,
    EnableFuelConsumption = true
}

-- Logging
Config.Logging = {
    EnableConsoleLogging = true,
    EnableFileLogging = false,
    EnableWebhookLogging = false,
    WebhookURL = ""
}

-- Performance
Config.Performance = {
    UpdateInterval = 1000, -- milliseconds
    SyncInterval = 5000, -- milliseconds
    MaxEntities = 100 -- maximum number of entities to process at once
}
