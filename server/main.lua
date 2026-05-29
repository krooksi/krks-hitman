local QBCore = exports[Config.Core]:GetCoreObject()

local activeContracts = {}
local cooldowns = {}
local reputation = {}

local function Debug(msg)
    if Config.Debug then print(('[island_hitman/server] %s'):format(msg)) end
end

local function GetIdentifier(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return ('src:%s'):format(src) end
    return Player.PlayerData.citizenid or ('src:%s'):format(src)
end

local function Notify(src, msg, nType)
    TriggerClientEvent('island_hitman:client:notify', src, msg, nType or 'inform')
end

local function DiscordLog(title, description, color)
    if not Config.Discord.enabled or Config.Discord.webhook == '' then return end

    local embed = {
        {
            title = title,
            description = description,
            color = color or 16777215,
            footer = { text = os.date('%Y-%m-%d %H:%M:%S') }
        }
    }

    PerformHttpRequest(Config.Discord.webhook, function() end, 'POST', json.encode({
        username = 'Island Hitman Logs',
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end

local function FindContract(id)
    for _, contract in ipairs(Config.Contracts) do
        if contract.id == id then return contract end
    end
    return nil
end

local function CountPolice()
    local count = 0
    local players = QBCore.Functions.GetQBPlayers()
    for _, Player in pairs(players) do
        local job = Player.PlayerData.job and Player.PlayerData.job.name
        if job and Config.PoliceJobs[job] and Player.PlayerData.job.onduty then
            count += 1
        end
    end
    return count
end

local function HasAccess(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return false, 'Player missing' end

    if not Config.UseGangWhitelist then return true end

    local gang = Player.PlayerData.gang and Player.PlayerData.gang.name
    if gang and Config.AllowedGangs[gang] then
        return true
    end

    return false, Config.Locale.noGang
end

local function HasItem(src, itemName)
    if not itemName then return true end
    local count = exports.ox_inventory:Search(src, 'count', itemName)
    return count and count > 0
end

local function AddReward(src, amount)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return false end

    if Config.PaymentItem == 'cash' then
        Player.Functions.AddMoney('cash', amount, 'hitman-contract')
        return true
    end

    return exports.ox_inventory:AddItem(src, Config.PaymentItem, amount)
end

local function PublicContract(contract)
    return {
        id = contract.id,
        label = contract.label,
        description = contract.description,
        difficulty = contract.difficulty,
        reward = contract.reward,
        requiredItem = contract.requiredItem
    }
end

QBCore.Functions.CreateCallback('island_hitman:server:getContracts', function(source, cb)
    local src = source
    local ok, reason = HasAccess(src)
    if not ok then cb({ error = reason }) return end

    if CountPolice() < Config.MinPolice then
        cb({ error = Config.Locale.noPolice })
        return
    end

    local list = {}
    for _, contract in ipairs(Config.Contracts) do
        list[#list + 1] = PublicContract(contract)
    end

    cb({ contracts = list })
end)

RegisterNetEvent('island_hitman:server:startContract', function(contractId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local identifier = GetIdentifier(src)
    local now = os.time()

    local ok, reason = HasAccess(src)
    if not ok then Notify(src, reason, 'error') return end

    if CountPolice() < Config.MinPolice then
        Notify(src, Config.Locale.noPolice, 'error')
        return
    end

    if activeContracts[identifier] then
        Notify(src, Config.Locale.alreadyActive, 'error')
        return
    end

    if cooldowns[identifier] and cooldowns[identifier] > now then
        local left = math.ceil((cooldowns[identifier] - now) / 60)
        Notify(src, Config.Locale.cooldown .. (' (%s min)'):format(left), 'error')
        return
    end

    local contract = FindContract(contractId)
    if not contract then return end

    if not HasItem(src, contract.requiredItem) then
        Notify(src, Config.Locale.noItem:format(contract.requiredItem), 'error')
        return
    end

    if contract.requiredItem then
        exports.ox_inventory:RemoveItem(src, contract.requiredItem, 1)
    end

    local spawn = contract.coords[math.random(1, #contract.coords)]
    local reward = math.random(contract.reward.min, contract.reward.max)

    activeContracts[identifier] = {
        src = src,
        contractId = contract.id,
        reward = reward,
        started = now,
        expires = now + (Config.MaxActiveContractMinutes * 60),
    }

    cooldowns[identifier] = now + (Config.ContractCooldownMinutes * 60)

    DiscordLog('Contract started', ('%s / %s started %s'):format(GetPlayerName(src), identifier, contract.label), Config.Discord.colorStart)

    TriggerClientEvent('island_hitman:client:startContract', src, {
        id = contract.id,
        label = contract.label,
        difficulty = contract.difficulty,
        reward = contract.reward,
        targetModel = contract.targetModel,
        weapon = contract.weapon,
        health = contract.health,
        armor = contract.armor,
        spawn = spawn
    })
end)

RegisterNetEvent('island_hitman:server:completeContract', function(contractId, netId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local identifier = GetIdentifier(src)
    local active = activeContracts[identifier]

    if not active or active.contractId ~= contractId then
        Notify(src, 'Sul pole seda contracti aktiivne.', 'error')
        return
    end

    if os.time() > active.expires then
        activeContracts[identifier] = nil
        Notify(src, Config.Locale.expired, 'error')
        return
    end

    local paid = AddReward(src, active.reward)
    if not paid then
        Notify(src, 'Tasu andmine ebaõnnestus. Kontrolli payment itemit.', 'error')
        return
    end

    activeContracts[identifier] = nil

    if Config.ReputationEnabled then
        reputation[identifier] = (reputation[identifier] or 0) + Config.ReputationPerSuccess
    end

    Notify(src, Config.Locale.success:format(active.reward), 'success')
    DiscordLog('Contract completed', ('%s / %s completed %s and got $%s'):format(GetPlayerName(src), identifier, contractId, active.reward), Config.Discord.colorSuccess)
end)

RegisterNetEvent('island_hitman:server:failContract', function(contractId, reason)
    local src = source
    local identifier = GetIdentifier(src)
    local active = activeContracts[identifier]

    if not active or active.contractId ~= contractId then return end

    activeContracts[identifier] = nil

    if Config.ReputationEnabled then
        reputation[identifier] = math.max(0, (reputation[identifier] or 0) - Config.FailReputationLoss)
    end

    Notify(src, Config.Locale.failed, 'error')
    DiscordLog('Contract failed', ('%s / %s failed %s. Reason: %s'):format(GetPlayerName(src), identifier, contractId, reason or 'unknown'), Config.Discord.colorFail)
end)

RegisterNetEvent('island_hitman:server:policeAlert', function(data)
    local src = source
    local players = QBCore.Functions.GetQBPlayers()

    for _, Player in pairs(players) do
        local job = Player.PlayerData.job and Player.PlayerData.job.name
        if job and Config.PoliceJobs[job] and Player.PlayerData.job.onduty then
            TriggerClientEvent('ox_lib:notify', Player.PlayerData.source, {
                title = 'Dispatch',
                description = ('%s\nAsukoht: %s'):format(Config.Dispatch.message, data.street or 'Tundmatu'),
                type = 'warning'
            })
        end
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    local identifier = GetIdentifier(src)
    if activeContracts[identifier] then
        DiscordLog('Contract cancelled', ('%s dropped while contract was active.'):format(identifier), Config.Discord.colorFail)
        activeContracts[identifier] = nil
    end
end)

CreateThread(function()
    while true do
        Wait(60000)
        local now = os.time()
        for identifier, data in pairs(activeContracts) do
            if data.expires < now then
                activeContracts[identifier] = nil
            end
        end
    end
end)
