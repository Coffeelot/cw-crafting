local useDebug = Config.Debug

RegisterNetEvent('cw-crafting:server:craftItem', function(recipe, item, craftingAmount)
    local src = source
    local craftingAmount = tonumber(craftingAmount) -- safeguard craftingamount cause why not
    if useDebug then 
        print('Crafting', recipe, craftingAmount)
        print('item', json.encode(item))
        print('Skill', item.skillData.skillName, item.skillData.currentSkill)
    end

    local success = false
    
    if hasAllMaterials(src, item.materials, craftingAmount, item.keepMaterials) then
        for material, amount in pairs(item.materials) do
            if not item.keepMaterials or not item.keepMaterials[material] then 
                if useDebug then print('Removing', material, ' for crafting') end
                removeItem(src, material, amount*craftingAmount)
            else
                if useDebug then print('skipping removal of', material, 'as its marked as keep') end
            end

            if item.toItems ~= nil then
                for toMat, toAmount in pairs(item.toItems) do
                    addItem(src, toMat, toAmount*craftingAmount, item.metadata)
                end
                success = true
            else
                print('^1Recipe is not created correctly: Missing toItems^0', recipe)
            end

        end
    else
        TriggerClientEvent('cw-crafting:client:notify', src, 'You are lacking some of the items to craft this', 'error') -- also possible exploit, if you wanna kick someone add it after this
    end
    if success then
        increaseCraftingSkill(src, Config.CraftingRepGainFunction(recipe.craftingSkill, item)*craftingAmount, item.skillName or Config.CraftingSkillName)
    end
end)

local function updateBlueprints(citizenId, blueprints)
    if useDebug then print('Setting blueprints to', json.encode(blueprints, {indent=true})) end
    return MySQL.Sync.execute('UPDATE '..Config.PlayersTableName..' SET crafting_blueprints = ? WHERE '..Config.PlayerDbIdentifier..' = ?', {json.encode(blueprints), citizenId} )
end

local function fetchBlueprints(citizenId)
    local results = MySQL.Sync.fetchAll('SELECT crafting_blueprints FROM '..Config.PlayersTableName..' WHERE '..Config.PlayerDbIdentifier..' = ?', {citizenId})
    if results then
        if useDebug then print('Result from fetch', json.encode(results[1], {indent=true})) end
        local playerRes = results[1]
        if playerRes then 
            if useDebug then print('Player had a list') end
            return json.decode(playerRes.crafting_blueprints)
        else
            return {}
        end
    end
    return false
end

local function removeBlueprint(citizenId, blueprint)
    local blueprints = fetchBlueprints(citizenId)
    if blueprints then
        for i, bp in pairs(blueprints) do
            if bp == blueprint then
                table.remove(blueprints, i)
                MySQL.Sync.execute('UPDATE '..Config.PlayersTableName..' SET crafting_blueprints = ? WHERE '..Config.PlayerDbIdentifier..' = ?', {blueprints, citizenId} )
                return true
            end
        end
    else
        return false
    end
end

local function addBlueprint(src, citizenId, blueprint)
    local blueprints = fetchBlueprints(citizenId)
    if useDebug then print('bps', json.encode(blueprints, {indent=true})) end
    if blueprints ~= nil then
        if #blueprints > 0 then
            for i, bp in pairs(blueprints) do
                if bp == blueprint then
                   if useDebug then print('Character already has this blueprint') end
                   TriggerClientEvent('cw-crafting:client:notify', src, 'You already have this blueprint', 'error') 
                   return false
                end
            end
        end
        if useDebug then
            print('add Blueprint success:', blueprint)
        end
        blueprints[#blueprints+1] = blueprint
        updateBlueprints(citizenId, blueprints)
        return true
    else
        return false
    end
end

local function handleAddBlueprintFromItem(source, blueprint, slot)
    local src = source
    local citizenId = getCitizenId(src)
    local success = addBlueprint(src, citizenId, blueprint)
    if success then
        removeItemBySlot(src, Config.ItemName, 1, slot)
    else
        TriggerClientEvent('cw-crafting:client:notify', src, "You already know this recipe", "error")
    end
end

local function giveBlueprintItem(source, blueprintValue)
    local src = source
    local label = blueprintValue
    if Config.Blueprints[blueprintValue].label then
        label = Config.Blueprints[blueprintValue].label
    end
    local metadata = {}
    metadata.value = blueprintValue
    metadata.label = label
    addItem(src, Config.ItemName, 1, metadata)
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
       print(json.encode(tempBlueprints, {indent=true}))
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
    giveBlueprintItem(src, value)
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
    addBlueprint(source, citizenId, blueprint)
end)

RegisterServerCallback('cw-crafting:server:getBlueprints', function()
    if useDebug then print('Fetching Bps for player', source) end
    local citizenId = getCitizenId(source)
    if useDebug then print('Citizenid', citizenId) end
    return fetchBlueprints(citizenId)
 end)

function HandleUseBlueprint(src, itemMetaData, slotId)
    if Config.BlueprintDudes then
        TriggerClientEvent('cw-crafting:client:notify', src, "You need to find someone who can teach you this..", "error")
    else
        if useDebug then print('used blueprint') end
        local blueprint = nil
        if not itemMetaData.value then
            TriggerClientEvent('cw-crafting:client:notify', src, 'The person who gave/spawned you this can not read Readmes', 'error')
            return
        end
        blueprint = itemMetaData.value
        TriggerClientEvent('cw-crafting:client:progressbar', src)
        handleAddBlueprintFromItem(src, blueprint, slotId)
    end
end

RegisterNetEvent('cw-crafting:server:addBlueprintFromLearning', function(blueprint)
    local src = source
    if useDebug then
        print('used blueprint', json.encode(blueprint, {indent=true}))
    end
    TriggerClientEvent('cw-crafting:client:progressbar', src)
    handleAddBlueprintFromItem(src, blueprint.bpName)
end)

registerCommand('addblueprint', 'Give blueprint knowledge to player. (Admin Only)',{ { name = 'player id', help = 'the id of the player' }, { name = 'blueprint', help = 'name of blueprint' } }, true, function(source, args)
    local citizenId = getCitizenId(args[1])
    print('adding '..args[2].. ' to '..citizenId)
    addBlueprint(args[1], citizenId, args[2])
end, 'admin')

registerCommand('removeblueprint', 'Remove blueprint to player. (Admin Only)',{ { name = 'player id', help = 'the id of the player' }, { name = 'blueprint', help = 'name of blueprint' } }, true, function(source, args)
    local citizenId = getCitizenId(args[1])
    print('removing '..args[2].. ' from'..citizenId)
    removeBlueprint(citizenId, args[2])
end, 'admin')

registerCommand('giveblueprint', 'Add blueprint item to player. (Admin Only)',{ { name = 'player id', help = 'the id of the player' }, { name = 'blueprint', help = 'name of blueprint' } }, true, function(source, args)
    giveBlueprintItem(tonumber(args[1]), args[2])
end, 'admin')

registerCommand('cwdebugcrafting', 'toggle debug for crafting', {}, true, function(source, args)
    useDebug = not useDebug
    print('^3debug for crafting is now:^0', useDebug)
    TriggerClientEvent('cw-crafting:client:toggleDebug',source, useDebug)
end, 'admin')
