if SERVER then return end

playerData = nil
storeItems = nil

function requestNewData(openPlayerMenu)
  net.Start("WskyTTTLootboxes_ClientRequestData")
    net.WriteBool(openPlayerMenu)
  net.SendToServer()
end

net.Receive("WskyTTTLootboxes_ClientReceiveData", function (len, ply)
  print(len)
  local inventory = net.ReadTable()
  local availableStoreItems = net.ReadTable()
  playerData = inventory
  storeItems = availableStoreItems
end)