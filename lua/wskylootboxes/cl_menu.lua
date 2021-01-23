if SERVER then return end

include('cl_renderer.lua')

CreateClientConVar("wskylootboxes_confirm_scrap", 1, true, false, "Show confirmation popup when scrapping an item.")
CreateClientConVar("wskylootboxes_quick_unbox", 0, true, false, "Left click a crate to unbox it instantly.")

local minWidth, minHeight = 960, 540

function updateMenuSize ()
  local w, h = ScrW() / 2, ScrH() / 2
  width, height = math.Clamp(w, minWidth, (ScrW() * 0.75)), math.Clamp(h, minHeight, (ScrH() * 0.75))
end

menuOpen = false
menuRef = nil
width, height = ScrW() / 2, ScrH() / 2
margin = 4
padding = 6
titleBarHeight = 38
tabsSize = 32
footerSize = 46
stockItemHeight = 65
lastTab = nil

updateMenuSize()

hook.Add("OnScreenSizeChanged", "WskyTTTLootboxes_UpdateScreenSize", updateMenuSize)

local renderingHeight = (height - ((titleBarHeight * 2) + 38 + (padding * 2)))
stockItemHeight = renderingHeight / 10


concommand.Add("wskylootboxes_menu", function ()
  requestFreshPlayerData(true)
end)

hook.Add("PlayerButtonUp", "WskyTTTLootboxes_RequestInventoryData", function (ply, key)
  if (menuOpen or (key ~= KEY_F3 and key ~= KEY_I)) then return end
  menuOpen = true
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

  drawTabs(inventoryMenuContainer, activeTab, renderMenu)

  local leftInventoryPanel = vgui.Create("DPanel", inventoryMenuContainer)
  leftInventoryPanel:SetPos(0, tabsSize)
  leftInventoryPanel:SetSize(width * 0.75, height - (titleBarHeight + footerSize + tabsSize))
  leftInventoryPanel.Paint = function () end

  local rightInventoryPanel = vgui.Create("DPanel", inventoryMenuContainer)
  rightInventoryPanel:SetPos(width * 0.75, tabsSize)
  rightInventoryPanel:SetSize(width * 0.25, height - (titleBarHeight + tabsSize))
  rightInventoryPanel.Paint = function () end

  local footerPanel = vgui.Create("DPanel", inventoryMenuContainer)
  _, parentHeight = inventoryMenuContainer:GetSize()
  footerPanel:SetPos(0, parentHeight - footerSize)
  footerPanel:SetSize(width * 0.75, footerSize)
  footerPanel.Paint = function (self, w, h)
    local currentPage = ("Page "..pagination.currentPage.."/"..pagination.totalPages)
    draw.SimpleText(currentPage, "WskyFontSmaller", w / 2, h / 2, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
  end

  local pageBackButton = vgui.Create("DButton", footerPanel)
  pageBackButton:Dock(LEFT)
  pageBackButton:SetText("")
  pageBackButton:SetWidth(math.max(100, footerPanel:GetWide() / 6))
  pageBackButton.Paint = function (self, w, h)
    local lastPage = pagination.currentPage <= 1
    local color = topHatBlue
    local textColor = Color(255, 255, 255, 255)
    if lastPage then
      color = darken(topHatBlue, 0.75)
      textColor.a = 125
    end
    draw.RoundedBox(0, 0, 0, w, h, color)
    draw.SimpleText("Back", "WskyFontSmaller", w / 2, h / 2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
  end
  pageBackButton.DoClick = function ()
    if (pagination.currentPage <= 1) then return end
    pagination.currentPage = pagination.currentPage - 1
    requestFreshPlayerData(true)
  end

  local pageNextButton = vgui.Create("DButton", footerPanel)
  pageNextButton:Dock(RIGHT)
  pageNextButton:SetText("")
  pageNextButton:SetWidth(math.max(100, footerPanel:GetWide() / 6))
  pageNextButton.Paint = function (self, w, h)
    local lastPage = pagination.currentPage >= pagination.totalPages
    local color = topHatBlue
    local textColor = Color(255, 255, 255, 255)
    if lastPage then
      color = darken(topHatBlue, 0.75)
      textColor.a = 125
    end
    draw.RoundedBox(0, 0, 0, w, h, color)
    draw.SimpleText("Next Page", "WskyFontSmaller", w / 2, h / 2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
  end
  pageNextButton.DoClick = function ()
    if (pagination.currentPage >= pagination.totalPages) then return end
    pagination.currentPage = pagination.currentPage + 1
    requestFreshPlayerData(true)
  end

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

  local playerModel = playerData.activePlayerModel.modelName
  if (string.len(playerModel) < 1) then playerModel = LocalPlayer():GetModel() end
  inventoryModelPreview:SetModel(playerModel)
  inventoryModelPreview:SetCamPos(Vector(0, 40, 45))
  function inventoryModelPreview.Entity:GetPlayerColor()
    return LocalPlayer():GetPlayerColor():ToColor() or Vector(1, 1, 1)
  end
  function inventoryModelPreview:LayoutEntity(ent)
    ent:SetAngles(Angle(0, viewModelRotationDragger:GetFloatValue() - 90,  0))
  end

  if (activeTab == "inventory") then drawInventory(leftInventoryPanel, playerData.inventory)
  elseif (activeTab == "store") then drawStore(leftInventoryPanel, storeItems)
  elseif (activeTab == "market") then drawMarket(leftInventoryPanel, marketData.items)
  elseif (activeTab == "leaderboard") then drawLeaderboard(leftInventoryPanel, leaderboardData)
  else renderMenu("inventory") end

end

net.Receive("WskyTTTLootboxes_OpenPlayerInventory", function ()
  local tab = net.ReadString() or "inventory"
  renderMenu(tab)
end)