Config = {}
Config.Debug = false

Config.Inventory = 'qb' -- set this to ox if you have ox_inventory

Config.Blueprints = { -- rarity is 1-5, chance is 0.0-1.0 with lower numbers lowering chance of getting the item
	['lockpicks'] = { rarity = 1, chance = 70 },
	['aluminumoxide_pro'] = { rarity = 3, chance = 30 },
	['repairkit'] = { rarity = 2, chance = 40 },
	['screwdriverset'] = { rarity = 2, chance = 50 },
	['electronickit'] = { rarity = 2, chance = 30 },
	['radioscanner'] = { rarity = 3, chance = 5 },
	['gatecrack'] = { rarity = 4, chance = 20 },
	['handcuffs'] = { },
	['armor'] = { rarity = 5, chance = 5 },
}

Config.DefaultFailChance = 80

Config.DefaultCraftingTime = 1000 -- in milliseconds

Config.Recipes = {
	['aluminumoxide'] = { -- example of a very basic recipe. 
		name = 'aluminumoxide', -- this needs to correlate to an item
		category = "Materials", -- this will be the category the recipe is under
		materials = { -- materials used to craft
			["aluminum"] = 60,
			["glass"] = 30,
		}, 
	},
	['aluminumoxide_pro'] = { -- example of a recipe that is a "pro" version, unlockable through blueprints
		name = 'aluminumoxide',
		category = "Materials",
		materials = { 
			["aluminum"] = 180,
			["glass"] = 90,
		}, 
		amount = 5, 
		craftTime = 5000, 
		blueprint = 'aluminumoxide_pro'
	},
	['repairkit'] = { -- example of a recipe that can be aquired by having the correct job OR the blueprint 
		name = 'repairkit', 
		craftTime= 4000, 
		category = "Mechanic", 
		materials = { 
            ["metalscrap"] = 32,
            ["steel"] = 43,
            ["plastic"] = 61,
		}, 
		jobs = { 
			{ name = 'mechanic', level = 2 }
	 	},
		blueprint = 'repairkit',
		tables = {'mechanic', 'basic'} -- can be made on both mechanic and basic tables
	},
	['advancedrepairkit'] = { -- example of a recipe that requires BOTH job and blueprint to access
		name = 'advancedrepairkit', 
		craftTime= 7000, 
		category = "Mechanic", 
		materials = { 
			aluminum = 10, 
			steel = 3, 
			plastic = 4, 
			rubber = 2 
		}, 
		jobs = { 
			{ name = 'mechanic', level = 2 } 
	 	},
		blueprint = 'coolthing',
		requireBlueprintAndJob = true, -- this is needed to say BOTH are required
		tables = {'mechanic'} -- can be made on only mechanic tables
	},
	['lockpick'] = { 
		name= 'lockpick', 
		category = "Illegal", 
		materials = { metalscrap = 22, plastic = 32 }, 
		amount = 5, 
		blueprint = 'lockpicks', 
		illegal = true 
	},
	['screwdriverset'] = { 
		name= 'screwdriverset',
		category = "Tools", 
		materials = { metalscrap = 22, plastic = 32 }, 
		amount = 1, 
		blueprint = 'screwdriverset', 
	},
	["electronickit"] = {
        name = "electronickit",
		category = "Tools", 
        materials = {
            metalscrap = 30,
            plastic = 45,
            aluminum = 28,
        },
		blueprint = 'screwdriverset', 
    },
	["radioscanner"] = {
        name = "radioscanner",
		category = "Tools", 
        materials = {
            electronickit = 2,
            plastic = 52,
            steel = 40,
        },
		blueprint = 'radioscanner', 
    },
	["gatecrack"] = {
        name = "gatecrack",
		category = "Tools", 
        materials = {
            ["metalscrap"] = 10,
            ["plastic"] = 50,
            ["aluminum"] = 30,
            ["iron"] = 17,
            ["electronickit"] = 2,
        },
		blueprint = 'gatecrack', 
    },
	["drill"] = {
        name = "drill",
		category = "Tools", 
        materials = {
            ["iron"] = 50,
            ["steel"] = 50,
            ["screwdriverset"] = 3,
            ["advancedlockpick"] = 2
        },
		craftTime= 4000,
		blueprint = 'drill',
    },
	["handcuffs"] = {
        name = "handcuffs",
		category = "Gear", 
        materials = {
            ["metalscrap"] = 36,
            ["steel"] = 24,
            ["aluminum"] = 28,
        },
		blueprint = 'handcuffs',
		jobs = { 
			{ name = 'police', level = 2 } 
	 	},
    },
	['ironoxide'] = { -- example of a very basic recipe. 
		name = 'ironoxide',
		category = "Materials", 
		materials = {
			["iron"] = 60,
			["glass"] = 30,
		},
	},
	["armor"] = {
        name = "armor",
		category = "Gear", 
        materials = {
            ["iron"] = 33,
            ["steel"] = 44,
            ["plastic"] = 55,
            ["aluminum"] = 22,
        },
		craftTime= 4000,
		blueprint = 'armor',
		tables = {'guns'}
    },
	-- I got lazy here so these wont have blueprints by defaultlmao sorry deal with it
	["pistol_extendedclip"] = {
		name = "pistol_extendedclip",
		materials = {
			["metalscrap"] = 140,
			["steel"] = 250,
			["rubber"] = 60,
		},
		category = 'Weapon Attachments',
		tables = {'guns'}
	},
	["pistol_suppressor"] = {
		name = "pistol_suppressor",
		materials = {
			["metalscrap"] = 165,
			["steel"] = 285,
			["rubber"] = 75,
		},
		category = 'Weapon Attachments',
		tables = {'guns'}
	},
	["smg_extendedclip"] = {
		name = "smg_extendedclip",
		materials = {
			["metalscrap"] = 190,
			["steel"] = 305,
			["rubber"] = 85,
		},
		category = 'Weapon Attachments',
		tables = {'guns'}
	},
	["microsmg_extendedclip"] = {
		name = "microsmg_extendedclip",
		materials = {
			["metalscrap"] = 205,
			["steel"] = 340,
			["rubber"] = 110,
		},
		category = 'Weapon Attachments',
		tables = {'guns'}
	},
	["smg_drum"] = {
		name = "smg_drum",
		materials = {
			["metalscrap"] = 230,
			["steel"] = 365,
			["rubber"] = 130,
		},
		category = 'Weapon Attachments',
		tables = {'guns'}
	},
	["smg_scope"] = {
		name = "smg_scope",
		materials = {
			["metalscrap"] = 255,
			["steel"] = 390,
			["rubber"] = 145,
		},
		category = 'Weapon Attachments',
		tables = {'guns'}
	},
	["assaultrifle_extendedclip"] = {
		name = "assaultrifle_extendedclip",
		materials = {
			["metalscrap"] = 270,
			["steel"] = 435,
			["rubber"] = 155,
			["smg_extendedclip"] = 1,
		},
		category = 'Weapon Attachments',
		tables = {'guns'}
	},
	["assaultrifle_drum"] = {
		name = "assaultrifle_drum",
		materials = {
			["metalscrap"] = 300,
			["steel"] = 469,
			["rubber"] = 170,
			["smg_extendedclip"] = 2,
		},
		category = 'Weapon Attachments',
		tables = {'guns'}
	},
}


-- Search for more tables here, for example: https://gta-objects.xyz/objects
Config.CraftingTables = {
	['basic'] = {
		title = "Crafting",
		objects = { 'ex_prop_ex_toolchest_01', 'prop_toolchest_04', 'prop_toolchest_05'}, 
		locations = {  vector3(939.4, -1554.36, 30.58), }
	},
	['mechanic'] = {
		title = "Mechanic Crafting",
		objects = { 'prop_toolchest_05' },
		jobType = { ['mechanic'] = 1 }, -- NOTE: This checks TYPES not name. A new qb thing. It's good. Use it.
		locations = { vector3(948.81, -1552.64, 30.59), } -- If you add one of these objects (locations = ...) it will spawn boxzones
	},
	['guns'] = {
		title = "Weapon Crafting",
		objects = { 'gr_prop_gr_bench_01a' }
	},
}

