if CLIENT then return end

util.AddNetworkString("WskyTTTLootboxes_SellItem")
util.AddNetworkString("WskyTTTLootboxes_ScrapItem")
util.AddNetworkString("WskyTTTLootboxes_EquipItem")
util.AddNetworkString("WskyTTTLootboxes_UnequipItem")
util.AddNetworkString("WskyTTTLootboxes_RenameItem")
util.AddNetworkString("WskyTTTLootboxes_PlayerModelBodyGroup")

util.AddNetworkString("WskyTTTLootboxes_SetEntityCustomName")

function unEquipItem(steam64, playerData, itemID)
  local item = playerData.inventory[itemID]

  if (!item) then
    givePlayerError(ply)
    return
  end

  if (item.type == "weapon") then
    table.RemoveByValue(playerData.loadout, itemID)
  end

  if (item.type == "playerModel" and playerData.activePlayerModel == itemID) then
    playerData.activePlayerModel = ""
  end

  savePlayerData(steam64, playerData)

  return playerData
end

net.Receive("WskyTTTLootboxes_PlayerModelBodyGroup", function (len, ply)
  local steam64 = ply:SteamID64()
  local playerData = getPlayerData(steam64)
  local itemID = net.ReadString()
  local groupID = net.ReadFloat()
  local groupValue = net.ReadFloat()

  local item = getPlayerItem(playerData, itemID)

  if !item then return end

  if !item.bodyGroups then
    table.Merge(item, {
      ["bodyGroups"] = {}
    })
  end
  item.bodyGroups[groupID] = groupValue

  savePlayerData(steam64, playerData)
end)

net.Receive("WskyTTTLootboxes_SellItem", function (len, ply)
  local steam64 = ply:SteamID64()
  local playerData = getPlayerData(steam64)
  local marketData = getMarketData()
  local itemID = net.ReadString()
  local valueToSell = net.ReadFloat()
  local pagination = net.ReadTable()

  if (!itemID) then
    givePlayerError(ply)
    return
  end

  unEquipItem(steam64, playerData, itemID)

  local item = table.Copy(playerData.inventory[itemID])
  if (!item) then return end
  item.value = valueToSell
  item.owner = steam64
  item.ownerName = ply:GetName()

  table.Add(marketData.items, {item})
  playerData.inventory[itemID] = nil

  saveMarketData(marketData)
  savePlayerData(steam64, playerData)

  sendClientFreshPlayerData(ply, pagination.currentPage, playerData)

  sendClientFreshMarketData(nil, nil)

  net.Start("WskyTTTLootboxes_ClientsideWinChime")
    net.WriteString("garrysmod/save_load2.wav")
  net.Send(ply)

  net.Start("WskyTTTLootboxes_OpenPlayerInventory")
    net.WriteString("inventory")
  net.Send(ply)
end)

net.Receive("WskyTTTLootboxes_SetEntityCustomName", function ()
  local weapon = net.ReadEntity()
  local name = net.ReadString()

  if (!weapon or !name) then return end

  weapon:SetNWString("customName", name)
end)

net.Receive("WskyTTTLootboxes_ScrapItem", function (len, ply)
  local steam64 = ply:SteamID64()
  local playerData = getPlayerData(steam64)
  local itemID = net.ReadString()
  local pagination = net.ReadTable()

  if (!itemID) then
    givePlayerError(ply)
    return
  end

  unEquipItem(steam64, playerData, itemID)

  playerData = updatePlayerScrap(steam64, playerData.scrap + playerData.inventory[itemID].value)
  playerData.inventory[itemID] = nil

  savePlayerData(steam64, playerData)

  sendClientFreshPlayerData(ply, pagination.currentPage, playerData)

  net.Start("WskyTTTLootboxes_ClientsideWinChime")
    net.WriteString("wsky_lootboxes/scrapItem.ogg")
  net.Send(ply)

  net.Start("WskyTTTLootboxes_OpenPlayerInventory")
    net.WriteString("inventory")
  net.Send(ply)
end)

net.Receive("WskyTTTLootboxes_RenameItem", function (len, ply)
  local steam64 = ply:SteamID64()
  local playerData = getPlayerData(steam64)
  local itemID = net.ReadString()
  local newItemName = net.ReadString()
  local pagination = net.ReadTable()

  if (!itemID or !newItemName) then
    givePlayerError(ply)
    return
  end

  if (playerData.scrap < 200) then return end

  playerData = updatePlayerScrap(steam64, playerData.scrap - 200)

  playerData.inventory[itemID].customName = newItemName
  savePlayerData(steam64, playerData)


  sendClientFreshPlayerData(ply, pagination.currentPage, table.Copy(playerData))

  net.Start("WskyTTTLootboxes_ClientsideWinChime")
    net.WriteString("garrysmod/content_downloaded.wav")
  net.Send(ply)

  net.Start("WskyTTTLootboxes_OpenPlayerInventory")
    net.WriteString("inventory")
  net.Send(ply)

  net.Start("WskyTTTLootboxes_ClientsideUpdateWeaponName")
    net.WriteTable(playerData.inventory[itemID])
    net.WriteString(playerData.inventory[itemID].className)
  net.Send(ply)
end)

net.Receive("WskyTTTLootboxes_EquipItem", function (len, ply)
  if (!len or !ply) then return end
  local steam64 = ply:SteamID64()
  local playerData = getPlayerData(steam64)
  local itemID = net.ReadString()
  local pagination = net.ReadTable()

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

    playerData.activePlayerModel = itemID
  end

  if (item.type == "weapon") then
    if (!item or !item.className) then
      givePlayerError(ply)
      return
    end

    local newItemCat = getWeaponCategory(item.className)
    local loadout = playerData.loadout

    for i, equippedItemID in ipairs(loadout) do
      local equippedItem = getPlayerItem(playerData, equippedItemID)
      if !equippedItem then
        loadout[i] = nil
        break
      end
      local equippedItemCat = getWeaponCategory(equippedItem.className)
      if equippedItemCat == newItemCat then table.remove(loadout, i) end
    end

    table.insert(loadout, itemID)
    playerData.loadout = loadout

  end

  savePlayerData(steam64, playerData)

  sendClientFreshPlayerData(ply, pagination.currentPage, playerData)

  net.Start("WskyTTTLootboxes_ClientsideWinChime")
    net.WriteString("garrysmod/ui_click.wav")
  net.Send(ply)

end)

net.Receive("WskyTTTLootboxes_UnequipItem", function (len, ply)
  local steam64 = ply:SteamID64()
  local playerData = getPlayerData(steam64)
  local itemID = net.ReadString()
  local pagination = net.ReadTable()

  if (!itemID) then
    givePlayerError(ply)
    return
  end

  unEquipItem(steam64, playerData, itemID)

  savePlayerData(steam64, playerData)

  sendClientFreshPlayerData(ply, pagination.currentPage, playerData)

  net.Start("WskyTTTLootboxes_OpenPlayerInventory")
    net.WriteString("inventory")
  net.Send(ply)

  net.Start("WskyTTTLootboxes_ClientsideWinChime")
    net.WriteString("garrysmod/ui_click.wav")
  net.Send(ply)
end)
