# Crafting 🔧
### ⭐ Check out our [Tebex store](https://cw-scripts.tebex.io/category/2523396) for some cheap scripts ⭐
We hated the idea of the crafting grind, so we made a crafting script that's focused on blueprints that can be aquired from loot or by having the correct job.

Blueprints are items that have a unique value tied to them. By default you have to find one of the blueprint trainers to teach you a blueprint. These are found at the bottom of the Config file. You can disable them to make blueprints usable to learn the reciepe instead. Reciepes can also be tied to jobs, or both jobs and blueprints! The config holds a lot of comments to help you create your own recipes, crafting benches and blueprints!

> Now also supports crafting skill using [cw-rep](https://github.com/Coffeelot/cw-rep/)! (might be biased here, but it's much better than using qbcores metadata)

### ❗❗ YOU CAN NOT SPAWN BLUEPRINT ITEMS WITH /giveitem OR ANY MENU! SEE COMMANDS ❗❗

Cw-crafting now supports QBOX, OX-core,QB-core and (possibly) ESX (as long as you use OX inventory) CW-rep is required for skill/rep use with OX and ESX

### THIS SCRIPT REQUIRES YOU TO READ THIS README AND GO THROUGH THE CONFIG. READ THROUGH IT WELL BEFORE YOU ASK QUESTIONS 🐱‍🐉

# Images
![ui](https://media.discordapp.net/attachments/1202695794537537568/1330247358507913287/image.png?ex=678d48e5&is=678bf765&hm=5314d122eaa7871f2dc943fb3cce8013ed86d08b44520002ba423fbda7ed41bb&=&format=webp&quality=lossless&width=804&height=197)
![crafting open](https://media.discordapp.net/attachments/1202695794537537568/1330247383124279326/image.png?ex=678d48ea&is=678bf76a&hm=db6783459e681c12bd8c60eb871c7b9b45e29227a1376b141b1f2e58f49d960a&=&format=webp&quality=lossless&width=804&height=430)
![filter](https://media.discordapp.net/attachments/1202695794537537568/1330247411930497084/image.png?ex=678d48f1&is=678bf771&hm=7a80fd1d2ecab968ed65cdd2c2b5712109f76f507df27b9a1e5e4d9f7172a919&=&format=webp&quality=lossless&width=804&height=192)

# Youtube Preview 📽
## Initial release video
[![YOUTUBE VIDEO](http://img.youtube.com/vi/NVUlgIOcvbU/0.jpg)](https://youtu.be/NVUlgIOcvbU)

## UI update video
[![YOUTUBE VIDEO](http://img.youtube.com/vi/IzgkVJ3RzDc/0.jpg)](https://youtu.be/IzgkVJ3RzDc)

# Features
- Blueprint based crafting
- Easy addition of new recipes
- Exports to give blueprints (through loot for example)
- A UI made in VUE
- Support for OX and QB inventory with limited support for other inventories (through QB)
- Crafting skill reqirements

# Developed by Coffeelot and Wuggie
[More scripts by us](https://github.com/stars/Coffeelot/lists/cw-scripts)  👈

**Support, updates and script previews**:

<a href="https://discord.gg/FJY4mtjaKr"> <img src="https://media.discordapp.net/attachments/1202695794537537568/1285652389080334337/discord.png?ex=66eb0c97&is=66e9bb17&hm=b1b2c17715f169f57cf646bb9785b0bf833b2e4037ef47609100ec8e902371df&=&format=webp" width="200"></a>

[![Buy Us a Coffee](https://www.buymeacoffee.com/assets/img/guidelines/download-assets-sm-2.svg)](https://www.buymeacoffee.com/cwscriptbois )
# Setup 🔧
## Add the blueprint item
### QB
Items to add to qb-core>shared>items.lua 
```lua
	-- CW crafting
	["cw_blueprint"] =          {["name"] = "blueprint",         ["label"] = "Blueprint",                  ["weight"] = 1, ["type"] = "item", ["image"] = "blueprint.png", ["unique"] = true, ["useable"] = true, ['shouldClose'] = true, ["combinable"] = nil, ["description"] = "A blueprint for a crafting item"},
```
Also make sure the images are in qb-inventory>html>images

### Ox
```lua
	['cw_blueprint'] = {
		label = 'Blueprint',
		weight = 1,
		close = true,
		allowArmed = true,
		stack = false,
	},
```

> A common issue here is that another script has the "cw_blueprint" name. If so, make sure to rename either this blueprint item or the other one and update all code.

## Make your recipe values show in qb inventory (optional)
> This step is not needed if you use ox inventory

To make it show item value in qb-inventory add this in app.js somewhere in the `FormatItemInfo` function (look for similar `else if` statements)
```
        else if (itemData.name == "blueprint") {
            $(".item-info-title").html("<p>" + itemData.label + "</p>");
            $(".item-info-description").html("<p> Recipe for: "+ itemData.info.value + "</p>");
        }
```

## (If you use QBOX): uncomment the QBX line in fxmanifest

## Adding Blueprints to loot
There are two server side exports for this script. You can either randomize the blueprints (chance is based of what's in the config):

### Randomize
```lua
exports['cw-crafting']:giveRandomBlueprint(source, rarity, failChance)
```
`rarity` can either be a max (ei just a number) or a table holding a span (`{ min: 2, max: 4}`)
`failChance` is a number between 1-1000 with the chance to fail. For example, if you set this to 900 it's a 90% chance you do NOT get the blueprint

**Example use:** 
```sql
exports['cw-crafting']:giveRandomBlueprint(source, {min = 1, max = 2}, 990)
```
this will give the player a blueprint of rarity 1-2, with a 99% fail chance

> Only blueprints that have been added to `Config.Blueprints` in the `Config.Lua` file will be randomized from!
### Specific
```lua
exports['cw-crafting']:giveBlueprintItem(source, blueprintValue)
```

You'll want to add these to server side loot distribution of any script you think could benefit from having a chance to give out blueprints.

**Example use:**
```lua
exports['cw-crafting']:giveBlueprintItem(source, 'repairkit')
```

## Creating new crafting tables
All you gotta do is go into the `Config.Lua`, head to the bottom and you'll find the Tables. You can add a table her,  in the same style as the existing ones. So say you wanted to add a "kitchen" table, it'd look like this:
```lua
kitchen = {
        title = "Open kitchen",
		animation = { dict = 'anim@amb@business@coc@coc_unpack_cut@', anim = 'fullcut_cycle_v7_cokecutter'}, -- define custom animations for this table with the animation prop (optional)
		icon = "food-fork-drink", -- icon for the crafting menu, uses Material Desgin Icons https://pictogrammers.com/library/mdi/ (optional)
		job = 'hotdogs', -- job name. Works same as qb target so you can use a table with ranks also (I think?) (optional)
		jobType = { ['food'] = 1 }, -- NOTE: This checks TYPES not name. A new qb thing. Means you can have one type for several jobs (optional)
		gang = 'hotdoggang', -- gang name. Works same as qb target so you can use a table with ranks also (I think?) (optional)
        objects = { 'gr_prop_gr_hobo_stove_01' }, -- providing this will make ALL objects of this variant a table, can include multiple (leave empty if this is not what you want, ei objects = {})
		locations = {  vector3(-165.14, -984.55, 254.22), }, -- spawn at these locations (optional)
		spawnTable = { { coords = vector4(794.49, -2613.63, 87.97, 2.4), prop = 'gr_prop_gr_hobo_stove_01' } }, -- List of several tables with prop and location. If these are added it will SPAWN a table that's interactable (optional)
		skipPlaceObjectOnGroundProperly = true -- If this is set to true then the object wont be placed onto ground via Native. Good for placing things on tables for example (optional)
    },
```
> Note: The example above has ALL the cration types, which obviously might not be optimal. Use one or more, to fit your needs.

Now you got a new table! To fill it with items all you need to do is add `"tables = {'kitchen'}"`  to your recipes. You can see examples of these in the Recipes object. If you check the Recipes at the top they have comments explaining the different fields

### Creating tables from other scripts
With this export you can create tables from other scripts. The `table` input is the exact same as how tables are defined in the Config, just like above ☝, and the name is a string that identifies the table for your recipes

```lua
	exports['cw-crafting']:createTable('name', table)
```

For example, if you wanted to create a table that has cooking on it:
```lua
	local table = {
		title = "Kitchen",
		icon = "stove",
		spawnTable = { { coords = vector4(743.47, -704.91, 49.14, 267.64), prop = 'prop_pizza_oven_01' } }
	},
	exports['cw-crafting']:createTable('kitchen', table)

```


## Creating recipes
As of the new update, we no longer provide the base QB recipies (since so many people refuse to read instructions and update them to fit their server before reporting errors). The recipies have also been updated to be more aligned to make them more easier to manage. The name needs to be unique.

Example recipe:
```lua
['lockpick'] = {
		category = "Tools", -- category 
		toItems = { -- table that includes the output and their amounts, this one will output 2 lockpicks
			lockpick = 2,
		},
		type = nil -- type of recipe. This is used to display breakdown recipes correctly for example. Valid values: nil or 'breakdown' 
		materials = { -- table that includes the input and their material cost
            metalscrap = 12,
            plastic = 12 
        },
        label = 'Lockpicks' -- label that shows in crafting menu, will default to item in toItems (if 1) or the recipe name (in this case 'lockpick') otherwise (optional, higly suggested)
		craftingSkill= 10, -- crafting skill required to craft this. Defaults to 0 if unset (optional)
		skillName='lockpick_crafting' -- Will override the default skill type with this one instead. Needs cw-rep to work (optional)
		craftingTime= 3000, -- crafting time (optional)
        blueprint = 'Lockpick', -- blueprint name. Case sensitive to the blueprint name! (optional)
		requireBlueprintAndJob = true -- if this is set then BOTH job and blueprint are required (optional, default is false)
		maxCraft = 20, -- the max amount you can craft in one batch (optional) 
        jobs = { -- table of job requirements (optional)
			{ type = 'mechanic', level = 2 }, -- example of a job using TYPE rather than name
			{ name = 'police', level = 2 } -- example of a job using specific names
	 	},
		tables = {'mechanic', 'police'}, -- specific tables this recipe can be made at
        metadata = { color = 'orange'}, -- metadata of item NOTE:this will apply to ALL items in toItems, so it's reccomended to only use one item output per recipe when you want metadata  (optional) 
		customSkillGain = 20 -- Overrides the skill gain with this value instead
		keepMaterials = { metalscrap = true } -- This will make it so that the recipe does not use up these items. Needs to match one in "materials". A toolbox icon will show in the UI on non-consumed materials
	}
```

> So if you only want a recipe to use jobs, don't include `blueprint` and vice versa. If both are included then either or will allow users to access the recipe, if `requireBlueprintAndJob` is set then it will require both.

### Creating recipes from other scripts
With this export you can create recipes from other scripts. The `recipe` input is the exact same as how recipes are defined in the Config, just like above ☝, and the name is a string that identifies the recipes. The name needs to be unique.

```lua
	exports['cw-crafting']:addRecipe('name', recipe)
```

For example, if you wanted to add a recipe for a sandwich at your kitchen:
```lua
	local recipe = {
		toItems = {
			sandwich = 1,
		},
		materials = {
			["bread"] = 2,
			["chicken_meat"] = 1,
			["lettuce"] = 1,
		},
		category = 'Sandwiches',
		tables = {'kitchen'},
	},
	exports['cw-crafting']:addRecipe('sandwich', recipe)

```
> Obviously don't just paste this in your code unless you have all those materials, or you're kinda dumb.

## Creating blueprints
Example blueprint:
```lua
	['aluminumoxide_pro'] = { 
		label="Aluminum Oxide Optimized", -- label of recipe that's shown (might only work for ox? I dunno)
		rarity = 3,  -- rarity level. Used for randomization.
		type='legal' -- defines what blueprint teacher teaches this. Needs to match type of teacher in Config.BlueprintDude
	},
```
> NOTE: Highly recommend setting maxCraft to 1 for legal weapons as the system that creates serials might not support multi-creation of the items

# Blueprints and BlueprintDudes
At the bottom of the config you'll find the BlueprintDudes. If you don't want this just remove them. If they are removed, you can learn recipes via using the blueprints when they are in your inventory.
If the dudes and recipes have matching types, they can teach you them. 

## Using an inventory that is not OX or QB?
You'll want to set `UseLocalImages` to true in the config and copy over all the images of the recipe items and ingredients to the images folder

# Want to change the look?
Crafting is now built in VUE, this means you can't just edit the files directly. This requires some more know-how than just developing with basic html/js. You can find out more information in this [Boilerplate Repo](https://github.com/alenvalek/fivem-vuejs-boilerplate).

The very bacis for building and installing it are:
1. Open a command window in the html folder
2. run `npm i`
3. run `npm run build` (to create a new build of the ui), `npm run watch` to dev with it

> If nothing is happening, try deleting the dist folder before you run the build command

> This does require some know-how and use of [NPM](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm)

> If you're catching errors, it might be because your Node version is old/to new. I use Node 18. 

# Commands
`/addblueprint <source> <blueprint name>` adds a blueprint to database for player

`/removeblueprint <source> <blueprint name>` removes a blueprint to database for player

`/giveblueprint <source> <blueprint name>` gives the player a blueprint item

# Sponsored Features
## Per-recipe skill requirements
@Knuffelpanda | [KnuffelpandaTV Clubhouse](https://discord.com/invite/MpVCTDgUyb)
