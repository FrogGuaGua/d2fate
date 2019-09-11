function OnPRStart(keys)
    local caster = keys.caster
    local ability = keys.ability
    ability:ApplyDataDrivenModifier(caster, caster, "iskander_strategy_operational_research_tier1", {})
end


function OnPRDamageTaken(keys)
    local caster = keys.caster
    local ability = keys.ability
    local threshold = keys.threshold
    if keys.DamageTaken >= threshold then
        caster:RemoveModifierByName("iskander_strategy_operational_research_tier1")
        caster.operational_research_shield = keys.shield
        --print(caster.operational_research_shield )
        ability:ApplyDataDrivenModifier(caster, caster, "iskander_strategy_operational_research_tier2", {})
    end
end

function OnPRInit(keys)
    --keys.caster.operational_research_shield = keys.shield
    local caster =keys.caster
    local fx = ParticleManager:CreateParticle("particles/custom/iskandar/iskandar_qq.vpcf",PATTACH_ABSORIGIN_FOLLOW, caster)
    --ParticleManager:SetParticleControl(fx, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(fx, 1, caster:GetAbsOrigin())
    Timers:CreateTimer(2.0,
    function()
        FxDestroyer(fx, false)
    end
    )
end

function OnPRDestroy(keys)
    keys.caster.operational_research_shield = 0
end