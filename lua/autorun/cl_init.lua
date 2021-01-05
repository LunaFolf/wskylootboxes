if SERVER then return end

TryTranslation = LANG and LANG.TryTranslation or nil

include('cl_data.lua')
include('cl_menu.lua')
include('shared.lua')

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

concommand.Add("wsky_ttt_whatweapon", function (ply)
  print(ply:GetActiveWeapon())
end)

concommand.Add("wsky_ttt_getplayermodels", function (ply)
  PrintTable(player_manager.AllValidModels())
end)

concommand.Add("wsky_ttt_getmymodel", function (ply)
  print(ply:GetModel())
end)