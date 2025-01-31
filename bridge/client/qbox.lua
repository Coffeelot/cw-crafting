if GetResourceState('qbx_core') ~= 'started' then return end

if Config.Debug then print('Using QBOX bridge') end

if not lib then
    print('^1You are using QBOX core, but Ox lib is not defined^0')
    print('Please add "@ox_lib/init.lua" to your shared_scripts in fxmanifest')
end

local VEHICLEHASHES = exports.qbx_core:GetVehiclesByHash()

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
    defineItems()
end)

if not QBX then
    print('^1 You are using QBOX core but the QBX object is not defined^0')
    print('Make sure to add "@qbx_core/modules/playerdata.lua" to the shared_scripts in fxmanifest')
end

function getPlayerJobName()
    local playerData = QBX.PlayerData
    if playerData and playerData.job then
        return playerData.job.name
    end
end

function getPlayerJobType()
    local playerData = QBX.PlayerData
    if playerData and playerData.job then
        return playerData.job.type
    end
end

function getPlayerJobLevel()
    local playerData = QBX.PlayerData
    if playerData and playerData.job and playerData.job.grade then
        return playerData.job.grade.level
    end
end

function hasGps()
    if exports.ox_inventory:Search('count', Config.ItemName.gps) >= 1 then
        return true
    end
    return false
end

function getCitizenId()
    return QBX.PlayerData.citizenid
end

function getVehicleModel(vehicle)
    local model = GetEntityModel(vehicle)
    local vehData = VEHICLEHASHES[model]
    if vehData then
        return vehData.name, vehData.brand
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
        local PlayerData = QBX.PlayerData
        return PlayerData.metadata.craftingrep or 0
    end
end

function getCraftingLevel(skill)
    if Config.UseCWRepForCraftingSkill then
        return exports['cw-rep']:getCurrentLevel(skill or Config.CraftingSkillName) or 0
    else
        local PlayerData = QBX.PlayerData
        if not PlayerData or PlayerData.metadata.craftingrep then print('Could not find player data') return 0 end
        if not PlayerData.metadata.craftingrep then return 0 end

        return math.ceil(PlayerData.metadata.craftingrep / 100) or 0
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