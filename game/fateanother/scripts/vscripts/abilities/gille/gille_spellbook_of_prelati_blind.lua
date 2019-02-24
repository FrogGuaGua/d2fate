function OnBlindStart(keys)
    local caster =keys.caster
    local target =keys.target
    local ffx = ParticleManager:CreateParticleForPlayer("particles/custom/gille/gille_blind.vpcf", PATTACH_MAIN_VIEW,target,target:GetPlayerOwner())
    keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_gille_blind", {})
    Timers:CreateTimer(5.0,function()
        ParticleManager:DestroyParticle( ffx, false )
        ParticleManager:ReleaseParticleIndex( ffx )
    end)
end