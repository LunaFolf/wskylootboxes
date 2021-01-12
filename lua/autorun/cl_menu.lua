if SERVER then return end

local menuOpen = false
local menuRef = nil
local width, height = ScrW() / 2, ScrH() / 2
local margin = 8
local padding = 8
local titleBarHeight = 38

hook.Add("PlayerButtonDown", "WskyTTTLootboxes_RequestInventoryData", function (ply, key)
  if (menuOpen or (key ~= KEY_F3 and key ~= KEY_I)) then return end
  requestNewData(true)
  menuOpen = true
end)

function getItemName(item)
  if (!item) then return end

  -- Check if Item is a crate
  local crateTag = "crate_"
  if (string.StartWith(item.type, crateTag)) then
    local crateType = string.sub(item.type, string.len(crateTag) + 1)
    if (crateType == "weapon") then return "Weapon Crate"
    elseif (crateType == "playerModel") then return "Player Model Crate"
    elseif (crateType == "any") then return "Random Crate"
    else return "Unknown Crate" end
  end

  -- Check if Item is a weapon
  if (item.type == "weapon") then
    local weapon = weapons.GetStored(item.className)
    local name = TryTranslation(weapon.PrintName)
    local tier = item.tier
    return item.tier .. " " .. name
  end

  -- Check if Item is a playerModel
  if (item.type == "playerModel") then
    local formattedName = player_manager.TranslateToPlayerModelName(item.modelName)
    local prepend = item.tier == "Exotic" and "Exotic " or ""
    return prepend .. string.upper(string.sub(formattedName, 1, 1)) .. string.sub(formattedName, 2)
  end

  return "[TBC] " .. item.type
end

function getItemPreview(item)
  if (!item) then return end

  -- Check if Item is a crate.
  local crateTag = "crate_"
  if (string.StartWith(item.type, crateTag)) then
    local crateType = string.sub(item.type, string.len(crateTag) + 1)
    local crateIcon = "vgui/ttt/wsky/icon_crate.png"

    if (crateType == "weapon") then
      crateIcon = "vgui/ttt/wsky/icon_crate_weapon.png"
    elseif (crateType == "playerModel") then
      crateIcon = "vgui/ttt/wsky/icon_crate_playerModel.png"
    end

    return {
      ["type"] = "icon",
      ["data"] = crateIcon
    }
  end

  if (item.type == "weapon") then
    local weapon = weapons.GetStored(item.className)

    -- If a weapon icon exists, return that.
    if (weapon.Icon) then
      return {
        ["type"] = "icon",
        ["data"] = weapon.Icon
      }
    end

    -- Otherwise, find an available model and use that.
    return {
      ["type"] = "model",
      ["data"] = weapon.WorldModel or ""
    }
  end

  -- Check if Item is a playerModel
  if (item.type == "playerModel") then
    return {
      ["type"] = "playerModel",
      ["data"] = item.modelName
    }
  end

  return {
    ["type"] = "icon",
    ["data"] = "vgui/spawnmenu/generating"
  }
end

