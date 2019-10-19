function OnCypriotStart(keys)
    local caster = keys.caster
    local point = keys.target_points[1]
    local pos = caster:GetAbsOrigin()
    local route = (point - pos):Length2D()
    local facing = (point - pos):Normalized()
    local num = math.modf(route / 200)
    local ability = keys.ability
    local start = 0
    local damage = keys.damage
    local p_damage =damage * 0.35
    if caster.IsThundergodAcquired then
        damage = damage + caster:GetIntellect()*2
        p_damage =p_damage + caster:GetIntellect()*2
    end
    Timers:CreateTimer(
        function()
            if start >= num then
                local endtargets =
                FindUnitsInRadius(
                caster:GetTeam(),
                point,
                nil,
                keys.radius,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_ALL,
                0,
                FIND_ANY_ORDER,
                false
                )
                local lightningfx2 = ParticleManager:CreateParticle( "particles/custom/iskandar/iskandar_wl2.vpcf", PATTACH_CUSTOMORIGIN, nil)
                ParticleManager:SetParticleControl(lightningfx2,2,point+Vector(50,-50,0))
                ParticleManager:SetParticleControl(lightningfx2,1,point+Vector(50,-50,0))
                ParticleManager:SetParticleControl(lightningfx2,0,point+Vector(50,-50,0))
                local lightningfx3 = ParticleManager:CreateParticle( "particles/custom/iskandar/iskandar_wl2.vpcf", PATTACH_CUSTOMORIGIN, nil)
                ParticleManager:SetParticleControl(lightningfx3,2,point + Vector(50,50,0))
                ParticleManager:SetParticleControl(lightningfx3,1,point + Vector(50,50,0))
                ParticleManager:SetParticleControl(lightningfx3,0,point + Vector(50,50,0))
                local lightningfx4 = ParticleManager:CreateParticle( "particles/custom/iskandar/iskandar_wl2.vpcf", PATTACH_CUSTOMORIGIN, nil)
                ParticleManager:SetParticleControl(lightningfx4,2,point + Vector(-50,-50,0))
                ParticleManager:SetParticleControl(lightningfx4,1,point + Vector(-50,-50,0))
                ParticleManager:SetParticleControl(lightningfx4,0,point + Vector(-50,-50,0))
                local lightningfx5 = ParticleManager:CreateParticle( "particles/custom/iskandar/iskandar_wl2.vpcf", PATTACH_CUSTOMORIGIN, nil)
                ParticleManager:SetParticleControl(lightningfx5,2,point + Vector(-50,50,0))
                ParticleManager:SetParticleControl(lightningfx5,1,point + Vector(-50,50,0))
                ParticleManager:SetParticleControl(lightningfx5,0,point + Vector(-50,50,0))
                --ParticleManager:SetParticleControl(lightningfx2,60,Vector(255,255,0))
                Timers:CreateTimer(2.0,
                function()
                    FxDestroyer(lightningfx2, false)
                    FxDestroyer(lightningfx3, false)
                    FxDestroyer(lightningfx4, false)
                    FxDestroyer(lightningfx5, false)
                end
                )

                for k,v in pairs(endtargets) do
                    DoDamage(caster, v, damage , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
                    ability:ApplyDataDrivenModifier(caster,v, "modifier_cypriot_slow", {})
                end

                return
            end
            local targetpoint = pos  + (facing * 200 * start)
            --print(targetpoint)
            local targets =
                FindUnitsInRadius(
                caster:GetTeam(),
                targetpoint,
                nil,
                keys.radius_2,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_ALL,
                0,
                FIND_ANY_ORDER,
                false
            )
            local lightningfx = ParticleManager:CreateParticle( "particles/custom/iskandar/iskandar_wl.vpcf", PATTACH_CUSTOMORIGIN, caster )
            ParticleManager:SetParticleControl(lightningfx, 0, targetpoint)
            StartSoundEventFromPosition("Hero_Zuus.LightningBolt",targetpoint)
            --ParticleManager:SetParticleControl(lightningfx, 20,Vector(0,255,255))
            Timers:CreateTimer(2.0,
                function()
                    FxDestroyer(lightningfx, false)
                end
            )
            for k,v in pairs(targets) do
                DoDamage(caster, v, p_damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
                ability:ApplyDataDrivenModifier(caster,v, "modifier_cypriot_slow", {})
            end
            start = start + 1 
            return 0.15
        end
    )
end
