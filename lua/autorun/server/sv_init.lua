if CLIENT then return end

math.randomseed(os.time())

include('../config.lua')

include('sv_downloads.lua')

include('sv_data.lua')
include('sv_crates.lua')
include('sv_commands.lua')
include('sv_itemManagement.lua')
include('sv_market.lua')
include('sv_store.lua')

include('../shared.lua')

include('sv_hooks.lua')

