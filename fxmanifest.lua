fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'SDK - SamuSonoIo'
description 'SDK Recycling'
version '1.0.0'

shared_scripts {
  'config.lua',
  'shared.lua',
  '@ox_lib/init.lua'
}

client_scripts {
  'client/*.lua'
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server/*.lua'
}