if CLIENT then return end

include('config.lua')
include('shared.lua')

util.AddNetworkString("WskyTTTLootboxes_ClientRequestData")
util.AddNetworkString("WskyTTTLootboxes_ClientReceiveData")

math.randomseed(os.time())

local inventories = {}

function wskyLootboxesUnboxWeapon()
  -- Randomly Select the weapon.
  local weaponCount = table.Count(allWeapons)
  local weaponNum = math.Round(math.Rand(1, weaponCount))
  local winningWeapon = allWeapons[weaponNum]

  print(weaponCount, weaponNum, winningWeapon)

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

  print(modelCount, modelNum, winningModel)

  return winningModel
end

local crateTypes = {
  "weapon",
  "playerModel"
}

net.Receive("WskyTTTLootboxes_ClientRequestData", function (len, ply)
  local steam64 = ply:SteamID64()
  if (!inventories[steam64]) then inventories[steam64] = {
    [1] = {
      ["type"] = "crate_weapon"
    },
    [2] = {
      ["type"] = "crate_playerModel"
    }
  } end

  net.Start("WskyTTTLootboxes_ClientReceiveData")
    net.WriteTable(inventories[steam64])
  net.Send(ply)
end)

concommand.Add("wsky_start_lootbox", function (ply, cmd, args)
  local steam64 = ply:SteamID64()
  local crateType = args[1] or "any"

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

  -- If player inventory doesn't exist, create it!
  if (!inventories[steam64]) then inventories[steam64] = {} end
  -- Store new item!
  table.Add(inventories[steam64], {newItem})

  -- Let player know of their winnings, and play a little tune.
  local winningItemText = "You won a " .. (weaponTier and (weaponTier .. " ") or "") .. winningItem
  messagePlayer(ply, winningItemText .. (winAFreeCrate and ", and a free crate!" or "!"))
  ply:EmitSound("wsky_lootboxes/lootbox_win.wav")
end)

concommand.Add("wsky_current_inventories", function ()
  PrintTable(inventories)
end)