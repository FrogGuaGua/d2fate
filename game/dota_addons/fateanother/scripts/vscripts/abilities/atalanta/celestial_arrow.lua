atalanta_celestial_arrow = class({})
LinkLuaModifier("modifier_celestial_arrow", "abilities/atalanta/modifier_celestial_arrow", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_celestial_arrow_onhit", "abilities/atalanta/modifier_celestial_arrow_onhit", LUA_MODIFIER_MOTION_NONE)

function atalanta_celestial_arrow:OnUpgrade()
    local caster = self:GetCaster()
    local ability = self    

    if IsServer() then
        --[[local fCastTimeReduction = self:GetSpecialValueFor("casttime_reduction_per_stack")
        local fAgility = self:GetSpecialValueFor("agility_per_stack")
        CustomNetTables:SetTableValue("sync","atalanta_q", {fCastTimeReduction = fCastTimeReduction, fAgility = fAgility})]]
        if not caster.ArrowHit then
            function caster:ArrowHit(...)
                ability:ArrowHit(...)
            end
        end

        if not caster.ShootArrow then
            function caster:ShootArrow(...)
                ability:ShootArrow(...)
            end
        end

        if not caster.ShootLinearArrow then
            function caster:ShootLinearArrow(...)
                ability:ShootLinearArrow(...)
            end
        end
    end
end

function atalanta_celestial_arrow:GetCastRange(location, target)
    local caster = self:GetCaster()
    local range = self:GetSpecialValueFor("range")
    
    if caster:HasModifier("modifier_arrows_of_the_big_dipper") then
        local fAgility = CustomNetTables:GetTableValue("sync","atalanta_agility").fAgility
        local tAttributeTable = CustomNetTables:GetTableValue("sync","atalanta_big_dipper")
        range = range + tAttributeTable.fExtraRange + (fAgility * tAttributeTable.fRangePerAGI)
    end

    --[[if IsServer() and caster:HasModifier("modifier_tauropolos") then
        local tauropolos = caster:FindAbilityByName("atalanta_tauropolos")
        range = range + tauropolos:GetSpecialValueFor("bonus_range_per_agi") * caster:GetAgility()
    end]]

    return range
end

function atalanta_celestial_arrow:CastFilterResultLocation(location)
    local caster = self:GetCaster()

    if caster:HasArrow() then
        return UF_SUCCESS
    end

    return UF_FAIL_CUSTOM
end

function atalanta_celestial_arrow:GetCustomCastErrorLocation(location)
    return "Not enough arrows..."
end

function atalanta_celestial_arrow:CreateShockRing(facing)
    local caster = self:GetCaster()
    local dummy = CreateUnitByName("visible_dummy_unit", caster:GetOrigin(), false, caster, caster, caster:GetTeamNumber())
    dummy:FindAbilityByName("dummy_visible_unit_passive"):SetLevel(1)
    dummy:SetDayTimeVisionRange(0)
    dummy:SetNightTimeVisionRange(0)
    dummy:SetOrigin(caster:GetOrigin())
    dummy:SetForwardVector(facing or caster:GetForwardVector())
    
    local particle = "particles/econ/items/windrunner/windrunner_ti6/windrunner_spell_powershot_channel_ti6_shock_ring.vpcf"
    local hModifier = caster:FindModifierByName("modifier_celestial_arrow_onhit")
    local iCurrentStack = hModifier and hModifier:GetStackCount() or 0
    if iCurrentStack > 4 then 
        particle = "particles/custom/atalanta/atalanta_shock_ring.vpcf"
    end

    local casterFX = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, dummy)
    ParticleManager:SetParticleControlEnt(casterFX, 1, dummy, PATTACH_ABSORIGIN_FOLLOW, nil, caster:GetOrigin(), false)
    ParticleManager:ReleaseParticleIndex(casterFX)

    Timers:CreateTimer(3, function()
        dummy:RemoveSelf()
    end)
end

function atalanta_celestial_arrow:OnSpellStart()
    local hCaster = self:GetCaster()
    local aoe = 100
    local effect = "particles/units/heroes/hero_windrunner/windrunner_spell_powershot.vpcf"
    local hModifier = hCaster:FindModifierByName("modifier_celestial_arrow_onhit")
    local iCurrentStack = hModifier and hModifier:GetStackCount() or 0
    if iCurrentStack == 10 then 
        aoe = 125
        effect = "particles/custom/atalanta/atalanta_arrow_10stack.vpcf"
    elseif iCurrentStack > 4 then  
        effect = "particles/custom/atalanta/atalanta_arrow.vpcf"
    end

    local position = self:GetCursorPosition()
    local origin = hCaster:GetAbsOrigin()
    local facing = ForwardVForPointGround(hCaster,position)
    
    self:ShootArrow({
        Effect = effect,
        Origin = origin,
        Speed = 3000,
        Facing = facing,
        AoE = aoe,
	    Range = self:GetCastRange(),
	    Linear = true
    })
