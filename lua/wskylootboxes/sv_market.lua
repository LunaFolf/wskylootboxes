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

  local tierNum = nil

  for index, tier in ipairs(weaponTiers) do
    if (tier.name == itemTable[itemID].tier) then tierNum = index end
  end

  if (string.StartWith(item.type, "crate_")) then
    itemTable[itemID].value = 10
  elseif (item.type == "weapon") then
    local baseItem = allWeapons[item.className]
    itemTable[itemID].value = math.Round(valueDepreciationFn() * generateItemValue("weapon", tierNum, baseItem.value))
  elseif (item.type == "playerModel") then
    local baseItem = playerModels[item.modelName]
    itemTable[itemID].value = math.Round(valueDepreciationFn() * generateItemValue("playerModel", tierNum, baseItem.value))
  end

  table.Merge(playerData.inventory, itemTable)
  if (!buyerIsOwner) then playerData.scrap = playerData.scrap - marketItemCost end
  marketData.items[marketItemID] = nil
  savePlayerData(steam64, playerData)
  saveMarketData(marketData)

  local owner = player.GetBySteamID64(item.owner)
  local ownerPlayerData = getPlayerData(item.owner)
  if (!buyerIsOwner) then ownerPlayerData.scrap = ownerPlayerData.scrap + marketItemCost end
  savePlayerData(item.owner, ownerPlayerData)

  sendClientFreshPlayerData(ply, playerData)
  sendClientFreshMarketData()
  if (owner and item.owner ~= steam64) then
    messagePlayer(owner, ply:Nick() .. " Bought your " .. getItemName(item) .. "!")
    sendClientFreshPlayerData(owner, ownerPlayerData)
  elseif (buyerIsOwner) then
    messagePlayer(owner, "Your " .. getItemName(item) .. " has been taken off the market.")
  end

  net.Start("WskyTTTLootboxes_OpenPlayerInventory")
    net.WriteString("market")
  net.Send(ply)

  net.Start("WskyTTTLootboxes_ClientsideWinItem")
    net.WriteString(itemTable[itemID].tier == "Exotic" and "wsky_lootboxes/partyblower.mp3" or "wsky_lootboxes/item.ogg")
    net.WriteTable(itemTable[itemID])
    net.WriteBool(false)
  net.Send(ply)
end)