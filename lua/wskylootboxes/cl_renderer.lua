if SERVER then return end

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
  local color = Color(topHatBlue.r, topHatBlue.g, topHatBlue.b)
  color = darken(color, 0.25)
  if (activeTab == tab.class) then color.a = 0 end
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
    local color = Color(topHatBlue.r, topHatBlue.g, topHatBlue.b)
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
      elseif (tab.class == "leaderboard") then requestFreshLeaderboardData(true) end
    end
  end
end

function drawInventory(parent, inventory)

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
    end
    local highestParent = getHighestParent(parent)
    local inventoryModelPreview = highestParent:Find("playerModelPreview")
    itemButtonClickable.DoRightClick = function (self)
      rightClickItem(highestParent, item, itemID, itemName, itemPreviewData, inventoryModelPreview)
    end
    local quickOpenConvar = GetConVar("wskylootboxes_quick_unbox")
    if !quickOpenConvar then quickOpenConvar = false else quickOpenConvar = quickOpenConvar:GetBool() end

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

    local itemPriceTag = vgui.Create("DPanel", itemPanel)
    itemPriceTag:Dock(RIGHT)
    itemPriceTag:SetHeight(itemHeight)
    itemPriceTag:SetWidth(itemHeight)
    itemPriceTag.Paint = function (self, w, h)
      local color = Color(0, 202, 255, 225)
      draw.RoundedBox(0, 0, 0, w, h, color)

      surface.SetFont("WskyFontSmaller")
      local text = item.value
      local priceWidth, priceHeight = surface.GetTextSize(text)
      draw.SimpleText(text, "WskyFontSmaller", (w - priceWidth) / 2, (h - priceHeight) / 2)
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
    end
    itemButtonClickable.DoClick = function () 
      net.Start("WskyTTTLootboxes_BuyFromStore")
        net.WriteFloat(itemIndex)
      net.SendToServer()
    end

  end
end

function drawMarket(parent, marketItems)

  local itemNum = 0
  for itemIndex, item in pairs(marketItems) do
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

    local itemPriceTag = vgui.Create("DPanel", itemPanel)
    itemPriceTag:Dock(RIGHT)
    itemPriceTag:SetHeight(itemHeight)
    itemPriceTag:SetWidth(itemHeight)
    itemPriceTag.Paint = function (self, w, h)
      local color = Color(0, 202, 255, 225)
      draw.RoundedBox(0, 0, 0, w, h, color)

      surface.SetFont("WskyFontSmaller")
      local text = item.value
      local priceWidth, priceHeight = surface.GetTextSize(text)
      draw.SimpleText(text, "WskyFontSmaller", (w - priceWidth) / 2, (h - priceHeight) / 2)
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
      draw.SimpleText(itemName, "WskyFontSmaller", margin, margin, color)
      draw.SimpleText("Seller: " .. item.ownerName and item.ownerName or item.owner, "WskyFontSmaller", margin, textHeight + margin)
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
    end
    itemButtonClickable.DoClick = function () 
      net.Start("WskyTTTLootboxes_BuyFromMarket")
        net.WriteFloat((itemIndex) + ((pagination.market.currentPage - 1) * 9))
      net.SendToServer()
    end

  end
end

function drawLeaderboard(parent, leaderboardData)
  local wipText = vgui.Create("DLabel", parent)
  local _, divHeight = parent:GetSize()
  wipText:SetText("This panel is still being developed and is currently not available.\nPlease check again in the future.")
  wipText:Dock(FILL)
  wipText:SetHeight(stockItemHeight)
  wipText:SetFont("WskyFontSmaller")
  wipText:DockMargin(margin * 2, 0, margin * 2, 0)
  wipText:SetWrap(true)
  wipText:CenterHorizontal()
end