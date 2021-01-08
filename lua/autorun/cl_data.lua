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
  playerData = freshPlayerData
  storeItems = availableStoreItems
  marketData = freshMarketData
end)