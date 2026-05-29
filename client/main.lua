local QBCore = exports[Config.Core]:GetCoreObject()

local contactPed = nil
local active = false
local activeTarget = nil
local activeBlip = nil
local activeNetId = nil
local expireAt = 0

local function Debug(msg)
    if Config.Debug then print(('[island_hitman/client] %s'):format(msg)) end
end

local function Notify(msg, nType)
    lib.notify({
        title = 'Hitman',
        description = msg,
        type = nType or 'inform'
    })
end

local function LoadModel(model)
    local hash = type(model) == 'string' and joaat(model) or model
    if not IsModelInCdimage(hash) then return false end
    RequestModel(hash)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(hash) do
        Wait(10)
        if GetGameTimer() > timeout then return false end
    end
    return hash
end

local function DeleteActive()
    if activeBlip and DoesBlipExist(activeBlip) then
        RemoveBlip(activeBlip)
    end
    activeBlip = nil

    if activeTarget and DoesEntityExist(activeTarget) then
        exports.ox_target:removeLocalEntity(activeTarget)
        DeleteEntity(activeTarget)
    end

    active = false
    activeTarget = nil
    activeNetId = nil
    expireAt = 0
end

local function PoliceDispatch(coords, phase)
    if not Config.Dispatch.enabled then return end

    if Config.Dispatch.useCustomEvent then
        TriggerEvent(Config.Dispatch.customClientEvent, coords, phase)
        return
    end

    local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local streetName = GetStreetNameFromHashKey(streetHash)

    TriggerServerEvent('island_hitman:server:policeAlert', {
        coords = coords,
        street = streetName,
        phase = phase
    })
end

local function SpawnTarget(contract)
    local coords = contract.spawn
    local hash = LoadModel(contract.targetModel)
    if not hash then
        Notify('Target modeli laadimine ebaõnnestus.', 'error')
        TriggerServerEvent('island_hitman:server:failContract', contract.id, 'bad_model')
        return
    end

    local ped = CreatePed(4, hash, coords.x, coords.y, coords.z - 1.0, coords.w, true, true)
    SetModelAsNoLongerNeeded(hash)

    if not DoesEntityExist(ped) then
        Notify('Sihtmärki ei saanud spawnida.', 'error')
        TriggerServerEvent('island_hitman:server:failContract', contract.id, 'spawn_failed')
        return
    end

    active = true
    activeTarget = ped
    activeNetId = NetworkGetNetworkIdFromEntity(ped)
    expireAt = GetGameTimer() + (Config.MaxActiveContractMinutes * 60 * 1000)

    SetNetworkIdCanMigrate(activeNetId, true)
    SetEntityAsMissionEntity(ped, true, true)
    SetPedRelationshipGroupHash(ped, joaat('HATES_PLAYER'))
    SetPedCombatAbility(ped, 2)
    SetPedCombatMovement(ped, 2)
    SetPedCombatRange(ped, 2)
    SetPedAlertness(ped, 3)
    SetPedAccuracy(ped, contract.difficulty == 'hard' and 55 or contract.difficulty == 'medium' and 38 or 24)
    SetEntityHealth(ped, contract.health or 200)
    SetPedArmour(ped, contract.armor or 0)
    GiveWeaponToPed(ped, joaat(contract.weapon or 'WEAPON_PISTOL'), 90, false, true)
    TaskWanderStandard(ped, 10.0, 10)

    activeBlip = AddBlipForEntity(ped)
    SetBlipSprite(activeBlip, Config.TargetBlip.sprite)
    SetBlipColour(activeBlip, Config.TargetBlip.color)
    SetBlipScale(activeBlip, Config.TargetBlip.scale)
    SetBlipAsShortRange(activeBlip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Config.TargetBlip.label)
    EndTextCommandSetBlipName(activeBlip)

    exports.ox_target:addLocalEntity(ped, {
        {
            label = 'Kontrolli sihtmärki',
            icon = 'fa-solid fa-crosshairs',
            distance = 2.0,
            canInteract = function(entity)
                return active and entity == activeTarget and IsEntityDead(entity)
            end,
            onSelect = function()
                if not active or not activeTarget or not IsEntityDead(activeTarget) then return end
                TriggerServerEvent('island_hitman:server:completeContract', contract.id, activeNetId)
                DeleteActive()
            end
        }
    })

    Notify(Config.Locale.started, 'success')

    CreateThread(function()
        while active and activeTarget == ped do
            Wait(1000)

            if not DoesEntityExist(ped) then
                TriggerServerEvent('island_hitman:server:failContract', contract.id, 'target_missing')
                Notify(Config.Locale.targetEscaped, 'error')
                DeleteActive()
                break
            end

            if GetGameTimer() > expireAt then
                TriggerServerEvent('island_hitman:server:failContract', contract.id, 'expired')
                Notify(Config.Locale.expired, 'error')
                DeleteActive()
                break
            end

            if IsEntityDead(ped) then
                local c = GetEntityCoords(ped)
                if math.random(1, 100) <= Config.Dispatch.chanceOnKill then
                    PoliceDispatch(c, 'kill')
                end
            end
        end
    end)
