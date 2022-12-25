fx_version 'cerulean'
game 'gta5'

description 'Admin Menu'

ui_page "nui/index.html"

shared_scripts {
    'shared/sh_config.lua',
    'locale.lua',
    'locales/en.lua', -- Change this to your desired language.
}

client_scripts {
    '@norskpixel-core/shared/items.lua',
    '@norskpixel-core/shared/gangs.lua',
    '@norskpixel-core/shared/jobs.lua',
    '@norskpixel-core/shared/vehicles.lua',
    'client/**/cl_*.lua',
    'shared/sh_commands.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/**/sv_*.lua',
}

files {
    "nui/index.html",
    "nui/js/**.js",
    "nui/css/**.css",
    "nui/webfonts/*.css",
    "nui/webfonts/*.otf",
    "nui/webfonts/*.ttf",
    "nui/webfonts/*.woff2",
}

exports {
    'CreateLog',
    'ToggleDev',
}

server_exports {
    'CreateLog'
} 

dependencies {
    'oxmysql',
    'norskpixel-core'
}

lua54 'yes'