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

  local itemID = uuid()
  local itemTable = {
    [itemID] = item
  }

  if (string.StartWith(item.type, "crate_")) then
    itemTable[itemID].value = 10
  elseif (item.type == "weapon") then
    local baseItem = allWeapons[item.className]
    itemTable[itemID].value = math.Round(valueDepreciationFn() * baseItem.value)
  elseif (item.type == "playerModel") then
    local baseItem = playerModels[item.modelName]
    itemTable[itemID].value = math.Round(valueDepreciationFn() * baseItem.value)
  end

  table.Merge(playerData.inventory, itemTable)
  if (!buyerIsOwner) then playerData.scrap = playerData.scrap - marketItemCost end
  marketData.items[marketItemID] = nil
  savePlayerData(steam64, playerData)
  saveMarketData(marketData)

  local owner = player.GetBySteamID64(item.owner)
  local ownerPlayerData = getPlayerData(item.owner)
  ownerPlayerData.scrap = ownerPlayerData.scrap + marketItemCost
  savePlayerData(item.owner, ownerPlayerData)

  sendClientFreshData(ply, playerData)
  if (owner) then
    messagePlayer(owner, ply:Nick() .. " Bought your " .. (item.className or item.modelName) .. "!")
    sendClientFreshData(owner, ownerPlayerData)
  end

  net.Start("WskyTTTLootboxes_OpenPlayerInventory")
  net.Send(ply)
end)