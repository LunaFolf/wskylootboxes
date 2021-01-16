if CLIENT then return end

concommand.Add("wsky_lootbox_debug_genshin", function (ply, cmd, args)
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

concommand.Add("wsky_lootbox_debug_modelsearch", function (ply, cmd, args)
  if (!args[1]) then return end
  local steam64 = args[1]
  local searchQuery = args[2] or ""
  local playerData = getPlayerData(steam64)

  if (!playerData) then return end

  if (table.Count(table.GetKeys(playerData.inventory)) > 0) then
    playerData.inventory = {}
  end

  local models = player_manager.AllValidModels()
  local genshinModels = {}

  for name, path in pairs(models) do
    if (string.find(string.lower(name), searchQuery)) then
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

concommand.Add("wsky_lootbox_debug_printAllModels", function (ply)
  if (!ply) then return end
  local steam64 = ply:SteamID64()
  local playerData = getPlayerData(steam64)

  if (table.Count(table.GetKeys(playerData.inventory)) > 0) then
    playerData.inventory = {}
  end

  local models = player_manager.AllValidModels()

  -- for model, modelName in pairs(models) do
  --   table.Merge(playerData.inventory, {
  --     [uuid()] = {
  --       ["type"] = "playerModel",
  --       ["modelName"] = modelName,
  --       ["value"] = 1,
  --       ["tier"] = "Common",
  --       ["createdAt"] = os.time()
  --     }
  --   })
  -- end

  -- savePlayerData(steam64, playerData)

  PrintTable(models)
end)

concommand.Add("wsky_lootbox_debug_allItems", function (ply)
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
        ["value"] = weapon.value,
        ["tier"] = "Exotic",
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
        ["value"] = model.value,
        ["tier"] = "Exotic",
        ["createdAt"] = os.time()
      }
    })
  end

  savePlayerData(steam64, playerData)

  PrintTable(playerData)
end)