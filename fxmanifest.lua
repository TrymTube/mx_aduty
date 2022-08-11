fx_version 'bodacious'
game 'gta5'

author 'Max'
description 'simple aduty system'
version '0.2.0'

lua54 'yes'

shared_script {
	'@es_extended/imports.lua',
	'@es_extended/locale.lua',
	'config.lua'
}

client_scripts {
	'client/*.lua'
}

server_scripts {
	'server/*.lua'
}