end

local function OpenMenu()
    QBCore.Functions.TriggerCallback('island_hitman:server:getContracts', function(data)
        if not data or data.error then
            Notify(data and data.error or 'Serveri viga.', 'error')
            return
        end

        local options = {}
        for _, contract in ipairs(data.contracts) do
            local disabled = false
            local desc = contract.description .. ('\nTasu: $%s - $%s'):format(contract.reward.min, contract.reward.max)
            if contract.requiredItem then
                desc = desc .. ('\nVajalik: %s'):format(contract.requiredItem)
            end

            options[#options + 1] = {
                title = contract.label,
                description = desc,
                icon = 'user-secret',
                disabled = disabled,
                onSelect = function()
                    TriggerServerEvent('island_hitman:server:startContract', contract.id)
                end
            }
        end

        if #options == 0 then
            options[#options + 1] = {
                title = 'Contracte pole saadaval',
                description = 'Proovi hiljem uuesti.',
                disabled = true
            }
        end

        lib.registerContext({
            id = 'island_hitman_menu',
            title = Config.Locale.menuTitle,
            menu = nil,
            options = options
        })
        lib.showContext('island_hitman_menu')
    end)
end

RegisterNetEvent('island_hitman:client:startContract', function(contract)
    if active then
        Notify(Config.Locale.alreadyActive, 'error')
        return
    end

    if math.random(1, 100) <= Config.Dispatch.chanceOnStart then
        PoliceDispatch(vector3(contract.spawn.x, contract.spawn.y, contract.spawn.z), 'start')
    end

    SpawnTarget(contract)
end)

RegisterNetEvent('island_hitman:client:notify', function(msg, nType)
    Notify(msg, nType)
end)

if Config.EnableCommand then
    RegisterCommand(Config.Command, function()
        OpenHitmanMenu()
    end)
end
--RegisterCommand(Config.Command, function()
    --OpenMenu()
--end, false)

CreateThread(function()
    if not Config.UseNPC then return end

    local hash = LoadModel(Config.NPC.model)
    if not hash then return end

    contactPed = CreatePed(4, hash, Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z - 1.0, Config.NPC.coords.w, false, true)
    SetEntityAsMissionEntity(contactPed, true, true)
    SetBlockingOfNonTemporaryEvents(contactPed, true)
    SetEntityInvincible(contactPed, true)
    FreezeEntityPosition(contactPed, true)

    if Config.NPC.scenario then
        TaskStartScenarioInPlace(contactPed, Config.NPC.scenario, 0, true)
    end

    exports.ox_target:addLocalEntity(contactPed, {
        {
            label = Config.NPC.targetLabel,
            icon = Config.NPC.icon,
            distance = 2.0,
            onSelect = function()
                OpenMenu()
            end
        }
    })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    DeleteActive()
    if contactPed and DoesEntityExist(contactPed) then
        exports.ox_target:removeLocalEntity(contactPed)
        DeleteEntity(contactPed)
    end
end)
