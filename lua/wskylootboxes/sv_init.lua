if CLIENT then return end

math.randomseed(os.time())

AddCSLuaFile('wskylootboxes/cl_data.lua')
AddCSLuaFile('wskylootboxes/cl_menu.lua')
AddCSLuaFile('wskylootboxes/cl_init.lua')
AddCSLuaFile('wskylootboxes/renderer/cl_renderer_init.lua')
AddCSLuaFile('wskylootboxes/renderer/cl_leaderboard.lua')
AddCSLuaFile('wskylootboxes/renderer/cl_market.lua')
AddCSLuaFile('wskylootboxes/renderer/settings/cl_settings.lua')
AddCSLuaFile('wskylootboxes/renderer/settings/cl_playerModelSettings.lua')
AddCSLuaFile('wskylootboxes/renderer/cl_store.lua')
AddCSLuaFile('wskylootboxes/renderer/cl_inventory.lua')
AddCSLuaFile('wskylootboxes/cl_notifications.lua')
AddCSLuaFile('wskylootboxes/cl_weaponNaming.lua')

AddCSLuaFile('config.lua')

include('config.lua')

include('sv_downloads.lua')

include('sv_data.lua')
include('sv_migrations.lua')

include('sv_crates.lua')
include('sv_commands.lua')
include('sv_itemManagement.lua')
include('sv_market.lua')
include('sv_store.lua')
include('sv_debug.lua')
include('sv_exoticParticles.lua')

include('sv_jaxbot.lua')

include('sv_cron.lua')

include('sv_hooks.lua')
