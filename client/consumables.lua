-- Variables
local alcoholCount, healing, smokingWeed, relieveCount = 0, false, false, 0

-- Functions

local function healOxy()
    if not healing then
        healing = true
    else
        return
    end

    local count = 9
    while count > 0 do
        Wait(1000)
        count -= 1
        SetEntityHealth(cache.ped, GetEntityHealth(cache.ped) + 6)
    end
    healing = false
end

local function trevorEffect()
    AnimpostfxPlay('DrugsTrevorClownsFightIn', 3.0, 0)
    Wait(3000)
    AnimpostfxPlay('DrugsTrevorClownsFight', 3.0, 0)
    Wait(3000)
	AnimpostfxPlay('DrugsTrevorClownsFightOut', 3.0, 0)
	AnimpostfxStop('DrugsTrevorClownsFight')
	AnimpostfxStop('DrugsTrevorClownsFightIn')
	AnimpostfxStop('DrugsTrevorClownsFightOut')
end

local function methBagEffect()
    local startStamina = 8
    trevorEffect()
    SetRunSprintMultiplierForPlayer(cache.playerId, 1.49)
    while startStamina > 0 do
        Wait(1000)
        if math.random(5, 100) < 10 then
            RestorePlayerStamina(cache.playerId, 1.0)
        end
        startStamina = startStamina - 1
        if math.random(5, 100) < 51 then
            trevorEffect()
        end
    end
    SetRunSprintMultiplierForPlayer(cache.playerId, 1.0)
end

local function ecstasyEffect()
    local startStamina = 30
    SetFlash(0, 0, 500, 7000, 500)
    while startStamina > 0 do
        Wait(1000)
        startStamina -= 1
        RestorePlayerStamina(cache.playerId, 1.0)
        if math.random(1, 100) < 51 then
            SetFlash(0, 0, 500, 7000, 500)
            ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.08)
        end
    end
    if IsPedRunning(cache.ped) then
        SetPedToRagdoll(cache.ped, math.random(1000, 3000), math.random(1000, 3000), 3, false, false, false)
    end
end

local function alienEffect()
    AnimpostfxPlay('DrugsMichaelAliensFightIn', 3.0, 0)
    Wait(math.random(5000, 8000))
    AnimpostfxPlay('DrugsMichaelAliensFight', 3.0, 0)
    Wait(math.random(5000, 8000))
    AnimpostfxPlay('DrugsMichaelAliensFightOut', 3.0, 0)
    AnimpostfxStop('DrugsMichaelAliensFightIn')
    AnimpostfxStop('DrugsMichaelAliensFight')
    AnimpostfxStop('DrugsMichaelAliensFightOut')
end

local function crackBaggyEffect()
    local startStamina = 8
    alienEffect()
    SetRunSprintMultiplierForPlayer(cache.playerId, 1.3)
    while startStamina > 0 do
        Wait(1000)
        if math.random(1, 100) < 10 then
            RestorePlayerStamina(cache.playerId, 1.0)
        end
        startStamina -= 1
        if math.random(1, 100) < 60 and IsPedRunning(cache.ped) then
            SetPedToRagdoll(cache.ped, math.random(1000, 2000), math.random(1000, 2000), 3, false, false, false)
        end
        if math.random(1, 100) < 51 then
            alienEffect()
        end
    end
    if IsPedRunning(cache.ped) then
        SetPedToRagdoll(cache.ped, math.random(1000, 3000), math.random(1000, 3000), 3, false, false, false)
    end
    SetRunSprintMultiplierForPlayer(cache.playerId, 1.0)
end

local function cokeBaggyEffect()
    local startStamina = 20
    alienEffect()
    SetRunSprintMultiplierForPlayer(cache.playerId, 1.1)
    while startStamina > 0 do
        Wait(1000)
        if math.random(1, 100) < 20 then
            RestorePlayerStamina(cache.playerId, 1.0)
        end
        startStamina -= 1
        if math.random(1, 100) < 10 and IsPedRunning(cache.ped) then
            SetPedToRagdoll(cache.ped, math.random(1000, 3000), math.random(1000, 3000), 3, false, false, false)
        end
        if math.random(1, 300) < 10 then
            alienEffect()
            Wait(math.random(3000, 6000))
        end
    end
    if IsPedRunning(cache.ped) then
        SetPedToRagdoll(cache.ped, math.random(1000, 3000), math.random(1000, 3000), 3, false, false, false)
    end
    SetRunSprintMultiplierForPlayer(cache.playerId, 1.0)
