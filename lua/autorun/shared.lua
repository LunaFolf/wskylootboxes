if CLIENT then
  local consoleFont = "Segoe UI"
  local DefaultFont = "Unispace"

  local headerSize, defaultSize, regularSize, smallSize, miniSize, extraSmallSize = 182, 72, 58, 32, 22, 12

  surface.CreateFont( "WskyVendingMachineConsoleHeader", {
    font = consoleFont,
    size = headerSize
  } )

  surface.CreateFont( "WskyVendingMachineConsoleDefault", {
    font = consoleFont,
    size = smallSize,
    weight = 500
  } )

  surface.CreateFont( "WskyVendingMachineConsoleMini", {
    font = consoleFont,
    size = miniSize,
    weight = 100
  } )

  surface.CreateFont( "WskyVendingMachineHeader", {
    font = DefaultFont,
    size = defaultSize,
    weight = 1000
  } )

  surface.CreateFont( "WskyVendingMachineDefault", {
    font = DefaultFont,
    size = smallSize,
    weight = 1000
  } )

  surface.CreateFont( "WskyVendingMachineRegular", {
    font = DefaultFont,
    size = regularSize,
    weight = 1000
  } )

  surface.CreateFont( "WskyVendingMachineSmall", {
    font = DefaultFont,
    size = smallSize,
    weight = 1000
  } )

  surface.CreateFont( "WskyVendingMachineSmaller", {
    font = DefaultFont,
    size = miniSize,
    weight = 1000
  } )

  surface.CreateFont( "WskyVendingMachineMini", {
    font = DefaultFont,
    size = extraSmallSize,
    weight = 1000
  } )

  function createBasicFrame (width, height, title, draggable)
    local Frame = vgui.Create( "DFrame" )
    Frame:SetSize(width, height)
    Frame:SetTitle( "" )
    Frame:SetVisible(true)
    Frame:SetDraggable(draggable)
    Frame:ShowCloseButton(false)
    Frame:Center()
    Frame.Paint = function(self, w, h)
      draw.RoundedBox(0, 0, 0, w, h, Color(65, 65, 65, 225))
      draw.RoundedBox(0, 0, 0, w, 32, Color(0, 0, 0, 225))
      draw.SimpleText(title, "DermaLarge", 4, 0)
    end
    Frame:MakePopup()

    Frame.OnKeyCodePressed = function (_, key)
      print(key)
      if (key == KEY_ESCAPE or key == KEY_FIRST or key == KEY_BACKSPACE or key == KEY_C or key == KEY_Q) then Frame:Close() end
    end

    local CloseBtn = vgui.Create("DButton", Frame)
    CloseBtn:SetText( "X" )
    CloseBtn:SetTextColor( Color(255, 255, 255) )
    CloseBtn:SetPos(width - 32, 0)
    CloseBtn:SetSize(32, 32)
    CloseBtn.Paint = function(self, w, h)
      draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,255))
    end
    CloseBtn.DoClick = function()
      Frame:Close()
    end

    return Frame
  end

end

function messagePlayer(ply, message)
  if (ply && message) then
    ply:PrintMessage(HUD_PRINTTALK, "[Lootbox] " .. message)
  end
end