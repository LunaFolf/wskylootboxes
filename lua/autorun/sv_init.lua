if CLIENT then return end

include('config.lua')

include('sv_data.lua')
include('sv_crates.lua')
include('sv_download.lua')
include('sv_commands.lua')
include('sv_itemManagement.lua')
include('sv_market.lua')
include('sv_store.lua')

include('shared.lua')

include('sv_hooks.lua')

util.AddNetworkString("WskyTTTLootboxes_OpenPlayerInventory")
util.AddNetworkString("WskyTTTLootboxes_ClientsideWinChime")

math.randomseed(os.time())