fx_version "cerulean"

games { 'rdr3' }

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

lua54 'yes'

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    
    'client/Main.lua',
    'client/Natives.lua',
    'client/Keypress.lua',
    'client/Blips.lua',
    'client/Player.lua',
    'client/Events.lua',
    'client/Dataview.js',
    'client/Zones.lua'
}

server_scripts {
    'server/Main.lua',
    'server/Natives.lua',
}