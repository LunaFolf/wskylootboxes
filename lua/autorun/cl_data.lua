if SERVER then return end

playerData = nil

function requestNewData(openPlayerMenu)
  net.Start("WskyTTTLootboxes_ClientRequestData")
    net.WriteBool(openPlayerMenu)
  net.SendToServer()
end

net.Receive("WskyTTTLootboxes_ClientReceiveData", function (len, ply)
  local inventory = net.ReadTable()
  playerData = inventory
end)