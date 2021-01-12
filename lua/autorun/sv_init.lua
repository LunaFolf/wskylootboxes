if CLIENT then return end

include('config.lua')
include('sv_crates.lua')
include('sv_download.lua')
include('sv_commands.lua')
include('shared.lua')

util.AddNetworkString("WskyTTTLootboxes_ClientRequestData")
util.AddNetworkString("WskyTTTLootboxes_ClientReceiveData")

util.AddNetworkString("WskyTTTLootboxes_OpenPlayerInventory")

util.AddNetworkString("WskyTTTLootboxes_RequestCrateOpening")
util.AddNetworkString("WskyTTTLootboxes_EquipItem")
util.AddNetworkString("WskyTTTLootboxes_UnequipItem")

util.AddNetworkString("WskyTTTLootboxes_BuyFromStore")
util.AddNetworkString("WskyTTTLootboxes_BuyFromMarket")

util.AddNetworkString("WskyTTTLootboxes_SellItem")
util.AddNetworkString("WskyTTTLootboxes_ScrapItem")

util.AddNetworkString("WskyTTTLootboxes_ClientsideWinChime")

local dir = "wsky/Lootboxes"

function getStarterMarketData()
  return {
    ["items"] = {}
  }
end

function getStarterPlayerData()
  return {
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
        ["value"] = -1
      },
      [uuid()] = {
        ["type"] = "crate_playerModel",
        ["value"] = -1
      }
    }
  }
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

math.randomseed(os.time())

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
    local starterPlayerData = getStarterPlayerData()
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

function getWeaponCategory(weaponClassName)
  if(table.HasValue(table.GetKeys(primaryWeapons), weaponClassName)) then
    return "primary"
  elseif(table.HasValue(table.GetKeys(secondaryWeapons), weaponClassName)) then
    return "secondary"
  elseif(table.HasValue(table.GetKeys(meleeWeapons), weaponClassName)) then
    return "melee"
  end
end

function givePlayerError(ply, message)
  local messageToPrint = message or "There was an error! Please contact staff."
  messagePlayer(ply, messageToPrint)
  error(messageToPrint)
end

function unEquipItem(playerData, itemID)
  local item = playerData.inventory[itemID]

  if (!item) then 
    givePlayerError(ply)
  end

  if (item.type == "weapon") then
    local weaponCategory = getWeaponCategory(item.className)
    local unsetWeaponTable = {
      ["itemID"] = "",
      ["className"] = ""
    }

    if (weaponCategory == "primary" and playerData.activePrimaryWeapon.itemID == itemID) then
      playerData.activePrimaryWeapon = unsetWeaponTable
    elseif (weaponCategory == "secondary" and playerData.activeSecondaryWeapon.itemID == itemID) then
      playerData.activeSecondaryWeapon = unsetWeaponTable
    elseif (weaponCategory == "melee" and playerData.activeMeleeWeapon.itemID == itemID) then
      playerData.activeMeleeWeapon = unsetWeaponTable
    end
  end

  if (item.type == "playerModel" and playerData.activePlayerModel.itemID == itemID) then
    local unsetPlayerModelTable = {
      ["itemID"] = "",
      ["modelName"] = GAMEMODE.playermodel or "models/player/phoenix.mdl"
    }
    playerData.activePlayerModel = unsetPlayerModelTable
  end

  return playerData
end


net.Receive("WskyTTTLootboxes_SellItem", function (len, ply)
  local steam64 = ply:SteamID64()
  local playerData = getPlayerData(steam64)
  local marketData = getMarketData()
  local itemID = net.ReadString()
  local valueToSell = net.ReadFloat()

  if (!itemID) then
    givePlayerError(ply)
    return
  end

  unEquipItem(playerData, itemID)

  local item = table.Copy(playerData.inventory[itemID])
  if (!item) then return end
  item.value = valueToSell
  item.owner = steam64
  item.ownerName = ply:GetName()

  table.Add(marketData.items, {item})
  playerData.inventory[itemID] = nil

  saveMarketData(marketData)
  savePlayerData(steam64, playerData)

  sendClientFreshData(ply, playerData)

  net.Start("WskyTTTLootboxes_OpenPlayerInventory")
  net.Send(ply)
end)

net.Receive("WskyTTTLootboxes_ScrapItem", function (len, ply)
  local steam64 = ply:SteamID64()
  local playerData = getPlayerData(steam64)
  local itemID = net.ReadString()

  if (!itemID) then
    givePlayerError(ply)
    return
  end

  unEquipItem(playerData, itemID)

  playerData.scrap = playerData.scrap + playerData.inventory[itemID].value
  playerData.inventory[itemID] = nil

  savePlayerData(steam64, playerData)

  sendClientFreshData(ply, playerData)

  net.Start("WskyTTTLootboxes_OpenPlayerInventory")
  net.Send(ply)
end)

