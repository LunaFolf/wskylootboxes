if CLIENT then
  local fontName = "Segoe UI"
  local topHatBlue = Color(0, 202, 255, 225)
  local headerSize, defaultSize, regularSize, smallSize, miniSize, extraSmallSize = 182, 72, 58, 32, 22, 12

  surface.CreateFont( "WskyFontHeader", {
    font = fontName,
    size = defaultSize,
    weight = 500
  } )

  surface.CreateFont( "WskyFontDefault", {
    font = fontName,
    size = smallSize,
    weight = 500
  } )

  surface.CreateFont( "WskyFontRegular", {
    font = fontName,
    size = regularSize,
    weight = 500
  } )

  surface.CreateFont( "WskyFontSmall", {
    font = fontName,
    size = smallSize,
    weight = 500
  } )

  surface.CreateFont( "WskyFontSmaller", {
    font = fontName,
    size = miniSize,
    weight = 500
  } )

  surface.CreateFont( "WskyFontMini", {
    font = fontName,
    size = extraSmallSize,
    weight = 500
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
      draw.RoundedBox(0, 0, 0, w, 38, topHatBlue)
      draw.SimpleText(title, "WskyFontSmall", 6, 0)
    end
    Frame:MakePopup()
    Frame.OnKeyCodePressed = function (_, key)
      if (key == KEY_ESCAPE or key == KEY_FIRST or key == KEY_BACKSPACE or key == KEY_TAB) then Frame:Close() end
    end

    local CloseBtn = vgui.Create("DButton", Frame)
    CloseBtn:SetText( "X" )
    CloseBtn:SetTextColor( Color(255, 255, 255) )
    CloseBtn:SetPos(width - 38, 0)
    CloseBtn:SetSize(38, 38)
    CloseBtn.Paint = function(self, w, h)
      draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,125))
    end
    CloseBtn.DoClick = function()
      Frame:Close()
    end

    return Frame
  end

end

local random = math.random
function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

function messagePlayer(ply, message)
  if (ply && message) then
    ply:PrintMessage(HUD_PRINTTALK, "[Lootbox] " .. message)
  end
end