QBCore =  exports['qb-core']:GetCoreObject()
local useDebug = Config.Debug

local function increaseCraftingSkill(src, amount, skillName)
    if Config.UseCWRepForCraftingSkill then
        if useDebug then print('Increasing crafting skill by:', amount) end
        exports['cw-rep']:updateSkill(src, skillName, amount)
    else
        local Player = QBCore.Functions.GetPlayer(src)
        local newSkill = Player.PlayerData.metadata['craftingrep'] + amount
        if useDebug then print('New skill:', newSkill) end
        Player.Functions.SetMetaData('craftingrep', newSkill)
    end
end

RegisterNetEvent('cw-crafting:server:craftItem', function(recipe, item, craftingAmount)
    local src = source
    if useDebug then 
        print('Crafting', recipe, craftingAmount)
        print('item', json.encode(item))
        print('Skill', item.skillData.skillName, item.skillData.currentSkill)
    end

    local success = false
    local Player = QBCore.Functions.GetPlayer(src)
    if not Config.oxInv then
        for material, amount in pairs(item.materials) do
            if not item.keepMaterials or not item.keepMaterials[material] then 
                if not Player.Functions.RemoveItem(material, amount*craftingAmount) then 
                    TriggerClientEvent('QBCore:Notify', src, 'You are lacking the items to craft this', 'error') -- also possible exploit, if you wanna kick someone add it after this
                    return
                end
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[material], "remove")
            end
        end
        if item.toItems ~= nil then
            for material, amount in pairs(item.toItems) do
                Player.Functions.AddItem(material, amount*craftingAmount, item.metadata)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[material], "add")
            end
            success = true
        else
            print('Recipe is not created correctly: Missing toItems', recipe)
        end
    else
        local pped = GetPlayerPed(src)
        local coords = GetEntityCoords(pped)
        for material, amount in pairs(item.materials) do
            if not item.keepMaterials or not item.keepMaterials[material] then 
                if not exports.ox_inventory:RemoveItem(src, material, amount * craftingAmount) then 
                    TriggerClientEvent('QBCore:Notify', src, 'You are lacking the items to craft this', 'error') -- also possible exploit, if you wanna kick someone add it after this
                    return
                end
            end
        end
        if item.toItems ~= nil then
            for material, amount in pairs(item.toItems) do
                if exports.ox_inventory:CanCarryItem(src, material, amount*craftingAmount) then
                    exports.ox_inventory:AddItem(src, material, amount*craftingAmount, item.metadata)
                else
                    exports.ox_inventory:CustomDrop("craft", {{material, amount*craftingAmount, {durability = 100 }}}, coords)
                end
            end
            success = true
        else
            print('Recipe is not created correctly: Missing toItems', recipe)
        end
    end

    if success then
        increaseCraftingSkill(src, Config.CraftingRepGainFunction(recipe.craftingSkill, item)*craftingAmount, item.skillName or Config.CraftingSkillName)
    end
end)

local function updateBlueprints(citizenId, blueprints)
    return MySQL.Sync.execute('UPDATE players SET crafting_blueprints = ? WHERE citizenid = ?', {json.encode(blueprints), citizenId} )
end

local function fetchBlueprints(citizenId)
    local fetched = MySQL.Sync.fetchAll('SELECT crafting_blueprints FROM players WHERE citizenid = ?', {citizenId})[1].crafting_blueprints
    local decoded = json.decode(fetched)
    return decoded
end

local function removeBlueprint(citizenId, blueprint)
    local blueprints = fetchBlueprints(citizenId)
    if blueprints then
        for i, bp in pairs(blueprints) do
            if bp == blueprint then
                table.remove(blueprints, i)
                MySQL.Sync.execute('UPDATE players SET crafting_blueprints = ? WHERE citizenid = ?', {json.encode(blueprints), citizenId} )
                return true
            end
        end
    else
        return false
    end
end

