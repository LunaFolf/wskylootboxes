if CLIENT then return end

math.randomseed(os.time())

include('wsky_lootbox_config.lua')
include('wsky_lootbox_shared.lua')

include('sv_downloads.lua')

include('sv_data.lua')
include('sv_crates.lua')
include('sv_commands.lua')
include('sv_itemManagement.lua')
include('sv_market.lua')
include('sv_store.lua')
include('sv_debug.lua')
include('sv_exoticParticles.lua')

include('sv_hooks.lua')

