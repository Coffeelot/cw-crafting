if GetResourceState('es_extended') ~= 'started' then return end
if Config.Debug then print('Using ESX bridge') end

ESX = exports['es_extended']:getSharedObject()

if not lib then
    print('^1You are using ESX core, but Ox lib is not defined^0')
    print('Please add "@ox_lib/init.lua" to your shared_scripts in fxmanifest')
end

RegisterNetEvent('esx:playerLoaded', function()
    defineItems()
end)

function getPlayerJobName()
    local playerData = ESX.GetPlayerData()
    if playerData and playerData.job then
        return playerData.job.name
    end
end

function getPlayerJobType()
    local playerData = ESX.GetPlayerData()
    if playerData and playerData.job then
        return playerData.job.type
    end
end

function getPlayerJobLevel()
    local playerData = ESX.GetPlayerData()
    if playerData and playerData.job and playerData.job.grade then
        return playerData.job.grade
    end
end

function hasGps()
    if Config.Inventory == 'esx' then
        local xPlayer = ESX.GetPlayerData()
        if xPlayer and xPlayer.inventory then
            for _, item in pairs(xPlayer.inventory) do
                if item.name == Config.ItemName.gps and item.count >= 1 then
                    return true
                end
            end
        end
    elseif Config.Inventory == 'ox' then
        if exports.ox_inventory:Search('count', Config.ItemName.gps) >= 1 then
            return true
        end
    end
    return false
end

function getCitizenId()
    return ESX.GetPlayerData().identifier
end

function getVehicleModel(vehicle)
    local model = GetEntityModel(vehicle)
    return GetDisplayNameFromVehicleModel(model)
end

function getClosestPlayer()
    return ESX.Game.GetClosestPlayer()
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

    if Config.OxLibNotify then
        lib.notify({
            title = text,
            type = type,
        })
    else
        ESX.ShowNotification(text)
    end
end

function getCraftingSkill(skill)
    if Config.UseCWRepForCraftingSkill then
        return exports['cw-rep']:getCurrentSkill(skill or Config.CraftingSkillName) or 0
    else
        if Config.Debug then print('^1CW REP is required to use skills with for ESX core^0') end
        return 0
    end
end

function getCraftingLevel(skill)
    if Config.UseCWRepForCraftingSkill then
        return exports['cw-rep']:getCurrentLevel(skill or Config.CraftingSkillName) or 0
    else
        if Config.Debug then print('^1CW REP is required to use skills with for ESX core^0') end
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