fx_version 'cerulean'
game 'gta5'

author 'Your Name'
description 'Advanced Garbage Collection Job'
version '1.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/en.lua', -- or any other localization file you need
    'config.lua'
}

client_scripts {
    '@qb-core/client/wrapper.lua',
    '@qb-core/client/wrapper_func.lua',
    'client.lua'
}

server_scripts {
    '@qb-core/server/wrapper.lua',
    '@qb-core/server/wrapper_func.lua',
    'server.lua'
}

dependencies {
    'qb-core',
    'qb-menu',
    'ox_target'
}
