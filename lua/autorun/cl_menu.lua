if SERVER then return end

local TryTranslation = LANG and LANG.TryTranslation or nil

local menuOpen = false
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
    return player_manager.TranslateToPlayerModelName(item.modelName)
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

function rightClickItem(btn, item, itemID, itemName, itemPreviewData)
  print("right click!")
  if (!btn or !item) then return end

  print(itemID, itemName)

  -- Check if Item is a crate
  local crateTag = "crate_"
  if (string.StartWith(item.type, crateTag)) then
    local posX, posY = btn:CursorPos()
    local Menu = vgui.Create("DMenu", btn)
    Menu:SetPos(posX, posY)
    Menu:AddOption("Open Crate", function ()
      net.Start("WskyTTTLootboxes_RequestCrateOpening")
        net.WriteString(itemID)
      net.SendToServer()
    end)
  end
end


net.Receive("WskyTTTLootboxes_OpenPlayerInventory", function ()

  if (!TryTranslation) then TryTranslation = LANG and LANG.TryTranslation or nil end

  local inventoryMenuPanel = createBasicFrame(width, height, "Inventory", true)
  inventoryMenuPanel.OnClose = function ()
    menuOpen = false
  end

  local leftPanel = vgui.Create("DPanel", inventoryMenuPanel)
  leftPanel.Paint = function () end

  local scroller = vgui.Create("DScrollPanel", leftPanel)
  scroller:Dock(FILL)
  scroller:InvalidateParent(true)

  local divider = vgui.Create("DHorizontalDivider", inventoryMenuPanel)
  divider:SetPos(0, titleBarHeight)
  divider:SetSize(width, height - titleBarHeight)
  divider:SetLeft(leftPanel)
  divider:SetDividerWidth(4)
  divider:SetLeftMin(width)
  divider:SetLeftWidth(width)
  divider:SetRightMin(0)

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
      draw.SimpleText(itemName, "WskyFontSmaller", margin, margin)
    end

    local itemButtonClickable = vgui.Create("DButton", itemPanel)
    itemButtonClickable:SetPos(0, 0)
    itemButtonClickable:SetSize(divider:GetLeftWidth() - (margin * 2), itemHeight)
    itemButtonClickable:SetText("")
    itemButtonClickable:SetMouseInputEnabled(true)
    itemButtonClickable.Paint = function () end
    itemButtonClickable.DoRightClick = function () rightClickItem(itemPanel, item, itemID, itemName, itemPreviewData) end

  end
end)