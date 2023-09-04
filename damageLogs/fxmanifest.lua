fx_version 'cerulean'
games { 'rdr3', 'gta5' }

author 'Heavens <Solbac1134>'
description 'Simple Damage Logs with bone parts Credits on CFX natives'
version '0.1.0'

shared_script '@es_extended/imports.lua'


client_scripts {
    'cl/*.lua',
}

server_script {
    'sv/*.lua'
}
