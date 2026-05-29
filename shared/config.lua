Config = {}

Config.Debug = false
Config.Core = 'qb-core'

-- Command / NPC
Config.EnableCommand = false
Config.Command = ''
Config.UseNPC = true
Config.NPC = {
    model = 's_m_m_highsec_01',
    coords = vector4(-1154.74, -1515.82, 4.38, 95),
    scenario = 'WORLD_HUMAN_SMOKING',
    targetLabel = 'Talk to the contact',
    icon = 'fa-solid fa-user-secret'
}

-- Who can use it?
-- If UseGangWhitelist = false, everyone can use it.
Config.UseGangWhitelist = false
Config.AllowedGangs = {
    cartel = true,
    crips = true,
    ballas = true,
    vagos = true,
    families = true,
}

-- Police job names for dispatch/count
Config.PoliceJobs = {
    police = true,
    sheriff = true,
}

Config.MinPolice = 0
Config.ContractCooldownMinutes = 20
Config.MaxActiveContractMinutes = 20

-- Payments
Config.PaymentItem = 'black_money' -- ox_inventory item. If you want cash, set this to 'cash' and check the AddReward function in server/main.lua.
Config.ReputationEnabled = true
Config.ReputationPerSuccess = 1
Config.FailReputationLoss = 1

-- Dispatch
Config.Dispatch = {
    enabled = true,
    chanceOnStart = 15,
    chanceOnKill = 40,
    message = 'Suspicious armed activity reported in the area',
    useCustomEvent = false,
    customClientEvent = 'island_dispatch:client:hitmanAlert'
}

-- Discord logs
Config.Discord = {
    enabled = false,
    webhook = '',
    colorStart = 16753920,
    colorSuccess = 65280,
    colorFail = 16711680
}

-- Target blip
Config.TargetBlip = {
    sprite = 310,
    color = 1,
    scale = 0.85,
    label = 'Target'
}

-- Contracts. The target spawns at one random coords location.
Config.Contracts = {
    {
        id = 'low_1',
        label = 'Low Risk',
        description = 'Eliminate a low-priority NPC target.',
        difficulty = 'easy',
        reward = { min = 2500, max = 5000 },
        requiredItem = nil,
        targetModel = 'a_m_m_business_01',
        weapon = 'WEAPON_PISTOL',
        health = 160,
        armor = 0,
        coords = {
            vector4(-1158.65, -1521.11, 10.63, 125.0),
            vector4(247.82, -371.13, 44.31, 249.0),
            vector4(-590.01, -874.47, 25.92, 92.0),
        }
    },
    {
        id = 'mid_1',
        label = 'Medium Risk',
        description = 'The target may be armed and in a safer position.',
        difficulty = 'medium',
        reward = { min = 6500, max = 11000 },
        requiredItem = nil,
        targetModel = 'g_m_y_mexgoon_02',
        weapon = 'WEAPON_COMBATPISTOL',
        health = 220,
        armor = 25,
        coords = {
            vector4(1395.83, 1141.74, 114.63, 91.0),
            vector4(974.12, -1821.86, 31.18, 171.0),
            vector4(-1082.04, -1670.31, 4.70, 308.0),
        }
    },
    {
        id = 'high_1',
        label = 'High Risk',
        description = 'A harder target, better payment, and a higher chance of police notification.',
        difficulty = 'hard',
        reward = { min = 14000, max = 23000 },
        requiredItem = 'encrypted_contract',
        targetModel = 's_m_m_security_01',
        weapon = 'WEAPON_SMG',
        health = 260,
        armor = 50,
        coords = {
            vector4(2517.71, -384.18, 93.13, 88.0),
            vector4(-1575.42, -3010.23, 13.94, 60.0),
            vector4(846.19, -2360.18, 30.34, 176.0),
        }
    }
}

Config.Locale = {
    menuTitle = 'Hitman Contracts',
    menuDesc = 'Choose an NPC target. Contracts are not meant to be used against real players.',
    noGang = 'You are not in the required gang.',
    noPolice = 'There are not enough police officers in the city.',
    cooldown = 'You must wait before starting a new contract.',
    alreadyActive = 'You already have an active contract.',
    noItem = 'You are missing the required item: %s',
    started = 'Contract started. The target has been marked on your GPS.',
    success = 'Target eliminated. Payment received: $%s',
    failed = 'Contract failed.',
    expired = 'Contract expired.',
    targetEscaped = 'The target escaped or disappeared.',
    cancelled = 'Contract cancelled.',
}
