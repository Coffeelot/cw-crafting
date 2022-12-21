
fx_version 'adamant'
game 'gta5'

author 'Coffeelot and Wuggie'
description 'CW crafting system'
version '1.69'

ui_page 'html/index.html'

lua54 'yes'

files {
	'html/*',
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

dependency 'oxmysql'

