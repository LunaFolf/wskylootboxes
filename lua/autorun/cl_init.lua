if SERVER then return end

include('cl_data.lua')
include('cl_menu.lua')
include('shared.lua')

concommand.Add("wsky_ttt_whatweapon", function (ply)
  print(ply:GetActiveWeapon())
end)

concommand.Add("wsky_ttt_getplayermodels", function (ply)
  PrintTable(player_manager.AllValidModels())
end)