end

function atalanta_celestial_arrow:OnProjectileThink(location)
    local caster = self:GetCaster()

    if caster.ArrowsOfTheBigDipperAcquired then
        local tAttributeTable = CustomNetTables:GetTableValue("sync","atalanta_big_dipper")
        local radius = tAttributeTable.fVisionRadius
        local duration = tAttributeTable.fVisionDuration

        AddFOWViewer(caster:GetTeamNumber(), location, radius, duration, false)
    end
end

function atalanta_celestial_arrow:OnProjectileHit_ExtraData(target, location, data)
    if target == nil then
        return
    end
    local hCaster = self:GetCaster()
    if self.bFirstHit == true then  
        local fOnHitBuffDuration = self:GetSpecialValueFor("stacks_duration")
        local iMaxStacks = self:GetSpecialValueFor("max_stacks")
        local hModifier = hCaster:FindModifierByName("modifier_celestial_arrow_onhit")
        local iCurrentStack = hModifier and hModifier:GetStackCount() or 0
        if not hModifier then 
            local fCastTimeReduction = self:GetSpecialValueFor("casttime_reduction_per_stack")
            local fAgility = self:GetSpecialValueFor("agility_per_stack")
            hCaster:AddNewModifier(hCaster, self, "modifier_celestial_arrow_onhit", {Duration = fOnHitBuffDuration, fAgility = fAgility, fCastTimeReduction = fCastTimeReduction})
        else
            hModifier:SetDuration(fOnHitBuffDuration, true)
        end
        hCaster:SetModifierStackCount("modifier_celestial_arrow_onhit", self, math.min(iCurrentStack + 1,iMaxStacks))
        self.bFirstHit = false
    end    
    hCaster:ArrowHit(target, data["1"])
end

function atalanta_celestial_arrow:ArrowHit(target, slow, bIsPhoebus)
    local caster = self:GetCaster()

    caster:AddHuntStack(target, 1)

    local damage = caster:GetAverageTrueAttackDamage(caster)
    if bIsPHoebus then
        damage = damage * 0.75
    end

    if target:HasModifier("modifier_a_scroll") then
        damage = damage * 0.75
    end

    local stacks = target:GetModifierStackCount("modifier_calydonian_hunt", caster)
    local ability = caster:FindAbilityByName("atalanta_calydonian_hunt")
    local damagePercent = ability:GetSpecialValueFor("damage_per_stack")
    local huntDamage = damage * damagePercent * stacks / 100

    if caster.HuntersMarkAcquired then
        local physicalReduction = GetPhysicalDamageReduction(target:GetPhysicalArmorValue())
        huntDamage = huntDamage / (1 - physicalReduction)
    end
    
    DoDamage(caster, target, damage + huntDamage, DAMAGE_TYPE_PHYSICAL, 0, self, false)

    if slow and slow > 0 then
        target:AddNewModifier(caster, target, "modifier_barrage_slow", {Duration = slow})
    end
end

function atalanta_celestial_arrow:ShootArrow(keys)
    local caster = self:GetCaster()
    local ability = self

    keys.Effect = keys.Effect or "particles/econ/items/enchantress/enchantress_virgas/ench_impetus_virgas.vpcf"
    keys.Sound = keys.Sound or "Ability.Powershot.Alt"

    if not keys.DontUseArrow then
        caster:UseArrow(1)
    end

    if not keys.NoSound then
        caster:EmitSound(keys.Sound)
    end

    --[[if keys.GlobalSound == true then
        print("globalsnd")
        EmitGlobalSound(keys.Sound)
    end]]

    if not keys.NoShock then
        self:CreateShockRing(keys.Facing)
    end

    if keys.Linear then
        caster:ShootLinearArrow(keys)
    else
        caster:ShootAoEArrow(keys)
    end

    if caster.ArrowsOfTheBigDipperAcquired and not keys.DontCountArrow then
        caster:CheckBonusArrow(keys)
    end
end

function atalanta_celestial_arrow:ShootLinearArrow(keys)
    local projectileTable = {
        EffectName = keys.Effect,
        Ability = self,
        vSpawnOrigin = keys.Origin,
        vVelocity = keys.Facing * keys.Speed,
        fDistance = keys.Range,
        fStartRadius = keys.AoE,
        fEndRadius = keys.AoE,
        Source = self:GetCaster(),
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        bProvidesVision = false,
    }
    self.bFirstHit = true
    ProjectileManager:CreateLinearProjectile(projectileTable)
end

function atalanta_celestial_arrow:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function atalanta_celestial_arrow:GetIntrinsicModifierName()
    return "modifier_celestial_arrow"
end

function atalanta_celestial_arrow:GetAbilityTextureName()
    return "windrunner_powershot"
end