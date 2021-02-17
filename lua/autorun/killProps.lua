if CLIENT then return end

function deleteProps()
  local props = ents.FindByClass('prop_physics')
  local propsMult = ents.FindByClass('prop_physics_multiplayer')
  local physbox = ents.FindByClass('func_physbox')
  local propsMultRes = ents.FindByClass('prop_physics_respawnable')
  table.Add(props, propsMult)
  table.Add(props, physbox)
  table.Add(props, propsMultRes)

  for i, prop in ipairs(props) do
    print(i, prop)
    prop:Remove()
  end
end

concommand.Add("wsky_remove_prop", deleteProps)

hook.Add("GMPostCleanupMap", "WskyTTT_RemovePhysicsProps", deleteProps)

hook.Add("TTTPrepareRound", "WskyTTT_RemovePhysicsProps", deleteProps)
hook.Add("TTTBeginRound", "WskyTTT_RemovePhysicsProps", deleteProps)
hook.Add("TTTEndRound", "WskyTTT_RemovePhysicsProps", deleteProps)
