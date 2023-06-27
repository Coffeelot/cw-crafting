# Crafting 🔧
We hated the idea of the crafting grind, so we made a crafting script that's focused on blueprints that can be aquired from loot or by having the correct job.

Blueprints are items that have a unique value tied to them. By default you have to find one of the blueprint trainers to teach you a blueprint. These are found at the bottom of the Config file. You can disable them to make blueprints usable to learn the reciepe instead. Reciepes can also be tied to jobs, or both jobs and blueprints! The config holds a lot of comments to help you create your own recipes, crafting benches and blueprints!

### ❗❗ YOU CAN NOT SPAWN BLUEPRINT ITEMS WITH /giveitem OR ANY MENU! SEE COMMANDS ❗❗


READ SETUP BEFORE YOU ASK QUESTIONS 🐱‍🐉

# Youtube Preview 📽
[![YOUTUBE VIDEO](http://img.youtube.com/vi/NVUlgIOcvbU/0.jpg)](https://youtu.be/NVUlgIOcvbU)

# Features
- Blueprint based crafting
- Easy addition of new recipes
- Exports to give blueprints (through loot for example)
- All base QB recipes
- A very sexy UI if I do say so myself
- Support for OX inventory

## Commands
`/addblueprint <source> <blueprint name>` adds a blueprint to database for player

`/removeblueprint <source> <blueprint name>` removes a blueprint to database for player

`/giveblueprint <source> <blueprint name>` gives the player a blueprint item


# Developed by Coffeelot and Wuggie
[More scripts by us](https://github.com/stars/Coffeelot/lists/cw-scripts)  👈

**Support, updates and script previews**:

[![Join The discord!](https://cdn.discordapp.com/attachments/977876510620909579/1013102122985857064/discordJoin.png)](https://discord.gg/FJY4mtjaKr )

**All our scripts are and will remain free**. If you want to support that endeavour, you can buy us a coffee here:

[![Buy Us a Coffee](https://www.buymeacoffee.com/assets/img/guidelines/download-assets-sm-2.svg)](https://www.buymeacoffee.com/cwscriptbois )
# Setup 🔧
## Add to qb-core ❗
Items to add to qb-core>shared>items.lua 
```
	-- CW crafting
	["blueprint"] =          {["name"] = "blueprint",         ["label"] = "Blueprint",                  ["weight"] = 1, ["type"] = "item", ["image"] = "blueprint.png", ["unique"] = true, ["useable"] = true, ['shouldClose'] = true, ["combinable"] = nil, ["description"] = "A blueprint for a crafting item"},
```
Also make sure the images are in qb-inventory>html>images

## Make your recipe values show in qb inventory (optional)
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
```    
kitchen = {
        title = "Open kitchen",
        objects = { 'gr_prop_gr_hobo_stove_01' }
    },
```


Now you got a new table! To fill it with items all you need to do is add `"tables = {'kitchen'}"`  to your recipes. You can see examples of these in the Recipes object. If you check the Recipes at the top they have comments explaining the different fields