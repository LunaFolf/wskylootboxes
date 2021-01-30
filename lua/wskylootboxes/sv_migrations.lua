if CLIENT then return end

-- This is a migration file, it is designed to convert data from previous updates to the latest.
-- Unless there is a bug, old migrations SHOULD NEVER BE REMOVED for the sake of compatability.

local function consolidateLoadout (playerData)

  if !playerData.loadout then
    playerData.loadout = {}
  end

  local melee = playerData.activeMeleeWeapon
  local primary = playerData.activePrimaryWeapon
  local secondary = playerData.activeSecondaryWeapon

  if melee and string.len(melee.itemID) > 0 then
    table.insert(melee and playerData.loadout, melee.itemID)
  end

  if primary and string.len(primary.itemID) > 0 then
    table.insert(playerData.loadout, primary.itemID)
  end

  if secondary and string.len(secondary.itemID) > 0 then
    table.insert(playerData.loadout, secondary.itemID)
  end
  playerData.activeMeleeWeapon = nil
  playerData.activePrimaryWeapon = nil
  playerData.activeSecondaryWeapon = nil

  return playerData
end

local function cleanupActivePlayerModel (playerData)
  local item = playerData.activePlayerModel
  if !item then return playerData end

  playerData.activePlayerModel = item.itemID

  return playerData
end

local function cleanupBadItemData (playerData)
  local inventory = playerData.inventory
  if !inventory then return end

  local itemIDs = table.GetKeys(inventory)

  for index, itemID in ipairs(itemIDs) do
    local item = inventory[itemID]
    if !item then return end

    item.owner = nil
    item.ownerName = nil
    item.itemID = nil
  end
end

local functionsToRun = {
  consolidateLoadout,
  cleanupActivePlayerModel,
  cleanupBadItemData
}

for i, ply in ipairs(player.GetAll()) do
  local steam64 = ply:SteamID64()
  local playerData = getPlayerData(steam64)

  for i, fnc in ipairs(functionsToRun) do
    playerData = (fnc(playerData) or playerData)
  end

  savePlayerData(steam64, playerData)
end