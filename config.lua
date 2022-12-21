Config = {}

Config.Inventory = 'qb'
Config.Blueprints = {
	['lockpicks'] = { },
}

Config.DefaultCraftingTime = 1000

Config.Recipies = {
	['aluminumoxide'] = { name = 'aluminumoxide', category = "Materials", materials = { aluminum = 1 }, amount = 10, craftingTime = 500},
	['repairkit'] = { name = 'repairkit', craftTime= 4000, category = "Mechanic",  materials = { aluminum = 4, steel = 2, plastic = 1, rubber = 1 }, jobs = { { name = 'mechanic', level = 2 } } },
	['lockpick'] = { name= 'lockpick', category = "Illegal", materials = { steel = 2 }, amount = 5, blueprint = 'lockpicks', illegal = true }
}

Config.CraftingTables = {
	basic = { 'ex_prop_ex_toolchest_01', 'gr_prop_gr_tool_chest_01a', 'gr_prop_gr_tool_draw_01a', 'gr_prop_gr_tool_draw_01b', 'prop_toolchest_04'},
	illegal = { 'gr_prop_gr_bench_04a' }
}