if SERVER then return end

include('cl_inventory.lua')
include('cl_market.lua')
include('cl_store.lua')
include('cl_leaderboard.lua')
include('cl_settings.lua')

local tabs = {
  {
    ["name"] = "Inventory",
    ["class"] = "inventory"
  },
  {
    ["name"] = "Store",
    ["class"] = "store"
  },
  {
    ["name"] = "Market",
    ["class"] = "market"
  },
  {
    ["name"] = "Leaderboard",
    ["class"] = "leaderboard"
  },
  {
    ["name"] = "Settings",
    ["class"] = "settings"
  }
}

function getHighestParent(panel)
  local parent = nil
  local loop = true

  while loop do
    parent = (parent and parent:GetParent() or panel:GetParent())
    if parent:GetName() == "WskyDFrame" then
      loop = false
    end
  end
  return parent
end

function rightClickItem(frame, item, itemID, itemName, itemPreviewData, inventoryModelPreview)
  if (!frame or !item) then return end

  -- Find cursor position and create menu.
  local posX, posY = frame:LocalCursorPos()
  local Menu = vgui.Create("DMenu", frame)
  Menu:SetPos(posX, posY)
  Menu:MoveToFront()

  -- Check if Item is a crate
  local crateTag = "crate_"
  if (string.StartWith(item.type, crateTag)) then
    Menu:AddOption("Open Crate", function ()
      net.Start("WskyTTTLootboxes_RequestCrateOpening")
        net.WriteString(itemID)
        net.WriteTable(pagination.inventory)
      net.SendToServer()
    end)
    Menu:AddSpacer()
  end
  
  
  local itemIsEquipped = (itemID == playerData.activeMeleeWeapon.itemID) or (itemID == playerData.activePrimaryWeapon.itemID) or (itemID == playerData.activeSecondaryWeapon.itemID) or (itemID == playerData.activePlayerModel.itemID)

  -- Check if Item is a playerModel or weapon
  if (not itemIsEquipped and (item.type == "playerModel" or item.type == "weapon")) then
    Menu:AddOption("Equip", function ()
      net.Start("WskyTTTLootboxes_EquipItem")
        net.WriteString(itemID)
        net.WriteTable(pagination.inventory)
      net.SendToServer()
      if (item.type == "playerModel" and inventoryModelPreview and item.modelName) then  inventoryModelPreview:SetModel(item.modelName) end
    end)
    Menu:AddSpacer()
  elseif (itemIsEquipped and (item.type == "playerModel" or item.type == "weapon")) then
    Menu:AddOption("Unequip", function ()
      net.Start("WskyTTTLootboxes_UnequipItem")
        net.WriteString(itemID)
        net.WriteTable(pagination.inventory)
      net.SendToServer()
    end)
    Menu:AddSpacer()
  end

  if (item.type == "weapon") then
    local name = nil
    Menu:AddOption("Rename Weapon (200 scrap)", function ()
        local questionPanel = vgui.Create("DFrame")
        questionPanel:MakePopup()
        questionPanel:SetSize( 400, 200 )
        questionPanel:Center()

        function renameItem()
          if (name and string.len(name) > 0 and string.len(name) < 50) then
            net.Start("WskyTTTLootboxes_RenameItem")
              net.WriteString(itemID)
              net.WriteString(name)
              net.WriteTable(pagination.inventory)
            net.SendToServer()
          end
        end

        local valueEntry = vgui.Create( "DTextEntry", questionPanel )
        valueEntry:Dock(TOP)
        valueEntry:SetPlaceholderText("Enter your weapon's new name!")
        valueEntry.OnEnter = function( self )
          name = self:GetValue()
          questionPanel:Close()

          renameItem()
        end

        local continueBtn = vgui.Create("DButton", questionPanel)
        continueBtn:Dock(BOTTOM)
        continueBtn:SetText("Continue")
        continueBtn.DoClick = function ()
          name = valueEntry:GetValue()
          questionPanel:Close()

          renameItem()
        end
      end)
      Menu:AddSpacer()
  end

  -- Give option to scrap/delete, if allowed.
  local scrapText = "Scrap Item (" .. item.value .. ")"
  if (item.value < 1) then scrapText = "Delete item" end
  if (item.value > -1) then
    Menu:AddOption(scrapText, function ()
      local width, height = width / 4, height / 4
      width = math.max(350, width)
      height = math.max(100, height)

      local submitScrapRequest = function ()
        net.Start("WskyTTTLootboxes_ScrapItem")
          net.WriteString(itemID)
          net.WriteTable(pagination.inventory)
        net.SendToServer()
      end

      local showDialog = GetConVar("wskylootboxes_confirm_scrap")
      if !showDialog then showDialog = true else showDialog = showDialog:GetBool() end

      if showDialog then
        createDialog(width, height, "Are you sure you want to scrap this item?" , function ()
          submitScrapRequest()
        end)
      else submitScrapRequest() end

    end)
    Menu:AddSpacer()
  end

  -- Give option to put on market, if allowed.
  local marketText = "Put item on market"
  if (item.value > -1) then
    local value = 0

    Menu:AddOption(marketText, function ()
      local questionPanel = vgui.Create("DFrame")
      questionPanel:MakePopup()
      questionPanel:SetSize( 400, 200 )
      questionPanel:Center()

      function sellItem()
        if (value and value > -1) then
          net.Start("WskyTTTLootboxes_SellItem")
            net.WriteString(itemID)
            net.WriteFloat(value)
            net.WriteTable(pagination.inventory)
          net.SendToServer()
        end
      end

      local valueEntry = vgui.Create( "DTextEntry", questionPanel )
      valueEntry:Dock(TOP)
      valueEntry:SetPlaceholderText("Enter value you want to sell your item for")
      valueEntry.OnEnter = function( self )
        value = tonumber(self:GetValue())
        questionPanel:Close()

        sellItem()
      end

      local continueBtn = vgui.Create("DButton", questionPanel)
      continueBtn:Dock(BOTTOM)
      continueBtn:SetText("Continue")
      continueBtn.DoClick = function ()
        value = tonumber(valueEntry:GetValue())
        questionPanel:Close()

        sellItem()
      end
    end)
  end
