if CLIENT then return end

util.AddNetworkString("WskyTTTLootboxes_ClientRequestPlayerData")
util.AddNetworkString("WskyTTTLootboxes_ClientRequestMarketData")
util.AddNetworkString("WskyTTTLootboxes_ClientRequestStoreData")
util.AddNetworkString("WskyTTTLootboxes_ClientRequestLeaderboardData")
util.AddNetworkString("WskyTTTLootboxes_ClientReceiveData")

dir = "wsky/Lootboxes"

local paginationPerPageLimit = 9

function getPaginated(tableData, currentPage)
  if (!tableData or type(tableData) ~= "table") then return end

  if ( type(table.GetKeys(tableData)[1]) == "string" ) then
    -- decouple uuid items from their ids, makes sorting and clientside data management easier
    local tempTable = {}
    local keys = table.GetKeys(tableData)
    for i, key in ipairs(keys) do
      local item = tableData[key]
      item.itemID = key
      table.insert(tempTable, item)
    end
    tableData = tempTable
  end

  table.sort(tableData, function (a, b)
    return a.createdAt < b.createdAt
  end)

  local output = {}
  local startPos, endPos = math.max(1, (currentPage - 1) * paginationPerPageLimit), currentPage * paginationPerPageLimit
  local totalNumberOfPages = math.ceil(table.Count(tableData) / paginationPerPageLimit)

  for i=startPos,endPos do
    table.insert(output, tableData[i])
  end

  return output, totalNumberOfPages
end

function getStarterMarketData()
  return {
    ["items"] = {}
  }
end

function getLeaderboardData()
  local playerFiles, _ = file.Find(dir.."/playerdata/*.json","DATA","nameasc")
  
  local mostScrap = nil

  for i, file in ipairs(playerFiles) do
    local steam64 = string.Split(file, ".json")[1]
    local playerData = getPlayerData(steam64)
    if !mostScrap then
      mostScrap = {
        ["steam64"] = steam64,
        ["value"] = playerData.scrap
      }
    elseif (playerData.scrap > mostScrap.value) then
      mostScrap = {
        ["steam64"] = steam64,
        ["value"] = playerData.scrap
      }
    end
  end

  return {
    ["mostScrap"] = mostScrap
  }
end

function getStarterPlayerData(steam64)
  local defaultPlayerData = {
    ["activePlayerModel"] = {
      ["itemID"] = "",
      ["modelName"] = ""
    },
    ["activeMeleeWeapon"] = {
      ["itemID"] = "",
      ["className"] = ""
    },
    ["activePrimaryWeapon"] = {
      ["itemID"] = "",
      ["className"] = ""
    },
    ["activeSecondaryWeapon"] = {
      ["itemID"] = "",
      ["className"] = ""
    },
    ["scrap"] = 100,
    ["inventory"] = {
      [uuid()] = {
        ["type"] = "crate_weapon",
        ["value"] = -1,
        ["createdAt"] = os.time()
      },
      [uuid()] = {
        ["type"] = "crate_playerModel",
        ["value"] = -1,
        ["createdAt"] = os.time()
      }
    }
  }

  bonusInventoryItems = exclusiveModels[steam64]

  if (bonusInventoryItems and table.Count(bonusInventoryItems) > 0) then
    for i, item in pairs(bonusInventoryItems) do
      local classKeyName = ((item.type == "weapon") and "className" or "modelName")
      table.Merge(defaultPlayerData.inventory, {
        [uuid()] = {
          ["type"] = item.type,
          [classKeyName] = item[classKeyName],
          ["value"] = -1,
          ["createdAt"] = os.time()
        }
      })
    end
  end

  return defaultPlayerData
end

function checkAndCreateDir(dirs)
  local path = ""
  for k, dir in pairs(string.Explode("/", dirs)) do
    if not file.Exists(dir, path) then
      file.CreateDir(path .. dir)
    end
    path = path .. dir .. "/"
  end
end

