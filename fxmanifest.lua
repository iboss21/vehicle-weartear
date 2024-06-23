fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'iBoss21 | https://discord.gg/theluxempire'
description 'Dynamic Vehicle Wear and Tear System for Realistic Roleplay (Compatible with QBCore and ESX)'
version '1.2.0'

shared_scripts { 
    '@qb-core/shared/locale.lua', -- For qb-core language support
    'config.lua'       -- Configuration file
}

client_scripts {
    'client/client.lua'         -- Client-side script (main.lua is now renamed to client.lua)
}

server_scripts {
    'server/server.lua'        -- Server-side script (main.lua is now renamed to server.lua)
}
