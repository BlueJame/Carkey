fx_version 'adamant'

game 'gta5'

description 'naypae Shop(เจ้าของหรือป่าวไม่รู้) Edit carkey '

version '2.0'

ui_page {
    'html/index.html',
}

files {
    'html/index.html',
    'html/lock.ogg',
    'html/unlock.ogg'
}

client_scripts {
    "config.lua",
    "code/client.lua"
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    "config.lua",
    "code/server.lua"
}
