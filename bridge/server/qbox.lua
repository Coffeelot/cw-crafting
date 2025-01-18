if GetResourceState('qbx_core') ~= 'started' then return end

AddEventHandler('ox_inventory:usedItem', function(playerId, name, slotId, metadata)
    if Config.UseDebug then print(playerId, 'using blueprint') end

    if name == Config.ItemName then
        HandleUseBlueprint(playerId, metadata, slotId)
    end
end)

-- Adds money to user
function addMoney(src, moneyType, amount)
    local player = exports.qbx_core:GetPlayer(tonumber(src))
    player.Functions.AddMoney(moneyType, math.floor(amount))
end

-- Removes money from user
function removeMoney(src, moneyType, amount, reason)
    local player = exports.qbx_core:GetPlayer(tonumber(src))
    return player.Functions.RemoveMoney(moneyType, math.floor(amount))
end

-- Checks that user can pay
function canPay(src, moneyType, cost)
    local player = exports.qbx_core:GetPlayer(tonumber(src))
    return player.PlayerData.money[moneyType] >= cost
end

-- Fetches the CitizenId by Source
function getCitizenId(src)
    local player = exports.qbx_core:GetPlayer(tonumber(src))
    return player.PlayerData.citizenid
end

-- Fetches the Source of an online player by citizenid
function getSrcOfPlayerByCitizenId(citizenId)
    return exports.qbx_core:GetPlayerByCitizenId(citizenId).PlayerData.source
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
        if Config.Debug then print('CW-REP: Increasing crafting skill by:', amount) end
        exports['cw-rep']:updateSkill(src, skillName, amount)
    else
        local Player = exports.qbx_core:GetPlayer(src)
        local newSkill = Player.PlayerData.metadata['craftingrep'] + amount
        if Config.Debug then print('New skill:', newSkill) end
        Player.Functions.SetMetaData('craftingrep', newSkill)
    end
end