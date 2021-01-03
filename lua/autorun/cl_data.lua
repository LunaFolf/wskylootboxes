local inventoryData = nil

function requestNewData()
  net.Start("WskyTTTLootboxes_ClientRequestData")
  net.SendToServer()
end

net.Receive("WskyTTTLootboxes_ClientReceiveData", function (len, ply)
  local inventory = net.ReadTable()
  inventoryData = inventory
  PrintTable(inventory)
end)