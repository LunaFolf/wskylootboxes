if CLIENT then return end

util.AddNetworkString("WskyTTTLootboxes_ClientRequestPlayerData")
util.AddNetworkString("WskyTTTLootboxes_ClientRequestMarketData")
util.AddNetworkString("WskyTTTLootboxes_ClientRequestStoreData")
util.AddNetworkString("WskyTTTLootboxes_ClientReceiveData")

dir = "wsky/Lootboxes"

function getStarterMarketData()
  return {
    ["items"] = {}
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

function sendClientFreshPlayerData(player, playerData, openMenu)
  sendPlayerData(player, {
    ["player"] = playerData or getPlayerData(player:SteamID64())
  }, openMenu and "inventory" or nil)
end

function sendClientFreshMarketData(players, marketData, openMenu)
  if (type(players) == "Player") then
    players = { players }
  elseif(!players) then players = player.GetAll() end

  for i, player in ipairs(players) do
    sendPlayerData(player, {
      ["market"] = marketData or getMarketData()
    }, openMenu and "market" or nil)
  end
end

function sendClientFreshStoreData(player, openMenu)
  sendPlayerData(player, {
    ["store"] = storeItems
  }, openMenu and "store" or nil)
end

function sendPlayerData(ply, data, openMenu)
  if (!ply or !data) then return end

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
  sendClientFreshPlayerData(ply, nil, openMenu)
end)

net.Receive("WskyTTTLootboxes_ClientRequestStoreData", function (len, ply)
  local openMenu = net.ReadBool()
  sendClientFreshStoreData(ply, openMenu)
end)

net.Receive("WskyTTTLootboxes_ClientRequestMarketData", function (len, ply)
  local openMenu = net.ReadBool()
  sendClientFreshMarketData(ply, nil, openMenu)
end)