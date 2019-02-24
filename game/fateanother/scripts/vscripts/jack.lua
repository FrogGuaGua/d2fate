

function OnMissThink(caster)
    ProjectileManager:ProjectileDodge(caster)
    Timers:CreateTimer(0.2,function()
        ProjectileManager:ProjectileDodge(caster)
    end)
end

function JackCheckCombo(caster)
	if caster:GetStrength() >= 19.1 and caster:GetAgility() >= 19.1 and caster:GetIntellect() >= 19.1 then
		if caster:FindAbilityByName("jack_the_mist"):IsCooldownReady() then
			caster:SwapAbilities("jack_surgery", "jack_the_mist", false, true) 
			Timers:CreateTimer({
				endTime = 5,
				callback = function()
				caster:SwapAbilities("jack_surgery", "jack_the_mist", true, false) 
			end
			})			
		end
	end
end

function AddMairaCurseCount(keys)
    local target = keys.target
    local currentStack = target:GetModifierStackCount("modifier_curse_maria", keys.ability)
    if keys.target:HasModifier("modifier_curse_maria") then 
        keys.target:SetModifierStackCount("modifier_curse_maria", keys.ability, currentStack + 1)
        ParticleManager:SetParticleControl( target.cursefx, 1, Vector( 0, currentStack + 1, 0 ) )
    end	
end

