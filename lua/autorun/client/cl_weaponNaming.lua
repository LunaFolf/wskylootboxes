if SERVER then return end

net.Receive("WskyTTTLootboxes_ClientsideUpdateWeaponName", function ()
  local inventoryWeapon = net.ReadTable()
  local weaponClass = net.ReadString()
  if (!weaponClass) then return end

  local ply = LocalPlayer()
  local steam64 = ply:SteamID64()

  timer.Simple(0.2, function ()
    if (!inventoryWeapon) then return end

    local weapon = LocalPlayer():GetWeapon(weaponClass)
    local customName = getItemName(inventoryWeapon)

    weapon:SetNWString("customName", customName)

    net.Start("WskyTTTLootboxes_SetEntityCustomName")
      net.WriteEntity(weapon)
      net.WriteString(customName)
    net.SendToServer()
  end)
end)