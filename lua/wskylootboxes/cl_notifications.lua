if SERVER then return end

local padding = 8
local width, height = math.max(400, ScrW() / 5), 72 + (32 + (padding * 2))
local newItemNotification = nil

local function drawNewItemNotification(item, playerWonAFreeCrate)

  if (newItemNotification) then
    newItemNotification:Remove()
  end

  local notify = vgui.Create("DNotify")
  notify:SetPos((ScrW() - width) / 2, padding)
  notify:SetSize(width, height + (playerWonAFreeCrate and padding * 3 or 0))

  local notifyPanel = vgui.Create("DPanel", notify)
  notifyPanel:Dock(FILL)
  local color = Color(topHatBlue.r, topHatBlue.g, topHatBlue.b)
  color = darken(color, 0.25)
  notifyPanel:SetBackgroundColor(color)

  local title = vgui.Create("DPanel", notifyPanel)
  title:Dock(TOP)
  title:SetHeight(32 + padding)
  title.Paint = function (self, w, h)
    surface.SetFont("WskyFontSmall")
    local text = "New Item" .. (playerWonAFreeCrate and "s" or "") .. "!"
    local textWidth, textHeight = surface.GetTextSize(text)
    draw.DrawText(text, "WskyFontSmall", w / 2, padding, topHatBlue, TEXT_ALIGN_CENTER)

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

  drawNewItemNotification(item, winAFreeCrate)

  messagePlayer(ply, "New item" .. (winAFreeCrate and "s" or "") .. ": " .. getItemName(item) .. (winAFreeCrate and ", and a free crate" or "") .. "!")

  ply:EmitSound(soundString)
end)

net.Receive("WskyTTTLootboxes_ClientsideWinChime", function ()
  local ply = LocalPlayer()
  local soundString = net.ReadString()
  if (!ply or !soundString) then return end
  ply:EmitSound(soundString)
end)