net.Receive("WskyTTTLootboxes_ClientRequestData", function (len, ply)
  local openPlayerMenu = net.ReadBool()
  sendClientFreshData(ply)

  if (openPlayerMenu) then
    net.Start("WskyTTTLootboxes_OpenPlayerInventory")
    net.Send(ply)
  end
end)

net.Receive("WskyTTTLootboxes_EquipItem", function (len, ply)
  if (!len or !ply) then return end
  local steam64 = ply:SteamID64()
  local playerData = getPlayerData(steam64)
  local itemID = net.ReadString()

  if (!itemID) then
    givePlayerError(ply)
    return
  end

  local item = playerData.inventory[itemID]

  if (!item) then
    givePlayerError(ply)
    return
  end

  if (item.type == "playerModel") then
    if (!item or !item.modelName) then
      givePlayerError(ply)
      return
    end

    playerData.activePlayerModel.modelName = item.modelName
    playerData.activePlayerModel.itemID = itemID
  end

  if (item.type == "weapon") then
    if (!item or !item.className) then
      givePlayerError(ply)
      return
    end

    local weaponCategory = getWeaponCategory(item.className)

    if(weaponCategory == "primary") then
      playerData.activePrimaryWeapon.className = item.className
      playerData.activePrimaryWeapon.itemID = itemID
    elseif(weaponCategory == "secondary") then
      playerData.activeSecondaryWeapon.className = item.className
      playerData.activeSecondaryWeapon.itemID = itemID
    elseif(weaponCategory == "melee") then
      playerData.activeMeleeWeapon.className = item.className
      playerData.activeMeleeWeapon.itemID = itemID
    end
  end

  savePlayerData(steam64, playerData)

  sendClientFreshData(ply, playerData)

end)

net.Receive("WskyTTTLootboxes_UnequipItem", function (len, ply)
  local steam64 = ply:SteamID64()
  local playerData = getPlayerData(steam64)
  local itemID = net.ReadString()

  if (!itemID) then
    givePlayerError(ply)
    return
  end

  unEquipItem(playerData, itemID)

  savePlayerData(steam64, playerData)

  sendClientFreshData(ply, playerData)

  net.Start("WskyTTTLootboxes_OpenPlayerInventory")
  net.Send(ply)
end)

net.Receive("WskyTTTLootboxes_BuyFromStore", function (len, ply)
  local steam64 = ply:SteamID64()
  local playerData = getPlayerData(steam64)
  local storeItemID = net.ReadFloat()

  if (!storeItemID) then
    givePlayerError(ply)
    return
  end

  local item = table.Copy(storeItems[storeItemID])

  if (playerData.scrap < item.value) then return end

  local itemID = uuid()
  local itemTable = {
    [itemID] = item
  }
  playerData.scrap = playerData.scrap - item.value

  itemTable[itemID].value = math.floor(itemTable[itemID].value * 0.75)

  table.Merge(playerData.inventory, itemTable)

  savePlayerData(steam64, playerData)

  sendClientFreshData(ply, playerData)

  net.Start("WskyTTTLootboxes_OpenPlayerInventory")
  net.Send(ply)
end)

net.Receive("WskyTTTLootboxes_BuyFromMarket", function (len, ply)
  local steam64 = ply:SteamID64()
  local playerData = getPlayerData(steam64)
  local marketData = getMarketData()
  local marketItemID = net.ReadFloat()

  if (!marketItemID) then
    givePlayerError(ply)
    return
  end

  local item = table.Copy(marketData.items[marketItemID])
  local marketItemCost = item.value

  if (!item or (playerData.scrap < item.value)) then return end

  local itemID = uuid()
  local itemTable = {
    [itemID] = item
  }

  if (string.StartWith(item.type, "crate_")) then
    itemTable[itemID].value = 10
  elseif (item.type == "weapon") then
    local baseItem = allWeapons[item.className]
    itemTable[itemID].value = math.Round(math.Rand(0.85, 1.15) * baseItem.value)
  elseif (item.type == "playerModel") then
    local baseItem = playerModels[item.modelName]
    itemTable[itemID].value = math.Round(math.Rand(0.85, 1.15) * baseItem.value)
  end

  table.Merge(playerData.inventory, itemTable)
  playerData.scrap = playerData.scrap - marketItemCost
  marketData.items[marketItemID] = nil
  savePlayerData(steam64, playerData)
  saveMarketData(marketData)

  local owner = player.GetBySteamID64(item.owner)
  local ownerPlayerData = getPlayerData(item.owner)
  ownerPlayerData.scrap = ownerPlayerData.scrap + marketItemCost
  savePlayerData(item.owner, ownerPlayerData)

  sendClientFreshData(ply, playerData)
  if (owner) then sendClientFreshData(owner, ownerPlayerData) end

  net.Start("WskyTTTLootboxes_OpenPlayerInventory")
  net.Send(ply)
end)

