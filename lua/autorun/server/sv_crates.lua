if CLIENT then return end

util.AddNetworkString("WskyTTTLootboxes_RequestCrateOpening")
util.AddNetworkString("WskyTTTLootboxes_OpenPlayerInventory")
util.AddNetworkString("WskyTTTLootboxes_ClientsideWinChime")

percentageChanceToWinCrate = 30

crateTypes = {
  "weapon",
  "playerModel"
}

function generateExoticParticleEffect(type)
  local particleCount = 0
  if (type == "playerModel") then
    particleCount = table.Count(playerModelParticles)
    return playerModelParticles[math.Round(math.Rand(1, particleCount))]
  end
  if (type == "weapon") then
    particleCount = table.Count(weaponParticles)
    return weaponParticles[math.Round(math.Rand(1, particleCount))]
  end
end

function generateItemValue(itemType, itemTier, baseValue)
  local tierCount = table.Count(weaponTiers)
  local currentTier = weaponTiers[itemTier]
  local multiplier = currentTier.multiplier
  local value = math.Round(baseValue * multiplier)

  return ((value > 0) and value) or baseValue

end

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

  value = generateItemValue("weapon", tierNum, allWeapons[winningWeapon].value)

  return winningWeapon, weaponTier.name, value
end

function wskyLootboxesUnboxPlayerModel()
  -- Randomly Select the model.
  local modelKeys = table.GetKeys(playerModels)
  local modelCount = table.Count(playerModels)
  local modelNum = math.Round(math.Rand(1, modelCount))
  local winningModel = modelKeys[modelNum]

  local exotic = math.Rand(0, 1) >= 0.95

  local value = generateItemValue("playerModel", exotic and 5 or 1, playerModels[winningModel].value)

  return winningModel, (exotic and "Exotic" or "Common"), value
end

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
        net.WriteBool(false)
      net.Send(ply)

      sendClientFreshData(ply, playerData)
    end
  end
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
    weaponClass, weaponTier, value = wskyLootboxesUnboxWeapon()
    newItem.className = weaponClass
    newItem.tier = weaponTier
  elseif (crateType == "playerModel") then
    modelName, modelTier, value = wskyLootboxesUnboxPlayerModel()
    newItem.modelName = modelName
    newItem.tier = modelTier
  end

  if (newItem.tier == "Exotic") then
    newItem.exoticParticleEffect = generateExoticParticleEffect(crateType)
  end

  value = math.Round(valueDepreciationFn() * value)

  newItem.value = value

  playerData.inventory[itemID] = nil

  newItem.createdAt = os.time()

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
    net.WriteBool(winAFreeCrate)
  net.Send(ply)

  sendClientFreshData(ply, playerData)

  net.Start("WskyTTTLootboxes_OpenPlayerInventory")
  net.Send(ply)
end)