function rightClickItem(frame, item, itemID, itemName, itemPreviewData, inventoryModelPreview)
  if (!frame or !item) then return end

  -- Find cursor position and create menu.
  local posX, posY = frame:CursorPos()
  local Menu = vgui.Create("DMenu", frame)
  Menu:SetPos(posX, posY)

  -- Check if Item is a crate
  local crateTag = "crate_"
  if (string.StartWith(item.type, crateTag)) then
    Menu:AddOption("Open Crate", function ()
      net.Start("WskyTTTLootboxes_RequestCrateOpening")
        net.WriteString(itemID)
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
      net.SendToServer()
      if (item.type == "playerModel" and inventoryModelPreview and item.modelName) then  inventoryModelPreview:SetModel(item.modelName) end
    end)
    Menu:AddSpacer()
  elseif (itemIsEquipped and (item.type == "playerModel" or item.type == "weapon")) then
    Menu:AddOption("Unequip", function ()
      net.Start("WskyTTTLootboxes_UnequipItem")
        net.WriteString(itemID)
      net.SendToServer()
    end)
    Menu:AddSpacer()
  end

  -- Give option to scrap/delete, if allowed.
  local scrapText = "Scrap Item (" .. item.value .. ")"
  if (item.value < 1) then scrapText = "Delete item" end
  if (item.value > -1) then
    Menu:AddOption(scrapText, function ()
      net.Start("WskyTTTLootboxes_ScrapItem")
          net.WriteString(itemID)
        net.SendToServer()
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

function renderMenu()
  if (!TryTranslation) then TryTranslation = LANG and LANG.TryTranslation or nil end

  if (menuRef) then menuRef:Close() end

  local inventoryMenuPanel = createBasicFrame(width, height, "Inventory", true)
  menuRef = inventoryMenuPanel
  inventoryMenuPanel.OnClose = function ()
    menuOpen = false
    menuRef = nil
  end

  local sheet = vgui.Create("DPropertySheet", inventoryMenuPanel)
  sheet:SetPos(0, titleBarHeight)
  sheet:SetSize(width, height - titleBarHeight)
  sheet.Paint = function () end

  local leftInventoryPanel = vgui.Create("DPanel")
  leftInventoryPanel.Paint = function () end

  local rightInventoryPanel = vgui.Create("DPanel")
  rightInventoryPanel.Paint = function () end

  local scroller = vgui.Create("DScrollPanel", leftInventoryPanel)
  scroller:Dock(FILL)
  scroller:InvalidateParent(true)

  local inventoryModelPreview = vgui.Create("DModelPanel", rightInventoryPanel)
  inventoryModelPreview:Dock(FILL)
  inventoryModelPreview:InvalidateParent(true)

  local playerModel = playerData.activePlayerModel.modelName
  if (string.len(playerModel) < 1) then playerModel = LocalPlayer():GetModel() end
  inventoryModelPreview:SetModel(playerModel)
  inventoryModelPreview:SetCamPos(Vector(0, -40, 45))

  local divider = vgui.Create("DHorizontalDivider", sheet, "inventoryDivider")
  divider:Dock(FILL)
  divider:SetLeft(leftInventoryPanel)
  divider:SetRight(rightInventoryPanel)
  divider:SetDividerWidth(4)
  divider:SetLeftMin(width * 0.75)
  divider:SetLeftWidth(width * 0.75)
  divider:SetRightMin(width * 0.25)

  sheet:AddSheet("Inventory", divider)

  local storePanel = vgui.Create("DPanel", sheet)
  storePanel:Dock(FILL)
  storePanel.Paint = function () end
  sheet:AddSheet("Store", storePanel)

  -- local tradingPanel = vgui.Create("DPanel", sheet)
  -- tradingPanel:Dock(FILL)
  -- tradingPanel.Paint = function () end
  -- sheet:AddSheet("Trading", tradingPanel)

  local marketPanel = vgui.Create("DPanel", sheet)
  marketPanel:Dock(FILL)
  marketPanel.Paint = function () end
  sheet:AddSheet("Market", marketPanel)

  local marketScroller = vgui.Create("DScrollPanel", marketPanel)
  marketScroller:Dock(FILL)
  marketScroller.Paint = function () end


  local itemNum = 0
  for itemID, item in pairs(playerData.inventory) do
    itemNum = itemNum + 1
    local itemName = getItemName(item)
    local itemPreviewData = getItemPreview(item)

    local offset = (itemNum - 1)
    local itemHeight = 75
    local itemPanel = vgui.Create("DButton", scroller)
    local y = (itemHeight * offset) + (padding * offset) + padding

    itemPanel:Dock(TOP)
    itemPanel:DockMargin(margin, margin, margin, margin)
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
        local eyepos = itemPreview.Entity:GetBonePosition(boneIndex or 1)
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
      draw.SimpleText(itemName, "WskyFontSmaller", margin, margin)
      if (item.type == "weapon") then
        draw.SimpleText(getWeaponCategory(item.className) .. " weapon", "WskyFontSmaller", margin, textHeight + margin)
      end
    end

    local itemButtonClickable = vgui.Create("DButton", itemPanel)
    itemButtonClickable:SetPos(0, 0)
    itemButtonClickable:SetSize(divider:GetLeftWidth() - (margin * 2), itemHeight)
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
    itemButtonClickable.DoRightClick = function () rightClickItem(inventoryMenuPanel, item, itemID, itemName, itemPreviewData, inventoryModelPreview) end

  end

  local itemNum = 0
  for itemID, item in pairs(storeItems) do
    itemNum = itemNum + 1
    local itemName = getItemName(item)
    local itemPreviewData = getItemPreview(item)

    local offset = (itemNum - 1)
    local itemHeight = 75
    local itemPanel = vgui.Create("DButton", storePanel)
    local y = (itemHeight * offset) + (padding * offset) + padding

    itemPanel:Dock(TOP)
    itemPanel:DockMargin(margin, margin, margin, margin)
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
        local eyepos = itemPreview.Entity:GetBonePosition(boneIndex or 1)
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
    itemButtonClickable:SetSize(divider:GetLeftWidth() - (margin * 2), itemHeight)
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
        net.WriteFloat(itemID)
      net.SendToServer()
    end

  end

  local itemNum = 0
  for itemID, item in pairs(marketData.items) do
    itemNum = itemNum + 1
    local itemName = getItemName(item)
    local itemPreviewData = getItemPreview(item)

    local offset = (itemNum - 1)
    local itemHeight = 75
    local itemPanel = vgui.Create("DButton", marketScroller)
    local y = (itemHeight * offset) + (padding * offset) + padding

    itemPanel:Dock(TOP)
    itemPanel:DockMargin(margin, margin, margin, margin)
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
        local eyepos = itemPreview.Entity:GetBonePosition(boneIndex or 1)
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
      draw.SimpleText(itemName, "WskyFontSmaller", margin, margin)
      draw.SimpleText("Seller: " .. item.ownerName and item.ownerName or item.owner, "WskyFontSmaller", margin, textHeight + margin)
    end

    local itemButtonClickable = vgui.Create("DButton", itemPanel)
    itemButtonClickable:SetPos(0, 0)
    itemButtonClickable:SetSize(divider:GetLeftWidth() - (margin * 2), itemHeight)
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
        net.WriteFloat(itemID)
      net.SendToServer()
    end

  end
end

net.Receive("WskyTTTLootboxes_OpenPlayerInventory", renderMenu)