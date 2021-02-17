if CLIENT then return end

util.AddNetworkString("WskyTTTLootboxes_ClientsideUpdateWeaponName")
util.AddNetworkString("WskyTTTLootboxes_ClientDeathMessage")

local playersInSpectateMode = {}

hook.Add("PlayerSpawn", "WskyTTTLootboxes_GiveActiveWeapons", function (ply)
  local steam64 = ply:SteamID64()
  if (!steam64) then return end

  table.RemoveByValue(playersInSpectateMode, steam64)

  local playerData = getPlayerData(steam64)

  for i, itemID in ipairs(playerData.loadout) do
    local item = getPlayerItem(playerData, itemID)
    if !item then return end

    local itemCategory = getWeaponCategory(item.className)

    local weapon = ply:Give(item.className)
    weapon:SetNWString("exoticParticleEffect", item.exoticParticleEffect)
    net.Start("WskyTTTLootboxes_ClientsideUpdateWeaponName")
      net.WriteTable(item)
      net.WriteString(item.className)
    net.Send(ply)
  end

  timer.Simple(0.2, function ()
    SetPlayerModel(ply)
  end)

  postToJaxbot("gameEvent",

  -- BodyData crap
  {
    ["gamemode"] = engine.ActiveGamemode(),
    ["event_type"] = "respawn",
    ["steamid"] = steam64
  })
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

  timer.Simple(0.2, function ()
    postToJaxbot("gameEvent",

    -- BodyData crap
    {
      ["gamemode"] = engine.ActiveGamemode(),
      ["event_type"] = "round_end"
    })
  end)
end)

hook.Add("PlayerDeath", "WskyTTTLootboxes_PlayerDeathMessage", function (victim, inflictor, attacker)
  print(victim, inflictor, attacker)

  local attackerRole = attacker.GetRole and attacker:GetRole() or 0
  local wep = attacker.GetActiveWeapon and attacker:GetActiveWeapon() or nil
  local weaponName = ""
  local weaponNameIsClass = false

  local deathByExplosion = false

  if (inflictor.GetClass and inflictor:GetClass() == "env_explosion") then
    deathByExplosion = true
    wep = nil
    weaponName = "Explosion"
  end

  local fallback = "#NOCUSTOM#"

  if wep and wep:IsValid() then
    local customWeaponName = wep:GetNWString("customName", fallback)
    if customWeaponName == fallback then weaponNameIsClass = true end
    weaponName = (customWeaponName ~= fallback and customWeaponName or wep:GetClass())
  end

  local suicide = victim == attacker
  if (attacker.GetClass and attacker:GetClass() == "worldspawn") then suicide = true end

  net.Start("WskyTTTLootboxes_ClientDeathMessage")
    net.WriteString(attacker.Nick and attacker:Nick() or "")
    net.WriteFloat(attackerRole)
    net.WriteString(weaponName)
    net.WriteBool(weaponNameIsClass)
    net.WriteBool(suicide)
  net.Send(victim)

  postToJaxbot("gameEvent",

  -- BodyData crap
  {
    ["gamemode"] = engine.ActiveGamemode(),
    ["event_type"] = "death",
    ["attacker_nickname"] = attacker:Nick(),
    ["attacker_steamid"] = attacker:SteamID64(),
    ["victim_nickname"] = victim:Nick(),
    ["victim_steamid"] = victim:SteamID64(),
    ["cause_of_death"] = suicide and "Suicide" or weaponName
  })
end)

hook.Add("PlayerDroppedWeapon", "WskyTTTLootboxes_WeaponDropped", function (owner, weapon)
  if (!weapon or !weapon:IsValid()) then return end

  clearParticlesOnPlayer(weapon)

  local particleEffect = weapon:GetNWString("exoticParticleEffect")
  if (particleEffect ~= "") then spawnParticleOnPlayer("weapon_world", particleEffect, weapon) end
end)
