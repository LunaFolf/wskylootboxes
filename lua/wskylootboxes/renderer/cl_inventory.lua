function drawInventory(parent, inventory)

  local quickOpenConvar = GetConVar("wskylootboxes_quick_unbox")
  if !quickOpenConvar then quickOpenConvar = false else quickOpenConvar = quickOpenConvar:GetBool() end

  local itemNum = 0
  for itemIndex, item in pairs(inventory) do
    local itemID = item.itemID
    itemNum = itemNum + 1
    local itemName = getItemName(item)
    local itemPreviewData = getItemPreview(item)

    local offset = (itemNum - 1)
    local itemHeight = stockItemHeight
    local itemPanel = vgui.Create("DButton", parent, "inventoryItem_"..tostring(itemNum))
    local y = (itemHeight * offset) + (padding * offset) + padding

    itemPanel:Dock(TOP)
    itemPanel:DockMargin(margin, margin, margin, 0)
    itemPanel:SetHeight(itemHeight)
    itemPanel:SetText("")
    itemPanel:SetMouseInputEnabled(true)

    itemPanel.Paint = function (self, w, h)
      local color = Color(0, 0, 0, 80)
      draw.RoundedBox(0, 0, 0, w, h, color)
    end

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
      local textWidth, textHeight = surface.GetTextSize(itemName)
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
      if (item.tier == "Exotic") then
        draw.SimpleText(item.exoticParticleEffect, "WskyFontSmaller", textWidth + (padding * 2), padding)
      end
    end

    local itemButtonClickable = vgui.Create("DButton", itemPanel)
    itemButtonClickable:SetPos(0, 0)
    itemButtonClickable:SetSize(parent:GetWide() - (margin * 2), itemHeight)
    itemButtonClickable:SetText("")
    itemButtonClickable:SetMouseInputEnabled(true)
    itemButtonClickable.Paint = function (self, w, h)
      local equipped = false
      
      if (item.type == 'playerModel' and playerData.activePlayerModel.itemID == itemID) then
          equipped = true
      elseif (item.type == 'weapon') then
        if (playerData.activeMeleeWeapon.itemID == itemID) then
          equipped = true
        elseif (playerData.activePrimaryWeapon.itemID == itemID) then
          equipped = true
        elseif (playerData.activeSecondaryWeapon.itemID == itemID) then
          equipped = true
        end
      end

      if (equipped) then
        surface.SetDrawColor(120, 255, 120, 120)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
      end

      if !self:IsHovered() then return end
      local text = ""
      if string.StartWith(item.type, "crate_") and quickOpenConvar then text = "Open Crate?" end
      draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 125))
      draw.SimpleText(text, "WskyFontDefault", w / 2, h / 2, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)

      local extraText = "Right click for options"
      surface.SetFont("WskyFontSmaller")
      local _, textHeight = surface.GetTextSize(extraText)
      draw.SimpleText(extraText, "WskyFontSmaller", w / 2, h - (textHeight + margin), Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end
    local highestParent = getHighestParent(parent)
    local inventoryModelPreview = highestParent:Find("playerModelPreview")
    itemButtonClickable.DoRightClick = function (self)
      rightClickItem(highestParent, item, itemID, itemName, itemPreviewData, inventoryModelPreview)
    end

    if (string.StartWith(item.type, "crate_") and quickOpenConvar) then
      itemButtonClickable.DoClick = function ()
        net.Start("WskyTTTLootboxes_RequestCrateOpening")
          net.WriteString(itemID)
          net.WriteTable(pagination.inventory)
        net.SendToServer()
      end
    end

  end
end
