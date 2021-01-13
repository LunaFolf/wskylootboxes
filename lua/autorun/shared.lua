if CLIENT then
  local fontName = "Segoe UI"
  topHatBlue = Color(0, 202, 255, 225)
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

      local scrap = playerData and playerData.scrap or nil

      if title == "Inventory" and scrap then
        surface.SetFont("WskyFontSmaller")
        local scrapWidth, scrapHeight = surface.GetTextSize("Scrap: " .. scrap)
        draw.SimpleText("Scrap: " .. scrap, "WskyFontSmaller", (w - 38) - scrapWidth - 6, (36 - scrapHeight) / 2)
      end
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

  function createDialog (width, height, confirmationText, confirmFnc, cancelFnc)
    local confirmationMenu = createBasicFrame(width, height, "Confirmation", false)
    confirmationText = confirmationText or "Are you sure?"

    local container = vgui.Create("DPanel", confirmationMenu)
    container.Paint = function () end
    container:SetPos(0, 38)
    container:SetSize(width, height - 38)
    container:DockPadding(8, 8, 8, 8)

    local confirmationTextPanel = vgui.Create("DPanel", container)
    confirmationTextPanel:Dock(FILL)
    confirmationTextPanel.Paint = function (self, w, h)
      surface.SetFont("WskyFontSmaller")
      local textW, textH = surface.GetTextSize(confirmationText)
      draw.SimpleText(confirmationText, "WskyFontSmaller", (w - textW) / 2, (h - textH) / 2)
    end

    local footer = vgui.Create("DPanel", container)
    footer:Dock(BOTTOM)
    footer:SetHeight(height / 4)
    footer.Paint = function () end

    local confirmBtn = vgui.Create("DButton", footer)
    confirmBtn:Dock(RIGHT)
    confirmBtn:SetFGColor(Color(255, 255, 255, 255))
    confirmBtn:SetText("Confirm")
    confirmBtn.Paint = function (self, w, h)
      local color = Color(0, 202, 255, 225)
      draw.RoundedBox(0, 0, 0, w, h, color)
    end
    confirmBtn.DoClick = function ()
      confirmationMenu:Close()
      if (confirmFnc) then confirmFnc() end
    end

    local cancelBtn = vgui.Create("DButton", footer)
    cancelBtn:Dock(LEFT)
    cancelBtn:SetText("Cancel")
    cancelBtn.Paint = function (self, w, h)
      local color = Color(202, 202, 202, 225)
      draw.RoundedBox(0, 0, 0, w, h, color)
    end
    cancelBtn.DoClick = function ()
      confirmationMenu:Close()
      if (cancelFnc) then cancelFnc() end
    end

    return confirmationMenu
  end

end

if SERVER then
  function SetPlayerModel (ply)
    if (!ply or !ply:IsValid()) then return end
    local steam64 = ply:SteamID64()
    local playerData = getPlayerData(steam64)

    local playerModel = playerData.activePlayerModel.modelName
    local hasCustomModel = string.len(playerModel) > 0

    if (ply:IsBot() and not hasCustomModel) then
      local modelKeys = table.GetKeys(playerModels)
      local modelCount = table.Count(playerModels)
      local modelNum = math.Round(math.Rand(1, modelCount))
      playerData.activePlayerModel.modelName = modelKeys[modelNum]

      savePlayerData(steam64, playerData)
      needToUpdateModel = true
    end

    local modelIsDifferentFromCurrent = ( string.lower(playerModel) ~= string.lower(ply:GetModel()) )
    local needToUpdateModel = (hasCustomModel and modelIsDifferentFromCurrent)
    
    if (needToUpdateModel) then
      ply:SetModel(playerModel)
    end
  end

  function GetPlayersAndSetModels()
    for _, ply in pairs(player.GetAll()) do
      SetPlayerModel(ply)
    end
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

function getWeaponCategory(weaponClassName)
  if(table.HasValue(table.GetKeys(primaryWeapons), weaponClassName)) then
    return "primary"
  elseif(table.HasValue(table.GetKeys(secondaryWeapons), weaponClassName)) then
    return "secondary"
  elseif(table.HasValue(table.GetKeys(meleeWeapons), weaponClassName)) then
    return "melee"
  end
end

function givePlayerError(ply, message)
  local messageToPrint = message or "There was an error! Please contact staff."
  messagePlayer(ply, messageToPrint)
  error(messageToPrint)
end