end

local function smokeWeed()
    CreateThread(function()
        while smokingWeed do
            Wait(10000)
            TriggerServerEvent('hud:server:RelieveStress', math.random(15, 18))
            relieveCount += 1
            if relieveCount == 6 then
                exports.scully_emotemenu:cancelEmote()
                if smokingWeed then
                    smokingWeed = false
                    relieveCount = 0
                end
            end
        end
    end)
end

-- Events

RegisterNetEvent('consumables:client:Eat', function(itemName)
    exports.scully_emotemenu:playEmoteByCommand('eat')
    if lib.progressBar({
        duration = 5000,
        label = 'Eating...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = false,
            car = false,
            mouse = false,
            combat = true
        }
    }) then -- if completed
        TriggerEvent('inventory:client:ItemBox', exports.ox_inventory:Items()[itemName], 'remove')
        exports.scully_emotemenu:cancelEmote()
        TriggerServerEvent('consumables:server:addHunger', QBX.PlayerData.metadata.hunger + ConsumablesEat[itemName])
        TriggerServerEvent('hud:server:RelieveStress', math.random(2, 4))
    end
end)

RegisterNetEvent('consumables:client:Drink', function(itemName)
    exports.scully_emotemenu:playEmoteByCommand('drink')
    if lib.progressBar({
        duration = 5000,
        label = 'Drinking...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = false,
            car = false,
            mouse = false,
            combat = true
        }
    }) then -- if completed
        TriggerEvent('inventory:client:ItemBox', exports.ox_inventory:Items()[itemName], 'remove')
        exports.scully_emotemenu:cancelEmote()
        TriggerServerEvent('consumables:server:addThirst', QBX.PlayerData.metadata.thirst + ConsumablesDrink[itemName])
    end
end)

RegisterNetEvent('consumables:client:DrinkAlcohol', function(itemName)
    exports.scully_emotemenu:playEmoteByCommand('beer7')
    if lib.progressBar({
        duration = math.random(3000, 6000),
        label = 'Drinking liquor...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = false,
            car = false,
            mouse = false,
            combat = true
        }
    }) then -- if completed
        exports.scully_emotemenu:cancelEmote()
        TriggerEvent('inventory:client:ItemBox', exports.ox_inventory:Items()[itemName], 'remove')
        TriggerServerEvent('consumables:server:drinkAlcohol', itemName)
        TriggerServerEvent('consumables:server:addThirst', QBX.PlayerData.metadata.thirst + ConsumablesAlcohol[itemName])
        TriggerServerEvent('hud:server:RelieveStress', math.random(2, 4))
        alcoholCount += 1
        if alcoholCount > 1 and alcoholCount < 4 then
            TriggerEvent('evidence:client:SetStatus', 'alcohol', 200)
        elseif alcoholCount >= 4 then
            TriggerEvent('evidence:client:SetStatus', 'heavyalcohol', 200)
        end
    else -- if canceled
        exports.scully_emotemenu:cancelEmote()
        exports.qbx_core:Notify('Canceled...', 'error')
    end
end)

RegisterNetEvent('consumables:client:Cokebaggy', function()
    if lib.progressBar({
        duration = math.random(5000, 8000),
        label = 'Quick sniff...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = false,
            car = false,
            mouse = false,
            combat = true
        },
        anim = {
            dict = 'switch@trevor@trev_smoking_meth',
            clip = 'trev_smoking_meth_loop',
            flag = 49
        }
    }) then -- if completed
        TriggerServerEvent('consumables:server:useCokeBaggy')
        TriggerEvent('inventory:client:ItemBox', exports.ox_inventory:Items()['cokebaggy'], 'remove')
        TriggerEvent('evidence:client:SetStatus', 'widepupils', 200)
        cokeBaggyEffect()
    else -- if canceled
        exports.qbx_core:Notify('Canceled...', 'error')
    end
