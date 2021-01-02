print("client!")

local width, height = math.max(426, ScrW() / 6), 100
local margin = 32
local padding = 8
local titleBarHeight = 32

width, height = width + (padding * 2), height + (padding * 2)

concommand.Add("wsky_ttt_whatweapon", function (ply)
  print(ply:GetActiveWeapon())
end)

net.Receive("WskyTTTLootbox_Winnings", function (len)
  if len then
    local ply = LocalPlayer()
    local weapon = net.ReadTable()
  end
end)

hook.Add("HUDPaint", "WskyTTTLootbox_HUDPaint", function ()

  draw.RoundedBox(0, ScrW() / 2 - (width / 2), margin, width, height, Color(0, 0, 0, 125))
  surface.SetFont("GModNotify")
  local text = "New Item!"
  local textWidth, textHeight = surface.GetTextSize(text)
  draw.SimpleText("New Item!", "GModNotify", ScrW() / 2 - (textWidth / 2), margin + padding)
end)