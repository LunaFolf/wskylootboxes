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
  "weapon_zm_mac10"
}

secondaryWeapons = {
  "weapon_zm_revolver",
  "weapon_ttt_glock",
  "weapon_zm_pistol"
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