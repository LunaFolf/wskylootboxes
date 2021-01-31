local function drawTitle(text, parent)
  if !text or !parent then return end
  local label = parent:Add("DLabel")

  surface.SetFont("WskyFontRegular")
  local w, h = surface.GetTextSize(text)

  label:Dock(TOP)
  label:SetHeight(h)
  label:DockMargin(0, 0, 0, margin)
  label:SetFont("WskyFontRegular")
  label:SetText(text)
end

function drawSettings(parent)
  local settingsPanel = vgui.Create("DPanel", parent)
  settingsPanel:Dock(FILL)
  settingsPanel:DockPadding(padding * 4, padding * 4, padding * 4, padding * 4)
  settingsPanel.Paint = function (self, w, h)
    draw.RoundedBox(0, 0, 0, w, h, Color(75, 75, 75, 255))
  end

  drawTitle("Inventory Settings", settingsPanel)

  local quickUnboxSetting = settingsPanel:Add("DCheckBoxLabel")
  quickUnboxSetting:DockMargin(padding * 4, margin, 0, margin)
  quickUnboxSetting:Dock(TOP)
  quickUnboxSetting:SetText("Quickly unbox lootboxes (left click)")
  quickUnboxSetting:SetConVar("wskylootboxes_quick_unbox")
  quickUnboxSetting:SizeToContents()

  local confirmScrapSetting = settingsPanel:Add("DCheckBoxLabel")
  confirmScrapSetting:DockMargin(padding * 4, margin, 0, margin)
  confirmScrapSetting:Dock(TOP)
  confirmScrapSetting:SetText("Show confirmation before scrapping items")
  confirmScrapSetting:SetConVar("wskylootboxes_confirm_scrap")
  confirmScrapSetting:SizeToContents()

  drawTitle("UI Settings", settingsPanel)

  local colorMixerLabel = vgui.Create("DLabel", settingsPanel)
  local labelText = "UI Main Colour"
  surface.SetFont("WskyFontSmaller")
  local _, textHeight = surface.GetTextSize(labelText)
  colorMixerLabel:Dock(TOP)
  colorMixerLabel:SetHeight(textHeight)
  colorMixerLabel:DockMargin(0, margin, 0, margin)
  colorMixerLabel:SetFont("WskyFontSmaller")
  colorMixerLabel:SetText(labelText)

  local UIColorMixer = vgui.Create("DColorMixer", settingsPanel)
  UIColorMixer:DockMargin(padding * 4, margin, padding * 4, margin)
  UIColorMixer:SetSize(150, 150)
  UIColorMixer:Dock(TOP)
  UIColorMixer:SetPalette(true)
  UIColorMixer:SetAlphaBar(false)
  UIColorMixer:SetWangs(true)
  UIColorMixer:SetColor(mainMenuColor)

  UIColorMixer:SetConVarR("wskylootboxes_menucolor_red")
  UIColorMixer:SetConVarG("wskylootboxes_menucolor_green")
  UIColorMixer:SetConVarB("wskylootboxes_menucolor_blue")

  UIColorMixer.ValueChanged = function (self, color)
    updateMenuColor(color.r, color.g, color.b)
  end

  local colorResetBtn = vgui.Create("DButton", settingsPanel)
  colorResetBtn:Dock(TOP)
  colorResetBtn:SetText("")
  local w, h = colorResetBtn:GetSize()
  colorResetBtn:SetSize(parent:GetWide() / 2, h * 1.5)
  colorResetBtn:DockMargin(padding * 4, margin, parent:GetWide() * 0.75, margin)
  colorResetBtn.Paint = function (self, w, h)
    draw.RoundedBox(0, 0, 0, w, h, mainMenuColor)
    draw.SimpleText("Reset Colour", "WskyFontSmaller", w / 2, h / 2, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
  end
  colorResetBtn.DoClick = function ()
    UIColorMixer:SetColor(topHatBlue)
  end

  drawTitle("Notification Settings", settingsPanel)

  local notificationVolumeLabel = vgui.Create("DLabel", settingsPanel)
  local labelText = "Notification volume"
  surface.SetFont("WskyFontSmaller")
  local _, textHeight = surface.GetTextSize(labelText)
  notificationVolumeLabel:Dock(TOP)
  notificationVolumeLabel:SetHeight(textHeight)
  notificationVolumeLabel:DockMargin(0, margin, 0, margin)
  notificationVolumeLabel:SetFont("WskyFontSmaller")
  notificationVolumeLabel:SetText(labelText)

  local notificationVolume = GetConVar("wskylootboxes_volume")
  local notificationVolumeSlider = vgui.Create("DNumSlider", settingsPanel)
  notificationVolumeSlider:DockMargin(padding * 4, margin, padding * 4, margin)
  notificationVolumeSlider:Dock(TOP)
  notificationVolumeSlider:SetMin(0)
  notificationVolumeSlider:SetMax(100)
  notificationVolumeSlider:SetDecimals(0)
  notificationVolumeSlider:SetValue((notificationVolume:GetFloat() * 100) or 25)

  notificationVolumeSlider.OnValueChanged = function (self, value)
    notificationVolume:SetFloat(value / 100)
  end
end
