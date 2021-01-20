valueDepreciationFn = function ()
  return math.Rand(0.35, 0.55)
end

-- Available weapons that can be won via lootboxes

meleeWeapons = {
  ["weapon_zm_improvised"] = {
    ["value"] = 125
  }
}

primaryWeapons = {
  ["weapon_sp_winchester"] = {
    ["value"] = 310
  },
  ["weapon_752_bowcaster"] = {
    ["value"] = 310
  },
  ["weapon_zm_rifle"] = {
    ["value"] = 310
  },
  ["weapon_rp_pocket"] = {
    ["value"] = 340
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
  ["weapon_ap_mrca1"] = {
    ["value"] = 190
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
  ["weapon_zm_sledge"] = {
    ["value"] = 250
  },
  ["weapon_zm_shotgun"] = {
    ["value"] = 180
  },
  ["weapon_ttt_tmp"] = {
    ["value"] = 122
  },
  ["weapon_zm_mac10"] = {
    ["value"] = 115
  },
  ["weapon_ap_mrca1"] = {
    ["value"] = 125
  },
  ["weapon_ap_tec9"] = {
    ["value"] = 135
  },
  ["weapon_ap_vector"] = {
    ["value"] = 120
  },
  ["weapon_ttt_mp5"] = {
    ["value"] = 225
  },
  ["weapon_ttt_famas"] = {
    ["value"] = 150
  },
  ["weapon_ttt_m3s90"] = {
    ["value"] = 200
  },
  ["weapon_sp_striker"] = {
    ["value"] = 210
  },
  ["weapon_sp_dbarrel"] = {
    ["value"] = 200
  },
  ["weapon_752_e11"] = {
    ["value"] = 160
  },
}

secondaryWeapons = {
  ["weapon_zm_revolver"] = {
    ["value"] = 162
  },
  ["weapon_pp_rbull"] = {
    ["value"] = 162
  },
  ["weapon_pp_remington"] = {
    ["value"] = 172
  },
  ["weapon_ttt_glock"] = {
    ["value"] = 75
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
  ["weapon_ttt_dual_elites"] = {
    ["value"] = 135
  },
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
  ["models/player/linktp.mdl"] = {
    ["value"] = 115
  },
  ["models/player/genshin_impact_albedo.mdl"] = {
    ["value"] = 115
  },
  ["models/player/drpyspy/spy.mdl"] = {
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
  ["models/player/uk_police/uk_police_01.mdl"] = {
    ["value"] = 150
  },
  ["models/player/gman_high.mdl"] = {
    ["value"] = 150
  },
  ["models/player/uk_police/uk_police_02.mdl"] = {
    ["value"] = 150
  },
  ["models/player/sono/starwars/green_company_trooper.mdl"] = {
    ["value"] = 150
  },
  ["models/player/uk_police/uk_police_03.mdl"] = {
    ["value"] = 150
  },
  ["models/player/breen.mdl"] = {
    ["value"] = 150
  },
  ["models/player/uk_police/uk_police_04.mdl"] = {
    ["value"] = 150
  },
  ["models/player/genshin_impact_aether.mdl"] = {
    ["value"] = 150
  },
  ["models/Barbara/genshin_impact/rstar/Barbara/Barbara.mdl"] = {
    ["value"] = 150
  },
  ["models/player/genshin_impact_ayaka.mdl"] = {
    ["value"] = 150
  },
  ["models/fbi_pack/fbi_01.mdl"] = {
    ["value"] = 170
  },
  ["models/fbi_pack/fbi_02.mdl"] = {
    ["value"] = 170
  },
  ["models/fbi_pack/fbi_03.mdl"] = {
    ["value"] = 170
  },
  ["models/fbi_pack/fbi_04.mdl"] = {
    ["value"] = 170
  },
  ["models/player/MasterChiefH2_red.mdl"] = {
    ["value"] = 170
  },
  ["models/player/MasterChiefH2_blue.mdl"] = {
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
  ["models/player/robber.mdl"] = {
    ["value"] = 180
  },
  ["models/player/zelda.mdl"] = {
    ["value"] = 220
  },
  ["models/player/alice.mdl"] = {
    ["value"] = 220
  },
  ["models/player/macdguy.mdl"] = {
    ["value"] = 180
  },
  ["models/player/rorschach.mdl"] = {
    ["value"] = 190
  },
  ["models/Avengers/Iron Man/mark7_player.mdl"] = {
    ["value"] = 240
  },
  ["models/pechenko_121/Deadpool/chr_deadpool2.mdl"] = {
    ["value"] = 240
  }
}

exclusiveModels = {
  ["76561198037289710"] = {
    [1] = {
      ["type"] = "playerModel",
      ["modelName"] = "models/player/teslapower.mdl"
    }
  },
  ["76561198332078167"] = {
    [1] = {
      ["type"] = "playerModel",
      ["modelName"] = "models/player/genshin_impact_chongyun.mdl"
    }
  },
  ["76561198080812606"] = {
    [1] = {
      ["type"] = "playerModel",
      ["modelName"] = "models/player/sono/starwars/commander_bly.mdl"
    }
  },
  ["76561198412400073"] = {
    [1] = {
      ["type"] = "playerModel",
      ["modelName"] = "models/konnie/isa/detroit/connor.mdl"
    }
  }
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
  {
    ["type"] = "crate_any",
    ["value"] = math.ceil(((playersModelAveragePrice + weaponsAveragePrice) / 2) * 1)
  },
  {
    ["type"] = "crate_weapon",
    ["value"] = math.ceil(weaponsAveragePrice * 1.5)
  },
  {
    ["type"] = "crate_playerModel",
    ["value"] = math.ceil(playersModelAveragePrice * 1.5)
  },
  {
    ["type"] = "playerModel",
    ["modelName"] = "models/player/fortnite/mandalorian.mdl",
    ["value"] = 6000
  },
  {
    ["type"] = "playerModel",
    ["modelName"] = "models/player/teslapower.mdl",
    ["value"] = 8000
  },
}

itemNameOverrides = {
  ["Codyregimental2"] = "Commander Cody",
  ["Libertyprime"] = "Liberty Prime",
  ["Niko"] = "Niko Bellic",
  ["Doomguy"] = "Doom guy",
  ["Classygentleman"] = "Classy Gentleman",
  ["Masterchief3"] = "Master Chief",
  ["FBI_01"] = "FBI Agent",
  ["FBI_02"] = "FBI Agent",
  ["FBI_03"] = "FBI Agent",
  ["FBI_04"] = "FBI Agent",
  ["FBI_05"] = "FBI Agent",
  ["FBI_06"] = "FBI Agent",
  ["FBI_07"] = "FBI Agent",
  ["FBI_08"] = "FBI Agent",
  ["FBI_09"] = "FBI Agent",
  ["UK_Police_01"] = "UK Police Officer",
  ["UK_Police_02"] = "UK Police Officer",
  ["UK_Police_03"] = "UK Police Officer",
  ["UK_Police_04"] = "UK Police Officer",
  ["UK_Police_05"] = "UK Police Officer",
  ["UK_Police_06"] = "UK Police Officer",
  ["UK_Police_07"] = "UK Police Officer",
  ["UK_Police_08"] = "UK Police Officer",
  ["UK_Police_09"] = "UK Police Officer",
  ["Smith"] = "Agent Smith",
  ["PuggaMaximus"] = "Pugga Maximus",
  ["CHR_Deadpool"] = "Deadpool",
  ["PUTIN"] = "Vladimir Putin",
  ["Masterchief2Red"] = "Halo Spartan - Red",
  ["Masterchief2blue"] = "Halo Spartan - Blue",
  ["Spytf2"] = "Spy",
  ["Linktp"] = "Link",
  ["Fornite Mandalorian"] = "Mandalorian"
}