if CLIENT then return end

math.randomseed(os.time())

AddCSLuaFile('wskylootboxes/cl_data.lua')
AddCSLuaFile('wskylootboxes/cl_menu.lua')
AddCSLuaFile('wskylootboxes/cl_init.lua')
AddCSLuaFile('wskylootboxes/cl_renderer.lua')
AddCSLuaFile('wskylootboxes/cl_notifications.lua')
AddCSLuaFile('wskylootboxes/cl_weaponNaming.lua')

AddCSLuaFile('shared.lua')
AddCSLuaFile('config.lua')

include('config.lua')
include('shared.lua')

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