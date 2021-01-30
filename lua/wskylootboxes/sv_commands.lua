if CLIENT then return end

local function findPlayers(nicknameFilter)
  local players = {}

  nicknameFilter = string.Trim(nicknameFilter, "\"")
  nicknameFilter = string.lower(nicknameFilter)

  for k, v in ipairs(player.GetAll()) do
    local nickname = v:Nick()
    if string.find( string.lower( nickname ), nicknameFilter ) then table.insert(players, v) end
  end

  return players
end

local function autoComplete(cmd, argStr)

  argStr = string.Trim(argStr) -- Trim any whitespace from the arguments

  local argTable = string.Split(argStr, " ") -- Get arguments in table format for easier access
  local curArgIndex, curArgValue = table.Count(argTable), argTable[table.Count(argTable)] -- Get current argument for autofill, It should just be the last one.

  local fullString = cmd .. " " .. table.concat(argTable, " ", 1, curArgIndex - 1) .. ((curArgIndex > 1) and " " or "")

  local returnTable = {}

  if (string.StartWith(cmd, "wskylootboxes_crate")) then
    if curArgIndex == 1 then
      table.insert(returnTable, fullString.."crate_any")
      for k, v in ipairs(crateTypes) do
        table.insert(returnTable, fullString.."crate_"..v)
      end
    elseif curArgIndex == 2 then
      for k, v in ipairs(findPlayers(curArgValue)) do
        table.insert(returnTable, fullString .. ("\"" .. v:Nick() .. "\""))
      end
    end
  end

  if (string.StartWith(cmd, "wskylootboxes_scrap")) then
    if curArgIndex == 1 then
      local args = {"add", "set", "clear", "reset"}
      for k, v in ipairs(args) do
        table.insert(returnTable, fullString..v)
      end
    elseif curArgIndex == 2 then
      for k, v in ipairs(findPlayers(curArgValue)) do
        table.insert(returnTable, fullString .. ("\"" .. v:Nick() .. "\""))
      end
    end
  end

  return returnTable
end

concommand.Add("wskylootboxes_crate", function (ply, cmd, args, argStr)
  local crateType = args[1]
  local playerName = args[2]
  local numberOfCrates = tonumber(args[3]) or 1

  if (not crateType or not playerName) then return end

  local players = findPlayers(playerName)

  for crateNum = 1, numberOfCrates do
    for k, v in ipairs(players) do
      local steam64 = v:SteamID64()
      local playerData = getPlayerData(steam64)
      local crate = generateACrate(crateType)

      table.Merge(playerData.inventory, {
        [uuid()] = crate
      })

      savePlayerData(steam64, playerData)

      -- Let player know of their winnings, and play a little tune.
      net.Start("WskyTTTLootboxes_ClientsideWinItem")
      net.WriteString("wsky_lootboxes/item_2.ogg")
        net.WriteTable(crate)
        net.WriteBool(false)
      net.Send(v)
    end
  end
end, autoComplete)

concommand.Add("wskylootboxes_scrap", function (ply, cmd, args, argStr)
  local action = args[1]
  local playerName = args[2]
  local scrapAmount = args[3]

  if !action or !playerName then
    print("Action or Player missing.")
    return
  end
  if ((action ~= 'reset') and (action ~= 'clear')) and not scrapAmount then
    print("Scrap amount missing.")
    return
  end

  local players = findPlayers(playerName)
  local playerCount = table.Count(players)

  if playerCount > 1 then
    print("More than 1 player found! Refusing command.")
  elseif playerCount < 1 then
    print("No user found.")
  end

  for k, player in ipairs(players) do
    local steam64 = player:SteamID64()
    local playerData = getPlayerData(steam64)

    if action == "add" then
      playerData.scrap = playerData.scrap + tonumber(scrapAmount)
    elseif action == "set" then
      playerData.scrap = tonumber(scrapAmount)
    elseif action == "clear" then
      playerData.scrap = 0
    elseif action == "reset" then
      playerData.scrap = 100
    end

    print(action.." "..player:Nick().."'s scrap to "..formatScrap(playerData.scrap))

    savePlayerData(steam64, playerData)
  end
end, autoComplete)
