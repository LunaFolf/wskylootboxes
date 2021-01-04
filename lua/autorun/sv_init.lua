if CLIENT then return end

include('config.lua')
include('shared.lua')

util.AddNetworkString("WskyTTTLootboxes_ClientRequestData")
util.AddNetworkString("WskyTTTLootboxes_ClientReceiveData")
util.AddNetworkString("WskyTTTLootboxes_OpenPlayerInventory")
util.AddNetworkString("WskyTTTLootboxes_RequestCrateOpening")

local dir = "wsky/Lootboxes"

function getStarterPlayerData()
  return {
    ["playerModel"] = "",
    ["meleeWeapon"] = "",
    ["primaryWeapon"] = "",
    ["secondaryWeapon"] = "",
    ["scrap"] = 4000,
    ["inventory"] = {
      [uuid()] = {
      ["type"] = "crate_weapon"
      },
      [uuid()] = {
        ["type"] = "crate_playerModel"
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

function savePlayerData(steam64, inventory)
  if (!steam64 or !inventory) then return end

  local fileName = dir .. "/playerdata/" .. steam64 .. ".json"
  checkAndCreateDir(dir .. "/playerdata")
  
  file.Write(fileName, util.TableToJSON(inventory))
end

function wskyLootboxesUnboxWeapon()
  -- Randomly Select the weapon.
  local weaponCount = table.Count(allWeapons)
  local weaponNum = math.Round(math.Rand(1, weaponCount))
  local winningWeapon = allWeapons[weaponNum]

  -- Randomly Select the weapon Tier.
  local tierCount = table.Count(weaponTiers)
  local tierNum = math.Round(math.Rand(1, tierCount))
  local weaponTier = weaponTiers[tierNum]

  return winningWeapon, weaponTier
end

function wskyLootboxesUnboxPlayerModel()
  -- Randomly Select the model.
  local modelCount = table.Count(playerModels)
  local modelNum = math.Round(math.Rand(1, modelCount))
  local winningModel = playerModels[modelNum]

  return winningModel
end

local crateTypes = {
  "weapon",
  "playerModel"
}

net.Receive("WskyTTTLootboxes_ClientRequestData", function (len, ply)
  local steam64 = ply:SteamID64()
  local playerData = getPlayerData(steam64)
  local openPlayerMenu = net.ReadBool()

  net.Start("WskyTTTLootboxes_ClientReceiveData")
    net.WriteTable(playerData)
  net.Send(ply)

  if (openPlayerMenu) then
    net.Start("WskyTTTLootboxes_OpenPlayerInventory")
    net.Send(ply)
  end
end)

net.Receive("WskyTTTLootboxes_RequestCrateOpening", function (len, ply)
  if (!len or !ply) then return end
  local steam64 = ply:SteamID64()
  local playerData = getPlayerData(steam64)
  local itemID = net.ReadString()

  if (!itemID) then
    messagePlayer(ply, "There was an error opening this crate! Please contact staff.")
    return
  end

  local crate = playerData.inventory[itemID]

  if (!crate) then
    messagePlayer(ply, "There was an error opening this crate! Please contact staff.")
    return
  end

  local crateTag = "crate_"
  if (!string.StartWith(crate.type, crateTag)) then return end

  local crateType = string.sub(crate.type, string.len(crateTag) + 1)

  -- Calculate whether you win a free crate.
  local percentToWinFreeCrate = 40
  local rollOfDice = math.random() * 100
  local winAFreeCrate = false
  if (rollOfDice < percentToWinFreeCrate) then winAFreeCrate = true end

  -- Catch out erroneous crateType.
  if (crateType ~= "any" and table.HasValue(crateTypes, crateType) == false) then
    messagePlayer(ply, "There was an error opening this crate! Please contact staff.")
    return
  end

  local winningItem = ""
  local weaponTier = null

  while (table.HasValue(crateTypes, crateType) == false) do
    local numOfCrateTypes = table.Count(crateTypes)
    crateType = crateTypes[math.Round(math.Rand(1, numOfCrateTypes))]
  end

  -- Create item table for new item.
  local newItem = {}
  newItem.type = crateType

  -- Find crate type and unbox it.
  if (crateType == "weapon") then
    winningItem, weaponTier = wskyLootboxesUnboxWeapon()
    newItem.className = winningItem
    newItem.tier = weaponTier
  elseif (crateType == "playerModel") then
    winningItem = wskyLootboxesUnboxPlayerModel()
    newItem.modelName = winningItem
  end

  playerData.inventory[itemID] = nil

  -- Store new item!
  table.Merge(playerData.inventory, {
    [uuid()] = newItem
  })

  if (winAFreeCrate) then
    local freeCrate = {}
    local numOfCrateTypes = table.Count(crateTypes)
    freeCrate.type = "crate_" .. crateTypes[math.Round(math.Rand(1, numOfCrateTypes))]
    
    table.Merge(playerData.inventory, {
      [uuid()] = freeCrate
    })
  end

  savePlayerData(steam64, playerData)

  -- Let player know of their winnings, and play a little tune.
  local winningItemText = "You won a " .. (weaponTier and (weaponTier .. " ") or "") .. winningItem
  messagePlayer(ply, winningItemText .. (winAFreeCrate and ", and a free crate!" or "!"))
  ply:EmitSound("garrysmod/save_load1.wav")
end)

function SetPlayerModel (ply, model)
  if (!ply or !model) then return end
  ply:SetModel(model)
end

function GetPlayersAndSetModels()
  for _, ply in pairs(player.GetAll()) do
    local steam64 = ply:SteamID64()
    local playerData = getPlayerData(steam64)

    local playerModel = playerData.playerModel
    local hasCustomModel = string.len(playerModel) > 0

    local modelIsDifferentFromCurrent = ( string.lower(playerModel) ~= string.lower(ply:GetModel()) )
    local needToUpdateModel = (hasCustomModel and modelIsDifferentFromCurrent)
    
    if (needToUpdateModel) then
      SetPlayerModel(ply, playerModel)
    end
  end
end

hook.Add("TTTPrepareRound", "WskyTTTLootboxes_SetPrepareRoundModels", function ()
  GetPlayersAndSetModels()
  timer.Create("WskyTTTLootboxes_CheckPlayerModelChange", 2, 0, function ()
    GetPlayersAndSetModels()
  end)
end)
hook.Add("TTTBeginRound", "WskyTTTLootboxes_SetBeginRoundModels", GetPlayersAndSetModels())
hook.Add("TTTEndRound", "WskyTTTLootboxes_SetEndRoundModels", function ()
  timer.Destroy("WskyTTTLootboxes_CheckPlayerModelChange")
  GetPlayersAndSetModels()
end)