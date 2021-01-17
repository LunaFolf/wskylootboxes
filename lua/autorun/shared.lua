TryTranslation = LANG and LANG.TryTranslation or nil

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
    local exoticEffect = playerData.activePlayerModel.exoticParticleEffect
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
      clearParticlesOnPlayer(ply)
      if (exoticEffect) then spawnParticleOnPlayer("playerModel", exoticEffect, ply) end
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

function getItemName(item)
  if (!TryTranslation) then TryTranslation = LANG and LANG.TryTranslation or nil end
  if (!item) then return end

  print("customName: ", item.customName)

  if (item.customName) then return item.customName end

  local chosenName = nil
  local tier = item.tier

  -- Check if Item is a crate
  local crateTag = "crate_"
  if (string.StartWith(item.type, crateTag)) then
    local crateType = string.sub(item.type, string.len(crateTag) + 1)
    if (crateType == "weapon") then chosenName = "Weapon Crate"
    elseif (crateType == "playerModel") then chosenName = "Player Model Crate"
    elseif (crateType == "any") then chosenName = "Random Crate"
    else chosenName = "Unknown Crate" end
  end

  -- Check if Item is a weapon
  if (item.type == "weapon") then
    local weapon = weapons.GetStored(item.className)
    local weaponName = weapon.PrintName or weapon.ClassName
    local name = (TryTranslation and TryTranslation(weaponName) or weaponName)
    chosenName = tier .. " " .. name
  end

  -- Check if Item is a playerModel
  if (item.type == "playerModel") then
    local formattedName = player_manager.TranslateToPlayerModelName(item.modelName)
    local genshinTag = "Genshin Impact "
    if (string.StartWith(formattedName, genshinTag)) then
      formattedName = string.sub(formattedName, string.len(genshinTag) + 1)
    end
    local prepend = (tier == "Exotic" and "Exotic " or "")
    if (tier ~= "Exotic") then tier = nil end
    chosenName = prepend .. string.upper(string.sub(formattedName, 1, 1)) .. string.sub(formattedName, 2)
  end

  -- Check for name overrides
  local className = (tier and string.sub(chosenName, string.len(tier) + 2) or chosenName)
  local override = itemNameOverrides[className]
  if (override) then chosenName = (tier and (tier .. " " .. override) or override) end

  return chosenName or "# WSKY_LOOTBOX_NAME_MISSING #"
end

function getItemPreview(item)
  if (!item) then return end

  -- Check if Item is a crate.
  local crateTag = "crate_"
  if (string.StartWith(item.type, crateTag)) then
    local crateType = string.sub(item.type, string.len(crateTag) + 1)
    local crateIcon = "vgui/ttt/wsky/icon_crate.png"

    if (crateType == "weapon") then
      crateIcon = "vgui/ttt/wsky/icon_crate_weapon.png"
    elseif (crateType == "playerModel") then
      crateIcon = "vgui/ttt/wsky/icon_crate_playerModel.png"
    end

    return {
      ["type"] = "icon",
      ["data"] = crateIcon
    }
  end

  if (item.type == "weapon") then
    local weapon = weapons.GetStored(item.className)

    -- If a weapon icon exists, return that.
    if (weapon.Icon) then
      return {
        ["type"] = "icon",
        ["data"] = weapon.Icon
      }
    end

    -- Otherwise, find an available model and use that.
    return {
      ["type"] = "model",
      ["data"] = weapon.WorldModel or ""
    }
  end

  -- Check if Item is a playerModel
  if (item.type == "playerModel") then
    return {
      ["type"] = "playerModel",
      ["data"] = item.modelName
    }
  end

  return {
    ["type"] = "icon",
    ["data"] = "vgui/spawnmenu/generating"
  }
end