local QBCore = exports['qb-core']:GetCoreObject()
local Recipes = {}
local Blueprints = {}
local CurrentAmount = 1
local currentTableType = nil
local lastTableType = nil
local ItemNames = {}
local useDebug = Config.Debug
local isCrafting = false
local Entities = {}

local function getOxItems()
    if Config.oxInv then
        for items, datas in pairs(exports.ox_inventory:Items()) do
            ItemNames[items] = datas
        end
    end
end

local function getCraftingSkill()
    if Config.UseCWRepForCraftingSkill then
        return exports['cw-rep']:getCurrentSkill(Config.CraftingSkillName) or 0
    else
        local PlayerData = QBCore.Functions.GetPlayerData()
        return PlayerData.metadata.craftingrep or 0
    end
end

local function getCraftingLevel()
    if Config.UseCWRepForCraftingSkill then
        return exports['cw-rep']:getCurrentLevel(Config.CraftingSkillName) or 0
    else
        local PlayerData = QBCore.Functions.GetPlayerData()
        if not PlayerData or PlayerData.metadata.craftingrep then print('Could not find player data') return 0 end
        if not PlayerData.metadata.craftingrep then return 0 end

        return math.ceil(PlayerData.metadata.craftingrep / 100) or 0
    end
end

local function verifyAllItemsExists()
    local allItemsExist = true;
    local recipesAreFine = true;
    for recipe, item in pairs(Config.Recipes) do
        if not Config.oxInv then
            if item.materials ~= nil then
                for mat, amount in pairs(item.materials) do
                    if not QBCore.Shared.Items[mat] then
                        allItemsExist = false
                        print('!!! CW CRAFTING WARNING !!!')
                        print('item defined in config but does not exist in your item.lua: ', mat)
                    end
                end
            else
                recipesAreFine = false
                print('!!! CW CRAFTING WARNING !!!')
                print('Recipe has no input: ', recipe)
            end
            if item.toItems ~= nil then
                for mat, amount in pairs(item.toItems) do
                    if not QBCore.Shared.Items[mat] then
                        allItemsExist = false
                        print('!!! CW CRAFTING WARNING !!!')
                        print('item defined in config but does not exist in your item.lua: ', mat)
                    end
                end
            else
                recipesAreFine = false
                print('!!! CW CRAFTING WARNING !!!')
                print('Recipe has no output: ', recipe)
            end
        else
            if item.materials ~= nil then
                for mat, amount in pairs(item.materials) do
                    if not ItemNames[mat] then
                        allItemsExist = false
                        print('!!! CW CRAFTING WARNING !!!')
                        print('item defined in config but does not exist in your item.lua: ', mat)
                    end
                end
            else
                recipesAreFine = false
                print('!!! CW CRAFTING WARNING !!!')
                print('Recipe has no input: ', recipe)
            end
            if item.toItems ~= nil then
                for mat, amount in pairs(item.toItems) do
                    if not ItemNames[mat] then
                        allItemsExist = false
                        print('!!! CW CRAFTING WARNING !!!')
                        print('item defined in config but does not exist in your item.lua: ', mat)
                    end
                end
            else
                recipesAreFine = false
                print('!!! CW CRAFTING WARNING !!!')
                print('Recipe has no output: ', recipe)
            end
        end
    end
    if not allItemsExist or not recipesAreFine then
        print('^1-------------------------')
        print('^1There are issues with your cw crafting setup. This is most likely NOT the fault of the script.')
        if not allItemsExist then
            print('- Make sure to check all the item names for misspellings and that they exist')
            print('- Item names are case sensitive')
        end
        if not recipesAreFine then 
            print('- One or more of your crafting recipes are broken. Either lacking an input our an output')
        end
        print('^1-------------------------')
    end
end

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        getOxItems()
        verifyAllItemsExists()
    end
end)

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    if Config.oxInv then
        getOxItems()
    end
end)

