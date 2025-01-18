if GetResourceState('qb-core') ~= 'started' or GetResourceState('qbx_core') == 'started' then return end

QBCore = exports['qb-core']:GetCoreObject()

if Config.oxInv then
    AddEventHandler('ox_inventory:usedItem', function(playerId, name, slotId, metadata)
        if Config.UseDebug then print(playerId, 'using blueprint') end
    
        if name == Config.ItemName then
            HandleUseBlueprint(playerId, metadata, slotId)
        end
    end)
else
    QBCore.Functions.CreateUseableItem(Config.ItemName, function(source, item)
        HandleUseBlueprint(source, item.info, item.slot)
    end)
end


-- Adds money to user
function addMoney(src, moneyType, amount)
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddMoney(moneyType, math.floor(amount))
end

-- Removes money from user
function removeMoney(src, moneyType, amount, reason)
    local Player = QBCore.Functions.GetPlayer(src)
    return Player.Functions.RemoveMoney(moneyType, math.floor(amount))
end

-- Checks that user can pay
function canPay(src, moneyType, cost)
    local Player = QBCore.Functions.GetPlayer(src)
    return Player.PlayerData.money[moneyType] >= cost
end

-- Fetches the CitizenId by Source
function getCitizenId(src)
    local Player = QBCore.Functions.GetPlayer(src)
    return Player.PlayerData.citizenid
end

-- Fetches the Source of an online player by citizenid
function getSrcOfPlayerByCitizenId(citizenId)
    return QBCore.Functions.GetPlayerByCitizenId(citizenId).PlayerData.source
end

function addItem(src, itemName, amount, metadata)
    if Config.oxInv then
        local pped = GetPlayerPed(src)
        local coords = GetEntityCoords(pped)
    
        if exports.ox_inventory:CanCarryItem(src, itemName, amount) then
            return exports.ox_inventory:AddItem(src, itemName, amount, metadata)
        else
            local item = { name = itemName, amount = amount, metadata =  metadata }
            exports.ox_inventory:CustomDrop("cw-craft", { item }, coords)
        end
    else
        exports['qb-inventory']:AddItem(src, itemName, amount, false, metadata)
    end
    
end

function removeItem(src, itemName, amount)
    if Config.oxInv then
        return exports.ox_inventory:RemoveItem(src, itemName, amount)
    else
        local Player = QBCore.Functions.GetPlayer(src)
        if not Player then return false end
        return exports['qb-inventory']:RemoveItem(src, itemName, amount)
    end
end

function removeItemBySlot(src, itemName, amount, slot)
    if Config.oxInv then
        return exports.ox_inventory:RemoveItem(src, itemName, amount, nil, slot)
    else
        local Player = QBCore.Functions.GetPlayer(src)
        if not Player then return false end
        return exports['qb-inventory']:RemoveItem(src, itemName, amount, slot)
    end
end

function hasAllMaterials(src, materials, craftingAmount, keepMaterials)
    if Config.oxInv then
        keepMaterials = keepMaterials or {} 

        for material, amount in pairs(materials) do
            local totalAmount = amount
            if not keepMaterials[material] then 
                totalAmount = totalAmount * craftingAmount
            end
            if not exports.ox_inventory:GetItemCount(src, material, totalAmount) then return false end
        end
        return true
    else
        local Player = QBCore.Functions.GetPlayer(src)
        if not Player then return false end
        
        keepMaterials = keepMaterials or {}  -- Initialize to empty table if nil
        
        for material, amount in pairs(materials) do
            local totalAmount = amount
            if not keepMaterials[material] then
                totalAmount = totalAmount * craftingAmount
            end
            
            local item = Player.Functions.GetItemByName(material)
            if not item or item.amount < totalAmount then 
                return false 
            end
        end
        return true
    end
end

function increaseCraftingSkill(src, amount, skillName)
    if Config.UseCWRepForCraftingSkill then
        if Config.Debug then print('Increasing crafting skill by:', amount) end
        exports['cw-rep']:updateSkill(src, skillName, amount)
    else
        local Player = QBCore.Functions.GetPlayer(src)
        local newSkill = Player.PlayerData.metadata['craftingrep'] + amount
        if Config.Debug then print('New skill:', newSkill) end
        Player.Functions.SetMetaData('craftingrep', newSkill)
    end
end