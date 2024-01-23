
fx_version 'adamant'
game 'gta5'
lua54 'yes'

author 'Coffeelot and Wuggie'
description 'CW crafting system'
version '2.0'

ui_page {
    "html/dist/index.html"
}

files {
    "html/dist/index.html",
    "html/dist/assets/*.*",
    "images/*.*"
}

client_scripts{
    'config.lua',
    'client/*.lua',
}

server_scripts{
    '@oxmysql/lib/MySQL.lua',
    'config.lua',
    'server/*.lua',
}

shared_scripts {
    'config.lua',
}

exports {
    'giveRandomBlueprint',
    'giveBlueprintItem',
}

dependency 'oxmysql'

