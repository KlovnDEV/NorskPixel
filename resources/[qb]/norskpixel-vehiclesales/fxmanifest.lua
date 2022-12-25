
fx_version 'cerulean'
game 'gta5'

description 'norskpixel-VehicleSales'
version '1.1.0'

ui_page 'html/ui.html'

shared_scripts { 
	'config.lua'
}

client_script 'client/main.lua'
server_script 'server/main.lua'

files {
	'html/reset.css',
	'html/logo.svg',
	'html/ui.css',
	'html/ui.html',
	'html/vue.min.js',
	'html/ui.js',
}
