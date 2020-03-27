IP_duration = 7
IMPROVE_IP_duration = 13
LinkLuaModifier("sword_martial", "abilities/nero/sword_martial", LUA_MODIFIER_MOTION_NONE)

function OnNeroGBStart(keys)
    local caster = keys.caster
    local ability = keys.ability
    ability:ApplyDataDrivenModifier(caster, caster, "modifier_gladiusanus_blauserum_bonus_damage", {})
    local modifier = caster:FindModifierByName("modifier_gladiusanus_blauserum_bonus_damage")
    Timers:CreateTimer(
        function()
            modifier:SetStackCount(modifier:GetStackCount() + 5)
            if modifier:GetStackCount() ~= 100 then
                return 0.1
            end
        end
    )
end

function OnNeroGBEnd(keys)
    local caster = keys.caster
    local modifier = caster:FindModifierByName("modifier_gladiusanus_blauserum_bonus_damage")
    local casterfacing = caster:GetForwardVector()
    local pushTarget = Physics:Unit(caster)
    local initialUnitOrigin = caster:GetAbsOrigin()
    local stack = modifier:GetStackCount()
    local len = 1000
    if caster.IsPTBAcquired == true then
        len = 1200
    end
    caster:EmitSound("Nero.Rosa")
    StartAnimation(caster, {duration = 0.5, activity = ACT_DOTA_CAST_ABILITY_1, rate = 1})
    local charge =
        ParticleManager:CreateParticle(
        "particles/units/heroes/hero_disruptor/disruptor_kineticdischarge_aoe_discharge_c.vpcf",
        PATTACH_ABSORIGIN,
        caster
    )
    Timers:CreateTimer(
        1.5,
        function()
            ParticleManager:DestroyParticle(charge, false)
            ParticleManager:ReleaseParticleIndex(charge)
        end
    )
    giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 0.4)
    caster.TFAStack = stack
    local speed = 3000
    speed = (caster.TFAStack / 300 + 1) * speed
    caster:RemoveModifierByName("modifier_gladiusanus_blauserum_bonus_damage")
    local charge = {
        Ability = keys.ability,
        EffectName = "particles/econ/items/windrunner/windrunner_ti6/windrunner_spell_powershot_ti6_spray.vpcf",
        iMoveSpeed = speed,
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = len,
        Source = caster,
        fStartRadius = 200,
        fEndRadius = 200,
        bHasFrontialCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 0.4,
        bDeleteOnHit = false,
        vVelocity = casterfacing * speed
    }
    caster.chargedummy=ProjectileManager:CreateLinearProjectile(charge)
    caster:PreventDI()
    caster:SetPhysicsFriction(0)
    caster:SetPhysicsVelocity(casterfacing:Normalized() * speed)
    caster:SetNavCollisionType(PHYSICS_NAV_BOUNCE)
    caster:OnPhysicsFrame(
        function(unit)
            local unitOrigin = unit:GetAbsOrigin()
            local diff = unitOrigin - initialUnitOrigin
            local n_diff = diff:Normalized()
            unit:SetPhysicsVelocity(unit:GetPhysicsVelocity():Length() * n_diff)
            if diff:Length() > len then
                unit:PreventDI(false)
                unit:SetPhysicsVelocity(Vector(0, 0, 0))
                unit:OnPhysicsFrame(nil)
                caster:RemoveModifierByName("pause_sealdisabled")
                FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
            end
        end
    )
    caster:OnPreBounce(
        function(unit, normal)
            unit:RemoveModifierByName("pause_sealdisabled")
            unit:SetBounceMultiplier(0)
            unit:PreventDI(false)
            unit:SetPhysicsVelocity(Vector(0, 0, 0))
            FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
            ProjectileManager:DestroyLinearProjectile(unit.chargedummy)
        end
    )
end

