AddCSLuaFile('client/cl_data.lua')
AddCSLuaFile('client/cl_menu.lua')
AddCSLuaFile('client/cl_init.lua')
AddCSLuaFile('client/cl_notifications.lua')

AddCSLuaFile('shared.lua')
AddCSLuaFile('config.lua')

include("config.lua")

local pcfFiles = {
  "halloween2015_unusuals",
  "halloween2016_unusuals",
  "halloween2018_unusuals",
  "invasion_unusuals"
}

particles = {
  "unusual_eldritch_flames_orange",
  "unusual_eldritch_flames_purple",
  "unusual_hw_deathbydisco_parent",
  "unusual_mystery_parent",
  "unusual_mystery_parent_green",
  "unusual_nether_sparkles_blue",
  "unusual_nether_sparkles_pink",
  "unusual_circling_spell_orange_parent",
  "unusual_circling_spell_purple_parent",
  "unusual_invasion_abduction",
  "unusual_invasion_boogaloop",
  "unusual_invasion_codex",
  "unusual_invasion_codex_2",
  "unusual_invasion_nebula",
  "unusual_invasion_boogaloop_2",
  "unusual_circling_spell_blue_parent",
  "unusual_circling_spell_green_parent"
}

for i, file in ipairs(pcfFiles) do
  game.AddParticles( "particles/"..file..".pcf" )
end

for i, particle in ipairs(particles) do
  PrecacheParticleSystem( particle )
end

concommand.Add("wsky_steam64", function (ply)
  print(ply:SteamID64())
end)