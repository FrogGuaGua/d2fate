atalanta_phoebus_catastrophe_snipe = class({})
LinkLuaModifier("modifier_phoebus_catastrophe_cooldown", "abilities/atalanta/modifier_phoebus_catastrophe_cooldown", LUA_MODIFIER_MOTION_NONE)

require("abilities/atalanta/phoebus_catastrophe")

atalanta_phoebus_catastrophe_wrapper(atalanta_phoebus_catastrophe_snipe)

function atalanta_phoebus_catastrophe_snipe:GetCastRange(location, target)
    return self:GetSpecialValueFor("range")
end

function atalanta_phoebus_catastrophe_snipe:CastFilterResultTarget(target)
    local caster = self:GetCaster()

    if IsServer() and not IsInSameRealm(target:GetOrigin(), caster:GetOrigin()) then
        return UF_FAIL_CUSTOM
    end

    if caster:GetArrowCount() < 2 then
        return UF_FAIL_CUSTOM
    end

    local result = UnitFilter(target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, self:GetCaster():GetTeamNumber())
    if result ~= UF_SUCCESS then
        return result
    end

    return UF_SUCCESS
end

function atalanta_phoebus_catastrophe_snipe:GetCustomCastErrorTarget(target)
    local caster = self:GetCaster()

    if IsServer() and not IsInSameRealm(target:GetOrigin(), caster:GetOrigin()) then
        return "#Cannot_Be_Cast_Now"
    end

    return "Not enough arrows..."
end

function atalanta_phoebus_catastrophe_snipe:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self
    local target = self:GetCursorTarget()
    local position = target:GetOrigin()
    local origin = caster:GetOrigin()
    local arrows = self:GetSpecialValueFor("arrows")

    local dummy = CreateUnitByName("sight_dummy_unit", caster:GetOrigin(), false, caster, caster, caster:GetTeamNumber())
    dummy:SetDayTimeVisionRange(400)
    dummy:SetNightTimeVisionRange(400)
    dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)

    local time = 0
    local targetTime = 2 + 0.2 + 0.1 * arrows
    Timers:CreateTimer(function()
        if time >= targetTime or dummy:IsNull() then
            return
        end

        dummy:SetOrigin(target:GetOrigin())
        targetTime = targetTime + 0.1

        return 0.1
    end)

    self:ShootAirArrows()
    caster.snipeParticle = ParticleManager:CreateParticleForTeam("particles/custom/atalanta/atalanta_crosshair.vpcf", PATTACH_OVERHEAD_FOLLOW, target, caster:GetTeamNumber())

    ParticleManager:SetParticleControl( caster.snipeParticle, 0, target:GetAbsOrigin() + Vector(0,0,100)) 
    ParticleManager:SetParticleControl( caster.snipeParticle, 1, target:GetAbsOrigin() + Vector(0,0,100)) 

    Timers:CreateTimer(2, function()
        local screenFx = ParticleManager:CreateParticle("particles/custom/screen_green_splash.vpcf", PATTACH_EYES_FOLLOW, caster)

        local midpoint = (origin + position) / 2
        local sourceLocation = midpoint + Vector(0, 0, 1000)

        local arrowAoE = self:GetSpecialValueFor("arrow_aoe")

        if caster:HasModifier("modifier_tauropolos") then
            local tauropolos = caster:FindAbilityByName("atalanta_tauropolos")
            arrowAoE = arrowAoE + tauropolos:GetSpecialValueFor("bonus_aoe_per_agi") * caster:GetAgility()
        end

        for i=1,arrows do
            Timers:CreateTimer(0.1 + 0.1 * i, function()
                local sameRealm = IsInSameRealm(target:GetOrigin(), position)
                EmitGlobalSound("Ability.Powershot.Alt")
                caster:ShootArrow({
                    Origin = sourceLocation+RandomVector(200),
                    Target = sameRealm and target or nil,
                    Position = (not sameRealm) and position or nil,
                    AoE = arrowAoE,
                    Delay = 0.2,
                    Effect = effect,
                    DontUseArrow = true,
                    NoShock = true,
                    DontCountArrow = true,
                })
            end)
        end

        Timers:CreateTimer(0.2 + 0.1 * arrows, function()
            ParticleManager:DestroyParticle(screenFx, false)
            ParticleManager:DestroyParticle(caster.snipeParticle, true)

        dummy:RemoveSelf()
        end)
    end)

    self:AfterSpell()
end

function atalanta_phoebus_catastrophe_snipe:GetAbilityTextureName()
    return "custom/atalanta_phoebus_catastrophe"
end