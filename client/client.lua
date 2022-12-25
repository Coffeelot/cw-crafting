QBCore =  exports['qb-core']:GetCoreObject()
local Recipies = {}
local Blueprints = {}
local CurrentAmount = 1
local currentTableType = nil
local ItemNames = {}
local useDebug = Config.Debug

local function callitems()
    if Config.Inventory == 'ox' then
        for items, datas in pairs(exports.ox_inventory:Items()) do
            ItemNames[items] = datas
            print(ItemNames[items])
        end
    end
end

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

        local jobName = Player.job.name
        local jobLevel = Player.job.grade.level

        local playerHasJob = false
        local levelRequirement = nil
        for i, job in pairs(item.jobs) do
            if job.name == jobName then
                playerHasJob = true
                levelRequirement = job.level
            end
        end

        if playerHasJob then
            if levelRequirement ~= nil then
                if Player.job.grade.level >= levelRequirement then
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
        print('recipie did not match this table')
    end
    return false
end

local function canCraftItem(item)
    if useDebug then
       print('checking job')
    end
    if Config.Inventory == 'qb' then
        for material, amount in pairs(item.materials) do
            if useDebug then
               print(amount*CurrentAmount, material)
            end
            local hasItem = QBCore.Functions.HasItem(material, amount*CurrentAmount)
            if useDebug then
               print('hasitem', hasItem)
            end
            if not hasItem then
                return false
            end
            return true
        end
    elseif Config.Inventory == 'ox' then
        if useDebug then
           print(QBCore.Debug(item))
        end
        local craft = true
        for material, amount in pairs(item.materials) do
            local count = 0
            local recipe = exports.ox_inventory:Search('slots', material)
                for k, ingredients in pairs(recipe) do
                    if ingredients.metadata.degrade >= 1 then
                        count = count + ingredients.count
                    else
                        QBCore.Functions.Notify("Items are Bad Quality", 'error', 5000)
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
        callitems()
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

local function getRecipies()
    if useDebug then
       print('generating recipies for table', currentTableType)
    end
    Recipies = {}
    callitems()
    if useDebug then
       print('Amount of recipies: ',#Config.Recipies)
    end

    for recipie, item in pairs(Config.Recipies) do
--[[         if useDebug then
           print('checking recpie', recipie)
        end
        print('validating', item.name) ]]
        local canCraft = validateRights(item)
        if canCraft then
            if Config.Inventory == 'qb' then
                item.data = QBCore.Shared.Items[item.name]
            elseif Config.Inventory == 'ox' then
                item.data = ItemNames[item.name]
            end
            Recipies[recipie] = item
            if item.craftTime == nil then
                Recipies[recipie].craftTime = Config.DefaultCraftingTime
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
    return Recipies
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
            TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        end
        SendNUIMessage({
            action = "cwCrafting",
            toggle = bool
        })
    end)
end


RegisterNUICallback('attemptCrafting', function(recipie, cb)
    local Player = QBCore.Functions.GetPlayerData()
    local currentRecipie = Config.Recipies[recipie.currentRecipie]
    CurrentAmount = recipie.craftingAmount
    if useDebug then
        print(recipie.currentRecipie, dump(currentRecipie))
    end
    local success = craftItem(currentRecipie)
    cb(success)
end)

RegisterNUICallback('getRecipies', function(data, cb)
    if useDebug then
       print('Fetching recipies')
    end
    getRecipies()
    cb(Recipies)
end)


RegisterNUICallback('closeCrafting', function(_, cb)
    if useDebug then
        print('Closing crafting')
    end
    setCraftingOpen(false)
    cb('ok')
end)


RegisterCommand('openCrafting', function(source)
    if useDebug then
        print('Open crafting')
    end
    setCraftingOpen(true)
end)


CreateThread(function()
    for i, benchType in pairs(Config.CraftingTables) do
        local options = {}
        options[1] = {
            type = 'client',
            label = benchType.title,
            action = function()
                setCraftingOpen(true, i)
            end,
        }

        for j, benchProp in pairs(benchType) do
            exports['qb-target']:AddTargetModel(benchProp, {
                options = options,
                distance = 2.0
            })
        end

    end
end)

RegisterCommand('testcraft', function(_, args)
	craftItem(Config.Recipies[args[1]])
end)


RegisterNetEvent('cw-crafting:client:toggleDebug', function(debug)
   print('Setting debug to',debug)
   useDebug = debug
end)