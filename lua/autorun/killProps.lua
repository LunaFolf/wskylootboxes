if CLIENT then return end

CreateConVar("wsky_delete_props", 1)

function deleteProps(override)
  local willDeleteProps = GetConVar("wsky_delete_props"):GetBool()
  if (!willDeleteProps or !override) then return end

  local props = ents.FindByClass('prop_physics')
  local propsMult = ents.FindByClass('prop_physics_multiplayer')
  local physbox = ents.FindByClass('func_physbox')
  local propsMultRes = ents.FindByClass('prop_physics_respawnable')
  local discombobs = ents.FindByClass('weapon_ttt_confgrenade')
  table.Add(props, propsMult)
  table.Add(props, physbox)
  table.Add(props, propsMultRes)
  table.Add(props, discombobs)

  for i, prop in ipairs(props) do
    print(i, prop)
    prop:Remove()
  end
end

concommand.Add("wsky_remove_prop", function ()
 deleteProps(true)
end)

hook.Add("GMPostCleanupMap", "WskyTTT_RemovePhysicsProps", function ()
 deleteProps(false)
end)

hook.Add("TTTPrepareRound", "WskyTTT_RemovePhysicsProps", function ()
 deleteProps(false)
end)
hook.Add("TTTBeginRound", "WskyTTT_RemovePhysicsProps", function ()
 deleteProps(false)
end)
hook.Add("TTTEndRound", "WskyTTT_RemovePhysicsProps", function ()
 deleteProps(false)
end)
