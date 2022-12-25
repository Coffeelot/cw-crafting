QBCore =  exports['qb-core']:GetCoreObject()
local Recipies = {}
local Blueprints = {}
local currentTableType = nil

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
            print(blueprint, item.blueprint, blueprint == item.blueprint)
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
    if playerPassesBlueprintReq then
        return true
    end
    if playerPassesJobReq == nil and playerPassesBlueprintReq == nil then
        print('the recipie is base')
        return true
    elseif playerPassesJobReq == nil then
        print('the recipie does not require job')
        return playerPassesBlueprintReq
    elseif playerPassesBlueprintReq == nil then
        print('the recipie does not require Blueprints')
        return playerPassesJobReq
    end
    return playerPassesJobReq and playerPassesBlueprintReq
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
    print(dump(tables), currentTableType)

    if (tables == nil or tables[currentTableType]) and tables[currentTableType] then -- no table reqirement and this is a basic table
        print('is basic table')
        return validateAccess(item)
    end
    
    print('recipie did not match this table')
    return false
end

local function canCraftItem(item)
    print('checking job')
    if Config.Inventory == 'qb' then
        for material, amount in pairs(item.materials) do
            -- print(amount, material)
            local hasItem = QBCore.Functions.HasItem(material, amount)
            -- print('hasitem', hasItem)
            if not hasItem then
                return false
            end
        end
    else 
        -- ADD ox inv here
    end
    return true        
end

local function craftItem(item)
    if canCraftItem(item) then
        -- do emote here
        local craftTime = Config.DefaultCraftingTime
        if item.craftingTime then
            craftTime = item.craftingTime
        end
        local amount = 1
        if item.amount then
            amount = item.amount
        end
        TriggerEvent('animations:client:EmoteCommandStart', {"mechanic"})
        QBCore.Functions.Progressbar("crafting", "Crafting", craftTime , false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function()
            TriggerServerEvent('cw-crafting:server:craftItem', item)
            print('item name', item.name)
            QBCore.Functions.Notify('You have crafted '..amount..' '.. QBCore.Shared.Items[item.name].label, "success")
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
    print('generating recipies for table', currentTableType)
    Recipies = {}
    if Config.Debug then
       print('Amount of recipies: ',#Config.Recipies)
    end

    for recipie, item in pairs(Config.Recipies) do
        if Config.Debug then
           print('checking recpie', recipie)
        end
        print('validating', item.name)
        local canCraft = validateRights(item)
        if canCraft then
            if Config.Inventory == 'qb' then
                item.data = QBCore.Shared.Items[item.name]
            else
                -- ADD ox inv here
            end
            Recipies[recipie] = item
            if item.craftTime == nil then
                Recipies[recipie].craftTime = Config.DefaultCraftingTime
            end
            print('Has access to', item.name)
        else
            print('Did not have access to', item.name)
        end
        print("====================")

    end
    return Recipies
end

local function setCraftingOpen(bool, i)
    local citizenId = QBCore.Functions.GetPlayerData().citizenid
    print('hhiehiehei', i)
    QBCore.Functions.TriggerCallback('cw-crafting:server:getBlueprints', function(bps)
        Blueprints = bps
        if Config.Debug then
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
    local currentRecipie = Config.Recipies[recipie]
    print(recipie, dump(currentRecipie))
    local success = craftItem(currentRecipie)
    cb(success)
end)

RegisterNUICallback('getRecipies', function(data, cb)
    print('Fetching recipies')
    getRecipies()
    cb(Recipies)
end)


RegisterNUICallback('closeCrafting', function(_, cb)
    print('Closing crafting')
    setCraftingOpen(false)
    cb('ok')
end)


RegisterCommand('openCrafting', function(source)
    print('Open crafting')
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
