if GetResourceState('es_extended') ~= 'started' then return end

ESX = exports['es_extended']:getSharedObject()

AddEventHandler('ox_inventory:usedItem', function(playerId, name, slotId, metadata)
    if Config.UseDebug then print(playerId, 'using blueprint') end

    if name == Config.ItemName then
        HandleUseBlueprint(playerId, metadata, slotId)
    end
end)

-- Adds money to user
function addMoney(src, moneyType, amount)
    local xPlayer = ESX.GetPlayerFromId(src)
    xPlayer.addAccountMoney(moneyType, math.floor(amount))
end

-- Removes money from user
function removeMoney(src, moneyType, amount, reason)
    local xPlayer = ESX.GetPlayerFromId(src)
    if canPay(src, moneyType, amount) then
        xPlayer.removeAccountMoney(moneyType, math.floor(amount))
        return true
    end
    return false
end

-- Checks that user can pay
function canPay(src, moneyType, cost)
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        local account = xPlayer.getAccount(moneyType)
        if account and account.money >= cost then
            return true
        else
            return false
        end
    else
        print("Player not found for source: " .. tostring(src))
        return false
    end
end

-- Fetches the CitizenId by Source
function getCitizenId(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    return xPlayer.identifier
end

-- Fetches the Source of an online player by citizenid
function getSrcOfPlayerByCitizenId(citizenId)
    local players = ESX.GetPlayers()
    for _, playerId in ipairs(players) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer.identifier == citizenId then
            return playerId
        end
    end
end

function addItem(src, itemName, amount, metadata)
    
    local pped = GetPlayerPed(src)
    local coords = GetEntityCoords(pped)

    if exports.ox_inventory:CanCarryItem(src, itemName, amount) then
        return exports.ox_inventory:AddItem(src, itemName, amount, metadata)
    else
        local item = { name = itemName, amount = amount, metadata =  metadata }
        exports.ox_inventory:CustomDrop("cw-craft", { item }, coords)
    end
end

function hasAllMaterials(src, materials, craftingAmount, keepMaterials)
    keepMaterials = keepMaterials or {} 

    for material, amount in pairs(materials) do
        local totalAmount = amount
        if not keepMaterials[material] then 
            totalAmount = totalAmount * craftingAmount
        end
        if not exports.ox_inventory:GetItemCount(src, material, totalAmount) then return false end
    end
    return true
end

function removeItem(src, itemName, amount)
    return exports.ox_inventory:RemoveItem(src, itemName, amount)
end

function removeItemBySlot(src, itemName, amount, slot)
    return exports.ox_inventory:RemoveItem(src, itemName, amount, nil, slot)
end

function increaseCraftingSkill(src, amount, skillName)
    if Config.UseCWRepForCraftingSkill then
        if Config.Debug then print('CW-REP: Increasing crafting skill by:', amount) end
        exports['cw-rep']:updateSkill(src, skillName, amount)
    else
        print('^1CW REP IS REQUIRED TO USE SKILLS WITH ESX CORE^0')
    end
end