LinkLuaModifier("modifier_casting_phoebus", "abilities/atalanta/modifier_casting_phoebus", LUA_MODIFIER_MOTION_NONE)

function atalanta_phoebus_catastrophe_wrapper(ability)
    function ability:OnAbilityPhaseStart()
        local caster = self:GetCaster()
        local ability = self
        --EmitGlobalSound("Atalanta.PhoebusCast")
        
        caster:AddNewModifier(caster, ability, "modifier_casting_phoebus", {Duration = ability:GetCastPoint()+0.033})

        local enemies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 3500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
        if #enemies == 0 then 
            caster:EmitSound("Atalanta.PhoebusCast")  
        else
            EmitGlobalSound("Atalanta.PhoebusCast")
        end
    
        local casterFX = ParticleManager:CreateParticle("particles/econ/items/monkey_king/arcana/death/mk_spring_arcana_death_ground_impact.vpcf", PATTACH_POINT_FOLLOW, caster)
        ParticleManager:SetParticleControl(casterFX, 0, caster:GetOrigin())
    
        local casterFX2 = ParticleManager:CreateParticle("particles/econ/items/rubick/rubick_force_gold_ambient/rubick_telekinesis_land_force_impact_rings_gold.vpcf", PATTACH_POINT_FOLLOW, caster)
        ParticleManager:SetParticleControl(casterFX2, 0, caster:GetOrigin())
    
        local casterFX3 = ParticleManager:CreateParticle("particles/econ/items/rubick/rubick_force_gold_ambient/rubick_telekinesis_land_force_impact_d_gold.vpcf", PATTACH_POINT_FOLLOW, caster)
        ParticleManager:SetParticleControl(casterFX3, 0, caster:GetOrigin())
    
        Timers:CreateTimer(1, function()
            ParticleManager:ReleaseParticleIndex(casterFX)
            ParticleManager:ReleaseParticleIndex(casterFX2)
            ParticleManager:ReleaseParticleIndex(casterFX3)
        end)
    
        return true
    end
    function ability:OnAbilityPhaseInterrupted()
        local hCaster = self:GetCaster()
        local hAbility = self
        hCaster:RemoveModifierByName("modifier_casting_phoebus")
    end
    
    function ability:ShootAirArrows()
        local caster = self:GetCaster()
        local position = self:GetCursorPosition()
        local origin = caster:GetOrigin()
    
        EmitGlobalSound("Atalanta.PhoebusRelease")
    
        local midpoint = (origin + position) / 2
        local targetLocation = midpoint + Vector(0, 0, 1000)

        local dummy = CreateUnitByName("dummy_unit", targetLocation, false, caster, caster, caster:GetTeamNumber())
        dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
	dummy:SetOrigin(targetLocation + Vector(100, 0, 0))

        local dummy2 = CreateUnitByName("dummy_unit", targetLocation, false, caster, caster, caster:GetTeamNumber())
        dummy2:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
	dummy2:SetOrigin(targetLocation + Vector(-100, 0, 0))
    
        caster:ShootArrow({
            Target = dummy,
            AoE = 0,
            Delay = 0.6,
            Effect = effect,
            Facing = facing,
            DontCountArrow = true
        })
    
        caster:ShootArrow({
            Target = dummy2,
            AoE = 0,
            Delay = 0.6,
            Effect = effect,
            Facing = facing,
            DontCountArrow = true
        })
    end

    function ability:AfterSpell()
        local caster = self:GetCaster()
        local cooldown = self:GetCooldown(1)
        caster:RemoveModifierByName("modifier_casting_phoebus")

        local snipe = caster:FindAbilityByName("atalanta_phoebus_catastrophe_snipe")
        snipe:EndCooldown()
        snipe:StartCooldown(cooldown)

        --[[local barrage = caster:FindAbilityByName("atalanta_phoebus_catastrophe_barrage")
        barrage:EndCooldown()
        barrage:StartCooldown(cooldown)]]

        local masterCombo = caster.MasterUnit2:FindAbilityByName("atalanta_phoebus_catastrophe_proxy")
        masterCombo:EndCooldown()
        masterCombo:StartCooldown(cooldown)

        caster:AddNewModifier(caster, self, "modifier_phoebus_catastrophe_cooldown", {
            duration = cooldown
        })
    end

    function ability:GetPlaybackRateOverride()
        return 0.75
    end
    
    function ability:GetCastAnimation()
        return ACT_DOTA_CAST_ABILITY_4
    end
end


