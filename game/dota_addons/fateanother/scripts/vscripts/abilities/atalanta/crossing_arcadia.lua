atalanta_crossing_arcadia = class({})

function atalanta_crossing_arcadia:OnUpgrade()
    local caster = self:GetCaster()
    local ability = self

    if IsServer() then
        if not caster.ShootAoEArrow then
            function caster:ShootAoEArrow(...)
                ability:ShootAoEArrow(...)
            end
        end
    end
end

function atalanta_crossing_arcadia:GetCastRange()
    return self:GetSpecialValueFor("range")
end

function atalanta_crossing_arcadia:GetAOERadius()
    local caster = self:GetCaster()
    local aoe = self:GetSpecialValueFor("aoe")

    if IsServer() and caster:HasModifier("modifier_tauropolos") then
        local tauropolos = caster:FindAbilityByName("atalanta_tauropolos")
        aoe = aoe + tauropolos:GetSpecialValueFor("bonus_aoe_per_agi") * caster:GetAgility()
    end

    return aoe
end

function atalanta_crossing_arcadia:CastFilterResultLocation(location)
    local caster = self:GetCaster()

    --[[if IsServer() then
        if GridNav:IsBlocked(location) or not GridNav:IsTraversable(location) then
            return UF_FAIL_CUSTOM
        end
    end]]

    if not caster:HasArrow() then
        return UF_FAIL_CUSTOM
    end

    return UF_SUCCESS
end

function atalanta_crossing_arcadia:GetCustomCastErrorLocation(location)
    --[[if IsServer() then
        if GridNav:IsBlocked(location) or not GridNav:IsTraversable(location) then
            return "#Cannot_Travel"
        end
    end]]

    return "Not enough arrows..."
end

function atalanta_crossing_arcadia:OnProjectileHit_ExtraData(target, location, data)
    local caster = self:GetCaster()

    if not target then
        return
    end

    local targets = FindUnitsInRadius(caster:GetTeam(), target:GetOrigin(), nil, data["1"], DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
    for _,v in pairs(targets) do
        caster:ArrowHit(v, data["2"])
    end
end

function atalanta_crossing_arcadia:ShootAoEArrow(keys)
    local caster = self:GetCaster()
    local ability = self

    local source
    local origin
    local target
    local dummy
    local position

    if keys.Origin then
        local originDummy = CreateUnitByName("dummy_unit", keys.Origin, false, caster, caster, caster:GetTeamNumber())
        originDummy:SetOrigin(keys.Origin)
        originDummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)

        Timers:CreateTimer(1, function()
            originDummy:RemoveSelf()
        end)

        source = originDummy
        origin = keys.Origin
    else
        source = caster
        origin = caster:GetOrigin()
    end

    if not keys.Target then
        dummy = CreateUnitByName("dummy_unit", keys.Position, false, caster, caster, caster:GetTeamNumber())
        dummy:SetOrigin(keys.Position)
        dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)

        target = dummy
        position = keys.Position
    else
        target = keys.Target
        position = target:GetOrigin()
    end

    local displacement = position - origin
    if displacement == Vector(0, 0, 0) then
        displacement = Vector(1, 1, 0)
    end
    local velocity = displacement / keys.Delay

    local projectile = {
        Target = target,
        Source = source,
        Ability = self,
        EffectName = keys.Effect,
        bDodgable = false,
        bProvidesVision = false,
        iMoveSpeed = velocity:Length(),
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
	ExtraData = {keys.AoE or 0, keys.Slow or 0}
    }
    ProjectileManager:CreateTrackingProjectile(projectile)

    Timers:CreateTimer(keys.Delay + 0.1, function()
        if dummy then
            dummy:RemoveSelf()
        end

    end)
end

function atalanta_crossing_arcadia:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self
    local position = self:GetCursorPosition()
    local origin = caster:GetOrigin()

    local retreatDist = 500
    local forwardVec = caster:GetForwardVector()
    local archer = Physics:Unit(caster)

    local duration = self:GetSpecialValueFor("jump_duration")
    --local stunDuration = self:GetSpecialValueFor("stun_duration")
    local aoe = self:GetAOERadius()
    local effect = "particles/units/heroes/hero_enchantress/enchantress_impetus.vpcf"
    local facing = caster:GetForwardVector() + Vector(0, 0, -2)

    caster:PreventDI()
    caster:SetPhysicsFriction(0)
    caster:SetPhysicsVelocity(-forwardVec * retreatDist * 2 + Vector(0,0,1200))
    caster:SetPhysicsAcceleration(Vector(0,0,-3000))
    caster:SetNavCollisionType(PHYSICS_NAV_BOUNCE)
    caster:FollowNavMesh(true)

    ProjectileManager:ProjectileDodge(caster)

    Timers:CreateTimer(duration, function()
        caster:PreventDI(false)
        caster:SetPhysicsVelocity(Vector(0,0,0))
        caster:OnPhysicsFrame(nil)
        FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
    end)
    StartAnimation(caster, {duration=duration, activity=ACT_DOTA_CAST_ABILITY_1, rate=1.0})
    rotateCounter = 1
    Timers:CreateTimer(function()
        if rotateCounter == 13 then return end
        caster:SetForwardVector(RotatePosition(Vector(0,0,0), QAngle(0,30*rotateCounter,0), forwardVec))
        rotateCounter = rotateCounter + 1
        return 0.03
    end)
    giveUnitDataDrivenModifier(caster, caster, "jump_pause", 0.5)


    if caster.CrossingArcadiaPlusAcquired then
        local offset = 0.7071 * aoe - 50
        Timers:CreateTimer(0.15, function()
            if not caster:IsAlive() then
                return
            end
            caster:ShootArrow({
                Position = position + Vector(-offset, -offset, 0),
                AoE = aoe,
                Delay = 0.2,
                Effect = effect,
                Facing = facing,
                Stun = 0,
            })
        end)

        Timers:CreateTimer(0.25, function()
            if not caster:IsAlive() then
                return
            end
            caster:ShootArrow({
                Position = position + Vector(offset, -offset, 0),
                AoE = aoe,
                Delay = 0.2,
                Effect = effect,
                Facing = facing,
                Stun = 0,
                DontUseArrow = true
            })
        end)

        Timers:CreateTimer(0.35, function()
            if not caster:IsAlive() then
                return
            end
            caster:ShootArrow({
                Position = position + Vector(0, aoe - 50, 0),
                AoE = aoe,
                Delay = 0.2,
                Effect = effect,
                Facing = facing,
                Stun = 0,
                DontUseArrow = true
            })
        end)
        Timers:CreateTimer(duration, function()
            caster:SetForwardVector(forwardVec)
            caster:CastLastSpurt()
        end)
    else
        Timers:CreateTimer(0.25 , function()
            if not caster:IsAlive() then
                return
            end
            caster:ShootArrow({
                Position = position,
                AoE = aoe,
                Delay = 0.2,
                Effect = effect,
                Facing = facing,
                Stun = 0,
            })
        end)
        Timers:CreateTimer(duration, function()
            caster:SetForwardVector(forwardVec)
        end)
    end
