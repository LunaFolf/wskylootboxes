if CLIENT then return end

concommand.Add( "wsky_test_particle", function( ply, cmd, args )
  local particle = args[1] or "unusual_eldritch_flames_orange"
  spawnParticleOnPlayer("playerModel", particle, ply)
end )

function spawnParticleOnPlayer(position, particle, entity)
  if (position == "playerModel") then
    local attachment = entity:LookupAttachment("anim_attachment_head")
    if (attachment < 1) then attachment = entity:LookupAttachment("eyes") end

    ParticleEffectAttach(particle, PATTACH_POINT_FOLLOW, entity, attachment)
  elseif (position == "weapon_world") then

    ParticleEffectAttach(particle, PATTACH_ABSORIGIN_FOLLOW, entity, 1)
  end
end

function clearParticlesOnPlayer(entity)
  if (!entity:IsValid()) then return end
  entity:StopParticles()
end