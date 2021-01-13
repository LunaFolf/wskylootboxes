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

  if (!item or (playerData.scrap < item.value)) then return end

  local itemID = uuid()
  local itemTable = {
    [itemID] = item
  }

  if (string.StartWith(item.type, "crate_")) then
    itemTable[itemID].value = 10
  elseif (item.type == "weapon") then
    local baseItem = allWeapons[item.className]
    itemTable[itemID].value = math.Round(math.Rand(0.85, 1.15) * baseItem.value)
  elseif (item.type == "playerModel") then
    local baseItem = playerModels[item.modelName]
    itemTable[itemID].value = math.Round(math.Rand(0.85, 1.15) * baseItem.value)
  end

  table.Merge(playerData.inventory, itemTable)
  playerData.scrap = playerData.scrap - marketItemCost
  marketData.items[marketItemID] = nil
  savePlayerData(steam64, playerData)
  saveMarketData(marketData)

  local owner = player.GetBySteamID64(item.owner)
  local ownerPlayerData = getPlayerData(item.owner)
  ownerPlayerData.scrap = ownerPlayerData.scrap + marketItemCost
  savePlayerData(item.owner, ownerPlayerData)

  sendClientFreshData(ply, playerData)
  if (owner) then sendClientFreshData(owner, ownerPlayerData) end

  net.Start("WskyTTTLootboxes_OpenPlayerInventory")
  net.Send(ply)
end)