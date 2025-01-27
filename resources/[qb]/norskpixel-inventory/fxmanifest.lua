
fx_version 'cerulean'
game 'gta5'

description 'norskpixel-Inventory'
version '1.0.0'

shared_scripts {
	'config.lua',
	'@norskpixel-weapons/config.lua'
}

server_script 'server/main.lua'
client_script 'client/main.lua'

ui_page {
	'html/ui.html'
}

files {
	'html/ui.html',
	'html/css/main.css',
	'html/js/app.js',
	'html/images/*.png',
	'html/images/*.jpg',
	'html/ammo_images/*.png',
	'html/attachment_images/*.png',
	'html/*.ttf'
}

dependency 'norskpixel-weapons'

lua54 'yes'