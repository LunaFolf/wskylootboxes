include('config.lua')

math.randomseed(os.time())

availableWeapons = {}
local inventories = {}

util.AddNetworkString("WskyTTTLootbox_Winnings")

for i, weaponName in pairs(allWeapons) do
  local weapon = weapons.Get(weaponName)
  if (weapon) then
    table.insert(availableWeapons, weaponName)
  end
end

concommand.Add("wsky_start_lootbox", function (ply, cmd, args)
  local steam64 = ply:SteamID64()
  local numberOfUnboxes = tonumber(args[1]) or 1
  local curUnbox = 0

  print("Unboxing " .. numberOfUnboxes .. " crates...")

  while (curUnbox < numberOfUnboxes) do
    curUnbox = curUnbox + 1
    local weaponCount = table.Count(availableWeapons)
    local weaponNum = math.Round(math.Rand(1, weaponCount))

    local tierCount = table.Count(weaponTiers)
    local tierNum = math.Round(math.Rand(1, tierCount))

    local winningWeapon = availableWeapons[weaponNum]
    local weaponTier = weaponTiers[tierNum]

    local isMelee = table.HasValue(meleeWeapons, winningWeapon)
    local isPrimary = table.HasValue(primaryWeapons, winningWeapon)
    local isSecondary = table.HasValue(secondaryWeapons, winningWeapon)
    local slotToRemove = 0
    if (isMelee) then slotToRemove = 1 end
    if (isPrimary) then slotToRemove = 3 end
    if (isSecondary) then slotToRemove = 2 end

    if (!inventories[steam64]) then inventories[steam64] = {} end

    local newWeapon = {}
    newWeapon.className = winningWeapon
    newWeapon.tier = weaponTier

    table.Add(inventories[steam64], {newWeapon})

    net.Start("WskyTTTLootbox_Winnings")
      net.WriteTable(newWeapon)
    net.Send(ply)

    print("Crate " .. curUnbox .. ": " .. weaponTier .. " " .. winningWeapon .. "!")
  end
  ply:EmitSound("garrysmod/save_load1.wav")
end)

concommand.Add("wsky_current_inventories", function ()
  PrintTable(inventories)
end)