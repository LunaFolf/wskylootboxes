if CLIENT then return end

dailyStoreItems = {}

function generateDailyStore()

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

  dailyStoreItems = table.Copy(items)

  storeItems = {}
  table.Add(storeItems, fixedStoreItems)
  table.Add(storeItems, dailyStoreItems)
end

if table.Count(dailyStoreItems) < 1 then
  generateDailyStore()
end

concommand.Add("wskylootboxes_generateDaily", generateDailyStore)
