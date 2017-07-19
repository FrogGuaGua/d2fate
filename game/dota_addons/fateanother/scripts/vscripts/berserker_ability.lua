function OnFissureStart(keys)
	local caster = keys.caster
	local frontward = caster:GetForwardVector()
	local fiss = 
	{
		Ability = keys.ability,
        EffectName = "particles/custom/berserker/fissure_strike/shockwave.vpcf",
        iMoveSpeed = keys.Speed,
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = keys.Range,
        fStartRadius = keys.Width,
        fEndRadius = keys.Width,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        fExpireTime = GameRules:GetGameTime() + 0.5,
		bDeleteOnHit = false,
		vVelocity = frontward * keys.Speed
	}
	caster.FissureOrigin  = caster:GetAbsOrigin()
	caster.FissureTarget = keys.target_points[1]
	projectile = ProjectileManager:CreateLinearProjectile(fiss)
	BerCheckCombo(caster, keys.ability)
end

function OnFissureHit(keys)
	local caster = keys.caster
	local target = keys.target
	local courageAbility = caster:FindAbilityByName("berserker_5th_courage") 
	if caster:HasModifier("modifier_courage_damage_stack_indicator") then
		keys.Damage = keys.Damage + courageAbility:GetLevelSpecialValueFor("bonus_damage", courageAbility:GetLevel()-1)
		DeductCourageDamageStack(caster)
	end 

	DoDamage(keys.caster, keys.target, keys.Damage , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	if not IsImmuneToSlow(target) then keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_fissure_strike_slow", {}) end

	giveUnitDataDrivenModifier(keys.caster, keys.target, "pause_sealenabled", 0.01)

    local pushTarget = Physics:Unit(target)
    target:PreventDI()
    target:SetPhysicsFriction(0)
	local vectorC = (caster.FissureTarget - caster.FissureOrigin) --knockback in direction as fissure
	-- get the direction where target will be pushed back to
	target:SetPhysicsVelocity(vectorC:Normalized() * 1500)
    target:SetNavCollisionType(PHYSICS_NAV_BOUNCE)
	local initialUnitOrigin = keys.target:GetAbsOrigin()
	
	target:OnPhysicsFrame(function(unit) -- pushback distance check
		local unitOrigin = unit:GetAbsOrigin()
		local diff = unitOrigin - initialUnitOrigin
		local n_diff = diff:Normalized()
		unit:SetPhysicsVelocity(unit:GetPhysicsVelocity():Length() * n_diff) -- track the movement of target being pushed back
		if diff:Length() > 400 then -- if pushback distance is over 400, stop it
			unit:PreventDI(false)
			unit:SetPhysicsVelocity(Vector(0,0,0))
			unit:OnPhysicsFrame(nil)
			FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
		end
	end)
	
	target:OnPreBounce(function(unit, normal) -- stop the pushback when unit hits wall
		unit:SetBounceMultiplier(0)
		unit:PreventDI(false)
		unit:SetPhysicsVelocity(Vector(0,0,0))
		giveUnitDataDrivenModifier(caster, target, "stunned",  caster:FindAbilityByName("berserker_5th_fissure_strike"):GetSpecialValueFor("collide_duration"))
	end)
end

function OnCourageStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local radius = 400
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
		-- Apply armor reduction and damage reduction buff to nearby enemies
		ability:ApplyDataDrivenModifier(caster, v, "modifier_courage_armor_reduction", {}) 
		ability:ApplyDataDrivenModifier(caster, v, "modifier_courage_attack_damage_debuff", {}) 
	end 

	-- Apply stackable speed buff
	local currentStack = caster:GetModifierStackCount("modifier_courage_stackable_buff", keys.ability)
	if currentStack == 0 and caster:HasModifier("modifier_courage_stackable_buff") then 
		currentStack = 1 
	elseif currentStack == keys.MaxStack then 
		currentStack = currentStack-1 
	end

	caster:RemoveModifierByName("modifier_courage_stackable_buff") 
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_courage_stackable_buff", {}) 
	caster:SetModifierStackCount("modifier_courage_stackable_buff", keys.ability, currentStack + 1)

	-- Apply damage buff indicator
	caster:RemoveModifierByName("modifier_courage_damage_stack_indicator")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_courage_damage_stack_indicator", {}) 
	caster:SetModifierStackCount("modifier_courage_damage_stack_indicator", ability, 9)

	-- Apply damage buff
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_courage_attack_damage_buff", {}) 

	-- Reduce Nine Lives cooldown if applicable
	if caster.IsEternalRageAcquired then
		ReduceCooldown(caster:FindAbilityByName("berserker_5th_nine_lives"), 5)
	end

	caster.courage_particle = ParticleManager:CreateParticle("particles/custom/berserker/courage/buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(caster.courage_particle, 1, Vector(currentStack + 1,1,1))
	ParticleManager:SetParticleControl(caster.courage_particle, 3, Vector(radius,1,1))
end

function OnCourageBuffEnded(keys)
	ParticleManager:DestroyParticle(keys.caster.courage_particle, false)
	keys.caster.courage_particle = nil
end

function OnCourageAttackLanded(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	DeductCourageDamageStack(caster)
end

function DeductCourageDamageStack(caster)
	local courageAbility = caster:FindAbilityByName("berserker_5th_courage")
	-- Deduce a stack from damage buff
	local currentStack = caster:GetModifierStackCount("modifier_courage_damage_stack_indicator", courageAbility)
	if currentStack == 1 then
		caster:RemoveModifierByName("modifier_courage_damage_stack_indicator")
	else
		caster:SetModifierStackCount("modifier_courage_damage_stack_indicator", courageAbility, currentStack-1)
	end
end

function OnRoarStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	giveUnitDataDrivenModifier(caster, caster, "rb_sealdisabled", 10.0)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_madmans_roar_silence", {})

	local courageAbility = caster:FindAbilityByName("berserker_5th_courage")
	local courageCooldown = courageAbility:GetCooldown(courageAbility:GetLevel())
	courageAbility:StartCooldown(courageCooldown)

	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName(keys.ability:GetAbilityName())
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(keys.ability:GetCooldown(1))
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_madmans_roar_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})
	
	-- Remove Berserk modifier and set health to max
	if caster:HasModifier("modifier_berserk_self_buff") then
		caster:RemoveModifierByName("modifier_berserk_self_buff")
	end
	caster:SetHealth(caster:GetMaxHealth())

	local casterloc = caster:GetAbsOrigin()
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 3000
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	local finaldmg = 0
	for k,v in pairs(targets) do
		local dist = (v:GetAbsOrigin() - casterloc):Length2D() 
		if dist <= 300 then
			finaldmg = keys.Damage1
		        giveUnitDataDrivenModifier(caster, v, "stunned", 3.0)
			giveUnitDataDrivenModifier(caster, v, "rb_sealdisabled", 3.0)
		elseif dist > 300 and dist <= 1000 then
			finaldmg = keys.Damage2
			if not IsImmuneToSlow(v) then 
				ability:ApplyDataDrivenModifier(caster, v, "modifier_madmans_roar_slow_strong", {}) 
			end
		elseif dist > 1000 and dist <= 2000 then
			finaldmg = keys.Damage3
			if not IsImmuneToSlow(v) then 
				ability:ApplyDataDrivenModifier(caster, v, "modifier_madmans_roar_slow_moderate", {}) 
			end
		elseif dist > 2000 and dist <= 3000 then
			finaldmg = 0
			if not IsImmuneToSlow(v) then 
				ability:ApplyDataDrivenModifier(caster, v, "modifier_madmans_roar_slow_moderate", {}) 
			end
		end

	    DoDamage(caster, v, finaldmg , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	end
	ParticleManager:CreateParticle("particles/custom/screen_face_splash.vpcf", PATTACH_EYES_FOLLOW, caster)
	ScreenShake(caster:GetOrigin(), 30, 2.0, 5.0, 10000, 0, true)

end

function OnBerserkStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local hplock = keys.Health
	local duration = keys.Duration
	local damageTaken = keys.DamageTaken
	local ply = caster:GetPlayerOwner()
	local berserkCounter = 0
	caster.BerserkDamageTaken = 0

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_berserk_self_buff", {})
	Timers:CreateTimer(function()
		if caster:HasModifier("modifier_berserk_self_buff") == false then return end
		if berserkCounter > duration then return end
		-- local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff_symbol.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
  --   	ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin() )
		caster:SetHealth(math.min(hplock , caster:GetMaxHealth() - caster:GetModifierStackCount("modifier_gae_buidhe", keys.ability) * 100)) -- 100 being unit health reduction, refer to ZL KV/lua.
		berserkCounter = berserkCounter + 0.033
		return 0.033
		end
	)

	if caster.IsEternalRageAcquired then 
		local explosionCounter = 0
		local manaregenCounter = 0

		Timers:CreateTimer(function()
			if caster:HasModifier("modifier_berserk_self_buff") == false then return end
			if explosionCounter == duration then return end
			local radius = 300
			local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
			for k,v in pairs(targets) do
		        DoDamage(caster, v, caster.BerserkDamageTaken/5, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
			end
			caster.BerserkDamageTaken = 0
			local berserkExp = ParticleManager:CreateParticle("particles/custom/berserker/berserk/eternal_rage_shockwave.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControl(berserkExp, 1, Vector(radius,0,radius))
			-- DebugDrawCircle(caster:GetAbsOrigin(), Vector(255,0,0), 0.5, radius, true, 0.5)

			explosionCounter = explosionCounter + 1.0
			return 1.0
			end
		)
	end

	BerCheckCombo(caster, keys.ability)
	EmitGlobalSound("Berserker.Roar")

	-- hi i'm definitely not a hacky replacement for not being able to get status effect particles to work
	caster:SetRenderColor(255, 127, 127)
end

function OnBerserkDamageTaken(keys)
	local caster = keys.caster 
	local damageTaken = keys.DamageTaken
	if caster.IsEternalRageAcquired then
		caster.BerserkDamageTaken = caster.BerserkDamageTaken + damageTaken
		print(caster.BerserkDamageTaken)
		caster:SetMana(caster:GetMana() + damageTaken/5)
		ParticleManager:CreateParticle("particles/custom/berserker/berserk/mana_conversion.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)

		--reduce cooldown of skills
		if caster.IsCDReductionCoolingdown == false then
			for i=0, 15 do 
				local ability = caster:GetAbilityByIndex(i)
				if ability ~= nil then
					local remainingCD = ability:GetCooldownTimeRemaining()
					ability:EndCooldown()
					if (remainingCD-1) > 0 then
						ability:StartCooldown(remainingCD-1)
					end
				else 
					break
				end
			end

			--Lower the remaining cooldown duration of the Master 2 (Rin)
			local masterComboAbility = caster.MasterUnit2:GetAbilityByIndex(5)									--Get the combo ability
			local masterComboCooldownRemaining = masterComboAbility:GetCooldownTimeRemaining()					--Get the remaining cooldown time
			masterComboAbility:EndCooldown()	
			masterComboAbility:StartCooldown(masterComboCooldownRemaining-1)

			--Refreshing the madman roar cooldown modifier
			if caster:HasModifier("modifier_madmans_roar_cooldown") then
				local comboCdRemaining = caster:FindModifierByName("modifier_madmans_roar_cooldown"):GetRemainingTime()
				caster:RemoveModifierByName("modifier_madmans_roar_cooldown")
				caster:FindAbilityByName("berserker_5th_madmans_roar"):ApplyDataDrivenModifier(caster, caster, "modifier_madmans_roar_cooldown", {duration = comboCdRemaining-1})		
			end

			--0.25 proc cooldown
			caster.IsCDReductionCoolingdown = true
			Timers:CreateTimer(0.25, function()
				caster.IsCDReductionCoolingdown = false
			end)
		end
	end
end

-- Eternal Rage passive
function OnBerserkProc(keys)
	local caster = keys.caster
	local target = keys.target
	if not caster.IsRageBashOnCooldown and caster:HasModifier("modifier_courage_attack_damage_buff") then
		local radius = 300
		local targets = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
		for k,v in pairs(targets) do
	        DoDamage(caster, v, 50, DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)
	        v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 0.5})
		end
		caster.IsRageBashOnCooldown = true
		target:EmitSound("Hero_Centaur.HoofStomp")
		Timers:CreateTimer(4.0, function()
			caster.IsRageBashOnCooldown = false
		end)

		ParticleManager:CreateParticle("particles/custom/berserker/courage/stun_explosion.vpcf", PATTACH_ABSORIGIN, target)
		-- DebugDrawCircle(target:GetAbsOrigin(), Vector(255,0,0), 0.5, radius, true, 0.5)
	end
end

function BerserkEnd(keys)
	keys.caster:SetRenderColor(255, 255, 255)
end


function OnNineCast(keys)
	local caster = keys.caster
	local casterName = caster:GetName()
	if casterName == "npc_dota_hero_doom_bringer" then
		StartAnimation(caster, {duration=0.3, activity=ACT_DOTA_CAST_ABILITY_5, rate=0.2})
	elseif casterName == "npc_dota_hero_sven" then
		StartAnimation(caster, {duration=0.3, activity=ACT_DOTA_RUN, rate=0.2})
	elseif casterName == "npc_dota_hero_ember_spirit" then
		StartAnimation(caster, {duration=0.3, activity=ACT_DOTA_RUN, rate=0.2})
	end
end

function OnNineStart(keys)
	local caster = keys.caster
	local casterName = caster:GetName()
	local targetPoint = keys.target_points[1]
	local ability = keys.ability
	local berserker = Physics:Unit(caster)
	local origin = caster:GetAbsOrigin()
	local distance = (targetPoint - origin):Length2D()
	local forward = (targetPoint - origin):Normalized() * distance

	caster:SetPhysicsFriction(0)
	caster:SetPhysicsVelocity(caster:GetForwardVector()*distance)
	caster:SetNavCollisionType(PHYSICS_NAV_BOUNCE)
	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 4.0)
	caster:EmitSound("Hero_OgreMagi.Ignite.Cast")
	--ability:ApplyDataDrivenModifier(caster, caster, "modifier_dash_anim", {})
	if casterName == "npc_dota_hero_doom_bringer" then
		StartAnimation(caster, {duration=1, activity=ACT_DOTA_CAST_ABILITY_5, rate=0.5})
	elseif casterName == "npc_dota_hero_sven" then
		StartAnimation(caster, {duration=1, activity=ACT_DOTA_RUN, rate=0.5})
	elseif casterName == "npc_dota_hero_ember_spirit" then
		StartAnimation(caster, {duration=1, activity=ACT_DOTA_RUN, rate=0.8})
	end

	function DoNineLanded(caster)
		caster:OnPreBounce(nil)
		caster:OnPhysicsFrame(nil)
		caster:SetBounceMultiplier(0)
		caster:PreventDI(false)
		caster:SetPhysicsVelocity(Vector(0,0,0))
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
		Timers:RemoveTimer(caster.NineTimer)
		caster.NineTimer = nil
		if caster:IsAlive() then
			OnNineLanded(caster, keys.ability)
			return 
		end
		return
	end

	caster.NineTimer = Timers:CreateTimer(1.0, function()
		DoNineLanded(caster)
	end)

	caster:OnPhysicsFrame(function(unit)
		if CheckDummyCollide(unit) then
			DoNineLanded(unit)
		end
	end)

	caster:OnPreBounce(function(unit, normal) -- stop the pushback when unit hits wall
		DoNineLanded(unit)
	end)

	if caster:GetName() == "npc_dota_hero_ember_spirit" then
		caster:EmitSound("Archer.NineLives")
	end


	--[[Timers:CreateTimer(function()
		if travelCounter == 33 then OnNineLanded(caster, keys.ability) return end
		caster:SetAbsOrigin(caster:GetAbsOrigin() + forward) 
		travelCounter = travelCounter + 1
		
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
		return 0.03
		end
	)]]
end

-- add pause
function OnNineLanded(caster, ability)
	local tickdmg = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1)
	local lasthitdmg = ability:GetLevelSpecialValueFor("damage_lasthit", ability:GetLevel() - 1)
	local courageAbility = 0
	local courageDamage = 0
	if caster:GetName() == "npc_dota_hero_doom_bringer" then 
		courageAbility = caster:FindAbilityByName("berserker_5th_courage")
		courageDamage = courageAbility:GetSpecialValueFor("bonus_damage")
	end
	local returnDelay = 0.3
	if caster:GetName() == "npc_dota_hero_ember_spirit" then
		returnDelay = 0.1
	end
	local radius = ability:GetSpecialValueFor("radius")
	local lasthitradius = ability:GetSpecialValueFor("radius_lasthit")
	local stun = ability:GetSpecialValueFor("stun_duration")
	local nineCounter = 0
	local casterInitOrigin = caster:GetAbsOrigin() 

	-- swap animation
	if caster:GetName() == "npc_dota_hero_doom_bringer" then 
		if caster:IsAlive() then
			StartAnimation(caster, {duration=3.5, activity=ACT_DOTA_CAST_ABILITY_6, rate=1.0})
		end
	end

	-- main timer
	Timers:CreateTimer(function()
		if caster:IsAlive() then -- only perform actions while caster stays alive
			local particle = ParticleManager:CreateParticle("particles/custom/berserker/nine_lives/hit.vpcf", PATTACH_ABSORIGIN, caster)
			ParticleManager:SetParticleControlForward(particle, 0, caster:GetForwardVector() * -1)
			ParticleManager:SetParticleControl(particle, 1, Vector(0,0,(nineCounter % 2) * 180))
			if caster:GetName() == "npc_dota_hero_sven" then 
				if math.random(0,1) == 0 then 
					StartAnimation(caster, {duration=0.3, activity=ACT_DOTA_ATTACK, rate=2.5})
				else
					StartAnimation(caster, {duration=0.3, activity=ACT_DOTA_ATTACK2, rate=2.5})
				end
			elseif caster:GetName() == "npc_dota_hero_ember_spirit" then 
				StartAnimation(caster, {duration=0.3, activity=ACT_DOTA_ATTACK, rate=3.0}) 
			end
			caster:EmitSound("Hero_EarthSpirit.StoneRemnant.Impact") 

			if nineCounter == 8 then -- if it is last strike

				caster:EmitSound("Hero_EarthSpirit.BoulderSmash.Target")
				caster:RemoveModifierByName("pause_sealdisabled") 
				ScreenShake(caster:GetOrigin(), 7, 1.0, 2, 1500, 0, true)
				-- do damage to targets
				local damage = lasthitdmg 
				if caster:HasModifier("modifier_courage_damage_stack_indicator") then
					damage = damage + courageDamage
					DeductCourageDamageStack(caster)
				end 
				local lasthitTargets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, lasthitradius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 1, false)
				for k,v in pairs(lasthitTargets) do
					if v:GetName() ~= "npc_dota_ward_base" then
						if caster.IsProjectionImproved then 
							DoDamage(caster, v, damage + v:GetHealth() * 0.05, DAMAGE_TYPE_MAGICAL, 0, ability, false)
						else
							DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
						end
						giveUnitDataDrivenModifier(caster, v, "stunned", 0.5)
						if caster:GetName() ~= "npc_dota_hero_ember_spirit" then
							giveUnitDataDrivenModifier(caster, v, "revoked", 0.5)
						end
						-- push enemies back
						local pushback = Physics:Unit(v)
						v:PreventDI()
						v:SetPhysicsFriction(0)
						v:SetPhysicsVelocity((v:GetAbsOrigin() - casterInitOrigin):Normalized() * 300)
						v:SetNavCollisionType(PHYSICS_NAV_NOTHING)
						v:FollowNavMesh(false)
						Timers:CreateTimer(0.5, function()  
							v:PreventDI(false)
							v:SetPhysicsVelocity(Vector(0,0,0))
							v:OnPhysicsFrame(nil)
							FindClearSpaceForUnit(v, v:GetAbsOrigin(), true)
						end)
					end
				end

				if caster:GetName() == "npc_dota_hero_doom_bringer" then
					EmitGlobalSound("Berserker.Roar")
				elseif caster:GetName() == "npc_dota_hero_sven" then
					EmitGlobalSound("Lancelot.Roar1" )
					StartAnimation(caster, {duration=0.7, activity=ACT_DOTA_CAST_ABILITY_6, rate=3.0})
				elseif caster:GetName() == "npc_dota_hero_ember_spirit" then
					caster:EmitSound("Archer.NineFinish") 
				end

				ParticleManager:SetParticleControl(particle, 2, Vector(1,1,lasthitradius))
				ParticleManager:SetParticleControl(particle, 3, Vector(lasthitradius / 350,1,1))
				ParticleManager:CreateParticle("particles/custom/berserker/nine_lives/last_hit.vpcf", PATTACH_ABSORIGIN, caster)

				-- DebugDrawCircle(caster:GetAbsOrigin(), Vector(255,0,0), 0.5, lasthitradius, true, 0.5)
			else
				-- if its not last hit, do regular hit stuffs
				local damage = tickdmg -- store original tick damage 
				if caster:HasModifier("modifier_courage_damage_stack_indicator") then
					damage = damage + courageDamage
					DeductCourageDamageStack(caster)
				end 
				local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, 1, false)
				for k,v in pairs(targets) do
					if caster.IsProjectionImproved then 
						DoDamage(caster, v, damage + v:GetHealth() * 0.05, DAMAGE_TYPE_MAGICAL, 0, ability, false)
					else
						DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
					end
					giveUnitDataDrivenModifier(caster, v, "stunned", 0.5)
					if caster:GetName() ~= "npc_dota_hero_ember_spirit" then
						print("9 revoke")
						giveUnitDataDrivenModifier(caster, v, "revoked", 0.5)
					end
				end

				ParticleManager:SetParticleControl(particle, 2, Vector(1,1,radius))
				ParticleManager:SetParticleControl(particle, 3, Vector(radius / 350,1,1))
				-- DebugDrawCircle(caster:GetAbsOrigin(), Vector(255,0,0), 0.5, radius, true, 0.5)

				nineCounter = nineCounter + 1
				return returnDelay
			end

		end 
	end)
