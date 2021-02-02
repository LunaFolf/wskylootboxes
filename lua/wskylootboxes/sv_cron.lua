if CLIENT then return end

function getDailyStoreData()
  local dailyStoreItems = {}

  local fileName = dir.."/dailyStore.json"
  checkAndCreateDir(dir)
  local fileOutput = file.Read(fileName)
  if not fileOutput or string.len(fileOutput) <= 0 then
    local starterData = {}
    file.Write(fileName, util.TableToJSON(starterData))
    dailyStoreItems = starterData
  else
    dailyStoreItems = util.JSONToTable(fileOutput)
  end

  return table.Copy(dailyStoreItems)
end

function saveDailyStoreData(storeData)
  if (!storeData) then return end

  local fileName = dir.."/dailyStore.json"
  checkAndCreateDir(dir)

  file.Write(fileName, util.TableToJSON(storeData))
end

function refreshStoreWithDailys()
  storeItems = {}
  table.Add(storeItems, fixedStoreItems)
  table.Add(storeItems, getDailyStoreData())
end

function generateDailyStore()

  saveDailyStoreData({})

  local weaponItem, playerModelItem, vipPlayerModelItem = {}, {}, {}

  weaponItem.type = "weapon"
  playerModelItem.type = "playerModel"
  vipPlayerModelItem.type = "playerModel"

  vipPlayerModelItem.role = "vip"

  weaponItem.className, weaponItem.tier, weaponItem.value = wskyLootboxesUnboxWeapon()
  playerModelItem.modelName, playerModelItem.tier, playerModelItem.value = wskyLootboxesUnboxPlayerModel()
  vipPlayerModelItem.modelName, vipPlayerModelItem.tier, vipPlayerModelItem.value = wskyLootboxesUnboxPlayerModel(true)

  local items = { weaponItem, playerModelItem, vipPlayerModelItem }

  for k, item in pairs(items) do
    if item.tier ~= "Exotic" then
      item.tier = "Exotic"
    end
    item.exoticParticleEffect = generateExoticParticleEffect(item.type)
    item.value = math.min(2000, math.Round(item.value * ( item.type == "weapon" and 2.5 or 7 )))
  end

  saveDailyStoreData(items)
  refreshStoreWithDailys()
end

refreshStoreWithDailys()

concommand.Add("wskylootboxes_generateDaily", generateDailyStore)
