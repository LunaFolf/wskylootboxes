if CLIENT then return end

hook.Add("PlayerSay", "WskyTTTLootboxes_SteamLinkCommand", function (ply, message)
  print(message)
  if ( !ply or !IsValid(ply) or !IsPlayer(ply) ) then return end

  message = string.lower(message)
  if message == "/steamlink" then
    print("sending http post3")
    postToJaxbot("steamLinkCode",

    -- BodyData crap
    {
      ["steamID"] = tostring(ply:SteamID64())
    },

    -- OnSuccess Function
    function (body, length, headers, code)
      body = util.JSONToTable(body)
      if body.status == "success" and body.data.token then
        messagePlayer(ply, "Your discord token is: "..body.data.token)
        messagePlayer(ply, "Take this token and run the .steamlink command in TopHat Discord.")
        messagePlayer(ply, "i.e. .steamlink "..body.data.token)
      end
    end)

  return ""
  end
end)

-- Jaxbot player death
hook.Add("PlayerDeath", "WskyTTTLootboxes_JaxBot_PlayerDeath", function (victim, inflictor, attacker)
  local data = {
    ["guildId"] = "704721117574725755",
    ["gamemode"] = engine.ActiveGamemode(),
    ["event_type"] = "death",
    ["attacker_nickname"] = attacker.Nick and attacker:Nick() or attacker:GetClass(),
    ["attacker_steamid"] = attacker.SteamID64 and attacker:SteamID64() or nil,
    ["victim_nickname"] = victim:Nick(),
    ["victim_steamid"] = victim.SteamID64 and victim:SteamID64() or nil,
    ["cause_of_death"] = suicide and "Suicide" or weaponName,
    ["round_state"] = tostring(GAMEMODE.round_state)
  }

  postToJaxbot("gameEvent", data)
end)

-- Jaxbot player connect
hook.Add("PlayerInitialSpawn", "WskyTTTLootboxes_JaxBot_PlayerInitialSpawn", function (ply)
  local data = {
    ["guildId"] = "704721117574725755",
    ["gamemode"] = engine.ActiveGamemode(),
    ["event_type"] = "connect",
    ["steamid"] = ply:SteamID64(),
    ["observation_mode"] = tostring(ply:GetObserverMode()),
    ["round_state"] = tostring(GAMEMODE.round_state)
  }

  postToJaxbot("gameEvent", data)
end)

concommand.Add("wsky_testconnect", function (ply)
  local data = {
    ["guildId"] = "704721117574725755",
    ["gamemode"] = engine.ActiveGamemode(),
    ["event_type"] = "connect",
    ["steamid"] = ply:SteamID64(),
    ["observation_mode"] = tostring(ply:GetObserverMode()),
    ["round_state"] = tostring(GAMEMODE.round_state)
  }

  postToJaxbot("gameEvent", data)
end)

-- Jaxbot player disconnect
hook.Add("PlayerDisconnected", "WskyTTTLootboxes_JaxBot_PlayerDisconnected", function (ply)
  local data = {
    ["guildId"] = "704721117574725755",
    ["gamemode"] = engine.ActiveGamemode(),
    ["event_type"] = "disconnect",
    ["steamid"] = ply.SteamID64 and ply:SteamID64() or "",
    ["observation_mode"] = tostring(ply:GetObserverMode()),
    ["round_state"] = tostring(GAMEMODE.round_state)
  }

  postToJaxbot("gameEvent", data)
end)

-- Jaxbot player spawn
hook.Add("PlayerSpawn", "WskyTTTLootboxes_JaxBot_PlayerSpawn", function (ply)
  timer.Simple(0.2, function ()
    local data = {
      ["guildId"] = "704721117574725755",
      ["gamemode"] = engine.ActiveGamemode(),
      ["event_type"] = "respawn",
      ["steamid"] = ply:SteamID64(),
      ["observation_mode"] = tostring(ply:GetObserverMode()),
      ["round_state"] = tostring(GAMEMODE.round_state)
    }

    postToJaxbot("gameEvent", data)
  end)
end)

-- Jaxbot end round
hook.Add("TTTEndRound", "WskyTTTLootboxes_JaxBot_EndRound", function ()
  local data = {
    ["guildId"] = "704721117574725755",
    ["gamemode"] = engine.ActiveGamemode(),
    ["event_type"] = "round_end"
  }

  timer.Simple(0.2, function ()
    postToJaxbot("gameEvent", data)
  end)
end)