local function addBlueprint(citizenId, blueprint)
    local blueprints = fetchBlueprints(citizenId)
    if blueprints ~= nil then
        if #blueprints > 0 then
            for i, bp in pairs(blueprints) do
                if bp == blueprint then
                    print('Character already has this blueprint')
                    return false
                end
            end
        end
        if Config.Debugcraft then
            print('add Blueprint success:', blueprint)
        end
        blueprints[#blueprints+1] = blueprint
        updateBlueprints(citizenId, blueprints)
        return true
    else
        return false
    end
end

local function handleAddBlueprintFromItem(source, blueprint)
    local Player = QBCore.Functions.GetPlayer(source)
    local citizenId = Player.PlayerData.citizenid
    local success = addBlueprint(citizenId, blueprint)
    if success then
        local blueprints = Player.Functions.GetItemsByName('blueprint')
        if not Config.oxInv then
            local slot = nil
            for _, bpItem in ipairs(blueprints) do
                if Config.Debugcraft then
                   print(bpItem.info.value)
                end
                if bpItem.info.value == blueprint then
                    slot = bpItem.slot
                end
            end
            if slot then
                Player.Functions.RemoveItem('blueprint', 1, slot)
                TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['blueprint'], "remove")
                addBlueprint(citizenId, blueprint)
            end
        else
            local slot = nil
            for _, bpItem in ipairs(blueprints) do

                   print(bpItem.metadata.value)

                if bpItem.metadata.value == blueprint then
                    slot = bpItem.slot
                end
            end
            if slot then
                Player.Functions.RemoveItem('blueprint', 1, slot)
                TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['blueprint'], "remove")
                addBlueprint(citizenId, blueprint)
            end
        end
    else
        TriggerClientEvent('QBCore:Notify', source, "You already know this recipe", "error")
    end
end

local function getQBItem(item)
    local qbItem = QBCore.Shared.Items[item]
    if qbItem then
        return qbItem
    else
        print('Someone forgot to add the item')
    end
end

local function giveBlueprintItem(source, blueprintValue)
    local label = blueprintValue
    if Config.Blueprints[blueprintValue].label then
        label = Config.Blueprints[blueprintValue].label
    end
    local info = {}
    info.value = blueprintValue
    info.label = label
    if not Config.oxInv then
    	local Player = QBCore.Functions.GetPlayer(source)
        Player.Functions.AddItem('blueprint', 1, nil, info)
        TriggerClientEvent('inventory:client:ItemBox', source, getQBItem('blueprint'), "add")
    else
        exports.ox_inventory:AddItem(source, 'blueprint', 1, info)
    end
end
exports("giveBlueprintItem", giveBlueprintItem)

local function filterByRarity(min, max)
    local tempBlueprints = {}
    for index, bp in pairs(Config.Blueprints) do
        local rarity = bp.rarity
        if rarity == nil then
           rarity = 1
        end
        if rarity >= min and rarity <= max then
            local i = #tempBlueprints+1
            tempBlueprints[i] = bp
            tempBlueprints[i].value = index
        end
    end
    if useDebug then
       print('sorted BPS', min, max)
       print(QBCore.Debug(tempBlueprints))
    end
    return tempBlueprints
end

