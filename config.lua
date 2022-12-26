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

Config.Recipies = {
	['aluminumoxide'] = { -- example of a very basic recipie. 
		name = 'aluminumoxide', -- this needs to correlate to an item
		category = "Materials", -- this will be the category the recipie is under
		materials = { -- materials used to craft
			["aluminum"] = 60,
			["glass"] = 30,
		}, 
	},
	['aluminumoxide_pro'] = { -- example of a recipie that is a "pro" version, unlockable through blueprints
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
	['repairkit'] = { -- example of a recipie that can be aquired by having the correct job OR the blueprint 
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
	['advancedrepairkit'] = { -- example of a recipie that requires BOTH job and blueprint to access
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
	['ironoxide'] = { -- example of a very basic recipie. 
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
}

Config.CraftingTables = {
	basic = { 'ex_prop_ex_toolchest_01', 'gr_prop_gr_tool_chest_01a', 'gr_prop_gr_tool_draw_01a', 'gr_prop_gr_tool_draw_01b', 'prop_toolchest_04'},
	illegal = { 'gr_prop_gr_bench_04a' }
}

Config.CraftingTables = {
	basic = { 
		title = "Open crafting",
		objects = { 'ex_prop_ex_toolchest_01', 'gr_prop_gr_tool_chest_01a', 'gr_prop_gr_tool_draw_01a', 'gr_prop_gr_tool_draw_01b', 'prop_toolchest_04' }
	},
	mechanic = {
		title = "Open mechanic crafting",
		objects = { 'gr_prop_gr_bench_04a' }
	},
	guns = {
		title = "Open gun crafting",
		objects = { 'gr_prop_gr_bench_04a' }
	},
}