function OnBackstabAttackLanded(keys)
    local target=keys.target
    local caster=keys.caster
    local ability=keys.ability
    if  (not IsFacingUnit(target, caster, 240)) and (not caster:HasModifier("modifier_backstab_cooldown")) then
        DoDamage(keys.caster, target,caster:GetAttackDamage() * keys.Radio, DAMAGE_TYPE_PURE, 0, keys.ability, false)
        giveUnitDataDrivenModifier(caster,target, "stunned", 0.1)
        giveUnitDataDrivenModifier(caster,target, "silenced", keys.Duration)
        ability:ApplyDataDrivenModifier(caster,caster, "modifier_backstab_aspd", {})
        if caster.IsUshiroAcquired == true then
            ability:ApplyDataDrivenModifier(caster,caster, "modifier_backstab_cooldown", {duration = 1.0})
            ability:StartCooldown(1.0)
        else
            ability:ApplyDataDrivenModifier(caster,caster, "modifier_backstab_cooldown", {duration = 5.0})
            ability:StartCooldown(5.0)
        end
        AddMairaCurseCount(keys)    
        target:EmitSound("Jack.BackHit")
        if caster.IsInformationErasureAcquired then
            OnMissThink(caster)
        end
        local Fx2 = ParticleManager:CreateParticle( "particles/econ/items/riki/riki_immortal_ti6/riki_immortal_ti6_blinkstrike_r_backstab_hit_blood.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
        ParticleManager:SetParticleControl( Fx2, 3, target:GetAbsOrigin() )
        Timers:CreateTimer(2.0,function()
            ParticleManager:DestroyParticle( Fx2, false )
            ParticleManager:ReleaseParticleIndex( Fx2 )
        end)
	end
end



function OnSurgeryStart(keys)
    local target =keys.target
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local heal = keys.heal
    local ability = keys.ability
    if target:GetName() == "npc_dota_ward_base" then 
		keys.ability:EndCooldown()
		caster:GiveMana(keys.ability:GetManaCost(1))
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Be_Cast_Now")
		return
    end
    
    if target:GetTeamNumber() == caster:GetTeamNumber() then
        JackCheckCombo(caster)
        local healthdiff = (target:GetMaxHealth()-target:GetHealth()) * 0.3
        heal = healthdiff + 300
        target:AddNewModifier(caster, caster, "modifier_stunned", {Duration = keys.mini_stun})
        target:ApplyHeal(heal, caster)
        keys.ability:ApplyDataDrivenModifier(caster,target,"modifier_surgery_slow",{Duration = 1.5})
    else
        keys.ability:ApplyDataDrivenModifier(caster,target,"modifier_surgery_slow",{Duration = 1.5})
        keys.ability:ApplyDataDrivenModifier(caster,target,"modifier_surgery_enemy",{Duration = 5})
        target:AddNewModifier(caster, caster, "modifier_stunned", {Duration = keys.mini_stun})
        AddMairaCurseCount(keys)
    end
    caster:EmitSound("Jack.Surgery")
end

function OnSurgeryTick(keys)
    local caster = keys.caster
	local target = keys.target
    local damage = (target:GetMaxHealth()-target:GetHealth()) * 0.1
    if caster.IsFemaleSlayerAcquired and IsFemaleServant(target) then
        damage = damage + 100
    end
    if caster.IsMurderAcquired then
        damage = damage + 75
    end
    DoDamage(keys.caster, keys.target,damage, DAMAGE_TYPE_PURE, 0, keys.ability, false)
end

function OnSnakeStepStart(keys)
    local caster = keys.caster
    local ability= keys.ability
    local point  = caster:GetAbsOrigin()
    local casterfacing = -caster:GetForwardVector()
    local active = Physics:Unit(caster)
    local angle = 120
    local increment_factor = 30
    local destination = point + casterfacing
    giveUnitDataDrivenModifier(caster, caster, "jump_pause", 0.3)
    caster:EmitSound("Jack.Q")
    if caster.IsInformationErasureAcquired then
        OnMissThink(caster)
    end
    local Fx1 = ParticleManager:CreateParticle( "particles/units/heroes/hero_grimstroke/grimstroke_cast_ink_swell.vpcf", PATTACH_CUSTOMORIGIN, caster )
    ParticleManager:SetParticleControl( Fx1, 0, caster:GetAbsOrigin() )
    local vc= caster:GetForwardVector()
    ParticleManager:SetParticleControlForward( Fx1, 0, Vector(vc.x,-vc.y,-vc.z))
    Timers:CreateTimer(0.8,function()
        ParticleManager:DestroyParticle( Fx1, false )
        ParticleManager:ReleaseParticleIndex( Fx1 )
    end)
    local knife =
	{
		Ability = keys.ability,
		EffectName = "",
		iMoveSpeed = 3000,
		vSpawnOrigin = caster:GetAbsOrigin(),
		fDistance = 100,
		Source = caster,
		fStartRadius = 75,
        fEndRadius = 75,
		bHasFrontialCone = true,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_ALL,
		fExpireTime = GameRules:GetGameTime() + 0.4,
		bDeleteOnHit = false,
		vVelocity = 0,
	}
    local count = 0 

    Timers:CreateTimer( function()
        if count == 9 then return end
        local newpoint = - point
        local theta = ( angle - count * increment_factor ) * math.pi / 180
        local px = math.cos( theta ) * ( destination.x - newpoint.x ) - math.sin( theta ) * ( destination.y - newpoint.y ) + newpoint.x
        local py = math.sin( theta ) * ( destination.x - newpoint.x ) + math.cos( theta ) * ( destination.y - newpoint.y ) + newpoint.y

        local new_forward = ( Vector( px, py, newpoint.z ) - newpoint ):Normalized()
        knife.vVelocity = new_forward * 3000
        knife.fExpireTime = GameRules:GetGameTime() + 0.4
        local projectile = ProjectileManager:CreateLinearProjectile(knife)
        count = count + 1        
        return 0.01
    end
)
    casterfacing = -caster:GetForwardVector()
    caster:PreventDI(false)
    caster:SetPhysicsVelocity(Vector(0,0,0))
    caster:OnPhysicsFrame(nil)
    caster:PreventDI()
    caster:SetPhysicsFriction(0)
    caster:SetPhysicsVelocity(casterfacing:Normalized() * 1200)
    caster:SetNavCollisionType(PHYSICS_NAV_BOUNCE)
    caster:OnPhysicsFrame(function(unit)
        local unitOrigin = unit:GetAbsOrigin()
        local diff = unitOrigin - point
        local n_diff = diff:Normalized()
        unit:SetPhysicsVelocity(unit:GetPhysicsVelocity():Length() * n_diff)
        if diff:Length() > keys.range then 
            unit:PreventDI(false)
			unit:SetPhysicsVelocity(Vector(0,0,0))
			unit:OnPhysicsFrame(nil)
            FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
            keys.ability:ApplyDataDrivenModifier( caster, caster, "jack_snake_step_rapid", {} )
            if caster.IsInformationErasureAcquired then
                OnMissThink(caster)
            end
        end
    end)
    caster:OnPreBounce(function(unit, normal) -- stop the pushback when unit hits wall
		unit:SetBounceMultiplier(0)
		unit:PreventDI(false)
        unit:SetPhysicsVelocity(Vector(0,0,0))
        FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
    end)
    keys.ability:ApplyDataDrivenModifier( caster, caster, "jack_snake_step_used", {} )

    caster:SwapAbilities("jack_snake_raid", "jack_snake_step", true, false) 
    caster.issnakechainend = false
    Timers:RemoveTimer('jack_snake_chain')

    caster:EmitSound("Jack.ShadowStrike")
end


function OnSnakeStepHit(keys)
    local target = keys.target
    local damage = keys.damage
    local mini_stun = keys.mini_stun
    DoDamage(keys.caster, target,damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
    target:AddNewModifier(caster, caster, "modifier_stunned", {Duration = mini_stun})

end


function OnSnakeUpgrade(keys)
    local ability = keys.caster:FindAbilityByName("jack_snake_step")
    ability:SetLevel(keys.ability:GetLevel())
    local ability2= keys.caster:FindAbilityByName("jack_shadow_strike")
    ability2:SetLevel(keys.ability:GetLevel())
end

function OnSnakeRaidStart(keys)
    local caster = keys.caster
	local ability = keys.ability
	local ply = caster:GetPlayerOwner()
	local forward = ( keys.target_points[1] - caster:GetAbsOrigin() ):Normalized() -- caster:GetForwardVector() 
	local origin = caster:GetAbsOrigin()
    local destination = origin + forward
    if (math.abs(destination.x - origin.x) < 0.01) and (math.abs(destination.y - origin.y) < 0.01) then
		destination = caster:GetForwardVector() + caster:GetAbsOrigin()
    end
    ability:ApplyDataDrivenModifier( caster, caster, "jack_on_charge", {} )
    local snake =
	{
		Ability = keys.ability,
		EffectName = "",
		iMoveSpeed = 1500,
		vSpawnOrigin = caster:GetAbsOrigin(),
		fDistance = 700,
		Source = caster,
		fStartRadius = 75,
        fEndRadius = 75,
		bHasFrontialCone = true,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		fExpireTime = GameRules:GetGameTime() + 0.4,
		bDeleteOnHit = true,
		vVelocity = forward * 1500
	}
    local projectile = ProjectileManager:CreateLinearProjectile(snake)
    
    local sin = Physics:Unit(caster)
    caster:PreventDI()
    caster:SetPhysicsFriction(0)
    caster:SetPhysicsVelocity(forward:Normalized() * 1500)
    caster:SetNavCollisionType(PHYSICS_NAV_BOUNCE)
    caster:OnPhysicsFrame(function(unit)
        local unitOrigin = unit:GetAbsOrigin()
        local diff = unitOrigin - origin
        local n_diff = diff:Normalized()
        unit:SetPhysicsVelocity(unit:GetPhysicsVelocity():Length() * n_diff)
        if diff:Length() > keys.range then 
            unit:PreventDI(false)
			unit:SetPhysicsVelocity(Vector(0,0,0))
			unit:OnPhysicsFrame(nil)
            FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
            keys.ability:ApplyDataDrivenModifier( caster, caster, "jack_snake_step_rapid", {} )
        end
    end)
    caster:OnPreBounce(function(unit, normal) -- stop the pushback when unit hits wall
		unit:SetBounceMultiplier(0)
		unit:PreventDI(false)
        unit:SetPhysicsVelocity(Vector(0,0,0))
        FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
    end)
    

end



function OnSnakeRaidHit(keys)
    local target = keys.target
    local damage = keys.damage
    local mini_stun = keys.mini_stun
    local caster = keys.caster
    local ability = keys.ability
    DoDamage(keys.caster, target,damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
    if caster.IsMurderAcquired == true then
        caster:PerformAttack( target, true, true, true, true, false, false, true )
    end
    if caster.IsInformationErasureAcquired then
        OnMissThink(caster)
    end
    caster:RemoveModifierByName("jack_on_charge")
    if caster.IsFemaleSlayerAcquired and IsFemaleServant(target) then
        DoDamage(caster, target, damage*0.2, DAMAGE_TYPE_PURE, 0, ability, false)
    end
    if not caster:HasModifier("jack_flash_buff") then
        ability:EndCooldown()
        keys.ability:ApplyDataDrivenModifier(caster, caster, "jack_flash_buff", {})
    end
    target:EmitSound("Jack.Q")
    local Fx1 = ParticleManager:CreateParticle( "particles/units/heroes/hero_grimstroke/grimstroke_cast_ink_swell.vpcf", PATTACH_CUSTOMORIGIN, target )
    ParticleManager:SetParticleControl( Fx1, 0, target:GetAbsOrigin() )
    local vc= caster:GetForwardVector()
    vc = -vc
    ParticleManager:SetParticleControlForward( Fx1, 0, vc)
    Timers:CreateTimer(0.8,function()
        ParticleManager:DestroyParticle( Fx1, false )
        ParticleManager:ReleaseParticleIndex( Fx1 )
    end)
    AddMairaCurseCount(keys)
    target:AddNewModifier(caster, caster, "modifier_stunned", {Duration = mini_stun})
    caster:SetBounceMultiplier(0)
    caster:PreventDI(false)
    caster:SetPhysicsVelocity(Vector(0,0,0))
    
    

    local targetpoint = target:GetAbsOrigin()
    --giveUnitDataDrivenModifier(caster, caster, "jump_pause", 0.3)

    local jack = Physics:Unit(caster)
    local dist = (targetpoint - caster:GetAbsOrigin()):Normalized()
    local origin = caster:GetAbsOrigin()
    caster:SetPhysicsFriction(0)
    caster:SetPhysicsVelocity(dist*2300)
    caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
    caster:FollowNavMesh(false)	
    caster:SetAutoUnstuck(false)
    keys.ability:ApplyDataDrivenModifier( caster, caster, "jack_snake_step_rapid", {} )

    caster:OnPhysicsFrame(function(unit)
        local unitOrigin = unit:GetAbsOrigin()
        local diff = unitOrigin - origin
        local n_diff = diff:Normalized()
        unit:SetPhysicsVelocity(unit:GetPhysicsVelocity():Length() * n_diff)
        if diff:Length() > 250 then 
            unit:PreventDI(false)
			unit:SetPhysicsVelocity(Vector(0,0,0))
			unit:OnPhysicsFrame(nil)
            FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
            keys.ability:ApplyDataDrivenModifier( caster, caster, "jack_snake_step_rapid", {} )
        end
    end)
    --local ability2 = caster:FindAbilityByName("jack_snake_step")
    --if ability2:IsCooldownReady() and target:IsHero() then 
        --caster:SwapAbilities("jack_snake_step", "jack_snake_raid", true, false) 
        --caster.issnakechainend = true
       -- Timers:CreateTimer('jack_snake_chain',{
           -- endTime = 0.05 ,
         --   callback = function()
        --    local currentAbil = caster:GetAbilityByIndex(1)
        --    if currentAbil:GetAbilityName() ~= "jack_snake_step" or caster.issnakechainend then
         --       caster:SwapAbilities("jack_snake_raid", "jack_snake_step", true, false) 
       --         caster.issnakechainend = false
         --   end
      --   end})

        caster:OnPreBounce(function(unit, normal) -- stop the pushback when unit hits wall
		    caster:SetBounceMultiplier(0)
		    caster:PreventDI(false)
            caster:SetPhysicsVelocity(Vector(0,0,0))
            FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
        end)
end



function OnWaspStingStart(keys)
    local target=keys.target
    local caster=keys.caster
    local origin = caster:GetAbsOrigin()
    local targetabs = target:GetAbsOrigin()
    local diff=(origin-targetabs):Length2D()
    local damage  = keys.damage
    local mini_stun = keys.mini_stun
    local atk = caster:GetAttackDamage()
    damage = damage / 2 + atk
    if caster.IsMurderAcquired then
        damage = damage + 50
    end
    if diff <= 325 then
        if target:GetMaxHealth() * 0.35 > target:GetHealth()  then
            damage = damage * 2
        end
        target:EmitSound("Jack.W")
        local b1= ParticleManager:CreateParticle( "particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta_blood_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
        ParticleManager:SetParticleControl( b1, 1, target:GetAbsOrigin() + Vector(0, 0, 250) )
        ParticleManager:SetParticleControl( b1, 2, target:GetAbsOrigin() + Vector(0, 0, 250) )
        ParticleManager:SetParticleControl( b1, 3, target:GetAbsOrigin() + Vector(0, 0, 250) )
        Timers:CreateTimer(0.8,function()
            ParticleManager:DestroyParticle( b1, false )
            ParticleManager:ReleaseParticleIndex( b1 )
        end)

        AddMairaCurseCount(keys)
        if caster:HasModifier("jack_maria_the_ripper_start") then
            caster:RemoveModifierByName("jack_maria_the_ripper_start")
            target.cursefx =  ParticleManager:CreateParticle( "particles/custom/jack/maria_the_ripper_curse.vpcf", PATTACH_CUSTOMORIGIN, target )
            ParticleManager:SetParticleControlEnt( target.cursefx, 0, target, PATTACH_POINT_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true )
            ParticleManager:SetParticleControl( target.cursefx, 1, Vector( 0, 1, 0 ) )
            caster.cursetarget = target
            keys.ability:ApplyDataDrivenModifier( caster, target, "modifier_curse_maria_tigger", {})
            keys.ability:ApplyDataDrivenModifier( caster, target, "modifier_curse_maria", {})
            caster:FindAbilityByName("jack_wasp_sting"):EndCooldown()
            caster:FindAbilityByName("jack_wasp_sting"):StartCooldown(0.3)
            target:SetModifierStackCount("modifier_curse_maria", keys.ability, 1)
            caster.oncurseeffect = true
            caster:SwapAbilities("jack_maria_the_ripper", "jack_maria_curse_tigger", false, true) 
            Timers:CreateTimer('jack_maria_curse',{
                endTime = 7.05,
                callback = function()
                    ParticleManager:DestroyParticle( target.cursefx, true )
                    ParticleManager:ReleaseParticleIndex( target.cursefx )
                    target.cursefx = nil
                    local currentAbil = caster:GetAbilityByIndex(6)
                    if currentAbil:GetAbilityName() ~= "jack_maria_the_ripper" or caster.oncurseeffect then
                        caster:SwapAbilities("jack_maria_curse_tigger", "jack_maria_the_ripper", false, true) 
                        caster.oncurseeffect = false
                    end
            end})
            caster:EmitSound("Jack.MariaTheRipperStart")
            local p = caster:GetPlayerOwner()
            EmitSoundOnClient("Jack.CurseEffect",p)
            caster:EmitSound("Jack.CurseEffect")
        end

        if IsRevoked(target) then
            DoDamage(caster , target, damage - atk, DAMAGE_TYPE_PURE, 0, keys.ability, false)
            caster:PerformAttack( target, true, true, true, true, false, false, true )
            if caster.IsFemaleSlayerAcquired and IsFemaleServant(target) then
                DoDamage(caster, target, damage*0.3, DAMAGE_TYPE_PURE, 0, ability, false)
            end
            target:AddNewModifier(caster, caster, "modifier_stunned", {Duration = mini_stun})
            Timers:CreateTimer(0.1,function()
                DoDamage(caster , target , damage - atk, DAMAGE_TYPE_PURE, 0, keys.ability, false)
                caster:PerformAttack( target, true, true, true, true, false, false, true )
                if caster.IsFemaleSlayerAcquired and IsFemaleServant(target) then
                    DoDamage(caster, target, damage*0.3, DAMAGE_TYPE_PURE, 0, ability, false)
                end
                target:AddNewModifier(caster, caster, "modifier_stunned", {Duration = mini_stun})
            end)
        else
            DoDamage(caster,target,damage - atk, DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)
            caster:PerformAttack( target, true, true, true, true, false, false, true )
            if caster.IsFemaleSlayerAcquired and IsFemaleServant(target) then
                DoDamage(caster, target, damage*0.3, DAMAGE_TYPE_PURE, 0, ability, false)
            end
            target:AddNewModifier(caster, caster, "modifier_stunned", {Duration = mini_stun})
            Timers:CreateTimer(0.1,function()
                DoDamage(caster , target , damage - atk, DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)
                caster:PerformAttack( target, true, true, true, true, false, false, true )
                if caster.IsFemaleSlayerAcquired and IsFemaleServant(target) then
                    DoDamage(caster, target, damage*0.3, DAMAGE_TYPE_PURE, 0, ability, false)
                end
                target:AddNewModifier(caster, caster, "modifier_stunned", {Duration = mini_stun})
            end) 
        end  
    else
        local info = {
            Target = target,
            Source = caster, 
            Ability = keys.ability,
            EffectName = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger.vpcf",
            vSpawnOrigin = caster:GetAbsOrigin(),
            iMoveSpeed = 1700
        }
        ProjectileManager:CreateTrackingProjectile(info) 
    end

end

function OnWaspStingHit(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local target = keys.target
    local mini_stun =keys.mini_stun
	keys.target:TriggerSpellReflect(keys.ability)
    if IsSpellBlocked(keys.target) then return end -- Linken effect checker
    local damage = keys.damage
    if caster.IsMurderAcquired then
        damage = damage + 100
    end
    --local ability = keys.ability
    if caster.IsUshiroAcquired == true then
        DoDamage(caster,target, caster:GetAttackDamage(), DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)
    end
    damage = damage + ((target:GetMaxHealth() - target:GetHealth())*0.16)
    DoDamage(caster,target, damage, DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)
    if caster.IsFemaleSlayerAcquired and IsFemaleServant(target) then
        DoDamage(caster, target, (damage+caster:GetAttackDamage()) *0.2, DAMAGE_TYPE_PURE, 0, keys.ability, false)
    end
    local Fx1 = ParticleManager:CreateParticle( "particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta_blood_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
    ParticleManager:SetParticleControl( Fx1, 1, target:GetAbsOrigin() + Vector(0, 0, 100) )
    ParticleManager:SetParticleControl( Fx1, 2, target:GetAbsOrigin() + Vector(0, 0, 100) )
    ParticleManager:SetParticleControl( Fx1, 3, target:GetAbsOrigin() + Vector(0, 0, 100) )
    Timers:CreateTimer(0.8,function()
        ParticleManager:DestroyParticle( Fx1, false )
        ParticleManager:ReleaseParticleIndex( Fx1 )
    end)
    target:EmitSound("Jack.W")
    target:AddNewModifier(caster, caster, "modifier_stunned", {Duration = mini_stun})
    AddMairaCurseCount(keys)
    if caster:HasModifier("jack_maria_the_ripper_start") then
        caster:RemoveModifierByName("jack_maria_the_ripper_start")
        caster.cursetarget = target
        keys.ability:ApplyDataDrivenModifier( caster, target, "modifier_curse_maria_tigger", {})
        keys.ability:ApplyDataDrivenModifier( caster, target, "modifier_curse_maria", {})
        --caster:FindAbilityByName("jack_wasp_sting"):EndCooldown()
        target:SetModifierStackCount("modifier_curse_maria", keys.ability, 1)
        caster:EmitSound("Jack.MariaTheRipperStart")
        target.cursefx =  ParticleManager:CreateParticle( "particles/custom/jack/maria_the_ripper_curse.vpcf", PATTACH_CUSTOMORIGIN, target )
		ParticleManager:SetParticleControlEnt( target.cursefx, 0, target, PATTACH_POINT_FOLLOW, "attach_origin", caster:GetAbsOrigin() , true )
        ParticleManager:SetParticleControl( target.cursefx, 1, Vector( 0, 1, 0 ) )
        if caster.stingtarget ~= nil then caster.stingtarget = nil end
        caster.stingtarget = target

        caster:SwapAbilities("jack_wasp_sting", "jack_shadow_strike", false, true) 
        caster.isstingchainend = true
        Timers:CreateTimer('jack_sting_chain',{
            endTime = 3 ,
            callback = function()
                local currentAbil = caster:GetAbilityByIndex(2)
                if currentAbil:GetAbilityName() ~= "jack_wasp_sting" or caster.issnakechainend then
                    caster:SwapAbilities("jack_shadow_strike", "jack_wasp_sting", false, true) 
                    caster.isstingchainend = false
                    if caster.stingtarget ~= nil then caster.stingtarget = nil end
                end
        end})
        caster.oncurseeffect = true
        caster:SwapAbilities("jack_maria_the_ripper", "jack_maria_curse_tigger", false, true) 
        Timers:CreateTimer('jack_maria_curse',{
            endTime = 7.05,
            callback = function()
                ParticleManager:DestroyParticle( target.cursefx, true )
                ParticleManager:ReleaseParticleIndex( target.cursefx )
                target.cursefx = nil
                local currentAbil = caster:GetAbilityByIndex(6)
                if currentAbil:GetAbilityName() ~= "jack_maria_the_ripper" or caster.oncurseeffect then
                    caster:SwapAbilities("jack_maria_curse_tigger", "jack_maria_the_ripper", false, true) 
                    caster.oncurseeffect = false
                end
        end})
    end

end

function OnShadowStrikeStart(keys)
    local caster = keys.caster
    local target = caster.stingtarget
    local ability = keys.ability
    local targetabs = target:GetAbsOrigin()
    local casterabs = caster:GetAbsOrigin()
    local distance = (targetabs - casterabs):Length2D()
    if caster.IsMurderAcquired then
        keys.damage = keys.damage + 75    
    end
    if target:HasModifier("modifier_curse_maria") then 
        local currentStack = target:GetModifierStackCount("modifier_curse_maria", keys.ability)
        target:SetModifierStackCount("modifier_curse_maria", keys.ability, currentStack + 1)
    end	
    if distance <= 3000 and target:IsAlive() then
        caster:SetAbsOrigin(targetabs - target:GetForwardVector():Normalized()*100)
        DoDamage(caster,target, keys.damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
        caster:PerformAttack( target, true, true, true, true, false, false, true )
        target:AddNewModifier(caster, caster, "modifier_stunned", {Duration = keys.mini_stun})
        local Fx1 = ParticleManager:CreateParticle( "particles/units/heroes/hero_grimstroke/grimstroke_cast_ink_swell.vpcf", PATTACH_CUSTOMORIGIN, target )
        ParticleManager:SetParticleControl( Fx1, 0, target:GetAbsOrigin() )
        local vc= target:GetForwardVector()
        ParticleManager:SetParticleControlForward( Fx1, 0, vc)
        Timers:CreateTimer(0.8,function()
            ParticleManager:DestroyParticle( Fx1, false )
            ParticleManager:ReleaseParticleIndex( Fx1 )
        end)
    end
    if caster.IsInformationErasureAcquired then
        OnMissThink(caster)
    end
    if caster.IsFemaleSlayerAcquired and IsFemaleServant(target) then
        DoDamage(caster, target, keys.damage*0.2, DAMAGE_TYPE_PURE, 0, ability, false)
    end
    caster.stingtarget = nil
    target:EmitSound("Jack.BackHit")
    caster:SwapAbilities("jack_shadow_strike", "jack_wasp_sting", false, true) 
    Timers:RemoveTimer('jack_sting_chain')
end

function GetBwteenPoint(startpoint,endpoint,distance)
    local normal = (startpoint - endpoint):Normalized()
    local retpoint = normal * distance + startpoint
    return retpoint
end


function OnBatGrabStart(keys)               -- unuse
    local target = keys.target              --discard
    local caster = keys.caster
    local jack   = Physics:Unit(caster)
    local origin = caster:GetAbsOrigin()
    local targetpoint = target:GetAbsOrigin()
    local casterfacing = caster:GetForwardVector()
    local diff = targetpoint - origin
    local line1 = diff:Length() * 0.25     -- this is distance
    local line2 = diff:Length() * 0.6
    local line3 = diff:Length() * 0.95
    local point1 = GetBwteenPoint(origin,targetpoint,line1)
    local point2 = GetBwteenPoint(origin,targetpoint,line2)
    local point3 = GetBwteenPoint(origin,targetpoint,line3)
    local jumprange = 700
    local range = ( diff:Length() / 1000 ) * jumprange
    caster:PreventDI()
    caster:SetPhysicsFriction(0)
    local newvector1 = ( point1 - origin):Normalized()
    newvector1= Vector(newvector1.y,-newvector1.x,newvector1.z)
    local realpoint1 = newvector1*600  + point1
    local realvector1 = ( origin - realpoint1 ):Normalized()       -- point 1 case


    local newvector2 = -newvector1
    local realpoint2 = newvector2 * 800 + point2                 --point 2 case


    caster:SetPhysicsVelocity(realvector1*1500)
    caster:SetNavCollisionType(PHYSICS_NAV_BOUNCE)
    caster:OnPhysicsFrame(function(unit)
        local unitOrigin = unit:GetAbsOrigin()
        local difff = unitOrigin - origin
        local n_diff = difff:Normalized()
        unit:SetPhysicsVelocity(unit:GetPhysicsVelocity():Length() * n_diff)
        if difff:Length() > line1 then 
            unit:PreventDI(false)
			unit:SetPhysicsVelocity(Vector(0,0,0))
			unit:OnPhysicsFrame(nil)
            --keys.ability:ApplyDataDrivenModifier( caster, caster, "jack_snake_step_rapid", {} )
            local neworrgin = caster:GetAbsOrigin()
            local realvector2 = (origin - realpoint2):Normalized()
            caster:SetPhysicsVelocity(realvector2*1500)
            caster:SetNavCollisionType(PHYSICS_NAV_BOUNCE)
            caster:OnPhysicsFrame(function(unit)
                local unitOrigin1 = unit:GetAbsOrigin()
                local diff1=unitOrigin1-neworrgin
                unit:SetPhysicsVelocity(unit:GetPhysicsVelocity():Length() * n_diff1)
                if diff1:Length() > line2 then
                    unit:PreventDI(false)
                    unit:SetPhysicsVelocity(Vector(0,0,0))
                    unit:OnPhysicsFrame(nil)
                end 
            end
            )
        end
    end)
    
    



    


    

end



function OnBatGrabLevelUp(keys)  --discard
    
end




function OnBatFallenStart(keys)
    local caster = keys.caster
    local damage = keys.damage
    local mini_stun=keys.mini_stun
    local count = 0
    local ability = keys.ability
    --print(targets)
    if caster.IsInformationErasureAcquired then
        OnMissThink(caster)
    end
    if caster.IsMurderAcquired then
        damage = damage + 100
    end
    local bodyFxIndex = ParticleManager:CreateParticle("particles/econ/events/fall_major_2015/teleport_end_fallmjr_2015_lvl2_black_b.vpcf",PATTACH_CUSTOMORIGIN_FOLLOW, caster )
    ParticleManager:SetParticleControl(bodyFxIndex, 3, caster:GetAbsOrigin()+Vector(0,0,400))
    Timers:CreateTimer(0.7,function()
        
        giveUnitDataDrivenModifier(caster, caster, "jump_pause", 0.7)
        --caster:Cancel()
        StartAnimation(caster, {duration=0.7, activity=ACT_DOTA_CAST_ABILITY_3, rate=0.7})
    end)
    Timers:CreateTimer(1.4,function()
        ParticleManager:DestroyParticle( bodyFxIndex, false )
        ParticleManager:ReleaseParticleIndex( bodyFxIndex )
        if caster:IsAlive() then         
            keys.ability:ApplyDataDrivenModifier(caster,caster,"jack_bat_fallen",{Duration = 3.0})    
            local origin = caster:GetAbsOrigin()
            local targets = FindUnitsInRadius(caster:GetTeam(), origin, nil,keys.ratio, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
            local count = 0
        --print(targets)
            for k,v in pairs(targets) do
                DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
                if caster.IsFemaleSlayerAcquired and IsFemaleServant(v) then
                      DoDamage(caster, v, damage*0.2, DAMAGE_TYPE_PURE, 0, ability, false)
                end
                count = count + 1
                v:AddNewModifier(caster, caster, "modifier_stunned", {Duration = keys.mini_stun})
            end
            if count == 1 then
                DoDamage(caster, targets[1], damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
                if caster.IsFemaleSlayerAcquired and IsFemaleServant(targets[1]) then
                      DoDamage(caster, targets[1], damage*0.2, DAMAGE_TYPE_PURE, 0, ability, false)
                end
            end
            if caster.IsInformationErasureAcquired then
               OnMissThink(caster)
            end
            local radius = keys.ratio
            local circleFxIndex = ParticleManager:CreateParticle( "particles/econ/items/legion/legion_overwhelming_odds_ti7/legion_commander_odds_ti7_ground_pillar_black.vpcf", PATTACH_CUSTOMORIGIN, caster )
            ParticleManager:SetParticleControl( circleFxIndex, 0, caster:GetAbsOrigin() )
            caster:EmitSound("Jack.BatFallen")
         end
    end)
end

function MRSound(keys)
    local caster = keys.caster
    local soundindex = RandomInt(1,4)
    if soundindex == 3 or soundindex == 4 then caster:EmitSound("Jack.MariaTheRipperCast2") 
    else 
        caster:EmitSound("Jack.MariaTheRipperCast1") 
    end
end

function OnMariaTheRipperStart(keys)
    local caster = keys.caster
    local ability = keys.ability
    local damage = keys.damage
    giveUnitDataDrivenModifier(caster, caster, "modifier_silence", 0.7)
    if caster.IsInformationErasureAcquired then
        ability:ApplyDataDrivenModifier(caster,caster,"modifier_curse_maria_casting",{Duration = 6.7})
    end
    Timers:CreateTimer(0.7,function()
        ability:ApplyDataDrivenModifier(caster,caster,"jack_maria_the_ripper_start",{Duration = 6.0})
    end)
    if caster.IsMurderAcquired then
        caster:FindAbilityByName("jack_wasp_sting"):EndCooldown()
    end 
    caster.cursedamage=damage
    --local skillq = caster:GetAbilityByIndex(0):GetName()
    --if skillq == "jack_snake_step" then
        --caster:SwapAbilities("jack_snake_step", "jack_snake_raid", false, true) 
        --caster.issnakechainend = true
        --Timers:CreateTimer('jack_snake_chain',{
        --endTime = 3 ,
        --callback = function()
            --local currentAbil = caster:GetAbilityByIndex(1)
            --if currentAbil:GetAbilityName() ~= "jack_snake_step" or caster.issnakechainend then
               -- caster:SwapAbilities("jack_snake_raid", "jack_snake_step", false, true) 
               -- caster.issnakechainend = false
            --end
        --end})
    --end
end

function OnCurseTick(keys)
    local caster = keys.caster
    local basedmg = caster.cursedamage
    local target = keys.target
    local ability = keys.ability
    DoDamage(caster, target, basedmg*0.15, DAMAGE_TYPE_MAGICAL, 0, ability, false)
    ---
end


function OnCurseTrigger(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local currentStack = keys.target:GetModifierStackCount("modifier_curse_maria", keys.ability)
    --print(currentStack)
    local basedmg = caster.cursedamage
    local currectdmg = basedmg
    for i=0,currentStack do
        currectdmg = currectdmg * 1.1
    end
    StopSoundEvent("Jack.CurseEffect",caster:GetPlayerOwner())
    
    local i = 0
    if IsFemaleServant(target) then 
        currectdmg = currectdmg * 1.3 
        i = i +1
    end
    if not GameRules:IsDaytime() then 
        currectdmg = currectdmg * 1.3 
        i = i +1
    end
    if target:HasModifier("jack_the_mist_effect") then
        currectdmg = currectdmg * 1.3 
        i = i +1
    end
    -- if in frog then i = i + 1 end


    if i == 3 and not (caster:HasModifier("modifier_max_maria_cd"))then
        DoDamage(caster, target, 30000, DAMAGE_TYPE_MAGICAL, 0, ability, false)
        local bloodfx = ParticleManager:CreateParticleForPlayer("particles/econ/events/killbanners/screen_killbanner_compendium16_firstblood_splatter1.vpcf", PATTACH_MAIN_VIEW, target,target:GetPlayerOwner())
        Timers:CreateTimer(5,function()
            ParticleManager:DestroyParticle( bloodfx, false )
            ParticleManager:ReleaseParticleIndex( bloodfx )
        end)
        EmitGlobalSound("Jack.MAXCURSE")
        ability:ApplyDataDrivenModifier(caster,caster,"modifier_max_maria_cd",{Duration = 20})
    end
    DoDamage(caster, target, currectdmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
    if caster.IsFemaleSlayerAcquired and IsFemaleServant(target) then
        DoDamage(caster, target, currectdmg*0.3, DAMAGE_TYPE_PURE, 0, ability, false)
    end
    if caster.IsMurderAcquired then
        if not GameRules:IsDaytime() then 
            DoDamage(caster, target, currectdmg*0.3, DAMAGE_TYPE_PURE, 0, ability, false)
        end
        if target:HasModifier("jack_the_mist_effect") then
            DoDamage(caster, target, currectdmg*0.3, DAMAGE_TYPE_PURE, 0, ability, false)
        end
    end
    local targetFx = ParticleManager:CreateParticle( "particles/econ/items/dark_willow/dark_willow_ti8_immortal_head/dw_crimson_ti8_immortal_cursed_crownmarker.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
    target:EmitSound("Jack.CurseBaofa")
    Timers:CreateTimer(0.75,function()
        ParticleManager:DestroyParticle( targetFx, false )
        ParticleManager:ReleaseParticleIndex( targetFx )
    end)
    target:RemoveModifierByName("modifier_curse_maria")
end



function OnCurseTargetDeath(keys)
    local caster = keys.caster
    local target = caster.cursetarget
    if target:HasModifier("modifier_curse_maria") then
       target:RemoveModifierByName("modifier_curse_maria_tigger")
       target:RemoveModifierByName("modifier_curse_maria")
       local currentAbil = caster:GetAbilityByIndex(6)
       if currentAbil:GetAbilityName() ~= "jack_maria_the_ripper"  then
           caster:SwapAbilities("jack_maria_curse_tigger", "jack_maria_the_ripper", false, true) 
           caster.oncurseeffect = nil
       end
       Timers:RemoveTimer('jack_maria_curse')
       caster.oncurseeffect = nil
       caster.cursetarget = nil
       caster:EmitSound("Jack.CurseTrigger")
       if target.cursefx ~= nil then
       ParticleManager:DestroyParticle( target.cursefx, true )
       ParticleManager:ReleaseParticleIndex( target.cursefx )
       target.cursefx = nil
       end
    end
end

function OnCurseTargetDestory(keys)
    local caster = keys.caster
    local target = caster.cursetarget
    print("im run")
    local currentAbil = caster:GetAbilityByIndex(6)
    if currentAbil:GetAbilityName() ~= "jack_maria_the_ripper"  then
        caster:SwapAbilities("jack_maria_curse_tigger", "jack_maria_the_ripper", false, true) 
        caster.oncurseeffect = nil
     end
       Timers:RemoveTimer('jack_maria_curse')
       caster.oncurseeffect = nil
       caster.cursetarget = nil
       caster:EmitSound("Jack.CurseTrigger")
       if target.cursefx ~= nil then
       ParticleManager:DestroyParticle( target.cursefx, true )
       ParticleManager:ReleaseParticleIndex( target.cursefx )
       target.cursefx = nil
       end
end

function OnMariaCurseTigger(keys)
    local caster = keys.caster
    local target=caster.cursetarget
    if target:HasModifier("modifier_curse_maria")  then
        target:RemoveModifierByName("modifier_curse_maria_tigger")
        target:RemoveModifierByName("modifier_curse_maria")
    end
end

function OnMariaCurseTiggerOld(keys)
    local caster = keys.caster
    local target = caster.cursetarget
    if target:HasModifier("modifier_curse_maria")  then
        target:RemoveModifierByName("modifier_curse_maria_tigger")
        target:RemoveModifierByName("modifier_curse_maria")
        local currentAbil = caster:GetAbilityByIndex(6)
        if currentAbil:GetAbilityName() ~= "jack_maria_the_ripper"  then
            caster:SwapAbilities("jack_maria_curse_tigger", "jack_maria_the_ripper", false, true) 
            caster.oncurseeffect = nil
        end
        Timers:RemoveTimer('jack_maria_curse')
        caster.oncurseeffect = nil
        caster.cursetarget = nil
        caster:EmitSound("Jack.CurseTrigger")
        if target.cursefx ~= nil then
        ParticleManager:DestroyParticle( target.cursefx, true )
        ParticleManager:ReleaseParticleIndex( target.cursefx )
        target.cursefx = nil
        end
     end
end




function OnInformationErasureAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    local master = hero.MasterUnit
    hero.IsInformationErasureAcquired = true
    hero:FindAbilityByName("jack_information_erasure_passive"):SetLevel(1)
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnNightRemainsAcquired(keys)  ---- discard
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    local master = hero.MasterUnit
    hero.IsOnNightRemainsAcquired = true
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnFemaleSlayerAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    local master = hero.MasterUnit
    hero.IsFemaleSlayerAcquired = true
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnUshiroAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    local master = hero.MasterUnit
    hero.IsUshiroAcquired = true
    hero:FindAbilityByName("jack_backstab"):SetLevel(2)
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnMurderAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    local master = hero.MasterUnit
    hero.IsMurderAcquired = true
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end





