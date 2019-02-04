function OnShotStart(kv)
    local caster = kv.caster
    local targetpoint = kv.target_points[1]
    local ability = kv.ability
    local casterloc=caster:GetAbsOrigin()
    local excal = 
	{
		Ability = kv.ability,
        EffectName = "",
        iMoveSpeed = kv.speed,
        vSpawnOrigin = casterloc,
        fDistance = kv.range,
        fStartRadius = kv.width,
        fEndRadius = kv.width,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 5.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * kv.speed
    }
    local projectile = ProjectileManager:CreateLinearProjectile(excal)
end

function OnShotHit(kv)
    --flayer
    local caster = kv.caster
    local damage =  kv.damage

    local bones_damage = caster:FindModifierByName("modifier_trouble_times_hero"):GetDeadNumber() * (-0.02)
    damage = damage * (1+bones_damage)


    kv.target:AddNewModifier(kv.caster, kv.target, "modifier_stunned", {Duration = kv.stun_duration})
    DoDamage(caster, kv.target, damage , DAMAGE_TYPE_MAGICAL, 0, kv.ability, false)

    local flayer = caster:FindAbilityByName("lvbu_flayer")
    flayer:AddStack(kv.target)
end