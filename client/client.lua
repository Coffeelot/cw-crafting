local QBCore = exports['qb-core']:GetCoreObject()
local Recipes = {}
local Blueprints = {}
local CurrentAmount = 1
local currentTableType = nil
local ItemNames = {}
local useDebug = Config.Debug

local function getOxItems()
    if Config.Inventory == 'ox' then
        for items, datas in pairs(exports.ox_inventory:Items()) do
            ItemNames[items] = datas
        end
    end
end

AddEventHandler('onResourceStart', function(resource)
   if resource == GetCurrentResourceName() then
        getOxItems()
   end
end)

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    getOxItems()
    if Config.Inventory == 'ox' then
        exports.ox_inventory:displayMetadata("value", "Blueprint")
    end
end)

function dump(o)
   if type(o) == 'table' then
   local s = '{ '
   for k,v in pairs(o) do
      if type(k) ~= 'number' then k = '"'..k..'"' end
      s = s .. '['..k..'] = ' .. dump(v) .. ','
   end
   return s .. '} '
   else
   return tostring(o)
   end
end

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
            -- print('Does not have jobs', dump(item.jobs))
            return false
        end
    else
        -- print('No job requirement for', item.name )
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
        -- print('No blueprint requirement for', item.name)
        return nil
    end
end

local function validateAccess(item)
    local playerPassesJobReq = validateJob(item)
    local playerPassesBlueprintReq = validateBlueprints(item)

    if item.requireBlueprintAndJob == true then
        if useDebug then
            print(item.name.. ' requires both job and blueprint', playerPassesJobReq, playerPassesBlueprintReq)
        end
        return playerPassesJobReq and playerPassesBlueprintReq
    elseif item.blueprint ~= nil and item.jobs ~= nil then
        if useDebug then
           print(item.name.. ' can use either job or blueprint', playerPassesJobReq, playerPassesBlueprintReq)
        end
        return playerPassesJobReq or playerPassesBlueprintReq
    elseif item.blueprint ~= nil then
        if useDebug then
           print(item.name.. ' requires blueprint', playerPassesBlueprintReq)
        end
        return playerPassesBlueprintReq
    elseif item.jobs ~= nil then
        if useDebug then
           print(item.name.. ' requires job', playerPassesJobReq)
        end
        return playerPassesJobReq
    end
    if useDebug then
       print(item.name..' has no requirements')
    end
    return true
end

local function validateRights(item)
    local tables = {}
    if item.tables ~= nil then
        for i, table in pairs(item.tables) do
            tables[table] = table
        end
    else
        tables = { ['basic'] = 'basic' }
    end

    if (tables == nil or tables[currentTableType]) and tables[currentTableType] then -- no table reqirement and this is a basic table
        if useDebug then
            print('is basic table')
        end
        return validateAccess(item)
    end
    if useDebug then
        print('recipe did not match this table')
    end
    return false
end

local function canCraftItem(item)
    if useDebug then
       print('checking job')
    end
    if Config.Inventory == 'qb' then
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
    elseif Config.Inventory == 'ox' then
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

local function craftItem(item)
    if canCraftItem(item) then
        -- do emote here
        local craftTime = Config.DefaultCraftingTime*CurrentAmount
        if item.craftingTime then
            craftTime = item.craftingTime*CurrentAmount
        end
        local amount = 1
        if item.amount then
            amount = item.amount*CurrentAmount
        end
        TriggerEvent('animations:client:EmoteCommandStart', {"mechanic"})
        QBCore.Functions.Progressbar("crafting", "Crafting", craftTime , false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function()
            TriggerServerEvent('cw-crafting:server:craftItem', PlayerPedId(), item, CurrentAmount)
           --[[  print('item name', item.name) ]]
            if Config.Inventory == 'qb' then
                QBCore.Functions.Notify('You have crafted '..amount..' '.. QBCore.Shared.Items[item.name].label, "success")
            else
                QBCore.Functions.Notify('You have crafted '..amount..' '.. ItemNames[item.name].label, "success")
            end
            TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        end, function() -- Cancel
            TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            QBCore.Functions.Notify(Lang:t('error.canceled'), "error")
        end)
        return true
    else
        QBCore.Functions.Notify('You dont have the required items', "error", 2500)
    end
    return false
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
        local canCraft = validateRights(item)
        if canCraft then
            local materialsNameMap = {}
            if Config.Inventory == 'qb' then
                item.data = QBCore.Shared.Items[item.name]
                for mat, amount in pairs(item.materials) do
                    materialsNameMap[mat] = QBCore.Shared.Items[mat].label
                end
            elseif Config.Inventory == 'ox' then
                if useDebug then
                   print('name', item.materials)
                end
                item.data = ItemNames[item.name]
                for mat, amount in pairs(item.materials) do
                    materialsNameMap[mat] = ItemNames[mat].label
                end
            end
            item.materialsNameMap = materialsNameMap

            Recipes[recipe] = item
            if item.craftTime == nil then
                Recipes[recipe].craftTime = Config.DefaultCraftingTime
            end
            if useDebug then
                print('Has access to', item.name)
            end
        else
            if useDebug then
                print('Did not have access to', item.name)
            end
        end
        if useDebug then
            print("====================")
        end

    end
    return Recipes
