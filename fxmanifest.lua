fx_version 'cerulean'
game 'gta5'

author 'iBoss21'
description 'Advanced Vehicle Wear System'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'ox_lib',
    'oxmysql'
}

lua54 'yes'