local function validateJob(item)
    if item.jobs then
        local Player = QBCore.Functions.GetPlayerData()

        local playerHasJob = false
        local levelRequirement = nil
        local jobLevel = Player.job.grade.level
        local jobName = Player.job.name
        local jobType = Player.job.type
    
        for i, job in pairs(item.jobs) do
            if job.type and jobType then
                if job.type == jobType then
                    playerHasJob = true
                    levelRequirement = job.level
                    break;
                end
            else
                if job.name == jobName then
                    playerHasJob = true
                    levelRequirement = job.level
                    break;
                end
            end
        end

        if playerHasJob then
            if levelRequirement ~= nil then
                if jobLevel >= levelRequirement then
                    return true
                else
                    -- print('Does not have the correct level')
                    return false
                end
            else
                return false
            end
        else
            return false
        end
    else
        return nil
    end
end

local function validateBlueprints(item)
    if item.blueprint then
        for i, blueprint in pairs(Blueprints) do
            if blueprint == item.blueprint then return true end
        end
        return false
    else
        return nil
    end
end

local function validateAccess(item, recipe)
    local playerPassesJobReq = validateJob(item)
    local playerPassesBlueprintReq = validateBlueprints(item)

    if item.requireBlueprintAndJob == true then
        if useDebug then
            print(recipe.. ' requires both job and blueprint', playerPassesJobReq, playerPassesBlueprintReq)
        end
        return playerPassesJobReq and playerPassesBlueprintReq
    elseif item.blueprint ~= nil and item.jobs ~= nil then
        if useDebug then
           print(recipe.. ' can use either job or blueprint', playerPassesJobReq, playerPassesBlueprintReq)
        end
        return playerPassesJobReq or playerPassesBlueprintReq
    elseif item.blueprint ~= nil then
        if useDebug then
           print(recipe.. ' requires blueprint', playerPassesBlueprintReq)
        end
        return playerPassesBlueprintReq
    elseif item.jobs ~= nil then
        if useDebug then
           print(recipe.. ' requires job', playerPassesJobReq)
        end
        return playerPassesJobReq
    end
    if useDebug then
       print(recipe..' has no requirements')
    end
    return true
end

local function validateRights(item, recipe)
    local tables = {}
    if item.tables ~= nil then
        for i, table in pairs(item.tables) do
            tables[table] = table
        end
    else
        tables = { ['basic'] = 'basic' }
    end

    if useDebug then print('Item table:', json.encode(tables, {indent=true})) print('Current table type', currentTableType) print('matches', tables[currentTableType]) end
    if (tables == nil or tables[currentTableType]) and tables[currentTableType] then -- no table reqirement and this is a basic table
        if useDebug then
            print('is basic table')
        end
        return validateAccess(item, recipe)
    end
    if useDebug then
        print('recipe did not match this table')
    end
    return false
end

local function canCraftItem(item)
    if not Config.oxInv then
        local craft = true
        for material, amount in pairs(item.materials) do
            if useDebug then
               print(amount*CurrentAmount, material)
            end
            local hasItem = QBCore.Functions.HasItem(material, amount*CurrentAmount)
            if useDebug then
               print('hasitem', hasItem)
            end
            if not hasItem then
                craft = false
            end
        end
        return craft
    else
        local craft = true
        for material, amount in pairs(item.materials) do
            local count = 0
            local recipe = exports.ox_inventory:Search('slots', material)
                for k, ingredients in pairs(recipe) do
                    if ingredients.metadata.degrade ~= nil then
                        if ingredients.metadata.degrade >= 1 then
                            count = count + ingredients.count
                        else
                            QBCore.Functions.Notify("Items are Bad Quality", 'error', 5000)
                        end
                    else
                        count = count + ingredients.count
                    end
                end
                if count < amount*CurrentAmount then
                    craft = false
                end
        end
        if not craft then return false end
        return true
    end
end

