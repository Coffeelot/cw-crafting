
fx_version 'adamant'
game 'gta5'
lua54 'yes'

author 'Coffeelot and Wuggie'
description 'CW crafting system'
version '3.6'

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
    'bridge/client/*.lua',
    'client/functions.lua',
    'client/client.lua',
}

server_scripts{
    '@oxmysql/lib/MySQL.lua',
    'config.lua',
    'bridge/server/*.lua',
    'server/functions.lua',
    'server/server.lua',
}

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua',
    -- '@qbx_core/modules/playerdata.lua' -- Needed for QBOX!
}

dependency 'oxmysql'
