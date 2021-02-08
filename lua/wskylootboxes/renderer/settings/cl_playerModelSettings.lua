function drawPlayerModelSettings(parent)
  local settingsPanel = vgui.Create("DPanel", parent)
  settingsPanel:Dock(FILL)
  settingsPanel:DockPadding(padding * 4, padding * 4, padding * 4, padding * 4)
  settingsPanel.Paint = function (self, w, h)
    draw.RoundedBox(0, 0, 0, w, h, Color(125, 125, 125, 125))
  end

  local leftInventoryPanel = vgui.Create("DPanel", settingsPanel)
  leftInventoryPanel:Dock(LEFT)
  leftInventoryPanel:SetWidth((width - (padding * 8)) * 0.75)
  leftInventoryPanel.Paint = function () end

  local rightInventoryPanel = vgui.Create("DPanel", settingsPanel)
  rightInventoryPanel:Dock(RIGHT)
  rightInventoryPanel:SetWidth((width - (padding * 8)) * 0.25)
  rightInventoryPanel.Paint = function () end

  local bodyGroups = {}

  local inventoryModelPreview = vgui.Create("DModelPanel", rightInventoryPanel, "playerModelPreview")
  inventoryModelPreview:Dock(FILL)

  local viewModelRotationDragger = vgui.Create("DNumberScratch", rightInventoryPanel)
  viewModelRotationDragger:Dock(FILL)
  viewModelRotationDragger:SetHeight(32)
  viewModelRotationDragger:SetValue(180)
  viewModelRotationDragger:SetMin(0)
  viewModelRotationDragger:SetMax(360)
  viewModelRotationDragger:SetImageVisible(false)
  viewModelRotationDragger.PaintScratchWindow = function () end

  inventoryModelPreview:SetModel(currentPlayerModel)
  inventoryModelPreview:SetCamPos(Vector(0, 40, 45))
  function inventoryModelPreview.Entity:GetPlayerColor()
    return LocalPlayer():GetPlayerColor():ToColor() or Vector(1, 1, 1)
  end
  function inventoryModelPreview:LayoutEntity(ent)
    ent:SetAngles(Angle(0, viewModelRotationDragger:GetFloatValue() - 90,  0))
  end

  for groupID, groupValue in pairs(currentPlayerModelBodyGroups) do
    inventoryModelPreview.Entity:SetBodygroup(tonumber(groupID), groupValue)
  end

  bodyGroups = inventoryModelPreview.Entity:GetBodyGroups()

  for i, group in ipairs(bodyGroups) do

    if table.Count(group.submodels) > 1 then
      local curBodyGroupValue = inventoryModelPreview.Entity:GetBodygroup(group.id)

      surface.SetFont("WskyFontSmaller")
      local textWidth, textHeight = surface.GetTextSize(group.name)

      local sliderContainer = vgui.Create("DPanel", leftInventoryPanel)
      sliderContainer:Dock(TOP)
      sliderContainer:SetHeight(textHeight)
      sliderContainer:DockMargin(0, margin, 0, margin)
      sliderContainer.Paint = function () end

      local bodyGroupLabel = vgui.Create("DLabel", sliderContainer)
      bodyGroupLabel:Dock(LEFT)
      bodyGroupLabel:SetWidth(textWidth)
      bodyGroupLabel:SetFont("WskyFontSmaller")
      bodyGroupLabel:SetText(group.name)
      bodyGroupLabel:SetColor(Color(40,40,40,255))

      local bodyGroupSlider = vgui.Create("DNumSlider", sliderContainer)
      bodyGroupSlider:Dock(RIGHT)
      bodyGroupSlider:SetWidth(width)
      bodyGroupSlider:SetMin(0)
      bodyGroupSlider:SetValue(curBodyGroupValue)
      bodyGroupSlider:SetMax(table.Count(group.submodels) - 1)
      bodyGroupSlider:SetDecimals(0)

      bodyGroupSlider.OnValueChanged = function (self, value)
        value = math.Round(value)
        if value == curBodyGroupValue then return end

        curBodyGroupValue = value
        inventoryModelPreview.Entity:SetBodygroup(group.id, value)

        net.Start("WskyTTTLootboxes_PlayerModelBodyGroup")
          net.WriteString(currentPlayerModelID)
          net.WriteFloat(group.id)
          net.WriteFloat(value)
        net.SendToServer()

      end
    end
  end

end
