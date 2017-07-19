atalanta_calydonian_hunt = class({})
LinkLuaModifier("modifier_calydonian_hunt", "abilities/atalanta/modifier_calydonian_hunt", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_calydonian_hunt_root", "abilities/atalanta/modifier_calydonian_hunt_root", LUA_MODIFIER_MOTION_NONE)

function atalanta_calydonian_hunt:OnUpgrade()
    local caster = self:GetCaster()
    local ability = self

    if IsServer() and not caster.AddHuntStack then
        function caster:AddHuntStack(...)
        ability:AddStack(...)
        end
    end
end

function atalanta_calydonian_hunt:AddStack(target, count)
    local caster = self:GetCaster()

    local modifier = target:FindModifierByName("modifier_calydonian_hunt")
    local currentStack = modifier and modifier:GetStackCount() or 0
    local maxStacks = self:GetSpecialValueFor("max_stacks")

    if caster.GoldenAppleAcquired then
        maxStacks = maxStacks + self:GetSpecialValueFor("attribute_stack_bonus")
    end

    target:RemoveModifierByName("modifier_calydonian_hunt")
    target:AddNewModifier(caster, self, "modifier_calydonian_hunt", {
        duration = self:GetDebuffDuration()
    })
    target:SetModifierStackCount("modifier_calydonian_hunt", self, math.min(maxStacks, currentStack + count))
end

function atalanta_calydonian_hunt:GetDebuffDuration()
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("debuff_duration")

    if caster.HuntersMarkAcquired then
        duration = duration + self:GetSpecialValueFor("attribute_bonus_duration")
    end

    return duration
end

function atalanta_calydonian_hunt:OnSpellStart()
    local caster = self:GetCaster()
    local detonateDamagePerStack = self:GetSpecialValueFor("detonate_stack")

    caster:EmitSound("Hero_NagaSiren.Ensnare.Cast")

    local casterFX = ParticleManager:CreateParticle("particles/econ/items/enchantress/enchantress_lodestar/ench_lodestar_death.vpcf", PATTACH_POINT_FOLLOW, caster)
    ParticleManager:SetParticleControl(casterFX, 0, caster:GetOrigin())

    Timers:CreateTimer(1, function()
        ParticleManager:ReleaseParticleIndex(casterFX)
    end)

    local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, 99999, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
    local duration = self:GetSpecialValueFor("root_duration")
    for _,v in pairs(targets) do
        if v:HasModifier("modifier_calydonian_hunt") and (caster:CanEntityBeSeenByMyTeam(v) or caster.GoldenAppleAcquired) then
            v:AddNewModifier(caster, self, "modifier_calydonian_hunt_root", {
                duration = duration
            })
            local stacks = v:GetModifierStackCount("modifier_calydonian_hunt", caster)
            if caster.HuntersMarkAcquired then
                local detonateDamage = detonateDamagePerStack * stacks
                DoDamage(caster, v, detonateDamage, DAMAGE_TYPE_MAGICAL, 0, self, false)
                v:RemoveModifierByName("modifier_calydonian_hunt")
            end
	    giveUnitDataDrivenModifier(caster, v, "rooted", duration)
        end
    end

    --[[if caster.GoldenAppleAcquired and caster:FindAbilityByName("atalanta_golden_apple"):IsCooldownReady() then
        caster:SwapAbilities("atalanta_calydonian_hunt", "atalanta_golden_apple", false, true)
        Timers:CreateTimer(self:GetSpecialValueFor("attribute_swap_duration"), function()
            caster:SwapAbilities("atalanta_golden_apple", "atalanta_calydonian_hunt", false, true)
        end)
    end]]

    if caster:GetStrength() >= 19.1
        and caster:GetAgility() >= 19.1
        and caster:GetIntellect() >= 19.1
        and caster:HasModifier("modifier_r_used")
        and caster:FindAbilityByName("atalanta_phoebus_catastrophe_snipe"):IsCooldownReady()
    then
        local modifier = caster:FindModifierByName("modifier_r_used")
	local timeLeft = modifier:GetRemainingTime()

	if timeLeft > 0 then
            if not caster.ComboTimer then
                --caster:SwapAbilities("atalanta_last_spurt", "atalanta_phoebus_catastrophe_barrage", false, true)
                caster:SwapAbilities("atalanta_priestess_of_the_hunt", "atalanta_phoebus_catastrophe_snipe", false, true)
                caster.ComboTimer = Timers:CreateTimer(timeLeft, function()
                    caster.ComboTimer = nil
                    --caster:SwapAbilities("atalanta_phoebus_catastrophe_barrage", "atalanta_last_spurt", false, true)
                    caster:SwapAbilities("atalanta_phoebus_catastrophe_snipe", "atalanta_priestess_of_the_hunt", false, true)
                end)
            else
                Timers:RemoveTimer(caster.ComboTimer)
                caster.ComboTimer = Timers:CreateTimer(timeLeft, function()
                    caster.ComboTimer = nil
                    --caster:SwapAbilities("atalanta_phoebus_catastrophe_barrage", "atalanta_last_spurt", false, true)
                    caster:SwapAbilities("atalanta_phoebus_catastrophe_snipe", "atalanta_priestess_of_the_hunt", false, true)
                end)
            end
        end
    end
end

function atalanta_calydonian_hunt:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end

function atalanta_calydonian_hunt:GetAbilityTextureName()
    return "custom/atalanta_calydonian_hunt"
end