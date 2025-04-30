ItemNames = {}

local Recipes = {}
local Blueprints = {}
local CurrentAmount = 1
local currentTableType = nil
local lastTableType = nil
local useDebug = Config.Debug
local isCrafting = false
local Entities = {}
local allItemsExist = true;
local recipesAreFine = true;

local function stopAnimation()
    ClearPedTasks(PlayerPedId())
end

local function handleAnimation(animation)
    animation = animation or {}
    local animDict = animation.dict or 'anim@amb@business@coc@coc_unpack_cut@'
    local anim = animation.anim or 'fullcut_cycle_v7_cokecutter'
    if not DoesAnimDictExist(animDict) then
        if useDebug then print('animation dict does not exist') end
        return false
    end
    RequestAnimDict(animDict)
    while (not HasAnimDictLoaded(animDict)) do Wait(10) end
    TaskPlayAnim(PlayerPedId(), animDict, anim, 5.0, 5.0, -1, 51, 0, false, false, false)
end

local function verifyAllItemsExists()
    for recipe, item in pairs(Config.Recipes) do
        if item.materials ~= nil then
            for mat, amount in pairs(item.materials) do
                if not ItemNames[mat] then
                    allItemsExist = false
                    print('^1!!! CW CRAFTING WARNING !!!^0')
                    print('item defined in config but does not exist in your item.lua: ', mat)
                end
            end
        else
            recipesAreFine = false
            print('^1!!! CW CRAFTING WARNING !!!^0')
            print('Recipe has no input: ', recipe)
        end
        if item.toItems ~= nil then
            for mat, amount in pairs(item.toItems) do
                if not ItemNames[mat] then
                    allItemsExist = false
                    print('^1!!! CW CRAFTING WARNING !!!^0')
                    print('item defined in config but does not exist in your item.lua: ', mat)
                end
            end
        else
            recipesAreFine = false
            print('^1!!! CW CRAFTING WARNING !!!^0')
            print('Recipe has no output: ', recipe)
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

local function setupPrintout()
    if useDebug then
        print('^4=== '.. GetCurrentResourceName()..' ===')
        print('^2= Base setup = ')
        print('Using OX Lib', Config.oxLib)
        print('Using OX inventory', Config.oxInv)
        print('Using Local Images', Config.UseLocalImages)
    
        print('^2= Rep = ')
        print('Using CW Rep', Config.UseCWRepForCraftingSkill)
        print('Using Level instead of skill', Config.UseLevelsInsteadOfSkill)
        if not Config.UseCWRepForCraftingSkill and Config.UseLevelsInsteadOfSkill then print('^1Thissetup is incorrect. You need cw rep to use levels') end
        print('Crafting skill name', Config.CraftingSkillName)
        print('Crating Skill label', Config.CraftingSkillLabel)
    
        if not allItemsExist or not recipesAreFine then
            print('^1Your recipes are not set up correctly')
            if not allItemsExist then
                print('- Make sure to check all the item names for misspellings and that they exist')
                print('- Item names are case sensitive')
            end
            if not recipesAreFine then 
                print('- One or more of your crafting recipes are broken. Either lacking an input our an output')
            end
        end
    end
end

local function baseUiSetup()
    if useDebug then
        print('Primary color:', Config.PrimaryUiColor)
    end
    SendNUIMessage({
        action = "cwCrafting",
        type = 'baseData',
        baseData = {
            primary = Config.PrimaryUiColor 
        }
    })
end

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        defineItems()
        verifyAllItemsExists()
        setupPrintout()
        Wait(1000)
        baseUiSetup()
    end
end)


