if GetResourceState('ox_core') ~= 'started' then return end
local Ox = require '@ox_core.lib.init'

if Config.Debug then print('Using OX Core bridge') end

if not lib then
    print('^1You are using OX core, but Ox lib is not defined^0')
    print('Please add "@ox_lib/init.lua" to your shared_scripts in fxmanifest')
end

-- Get vehicle data from ox_core
local VEHICLEHASHES = Ox.GetVehicleData()

-- Listen for player loaded event
RegisterNetEvent('ox:playerLoaded', function()
    defineItems()
end)

function getPlayerJobName()
    local player = Ox.GetPlayer()
    if player and player.job then
        return player.job.name
    end
end

function getPlayerJobType()
    local player = Ox.GetPlayer()
    if player and player.job then
        return player.job.type
    end
end

function getPlayerJobLevel()
    local player = Ox.GetPlayer()
    if player and player.job and player.job.grade then
        return player.job.grade
    end
end

function hasGps()
    if exports.ox_inventory:Search('count', Config.ItemName.gps) >= 1 then
        return true
    end
    return false
end

function getCitizenId()
    local player = Ox.GetPlayer()
    return player.stateId
end

function getVehicleModel(vehicle)
    local model = GetEntityModel(vehicle)
    local vehData = VEHICLEHASHES[model]
    if vehData then
        return vehData.name, vehData.make
    end
    return GetDisplayNameFromVehicleModel(model)
end

function getClosestPlayer()
    local coords = GetEntityCoords(cache.ped)
    local playerId, _, playerCoords = lib.getClosestPlayer(coords, 50, false)
    local closestDistance = playerCoords and #(playerCoords - coords) or nil
    return playerId, closestDistance
end

function notify(text, type)
    -- Remove this block if you dont want in-app notifications
    if UiIsOpen then
        SendNUIMessage({
            type = "notify",
            data = {
                title = text,
                type = type,
            },
        })
        return
    end

    lib.notify({
        title = text,
        type = type,
    })
end

function getCraftingSkill(skill)
    if Config.UseCWRepForCraftingSkill then
        return exports['cw-rep']:getCurrentSkill(skill or Config.CraftingSkillName) or 0
    else
        if Config.Debug then print('^1CW REP is required to use skills with for OX core^0') end
        return 0
    end
end

function getCraftingLevel(skill)
    if Config.UseCWRepForCraftingSkill then
        return exports['cw-rep']:getCurrentLevel(skill or Config.CraftingSkillName) or 0
    else
        if Config.Debug then print('^1CW REP is required to use skills with for OX core^0') end
        return 0
    end
end

function defineItems()
    if Config.oxInv then
        for items, datas in pairs(exports.ox_inventory:Items()) do
            ItemNames[items] = datas
        end
    end
end

function hasItem(material, amount)
    local count = 0
    local recipe = exports.ox_inventory:Search('slots', material)
    for k, ingredients in pairs(recipe) do
        if ingredients.metadata.degrade ~= nil then
            if ingredients.metadata.degrade >= 1 then
                count = count + ingredients.count
            else
                notify("Items are Bad Quality", 'error')
            end
        else
            count = count + ingredients.count
        end
    end
    if count < amount then
        return false
    end
    return true
end

function triggerProgressBar(name, label, time, cbSuc, cbCancel)
    local canCancel = cbCancel ~= nil

    if lib.progressBar({
        duration = time,
        label = label,
        canCancel = canCancel,
    }) then
        cbSuc()
    else
        cbCancel()
    end
end

function hasBlueprint(input)
    local items = exports.ox_inventory:Search('slots', Config.ItemName)
    for i,bp in pairs(items) do
        if bp.metadata.value == input then
            return true
        end
    end
    return false
end