function generateACrate(type)
  local crate = {}
  if type then
    crate.type = type
  else
    local numOfCrateTypes = table.Count(crateTypes)
    crate.type = "crate_" .. crateTypes[math.Round(math.Rand(1, numOfCrateTypes))]
  end
  crate.value = 10

  crate.createdAt = os.time()
  
  return crate
end

function SetPlayerModel (ply, model)
  if (!ply or !model) then return end
  ply:SetModel(model)
end

function GetPlayersAndSetModels()
  for _, ply in pairs(player.GetAll()) do
    local steam64 = ply:SteamID64()
    local playerData = getPlayerData(steam64)

    local playerModel = playerData.activePlayerModel.modelName
    local hasCustomModel = string.len(playerModel) > 0

    local modelIsDifferentFromCurrent = ( string.lower(playerModel) ~= string.lower(ply:GetModel()) )
    local needToUpdateModel = (hasCustomModel and modelIsDifferentFromCurrent)
    
    if (needToUpdateModel) then
      SetPlayerModel(ply, playerModel)
    end
  end
end

function GiveOutFreeCrates()
  for _, ply in pairs(player.GetAll()) do
    local steam64 = ply:SteamID64()
    local playerData = getPlayerData(steam64)

    local shouldGetACrate = (math.Rand(0, 1)*100) >= percentageChanceToWinCrate

    if !shouldGetACrate then
      messagePlayer(ply, "Ahh bummer, you nearly got a crate! maybe next round?")
    else
      local crate = generateACrate()
      table.Merge(playerData.inventory, {
        [uuid()] = crate
      })

      savePlayerData(steam64, playerData)

      -- Let player know of their winnings, and play a little tune.
      net.Start("WskyTTTLootboxes_ClientsideWinChime")
      net.WriteString("garrysmod/save_load2.wav")
        net.WriteTable(crate)
      net.Send(ply)

      sendClientFreshData(ply, playerData)
    end
  end
end

hook.Add("PlayerSpawn", "WskyTTTLootboxes_GiveActiveWeapons", function (ply)
  local steam64 = ply:SteamID64()
  if (!steam64) then return end
  timer.Destroy("WskyTTTLootboxes_CheckPlayerModelChange")

  local playerData = getPlayerData(steam64)
  local primaryWeapon, secondaryWeapon, meleeWeapon = playerData.activePrimaryWeapon, playerData.activeSecondaryWeapon, playerData.activeMeleeWeapon 
  
  if (primaryWeapon and primaryWeapon.className) then
    ply:Give(primaryWeapon.className)
  end
  
  if (secondaryWeapon and secondaryWeapon.className) then
    ply:Give(secondaryWeapon.className)
  end
  
  if (meleeWeapon and meleeWeapon.className) then
    ply:Give(meleeWeapon.className)
  end

  timer.Simple(0.2, function ()
    local playerModel = playerData.activePlayerModel.modelName
    local hasCustomModel = string.len(playerModel) > 0

    local modelIsDifferentFromCurrent = ( string.lower(playerModel) ~= string.lower(ply:GetModel()) )
    local needToUpdateModel = (hasCustomModel and modelIsDifferentFromCurrent)
    
    if (needToUpdateModel) then
      SetPlayerModel(ply, playerModel)
    end
  end)
end)

hook.Add("TTTPrepareRound", "WskyTTTLootboxes_SetPrepareRoundModels", function ()
  timer.Simple(0.2, function ()
    GetPlayersAndSetModels()
  end)
  timer.Create("WskyTTTLootboxes_CheckPlayerModelChange", 2, 0, function ()
    GetPlayersAndSetModels()
  end)
end)
hook.Add("TTTBeginRound", "WskyTTTLootboxes_SetBeginRoundModels", function ()
  GetPlayersAndSetModels()
  timer.Destroy("WskyTTTLootboxes_CheckPlayerModelChange")
end)

hook.Add("TTTEndRound", "WskyTTTLootboxes_SetEndRoundModels", function ()
  timer.Destroy("WskyTTTLootboxes_CheckPlayerModelChange")
  GetPlayersAndSetModels()
  GiveOutFreeCrates()
end)