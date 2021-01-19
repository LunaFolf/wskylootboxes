if SERVER then return end

include('cl_renderer.lua')

menuOpen = false
menuRef = nil
width, height = ScrW() / 2, ScrH() / 2
margin = 4
padding = 6
titleBarHeight = 38
stockItemHeight = 65
lastTab = nil
scrollToChild = nil

hook.Add("PlayerButtonDown", "WskyTTTLootboxes_RequestInventoryData", function (ply, key)
  if (menuOpen or (key ~= KEY_F3 and key ~= KEY_I)) then return end
  requestFreshPlayerData(true)
end)

function renderMenu(activeTab)
  if (!TryTranslation) then TryTranslation = LANG and LANG.TryTranslation or nil end

  if (menuRef) then menuRef:Close() end

  activeTab = activeTab or "inventory"
  lastTab = string.sub(activeTab, 1)

  local inventoryMenuPanel = createBasicFrame(width, height, "Inventory", true)
  menuRef = inventoryMenuPanel
  inventoryMenuPanel.OnClose = function ()
    menuOpen = false
    menuRef = nil
  end

  local inventoryMenuContainer = vgui.Create("DPanel", inventoryMenuPanel)
  inventoryMenuContainer:SetPos(0, titleBarHeight)
  inventoryMenuContainer:SetSize(width, height - titleBarHeight)
  inventoryMenuContainer.Paint = function () end

  local leftInventoryPanel = vgui.Create("DPanel")
  leftInventoryPanel.Paint = function () end

  local rightInventoryPanel = vgui.Create("DPanel")
  rightInventoryPanel.Paint = function () end

  local scroller = vgui.Create("DScrollPanel", leftInventoryPanel)
  scroller:Dock(FILL)
  scroller:InvalidateParent(true)

  local divider = vgui.Create("DHorizontalDivider", inventoryMenuContainer, "inventoryDivider")
  divider:Dock(FILL)
  divider:SetLeft(leftInventoryPanel)
  divider:SetRight(rightInventoryPanel)
  divider:SetDividerWidth(4)
  divider:SetLeftMin(width * 0.75)
  divider:SetLeftWidth(width * 0.75)
  divider:SetRightMin(width * 0.25)

  local inventoryModelPreview = vgui.Create("DModelPanel", rightInventoryPanel, "playerModelPreview")
  inventoryModelPreview:Dock(FILL)

  local viewModelScroller = vgui.Create("DNumberScratch", rightInventoryPanel)
  viewModelScroller:Dock(FILL)
  viewModelScroller:SetHeight(32)
  viewModelScroller:SetValue(180)
  viewModelScroller:SetMin(0)
  viewModelScroller:SetMax(360)
  viewModelScroller:SetImageVisible(false)
  viewModelScroller.PaintScratchWindow = function () end

  local playerModel = playerData.activePlayerModel.modelName
  if (string.len(playerModel) < 1) then playerModel = LocalPlayer():GetModel() end
  inventoryModelPreview:SetModel(playerModel)
  inventoryModelPreview:SetCamPos(Vector(0, 40, 45))
  function inventoryModelPreview.Entity:GetPlayerColor()
    return LocalPlayer():GetPlayerColor():ToColor() or Vector(1, 1, 1)
  end
  function inventoryModelPreview:LayoutEntity(ent)
    ent:SetAngles(Angle(0, viewModelScroller:GetFloatValue() - 90,  0))
  end

  drawTabs(inventoryMenuContainer, activeTab, renderMenu)

  if (activeTab == "inventory") then drawInventory(scroller, playerData.inventory)
  elseif (activeTab == "store") then drawStore(scroller, storeItems)
  elseif (activeTab == "market") then drawMarket(scroller, marketData.items)
  elseif (activeTab == "leaderboard") then drawLeaderboard(scroller, leaderboardData)
  else renderMenu("inventory") end

  local bottomPaddingBlock = vgui.Create("DPanel", scroller)
  bottomPaddingBlock:Dock(TOP)
  bottomPaddingBlock:DockMargin(margin, margin * 2, margin * 2, margin)
  bottomPaddingBlock:SetHeight(margin * 2)
  bottomPaddingBlock:SetText("")
  bottomPaddingBlock:SetMouseInputEnabled(true)
  bottomPaddingBlock.Paint = function () end
end

net.Receive("WskyTTTLootboxes_OpenPlayerInventory", function ()
  local tab = net.ReadString() or "inventory"
  renderMenu(tab)
end)