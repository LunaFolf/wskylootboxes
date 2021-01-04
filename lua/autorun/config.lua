-- Available weapons that can be won via lootboxes

meleeWeapons = {
  "weapon_zm_improvised"
}

primaryWeapons = {
  "weapon_zm_rifle",
  "weapon_ttt_aug",
  "weapon_ttt_sg550",
  "weapon_ttt_galil",
  "weapon_zm_sledge",
  "weapon_zm_shotgun",
  "weapon_ttt_tmp",
  "weapon_zm_mac10",
  "weapon_ttt_mp5",
  "weapon_ttt_famas",
  "weapon_ttt_m3s90"
}

secondaryWeapons = {
  "weapon_zm_revolver",
  "weapon_ttt_glock",
  "weapon_zm_pistol"
}

playerModels = {
  "models/player/genshin_impact_xiangling.mdl",
  "models/player/MasterChiefH3.mdl",
  "models/player/genshin_impact_diluc.mdl",
  "models/player/putin.mdl",
  "models/player/genshin_impact_razor.mdl",
  "models/player/puggamaximus.mdl",
  "models/player/genshin_impact_zhongli.mdl",
  "models/gonzo/regimentalclones2/cody/cody.mdl",
  "models/player/genshin_impact_amber.mdl"
}

allWeapons = {}
table.Add(allWeapons, primaryWeapons)
table.Add(allWeapons, secondaryWeapons)
table.Add(allWeapons, meleeWeapons)

weaponTiers = {
  "Common",
  "Uncommon",
  "Rare",
  "Legendary",
  "Exotic"
}