end)

RegisterNetEvent('consumables:client:Crackbaggy', function()
    if lib.progressBar({
        duration = math.random(7000, 10000),
        label = 'Smoking crack...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = false,
            car = false,
            mouse = false,
            combat = true
        },
        anim = {
            dict = 'switch@trevor@trev_smoking_meth',
            clip = 'trev_smoking_meth_loop',
            flag = 49
        }
    }) then -- if completed
        TriggerServerEvent('consumables:server:useCrackBaggy')
        TriggerEvent('inventory:client:ItemBox', exports.ox_inventory:Items()['crack_baggy'], 'remove')
        TriggerEvent('evidence:client:SetStatus', 'widepupils', 300)
        crackBaggyEffect()
    else -- if canceled
        exports.qbx_core:Notify('Canceled...', 'error')
    end
end)

RegisterNetEvent('consumables:client:EcstasyBaggy', function()
    if lib.progressBar({
        duration = 3000,
        label = 'Popping pills...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = false,
            car = false,
            mouse = false,
            combat = true
        },
        anim = {
            dict = 'mp_suicide',
            clip = 'pill',
            flag = 49
        }
    }) then -- if completed
        TriggerServerEvent('consumables:server:useXTCBaggy')
        TriggerEvent('inventory:client:ItemBox', exports.ox_inventory:Items().xtcbaggy, 'remove')
        ecstasyEffect()
    else -- if canceled
        exports.qbx_core:Notify('Canceled...', 'error')
    end
end)

RegisterNetEvent('consumables:client:oxy', function()
    if lib.progressBar({
        duration = 2000,
        label = 'Healing...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = false,
            car = false,
            mouse = false,
            combat = true
        },
        anim = {
            dict = 'mp_suicide',
            clip = 'pill',
            flag = 49
        }
    }) then -- if completed
        TriggerServerEvent('consumables:server:useOxy')
        TriggerEvent('inventory:client:ItemBox', exports.ox_inventory:Items()['oxy'], 'remove')
        ClearPedBloodDamage(cache.ped)
		healOxy()
    else -- if canceled
        exports.qbx_core:Notify('Canceled', 'error')
    end
end)

RegisterNetEvent('consumables:client:meth', function()
    if lib.progressBar({
        duration = 1500,
        label = 'Smoking meth...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = false,
            car = false,
            mouse = false,
            combat = true
        },
        anim = {
            dict = 'switch@trevor@trev_smoking_meth',
            clip = 'trev_smoking_meth_loop',
            flag = 49
        }
    }) then -- if completed
        TriggerServerEvent('consumables:server:useMeth')
        TriggerEvent('inventory:client:ItemBox', exports.ox_inventory:Items()['meth'], 'remove')
        TriggerEvent('evidence:client:SetStatus', 'widepupils', 300)
		TriggerEvent('evidence:client:SetStatus', 'agitated', 300)
        methBagEffect()
    else -- if canceled
        exports.qbx_core:Notify('Canceled...', 'error')
	end
end)

RegisterNetEvent('consumables:client:UseJoint', function()
    if lib.progressBar({
        duration = 1500,
        label = 'Lighting joint...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = false,
            car = false,
            mouse = false,
            combat = true
        }
    }) then -- if completed
        TriggerEvent('inventory:client:ItemBox', exports.ox_inventory:Items()['joint'], 'remove')
        exports.scully_emotemenu:playEmoteByCommand('joint')
        TriggerEvent('evidence:client:SetStatus', 'weedsmell', 300)
        smokeWeed()
    end
end)

--Threads

CreateThread(function()
    while true do
        Wait(10)
        if alcoholCount > 0 then
            Wait(1000 * 60 * 15)
            alcoholCount -= 1
        else
            Wait(2000)
        end
    end
end)