local function randomizeBlueprint(blueprints)
    return blueprints[math.random(1, #blueprints)]
end

local function giveRandomBlueprint(source , rarity, failChance)
    local foundItem = nil
    local minRarity = 1
    local maxRarity = 1
    if type(rarity) == 'table' then
        if useDebug then
           print('table')
        end
        minRarity = rarity.min
        maxRarity = rarity.max
    else
        if useDebug then
           print('not table')
        end
        maxRarity = rarity
    end

    local chance = math.random(0,1000)

    if useDebug then
        print('Roll:', chance)
        print('failChance:', failChance)
    end
    if failChance <= chance then
        local blueprints = filterByRarity(minRarity,maxRarity)
        giveBlueprintItem(source, randomizeBlueprint(blueprints).value)
    else
        if useDebug then
           print('Roll Failed', failChance, chance)
        end
    end
end
exports("giveRandomBlueprint", giveRandomBlueprint) -- Use this to give blueprints from random loot

RegisterNetEvent('cw-crafting:server:giveBlueprint', function(value)
    giveBlueprintItem(source, value)
end)

RegisterNetEvent('cw-crafting:server:giveRandomBlueprint', function(source, rarity, failChance)
    if useDebug then
       print('srs', source)
    end

    giveRandomBlueprint(source, rarity , failChance)
end)

RegisterNetEvent('cw-crafting:server:removeBlueprint', function(citizenId,blueprint)
    removeBlueprint(citizenId, blueprint)
end)

RegisterNetEvent('cw-crafting:server:addBlueprint', function(citizenId,blueprint)
    addBlueprint(citizenId, blueprint)
end)

QBCore.Functions.CreateCallback('cw-crafting:server:getBlueprints', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    local citizenId = Player.PlayerData.citizenid
    cb(fetchBlueprints(citizenId))
 end)


QBCore.Functions.CreateUseableItem("blueprint", function(source, item)
    if Config.BlueprintDudes then
        TriggerClientEvent('QBCore:Notify', source, "You need to find someone who can teach you this..", "error")
    else
        if useDebug then print('used blueprint') end
        local blueprint = nil
        if not Config.oxInv then
            if not item.info.value then
                TriggerClientEvent('QBCore:Notify', source, 'The person who gave/spawned you this can not read Readmes', 'error')
                return
            end
            blueprint = item.info.value
        else
            if not item.metadata.value then
                TriggerClientEvent('QBCore:Notify', source, 'The person who gave/spawned you this can not read Readmes', 'error')
                return
            end
            blueprint = item.metadata.value
        end
        TriggerClientEvent('cw-crafting:client:progressbar', source)
        handleAddBlueprintFromItem(source, blueprint)
    end
end)

RegisterNetEvent('cw-crafting:server:addBlueprintFromLearning', function(blueprint)
    local src = source
    if useDebug then
        print('used blueprint', json.encode(blueprint, {indent=true}))
    end
    TriggerClientEvent('cw-crafting:client:progressbar', src)
    handleAddBlueprintFromItem(src, blueprint.bpName)
end)

QBCore.Commands.Add('addblueprint', 'Give blueprint knowledge to player. (Admin Only)',{ { name = 'player id', help = 'the id of the player' }, { name = 'blueprint', help = 'name of blueprint' } }, true, function(source, args)
    local Player = QBCore.Functions.GetPlayer(tonumber(args[1]))
    local citizenId = Player.PlayerData.citizenid
    print('adding '..args[2].. ' to '..citizenId)
    addBlueprint(citizenId, args[2])
end, 'admin')

QBCore.Commands.Add('removeblueprint', 'Remove blueprint to player. (Admin Only)',{ { name = 'player id', help = 'the id of the player' }, { name = 'blueprint', help = 'name of blueprint' } }, true, function(source, args)
    print(args[1])
    local Player = QBCore.Functions.GetPlayer(tonumber(args[1]))
    local citizenId = Player.PlayerData.citizenid
    print('removing '..args[2].. ' to '..citizenId)
    removeBlueprint(citizenId, args[2])
end, 'admin')

QBCore.Commands.Add('giveblueprint', 'Give blueprint item to player. (Admin Only)',{ { name = 'player id', help = 'the id of the player' }, { name = 'blueprint', help = 'name of blueprint' } }, true, function(source, args)
    giveBlueprintItem(tonumber(args[1]), args[2])
end, 'admin')

QBCore.Commands.Add('cwdebugcrafting', 'toggle debug for crafting', {}, true, function(source, args)
    useDebug = not useDebug
    print('debug is now:', useDebug)
    TriggerClientEvent('cw-crafting:client:toggleDebug',source, useDebug)
end, 'admin')

QBCore.Commands.Add('testbp', 'test bps. (Admin Only)',{}, true, function(source)
    TriggerEvent('cw-crafting:server:giveRandomBlueprint',source)
    --TriggerEvent('cw-crafting:server:giveRandomBlueprint',source, 3, 50)
end, 'admin')