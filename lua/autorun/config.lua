-- Available weapons that can be won via lootboxes

meleeWeapons = {
  ["weapon_zm_improvised"] = {
    ["value"] = 125
  }
}

primaryWeapons = {
  ["ttt_m9k_intervention"] = {
    ["value"] = 400
  },
  ["ttt_m9k_m24"] = {
    ["value"] = 350
  },
  ["weapon_zm_rifle"] = {
    ["value"] = 310
  },
  ["ttt_m9k_svt40"] = {
    ["value"] = 340
  },
  ["ttt_m9k_svu"] = {
    ["value"] = 380
  },
  ["weapon_ttt_aug"] = {
    ["value"] = 187
  },
  ["weapon_752_ihr"] = {
    ["value"] = 180
  },
  ["weapon_752_dc15s"] = {
    ["value"] = 220
  },
  ["weapon_ttt_sg550"] = {
    ["value"] = 210
  },
  ["weapon_752_e5"] = {
    ["value"] = 210
  },
  ["weapon_752_dc15a"] = {
    ["value"] = 250
  },
  ["weapon_ttt_m16"] = {
    ["value"] = 205
  },
  ["weapon_ttt_galil"] = {
    ["value"] = 225
  },
  ["ttt_m9k_scar"] = {
    ["value"] = 230
  },
  ["weapon_zm_sledge"] = {
    ["value"] = 250
  },
  ["weapon_zm_shotgun"] = {
    ["value"] = 180
  },
  ["weapon_ttt_tmp"] = {
    ["value"] = 122
  },
  ["ttt_m9k_smgp90"] = {
    ["value"] = 120
  },
  ["ttt_m9k_fg42"] = {
    ["value"] = 130
  },
  ["weapon_zm_mac10"] = {
    ["value"] = 115
  },
  ["weapon_ttt_mp5"] = {
    ["value"] = 225
  },
  ["ttt_m9k_usc"] = {
    ["value"] = 225
  },
  ["weapon_ttt_famas"] = {
    ["value"] = 150
  },
  ["ttt_m9k_mp9"] = {
    ["value"] = 160
  },
  ["ttt_m9k_g36"] = {
    ["value"] = 160
  },
  ["weapon_ttt_m3s90"] = {
    ["value"] = 200
  },
  ["ttt_m9k_spas12"] = {
    ["value"] = 250
  },
  ["ttt_m9k_usas"] = {
    ["value"] = 290
  },
  ["weapon_752_e11"] = {
    ["value"] = 160
  },
}

secondaryWeapons = {
  ["ttt_m9k_m29satan"] = {
    ["value"] = 152
  },
  ["weapon_zm_revolver"] = {
    ["value"] = 162
  },
  ["weapon_ttt_glock"] = {
    ["value"] = 75
  },
  ["ttt_m9k_hk45"] = {
    ["value"] = 125
  },
  ["weapon_zm_pistol"] = {
    ["value"] = 120
  },
  ["weapon_752_elg3a"] = {
    ["value"] = 150
  },
  ["weapon_752_dc17"] = {
    ["value"] = 150
  },
  ["ttt_m9k_luger"] = {
    ["value"] = 125
  },
  ["ttt_m9k_colt1911"] = {
    ["value"] = 130
  },
  ["weapon_ttt_dual_elites"] = {
    ["value"] = 135
  },
  ["ttt_m9k_contender"] = {
    ["value"] = 320
  }
}

