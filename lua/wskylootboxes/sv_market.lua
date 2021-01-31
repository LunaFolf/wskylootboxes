if CLIENT then return end

util.AddNetworkString("WskyTTTLootboxes_BuyFromMarket")

net.Receive("WskyTTTLootboxes_BuyFromMarket", function (len, ply)
  local steam64 = ply:SteamID64()
  local playerData = getPlayerData(steam64)
  local marketData = getMarketData()
  local marketItemID = net.ReadFloat()

  if (!marketItemID) then
    givePlayerError(ply)
    return
  end

  local item = table.Copy(marketData.items[marketItemID])
  local marketItemCost = item.value
  local buyerIsOwner = (item.owner == steam64)

  if (!buyerIsOwner and (!item or (playerData.scrap < item.value))) then return end

  local newItem = table.Copy(item)
  newItem.owner = nil
  newItem.ownerName = nil
  newItem.itemID = nil

  local itemID = uuid()
  local itemTable = {
    [itemID] = newItem
  }

  local tierNum = nil

  for index, tier in ipairs(weaponTiers) do
    if (tier.name == itemTable[itemID].tier) then tierNum = index end
  end

  local baseItem = nil

  if (string.StartWith(item.type, "crate_")) then
    -- overwrite crate values to avoid weird inflation shit
    itemTable[itemID].value = 10
  elseif (item.type == "weapon") then
    baseItem = allWeapons[item.className]
  elseif (item.type == "playerModel") then
    baseItem = playerModels[item.modelName]
  end

  itemTable[itemID].value = math.Round(valueDepreciationFn() * generateItemValue(item.type, tierNum, baseItem.value))

  table.Merge(playerData.inventory, itemTable)
  savePlayerData(steam64, playerData)

  if (!buyerIsOwner) then
    playerData = updatePlayerScrap(steam64, playerData.scrap - marketItemCost)
  end
  table.remove(marketData.items, marketItemID)
  saveMarketData(marketData)

  local owner = player.GetBySteamID64(item.owner)
  local ownerPlayerData = getPlayerData(item.owner)
  if (!buyerIsOwner) then
    ownerPlayerData = updatePlayerScrap(item.owner, ownerPlayerData.scrap + marketItemCost)
  end
  savePlayerData(item.owner, ownerPlayerData)

  sendClientFreshPlayerData(ply, nil, playerData)
  sendClientFreshMarketData(nil, nil)
  if (owner and item.owner ~= steam64) then
    messagePlayer(owner, ply:Nick() .. " Bought your " .. getItemName(item) .. "!")
    sendClientFreshPlayerData(owner, nil, ownerPlayerData)
  elseif (buyerIsOwner) then
    messagePlayer(owner, "Your " .. getItemName(item) .. " has been taken off the market.")
  end

  net.Start("WskyTTTLootboxes_OpenPlayerInventory")
    net.WriteString("market")
  net.Send(ply)

  net.Start("WskyTTTLootboxes_ClientsideWinItem")
    net.WriteString(itemTable[itemID].tier == "Exotic" and "wsky_lootboxes/confetti.wav" or "wsky_lootboxes/purchase.wav")
    net.WriteTable(itemTable[itemID])
    net.WriteBool(false)
  net.Send(ply)
end)
