
qq = "iskander_strategy_operational_research"
qw = "iskander_strategy_bravado"
qe = "iskander_strategy_ambush"
qr = "iskander_strategy_forward"
qf = "iskander_strategy_close_spellbook"

q = "iskander_strategy_open_spellbook"
w = "iskander_cypriot"
e = "iskander_gordius_wheel"
r = "iskander_army_of_the_king"
f = "iskander_charisma"


function OnPRStart(keys)
    local caster = keys.caster
    local ability = keys.ability
    ability:ApplyDataDrivenModifier(caster, caster, "iskander_strategy_operational_research_tier1", {})
    StrategyClose(caster)
    if caster.IsStrategyImproved then
        caster:FindAbilityByName(q):StartCooldown(1)
    else
        caster:FindAbilityByName(q):StartCooldown(30)
    end   
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

function StrategyClose(caster)
    caster:SwapAbilities(q, qq, true, false) 
	caster:SwapAbilities(w, qw, true, false) 
    caster:SwapAbilities(e, qe, true, false)
	if caster:HasModifier("modifier_gordius_wheel") then
		caster:SwapAbilities("iskander_via_expugnatio", qr, true, false) 
    else
        caster:SwapAbilities(r, qr, true, false) 
    end
	caster:SwapAbilities(f, qf, true, false) 
end

