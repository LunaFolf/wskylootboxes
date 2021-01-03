if SERVER then return end

local menuOpen = false

include('cl_data.lua')
include('shared.lua')

local width, height = math.max(426, ScrW() / 6), 100
local margin = 32
local padding = 8
local titleBarHeight = 32

width, height = width + (padding * 2), height + (padding * 2)

concommand.Add("wsky_ttt_whatweapon", function (ply)
  print(ply:GetActiveWeapon())
end)

hook.Add("PlayerButtonDown", "WskyLootboxes_OpenPlayerMenu", function (ply, key)
  if (menuOpen or (key ~= KEY_F3 and key ~= KEY_I)) then return end
  menuOpen = true

  local Frame = createBasicFrame(ScrW() / 2, ScrH() / 2, "Inventory", false)
  requestNewData()
  Frame.OnClose = function ()
    menuOpen = false
  end
end)