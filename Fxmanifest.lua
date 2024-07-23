fx_version 'cerulean'
game 'gta5'

author 'Your Name'
description 'Advanced Garbage Collection Job'
version '1.0.0'

-- Define the server-side scripts
server_scripts {
    '@qb-core/server/main.lua',  -- Ensure this path matches the location of qb-core server script
    'server.lua'
}

-- Define the client-side scripts
client_scripts {
    '@qb-core/client/main.lua',  -- Ensure this path matches the location of qb-core client script
    'client.lua'
}

-- Specify dependencies
dependencies {
    'qb-core',
    'qb-menu',
    'ox_target'
}

-- Files and folders that will be included in the resource
files {
    'locales/en.lua',    -- Ensure localization files are correct
    'config.lua'         -- Ensure config file is correctly referenced
}