function OnNeroGBEndHit(keys)
    caster = keys.caster
    target = keys.target
    damage = keys.damage
    if caster.IsPTBAcquired == true then
        damage = damage + 150
    end
    damage = caster:GetAgility() * keys.agi_ratio + damage
    damage = (caster.TFAStack / 100) * damage + damage
    local fx =
        ParticleManager:CreateParticle(
        "particles/units/heroes/hero_disruptor/disruptor_kineticdischarge_aoe_discharge_c.vpcf",
        PATTACH_ABSORIGIN,
        target
    )
    local fx2 =
        ParticleManager:CreateParticle(
        "particles/units/heroes/hero_treant/treant_overgrowth_hero_glow.vpcf",
        PATTACH_ABSORIGIN,
        target
    )
    --Timers:CreateTimer(
        --0.6,
        --function()
            DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
            ParticleManager:DestroyParticle(fx, false)
            ParticleManager:ReleaseParticleIndex(fx)
            ParticleManager:DestroyParticle(fx2, false)
            ParticleManager:ReleaseParticleIndex(fx2)
        --end
    --)
    target:AddNewModifier(caster, caster, "modifier_stunned", {Duration = 0.8})
end

function OnNeroDBStart(keys)
    local target = keys.target
    local caster = keys.caster
    local max_count = keys.max_hit
    local count = 0
    local temp = target
    if caster.IsPTBAcquired == true then
        max_count = max_count + 1
    end
    local time = 1.8 / max_count
    local agi = caster:GetAgility() * 0.8
    keys.ability:ApplyDataDrivenModifier(caster, caster, "unselect_state", {duration=1.8})
    --keys.damage = keys.damage + (agi/4)
    Timers:CreateTimer(
        function()
            if count == 0 then
                caster:SetModel("models/development/invisiblebox.vmdl")
            end
            if not caster:IsAlive() then
                caster:SetModel("models/nero/nero.vmdl")
            end
            local v = RandomVector(300)
            caster:EmitSound("Hero_Juggernaut.OmniSlash.Damage")
            if caster:IsAlive()  and  count ~= max_count  and  (not caster:IsStunned()) then
                if caster.Focus == target and caster.Focus:IsAlive() then
                    DoDamage(caster, caster.Focus, keys.damage + agi, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
                    caster.Focus:AddNewModifier(caster, caster.Focus, "modifier_stunned", {Duration = 0.05})
                    count = count + 1
                    CreateSlashFx(
                        caster,
                        caster.Focus:GetAbsOrigin() + v,
                        caster.Focus:GetAbsOrigin() - v + RandomVector(120)
                    )
                    caster:SetAbsOrigin(caster.Focus:GetAbsOrigin() - v)
                    return time
                else
                    if count ~= max_count then
                        count = count + 1
                        local targets =
                            FindUnitsInRadius(
                            caster:GetTeam(),
                            temp:GetAbsOrigin(),
                            nil,
                            keys.radiu,
                            DOTA_UNIT_TARGET_TEAM_ENEMY,
                            DOTA_UNIT_TARGET_ALL,
                            0,
                            FIND_ANY_ORDER,
                            false
                        )

                        local c = 0
                        for k, v in pairs(targets) do
                            c = c + 1
                        end

                        if c == 1 then
                            if caster.Focus == targets[1] then
                                DoDamage(
                                    caster,
                                    targets[1],
                                    keys.damage + agi,
                                    DAMAGE_TYPE_MAGICAL,
                                    0,
                                    keys.ability,
                                    false
                                )
                            else
                                DoDamage(caster, targets[1], keys.damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
                            end
                            CreateSlashFx(
                                caster,
                                targets[1]:GetAbsOrigin() + v,
                                targets[1]:GetAbsOrigin() - v + RandomVector(120)
                            )
                            caster:SetAbsOrigin(targets[1]:GetAbsOrigin() - v)
                            return time
                        end
                        if c ~= 0 then
                            if caster.Focus == targets[2] then
                                DoDamage(
                                    caster,
                                    targets[2],
                                    keys.damage + agi,
                                    DAMAGE_TYPE_MAGICAL,
                                    0,
                                    keys.ability,
                                    false
                                )
                            else
                                DoDamage(caster, targets[2], keys.damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
                            end
                            temp = targets[2]
                            CreateSlashFx(
                                caster,
                                targets[2]:GetAbsOrigin() + v,
                                targets[2]:GetAbsOrigin() - v + RandomVector(120)
                            )
                            caster:SetAbsOrigin(targets[2]:GetAbsOrigin() - v)
                            return time
                        end
                    end
                end
            end
            caster:RemoveModifierByName("unselect_state")
            caster:SetModel("models/nero/nero.vmdl")
            FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
        end
    )
end

function OnTheatreCast(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    local targetabs = target:GetAbsOrigin()
    local targetfac = target:GetForwardVector()
    if caster:HasModifier("modifier_aestus_domus_aurea") then
        caster:SetMana(caster:GetMana() + 800)
        keys.ability:EndCooldown()
        return
    end
    ability:ApplyDataDrivenModifier(caster, caster, "modifier_theatre_anim", {})
    EmitGlobalSound("Nero.Domus")
    giveUnitDataDrivenModifier(caster, caster, "pause_sealenabled", 1.5)

    Timers:CreateTimer(
        1.32,
        function()
            if caster:IsAlive() and not caster:HasModifier("modifier_invictus_spiritus") then
                caster:SetAbsOrigin(targetabs + targetfac * 600)
                FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
                keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_aestus_domus_aurea_focus", {})
                caster.Focus = target
                OnTheatreStart(keys)
                keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_aestus_domus_aurea", {})
            end
        end
    )
    NeroCheckCombo(caster, keys.ability)
end

function CreateBannerInCircle(handle, center, multiplier)
    local bannerTable = {}
    local banner = CreateUnitByName("nero_banner", center, true, nil, nil, handle:GetTeamNumber())
    table.insert(bannerTable, banner)
    return bannerTable
end

function OnTheatreStart(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local target = keys.target
    local centerabs = (caster:GetAbsOrigin() + target:GetAbsOrigin()) / 2
    caster.dumacenter = centerabs
    caster:SetForwardVector(-1 * (target:GetForwardVector()))
    caster:EmitSound("Hero_LegionCommander.Duel.Victory")
    local dummy = CreateUnitByName("visible_dummy_unit", centerabs, false, caster, caster, caster:GetTeamNumber())
    dummy:AddNewModifier(caster, nil, "modifier_kill", {duration = 10.0})
    giveUnitDataDrivenModifier(caster, dummy, "jump_pause", 10)

    caster:SetAbsOrigin(caster:GetAbsOrigin() + Vector(0, 0, 300))

    local t = 10
    Timers:CreateTimer(
        function()
            if t ~= 0 then
                caster:SetAbsOrigin(caster:GetAbsOrigin() - Vector(0, 0, 30))
                t = t - 1
            end
            return 0.01
        end
    )

    local banners = CreateUnitByName("nero_banner", centerabs, true, nil, nil, caster:GetTeamNumber())

    local startfx =
        ParticleManager:CreateParticle("particles/custom/nero/nero_ring_new.vpcf", PATTACH_ABSORIGIN_FOLLOW, dummy)

    local pushtargets =
        FindUnitsInRadius(
        caster:GetTeam(),
        centerabs,
        nil,
        keys.Radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_ALL,
        0,
        FIND_ANY_ORDER,
        false
    )
    for k, v in pairs(pushtargets) do
        DoDamage(caster, v, keys.debut_damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
        ApplyAirborne(caster, v, 0.2)
        if v ~= target then
            local pushTarget = Physics:Unit(v)
            local initialUnitOrigin = v:GetAbsOrigin()
            local diff = (initialUnitOrigin - centerabs):Normalized() -- yun dong fang xiang
            local length = 1050 - (centerabs - initialUnitOrigin):Length2D()
            if length >= 100 then length = 100 end
            v:PreventDI()
            v:SetPhysicsFriction(0)
            v:SetPhysicsVelocity(diff:Normalized() * 5000)
            v:SetNavCollisionType(PHYSICS_NAV_BOUNCE)
            v:OnPhysicsFrame(
                function(unit)
                    local unitOrigin = unit:GetAbsOrigin()
                    local p_diff = unitOrigin - initialUnitOrigin
                    local n_diff = p_diff:Length2D()
                    if n_diff > length then
                        unit:PreventDI(false)
                        unit:SetPhysicsVelocity(Vector(0, 0, 0))
                        unit:OnPhysicsFrame(nil)
                        FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
                    end
                end
            )
        end
    end
    local timeCounter = 0

    caster.theatreFx2 =
        ParticleManager:CreateParticle(
        "particles/custom/nero/nero_domus_ring_border.vpcf",
        PATTACH_ABSORIGIN_FOLLOW,
        dummy
    )
    ParticleManager:SetParticleControl(caster.theatreFx2, 1, Vector(keys.Radius, 0, 0))
    -- use to destory fx
    Timers:CreateTimer(
        function()
            if caster:IsAlive() and caster:HasModifier("modifier_aestus_domus_aurea") then
                local nerofx =
                    ParticleManager:CreateParticle(
                    "particles/custom/nero/nero_scorched_earth_child_embers_dominus.vpcf",
                    PATTACH_ABSORIGIN,
                    dummy
                )
                Timers:CreateTimer(
                    9.0,
                    function()
                        ParticleManager:DestroyParticle(nerofx, false)
                        ParticleManager:ReleaseParticleIndex(nerofx)
                    end
                )
                return 2.5
            end
        end
    )
    Timers:CreateTimer(
        0.5,
        function()
            if caster:IsAlive() and timeCounter < keys.Duration then
                timeCounter = timeCounter + 0.5
                return 0.5
            end
            FxDestroyer(startfx, false)
            FxDestroyer(caster.theatreFx2, false)
        end
    )

    -- light particle loop
    Timers:CreateTimer(
        function()
            if caster:HasModifier("modifier_aestus_domus_aurea") and caster:IsAlive() then
                local lightFx =
                    ParticleManager:CreateParticle(
                    "particles/custom/nero/nero_domus_ray.vpcf",
                    PATTACH_ABSORIGIN_FOLLOW,
                    caster
                )
                ParticleManager:SetParticleControl(lightFx, 7, caster:GetAbsOrigin())
                return 0.25
            else
                banners:RemoveSelf()
                caster.Focus = nil
                return
            end
        end
    )

    -- main loop
    Timers:CreateTimer(
        function()
            if caster:HasModifier("modifier_aestus_domus_aurea") and caster:IsAlive() then
                --apply debuff to faceaway enemies
                local targets =
                    FindUnitsInRadius(
                    caster:GetTeam(),
                    centerabs,
                    nil,
                    keys.Radius,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_ALL,
                    0,
                    FIND_ANY_ORDER,
                    false
                )
                for k, v in pairs(targets) do
                    keys.ability:ApplyDataDrivenModifier(keys.caster, v, "modifier_aestus_domus_aurea_debuff", {})
                    keys.ability:ApplyDataDrivenModifier(keys.caster, v, "modifier_aestus_domus_aurea_debuff_slow", {})
                end

                return 0.1
            else
                return
            end
        end
    )
end

function OnTheatreApplyDamage(keys)
    local target = keys.target
    local caster = keys.caster
    DoDamage(caster, target, keys.Damage / 4, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function OnFocusDamageTaken(keys)
    local attacker = keys.attacker
    local caster = keys.caster
end

function OnIPRespawn(keys)
    print("respawned")
    local caster = keys.caster
    keys.ability:EndCooldown()
end

function OnIPStart(keys)
    local caster = keys.caster

    caster:SwapAbilities(caster:GetAbilityByIndex(0):GetName(), "nero_acquire_divinity", false, true)
    caster:SwapAbilities(caster:GetAbilityByIndex(1):GetName(), "nero_acquire_golden_rule", false, true)
    caster:SwapAbilities(caster:GetAbilityByIndex(2):GetName(), "nero_acquire_martial_arts", false, true)
    caster:SwapAbilities(caster:GetAbilityByIndex(4):GetName(), "nero_close_spellbook", false, true)
    caster:SwapAbilities(caster:GetAbilityByIndex(5):GetName(), "nero_acquire_clairvoyance", false, true)
end

function OnIPClose(keys)
    local caster = keys.caster
    caster:SwapAbilities(caster:GetAbilityByIndex(0):GetName(), "nero_rosa_ichthys", false, true)
    caster:SwapAbilities(caster:GetAbilityByIndex(1):GetName(), "nero_gladiusanus_blauserum", false, true)
    caster:SwapAbilities(caster:GetAbilityByIndex(2):GetName(), "nero_blade_dance", false, true)
    caster:SwapAbilities(caster:GetAbilityByIndex(4):GetName(), "nero_imperial_privilege", false, true)
    caster:SwapAbilities(caster:GetAbilityByIndex(5):GetName(), "nero_aestus_domus_aurea", false, true)
end

function OnDivinityAcquired(keys)
    local caster = keys.caster
    if caster.IsPrivilegeImproved == true then
        keys.ability:ApplyDataDrivenModifier(
            caster,
            caster,
            "nero_acquire_divinity_passive",
            {duration = IMPROVE_IP_duration}
        )
        caster:FindAbilityByName("nero_imperial_privilege"):StartCooldown(30)
    else
        keys.ability:ApplyDataDrivenModifier(caster, caster, "nero_acquire_divinity_passive", {duration = IP_duration})
        caster:FindAbilityByName("nero_imperial_privilege"):StartCooldown(9999)
    end
    OnIPClose(keys)
end

function OnGoldenRuleAcquired(keys)
    local caster = keys.caster
    caster:ModifyGold(666, true, 0)
    if caster.IsPrivilegeImproved == true then
        keys.ability:ApplyDataDrivenModifier(
            caster,
            caster,
            "nero_acquire_golden_rule_passive",
            {duration = IMPROVE_IP_duration}
        )
        caster:FindAbilityByName("nero_imperial_privilege"):StartCooldown(30)
    else
        keys.ability:ApplyDataDrivenModifier(
            caster,
            caster,
            "nero_acquire_golden_rule_passive",
            {duration = IP_duration}
        )
        caster:FindAbilityByName("nero_imperial_privilege"):StartCooldown(9999)
    end
    OnIPClose(keys)
end

function OnGoldenRuleStart(keys)
    keys.caster:ModifyGold(666, true, 0)
end

function OnGoldenRuleThink(keys)
    keys.caster:ModifyGold(66, true, 0)
end

LinkLuaModifier("sword_martial", "abilities/nero/sword_martial", LUA_MODIFIER_MOTION_NONE)

function OnMartialArtsAcquired(keys)
    local caster = keys.caster
    if caster.IsPrivilegeImproved == true then
        keys.ability:ApplyDataDrivenModifier(caster, caster, "sword_martial", {duration = IMPROVE_IP_duration})
        keys.ability:ApplyDataDrivenModifier(caster, caster, "nero_martial_arts_fx", {duration = IMPROVE_IP_duration})
        caster:FindAbilityByName("nero_imperial_privilege"):StartCooldown(30)
    else
        caster:AddNewModifier(caster, self, "sword_martial", {duration = IP_duration})
        keys.ability:ApplyDataDrivenModifier(caster, caster, "nero_martial_arts_fx", {duration = IP_duration})
        caster:FindAbilityByName("nero_imperial_privilege"):StartCooldown(9999)
    end
    OnIPClose(keys)
end

function OnClairvoyanceAcquired(keys)
    local caster = keys.caster
    EmitSoundOnLocationWithCaster(keys.caster:GetAbsOrigin(), "Hero_KeeperOfTheLight.BlindingLight", keys.caster)
    if caster.IsPrivilegeImproved == true then
        SpawnVisionDummy(caster, caster:GetAbsOrigin(), 1800, IMPROVE_IP_duration, true)
        caster:FindAbilityByName("nero_imperial_privilege"):StartCooldown(30)
    else
        SpawnVisionDummy(caster, caster:GetAbsOrigin(), 1800, IP_duration, true)
        caster:FindAbilityByName("nero_imperial_privilege"):StartCooldown(9999)
    end
    OnIPClose(keys)
end

function NeroCheckCombo(caster, ability)
    if caster:GetStrength() >= 19.1 and caster:GetAgility() >= 19.1 and caster:GetIntellect() >= 19.1 then
        if
            ability == caster:FindAbilityByName("nero_aestus_domus_aurea") and
                caster:FindAbilityByName("nero_blade_dance"):IsCooldownReady() and
                caster:FindAbilityByName("nero_fiery_finale"):IsCooldownReady()
         then
            caster:SwapAbilities("nero_blade_dance", "nero_fiery_finale", false, true)
            Timers:CreateTimer(
                {
                    endTime = 1.8,
                    callback = function()
                        caster:SwapAbilities("nero_blade_dance", "nero_fiery_finale", true, false)
                    end
                }
            )
        end
    end
end

function OnNeroComboStart(keys)
    local caster = keys.caster
    local ability = keys.ability
    caster.IsFieryFinaleActivated = true
    local radius = caster:FindAbilityByName("nero_aestus_domus_aurea"):GetSpecialValueFor("radius")
    local flamePillarRadius = 200

    caster:AddNewModifier(caster, self, "sword_martial", {duration = IP_duration})

    -- Set master's combo cooldown
    local masterCombo = caster.MasterUnit2:FindAbilityByName(keys.ability:GetAbilityName())
    masterCombo:EndCooldown()
    masterCombo:StartCooldown(keys.ability:GetCooldown(1))
    ability:ApplyDataDrivenModifier(
        caster,
        caster,
        "modifier_fiery_finale_cooldown",
        {duration = ability:GetCooldown(ability:GetLevel())}
    )

    local tresAbility = caster:FindAbilityByName("nero_blade_dance")
    local tresCooldown = tresAbility:GetCooldown(tresAbility:GetLevel())
    tresAbility:StartCooldown(tresCooldown)

    caster.ScreenOverlay =
        ParticleManager:CreateParticle("particles/custom/screen_lightred_splash.vpcf", PATTACH_EYES_FOLLOW, caster)

    giveUnitDataDrivenModifier(caster, caster, "jump_pause", 4.0)
    caster.Focus:AddNewModifier(caster, caster.Focus, "modifier_stunned", {Duration = 4.0})
    local slash = {
        Ability = keys.ability,
        EffectName = "",
        iMoveSpeed = 99999,
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = 0,
        fStartRadius = 200,
        fEndRadius = 200,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        fExpireTime = GameRules:GetGameTime() + 2.0,
        bDeleteOnHit = false,
        vVelocity = caster:GetForwardVector() * 99999
    }
    local count = 0
    Timers:CreateTimer(
        function()
            if caster:IsAlive() and count ~= 100 and caster:HasModifier("modifier_aestus_domus_aurea") then
                local targetPoint = RandomPointInCircle(caster.dumacenter, radius)
                local targets =
                    FindUnitsInRadius(
                    caster:GetTeam(),
                    targetPoint,
                    nil,
                    flamePillarRadius,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_ALL,
                    0,
                    FIND_ANY_ORDER,
                    false
                )
                -- DebugDrawCircle(targetPoint, Vector(255,0,0), 0.5, flamePillarRadius, true, 30)
                for k, v in pairs(targets) do
                    DoDamage(caster, v, keys.FlameDamage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
                    v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 0.1})
                end

                local flameFx =
                    ParticleManager:CreateParticle(
                    "particles/custom/nero/nero_fiery_finale_eruption.vpcf",
                    PATTACH_ABSORIGIN,
                    caster
                )
                ParticleManager:SetParticleControl(flameFx, 0, targetPoint)
                Timers:CreateTimer(
                    12.0,
                    function()
                        ParticleManager:DestroyParticle(flameFx, false)
                        ParticleManager:ReleaseParticleIndex(flameFx)
                    end
                )
                caster:EmitSound("Hero_Batrider.Firefly.Cast")
                count = count + 1
                if count == 10 then
                    keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_laus_anim", {})
                    targets =
                        FindUnitsInRadius(
                        caster:GetTeam(),
                        caster.dumacenter ,
                        nil,
                        300,
                        DOTA_UNIT_TARGET_TEAM_ENEMY,
                        DOTA_UNIT_TARGET_ALL,
                        0,
                        FIND_ANY_ORDER,
                        false
                    )
                    for k, v in pairs(targets) do
                        DoDamage(
                            caster,
                            v,
                            200 + caster:GetAgility() * 2.5,
                            DAMAGE_TYPE_MAGICAL,
                            0,
                            keys.ability,
                            false
                        )
                        v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 0.2})
                    end
                    CreateSlashFx(
                        caster,
                        caster.Focus:GetAbsOrigin() + Vector(1200, 1200, 300),
                        caster:GetAbsOrigin() + Vector(-1200, -1200, 300)
                    )
                    EmitGlobalSound("FA.Quickdraw")
                end
                if count == 20 then
                    caster:SetAbsOrigin(caster.Focus:GetAbsOrigin())
                    EmitGlobalSound("Nero.Laus")
                end
                if count == 30 then
                    targets =
                        FindUnitsInRadius(
                        caster:GetTeam(),
                        caster.dumacenter,
                        nil,
                        900,
                        DOTA_UNIT_TARGET_TEAM_ENEMY,
                        DOTA_UNIT_TARGET_ALL,
                        0,
                        FIND_ANY_ORDER,
                        false
                    )
                    for k, v in pairs(targets) do
                        DoDamage(
                            caster,
                            v,
                            200 + caster:GetAgility() * 2.5,
                            DAMAGE_TYPE_MAGICAL,
                            0,
                            keys.ability,
                            false
                        )
                        v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 0.15})
                    end
                    CreateSlashFx(
                        caster,
                        caster.Focus:GetAbsOrigin() + Vector(1200, 1200, 300),
                        caster:GetAbsOrigin() + Vector(-1200, -1200, 300)
                    )
                    caster:SetForwardVector((caster.Focus:GetAbsOrigin() - caster.dumacenter):Normalized())
                    caster:SetAbsOrigin(caster.dumacenter - caster:GetForwardVector() * 600)
                    StartAnimation(caster, {duration = 1, activity = ACT_DOTA_CAST_ABILITY_1, rate = 1})
                    EmitGlobalSound("FA.Quickdraw")
                end
                if count == 80 and (caster.Focus:GetAbsOrigin() - caster.dumacenter):Length2D() <= 1050 then
                    if caster:IsAlive() then
                        local diff = caster.Focus:GetAbsOrigin() - caster:GetAbsOrigin()
                        local dist = 3000

                        slash.vSpawnOrigin = caster:GetAbsOrigin() - diff:Normalized() * 1000
                        slash.vVelocity = (caster.Focus:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized() * 99999
                        slash.fDistance = dist

                        local projectile = ProjectileManager:CreateLinearProjectile(slash)
                        CreateSlashFx(
                            caster,
                            slash.vSpawnOrigin,
                            slash.vSpawnOrigin + diff:Normalized() * 3000 + Vector(0, 0, 300)
                        )
                        if diff:Length2D() > 2000 then
                            caster:SetAbsOrigin(caster:GetAbsOrigin() - diff:Normalized() * 1000)
                            FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
                        else
                            caster:SetAbsOrigin(caster.Focus:GetAbsOrigin() + diff:Normalized() * 200)
                            FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
                        end
                        caster:EmitSound("Hero_Lion.FingerOfDeath")
                    end
                end
                if count == 90 then
                    local Fx =
                        ParticleManager:CreateParticle(
                        "particles/econ/items/luna/luna_lucent_ti5_gold/luna_eclipse_impact_notarget_moonfall_gold.vpcf",
                        PATTACH_ABSORIGIN,
                        caster.Focus
                    )
                    local Fx2 =
                        ParticleManager:CreateParticle(
                        "particles/custom/nero/nero_impact_2.vpcf",
                        PATTACH_ABSORIGIN,
                        caster.Focus
                    )
                    targets =
                        FindUnitsInRadius(
                        caster:GetTeam(),
                        caster.Focus:GetAbsOrigin(),
                        nil,
                        400,
                        DOTA_UNIT_TARGET_TEAM_ENEMY,
                        DOTA_UNIT_TARGET_ALL,
                        0,
                        FIND_ANY_ORDER,
                        false
                    )
                    for k, v in pairs(targets) do
                        DoDamage(caster, v, 500 + caster:GetAgility() * 3, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
                        v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 0.15})
                    end
                    caster:EmitSound("Hero_EarthSpirit.StoneRemnant.Impact")
                end
                return 0.04
            else
                OnNeroComboEnd(keys)
                return
            end
        end
    )
end

function OnLSCStart(keys)
    local caster = keys.caster
    local target = keys.target
    EmitGlobalSound("Nero.Laus")
    keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_laus_anim", {})
    giveUnitDataDrivenModifier(caster, caster, "jump_pause", 1.75)
    local slash = {
        Ability = keys.ability,
        EffectName = "",
        iMoveSpeed = 99999,
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = 0,
        fStartRadius = 200,
        fEndRadius = 200,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        fExpireTime = GameRules:GetGameTime() + 2.0,
        bDeleteOnHit = false,
        vVelocity = caster:GetForwardVector() * 99999
    }

    Timers:CreateTimer(
        0.2,
        function()
            OnNeroComboEnd(keys)
            if caster:IsAlive() then
                local max_hp_damage = 0.20
                if caster.IsPavilionAcquired then
                    max_hp_damage = max_hp_damage + CustomNetTables:GetTableValue("sync", "nero_pavilion").bonus
                end
                print(max_hp_damage)
                local targets =
                    FindUnitsInRadius(
                    caster:GetTeam(),
                    caster:GetAbsOrigin(),
                    nil,
                    900,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_ALL,
                    0,
                    FIND_ANY_ORDER,
                    false
                )
                for k, v in pairs(targets) do
                    DoDamage(caster, v, v:GetMaxHealth() * max_hp_damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
                    v:AddNewModifier(caster, caster, "modifier_stunned", {Duration = 0.1})
                end
                CreateSlashFx(
                    caster,
                    caster:GetAbsOrigin() + Vector(1200, 1200, 300),
                    caster:GetAbsOrigin() + Vector(-1200, -1200, 300)
                )
                EmitGlobalSound("FA.Quickdraw")
            end
        end
    )
    Timers:CreateTimer(
        0.5,
        function()
            if caster:IsAlive() then
                local targets =
                    FindUnitsInRadius(
                    caster:GetTeam(),
                    caster:GetAbsOrigin(),
                    nil,
                    900,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_ALL,
                    0,
                    FIND_ANY_ORDER,
                    false
                )
                for k, v in pairs(targets) do
                    DoDamage(caster, v, v:GetMaxHealth() * max_hp_damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
                    v:AddNewModifier(caster, caster, "modifier_stunned", {Duration = 0.1})
                end
                CreateSlashFx(
                    caster,
                    caster:GetAbsOrigin() + Vector(1200, -1200, 300),
                    caster:GetAbsOrigin() + Vector(-1200, 1200, 300)
                )
                EmitGlobalSound("FA.Quickdraw")
            end
        end
    )

    Timers:CreateTimer(
        1.75,
        function()
            if caster:IsAlive() then
                local diff = target:GetAbsOrigin() - caster:GetAbsOrigin()
                local dist = 3000

                slash.vSpawnOrigin = caster:GetAbsOrigin() - diff:Normalized() * 1000
                slash.vVelocity = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized() * 99999
                slash.fDistance = dist

                local projectile = ProjectileManager:CreateLinearProjectile(slash)
                CreateSlashFx(
                    caster,
                    slash.vSpawnOrigin,
                    slash.vSpawnOrigin + diff:Normalized() * 3000 + Vector(0, 0, 300)
                )
                if diff:Length2D() > 2000 then
                    caster:SetAbsOrigin(caster:GetAbsOrigin() + diff:Normalized() * 2000)
                    FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
                else
                    caster:SetAbsOrigin(target:GetAbsOrigin() - diff:Normalized() * 100)
                    FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
                end
                EmitGlobalSound("Hero_Lion.FingerOfDeath")
            end
        end
    )
end

function OnLausHit(keys)
    DoDamage(
        keys.caster,
        keys.target,
        keys.damage + keys.caster:GetAgility() * 5,
        DAMAGE_TYPE_MAGICAL,
        0,
        keys.ability,
        false
    )
    print("hited")
    keys.target:AddNewModifier(keys.caster, keys.target, "modifier_stunned", {Duration = 0.3})
end

function OnNeroComboEnd(keys)
    local caster = keys.caster
    caster.IsFieryFinaleActivated = false
    ParticleManager:DestroyParticle(caster.ScreenOverlay, false)
    ParticleManager:ReleaseParticleIndex(caster.ScreenOverlay)
    caster:RemoveModifierByName("modifier_aestus_domus_aurea")
    FxDestroyer(caster.theatreFx2, false)
end

function OnISStart(keys)
end

function NeroSpringFire(keys)
    local target = keys.target
    DoDamage(keys.caster, target, keys.damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function NeroCheer(keys)
    if keys.target:IsHero() then
        local targets =
            FindUnitsInRadius(
            caster:GetTeam(),
            caster:GetAbsOrigin(),
            nil,
            1300,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_ALL,
            0,
            FIND_ANY_ORDER,
            false
        )
        for k, v in pairs(targets) do
            if v:IsHero() then
                keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_cheer", {})
            end
        end
    end
end

function OnPrivilegeImproved(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    hero.IsPrivilegeImproved = true
    -- Set master 1's mana
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnPavilionAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    hero.IsPavilionAcquired = true
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnGloryAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    hero.IsGloryAcquired = true
    -- Set master 1's mana
    hero:FindAbilityByName("nero_spring"):SetLevel(2)
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnPTBAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    hero.IsPTBAcquired = true
    -- Set master 1's mana
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end
