if SERVER then return end

playerData = nil
storeItems = nil
marketData = nil

function requestNewData(openPlayerMenu)
  net.Start("WskyTTTLootboxes_ClientRequestPlayerData")
    net.WriteBool(openPlayerMenu)
  net.SendToServer()
end

net.Receive("WskyTTTLootboxes_ClientReceiveData", function (len, ply)
  local data = net.ReadTable()
  local freshPlayerData = data["player"]
  local availableStoreItems = data["store"]
  local freshMarketData = data["market"]

  local inventoryKeys = table.GetKeys(freshPlayerData.inventory)

  if (table.Count(inventoryKeys)) then
    table.sort(inventoryKeys, function (a, b)
      local aData = freshPlayerData.inventory[a]
      local bData = freshPlayerData.inventory[b]

      return aData.createdAt < bData.createdAt
    end)

    local sortedInventory = {}
    for index, ID in pairs(inventoryKeys) do
      local item = freshPlayerData.inventory[ID]
      item.itemID = ID
      table.Merge(sortedInventory, {
        [index] = item
      })
    end

    freshPlayerData.inventory = sortedInventory
  end

  playerData = freshPlayerData
  storeItems = availableStoreItems
  marketData = freshMarketData
end)