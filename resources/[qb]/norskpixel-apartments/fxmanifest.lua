
fx_version 'cerulean'
game 'gta5'

description 'norskpixel-Apartments'
version '1.0.0'

shared_script 'config.lua'

server_script 'server/main.lua'

client_scripts {
	'client/main.lua',
	'client/gui.lua'
}

dependencies {
	'norskpixel-core',
	'norskpixel-interior',
	'fivem-appearance',
	'norskpixel-weathersync'
}

lua54 'yes'