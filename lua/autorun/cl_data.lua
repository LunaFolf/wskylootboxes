if SERVER then return end

playerData = nil
storeItems = nil
marketData = nil

function requestNewData(openPlayerMenu)
  net.Start("WskyTTTLootboxes_ClientRequestData")
    net.WriteBool(openPlayerMenu)
  net.SendToServer()
end

net.Receive("WskyTTTLootboxes_ClientReceiveData", function (len, ply)
  local freshPlayerData = net.ReadTable()
  local availableStoreItems = net.ReadTable()
  local freshMarketData = net.ReadTable()

  local inventoryKeys = table.GetKeys(freshPlayerData.inventory)

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

  playerData = freshPlayerData
  storeItems = availableStoreItems
  marketData = freshMarketData
end)