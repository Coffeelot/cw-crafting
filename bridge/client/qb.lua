if GetResourceState('qb-core') ~= 'started' or GetResourceState('qbx_core') == 'started' then return end
if Config.Debug then print('Using QB bridge') end


local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
    defineItems()
end)

function getPlayerJobName()
    local playerData = QBCore.Functions.GetPlayerData()
    if playerData and playerData.job then
        return playerData.job.name
    end
end

function getPlayerJobType()
    local playerData = QBCore.Functions.GetPlayerData()
    if playerData and playerData.job then
        return playerData.job.type
    end
end

function getPlayerJobLevel()
    local playerData = QBCore.Functions.GetPlayerData()
    if playerData and playerData.job and playerData.job.grade then
        return playerData.job.grade.level
    end
end

function hasGps()
    if Config.Inventory == 'qb' then
        if QBCore.Functions.HasItem(Config.ItemName.gps) then
            return true
        end
    elseif Config.Inventory == 'ox' then
        if exports.ox_inventory:Search('count', Config.ItemName.gps) >= 1 then
            return true
        end
    end
    return false
end

function getCitizenId()
    return QBCore.Functions.GetPlayerData().citizenid
end

function getVehicleModel(vehicle)
    local model = GetEntityModel(vehicle)
    for vmodel, vdata in pairs(QBCore.Shared.Vehicles) do
        if model == joaat(vmodel) then
            return vdata.name, vdata.brand
        end
    end
    return GetDisplayNameFromVehicleModel(model)
end

function getClosestPlayer()
    return QBCore.Functions.GetClosestPlayer()
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
        QBCore.Functions.Notify(text, type)
    end

end

function getCraftingSkill(skill)
    if Config.UseCWRepForCraftingSkill then
        return exports['cw-rep']:getCurrentSkill(skill or Config.CraftingSkillName) or 0
    else
        local PlayerData = QBCore.Functions.GetPlayerData()
        return PlayerData.metadata.craftingrep or 0
    end
end

function getCraftingLevel(skill)
    if Config.UseCWRepForCraftingSkill then
        return exports['cw-rep']:getCurrentLevel(skill or Config.CraftingSkillName) or 0
    else
        local PlayerData = QBCore.Functions.GetPlayerData()
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
    else
        ItemNames = QBCore.Shared.Items
    end
end

function hasItem(material, amount)
    if Config.oxInv then
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
    else
        return QBCore.Functions.HasItem(material, amount) 
    end
end

function triggerProgressBar(name, label, time, cbSuc, cbCancel)
    if Config.oxLib then
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
    else
        local canCancel = cbCancel ~= nil

        QBCore.Functions.Progressbar(name, label, time , false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, cbSuc(), cbCancel() or {})
    end
end

local function getAllBlueprints()
    local blueprints = {}
    local blueprintItem = Config.ItemName
    local PlayerData = QBCore.Functions.GetPlayerData()
    for i,item in pairs(PlayerData.items) do
        if item.name == blueprintItem then
            blueprints[item.info.value] = item
        end
    end
    return blueprints
end

function hasBlueprint(input)
    if not Config.oxInv then
        local bps = getAllBlueprints()
        for i,bp in pairs(bps) do
            if bp.info.value == input then
                return true
            end
        end
        return false
    else
        local items = exports.ox_inventory:Search('slots', Config.ItemName)
        for i,bp in pairs(items) do
            if bp.metadata.value == input then
                return true
            end
        end
        return false
    end
end
