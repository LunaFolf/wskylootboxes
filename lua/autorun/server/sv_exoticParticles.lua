if CLIENT then return end

concommand.Add( "wsky_test_particle", function( ply, cmd, args )
  local particle = args[1] or "unusual_eldritch_flames_orange"
  spawnParticleOnPlayer("playerModel", particle, ply)
end )

function spawnParticleOnPlayer(position, particle, player)
  local eyesAttachment = player:LookupAttachment("eyes")
  
  print(position, particle, player, eyesAttachment)

  ParticleEffectAttach(particle, PATTACH_POINT_FOLLOW, player, eyesAttachment)
  print(type(particle), particle)
end

function clearParticlesOnPlayer(player)
  player:StopParticles()
end