end

local function drawTabButton(self, w, h, tab, activeTab)
  local color = Color(mainMenuColor.r, mainMenuColor.g, mainMenuColor.b)
  color = darken(color, 0.25)
  if (activeTab == tab.class) then color.a = 0
  elseif self:IsHovered() then color.a = 175 end
  draw.RoundedBox(0, 0, 0, w, h, color)
  draw.SimpleText(tab.name, "WskyFontSmaller", w / 2, h / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function drawTabs(parent, activeTab, renderMenuFn)
  local width, height = parent:GetSize()
  local numberOfTabs = table.Count(tabs)

  local tabsPanel = vgui.Create("DPanel", parent)
  tabsPanel:Dock(TOP)
  tabsPanel:SetHeight(tabsSize)
  tabsPanel.Paint = function (self, w, h)
    local color = Color(mainMenuColor.r, mainMenuColor.g, mainMenuColor.b)
    color = darken(color, 0.75)
    draw.RoundedBox(0, 0, 0, w, h, color)
  end

  for i, tab in ipairs(tabs) do
    local tabButton = vgui.Create("DButton", tabsPanel)
    tabButton:Dock(LEFT)
    tabButton:SetWidth(width / numberOfTabs)
    tabButton:SetText("")
    tabButton.Paint = function (self, w, h)
      drawTabButton(self, w, h, tab, activeTab)
    end
    tabButton.DoClick = function ()
      if (tab.class == "inventory") then requestFreshPlayerData(true)
      elseif (tab.class == "store") then requestFreshStoreData(true)
      elseif (tab.class == "market") then requestFreshMarketData(true)
      elseif (tab.class == "settings") then
        renderMenu("settings")
      elseif (tab.class == "leaderboard") then requestFreshLeaderboardData(true) end
    end
  end
end
