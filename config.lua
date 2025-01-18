Config = {}
Config.Debug = false

Config.oxInv = true -- set this to ox if you have ox_inventory

--  DISABLE OX LIB IN FXMANIFEST IF THIS IS FALSE:
Config.oxLib = true -- set this to ox if you have ox_lib !!! MAKE SURE OX LIB IS ADDED TO SHARED_SCRIPTS IN FXMANIFEST!!

Config.UseLocalImages = false -- set this to true if you want to use local images rather than automatic. Put the images for the recipes and ingredients in the 'images' folder next to the blueprint.png
Config.ReopenCraftingWhenFinished = false -- if true the script will re-open the crafting when it's done

Config.ItemName = "cw_blueprint" -- Name of the item in your items.lua
Config.PlayersTableName = 'characters' -- 'players' for qb/qbox, 'characters' for ox. Something else for esx probably
Config.PlayerDbIdentifier = 'stateId' -- 'citizenId' for qb/qbox, 'stateId' for ox, Something else for ex probably
Config.UseCWRepForCraftingSkill = false -- Set to true if you want to use cw-rep for skill instead of qbs metadata
-- The following all require cw-rep to be enabled:
Config.CraftingSkillName = 'crafting' -- Make sure this matches the crafting skill name in your cw-rep config
Config.CraftingSkillLabel = '"Crafting Skill"' -- Default name for the crafting skill
Config.UseLevelsInsteadOfSkill = false -- If true then cw-rep will use level instead of pure xp 
Config.DefaultMaxCraft = 10 -- Default max amount a player can craft at a time

Config.PrimaryUiColor = '#52d996' -- Primary color in UI, default is blue

local minimumSkillRep = 1 -- the least amount of skill you can gain per craft

-- You can tweak this function to return different amount of points per skill
-- The default one will give you 1 skill for a crafted item and the +1 for each 100 in skill requirement the item has. 
Config.CraftingRepGainFunction = function(skillReq, recipe)
	if recipe and recipe.customSkillGain then return recipe.customSkillGain end
	if not skillReq then return minimumSkillRep end
	
    local skillGain = 1 + math.floor((skillReq - 1) / 100)
	if skillGain < minimumSkillRep then return minimumSkillRep end
	if Config.Debug then print('Skill gain:', skillGain) end
	return skillGain
end


Config.Blueprints = { -- rarity is 1-5, chance is 0.0-1.0 with lower numbers lowering chance of getting the item
	['aluminumoxide_pro'] = { label="Aluminum Oxide Optimized", rarity = 3, type='legal' },
	['repairkit'] = { label="Repair Kit", rarity = 2,  type='legal' },
	['screwdriverset'] = { rarity = 2,  type='legal' },
	['electronickit'] = { rarity = 2,  type='legal' },
	['radioscanner'] = { rarity = 3, type='illegal' },
	['gatecrack'] = { rarity = 4,  type='illegal' },
	['armor'] = { rarity = 5, type='illegal'},
	['Ap Pistol'] = { rarity = 5, type='illegal' },
}

Config.DefaultFailChance = 80

Config.DefaultCraftingTime = 1000 -- in milliseconds
Config.LearningTime = 2500 -- time it takes to learn BP in milliseconds

Config.Recipes = {
	['lockpick'] = {
		category = "Tools",
		toItems = {
			lockpick = 2,
		},
		materials = { metalscrap = 12, plastic = 12 },
		craftingTime= 3000,
		craftingSkill= 10,
		customSkillGain = 5,
		keepMaterials = { plastic = true }
	},
	['breakdown_phone'] = {
		label = 'Breakdown phone',
		type = "breakdown",
		materials = {
			phone = 1
		},
		toItems = {
			aluminum = 14,
			glass = 21,
			plastic = 10
		},
		maxCraft = 10,
		category = 'Breakdown',
		craftingTime= 4000,
	},
	["weapon_appistol"] = {
		label = "AP Pistol",
		toItems = {
			WEAPON_APPISTOL = 1,
		},
		materials = {
			["metalscrap"] = 360,
		},
		category = 'Weapons',
		tables = {'guns'},
		blueprint = 'Ap Pistol',
		craftingSkill= 200,
		skillName = 'gun_crafting', -- optional. If set, will override what skill is required. ONLY WORKS WITH CW-REP!!!
		metadata = { registered= false } -- If set, will write info/metadata on item
	},
}


-- Search for more tables here, for example: https://gta-objects.xyz/objects
-- For icons see https://pictogrammers.com/library/mdi/
Config.CraftingTables = {
	['basic'] = {
		title = "Crafting",
		animation = { dict = 'anim@amb@business@coc@coc_unpack_cut@', anim = 'fullcut_cycle_v7_cokecutter'},
		objects = { 'ex_prop_ex_toolchest_01', 'prop_toolchest_04', 'prop_toolchest_05'}, 
		locations = {  vector3(939.4, -1554.36, 30.58), },
		skipPlaceObjectOnGroundProperly = true -- Defaults to false, if set to true then object wont be placed onto ground. Useful for placing items on tables etc
	},
	['mechanic'] = {
		title = "Mechanic Crafting",
		objects = { 'prop_toolchest_05' },
		icon = "car-wrench", -- optional. Defaults to 'wrench'
		jobType = { ['mechanic'] = 1 }, -- NOTE: This checks TYPES not name. A new qb thing. It's good. Use it.
		locations = { vector3(948.81, -1552.64, 30.59), }, -- BOXZONE: If you add one of these objects (locations = ...) it will spawn boxzones
		spawnTable = { { coords = vector4(794.49, -2613.63, 87.97, 2.4), prop = 'ex_prop_ex_toolchest_01' } } -- SPAWNS TABLE: the spawnTable field holds a list of several tables with prop and location. If these are added it will SPAWN a table that's interactable
	},
	['guns'] = {
		title = "Weapon Crafting",
		craftingLevelText = "Guns crafting level:",
		icon = "pistol",
		objects = { 'gr_prop_gr_bench_01a' }
	},
	['ballasguns'] = {
		title = "Weapon Crafting For Ballas",
		icon = "pistol",
		gang = "ballas",
		spawnTable = { { coords = vector4(100.52, -1968.95, 20.91, 352.84), prop='gr_prop_gr_bench_02a' }}
	},
}

Config.UseSundownUtils = false

Config.BlueprintDudes = { -- SET THIS TO Config.BlueprintDudes = nil TO DISABLE
	{
		model = 'cs_nigel',
		type = 'legal',
		coords = vector4(-1647.53, 248.17, 61.97, 118.29),
		animation = 'WORLD_HUMAN_SEAT_LEDGE_EATING',
	},
	{
		model = 'u_m_m_blane',
		type = 'illegal',
		coords = vector4(1641.73, 3731.21, 35.07, 6.15),
		animation = 'WORLD_HUMAN_DRINKING',
	}
}