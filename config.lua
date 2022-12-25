Config = {}
Config.Debug = false

Config.Inventory = 'qb'
Config.Blueprints = {
	['lockpicks'] = { },
	['aluminumoxide_pro'] = { },
	['repairkit'] = { },
}

Config.DefaultCraftingTime = 1000

Config.Recipies = {
	['aluminumoxide_pro'] = { 
		name = 'aluminumoxide',
		category = "Materials",
		materials = { aluminum = 3 }, 
		amount = 50, 
		craftTime = 5000, 
		blueprint = 'aluminumoxide_pro'
	},
	['aluminumoxide'] = { 
		name = 'aluminumoxide',
		category = "Materials", 
		materials = { aluminum = 1 }, 
		amount = 10
	},	
	['repairkit'] = { 
		name = 'repairkit', 
		craftTime= 4000, 
		category = "Mechanic", 
		materials = { 
			aluminum = 4, 
			steel = 2, 
			plastic = 1, 
			rubber = 1 
		}, 
		jobs = { 
			{ name = 'mechanic', level = 2 }
	 	},
		blueprint = 'repairkit',
		tables = {'mechanic', 'basic'} -- can be made on both mechanic and basic tables
	},
	['advancedrepairkit'] = {
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
		requireBlueprintAndJob = true,
		tables = {'mechanic'} -- can be made on only mechanic tables
	},
	['lockpick'] = { 
		name= 'lockpick', 
		category = "Illegal", 
		materials = { steel = 2 }, 
		amount = 5, 
		blueprint = 'lockpicks', 
		illegal = true 
	}
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