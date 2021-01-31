if SERVER then return end

local padding = 8
local width, height = math.max(400, ScrW() / 5), 72 + (32 + (padding * 2))
local newItemNotification = nil
local newScrapNotification = nil

local lastNewItemIndex = 1
local lastNewItemTime = 0
local spanBetweenItems = 2

local newScrapLifetime = 3

local function drawNewScrapNotification(oldScrapValue, newScrapValue)

  local difference = (newScrapValue - oldScrapValue)

  local width, height = width, height

  surface.SetFont("WskyFontDefault")
  local textWidth, textHeight = surface.GetTextSize(formatScrap(newScrapValue))
  local oldTextWidth, oldTextHeight = surface.GetTextSize(formatScrap(oldScrapValue))
  width = math.max(83, textWidth, oldTextWidth) + (padding * 2)
  height = (textHeight * 2) + (padding * 3)

  if (newScrapNotification) then
    newScrapNotification:Remove()
  end

  if difference == 0 then return end

  local startTime = SysTime() + (newScrapLifetime / 2)

  local notify = vgui.Create("DNotify")
  notify:SetLife(newScrapLifetime)
  notify:SetPos((ScrW() - width )/ 4, padding)
  notify:SetSize(width, height)

  local notifyPanel = vgui.Create("DPanel", notify)
  notifyPanel:Dock(FILL)
  notifyPanel.Paint = function (self, w, h)
    local animLerp = Lerp( (SysTime() - startTime) / (newScrapLifetime * 0.25), 0, 1)
    draw.RoundedBox(4, 0, 0, w, h - (textHeight * animLerp), Color(0, 0, 0, 125))
  end

  local balance = vgui.Create("DPanel", notifyPanel)
  balance:Dock(TOP)
  balance:SetHeight(textHeight + padding)
  balance.Paint = function (self, w, h)
    local animLerp = Lerp( (SysTime() - startTime) / (newScrapLifetime * 0.25), 0, difference)
    surface.SetFont("WskyFontDefault")
    local text = formatScrap(math.Round(oldScrapValue + animLerp))
    local textWidth, textHeight = surface.GetTextSize(text)
    draw.DrawText(text, "WskyFontDefault", w / 2, padding, mainMenuColor, TEXT_ALIGN_CENTER)

  end

  local scrapDifference = vgui.Create("DPanel", notifyPanel)
  scrapDifference:Dock(TOP)
  scrapDifference:SetHeight(textHeight + padding)
  scrapDifference.Paint = function (self, w, h)
    local animLerp = Lerp( (SysTime() - startTime) / (newScrapLifetime * 0.25), 1, 0)
    surface.SetFont("WskyFontDefault")
    local text = (difference > 0 and "+" or "")..formatScrap(difference)
    local textWidth, textHeight = surface.GetTextSize(text)
    draw.DrawText(text, "WskyFontDefault", w / 2, padding * animLerp, Color(255, 255, 255, 255 * animLerp), TEXT_ALIGN_CENTER)
  end

  notify:AddItem(notifyPanel)

  newScrapNotification = notify
end

