function OnFlurryStart(kv)
    local caster = kv.caster
    local targetpoint = kv.target_points[1]
    local ability = kv.ability
    local casterloc=caster:GetAbsOrigin()
    local firsthitdamage=kv.firstdamage
    local firstradius=kv.firstradius
    local lasthitdamage=kv.lastdamage
    local lastradius=kv.lastradius
    local stunduration=kv.stunduration
    local flayer = caster:FindAbilityByName("lvbu_flayer")  --flayer
    local bones_damage = caster:FindModifierByName("modifier_trouble_times_hero"):GetDeadNumber() * (-0.02) -- trouble time hero
    print(bones_damage)
    giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 2.8)
    firsthitdamage = firsthitdamage * (1+bones_damage)
    lasthitdamage = lasthitdamage * (1+bones_damage)

    Timers:CreateTimer(0.6,function()
        local targets=FindUnitsInRadius(caster:GetTeam(), casterloc, nil, firstradius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
        for _,v in pairs(targets) do
            if IsFacingUnit(caster, v, 210) then
                DoDamage(caster, v, firsthitdamage , DAMAGE_TYPE_MAGICAL, 0, ability, false)
                v:AddNewModifier(caster, v, "modifier_stunned", {Duration = stunduration})
                flayer:AddStack(v)
            end
        end
    end)
    Timers:CreateTimer(1.0,function()
        local targets=FindUnitsInRadius(caster:GetTeam(), casterloc, nil, firstradius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
        for _,v in pairs(targets) do
            if IsFacingUnit(caster, v, 180) then
                DoDamage(caster, v, firsthitdamage , DAMAGE_TYPE_MAGICAL, 0, ability, false)
                v:AddNewModifier(caster, v, "modifier_stunned", {Duration = stunduration})
                flayer:AddStack(v)
            end
        end
    end)
    Timers:CreateTimer(1.7,function()
        local targets=FindUnitsInRadius(caster:GetTeam(), casterloc, nil, firstradius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
        for _,v in pairs(targets) do
            if IsFacingUnit(caster, v, 60) then
                DoDamage(caster, v, firsthitdamage , DAMAGE_TYPE_MAGICAL, 0, ability, false)
                v:AddNewModifier(caster, v, "modifier_stunned", {Duration = stunduration})
                flayer:AddStack(v)
            end
        end
    end)
    Timers:CreateTimer(2.0,function()
        local targets=FindUnitsInRadius(caster:GetTeam(), casterloc, nil, firstradius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
            for _,v in pairs(targets) do
                if IsFacingUnit(v, caster, 120)  then
                    DoDamage(caster, v, firsthitdamage , DAMAGE_TYPE_MAGICAL, 0, ability, false)
                    v:AddNewModifier(caster, v, "modifier_stunned", {Duration = stunduration})
                    flayer:AddStack(v)
                end
            end
    end)
    Timers:CreateTimer(2.6,function()
        local casterforword=caster:GetForwardVector():Normalized()
        local t_point = casterforword * 200 + casterloc
        local t_targets = FindUnitsInRadius(caster:GetTeam(), t_point, nil, lastradius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
        for _,v in pairs(t_targets) do
            DoDamage(caster, v, lasthitdamage , DAMAGE_TYPE_MAGICAL, 0, ability, false)
            v:AddNewModifier(caster, v, "modifier_stunned", {Duration = stunduration})
            flayer:AddStack(v)
        end
    end)
end