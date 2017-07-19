atalanta_golden_apple = class({})
LinkLuaModifier("modifier_golden_apple_cooldown", "abilities/atalanta/modifier_golden_apple_cooldown", LUA_MODIFIER_MOTION_NONE)

function atalanta_golden_apple:GetCastRange()
    return self:GetSpecialValueFor("range")
end

function atalanta_golden_apple:GetAOERadius()
    local caster = self:GetCaster()
    return self:GetSpecialValueFor("aoe")
end

function atalanta_golden_apple:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self
    local position = self:GetCursorPosition()
    local origin = caster:GetOrigin()
    local forwardVector = caster:GetForwardVector()
    local duration = self:GetSpecialValueFor("lure_duration")
    local aoe = self:GetAOERadius()
    local speed = 1500
    local delay = math.max(0.1, (position - origin):Length() / speed)

    caster:ShootArrow({
        Position = position,
        AoE = 0,
        Delay = delay,
        Effect = "particles/units/heroes/hero_furion/furion_base_attack.vpcf",
        NoSound = true,
        DontUseArrow = true,
        DontCountArrow = true
    })

    local forcemove = {
        UnitIndex = nil,
        OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION ,
        Position = nil
    }

    local dummy = CreateUnitByName("visible_dummy_unit", position, false, caster, caster, caster:GetTeamNumber())
    dummy:SetOrigin(position)
    dummy:FindAbilityByName("dummy_visible_unit_passive"):SetLevel(1)
    dummy:SetDayTimeVisionRange(0)
    dummy:SetNightTimeVisionRange(0)

    dummy:EmitSound("Atalanta.GoldenApple")
	
    AddFOWViewer(caster:GetTeamNumber(), position, aoe, duration, false)

    local appleFX
    local appleFX2
    local appleFX3
    local totalTime = 0
    Timers:CreateTimer(delay, function()
        appleFX = ParticleManager:CreateParticle("particles/units/heroes/hero_enchantress/enchantress_natures_attendants_lvl4.vpcf", PATTACH_ABSORIGIN_FOLLOW, dummy)
        ParticleManager:SetParticleControlEnt(appleFX, 3, dummy, PATTACH_ABSORIGIN_FOLLOW, nil, dummy:GetOrigin(), false)
        ParticleManager:SetParticleControlEnt(appleFX, 4, dummy, PATTACH_ABSORIGIN_FOLLOW, nil, dummy:GetOrigin(), false)
        ParticleManager:SetParticleControlEnt(appleFX, 5, dummy, PATTACH_ABSORIGIN_FOLLOW, nil, dummy:GetOrigin(), false)
        ParticleManager:SetParticleControlEnt(appleFX, 6, dummy, PATTACH_ABSORIGIN_FOLLOW, nil, dummy:GetOrigin(), false)
        ParticleManager:SetParticleControlEnt(appleFX, 7, dummy, PATTACH_ABSORIGIN_FOLLOW, nil, dummy:GetOrigin(), false)
        ParticleManager:SetParticleControlEnt(appleFX, 8, dummy, PATTACH_ABSORIGIN_FOLLOW, nil, dummy:GetOrigin(), false)
        ParticleManager:SetParticleControlEnt(appleFX, 9, dummy, PATTACH_ABSORIGIN_FOLLOW, nil, dummy:GetOrigin(), false)
        ParticleManager:SetParticleControlEnt(appleFX, 10, dummy, PATTACH_ABSORIGIN_FOLLOW, nil, dummy:GetOrigin(), false)
        ParticleManager:SetParticleControlEnt(appleFX, 11, dummy, PATTACH_ABSORIGIN_FOLLOW, nil, dummy:GetOrigin(), false)

        appleFX2 = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_v2_teleport_model_glow.vpcf", PATTACH_ABSORIGIN_FOLLOW, dummy)
        ParticleManager:SetParticleControlEnt(appleFX2, 3, dummy, PATTACH_ABSORIGIN_FOLLOW, nil, dummy:GetOrigin(), false)

        appleFX3 = ParticleManager:CreateParticle("particles/econ/generic/generic_progress_meter/generic_progress_circle.vpcf", PATTACH_ABSORIGIN_FOLLOW, dummy)
        ParticleManager:SetParticleControl(appleFX3, 1, Vector(aoe, 0, 0))

       Timers:CreateTimer(function()
	   totalTime = totalTime + 0.1

           local targets = FindUnitsInRadius(caster:GetTeam(), position, nil, aoe,
               DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
               FIND_ANY_ORDER, false) 
           for k,v in pairs(targets) do
               forcemove.UnitIndex = v:entindex()
               forcemove.Position = position
               v:Stop()
               ExecuteOrderFromTable(forcemove) 
           end

           if totalTime >= duration then
               return
           end
           return 0.1
        end)
    end)

    Timers:CreateTimer(delay + duration, function()
        ParticleManager:ReleaseParticleIndex(appleFX2)
        ParticleManager:DestroyParticle(appleFX3, true)
        ParticleManager:ReleaseParticleIndex(appleFX3)
    end)

    Timers:CreateTimer(delay + duration + 2, function()
        ParticleManager:ReleaseParticleIndex(appleFX)

	dummy:StopSound("Atalanta.GoldenApple")
        dummy:RemoveSelf()
    end)

    caster:AddNewModifier(caster, self, "modifier_golden_apple_cooldown", {
        duration = self:GetCooldown(1)
    })
end

function atalanta_golden_apple:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end

function atalanta_golden_apple:GetAbilityTextureName()
    return "custom/atalanta_golden_apple"
end