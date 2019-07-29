function OnPainStart(keys)
    local target = keys.target
    local caster = keys.caster
    local ability = keys.ability
    local stack = caster:GetModifierStackCount("modifier_madness_stack", caster)
    caster:RemoveModifierByName("modifier_madness_stack")
	caster:FindAbilityByName("gille_spellbook_of_prelati"):ApplyDataDrivenModifier(caster, caster, "modifier_madness_stack", {})
	caster:SetModifierStackCount("modifier_madness_stack", caster, stack - 30) 
    if caster.IsBlackMagicImproved == true then
        local ffx = ParticleManager:CreateParticle("particles/econ/items/rubick/rubick_arcana/rbck_arc_venomancer_poison_nova_b.vpcf", PATTACH_ABSORIGIN,target)
        ParticleManager:SetParticleControl(ffx, 1, Vector(100,1,250))
        Timers:CreateTimer(0.8,function()
            ParticleManager:DestroyParticle( ffx, false )
            ParticleManager:ReleaseParticleIndex( ffx )
        end)
        local targets = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, keys.contagion, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
        for k,v in pairs(targets) do
            ability:ApplyDataDrivenModifier(caster,v, "modifier_gille_spellbook_of_prelati_pain", {}) 
        end
        if target:GetTeamNumber() == caster:GetTeamNumber() then
            ability:ApplyDataDrivenModifier(caster, target, "modifier_gille_spellbook_of_prelati_pain", {}) 
        end
    else
        ability:ApplyDataDrivenModifier(caster, target, "modifier_gille_spellbook_of_prelati_pain", {}) 
    end
end


function OnPainThink (keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    DoDamage(caster, target, keys.damage , DAMAGE_TYPE_MAGICAL, 0, ability, false)
end

function OnPainDeath (keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.unit
    local fx = ParticleManager:CreateParticle("particles/econ/items/rubick/rubick_arcana/rbck_arc_venomancer_poison_nova_b.vpcf", PATTACH_ABSORIGIN,target)
    ParticleManager:SetParticleControl(fx, 1, Vector(100,1,350))
    local targets = FindUnitsInRadius(caster:GetTeam(),target:GetAbsOrigin(), nil, keys.ratio, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
    for k,v in pairs(targets) do
        DoDamage(caster, v, keys.corpsedamage + caster:GetIntellect() * keys.intratio , DAMAGE_TYPE_MAGICAL, 0, ability, false)
        if v ~= target then
            ability:ApplyDataDrivenModifier(caster,v, "modifier_gille_spellbook_of_prelati_pain", {}) 
        end
    end
    Timers:CreateTimer(0.8,function()
        ParticleManager:DestroyParticle( fx, false )
		ParticleManager:ReleaseParticleIndex( fx )
    end)
end