end


QUsed = false
QTime = 0

function BerCheckCombo(caster, ability)
	if caster:GetStrength() >= 19.1 and caster:GetAgility() >= 19.1 and caster:GetIntellect() >= 19.1 then
		if ability == caster:FindAbilityByName("berserker_5th_fissure_strike") then
			QUsed = true
			QTime = GameRules:GetGameTime()
			Timers:CreateTimer({
				endTime = 4,
				callback = function()
				QUsed = false
			end
			})
		elseif ability == caster:FindAbilityByName("berserker_5th_berserk") and caster:FindAbilityByName("berserker_5th_courage"):IsCooldownReady() and caster:FindAbilityByName("berserker_5th_madmans_roar"):IsCooldownReady()  then
			if QUsed == true then 
				caster:SwapAbilities("berserker_5th_madmans_roar", "berserker_5th_courage", true, false) 
				local newTime =  GameRules:GetGameTime()
				Timers:CreateTimer({
					endTime = 4 - (newTime - QTime),
					callback = function()
					caster:SwapAbilities("berserker_5th_madmans_roar", "berserker_5th_courage", false, true) 
					QUsed = false
				end
				})
			end
		end
	end
end



function OnGodHandDeath(keys)
	local caster = keys.caster
	local newRespawnPos = caster:GetOrigin()
	local ply = caster:GetPlayerOwner()
	local radius = 600

	local dummy = CreateUnitByName("godhand_res_locator", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
	dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1) 
	dummy:AddNewModifier(caster, nil, "modifier_phased", {duration=1.0})
	dummy:AddNewModifier(caster, nil, "modifier_kill", {duration=1.1})


	--print("God Hand activated")
	Timers:CreateTimer({
		endTime = 1,
		callback = function()
		print(caster.bIsGHReady)
		if IsTeamWiped(caster) == false and caster.GodHandStock > 0 and caster.bIsGHReady and _G.CurrentGameState == "FATE_ROUND_ONGOING" then
			caster.bIsGHReady = false
			Timers:CreateTimer(7.0, function() caster.bIsGHReady = true end)
			EmitGlobalSound("Berserker.Roar") 
			local particle = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			caster.GodHandStock = caster.GodHandStock - 1
			GameRules:SendCustomMessage("<font color='#FF0000'>----------!!!!!</font> Remaining God Hand stock : " .. caster.GodHandStock , 0, 0)
			caster:SetRespawnPosition(dummy:GetAbsOrigin())
			caster:RespawnHero(false,false,false)
			caster:RemoveModifierByName("modifier_god_hand_stock")
			if caster.GodHandStock > 0 then
				keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_god_hand_stock", {})
				caster:SetModifierStackCount("modifier_god_hand_stock", caster, caster.GodHandStock)
			end

			-- Apply revive damage
			local resExp = ParticleManager:CreateParticle("particles/custom/berserker/god_hand/stomp.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControl(particle, 3, caster:GetAbsOrigin())
			local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			-- DebugDrawCircle(caster:GetAbsOrigin(), Vector(255,0,0), 0.5, radius, true, 0.5)
			for k,v in pairs(targets) do
		        DoDamage(caster, v, caster:GetMaxHealth() * 2.5/10, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
			end	

			-- Apply penalty
			keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_god_hand_debuff", {}) 
			-- Remove Gae Buidhe modifier
			caster:RemoveModifierByName("modifier_gae_buidhe")
			-- Reset godhand stock
			caster.ReincarnationDamageTaken = 0
			UpdateGodhandProgress(caster)
		else
			caster:SetRespawnPosition(caster.RespawnPos)
		end
		--caster:SetRespawnPosition(Vector(7000, 2000, 320)) need to set the respawn base after reviving
	end
	})	

end

function OnReincarnationDamageTaken(keys)
	local caster = keys.caster
	local ability = keys.ability
	local damageTaken = keys.DamageTaken
	local damageThreshold = 20000

	if damageTaken > 100 then
		GainReincarnationRegenStack(caster, ability)
	end

	if caster.IsGodHandAcquired ~= true then return end -- To prevent reincanationdamagetaken from incrementing when GH is not taken.

	if caster:HasModifier("modifier_berserk_self_buff") then 
		caster.ReincarnationDamageTaken = caster.ReincarnationDamageTaken+damageTaken*3
	else
		caster.ReincarnationDamageTaken = caster.ReincarnationDamageTaken+damageTaken
	end
	if caster.ReincarnationDamageTaken > damageThreshold and caster.IsGodHandAcquired then
		caster.ReincarnationDamageTaken = 0
		caster.GodHandStock = caster.GodHandStock + 1
		caster:RemoveModifierByName("modifier_god_hand_stock")
		caster:FindAbilityByName("berserker_5th_god_hand"):ApplyDataDrivenModifier(caster, caster, "modifier_god_hand_stock", {})
		caster:SetModifierStackCount("modifier_god_hand_stock", caster, caster.GodHandStock)
	end

	UpdateGodhandProgress(caster)
end

function UpdateGodhandProgress(caster)
	local damageTaken = caster.ReincarnationDamageTaken
	if not caster:HasModifier("modifier_reincarnation_progress") then
		caster:FindAbilityByName("berserker_5th_reincarnation"):ApplyDataDrivenModifier(caster, caster, "modifier_reincarnation_progress", {})
	end
	caster:SetModifierStackCount("modifier_reincarnation_progress", caster, damageTaken / 200)
end

function GainReincarnationRegenStack(caster, ability)
	local modifier = ability:ApplyDataDrivenModifier(caster, caster, "modifier_reincarnation_stack", {})
	if modifier:GetStackCount() < 5 then 
		modifier:IncrementStackCount() 
	end

	if not caster.reincarnation_particle then caster.reincarnation_particle = ParticleManager:CreateParticle("particles/custom/berserker/reincarnation/regen_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster) end
	ParticleManager:SetParticleControl(caster.reincarnation_particle, 1, Vector(modifier:GetStackCount(),0,0))
end

function OnReincarnationBuffEnded(keys)
	ParticleManager:DestroyParticle(keys.caster.reincarnation_particle, false)
	keys.caster.reincarnation_particle = nil
end

function OnImproveDivinityAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsDivinityImproved = true
	hero:FindAbilityByName("berserker_5th_divinity"):SetLevel(2)
	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnBerserkAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero:FindAbilityByName("berserker_5th_berserk_attribute_passive"):SetLevel(1)
	hero.IsEternalRageAcquired = true
	hero.IsRageBashOnCooldown = false
	hero.IsCDReductionCoolingdown = false
	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnGodHandAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	local ability = hero:FindAbilityByName("berserker_5th_god_hand")
	ability:SetLevel(1)
	hero.IsGodHandAcquired = true
	hero.GodHandStock = 11
	ability:ApplyDataDrivenModifier(hero, hero, "modifier_god_hand_stock", {}) 
	hero:SetModifierStackCount("modifier_god_hand_stock", hero, 11)
	hero.bIsGHReady = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnReincarnationAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsReincarnationAcquired = true
	hero:FindAbilityByName("berserker_5th_reincarnation"):SetLevel(1)
	hero.ReincarnationDamageTaken = 0
	UpdateGodhandProgress(hero)
	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end
