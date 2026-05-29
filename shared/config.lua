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
    targetLabel = 'Räägi kontaktiga',
    icon = 'fa-solid fa-user-secret'
}

-- Kes saavad kasutada?
-- Kui UseGangWhitelist = false, saavad kõik kasutada.
Config.UseGangWhitelist = false
Config.AllowedGangs = {
    cartel = true,
    crips = true,
    ballas = true,
    vagos = true,
    families = true,
}

-- Politsei tööde nimed dispatch/count jaoks
Config.PoliceJobs = {
    police = true,
    sheriff = true,
}

Config.MinPolice = 0
Config.ContractCooldownMinutes = 20
Config.MaxActiveContractMinutes = 20

-- Tasud
Config.PaymentItem = 'black_money' -- ox_inventory item. Kui tahad cashi, pane 'cash' ja vaata server/main.lua AddReward funktsiooni.
Config.ReputationEnabled = true
Config.ReputationPerSuccess = 1
Config.FailReputationLoss = 1

-- Dispatch
Config.Dispatch = {
    enabled = true,
    chanceOnStart = 15,
    chanceOnKill = 40,
    message = 'Kahtlane relvastatud tegevus piirkonnas',
    useCustomEvent = false,
    customClientEvent = 'island_dispatch:client:hitmanAlert'
}

-- Discord logid
Config.Discord = {
    enabled = false,
    webhook = '',
    colorStart = 16753920,
    colorSuccess = 65280,
    colorFail = 16711680
}

-- Blip sihtmärgile
Config.TargetBlip = {
    sprite = 310,
    color = 1,
    scale = 0.85,
    label = 'Sihtmärk'
}

-- Contractid. Target spawnib ühe random coords valiku peal.
Config.Contracts = {
    {
        id = 'low_1',
        label = 'Madal risk',
        description = 'Likvideeri madala tähtsusega NPC sihtmärk.',
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
        label = 'Keskmine risk',
        description = 'Sihtmärgil võib olla relv ja turvalisem positsioon.',
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
        label = 'Kõrge risk',
        description = 'Raskem sihtmärk, parem tasu ja suurem politsei teavituse chance.',
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
    menuDesc = 'Vali NPC sihtmärk. Contractid ei ole mõeldud päris mängijate vastu.',
    noGang = 'Sul puudub õige gang.',
    noPolice = 'Linnas pole piisavalt politseid.',
    cooldown = 'Sa pead enne uut contracti ootama.',
    alreadyActive = 'Sul on juba aktiivne contract.',
    noItem = 'Sul puudub vajalik item: %s',
    started = 'Contract alustatud. Sihtmärk on märgitud GPS-is.',
    success = 'Sihtmärk kõrvaldatud. Tasu saadud: $%s',
    failed = 'Contract ebaõnnestus.',
    expired = 'Contract aegus.',
    targetEscaped = 'Sihtmärk põgenes või kadus.',
    cancelled = 'Contract tühistatud.',
}
