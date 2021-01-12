if CLIENT then return end

percentageChanceToWinCrate = 30

function wskyLootboxesUnboxWeapon()
  -- Randomly Select the weapon.
  local weaponKeys = table.GetKeys(allWeapons)
  local weaponCount = table.Count(weaponKeys)
  local weaponNum = math.Round(math.Rand(1, weaponCount))
  local winningWeapon = weaponKeys[weaponNum]

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

crateTypes = {
  "weapon",
  "playerModel"
}

function sendClientFreshData(ply, playerData)
  if (!ply) then return end

  net.Start("WskyTTTLootboxes_ClientReceiveData")
    net.WriteTable(playerData or getPlayerData(ply:SteamID64()))
    net.WriteTable(storeItems)
    net.WriteTable(getMarketData())
  net.Send(ply)
end

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
    local exotic = math.Rand(0, 1) >= 0.9
    newItem.tier = exotic and "Exotic" or "Common"
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

-- end of crate stuff