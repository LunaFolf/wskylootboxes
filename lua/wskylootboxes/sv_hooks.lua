if CLIENT then return end

util.AddNetworkString("WskyTTTLootboxes_ClientsideUpdateWeaponName")
util.AddNetworkString("WskyTTTLootboxes_ClientDeathMessage")

local playersInSpectateMode = {}

hook.Add("PlayerSpawn", "WskyTTTLootboxes_GiveActiveWeapons", function (ply)
  local steam64 = ply:SteamID64()
  if (!steam64) then return end

  table.RemoveByValue(playersInSpectateMode, steam64)

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

function voidSpectators()
  for _, ply in pairs(player.GetAll()) do
    if ply:GetObserverMode() > 0 then table.insert(playersInSpectateMode, ply:SteamID64()) end
  end
end

hook.Add("TTTPrepareRound", "WskyTTTLootboxes_TTTPrepareRound", function ()
  playersInSpectateMode = {}
  timer.Simple(0.2, GetPlayersAndSetModels)
  timer.Create("WskyTTTLootboxes_CheckPlayerModelChange", 2, 0, GetPlayersAndSetModels)
end)

hook.Add("TTTBeginRound", "WskyTTTLootboxes_TTTBeginRound", function ()
  voidSpectators()
  timer.Destroy("WskyTTTLootboxes_CheckPlayerModelChange")
  timer.Simple(0.2, GetPlayersAndSetModels)
end)

hook.Add("TTTEndRound", "WskyTTTLootboxes_TTTEndRound", function ()
  timer.Destroy("WskyTTTLootboxes_CheckPlayerModelChange")
  timer.Simple(0.2, GetPlayersAndSetModels)
  GiveOutFreeCrates(playersInSpectateMode)
end)

hook.Add("PlayerDeath", "WskyTTTLootboxes_PlayerDeathMessage", function (victim, inflictor, attacker)
  if !victim:IsPlayer() or !attacker:IsPlayer() then return end

  local attackerRole = attacker:GetRole()
  local wep = attacker:GetActiveWeapon()
  local weaponName = ""
  local weaponNameIsClass = false

  local fallback = "#NOCUSTOM#"

  if wep:IsValid() then 
    local customWeaponName = wep:GetNWString("customName", fallback)
    if customWeaponName == fallback then weaponNameIsClass = true end
    weaponName = (customWeaponName ~= fallback and customWeaponName or wep:GetClass())
  end

  net.Start("WskyTTTLootboxes_ClientDeathMessage")
    net.WriteString(attacker:Nick())
    net.WriteFloat(attackerRole)
    net.WriteString(weaponName)
    net.WriteBool(weaponNameIsClass)
  net.Send(victim)
end)

hook.Add("PlayerDroppedWeapon", "WskyTTTLootboxes_WeaponDropped", function (owner, weapon)
  if (!weapon or !weapon:IsValid()) then return end

  clearParticlesOnPlayer(weapon)

  local particleEffect = weapon:GetNWString("exoticParticleEffect")
  if (particleEffect ~= "") then spawnParticleOnPlayer("weapon_world", particleEffect, weapon) end
end)