local function drawNewItemNotification(item, playerWonAFreeCrate)

  if (newItemNotification) then
    newItemNotification:Remove()
  end

  local notify = vgui.Create("DNotify")
  notify:SetPos((ScrW() - width) / 2, padding)
  notify:SetSize(width, height + (playerWonAFreeCrate and padding * 3 or 0))

  local notifyPanel = vgui.Create("DPanel", notify)
  notifyPanel:Dock(FILL)
  local color = Color(mainMenuColor.r, mainMenuColor.g, mainMenuColor.b)
  color = darken(color, 0.25)
  notifyPanel:SetBackgroundColor(color)

  local title = vgui.Create("DPanel", notifyPanel)
  title:Dock(TOP)
  title:SetHeight(32 + padding)
  title.Paint = function (self, w, h)
    surface.SetFont("WskyFontSmall")
    local text = "New Item" .. (playerWonAFreeCrate and "s" or "") .. "!"
    local textWidth, textHeight = surface.GetTextSize(text)
    draw.DrawText(text, "WskyFontSmall", w / 2, padding, mainMenuColor, TEXT_ALIGN_CENTER)

    if !playerWonAFreeCrate then return end
  end

  if (playerWonAFreeCrate) then
    surface.SetFont("WskyFontSmaller")
    local freeCrateText = "Plus a free crate!"
    local freeCrateTextWidth, freeCrateTextHeight = surface.GetTextSize(freeCrateText)

    local freeCrateTextPanel = vgui.Create("DPanel", notifyPanel)
    freeCrateTextPanel:Dock(BOTTOM)
    freeCrateTextPanel:SetHeight(freeCrateTextHeight + padding)
    freeCrateTextPanel.Paint = function (self, w, h)
      draw.DrawText(freeCrateText, "WskyFontSmaller", w / 2, (h - freeCrateTextHeight) - padding, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
    end
  end

  local itemHeight = 72
  local itemPanel = vgui.Create("DPanel", notifyPanel)

  itemPanel:Dock(BOTTOM)
  itemPanel:DockMargin(padding, padding, padding, padding)
  itemPanel:SetHeight(itemHeight)
  itemPanel:SetText("")
  itemPanel:SetMouseInputEnabled(true)

  itemPanel.Paint = function (self, w, h)
    local color = Color(0, 0, 0, 0)
    draw.RoundedBox(0, 0, 0, w, h, color)
  end

  local itemName = getItemName(item)
  local itemPreviewData = getItemPreview(item)

  local itemPreviewContainer = vgui.Create("DPanel", itemPanel)
  itemPreviewContainer:SetMouseInputEnabled(true)
  itemPreviewContainer:Dock(LEFT)
  itemPreviewContainer:SetHeight(itemHeight)
  itemPreviewContainer:SetWidth(itemHeight)
  itemPreviewContainer.Paint = function (self, w, h)
    local color = Color(255, 255, 255, 20)
    draw.RoundedBox(0, 0, 0, w, h, color)
  end

  if (itemPreviewData.type == "icon") then
    local itemImage = vgui.Create("DImage", itemPreviewContainer)
    itemImage:Dock(FILL)
    itemImage:SetImage(itemPreviewData.data)
    itemImage:SetMouseInputEnabled(true)
  else
    local itemPreview = vgui.Create("DModelPanel", itemPreviewContainer)
    itemPreview:Dock(FILL)
    itemPreview:SetModel(itemPreviewData.data)
    itemPreview:SetMouseInputEnabled(false)
    itemPreview:SetMouseInputEnabled(true)

    function itemPreview:LayoutEntity(ent)
      if (itemPreviewData.type == "playerModel") then return end

      local rotation = -15
      if (ent:GetModel() == "models/weapons/w_crowbar.mdl") then
        rotation = 105
      end
      ent:SetAngles(Angle(rotation, 0, 0))
      return
    end

    local center = itemPreview.Entity:OBBCenter()
    itemPreview:SetLookAt(center-Vector(2, 0, -5))
    itemPreview:SetCamPos(center-Vector(-10, -20, -5))
    itemPreview:SetDirectionalLight(BOX_RIGHT, Color(255, 255, 255, 255))

    if (itemPreviewData.type == "playerModel") then
      local boneIndex = itemPreview.Entity:LookupBone("ValveBiped.Bip01_Head1")
      local eyepos = itemPreview.Entity:GetBonePosition(boneIndex or 0)
      eyepos:Add(Vector(0, 0, 2))	-- Move up slightly
      itemPreview:SetLookAt(eyepos)
      itemPreview:SetCamPos(eyepos-Vector(-14, 0, 0))	-- Move cam in front of eyes
      itemPreview.Entity:SetEyeTarget(eyepos-Vector(-12, 0, 0))
    end
  end

  local itemInfoPanel = vgui.Create("DPanel", itemPanel)
  itemInfoPanel:SetMouseInputEnabled(true)
  itemInfoPanel:Dock(FILL)
  itemInfoPanel.Paint = function (self, w, h)
    draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 0))
    surface.SetFont("WskyFontSmaller")
    local _, textHeight = surface.GetTextSize(itemName)
    local color = Color(255, 255, 255, 255)
    if (item.tier == "Exotic") then
      color = Color(240, 190, 15, 255)
    elseif (item.tier == "Legendary") then
      color = Color(170, 115, 235, 255)
    elseif (item.tier == "Rare") then
      color = Color(40, 140, 195, 255)
    elseif (item.tier == "Uncommon") then
      color = Color(40, 155, 115, 255)
    end
    draw.SimpleText(itemName, "WskyFontSmaller", padding, padding, color)
    if (item.type == "weapon") then
      draw.SimpleText(getWeaponCategory(item.className) .. " weapon", "WskyFontSmaller", padding, textHeight + padding)
    end
  end

  notify:AddItem(notifyPanel)

  newItemNotification = notify
