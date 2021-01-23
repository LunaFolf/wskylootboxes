local pcfFiles = {
  "halloween2015_unusuals",
  "halloween2016_unusuals",
  "halloween2018_unusuals",
  "invasion_unusuals",
  "summer2020_unusuals"
}

playerModelParticles = {
  "unusual_mystery_parent",
  "unusual_mystery_parent_green",
  "unusual_invasion_abduction",
  "unusual_invasion_codex",
  "unusual_invasion_codex_2"
}

weaponParticles = {
  "unusual_eldritch_flames_orange",
  "unusual_eldritch_flames_purple",
  "unusual_hw_deathbydisco_parent",
  "unusual_nether_sparkles_blue",
  "unusual_nether_sparkles_pink"
}

particles = {}
table.Merge(particles, playerModelParticles)
table.Merge(particles, weaponParticles)

for i, file in ipairs(pcfFiles) do
  game.AddParticles( "particles/"..file..".pcf" )
end

for i, particle in ipairs(particles) do
  PrecacheParticleSystem( particle )
end

if SERVER then include('wskylootboxes/sv_init.lua') end
if CLIENT then include('wskylootboxes/cl_init.lua') end

concommand.Add("wskylootboxes_steam64", function (ply)
  if SERVER then return end
  print(ply:SteamID64())
end)