playerModels = {
  ["models/player/shaun.mdl"] = {
    ["value"] = 45
  },
  ["models/player/niko.mdl"] = {
    ["value"] = 65
  },
  ["models/player/sono/starwars/442nd_trooper.mdl"] = {
    ["value"] = 225
  },
  ["models/player/romanbellic.mdl"] = {
    ["value"] = 65
  },
  ["models/player/smith.mdl"] = {
    ["value"] = 70
  },
  ["models/player/genshin_impact_amber.mdl"] = {
    ["value"] = 85
  },
  ["models/player/spacesuit.mdl"] = {
    ["value"] = 87
  },
  ["models/player/genshin_impact_xiangling.mdl"] = {
    ["value"] = 95
  },
  ["models/player/p2_chell.mdl"] = {
    ["value"] = 100
  },
  ["models/player/puggamaximus.mdl"] = {
    ["value"] = 100
  },
  ["models/player/genshin_impact_razor.mdl"] = {
    ["value"] = 115
  },
  ["models/player/putin.mdl"] = {
    ["value"] = 125
  },
  ["models/player/genshin_impact_diluc.mdl"] = {
    ["value"] = 135
  },
  ["models/player/sono/starwars/187th_trooper.mdl"] = {
    ["value"] = 225
  },
  ["models/ex-mo/quake3/players/doom.mdl"] = {
    ["value"] = 140
  },
  ["models/player/genshin_impact_zhongli.mdl"] = {
    ["value"] = 145
  },
  ["models/player/uk_police/uk_police_04.mdl"] = {
    ["value"] = 150
  },
  ["models/fbi_pack/fbi_01.mdl"] = {
    ["value"] = 170
  },
  ["models/player/MasterChiefH3.mdl"] = {
    ["value"] = 200
  },
  ["models/player/sono/starwars/501st_trooper.mdl"] = {
    ["value"] = 225
  },
  ["models/norpo/ArkhamOrigins/Assassins/Deathstroke_ValveBiped.mdl"] = {
    ["value"] = 215
  },
  ["models/player/sam.mdl"] = {
    ["value"] = 220
  },
  ["models/player/alice.mdl"] = {
    ["value"] = 220
  },
  ["models/player/charple.mdl"] = {
    ["value"] = 220
  },
  ["models/player/macdguy.mdl"] = {
    ["value"] = 180
  },
  ["models/player/rorschach.mdl"] = {
    ["value"] = 190
  },
  ["models/gonzo/regimentalclones2/cody/cody.mdl"] = {
    ["value"] = 225
  },
  ["models/pechenko_121/Deadpool/chr_deadpool2.mdl"] = {
    ["value"] = 240
  },
  ["models/player/infernonaval/agent/infernoagent.mdl"] = {
    ["value"] = 200
  },
}

allWeapons = {}
table.Merge(allWeapons, primaryWeapons)
table.Merge(allWeapons, secondaryWeapons)
table.Merge(allWeapons, meleeWeapons)

weaponTiers = {
  [1] = {
    ["name"] = "Common",
    ["multiplier"] = 1
  },
  [2] = {
    ["name"] = "Uncommon",
    ["multiplier"] = 1.25
  },
  [3] = {
    ["name"] = "Rare",
    ["multiplier"] = 1.5
  },
  [4] = {
    ["name"] = "Legendary",
    ["multiplier"] = 1.75
  },
  [5] = {
    ["name"] = "Exotic",
    ["multiplier"] = 2
  }
}

local weaponsSum = 0
for i, key in pairs(table.GetKeys(allWeapons)) do
  weaponsSum = weaponsSum + allWeapons[key].value
end
local weaponsAveragePrice = math.ceil(weaponsSum / table.Count(allWeapons) * 1.25)

local playerModelsSum = 0
for i, key in pairs(table.GetKeys(playerModels)) do
  playerModelsSum = playerModelsSum + playerModels[key].value
end
local playersModelAveragePrice = math.ceil(playerModelsSum / table.Count(playerModels) * 1.75)

storeItems = {
  [1] = {
    ["type"] = "crate_weapon",
    ["value"] = math.ceil(weaponsAveragePrice * 2.5)
  },
  [2] = {
    ["type"] = "crate_any",
    ["value"] = math.ceil(((playersModelAveragePrice + weaponsAveragePrice) / 2) * 2.5)
  },
  [3] = {
    ["type"] = "crate_playerModel",
    ["value"] = math.ceil(playersModelAveragePrice * 2.5)
  },
  [4] = {
    ["type"] = "playerModel",
    ["modelName"] = "models/player/fortnite/mandalorian.mdl",
    ["value"] = 8000
  }
}