if SERVER then return end

include('config.lua')
include('shared.lua')

include('wskylootboxes/cl_data.lua')
include('wskylootboxes/cl_menu.lua')
include('wskylootboxes/cl_notifications.lua')
include('wskylootboxes/cl_weaponNaming.lua')

function getWeaponCategory(weaponClassName)
  if(table.HasValue(table.GetKeys(primaryWeapons), weaponClassName)) then
    return "primary"
  elseif(table.HasValue(table.GetKeys(secondaryWeapons), weaponClassName)) then
    return "secondary"
  elseif(table.HasValue(table.GetKeys(meleeWeapons), weaponClassName)) then
    return "melee"
  end
end

concommand.Add("wsky_current_weapon", function (ply)
  local curWeapon = ply:GetActiveWeapon()
  print(curWeapon:IsValid() and ply:GetActiveWeapon():GetClass() or "Can't find currently active weapon!")
end, nil, "Retieve the class name of the currently active weapon.")