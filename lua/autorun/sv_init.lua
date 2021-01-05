if CLIENT then return end

include('config.lua')
include('sv_download.lua')
include('shared.lua')

util.AddNetworkString("WskyTTTLootboxes_ClientRequestData")
util.AddNetworkString("WskyTTTLootboxes_ClientReceiveData")

util.AddNetworkString("WskyTTTLootboxes_OpenPlayerInventory")

util.AddNetworkString("WskyTTTLootboxes_RequestCrateOpening")
util.AddNetworkString("WskyTTTLootboxes_EquipItem")
util.AddNetworkString("WskyTTTLootboxes_UnequipItem")

util.AddNetworkString("WskyTTTLootboxes_BuyFromStore")

util.AddNetworkString("WskyTTTLootboxes_SellItem")

util.AddNetworkString("WskyTTTLootboxes_ClientsideWinChime")

local dir = "wsky/Lootboxes"

local percentageChanceToWinCrate = 30

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

function wskyLootboxesUnboxWeapon()
  -- Randomly Select the weapon.
  local weaponKeys = table.GetKeys(allWeapons)
  local weaponCount = table.Count(weaponKeys)
  local weaponNum = math.Round(math.Rand(1, weaponCount))
  local winningWeapon = weaponKeys[weaponNum]

  print(winningWeapon)

  -- Randomly Select the weapon Tier.
  local tierCount = table.Count(weaponTiers)
  local tierNum = math.Round(math.Rand(1, tierCount))
  local weaponTier = weaponTiers[tierNum]

  local nextTierUp = weaponTiers[math.min(tierCount, tierNum + 1)]

  local multMin, multMax = weaponTier.multiplier, nextTierUp.multiplier

  local multiplier = math.Rand(multMin, multMax)

  local value = allWeapons[winningWeapon].value

  value = math.Round(value * math.max(1, multiplier))

  return winningWeapon, weaponTier.name, value
end

function wskyLootboxesUnboxPlayerModel()
  -- Randomly Select the model.
  local modelKeys = table.GetKeys(playerModels)
  local modelCount = table.Count(playerModels)
  local modelNum = math.Round(math.Rand(1, modelCount))
  local winningModel = modelKeys[modelNum]

  local value = playerModels[winningModel].value

  return winningModel, value
end

local crateTypes = {
  "weapon",
  "playerModel"
}

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

function sendClientFreshData(ply, playerData)
  if (!ply) then return end

  net.Start("WskyTTTLootboxes_ClientReceiveData")
    net.WriteTable(playerData or getPlayerData(ply:SteamID64()))
    net.WriteTable(storeItems)
  net.Send(ply)
end

net.Receive("WskyTTTLootboxes_SellItem", function (len, ply)
  local steam64 = ply:SteamID64()
  local playerData = getPlayerData(steam64)
  local itemID = net.ReadString()

  if (!itemID) then
    givePlayerError(ply)
    return
  end

  unEquipItem(playerData, itemID)

  playerData.scrap = playerData.scrap + playerData.inventory[itemID].value
  playerData.inventory[itemID] = nill

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
  local itemID = uuid()
  local itemTable = {
    [itemID] = item
  }
  itemTable[itemID].value = math.floor(itemTable[itemID].value * 0.75)

  if (playerData.scrap < item.value) then return end

  PrintTable(itemTable)
  table.Merge(playerData.inventory, itemTable)

  playerData.scrap = playerData.scrap - item.value

  savePlayerData(steam64, playerData)

  sendClientFreshData(ply, playerData)

  net.Start("WskyTTTLootboxes_OpenPlayerInventory")
  net.Send(ply)
end)

net.Receive("WskyTTTLootboxes_RequestCrateOpening", function (len, ply)
  if (!len or !ply) then return end
  local steam64 = ply:SteamID64()
  local playerData = getPlayerData(steam64)
  local itemID = net.ReadString()

  if (!itemID) then
    givePlayerError(ply)
    return
  end

  local crate = playerData.inventory[itemID]

  if (!crate) then
    givePlayerError(ply)
    return
  end

  local crateTag = "crate_"
  if (!string.StartWith(crate.type, crateTag)) then return end

  local crateType = string.sub(crate.type, string.len(crateTag) + 1)

  -- Calculate whether you win a free crate.
  local winAFreeCrate = crate.value ~= -2 and ((math.Rand(0, 1)*100) <= percentageChanceToWinCrate)

  -- Catch out erroneous crateType.
  if (crateType ~= "any" and table.HasValue(crateTypes, crateType) == false) then
    givePlayerError(ply)
    return
  end

  local winningItem = ""
  local weaponTier = null
  local value = 0

  while (table.HasValue(crateTypes, crateType) == false) do
    local numOfCrateTypes = table.Count(crateTypes)
    crateType = crateTypes[math.Round(math.Rand(1, numOfCrateTypes))]
  end

  -- Create item table for new item.
  local newItem = {}
  newItem.type = crateType

  -- Find crate type and unbox it.
  if (crateType == "weapon") then
    winningItem, weaponTier, value = wskyLootboxesUnboxWeapon()
    newItem.className = winningItem
    newItem.tier = weaponTier
  elseif (crateType == "playerModel") then
    winningItem, value = wskyLootboxesUnboxPlayerModel()
    newItem.modelName = winningItem
  end

  value = math.Round(math.Rand(0.85, 1.15) * value)

  newItem.value = value

  playerData.inventory[itemID] = nil

  -- Store new item!
  table.Merge(playerData.inventory, {
    [uuid()] = newItem
  })

  if (winAFreeCrate) then
    local freeCrate = generateACrate()
    freeCrate.value = -2
    
    table.Merge(playerData.inventory, {
      [uuid()] = freeCrate
    })
  end

  savePlayerData(steam64, playerData)

  -- Let player know of their winnings, and play a little tune.
  net.Start("WskyTTTLootboxes_ClientsideWinChime")
    net.WriteString("garrysmod/save_load1.wav")
    net.WriteTable(newItem)
  net.Send(ply)

  sendClientFreshData(ply, playerData)

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
end)

hook.Add("TTTPrepareRound", "WskyTTTLootboxes_SetPrepareRoundModels", function ()
  GetPlayersAndSetModels()
  timer.Create("WskyTTTLootboxes_CheckPlayerModelChange", 2, 0, function ()
    GetPlayersAndSetModels()
  end)
end)
hook.Add("TTTBeginRound", "WskyTTTLootboxes_SetBeginRoundModels", GetPlayersAndSetModels)

hook.Add("TTTEndRound", "WskyTTTLootboxes_SetEndRoundModels", function ()
  timer.Destroy("WskyTTTLootboxes_CheckPlayerModelChange")
  GetPlayersAndSetModels()

  GiveOutFreeCrates()
end)