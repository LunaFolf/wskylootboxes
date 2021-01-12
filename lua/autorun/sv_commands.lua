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
  argStr = string.lower(argStr)
  
  local argTable = string.Split(argStr, " ") -- Get arguments in table format for easier access
  local curArgIndex, curArgValue = table.Count(argTable), argTable[table.Count(argTable)] -- Get current argument for autofill, It should just be the last one.

  local fullString = cmd .. " " .. table.concat(argTable, " ", 1, curArgIndex - 1) .. ((curArgIndex > 1) and " " or "")

  local returnTable = {}

  if (string.StartWith(cmd, "wsky_crate_generate")) then
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

  return returnTable
end

concommand.Add("wsky_crate_generate", function (ply, cmd, args, argStr)
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
      net.Start("WskyTTTLootboxes_ClientsideWinChime")
      net.WriteString("garrysmod/save_load2.wav")
        net.WriteTable(crate)
      net.Send(v)
    end
  end
end, autoComplete)