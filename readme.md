# Crafting 🔧
### ⭐ Check out our [Tebex store](https://cw-scripts.tebex.io/category/2523396) for some cheap scripts ⭐
We hated the idea of the crafting grind, so we made a crafting script that's focused on blueprints that can be aquired from loot or by having the correct job.

Blueprints are items that have a unique value tied to them. By default you have to find one of the blueprint trainers to teach you a blueprint. These are found at the bottom of the Config file. You can disable them to make blueprints usable to learn the reciepe instead. Reciepes can also be tied to jobs, or both jobs and blueprints! The config holds a lot of comments to help you create your own recipes, crafting benches and blueprints!

### ❗❗ YOU CAN NOT SPAWN BLUEPRINT ITEMS WITH /giveitem OR ANY MENU! SEE COMMANDS ❗❗


READ SETUP BEFORE YOU ASK QUESTIONS 🐱‍🐉

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

[![Join The discord!](https://cdn.discordapp.com/attachments/977876510620909579/1013102122985857064/discordJoin.png)](https://discord.gg/FJY4mtjaKr )

**All our scripts are and will remain free**. If you want to support that endeavour, you can buy us a coffee here:

[![Buy Us a Coffee](https://www.buymeacoffee.com/assets/img/guidelines/download-assets-sm-2.svg)](https://www.buymeacoffee.com/cwscriptbois )
# Setup 🔧
## Add to qb-core ❗
Items to add to qb-core>shared>items.lua 
```lua
	-- CW crafting
	["blueprint"] =          {["name"] = "blueprint",         ["label"] = "Blueprint",                  ["weight"] = 0, ["type"] = "item", ["image"] = "blueprint.png", ["unique"] = true, ["useable"] = true, ['shouldClose'] = true, ["combinable"] = nil, ["description"] = "A blueprint for a crafting item"},
```
For ox: 
```lua
	['blueprint'] = {
		label = 'Blueprint',
		weight = 0,
		close = true,
		allowArmed = true,
		stack = false,
	},
```
Also make sure the images are in qb-inventory>html>images

> A common issue here is that another script has the "blueprint" name. If so, make sure to rename either this blueprint item or the other one and update all code.

## Make your recipe values show in qb inventory (optional)
> This step is not needed if you use ox inventory

To make it show item value in qb-inventory add this in app.js somewhere in the `FormatItemInfo` function (look for similar `else if` statements)
```
        else if (itemData.name == "blueprint") {
            $(".item-info-title").html("<p>" + itemData.label + "</p>");
            $(".item-info-description").html("<p> Recipe for: "+ itemData.info.value + "</p>");
        }
```

## Adding Blueprints to loot
There are two exports for this script. You can either randomize the blueprints (chance is based of what's in the config):

```
exports['cw-crafting']:giveRandomBlueprint(source, rarity, failChance)
```
`rarity` can either be a max (ei just a number) or a table holding a span (`{ min: 2, max: 4}`)
`failChance` is a number between 1-1000 with the chance to fail. For example, if you set this to 900 it's a 90% chance you do NOT get the blueprint

Example use: `exports['cw-crafting']:giveRandomBlueprint(source, {min = 1, max = 2}, 990)`, this will give the player a blueprint of rarity 1-2, with a 99% fail chance

Or you can give a specific blueprint:
```
exports['cw-crafting']:giveBlueprintItem(source, blueprintValue)
```

You'll want to add these to server side loot distribution of any script you think could benefit from having a chance to give out blueprints.

‼ Only blueprints that have been added to `Config.Blueprints` in the `Config.Lua` file will be randomized from!

## Creating new crafting tables
All you gotta do is go into the `Config.Lua`, head to the bottom and you'll find the Tables. You can add a table her,  in the same style as the existing ones. So say you wanted to add a "kitchen" table, it'd look like this:
```lua
kitchen = {
        title = "Open kitchen",
		icon = "food-fork-drink", -- icon for the crafting menu, uses Material Desgin Icons https://pictogrammers.com/library/mdi/ (optional)
		job = 'hotdogs', -- job name. Works same as qb target so you can use a table with ranks also (I think?) (optional)
		jobType = { ['food'] = 1 }, -- NOTE: This checks TYPES not name. A new qb thing. Means you can have one type for several jobs (optional)
		gang = 'hotdoggang', -- gang name. Works same as qb target so you can use a table with ranks also (I think?) (optional)
        objects = { 'gr_prop_gr_hobo_stove_01' }, -- providing this will make ALL objects of this variant a table, can include multiple (leave empty if this is not what you want, ei objects = {})
		locations = {  vector3(-165.14, -984.55, 254.22), }, -- spawn at these locations (optional)
		spawnTable = { { coords = vector4(794.49, -2613.63, 87.97, 2.4), prop = 'gr_prop_gr_hobo_stove_01' } } -- List of several tables with prop and location. If these are added it will SPAWN a table that's interactable (optional)
    },
```
> Note: The example above has ALL the cration types, which obviously might not be optimal. Use one or more, to fit your needs.

Now you got a new table! To fill it with items all you need to do is add `"tables = {'kitchen'}"`  to your recipes. You can see examples of these in the Recipes object. If you check the Recipes at the top they have comments explaining the different fields

## Creating recipes
As of the new update, we no longer provide the base QB recipies (since so many people refuse to read instructions and update them to fit their server before reporting errors). The recipies have also been updated to be more aligned to make them more easier to manage.

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
		craftingTime= 3000, -- crafting time (optional)
        blueprint = 'Lockpick', -- blueprint name. Case sensitive to the blueprint name! (optional)
		maxCraft = 20, -- the max amount you can craft in one batch (optional) 
        jobs = { -- table of job requirements (optional)
			{ type = 'mechanic', level = 2 }, -- example of a job using TYPE rather than name
			{ name = 'police', level = 2 } -- example of a job using specific names
	 	},
		tables = {'mechanic', 'police'}, -- specific tables this recipe can be made at
        metadata = { color = 'orange'} -- metadata of item (optional)
	}
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