function getMarketData()
  local marketData = {}

  local fileName = dir .. "/market.json"
  checkAndCreateDir(dir)
  local fileOutput = file.Read(fileName)
  if not fileOutput or string.len(fileOutput) <= 0 then
    local starterMarketData = getStarterMarketData()
    file.Write(fileName, util.TableToJSON(starterMarketData))
    marketData = starterMarketData
  else
    marketData = util.JSONToTable(fileOutput)
  end

  return marketData
end

function saveMarketData(marketData)
  if (!marketData) then return end
  local fileName = dir .. "/market.json"
  checkAndCreateDir(dir)
  
  file.Write(fileName, util.TableToJSON(marketData))
end

function getPlayerData(steam64)
  local playerInventoryData = {}
  if (!steam64) then return end

  local fileName = dir .. "/playerdata/" .. steam64 .. ".json"
  checkAndCreateDir(dir .. "/playerdata")
  local fileOutput = file.Read(fileName)
  if not fileOutput or string.len(fileOutput) <= 0 then
    local starterPlayerData = getStarterPlayerData(steam64)
    file.Write(fileName, util.TableToJSON(starterPlayerData))
    playerInventoryData = starterPlayerData
  else
    playerInventoryData = util.JSONToTable(fileOutput)
  end

  return playerInventoryData
end

function savePlayerData(steam64, playerData)
  if (!steam64 or !playerData) then return end

  local fileName = dir .. "/playerdata/" .. steam64 .. ".json"
  checkAndCreateDir(dir .. "/playerdata")
  
  file.Write(fileName, util.TableToJSON(playerData))
end

function sendClientFreshPlayerData(player, currentPage, playerData, openMenu)
  local totalPages = 1
  playerData = playerData or getPlayerData(player:SteamID64())
  playerData.inventory, totalPages = getPaginated(playerData.inventory, currentPage)
  sendPlayerData(player, currentPage, totalPages, {
    ["player"] = playerData or getPlayerData(player:SteamID64())
  }, openMenu and "inventory" or nil)
end

function sendClientFreshMarketData(players, currentPage, marketData, openMenu)
  local totalPages = 1
  if (type(players) == "Player") then
    players = { players }
  elseif(!players) then players = player.GetAll() end

  for i, player in ipairs(players) do
    sendPlayerData(player, currentPage, totalPages, {
      ["market"] = marketData or getMarketData()
    }, openMenu and "market" or nil)
  end
end

function sendClientFreshStoreData(player, currentPage, openMenu)
  local totalPages = 1
  sendPlayerData(player, currentPage, totalPages, {
    ["store"] = storeItems
  }, openMenu and "store" or nil)
end

function sendClientFreshLeaderboardData(player, currentPage, openMenu)
  local totalPages = 1
  sendPlayerData(player, currentPage, totalPages, {
    ["leaderboard"] = getLeaderboardData()
  }, openMenu and "leaderboard" or nil)
end

function sendPlayerData(ply, currentPage, totalPages, data, openMenu)
  if (!ply or !data) then return end

  data.pagination = {
    ["currentPage"] = currentPage or 1,
    ["totalPages"] = totalPages or 1
  }

  net.Start("WskyTTTLootboxes_ClientReceiveData")
    net.WriteTable(data)
  net.Send(ply)

  if (openMenu) then
    net.Start("WskyTTTLootboxes_OpenPlayerInventory")
      net.WriteString(openMenu)
    net.Send(ply)
  end
end

net.Receive("WskyTTTLootboxes_ClientRequestPlayerData", function (len, ply)
  local openMenu = net.ReadBool()
  local currentPage = net.ReadFloat()
  sendClientFreshPlayerData(ply, currentPage, nil, openMenu)
end)

net.Receive("WskyTTTLootboxes_ClientRequestStoreData", function (len, ply)
  local openMenu = net.ReadBool()
  sendClientFreshStoreData(ply, 1, openMenu)
end)

net.Receive("WskyTTTLootboxes_ClientRequestMarketData", function (len, ply)
  local openMenu = net.ReadBool()
  sendClientFreshMarketData(ply, 1, nil, openMenu)
end)

net.Receive("WskyTTTLootboxes_ClientRequestLeaderboardData", function (len, ply)
  local openMenu = net.ReadBool()
  sendClientFreshLeaderboardData(ply, 1, openMenu)
end)