local function validateJob(item)
    if item.jobs then

        local playerHasJob = false
        local levelRequirement = nil
        local jobLevel = getPlayerJobLevel()
        local jobName = getPlayerJobName()
        local jobType = getPlayerJobType()
        if useDebug then print('Player job:', jobName, 'type:', jobType) end
    
        for i, job in pairs(item.jobs) do
            if useDebug then print('checking if player job matches this type:', job.type, 'or name:', job.name) end
            if job.type and jobType then
                if job.type == jobType then
                    playerHasJob = true
                    levelRequirement = job.level
                    if useDebug then print('Player has job of type. Level req:', levelRequirement) end
                    break;
                end
            else
                if job.name == jobName then
                    playerHasJob = true
                    levelRequirement = job.level
                    if useDebug then print('Player has job of name. Level req:', levelRequirement) end
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
           print(recipe.. ' requires blueprint. Player has blueprint:', playerPassesBlueprintReq)
        end
        return playerPassesBlueprintReq
    elseif item.jobs ~= nil then
        if useDebug then
           print(recipe.. ' requires job. Player has job:', playerPassesJobReq)
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
    local canCraft = true
    for material, amount in pairs(item.materials) do
        if useDebug then
            print('total amount', amount*CurrentAmount, material)
            print(json.encode(item, {indent=true}))
        end
        canCraft = hasItem(material, amount*CurrentAmount)
        if useDebug then
           print('hasitem',material, ': ', canCraft, amount*CurrentAmount)
        end
        if not canCraft then
            canCraft = false
        end
    end
    return canCraft
end

local function getHasItemsMap(item)
    local hasItemsMap = {}
    for material, amount in pairs(item.materials) do

        local total = amount*CurrentAmount
        if item.keepMaterials and item.keepMaterials[material] then
            total = 1*amount
        end
        if useDebug then
            print('amount:' ,total, material)
        end
        
        hasItemsMap[material] = hasItem(material, total)

    end
    return hasItemsMap
end

local function getSkillLabel(skillName)
    if Config.UseCWRepForCraftingSkill then
        return exports['cw-rep']:getSkillInfo(skillName).label or skillName
    end
    return Config.CraftingSkillLabel
end

local function getCurrentSkill()
    if Config.UseCWRepForCraftingSkill then
        if Config.UseLevelsInsteadOfSkill then
            return getCraftingLevel() or 0
        end
    end
    return getCraftingSkill() or 0
end

local function handleAddRecipeToCurrentList(recipe, item)
    if useDebug then
        print("=== Attempting to add Recipe for ^3"..(recipe or 'UNKNOWN').."^0 ===")
    end
    local skillName = item.skillName or Config.CraftingSkillName
    local skillLabel = getSkillLabel(skillName)
    local currentSkill = getCurrentSkill()

    local canCraft = validateRights(item, recipe)
    if not canCraft then 
        if useDebug then
            print('Player did ^1not^0 have access to^0', recipe)
        end
        return
    end
    
    local hasSkill = item.craftingSkill <= currentSkill
    if Config.HideRecipeIfSkillNotMet then 
        if not hasSkill then 
            if useDebug then
                print('Player did ^1not^0 have skills enough for^0', recipe)
            end
            return 
        end
    end
    
    local materialsNameMap = {}
    local toMaterialsNameMap = {}
    if useDebug then
        print('^2Passed Intial checks^0')
        print('All materials materials', json.encode(item.materials, {indent=true}))
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

    item.materialsNameMap = materialsNameMap
    item.toMaterialsNameMap = toMaterialsNameMap
    item.skillGain = Config.CraftingRepGainFunction(item.craftingSkill, item)
    if not item.maxCraft then
        item.maxCraft = Config.DefaultMaxCraft or 10
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
        passes = hasSkill
    }
    item.skillData = skillData
    item.craftingTime = item.craftingTime or Config.DefaultCraftingTime

    Recipes[recipe] = item
    if useDebug then
        print('^2Added^0', recipe)
    end
end

