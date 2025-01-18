if GetResourceState('ox_core') ~= 'started' then return end
local Ox = require '@ox_core/lib/init'

AddEventHandler('ox_inventory:usedItem', function(playerId, name, slotId, metadata)
    if Config.UseDebug then print(playerId, 'using blueprint') end

    if name == Config.ItemName then
        HandleUseBlueprint(playerId, metadata, slotId)
    end
end)

-- Adds money to user
function addMoney(src, moneyType, amount)
    local player = Ox.GetPlayer(tonumber(src))
    if not player then return false end
    if moneyType == 'cash' or moneyType == 'money' then
        return exports.ox_inventory:AddItem(src, 'money', amount)
    else
        local account = player.getAccount()
        local result = account.addBalance({ amount = amount, message = 'RacingApp Payout' })
        if Config.Debug then print('Ox Banking result for adding:', json.encode(result, {indent=true})) end
        return result.sucess
    end
end

-- Removes money from user
function removeMoney(src, moneyType, amount, reason)
    local player = Ox.GetPlayer(tonumber(src))
    if not player then return false end
    if moneyType == 'cash' or moneyType == 'money' then
        return exports.ox_inventory:RemoveItem(src, 'money', amount)
    else
        local account = player.getAccount()
        local result = account.removeBalance({ amount = amount, message = reason or 'RacingApp Charge' })
        if Config.Debug then print('Account balance', account.get('balance')) print('Ox Banking result for removing:', json.encode(result, {indent=true})) end
        return result.success
    end
end

-- Checks that user can pay
function canPay(src, moneyType, cost)
    local player = Ox.GetPlayer(tonumber(src))
    if not player then return false end
    if moneyType == 'cash' or moneyType == 'money' then
        return exports.ox_inventory:Search(src, 'count', 'money') >= cost
    else
        local account = player.getAccount()
        if not account then return false end
        return account.get('balance') >= tonumber(cost)
    end
end

-- Fetches the CitizenId by Source
function getCitizenId(src)
    local player = Ox.GetPlayer(tonumber(src))
    if not player then return nil end

    return player.stateId
end

-- Fetches the Source of an online player by citizenid
function getSrcOfPlayerByCitizenId(citizenId)
    local player = Ox.GetPlayerFromFilter({ stateId = citizenId })
    if not player then return nil end

    return player.source
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

function removeItem(src, itemName, amount)
    return exports.ox_inventory:RemoveItem(src, itemName, amount)
end

function removeItemBySlot(src, itemName, amount, slot)
    return exports.ox_inventory:RemoveItem(src, itemName, amount, nil, slot)
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

function increaseCraftingSkill(src, amount, skillName)
    if Config.UseCWRepForCraftingSkill then
        if useDebug then print('Increasing crafting skill by:', amount) end
        exports['cw-rep']:updateSkill(src, skillName, amount)
    else
        print('^1CW REP IS REQUIRED TO USE SKILLS WITH OX CORE^0')
    end
end