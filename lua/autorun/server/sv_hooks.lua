if CLIENT then return end

util.AddNetworkString("WskyTTTLootboxes_ClientsideUpdateWeaponName")

hook.Add("PlayerSpawn", "WskyTTTLootboxes_GiveActiveWeapons", function (ply)
  local steam64 = ply:SteamID64()
  if (!steam64) then return end

  local playerData = getPlayerData(steam64)
  local primaryWeapon, secondaryWeapon, meleeWeapon = playerData.activePrimaryWeapon, playerData.activeSecondaryWeapon, playerData.activeMeleeWeapon 

  if (primaryWeapon and primaryWeapon.className ~= "") then
    local weapon = ply:Give(primaryWeapon.className)
    weapon:SetNWString("exoticParticleEffect", primaryWeapon.exoticParticleEffect)
    net.Start("WskyTTTLootboxes_ClientsideUpdateWeaponName")
      net.WriteTable(primaryWeapon)
      net.WriteString(weapon.ClassName)
    net.Send(ply)
  end
  
  if (secondaryWeapon and secondaryWeapon.className ~= "") then
    local weapon = ply:Give(secondaryWeapon.className)
    weapon:SetNWString("exoticParticleEffect", secondaryWeapon.exoticParticleEffect)
    net.Start("WskyTTTLootboxes_ClientsideUpdateWeaponName")
      net.WriteTable(secondaryWeapon)
      net.WriteString(weapon.ClassName)
    net.Send(ply)
  end
  
  if (meleeWeapon and meleeWeapon.className ~= "") then
    local weapon = ply:Give(meleeWeapon.className)
    weapon:SetNWString("exoticParticleEffect", meleeWeapon.exoticParticleEffect)
    net.Start("WskyTTTLootboxes_ClientsideUpdateWeaponName")
      net.WriteTable(meleeWeapon)
      net.WriteString(weapon.ClassName)
    net.Send(ply)
  end

  timer.Simple(2, function ()
    SetPlayerModel(ply)
  end)
end)

hook.Add("TTTPrepareRound", "WskyTTTLootboxes_TTTPrepareRound", function ()
  timer.Simple(0.2, GetPlayersAndSetModels)
  timer.Create("WskyTTTLootboxes_CheckPlayerModelChange", 2, 0, GetPlayersAndSetModels)
end)

hook.Add("TTTBeginRound", "WskyTTTLootboxes_TTTBeginRound", function ()
  timer.Destroy("WskyTTTLootboxes_CheckPlayerModelChange")
  timer.Simple(0.2, GetPlayersAndSetModels)
end)

hook.Add("TTTEndRound", "WskyTTTLootboxes_TTTEndRound", function ()
  timer.Destroy("WskyTTTLootboxes_CheckPlayerModelChange")
  timer.Simple(0.2, GetPlayersAndSetModels)
  GiveOutFreeCrates()
end)

-- hook.Add("PlayerSwitchWeapon", "WskyTTTLootboxes_WeaponSwitch", function (ply, oldWeapon, newWeapon)
--   if (oldWeapon == newWeapon) then return end

--   clearParticlesOnPlayer(oldWeapon)
--   clearParticlesOnPlayer(newWeapon)

--   local particleEffect = newWeapon:GetNWString("exoticParticleEffect")
--   if (particleEffect ~= "") then spawnParticleOnPlayer("weapon", particleEffect, ply) end
-- end)

hook.Add("PlayerDroppedWeapon", "WskyTTTLootboxes_WeaponDropped", function (owner, weapon)
  if (!weapon or !weapon:IsValid()) then return end

  clearParticlesOnPlayer(weapon)

  local particleEffect = weapon:GetNWString("exoticParticleEffect")
  if (particleEffect ~= "") then spawnParticleOnPlayer("weapon_world", particleEffect, weapon) end
end)