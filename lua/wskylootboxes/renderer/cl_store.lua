function drawStore(parent, storeItems)

  local itemNum = 0
  for itemIndex, item in pairs(storeItems) do
    local itemID = item.itemID
    itemNum = itemNum + 1
    local itemName = getItemName(item)
    local itemPreviewData = getItemPreview(item)

    local offset = (itemNum - 1)
    local itemHeight = stockItemHeight
    local itemPanel = vgui.Create("DButton", parent)
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

    surface.SetFont("WskyFontSmaller")
    local priceText = formatScrap(item.value)
    local priceWidth, _ = surface.GetTextSize(item.value)

    local itemPriceTag = vgui.Create("DPanel", itemPanel)
    itemPriceTag:Dock(RIGHT)
    itemPriceTag:SetHeight(itemHeight)
    itemPriceTag:SetWidth(math.min(parent:GetWide() - (itemHeight * 4), math.max(itemHeight, priceWidth + (padding * 2))))
    itemPriceTag.Paint = function (self, w, h)
      local color = Color(0, 202, 255, 225)
      if playerData.scrap < item.value then
        color = globalColors.negative
      end
      draw.RoundedBox(0, 0, 0, w, h, color)

      surface.SetFont("WskyFontSmaller")
      local priceWidth, priceHeight = surface.GetTextSize(priceText)
      draw.SimpleText(priceText, "WskyFontSmaller", (w - priceWidth) / 2, (h - priceHeight) / 2)
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
      draw.SimpleText(itemName, "WskyFontSmaller", margin, margin)
    end

    local itemButtonClickable = vgui.Create("DButton", itemPanel)
    itemButtonClickable:SetPos(0, 0)
    itemButtonClickable:SetSize(parent:GetWide() - (margin * 2), itemHeight)
    itemButtonClickable:SetText("")
    itemButtonClickable:SetMouseInputEnabled(true)
    itemButtonClickable.Paint = function (self, w, h)
      if !self:IsHovered() then return end
      local text = "Buy Item?"
      local enoughMoneyToBuy = playerData.scrap >= item.value
      local borderColor = globalColors.positive
      if !enoughMoneyToBuy then
        text = "Not enough scrap"
        borderColor = globalColors.negative
      end
      borderColor.a = 120
      draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 125))
      draw.SimpleText(text, "WskyFontDefault", w / 2, h / 2, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      surface.SetDrawColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
      surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    itemButtonClickable.DoClick = function () 
      net.Start("WskyTTTLootboxes_BuyFromStore")
        net.WriteFloat(itemIndex)
      net.SendToServer()
    end

  end
end