end

--[[function atalanta_crossing_arcadia:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self
    local position = self:GetCursorPosition()
    local origin = caster:GetOrigin()

    if not IsInSameRealm(origin, position) then
        self:RefundManaCost()
        self:EndCooldown()
	return
    end

    local forwardVector = caster:GetForwardVector()
    local duration = self:GetSpecialValueFor("jump_time")
    local landDuration = self:GetSpecialValueFor("land_time")
    local hangTime = self:GetSpecialValueFor("hang_time")
    local stunDuration = self:GetSpecialValueFor("stun_duration")
    local initialDelta = Vector(0, 0, 70)
    local gravity = Vector(0, 0, 3)

    giveUnitDataDrivenModifier(caster, caster, "jump_pause", duration + landDuration + hangTime)

    local tick = 0
    local tickInterval = 0.033
    local totalTicks = duration / tickInterval
    local jumpVector = (position - origin) / totalTicks + initialDelta
    local downVector = Vector(0, 0, -1.5) / totalTicks

    Timers:CreateTimer(function()
    tick = tick + 1

        if tick >= totalTicks then
            return
        end

    caster:SetOrigin(caster:GetOrigin() + jumpVector)
    caster:SetForwardVector(caster:GetForwardVector() + downVector)
    jumpVector = jumpVector - gravity

    return tickInterval
    end)

    local aoe = self:GetAOERadius()
    local effect = "particles/units/heroes/hero_enchantress/enchantress_impetus.vpcf"
    local facing = caster:GetForwardVector() + Vector(0, 0, -2)
    if caster.CrossingArcadiaPlusAcquired then
        local offset = 0.7071 * aoe - 50
        Timers:CreateTimer(duration + 0.1, function()
            if not caster:IsAlive() then
                return
            end
            caster:ShootArrow({
                Position = position + Vector(-offset, -offset, 0),
                AoE = aoe,
                Delay = 0.2,
                Effect = effect,
                Facing = facing,
                Stun = stunDuration,
            })
        end)

        Timers:CreateTimer(duration + 0.2, function()
            if not caster:IsAlive() then
                return
            end
            caster:ShootArrow({
                Position = position + Vector(offset, -offset, 0),
                AoE = aoe,
                Delay = 0.2,
                Effect = effect,
                Facing = facing,
                Stun = stunDuration,
                DontUseArrow = true
            })
        end)

        Timers:CreateTimer(duration + 0.3, function()
            if not caster:IsAlive() then
                return
            end
            caster:ShootArrow({
                Position = position + Vector(0, aoe - 50, 0),
                AoE = aoe,
                Delay = 0.2,
                Effect = effect,
                Facing = facing,
                Stun = stunDuration,
                DontUseArrow = true
            })
        end)
    else
        Timers:CreateTimer(duration + 0.1, function()
            if not caster:IsAlive() then
                return
            end
            caster:ShootArrow({
                Position = position,
                AoE = aoe,
                Delay = 0.2,
                Effect = effect,
                Facing = facing,
                Stun = stunDuration,
            })
        end)
    end

    Timers:CreateTimer(duration + hangTime, function()
        caster:SetForwardVector(forwardVector)
        self:Land(landDuration)
    end)
end]]

function atalanta_crossing_arcadia:Land(duration)
    local caster = self:GetCaster()
    local ability = self
    local origin = caster:GetOrigin()
    local position = GetGroundPosition(origin, caster)

    local tick = 1
    local tickInterval = 0.033
    local totalTicks = duration / tickInterval
    local jumpVector = (position - origin)
    local tickVector = jumpVector / totalTicks

    Timers:CreateTimer(function()
    tick = tick + 1
    caster:SetOrigin(caster:GetOrigin() + tickVector)
    
        if tick >= totalTicks then
            caster:SetOrigin(GetGroundPosition(caster:GetOrigin(), caster))
            FindClearSpaceForUnit(caster, caster:GetOrigin(), true)
            if caster.CrossingArcadiaPlusAcquired then
                caster:CastLastSpurt()
            end
            return
        end

    return tickInterval
    end)
end

function atalanta_crossing_arcadia:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end

function atalanta_crossing_arcadia:GetAbilityTextureName()
    return "custom/atalanta_crossing_arcadia"
end