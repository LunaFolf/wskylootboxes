if CLIENT then return end

util.AddNetworkString("WskyTTTLootboxes_SellItem")
util.AddNetworkString("WskyTTTLootboxes_ScrapItem")
util.AddNetworkString("WskyTTTLootboxes_EquipItem")
util.AddNetworkString("WskyTTTLootboxes_UnequipItem")

function unEquipItem(playerData, itemID)
  local item = playerData.inventory[itemID]

  if (!item) then 
    givePlayerError(ply)
  end

  if (item.type == "weapon") then
    local weaponCategory = getWeaponCategory(item.className)
    local unsetWeaponTable = {
      ["itemID"] = "",
      ["className"] = ""
    }

    if (weaponCategory == "primary" and playerData.activePrimaryWeapon.itemID == itemID) then
      playerData.activePrimaryWeapon = unsetWeaponTable
    elseif (weaponCategory == "secondary" and playerData.activeSecondaryWeapon.itemID == itemID) then
      playerData.activeSecondaryWeapon = unsetWeaponTable
    elseif (weaponCategory == "melee" and playerData.activeMeleeWeapon.itemID == itemID) then
      playerData.activeMeleeWeapon = unsetWeaponTable
    end
  end

  if (item.type == "playerModel" and playerData.activePlayerModel.itemID == itemID) then
    local unsetPlayerModelTable = {
      ["itemID"] = "",
      ["modelName"] = GAMEMODE.playermodel or "models/player/phoenix.mdl"
    }
    playerData.activePlayerModel = unsetPlayerModelTable
  end

  return playerData
end

net.Receive("WskyTTTLootboxes_SellItem", function (len, ply)
  local steam64 = ply:SteamID64()
  local playerData = getPlayerData(steam64)
  local marketData = getMarketData()
  local itemID = net.ReadString()
  local valueToSell = net.ReadFloat()

  if (!itemID) then
    givePlayerError(ply)
    return
  end

  unEquipItem(playerData, itemID)

  local item = table.Copy(playerData.inventory[itemID])
  if (!item) then return end
  item.value = valueToSell
  item.owner = steam64
  item.ownerName = ply:GetName()

  table.Add(marketData.items, {item})
  playerData.inventory[itemID] = nil

  saveMarketData(marketData)
  savePlayerData(steam64, playerData)

  sendClientFreshData(ply, playerData)

  net.Start("WskyTTTLootboxes_OpenPlayerInventory")
  net.Send(ply)
end)

net.Receive("WskyTTTLootboxes_ScrapItem", function (len, ply)
  local steam64 = ply:SteamID64()
  local playerData = getPlayerData(steam64)
  local itemID = net.ReadString()

  if (!itemID) then
    givePlayerError(ply)
    return
  end

  unEquipItem(playerData, itemID)

  playerData.scrap = playerData.scrap + playerData.inventory[itemID].value
  playerData.inventory[itemID] = nil

  savePlayerData(steam64, playerData)

  sendClientFreshData(ply, playerData)

  net.Start("WskyTTTLootboxes_OpenPlayerInventory")
  net.Send(ply)
end)

net.Receive("WskyTTTLootboxes_EquipItem", function (len, ply)
  if (!len or !ply) then return end
  local steam64 = ply:SteamID64()
  local playerData = getPlayerData(steam64)
  local itemID = net.ReadString()

  if (!itemID) then
    givePlayerError(ply)
    return
  end

  local item = playerData.inventory[itemID]

  if (!item) then
    givePlayerError(ply)
    return
  end

  if (item.type == "playerModel") then
    if (!item or !item.modelName) then
      givePlayerError(ply)
      return
    end

    playerData.activePlayerModel.modelName = item.modelName
    playerData.activePlayerModel.exoticParticleEffect = item.exoticParticleEffect or nil
    playerData.activePlayerModel.itemID = itemID
  end

  if (item.type == "weapon") then
    if (!item or !item.className) then
      givePlayerError(ply)
      return
    end

    local weaponCategory = getWeaponCategory(item.className)

    if(weaponCategory == "primary") then
      playerData.activePrimaryWeapon.className = item.className
      playerData.activePrimaryWeapon.itemID = itemID
    elseif(weaponCategory == "secondary") then
      playerData.activeSecondaryWeapon.className = item.className
      playerData.activeSecondaryWeapon.itemID = itemID
    elseif(weaponCategory == "melee") then
      playerData.activeMeleeWeapon.className = item.className
      playerData.activeMeleeWeapon.itemID = itemID
    end
  end

  savePlayerData(steam64, playerData)

  sendClientFreshData(ply, playerData)

end)

net.Receive("WskyTTTLootboxes_UnequipItem", function (len, ply)
  local steam64 = ply:SteamID64()
  local playerData = getPlayerData(steam64)
  local itemID = net.ReadString()

  if (!itemID) then
    givePlayerError(ply)
    return
  end

  unEquipItem(playerData, itemID)

  savePlayerData(steam64, playerData)

  sendClientFreshData(ply, playerData)

  net.Start("WskyTTTLootboxes_OpenPlayerInventory")
  net.Send(ply)
end)