end

net.Receive("WskyTTTLootboxes_ClientsideWinItem", function ()
  if (!TryTranslation) then TryTranslation = LANG and LANG.TryTranslation or nil end
  local ply = LocalPlayer()
  local soundString = net.ReadString()
  local item = net.ReadTable()
  local winAFreeCrate = net.ReadBool()

  if (SysTime() - lastNewItemTime <= spanBetweenItems) then
    lastNewItemIndex = lastNewItemIndex + 1
    if lastNewItemIndex > 8 then lastNewItemIndex = 1 end
  else lastNewItemIndex = 0 end

  if lastNewItemIndex <= 0 then lastNewItemIndex = 1 end

  if item.tier == "Exotic" then
    ply:EmitSound("wsky_lootboxes/partyblower.mp3", 25)
  else ply:EmitSound("wsky_lootboxes/bracket"..lastNewItemIndex..".wav", 25) end

  drawNewItemNotification(item, winAFreeCrate)

  messagePlayer(ply, "New item" .. (winAFreeCrate and "s" or "") .. ": " .. getItemName(item) .. (winAFreeCrate and ", and a free crate" or "") .. "!")

  lastNewItemTime = SysTime()
end)

net.Receive("WskyTTTLootboxes_ClientsideWinChime", function ()
  local ply = LocalPlayer()
  local soundString = net.ReadString()
  if (!ply or !soundString) then return end
  ply:EmitSound(soundString, 25)
end)

net.Receive("WskyTTTLootboxes_ClientDeathMessage", function ()
  if (!TryTranslation) then TryTranslation = LANG and LANG.TryTranslation or nil end

  local attackerName = net.ReadString()
  local attackerRole = net.ReadFloat()
  local weaponName = net.ReadString()
  local weaponNameIsClass = net.ReadBool()

  local weaponNameSet = (weaponName ~= "")

  if weaponNameIsClass then
    local weapon = weapons.GetStored(weaponName)
    local printName = weapon.PrintName or weapon.ClassName
    local name = (TryTranslation and TryTranslation(printName) or printName)
    weaponName = name
  end

  local roleColor = Color(25, 200, 25, 200)

  if attackerRole == 0 then
    attackerRole = "Innocent"
  elseif attackerRole == 1 then
    attackerRole = "Traitor"
    roleColor = Color(200, 25, 25, 200)
  elseif attackerRole == 2 then
    attackerRole = "Detective"
    roleColor = Color(25, 25, 200, 200)
  end

  chat.AddText(Color(255, 255, 255), "You were killed by ", roleColor, attackerName, Color(255, 255, 255), (weaponNameSet and " using " or ""), topHatBlue, weaponName, Color(255, 255, 255), ". They were ", roleColor, attackerRole, Color(255, 255, 255), ".")
end)

net.Receive("WskyTTTLootboxes_ClientsideNotifyScrap", function ()
  local oldScrapValue = net.ReadFloat()
  local newScrapValue = net.ReadFloat()
  local difference = (newScrapValue - oldScrapValue)

  if difference > 0 then
    LocalPlayer():EmitSound("wsky_lootboxes/gmc_earn.wav", 25)
  elseif difference < 0 then
    LocalPlayer():EmitSound("wsky_lootboxes/gmc_lose.wav", 25)
  end

  drawNewScrapNotification(oldScrapValue, newScrapValue)
end)
