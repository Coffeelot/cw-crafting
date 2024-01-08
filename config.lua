Config = {}
Config.Debug = false

Config.oxInv = true -- set this to ox if you have ox_inventory

Config.Blueprints = { -- rarity is 1-5, chance is 0.0-1.0 with lower numbers lowering chance of getting the item
	['aluminumoxide_pro'] = { rarity = 3, chance = 30 },
	['repairkit'] = { rarity = 2, chance = 40 },
	['screwdriverset'] = { rarity = 2, chance = 50 },
	['electronickit'] = { rarity = 2, chance = 30 },
	['radioscanner'] = { rarity = 3, chance = 5 },
	['gatecrack'] = { rarity = 4, chance = 20 },
	['handcuffs'] = { },
	['armor'] = { rarity = 5, chance = 5 },
	['Ap Pistol'] = { rarity = 5, chance = 1 },
}

Config.DefaultFailChance = 80

Config.DefaultCraftingTime = 1000 -- in milliseconds

Config.Recipes = {
	['lockpick'] = {
		category = "Tools",
		toItems = {
			lockpick = 2,
		},
		materials = { metalscrap = 12, plastic = 12 },
		craftingTime= 3000,
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
		metadata = {registered= false} -- If set, will write info/metadata on item
	},
}


-- Search for more tables here, for example: https://gta-objects.xyz/objects
-- For icons see https://pictogrammers.com/library/mdi/
Config.CraftingTables = {
	['basic'] = {
		title = "Crafting",
		objects = { 'ex_prop_ex_toolchest_01', 'prop_toolchest_04', 'prop_toolchest_05'}, 
		locations = {  vector3(939.4, -1554.36, 30.58), }
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
		icon = "pistol",
		objects = { 'gr_prop_gr_bench_01a' }
	},
}

Config.UseSundownUtils = false

Config.BlueprintDudes = { -- SET THIS TO Config.BlueprintDudes = nil TO DISABLE
	{
		model = 'cs_nigel',
		coords = vector4(-1647.53, 248.17, 61.97, 118.29),
		animation = 'WORLD_HUMAN_SEAT_LEDGE_EATING',
	},
	{
		model = 'u_m_m_blane',
		coords = vector4(1641.73, 3731.21, 35.07, 6.15),
		animation = 'WORLD_HUMAN_DRINKING',
	}
}