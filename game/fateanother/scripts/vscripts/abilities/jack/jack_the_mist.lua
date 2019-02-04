function OnTheMistStart(keys)
    local caster = keys.caster
    local ability = keys.ability
    
    local masterCombo = caster.MasterUnit2:FindAbilityByName(keys.ability:GetAbilityName())
    CreateUITimer("The Mist",25,"the_mist_timer")
    masterCombo:EndCooldown()
    masterCombo:StartCooldown(keys.ability:GetCooldown(1))
    ability:ApplyDataDrivenModifier(caster, caster, "jack_the_mist_cd", {duration = ability:GetCooldown(ability:GetLevel())})
    local casterloc = caster:GetAbsOrigin()
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 20000 , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
    for k,v in pairs(targets) do 
        ability:ApplyDataDrivenModifier(caster, v, "jack_the_mist_effect", {duration = 25})
    end
    ability:ApplyDataDrivenModifier(caster,caster, "jack_the_mist_selfeffect", {duration = 30})
    local fogfx = ParticleManager:CreateParticle("particles/rain_fx/rain_mist_screen.vpcf", PATTACH_EYES_FOLLOW, caster)
end


function OnMistTick(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    local player = target:GetPlayerOwner()
    DoDamage(caster, target , 10 , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
    local fogfx1 = ParticleManager:CreateParticleForPlayer("particles/custom/jack/the_mist.vpcf", PATTACH_EYES_FOLLOW, target,player)
    Timers:CreateTimer(10,function()
        ParticleManager:DestroyParticle( fogfx1, false )
        ParticleManager:ReleaseParticleIndex( fogfx1 )   
    end)
end

function OnMistSelf(keys)
    local caster = keys.caster
    local ability = keys.ability
    local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 1200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
    for k,v in pairs(targets) do
        if v:GetName() == "npc_dota_ward_base" then
            DoDamage(keys.caster, v, 6, DAMAGE_TYPE_PURE, 0, keys.ability, false)
        end
    end
end