local function getHasItemsMap(item)
    local hasItemsMap = {}
    if not Config.oxInv then
        local craft = true
        for material, amount in pairs(item.materials) do
            if useDebug then
               print(amount*CurrentAmount, material)
            end
            hasItemsMap[material] = QBCore.Functions.HasItem(material, amount*CurrentAmount)
        end
    else
        local craft = true
        for material, amount in pairs(item.materials) do
            local count = exports.ox_inventory:Search('count', material)
            if count then 
                hasItemsMap[material] = count >= amount*CurrentAmount
            else
                hasItemsMap[material] = false
            end
                
        end
    end
    return hasItemsMap
end

local function getRecipes()
    if useDebug then
       print('generating recipes for table', currentTableType)
    end
    Recipes = {}
    if useDebug then
       print('Amount of recipes: ', #Config.Recipes)
    end

    for recipe, item in pairs(Config.Recipes) do
        local canCraft = validateRights(item, recipe)
        if canCraft then
            local materialsNameMap = {}
            local toMaterialsNameMap = {}
            if not Config.oxInv then
                if item.materials then
                    if useDebug then
                        print('Material used:')
                    end
                    for mat, amount in pairs(item.materials) do
                        if useDebug then
                            print(mat, amount)
                        end
                        materialsNameMap[mat] = QBCore.Shared.Items[mat].label
                    end
                else
                    print('!!! CW CRAFTING WARNING !!!')
                    print('Recipe has no input: ', recipe)
                end
                if item.toItems ~= nil then
                    if useDebug then
                       print('Materials given')
                    end
                    for mat, amount in pairs(item.toItems) do
                        if useDebug then
                            print(mat, amount)
                        end
                        toMaterialsNameMap[mat] = QBCore.Shared.Items[mat].label
                    end
                else
                    print('!!! CW CRAFTING WARNING !!!')
                    print('Recipe has no output: ', recipe)
                end
            else
                if useDebug then
                   print('materials', json.encode(item.materials, {indent=true}))
                end
                if item.materials then
                    for mat, amount in pairs(item.materials) do
                        materialsNameMap[mat] = ItemNames[mat].label
                    end
                else
                    print('!!! CW CRAFTING WARNING !!!')
                    print('Recipe has no input: ', recipe)
                end
                if item.toItems ~= nil then
                    for mat, amount in pairs(item.toItems) do
                        if mat and ItemNames[mat] and ItemNames[mat].label then
                            toMaterialsNameMap[mat] = ItemNames[mat].label
                        else
                            print('^1Recipe is using a broken item')
                            print('Material:', mat)
                            print('Item data', json.encode(ItemNames[mat], {indent=true}))
                            print('If the above is "null" then this item does not exist in your items.lua')
                        end
                    end
                else
                    print('!!! CW CRAFTING WARNING !!!')
                    print('Recipe has no output: ', recipe)
                end

            end
            item.materialsNameMap = materialsNameMap
            item.toMaterialsNameMap = toMaterialsNameMap
            item.skillGain = Config.CraftingRepGainFunction(item.craftingSkill, recipe)
            if not item.maxCraft then
                item.maxCraft = Config.DefaultMaxCraft or 10
            end

            local skillName = item.skillName or Config.CraftingSkillName
            local skillLabel = Config.CraftingSkillLabel
            local currentSkill = 0
            if Config.UseCWRepForCraftingSkill then
                skillLabel = exports['cw-rep']:getSkillInfo(skillName).label or skillName
                if Config.UseLevelsInsteadOfSkill then
                    currentSkill = exports['cw-rep']:getCurrentLevel(skillName) or 0
                else
                    currentSkill = exports['cw-rep']:getCurrentSkill(skillName) or 0
                end
            else
                local PlayerData = QBCore.Functions.GetPlayerData()
                currentSkill = PlayerData.metadata.craftingrep or 0
            end

            if useDebug then 
                print('Current skill level', currentSkill)
                print('Required skill level', item.craftingSkill)
            end
            if not item.craftingSkill then
                item.craftingSkill = 0
            else
            end
            local skillData = {
                skillName = skillName,
                currentSkill = currentSkill,
                skillLabel = skillLabel,
                passes = item.craftingSkill <= currentSkill
            }
            item.skillData = skillData
        
            Recipes[recipe] = item
            if item.craftingTime == nil then
                Recipes[recipe].craftingTime = Config.DefaultCraftingTime
            end
            if useDebug then
                print('Has access to', recipe)
            end
        else
            if useDebug then
                print('Did not have access to', recipe)
            end
        end
        if useDebug then
            print("====================")
        end

    end
    return Recipes
end

local function setCraftingOpen(bool, i)
    local craftingSkill = getCraftingSkill()
    local craftingLevel = getCraftingLevel()
    if not craftingSkill then craftingSkill = 0 end
    if bool then
        QBCore.Functions.TriggerCallback('cw-crafting:server:getBlueprints', function(bps)
            Blueprints = bps
            if useDebug then
                print('Crafting was opened', bool)
            end
            SetNuiFocus(bool, bool)
            currentTableType = i;
            StartScreenEffect('MenuMGIn', 1, true)
            SendNUIMessage({
                action = "cwCrafting",
                toggle = bool,
                type = 'toggleUi',
                table = Config.CraftingTables[currentTableType],
                craftingSkill = craftingSkill,
                craftingLevel = craftingLevel
            })
        end)
    else
        SetNuiFocus(bool, bool)
        lastTableType = currentTableType
        currentTableType = nil;
        StopScreenEffect('MenuMGIn')
        SendNUIMessage({
            action = "cwCrafting",
            toggle = bool,
            type = 'toggleUi',
            table = Config.CraftingTables[currentTableType],
            craftingSkill = craftingSkill
        })
    end
end exports('setCraftingOpen', setCraftingOpen)

local function craftItem(item, recipe)
    if canCraftItem(item) then
        local craftTime = Config.DefaultCraftingTime*CurrentAmount
        if item.craftingTime then
            craftTime = item.craftingTime*CurrentAmount
        end
        isCrafting = true
        TriggerEvent('animations:client:EmoteCommandStart', {"mechanic"})
        QBCore.Functions.Progressbar("crafting", "Crafting", craftTime , false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function()
            setCraftingOpen(true, lastTableType)
            TriggerServerEvent('cw-crafting:server:craftItem',recipe, item, CurrentAmount)
            TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            isCrafting = false
        end, function() -- Cancel
            TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            isCrafting = false
            QBCore.Functions.Notify(Lang:t('error.canceled'), "error")
        end)
        return true
    else
        QBCore.Functions.Notify('You dont have the required items', "error", 2500)
        return false
    end
end

local function benchpermissions(jobTypes)
    local Player = QBCore.Functions.GetPlayerData()
    if jobTypes[Player.job.type] ~= nil then return true else return false end
end

RegisterNUICallback('attemptCrafting', function(recipe, cb)
    if isCrafting then
        QBCore.Functions.Notify("You're already crafting something", "error")
    else
        local Player = QBCore.Functions.GetPlayerData()
        local currentRecipe = Config.Recipes[recipe.currentRecipe]
        CurrentAmount = recipe.craftingAmount
        if CurrentAmount == 0 then
            QBCore.Functions.Notify("You can't craft a batch of 0.", "error")
        end
        if useDebug then
            print(recipe.currentRecipe, json.encode(currentRecipe, {indent=true}))
        end
        local success = craftItem(currentRecipe, recipe.currentRecipe, lastTableType)
        cb(success)
        return
    end
    cb(false)
end)

RegisterNUICallback('getRecipes', function(data, cb)
    if useDebug then
       print('Fetching recipes')
    end
    getRecipes()
    cb(Recipes)
end)

RegisterNUICallback('getCanCraft', function(data, cb)
    if useDebug then
       print('Checking if items are in pockets')
    end
    CurrentAmount = data.craftingAmount
    local currentRecipe = Config.Recipes[data.currentRecipe]

    cb(getHasItemsMap(currentRecipe))
end)


RegisterNUICallback('closeCrafting', function(_, cb)
    if useDebug then
        print('Closing crafting')
    end
    setCraftingOpen(false)
    cb('ok')
end)

RegisterNUICallback('getSettings', function(_, cb)
    local settings = {
        oxInventory = Config.oxInv,
        useLocalImages = Config.UseLocalImages
    }
    cb(settings)
end)

--[[ RegisterCommand('openCrafting', function(source)
    if useDebug then
        print('Open crafting')
    end
    setCraftingOpen(true)
end)
 ]]

local function createTable(type, benchType)
    local options = {}
    options[1] = {
        type = 'client',
        label = benchType.title,
        icon = "fas fa-wrench",
        gang = benchType.gang,
        job = benchType.job,
        action = function()
            setCraftingOpen(true, type)
        end,
        canInteract = function()
            if benchType.jobType ~= nil then
                return benchpermissions(benchType.jobType)
            else
                return true
            end
        end,
    }

    if benchType.objects then
        for j, benchProp in pairs(benchType.objects) do
            exports['qb-target']:AddTargetModel(benchProp, {
                options = options,
                distance = 2.0
            })
        end
    end
    if benchType.locations then
        for j, benchLoc in pairs(benchType.locations) do
            exports['qb-target']:AddBoxZone('crafting-'..benchType.title..'-'..j, benchLoc, 1.5, 1.5, {
                name = 'crafting-'..benchType.title..'-'..j,
                heading = 0,
                debugPoly = useDebug,
                minZ = benchLoc.z - 0.5,
                maxZ = benchLoc.z + 0.5,
            }, {
                options = options,
                distance = 2.0
            })
        end
    end
    if benchType.spawnTable then
        for j, bench in pairs(benchType.spawnTable) do
            local benchEntity = CreateObject(bench.prop, bench.coords.x, bench.coords.y, bench.coords.z, false,  false, true)
            SetEntityHeading(benchEntity, bench.coords.w)
            if not bench.skipPlaceObjectOnGroundProperly then
                PlaceObjectOnGroundProperly(benchEntity)
            end
            FreezeEntityPosition(benchEntity, true)
            Entities[#Entities+1] = benchEntity
            exports['qb-target']:AddTargetEntity(benchEntity, {
                options = options,
                distance = 2.0
            })
        end
    end
    if not Config.CraftingTables[type] then
        Config.CraftingTables[type] = benchType
    end
end exports("createTable", createTable)

CreateThread(function()
    for i, benchType in pairs(Config.CraftingTables) do
        createTable(i, benchType)
    end
end)

local function addRecipe(name, recipe)
    if not name then print('^1 did not include name when trying to create table') return end
    if not recipe then print('^1 did not include recipe') return end
    
    if Config.Recipes[name] then print('^1 the name is already in use', name) return end

    Config.Recipes[name] = recipe
    if useDebug then print('^2Added recipe '..name..' to list of recipes') end
end exports("addRecipe", addRecipe)

-- RegisterCommand('testcraft', function(_, args)
-- 	craftItem(Config.Recipes[args[1]])
-- end)


RegisterNetEvent('cw-crafting:client:toggleDebug', function(debug)
   QBCore.Functions.Notify('Toggling Crafting debug to', debug)
   useDebug = debug
end)

AddEventHandler('onResourceStop', function (resource)
   if resource ~= GetCurrentResourceName() then return end
   for i, entity in pairs(Entities) do
       print('deleting', entity)
       if DoesEntityExist(entity) then
          DeleteEntity(entity)
       end
    end
end)

RegisterNetEvent('cw-crafting:client:progressbar', function()
    QBCore.Functions.Progressbar('learnbp', 'Studying text on blueprint', 2500, false, false, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
       return true
        --Stuff goes here
    end,{})
end)

local function getAllBlueprints()
    local blueprints = {}
    local blueprintItem = 'blueprint'
    local PlayerData = QBCore.Functions.GetPlayerData()
    for i,item in pairs(PlayerData.items) do
        if item.name == blueprintItem then
            blueprints[item.info.value] = item
        end
    end
    return blueprints
end

local function hasBlueprint(input)
    if not Config.oxInv then
        local bps = getAllBlueprints()
        for i,bp in pairs(bps) do
            if bp.info.value == input then
                return true
            end
        end
        return false
    else
        -- local items = exports.ox_inventory:GetItemCount('blueprint', { value = input } ,false)
        local items = exports.ox_inventory:Search('slots', 'blueprint')
        for i,bp in pairs(items) do
            if bp.metadata.value == input then
                return true
            end
        end
        return false
    end
end

local function generateBlueprintOptions(dude, oxlib)
    local bpOptions = {}
    for name, blueprint in pairs(Config.Blueprints) do
        local dudeHasBlueprint = true

        if not blueprint.type then
            blueprint.type = 'legal'
        end
        if not dude.type then
            dude.type = 'legal'
        end
        if blueprint.type ~= dude.type then
            dudeHasBlueprint = false
        end

        local label = name
        if blueprint.label then
            label = blueprint.label
        end

        if dudeHasBlueprint then
            if oxlib then
                bpOptions[#bpOptions+1] = {
                    type = "server",
                    serverEvent = "cw-crafting:server:addBlueprintFromLearning",
                    bpName = name,
                    icon = "fas fa-graduation-cap",
                    gang = dude.gang,
                    label = "Learn "..label,
                    canInteract = function()
                        return hasBlueprint(name)
                    end
                }
            else
                bpOptions[#bpOptions+1] = {
                    type = "server",
                    event = "cw-crafting:server:addBlueprintFromLearning",
                    bpName = name,
                    icon = "fas fa-graduation-cap",
                    gang = dude.gang,
                    label = "Learn "..label,
                    canInteract = function()
                        return hasBlueprint(name)
                    end
                }
            end
        end
    end

    return bpOptions
end

if Config.BlueprintDudes then
    CreateThread(function()
        for i, dude in pairs(Config.BlueprintDudes) do
            local animation
            if dude.animation then
                animation = dude.animation
            else
                animation = "WORLD_HUMAN_STAND_IMPATIENT"
            end
    
            QBCore.Functions.LoadModel(dude.model)
            local currentDude = CreatePed(0, dude.model, dude.coords.x, dude.coords.y, dude.coords.z-1.0, dude.coords.w, false, false)
            TaskStartScenarioInPlace(currentDude,  animation)
            FreezeEntityPosition(currentDude, true)
            SetEntityInvincible(currentDude, true)
            SetBlockingOfNonTemporaryEvents(currentDude, true)
            
            if Config.UseSundownUtils then
                exports['sundown-utils']:addPedToBanlist(currentDude)
            end
    
            if Config.oxLib then
                local options = generateBlueprintOptions(dude, true)
                if options and #options > 0 then 
                    exports.ox_target:addLocalEntity(currentDude, options)
                else
                    print('^3No options for blueprint npc', dude.model, 'with type:', dude.type)
                    print('^3This NPC will spawn but will be useless and might cause issues. Consider adding blueprints for them or removing them from your list')
                end
            else
                local options = generateBlueprintOptions(dude, false)
                if options and #options > 0 then 
                    exports['qb-target']:AddTargetEntity(currentDude, {
                        options = options,
                        distance = 2.0
                    })
                else
                    print('^3No options for blueprint npc', dude.model, 'with type:', dude.type)
                    print('^3This NPC will spawn but will be useless and might cause issues. Consider adding blueprints for them or removing them from your list')
                end
            end
        end
    end)
end