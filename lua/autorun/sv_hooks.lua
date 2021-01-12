if CLIENT then return end

hook.Add("PlayerSpawn", "WskyTTTLootboxes_GiveActiveWeapons", function (ply)
  local steam64 = ply:SteamID64()
  if (!steam64) then return end

  local playerData = getPlayerData(steam64)
  local primaryWeapon, secondaryWeapon, meleeWeapon = playerData.activePrimaryWeapon, playerData.activeSecondaryWeapon, playerData.activeMeleeWeapon 
  
  if (primaryWeapon and primaryWeapon.className) then
    ply:Give(primaryWeapon.className)
  end
  
  if (secondaryWeapon and secondaryWeapon.className) then
    ply:Give(secondaryWeapon.className)
  end
  
  if (meleeWeapon and meleeWeapon.className) then
    ply:Give(meleeWeapon.className)
  end

  timer.Simple(2, function ()
    local playerModel = playerData.activePlayerModel.modelName
    local hasCustomModel = string.len(playerModel) > 0

    local modelIsDifferentFromCurrent = ( string.lower(playerModel) ~= string.lower(ply:GetModel()) )
    local needToUpdateModel = (hasCustomModel and modelIsDifferentFromCurrent)

    if (needToUpdateModel) then
      SetPlayerModel(ply, playerModel)
    end
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