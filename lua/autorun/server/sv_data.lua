if CLIENT then return end

util.AddNetworkString("WskyTTTLootboxes_ClientRequestData")
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
      ["modelName"] = ""
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

function sendClientFreshData(ply, playerData)
  if (!ply) then return end

  net.Start("WskyTTTLootboxes_ClientReceiveData")
    net.WriteTable(playerData or getPlayerData(ply:SteamID64()))
    net.WriteTable(storeItems)
    net.WriteTable(getMarketData())
  net.Send(ply)
end

net.Receive("WskyTTTLootboxes_ClientRequestData", function (len, ply)
  local openPlayerMenu = net.ReadBool()
  sendClientFreshData(ply)

  if (openPlayerMenu) then
    net.Start("WskyTTTLootboxes_OpenPlayerInventory")
    net.Send(ply)
  end
end)