if CLIENT then return end

concommand.Add("wskylootboxes_debug_genshin", function (ply, cmd, args)
  if (!args[1]) then return end
  local steam64 = args[1]
  local playerData = getPlayerData(steam64)

  if (!playerData) then return end

  if (table.Count(table.GetKeys(playerData.inventory)) > 0) then
    playerData.inventory = {}
  end

  local models = player_manager.AllValidModels()
  local genshinModels = {}

  for name, path in pairs(models) do
    if (string.find(string.lower(name), "genshin")) then
      table.insert(genshinModels, path)
    end
  end

  for i, modelName in pairs(genshinModels) do
    table.Merge(playerData.inventory, {
      [uuid()] = {
        ["type"] = "playerModel",
        ["modelName"] = modelName,
        ["value"] = 1,
        ["tier"] = "Common",
        ["createdAt"] = os.time()
      }
    })
  end

  savePlayerData(steam64, playerData)

  PrintTable(genshinModels)
end)

concommand.Add("wskylootboxes_debug_modelsearch", function (ply, cmd, args)
  if (!args[1]) then return end
  local steam64 = args[1]
  local searchQuery = args[2] or ""
  local playerData = getPlayerData(steam64)

  if (!playerData) then return end

  if (table.Count(table.GetKeys(playerData.inventory)) > 0) then
    playerData.inventory = {}
  end

  local models = player_manager.AllValidModels()
  local filteredModels = {}

  for name, path in pairs(models) do
    if (string.find(string.lower(path), searchQuery) or string.find(string.lower(name), searchQuery)) then
      table.insert(filteredModels, path)
    end
  end

  for i, modelName in pairs(filteredModels) do
    table.Merge(playerData.inventory, {
      [uuid()] = {
        ["type"] = "playerModel",
        ["modelName"] = modelName,
        ["value"] = 1,
        ["tier"] = "Common",
        ["createdAt"] = os.time()
      }
    })
  end

  savePlayerData(steam64, playerData)

  PrintTable(filteredModels)
end)

concommand.Add("wskylootboxes_debug_printAllModels", function (ply)
  if (!ply) then return end
  local steam64 = ply:SteamID64()
  local playerData = getPlayerData(steam64)

  if (table.Count(table.GetKeys(playerData.inventory)) > 0) then
    playerData.inventory = {}
  end

  local models = player_manager.AllValidModels()

  PrintTable(models)
end)

concommand.Add("wskylootboxes_debug_allItems", function (ply)
  if (!ply) then return end
  local steam64 = ply:SteamID64()
  local playerData = getPlayerData(steam64)

  if (table.Count(table.GetKeys(playerData.inventory)) > 0) then
    playerData.inventory = {}
  end

  -- Add all weapons
  for className, weapon in pairs(allWeapons) do
    table.Merge(playerData.inventory, {
      [uuid()] = {
        ["type"] = "weapon",
        ["className"] = className,
        ["value"] = -1,
        ["tier"] = "Exotic",
        ["exoticParticleEffect"] = weaponParticles[math.Round(math.Rand(1, table.Count(weaponParticles)))],
        ["createdAt"] = os.time()
      }
    })
  end

  -- Add all playerModels
  for modelName, model in pairs(playerModels) do
    table.Merge(playerData.inventory, {
      [uuid()] = {
        ["type"] = "playerModel",
        ["modelName"] = modelName,
        ["value"] = -1,
        ["tier"] = "Exotic",
        ["exoticParticleEffect"] = playerModelParticles[math.Round(math.Rand(1, table.Count(playerModelParticles)))],
        ["createdAt"] = os.time()
      }
    })
  end


  savePlayerData(steam64, playerData)

  -- PrintTable(playerData)
end)

concommand.Add("wskylootboxes_debug_allItemsVip", function (ply)
  if (!ply) then return end
  local steam64 = ply:SteamID64()
  local playerData = getPlayerData(steam64)

  if (table.Count(table.GetKeys(playerData.inventory)) > 0) then
    playerData.inventory = {}
  end

  -- Add all playerModels
  for modelName, model in pairs(vipPlayerModels) do
    table.Merge(playerData.inventory, {
      [uuid()] = {
        ["type"] = "playerModel",
        ["modelName"] = modelName,
        ["value"] = -1,
        ["tier"] = "Exotic",
        ["exoticParticleEffect"] = playerModelParticles[math.Round(math.Rand(1, table.Count(playerModelParticles)))],
        ["createdAt"] = os.time()
      }
    })
  end


  savePlayerData(steam64, playerData)

  -- PrintTable(playerData)
end)

concommand.Add("wskylootboxes_debug_allItemsNotInLootboxes", function (ply)
  if (!ply) then return end
  local steam64 = ply:SteamID64()
  local playerData = getPlayerData(steam64)

  if (table.Count(table.GetKeys(playerData.inventory)) > 0) then
    playerData.inventory = {}
  end

  -- Add all weapons
  local allWeaponsKeys = table.GetKeys(allWeapons)
  for i, weapon in ipairs(weapons.GetList()) do
    local weaponIsInTable = table.HasValue(allWeaponsKeys, weapon.ClassName)
    if !weapon then
      table.Merge(playerData.inventory, {
        [uuid()] = {
          ["type"] = "weapon",
          ["className"] = weapon.ClassName,
          ["value"] = -1,
          ["tier"] = "Exotic",
          ["exoticParticleEffect"] = weaponParticles[math.Round(math.Rand(1, table.Count(weaponParticles)))],
          ["createdAt"] = os.time()
        }
      })
    end
  end

  -- Add all playerModels
  local playerModelsKeys = table.GetKeys(playerModels)
  for shortName, modelName in pairs(player_manager.AllValidModels()) do
    if !table.HasValue(playerModelsKeys, modelName) then
      table.Merge(playerData.inventory, {
        [uuid()] = {
          ["type"] = "playerModel",
          ["modelName"] = modelName,
          ["value"] = -1,
          ["tier"] = "Exotic",
          ["exoticParticleEffect"] = playerModelParticles[math.Round(math.Rand(1, table.Count(playerModelParticles)))],
          ["createdAt"] = os.time()
        }
      })
    end
  end

  savePlayerData(steam64, playerData)

  -- PrintTable(playerData)
end)
