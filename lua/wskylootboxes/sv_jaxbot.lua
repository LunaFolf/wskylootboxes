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
        messagePlayer(ply, "Take this token and run the -steamlink command in TopHat Discord.")
        messagePlayer(ply, "i.e. -steamlink "..body.data.token)
      end
    end)

  return ""
  end
end)
