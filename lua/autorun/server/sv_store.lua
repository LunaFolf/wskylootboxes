if CLIENT then return end

util.AddNetworkString("WskyTTTLootboxes_BuyFromStore")

net.Receive("WskyTTTLootboxes_BuyFromStore", function (len, ply)
  local steam64 = ply:SteamID64()
  local playerData = getPlayerData(steam64)
  local storeItemID = net.ReadFloat()

  if (!storeItemID) then
    givePlayerError(ply)
    return
  end

  local item = table.Copy(storeItems[storeItemID])

  if (playerData.scrap < item.value) then return end

  item.createdAt = os.time()

  local itemID = uuid()
  local itemTable = {
    [itemID] = item
  }
  playerData.scrap = playerData.scrap - item.value

  itemTable[itemID].value = math.floor(itemTable[itemID].value * 0.75)

  table.Merge(playerData.inventory, itemTable)

  savePlayerData(steam64, playerData)

  sendClientFreshData(ply, playerData)

  net.Start("WskyTTTLootboxes_OpenPlayerInventory")
  net.Send(ply)

  net.Start("WskyTTTLootboxes_ClientsideWinChime")
    net.WriteString("wsky_lootboxes/item.ogg")
  net.Send(ply)
end)