end

local function setCraftingOpen(bool, i)
    local citizenId = QBCore.Functions.GetPlayerData().citizenid
    if useDebug then
        print('hhiehiehei', i)
    end
    QBCore.Functions.TriggerCallback('cw-crafting:server:getBlueprints', function(bps)
        Blueprints = bps
        if useDebug then
            print('Crafting was opened')
        end
        SetNuiFocus(bool, bool)
        if bool then
            currentTableType = i;
        else
            currentTableType = nil;
        end
        SendNUIMessage({
            action = "cwCrafting",
            toggle = bool
        })
    end)
end

local function benchpermissions(jobTypes)
    local Player = QBCore.Functions.GetPlayerData()
    if jobTypes[Player.job.type] ~= nil then return true else return false end
end

RegisterNUICallback('attemptCrafting', function(recipe, cb)
    local Player = QBCore.Functions.GetPlayerData()
    local currentRecipe = Config.Recipes[recipe.currentRecipe]
    CurrentAmount = recipe.craftingAmount
    if useDebug then
        print(recipe.currentRecipe, dump(currentRecipe))
    end
    local success = craftItem(currentRecipe)
    cb(success)
end)

RegisterNUICallback('getRecipes', function(data, cb)
    if useDebug then
       print('Fetching recipes')
    end
    getRecipes()
    cb(Recipes)
end)


RegisterNUICallback('closeCrafting', function(_, cb)
    if useDebug then
        print('Closing crafting')
    end
    setCraftingOpen(false)
    cb('ok')
end)

RegisterNUICallback('getInventory', function(_, cb)
    cb(Config.Inventory)
end)

--[[ RegisterCommand('openCrafting', function(source)
    if useDebug then
        print('Open crafting')
    end
    setCraftingOpen(true)
end)
 ]]

CreateThread(function()
    for i, benchType in pairs(Config.CraftingTables) do
        local options = {}
        options[1] = {
            type = 'client',
            label = benchType.title,
            icon = "fas fa-wrench",
            action = function()
                setCraftingOpen(true, i)
            end,
            canInteract = function()
                if benchType.jobType ~= nil then
                    return benchpermissions(benchType.jobType)
                else
                    return true
                end
            end,
        }

        for j, benchProp in pairs(benchType.objects) do
            exports['qb-target']:AddTargetModel(benchProp, {
                options = options,
                distance = 2.0
            })
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

    end
end)

-- RegisterCommand('testcraft', function(_, args)
-- 	craftItem(Config.Recipes[args[1]])
-- end)


RegisterNetEvent('cw-crafting:client:toggleDebug', function(debug)
   print('Setting debug to',debug)
   useDebug = debug
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
    if Config.Inventory == 'qb' then
        local bps = getAllBlueprints()
        for i,bp in pairs(bps) do
            if bp.info.value == input then
                return true
            end
        end
        return false
    elseif Config.Inventory == 'ox' then
        local blueprintItem = 'blueprint'

        local items = exports.ox_inventory:Search('count', blueprintItem, { value = input } )
        return items > 0
    end
end

local function generateBlueprintOptions(dude)
    local options = {}
    for name, blueprint in pairs(Config.Blueprints) do
        local dudeHasBlueprint = true
        if blueprint.type and dude.type and blueprint.type ~= dude.type then
            dudeHasBlueprint = false
        end
        if dudeHasBlueprint then
            options[#options+1] = {
                type = "server",
                event = "cw-crafting:server:addBlueprintFromLearning",
                bpName = name,
                icon = "fas fa-graduation-cap",
                gang = dude.gang,
                label = "Learn "..name,
                canInteract = function()
                    return hasBlueprint(name)
                end
            }
        end
    end
    return options
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
    
            local options = generateBlueprintOptions(dude)
            exports['qb-target']:AddTargetEntity(currentDude, {
                options = options,
                distance = 2.0
            })
        end
    end)
end