local function getRecipes()
    Recipes = {}
    if useDebug then
        print('^5[Generating recipes for table', currentTableType, ']^0')
        print('Total amount of recipes in config: ', #Config.Recipes)
    end

    for recipe, item in pairs(Config.Recipes) do
        handleAddRecipeToCurrentList(recipe, item)
    end
    if useDebug then
        print('^2[Done adding recipes for', currentTableType, ']^0')
    end
    return Recipes
end

local function setCraftingOpen(openCrafting, i)
    local craftingSkill = getCraftingSkill()
    local craftingLevel = getCraftingLevel()
    if not craftingSkill then craftingSkill = 0 end
    if openCrafting then
        local bps = cwCallback.await('cw-crafting:server:getBlueprints')
        Blueprints = bps
        if useDebug then
            print('Crafting was opened', openCrafting)
        end
        SetNuiFocus(openCrafting, openCrafting)
        currentTableType = i;
        StartScreenEffect('MenuMGIn', 1, true)
        SendNUIMessage({
            action = "cwCrafting",
            toggle = openCrafting,
            type = 'toggleUi',
            table = Config.CraftingTables[currentTableType],
            craftingSkill = craftingSkill,
            craftingLevel = craftingLevel
        })
    else
        SetNuiFocus(openCrafting, openCrafting)
        lastTableType = currentTableType
        currentTableType = nil;
        StopScreenEffect('MenuMGIn')
        SendNUIMessage({
            action = "cwCrafting",
            toggle = openCrafting,
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
        handleAnimation(Config.CraftingTables[currentTableType])
        triggerProgressBar('crafting', 'Crafting', craftTime, function()
            if Config.ReopenCraftingWhenFinished then
                setCraftingOpen(true, lastTableType)
            end
            TriggerServerEvent('cw-crafting:server:craftItem',recipe, item, CurrentAmount)
            stopAnimation()
            isCrafting = false
        end, function() -- Cancel
            stopAnimation()
            isCrafting = false
            notify('Canceled crafting', "error")
        end)
        return true
    else
        notify('You dont have the required items', "error")
        return false
    end
end

local function benchpermissions(jobTypes)
    local jobType = getPlayerJobType()
    if jobTypes[jobType] ~= nil then return true else return false end
end

RegisterNUICallback('attemptCrafting', function(recipe, cb)
    if isCrafting then
        notify("You're already crafting something", "error")
    else
        local currentRecipe = Config.Recipes[recipe.currentRecipe]
        CurrentAmount = recipe.craftingAmount
        if CurrentAmount == 0 then
            notify("You can't craft a batch of 0.", "error")
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

local function generateTableOptions(type, benchType, oxLib) 

    if Config.oxLib then
        return {
            {
                label = benchType.title,
                icon = "fas fa-wrench",
                gang = benchType.gang,
                job = benchType.job,
                onSelect = function()
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
        }
    else
        return {
            {
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
        }
    end
end

local function createTable(type, benchType)
    local options = {}
    options = generateTableOptions(type, benchType)

    if options and #options > 0 then 
        if benchType.objects then
            for j, benchProp in pairs(benchType.objects) do
                if Config.useOxTarget then
                    exports.ox_target:addModel(benchProp, options)
                else
                    exports['qb-target']:AddTargetModel(benchProp, {
                        options = options,
                        distance = 2.0
                    })
                end
            end
        end
        if benchType.locations then
            for j, benchLoc in pairs(benchType.locations) do
                if Config.useOxTarget then
                    exports.ox_target:addBoxZone({
                        coords = benchLoc,
                        size = vector3(1.5, 1.5, 1.5),
                        debug = useDebug,
                        drawSprite = useDebug,
                        options = options,
                    })
                else
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
                if Config.useOxTarget then
                    exports.ox_target:addLocalEntity(benchEntity, options)
                else
                    exports['qb-target']:AddTargetEntity(benchEntity, {
                        options = options,
                        distance = 2.0
                    })
                end

            end
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


RegisterNetEvent('cw-crafting:client:notify', function(message, type)
   notify(message, type)
end)

RegisterNetEvent('cw-crafting:client:toggleDebug', function(debug)
   notify('Toggling Crafting debug to', debug)
   useDebug = debug
end)

RegisterNetEvent('cw-rep:client:repWasUpdated', function(skills)
    if useDebug then notify('Rep was updated') print('new skills', json.encode(skills, {indent=true})) end
    local craftingSkill = getCraftingSkill()
    local craftingLevel = getCraftingLevel()
    Wait(1000)
    SendNUIMessage({
        action = "cwCrafting",
        type = 'updateCraftingSkill',
        craftingSkill = craftingSkill,
        craftingLevel = craftingLevel
    })
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
    triggerProgressBar('learnbp', 'Studying blueprint...', Config.LearningTime, function()
       return true
    end)
end)

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

local function loadModel(model)
    if type(model) == 'string' then model = GetHashKey(model) end
    while not HasModelLoaded(model) do
        RequestModel(model)
        Wait(10)
    end
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
    
            loadModel(dude.model)
            local currentDude = CreatePed(0, dude.model, dude.coords.x, dude.coords.y, dude.coords.z-1.0, dude.coords.w, false, false)
            TaskStartScenarioInPlace(currentDude,  animation)
            FreezeEntityPosition(currentDude, true)
            SetEntityInvincible(currentDude, true)
            SetBlockingOfNonTemporaryEvents(currentDude, true)
    
            if Config.useOxTarget then
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