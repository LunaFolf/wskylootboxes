if SERVER then return end

playerData = nil
storeItems = nil
marketData = nil
leaderboardData = nil
pagination = {
  ["totalPages"] = 1,
  ["currentPage"] = 1
}

function requestFreshPlayerData(openMenu)
  print("requesting data")
  net.Start("WskyTTTLootboxes_ClientRequestPlayerData")
    net.WriteBool(openMenu)
    net.WriteFloat(pagination.currentPage)
  net.SendToServer()
end

function requestFreshStoreData(openMenu)
  net.Start("WskyTTTLootboxes_ClientRequestStoreData")
    net.WriteBool(openMenu)
  net.SendToServer()
end

function requestFreshMarketData(openMenu)
  net.Start("WskyTTTLootboxes_ClientRequestMarketData")
    net.WriteBool(openMenu)
  net.SendToServer()
end

function requestFreshLeaderboardData(openMenu)
  net.Start("WskyTTTLootboxes_ClientRequestLeaderboardData")
    net.WriteBool(openMenu)
  net.SendToServer()
end

net.Receive("WskyTTTLootboxes_ClientReceiveData", function (len, ply)
  local data = net.ReadTable()

  PrintTable(data)

  local freshPlayerData = data["player"]
  local availableStoreItems = data["store"]
  local freshMarketData = data["market"]
  local freshLeaderboardData = data["leaderboard"]
  local freshPagination = data["pagination"]

  if freshPagination then pagination = freshPagination end
  if freshPlayerData then playerData = freshPlayerData end
  if availableStoreItems then storeItems = availableStoreItems end
  if freshMarketData then marketData = freshMarketData end
  if freshLeaderboardData then leaderboardData = freshLeaderboardData end

  if (menuRef) then renderMenu(lastTab) end
end)