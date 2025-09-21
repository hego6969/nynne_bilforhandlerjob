fx_version 'cerulean'
game 'gta5'
lua54 'on'
author 'nynne'
version '1.0'

dependencies {
    'ox_lib'
}


client_scripts{
    'lib/Proxy.lua',
    'lib/Tunnel.lua',
	"config.lua",
    '@ox_lib/init.lua',
    'client/*.lua',
}

    server_scripts{
    "@vrp/lib/utils.lua",
    "@oxmysql/lib/MySQL.lua",
    '@ox_lib/init.lua',
    'config.lua',
    'server/*.lua',
}

fx_version 'adamant'
games { 'gta5', 'rdr3' }