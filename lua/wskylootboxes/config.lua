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
  ["weapon_zm_rifle"] = {
    ["value"] = 310
  },
  ["weapon_rp_pocket"] = {
    ["value"] = 340
  },
  ["weapon_ttt_aug"] = {
    ["value"] = 187
  },
  ["weapon_ttt_sg550"] = {
    ["value"] = 210
  },
  ["weapon_ap_mrca1"] = {
    ["value"] = 190
  },
  ["weapon_ttt_m16"] = {
    ["value"] = 205
  },
  ["weapon_ap_hbadger"] = {
    ["value"] = 215
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
  ["models/player/smith.mdl"] = {
    ["value"] = 70
  },
  ["models/player/spacesuit.mdl"] = {
    ["value"] = 87
  },
  ["models/player/p2_chell.mdl"] = {
    ["value"] = 100
  },
  ["models/player/linktp.mdl"] = {
    ["value"] = 115
  },
  ["models/player/subzero.mdl"] = {
    ["value"] = 80
  },
  ["models/player/anon/anon.mdl"] = {
    ["value"] = 100
  },
  ["models/player/scorpion.mdl"] = {
    ["value"] = 111
  },
  ["models/player/faith.mdl"] = {
    ["value"] = 90
  },
  ["models/player/drpyspy/spy.mdl"] = {
    ["value"] = 115
  },
  ["models/ex-mo/quake3/players/doom.mdl"] = {
    ["value"] = 140
  },
  ["models/player/gman_high.mdl"] = {
    ["value"] = 150
  },
  ["models/player/breen.mdl"] = {
    ["value"] = 150
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
  ["models/norpo/ArkhamOrigins/Assassins/Deathstroke_ValveBiped.mdl"] = {
    ["value"] = 175
  },
  ["models/player/sam.mdl"] = {
    ["value"] = 125
  },
  ["models/player/robber.mdl"] = {
    ["value"] = 155
  },
  ["models/player/zelda.mdl"] = {
    ["value"] = 155
  },
  ["models/player/alice.mdl"] = {
    ["value"] = 150
  },
  ["models/player/macdguy.mdl"] = {
    ["value"] = 140
  },
  ["models/player/rorschach.mdl"] = {
    ["value"] = 170
  },
  ["models/Avengers/Iron Man/mark7_player.mdl"] = {
    ["value"] = 160
  },
}

vipPlayerModels = {
  ["models/player/mcsteve.mdl"] = {
    ["value"] = 150
  },
  ["models/player/nuggets.mdl"] = {
    ["value"] = 120
  },
  ["models/player/chewbacca.mdl"] = {
    ["value"] = 100
  },
  ["models/player/teslapower.mdl"] = {
    ["value"] = 165
  },
  ["models/half-dead/Gopniks/extra/playermodelonly.mdl"] = {
    ["value"] = 107
  },
  ["models/player/foohysaurusrex.mdl"] = {
    ["value"] = 135
  },
  ["models/player/scarecrow.mdl"] = {
    ["value"] = 100
  },
  ["models/player/security_suit.mdl"] = {
    ["value"] = 125
  },
  ["models/player/darky_m/rust/hazmat.mdl"] = {
    ["value"] = 122
  }
}

exclusiveModels = {
  ["76561198037289710"] = {
    {
      ["type"] = "playerModel",
      ["modelName"] = "models/player/big_boss.mdl"
    }
  },
  ["76561198891822681"] = {
    {
      ["type"] = "playerModel",
      ["modelName"] = "models/player/plague_doktor/PLAYER_Plague_Doktor.mdl"
    }
  }
}

roles = {
  "admin",
  "moderator",
  "vip",
  "player"
}

-- Flip the table so that the indexes go up (player = 1, admin = 4, etc)
-- Becuase it makes more sense for higher roles to have higher indexes
roles = table.Reverse(roles)

allWeapons = {}

local function FilterWeaponsAndAddToIndex(weaponsTable)
  for key, value in pairs(weaponsTable) do
    if weapons.Get(key) ~= nil then
      allWeapons[key] = value
    else
      print("[Lootbox] WARNING: Weapon removed from loottable! " .. key)
    end
  end
end

FilterWeaponsAndAddToIndex(primaryWeapons)
FilterWeaponsAndAddToIndex(secondaryWeapons)
FilterWeaponsAndAddToIndex(meleeWeapons)

local function FilterPlayerModelsTable(playerModelsTable)
  for key, value in pairs(playerModelsTable) do
    if not file.Exists(key, "GAME") and not util.IsValidModel(key) then
      playerModelsTable[key] = nil
      print("[Lootbox] WARNING: PlayerModel removed from loottable! " .. key)
    end
  end
end

FilterPlayerModelsTable(playerModels)
FilterPlayerModelsTable(vipPlayerModels)

local function ValidateExclusiveItems()
  for steam64, items in pairs(exclusiveModels) do
    for itemIndex, item in ipairs(items) do
      if item.type == "playerModel" and not file.Exists(item.modelName, "GAME") and not util.IsValidModel(item.modelName) then
        exclusiveModels[steam64][itemIndex] = nil
        print("[Lootbox] WARNING: PlayerModel removed from exclusives! " .. steam64 .. " " .. item.modelName)
      end
    end
  end
end

ValidateExclusiveItems()

weaponTiers = {
  {
    ["name"] = "Common",
    ["multiplier"] = 0.65
  },
  {
    ["name"] = "Uncommon",
    ["multiplier"] = 1.25
  },
  {
    ["name"] = "Rare",
    ["multiplier"] = 1.5
  },
  {
    ["name"] = "Legendary",
    ["multiplier"] = 1.75
  },
  {
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

local vipPlayerModelsSum = 0
for i, key in pairs(table.GetKeys(vipPlayerModels)) do
  vipPlayerModelsSum = vipPlayerModelsSum + vipPlayerModels[key].value
end
local vipPlayersModelAveragePrice = math.ceil(vipPlayerModelsSum / table.Count(vipPlayerModels) * 1.75)

fixedStoreItems = {
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
    ["type"] = "crate_vip",
    ["value"] = math.ceil(vipPlayersModelAveragePrice * 2),
    ["role"] = "vip"
  }
}

storeItems = {}
table.Add(storeItems, fixedStoreItems)

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
  ["Fortnite Mandalorian"] = "Mandalorian",
  ["Shadow_Guard"] = "Shadow Guard",
  ["Sovereign_Protector"] = "Sovereign Protector"
}
