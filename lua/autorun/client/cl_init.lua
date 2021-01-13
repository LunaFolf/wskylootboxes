if SERVER then return end

TryTranslation = LANG and LANG.TryTranslation or nil

include('../config.lua')
include('cl_data.lua')
include('cl_menu.lua')
include('../shared.lua')

function getWeaponCategory(weaponClassName)
  if(table.HasValue(table.GetKeys(primaryWeapons), weaponClassName)) then
    return "primary"
  elseif(table.HasValue(table.GetKeys(secondaryWeapons), weaponClassName)) then
    return "secondary"
  elseif(table.HasValue(table.GetKeys(meleeWeapons), weaponClassName)) then
    return "melee"
  end
end

net.Receive("WskyTTTLootboxes_ClientsideWinChime", function ()
  if (!TryTranslation) then TryTranslation = LANG and LANG.TryTranslation or nil end
  local ply = LocalPlayer()
  local soundString = net.ReadString()
  local item = net.ReadTable()

   local winningItemText = ""

  if (item.type == "weapon") then
    local weapon = weapons.Get(item.className)

    winningItemText = "You got a " .. (item.tier and (item.tier .. " ") or "") .. TryTranslation(weapon.PrintName)
  elseif (item.type == "playerModel") then
    local playerModelName = player_manager.TranslateToPlayerModelName(item.modelName)
    local formattedName = string.upper(string.sub(playerModelName, 1, 1)) .. string.sub(playerModelName, 2)
    
    winningItemText = "You got a " .. formattedName .. " player model"
  elseif (string.StartWith(item.type, "crate_")) then
    local crateType = string.sub(item.type, string.len("crate_") + 1)
    if (crateType == "playerModel") then crateType = "player model" end

    winningItemText = "You got a " .. crateType .. " crate"
  end

  messagePlayer(ply, winningItemText .. "!")

  ply:EmitSound(soundString)
end)

concommand.Add("wsky_current_weapon", function (ply)
  local curWeapon = ply:GetActiveWeapon()
  print(curWeapon:IsValid() and ply:GetActiveWeapon():GetClass() or "Can't find currently active weapon!")
end, nil, "Retieve the class name of the currently active weapon.")