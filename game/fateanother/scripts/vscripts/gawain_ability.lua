function OnIRStart(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local target = keys.target

	if target:GetName() == "npc_dota_ward_base" then 
		keys.ability:EndCooldown()
		caster:GiveMana(keys.ability:GetManaCost(1))
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Be_Cast_Now")
		return
	end

	if caster:GetUnitName() == "npc_dota_hero_omniknight" then
		GawainCheckCombo(caster, keys.ability)
		GenerateArtificialSun(caster, target:GetAbsOrigin())
	end

	if target:GetTeamNumber() == caster:GetTeamNumber() then
		if caster.IsEclipseAcquired and target:GetName() == "npc_dota_hero_omniknight" then
			keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_invigorating_ray_Eclipse", {})
		end
		target:EmitSound("Hero_Omniknight.Purification")
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_invigorating_ray_ally", {})
		if caster.IsSunlightAcquired then
			keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_invigorating_ray_armor_buff", {})
		end
	else
		target:TriggerSpellReflect(keys.ability)
		if IsSpellBlocked(keys.target) then return end
		target:EmitSound("Hero_Omniknight.Purification")
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_invigorating_ray_enemy", {})
		if caster.IsSunlightAcquired then
			keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_invigorating_ray_armor_nerf", {})
		end
	end
	local lightFx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_sun_strike_beam.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( lightFx1, 0, target:GetAbsOrigin())
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( lightFx1, false )
		ParticleManager:ReleaseParticleIndex( lightFx1 )
	end)
end

function OnIRTickAlly(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local target = keys.target
	target:ApplyHeal(keys.Damage/10, caster)
	--target:SetHealth(target:GetHealth() + keys.Damage/5)
	local targets= FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 300 , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
	if caster.IsEclipseAcquired and target:GetName() == "npc_dota_hero_omniknight" then
		targets= FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 300 , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
		for k,v in pairs(targets) do
			DoDamage(caster, v, keys.Damage/10,  DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)	
			target:ApplyHeal(keys.Damage/25, caster)		
		end		
	end
end

function OnIRTickEnemy(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local target = keys.target
	if caster.IsEclipseAcquired then 
		damage = keys.Damage/10
	else
		damage = keys.Damage/10 * 0.66
	end
	DoDamage(caster, target, damage, DAMAGE_TYPE_PURE, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, keys.ability, false)
end

function OnIRUpgrade(keys)
	local caster=keys.caster
	local ability=keys.ability
	local curretskill = caster:FindAbilityByName("gawain_invigorating_ray_eclipse")
	curretskill:SetLevel(keys.ability:GetLevel())
end

function OnIRStartE(keys)
	local caster = keys.caster
	local ability = keys.ability
	GenerateArtificialSun(caster, caster:GetAbsOrigin())
	GawainCheckCombo(caster, caster:FindAbilityByName("gawain_invigorating_ray"))
	caster:EmitSound("Hero_Omniknight.Purification")
    keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_invigorating_ray_eclipse", {})
end

function OnIRTickEclipse(keys)
	local caster = keys.caster
	local damage= keys.Damage
	caster:ApplyHeal(damage/20,caster)
	local targets= FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 400 , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
	local heal = keys.ability:GetLevel() * 3
	for k,v in pairs(targets) do
		DoDamage(caster, v, keys.Damage/10,  DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)	
		caster:ApplyHeal(heal, caster)		
	end	
end

function OnDevoteStart(keys)
	local caster = keys.caster
	local ability = keys.ability

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_blade_of_the_devoted", {})
	if caster.IsEclipseAcquired then
		giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 0.5)
		local unit = Physics:Unit(caster)
		caster:SetPhysicsFriction(0)
		local ChargeRange = caster:GetForwardVector()*75
		caster:SetPhysicsVelocity(ChargeRange)
		caster:SetNavCollisionType(PHYSICS_NAV_BOUNCE)
        
		
		StartAnimation(caster,{duration=0.6,activity=ACT_DOTA_ATTACK_EVENT, rate=0.8})	

		caster:OnPreBounce(function(unit, normal) -- stop the pushback when unit hits wall
			unit:OnPreBounce(nil)
		    unit:SetBounceMultiplier(0)
		    unit:PreventDI(false)
			unit:SetPhysicsVelocity(Vector(0,0,0))
			FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
		end)
        local hitfx = ParticleManager:CreateParticle("particles/econ/items/lina/lina_ti7/light_strike_array_pre_ti7_gold_f_2.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
		ParticleManager:SetParticleControl( hitfx, 0, caster:GetAbsOrigin())
		Timers:CreateTimer(0.6,function()
			caster:OnPreBounce(nil)
			caster:SetBounceMultiplier(0)
			caster:PreventDI(false)
			caster:SetPhysicsVelocity(Vector(0,0,0))
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
			
			local targets2= FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 325 , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
			for k,v in pairs(targets2) do
				DoDamage(caster, v, keys.Damage , DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)
				v:AddNewModifier(caster, caster, "modifier_stunned", {Duration = 0.55})
				caster:EmitSound("Hero_Invoker.ColdSnap")
			end
		end)
	end
	Timers:CreateTimer(function()
		if caster:HasModifier("modifier_blade_of_the_devoted") then
			local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 300, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false) 
			
			for k,v in pairs(targets) do
				keys.ability:ApplyDataDrivenModifier(keys.caster, v, "modifier_blade_of_the_devoted_ally_deniable",{})
			end
		end
		return 0.1
	end)

	caster:EmitSound("Hero_EmberSpirit.FireRemnant.Cast")
	local lightFx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_sun_strike_beam.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControl( lightFx1, 0, caster:GetAbsOrigin())
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( lightFx1, false )
		ParticleManager:ReleaseParticleIndex( lightFx1 )
	end)
end

--list and related Dota KV file must be updated upon new hero release!!!
modifierList = {"modifier_max_mana_burst_cooldown","modifier_delusional_illusion_cooldown","modifier_max_excalibur_cooldown",
"modifier_wesen_gae_bolg_cooldown","modifier_arrow_rain_cooldown","modifier_bellerophon_2_cooldown",
"modifier_hecatic_graea_powered_cooldown","modifier_tsubame_mai_cooldown","modifier_madmans_roar_cooldown",
"modifier_max_enuma_elish_cooldown","modifier_endless_loop_cooldown","modifier_rampant_warrior_cooldown","modifier_nuke_cooldown",
"modifier_larret_de_mort_cooldown","modifier_annihilate_cooldown","modifier_fiery_finale_cooldown",
"modifier_polygamist_cooldown","modifier_raging_dragon_strike_cooldown","modifier_la_pucelle_cooldown","modifier_hippogriff_ride_cooldown","modifier_story_for_someones_sake_cooldown",
"modifier_phoebus_catastrophe_cooldown","modifier_lord_of_execution_cd",
"modifier_strike_air_cooldown","modifier_instinct_cooldown","modifier_battle_continuation_cooldown","modifier_hrunting_cooldown","jack_the_mist_cd",
"modifier_overedge_cooldown","modifier_blood_mark_cooldown","modifier_quickdraw_cooldown","modifier_eternal_arms_mastership_cooldown","modifier_mystic_shackle_cooldown",
"modifier_golden_apple_cooldown","modifier_protection_of_faith_proc_cd"} --last 3 lines are non-combos.

function OnDevoteHit(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local target = keys.target

	caster:RemoveModifierByName("modifier_blade_of_the_devoted")
	GenerateArtificialSun(caster, target:GetAbsOrigin())

	if target:GetTeamNumber() == caster:GetTeamNumber() then
		-- process team effect
		target:SetHealth(target:GetHealth() + keys.Damage + caster:GetAttackDamage())
		if caster.IsSunlightAcquired then
			target:SetMana(target:GetMana() + keys.Damage)
			for i=0, 15 do 
				local ability = target:GetAbilityByIndex(i)
				if ability ~= nil then
					local remainingCD = ability:GetCooldownTimeRemaining()
					ability:EndCooldown()
					ability:StartCooldown(remainingCD-15)
				else 
					break
				end
			end

			--Lower the remaining cooldown duration of the Master 2 (Rin)
			local masterComboAbility = target.MasterUnit2:GetAbilityByIndex(5)									--Get the target's Master's combo ability
			local masterComboCooldownRemaining = masterComboAbility:GetCooldownTimeRemaining()					--Get the remaining cooldown time
			masterComboAbility:EndCooldown()	
			masterComboAbility:StartCooldown(masterComboCooldownRemaining-15)
			--Refreshing the cooldown modifiers, including non-combos.
			for i = 1, #modifierList do
				if target:HasModifier(modifierList[i]) then
					cdRemaining = target:FindModifierByName(modifierList[i]):GetRemainingTime()
					target:RemoveModifierByName(modifierList[i])
					keys.ability:ApplyDataDrivenModifier(caster, target, modifierList[i], {duration = cdRemaining-15})		
				end
			end	
		end
	else
		-- process enemy effect
		DoDamage(caster, target, keys.Damage * 0.8, DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)
		target:AddNewModifier(caster, caster, "modifier_stunned", {Duration = 0.4})
	end

	if caster.IsEclipseAcquired then
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_blade_of_the_devoted_eclispe",{})
		caster.CurrentDevoteDamage = keys.Damage/8
	end

	target:EmitSound("Hero_Invoker.ColdSnap")
	local lightFx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_sun_strike_beam.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( lightFx1, 0, target:GetAbsOrigin())
	local flameFx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_fire_spirit_ground.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( flameFx1, 0, target:GetAbsOrigin())
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( lightFx1, false )
		ParticleManager:ReleaseParticleIndex( lightFx1 )
		ParticleManager:DestroyParticle( flameFx1, false )
		ParticleManager:ReleaseParticleIndex( flameFx1 )
	end)
end

function OnDevoteConsecutiveHit(keys)
	local caster = keys.caster
	local target = keys.target

	DoDamage(caster, target, caster.CurrentDevoteDamage, DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)
	target:AddNewModifier(caster, caster, "modifier_stunned", {Duration = 0.01})

	target:EmitSound("Hero_Invoker.ColdSnap")
	local lightFx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_sun_strike_beam.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( lightFx1, 0, target:GetAbsOrigin())
	local flameFx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_fire_spirit_ground.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( flameFx1, 0, target:GetAbsOrigin())
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( lightFx1, false )
		ParticleManager:ReleaseParticleIndex( lightFx1 )
		ParticleManager:DestroyParticle( flameFx1, false )
		ParticleManager:ReleaseParticleIndex( flameFx1 )
	end)
end



function OnGalatineStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ply = caster:GetPlayerOwner()
	local casterLoc = caster:GetAbsOrigin()
	local targetPoint = keys.target_points[1]
	local dist = (targetPoint - casterLoc):Length2D()
	local orbLoc = caster:GetAbsOrigin()
	local diff = caster:GetForwardVector()
	local timeElapsed = 0
	local flyingDist = 0
	local InFirstLoop = true
	caster.IsGalatineActive = true
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_excalibur_galatine_vfx", {})
	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 1.75)
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_excalibur_galatine_anim",{})
	EmitGlobalSound("Gawain.Galatine")


	local castFx1 = ParticleManager:CreateParticle("particles/custom/saber_excalibur_circle.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControl( castFx1, 0, caster:GetAbsOrigin())

	local castFx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControl( castFx2, 0, caster:GetAbsOrigin())
	

	
	local galatineDummy = CreateUnitByName("gawain_galatine_dummy", Vector(20000,20000,0), true, nil, nil, caster:GetTeamNumber())
	local flameFx1 = ParticleManager:CreateParticle("particles/custom/gawain/gawain_excalibur_galatine_orb.vpcf", PATTACH_ABSORIGIN_FOLLOW, galatineDummy )
	ParticleManager:SetParticleControl( flameFx1, 0, galatineDummy:GetAbsOrigin())
	if caster.IsEclipseAcquired then
		local flameFx2 = ParticleManager:CreateParticle("particles/dire_fx/bad_ancient002_pit_lava_blast_lava.vpcf", PATTACH_ABSORIGIN_FOLLOW, galatineDummy )
		local flameFx3 = ParticleManager:CreateParticle("particles/custom/rider/riderlava.vpcf", PATTACH_ABSORIGIN_FOLLOW, galatineDummy)
		Timers:CreateTimer(2.0,function()
            ParticleManager:ReleaseParticleIndex( flameFx2)
			ParticleManager:DestroyParticle(flameFx2,false)
			ParticleManager:ReleaseParticleIndex( flameFx3)
			ParticleManager:DestroyParticle(flameFx3,false)
		end)
	end

	Timers:CreateTimer(1.5, function()
		if caster:IsAlive() and timeElapsed < 1.5 and flyingDist < dist and caster.IsGalatineActive then
			if InFirstLoop then
				casterLoc = caster:GetAbsOrigin()
				orbLoc = caster:GetAbsOrigin()
				diff = caster:GetForwardVector()
				caster:SwapAbilities("gawain_excalibur_galatine", "gawain_excalibur_galatine_detonate", false, true)
				InFirstLoop = false
			end
			orbLoc = orbLoc + diff * 33
			galatineDummy:SetAbsOrigin(orbLoc)
			flyingDist = (casterLoc - orbLoc):Length2D()
			timeElapsed = timeElapsed + 0.033
			if caster.IsEclipseAcquired then
				local targets2= FindUnitsInRadius(caster:GetTeam(), galatineDummy:GetAbsOrigin(), nil, 300 , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
				for k,v in pairs(targets2) do
					DoDamage(caster, v, keys.Damage/50 , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
				end
			end
			return 0.033
		else 
			GenerateArtificialSun(caster, orbLoc)
            --caster:SwapAbilities("gawain_excalibur_galatine", "gawain_excalibur_galatine_detonate", true, false)
			if caster:GetAbilityByIndex(5):GetAbilityName() == "gawain_excalibur_galatine_detonate" then
				caster:SwapAbilities("gawain_excalibur_galatine", "gawain_excalibur_galatine_detonate", true, false)
			end
			-- Explosion on allies
			local targets = FindUnitsInRadius(caster:GetTeam(), galatineDummy:GetAbsOrigin(), nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
			for k,v in pairs(targets) do
				v:ApplyHeal(keys.Damage * 30/100, caster)
				if caster.IsSunlightAcquired then
					local healTime = 0
					Timers:CreateTimer(1.0, function()
						if healTime == 10 then return end
						v:ApplyHeal(keys.Damage * 3/50, caster)
						healTime = healTime + 1
						return 0.3
					end)
				end
			end

			-- Explosion on enemies
			local targets = FindUnitsInRadius(caster:GetTeam(), galatineDummy:GetAbsOrigin(), nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
			for k,v in pairs(targets) do
				if not caster.IsEclipseAcquired then
					DoDamage(caster, v, keys.Damage , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
					if caster.IsSunlightAcquired then
						keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_excalibur_galatine_slow", {duration=1.5})
					end
				else
					-- calculate the distance from center to enemy
					DoDamage(caster, v, keys.Damage + 300 , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
					local fxDummy = CreateUnitByName("dummy_unit", galatineDummy:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
					fxDummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
					--local LavaFxf = ParticleManager:CreateParticle("particles/dire_fx/dire_lava_gloops_child_13sec.vpcf", PATTACH_ABSORIGIN_FOLLOW, fxDummy )
			        --ParticleManager:SetParticleControl( LavaFxf, 1, fxDummy:GetAbsOrigin())		
					--local LavaFx = ParticleManager:CreateParticle("particles/neutral_fx/black_dragon_fireball_lava_a.vpcf", PATTACH_ABSORIGIN_FOLLOW, fxDummy )
					--ParticleManager:SetParticleControl( LavaFx, 1, fxDummy:GetAbsOrigin())
					--ParticleManager:SetParticleControl( LavaFxf,0,Vector(400, 400, 0))	
					--ParticleManager:SetParticleControl( LavaFx,0,Vector(400, 400, 0))	
					local firecount = 0
					local pooltargets = FindUnitsInRadius(caster:GetTeam(), galatineDummy:GetAbsOrigin(), nil, 500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
					Timers:CreateTimer(function()
						if firecount == 6 then return end
						pooltargets = FindUnitsInRadius(caster:GetTeam(), galatineDummy:GetAbsOrigin(), nil, 500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
						for k,v in pairs(pooltargets) do
							DoDamage(caster,v,keys.Damage/20, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
						end
						firecount=firecount+1
						return 0.5
					end)
					Timers:CreateTimer(6.0,function()
						--ParticleManager:DestroyParticle(LavaFx,false)
						--ParticleManager:ReleaseParticleIndex( LavaFx )
						--ParticleManager:DestroyParticle(LavaFxf,false)
						--ParticleManager:ReleaseParticleIndex( LavaFxf )
						fxDummy:RemoveSelf()
					end)
				end
			end
			local explodeFx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_hit.vpcf", PATTACH_ABSORIGIN, galatineDummy )
			ParticleManager:SetParticleControl( explodeFx1, 0, galatineDummy:GetAbsOrigin())			

			local explodeFx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf", PATTACH_ABSORIGIN_FOLLOW, galatineDummy )
			ParticleManager:SetParticleControl( explodeFx2, 0, galatineDummy:GetAbsOrigin())

			galatineDummy:EmitSound("Ability.LightStrikeArray")

			galatineDummy:ForceKill(true) 
			ParticleManager:DestroyParticle( flameFx1, false )
			ParticleManager:ReleaseParticleIndex( flameFx1 )
			ParticleManager:DestroyParticle( castFx1, false )
			ParticleManager:ReleaseParticleIndex( castFx1 )
			ParticleManager:DestroyParticle( castFx2, false )
			ParticleManager:ReleaseParticleIndex( castFx2 )

			Timers:CreateTimer( 2.0, function()
				ParticleManager:DestroyParticle( explodeFx1, false )
				ParticleManager:ReleaseParticleIndex( explodeFx1 )
				ParticleManager:DestroyParticle( explodeFx2, false )
				ParticleManager:ReleaseParticleIndex( explodeFx2 )
			end)
			return
		end
	end)
end

function OnGalatineDetonate(keys)
	local caster = keys.caster
	caster.IsGalatineActive = false
	if caster:GetAbilityByIndex(5):GetAbilityName() == "gawain_excalibur_galatine_detonate" then
		caster:SwapAbilities("gawain_excalibur_galatine", "gawain_excalibur_galatine_detonate", true, false)
	end
	--caster:SwapAbilities("gawain_excalibur_galatine", "gawain_excalibur_galatine_detonate", true, false)
end

function OnEmbraceStart(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local target = keys.target
	if caster:GetUnitName() == "npc_dota_hero_omniknight" then
		GenerateArtificialSun(caster, target:GetAbsOrigin())
	end
	
	if caster.IsEclipseAcquired then
		if target:GetTeamNumber() ~= caster:GetTeamNumber() then
			target:AddNewModifier(caster, caster, "modifier_stunned", {Duration = 0.4})
		end

    
		--fallen sun
		local sun = CreateUnitByName("gawain_artificial_sun",target:GetAbsOrigin(), true, nil, nil, caster:GetTeamNumber())
		local dottargets = FindUnitsInRadius(caster:GetTeam(), sun:GetAbsOrigin(), nil, 800, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
		sun:AddNewModifier(caster, caster, "modifier_kill", {duration = 2})
		local fallencout = 0
		local h=800
		sun:SetAbsOrigin(sun:GetAbsOrigin() + Vector(0,0,h))
		Timers:CreateTimer(function()
			if fallencout == 30 then return end
			dottargets = FindUnitsInRadius(caster:GetTeam(), sun:GetAbsOrigin(), nil, 600, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
			for k,v in pairs(dottargets) do
				DoDamage(caster,v,keys.Damage/40, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
			end
			sun:SetAbsOrigin(sun:GetAbsOrigin()  -  Vector(0,0,40))
			fallencout=fallencout+1
			return 0.1
		end)


		local SunFx1 = ParticleManager:CreateParticle("particles/econ/items/invoker/invoker_apex/invoker_sun_strike_team_immortal1.vpcf", PATTACH_CUSTOMORIGIN,nil )
		ParticleManager:SetParticleControl( SunFx1,0, target:GetAbsOrigin())
		Timers:CreateTimer({
			endTime = 2,
			callback = function()
			ParticleManager:DestroyParticle( SunFx1, false )
			local targets = FindUnitsInRadius(caster:GetTeam(), sun:GetAbsOrigin(), nil, 400, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
			for k,v in pairs(targets) do
				DoDamage(caster,v,keys.Damage*0.75, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
				v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 0.5})
				local SunFx2 = ParticleManager:CreateParticle("particles/econ/items/monkey_king/arcana/fire/mk_arcana_spring_fire_ring_glow.vpcf", PATTACH_ABSORIGIN_FOLLOW, v )
				ParticleManager:SetParticleControl( SunFx2,0, v:GetAbsOrigin())
                ParticleManager:SetParticleControl( SunFx2,1,Vector(400, 400, 0))
				local SunFx3 = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_supernova_reborn_shockwave.vpcf", PATTACH_ABSORIGIN_FOLLOW, v )
				ParticleManager:SetParticleControl( SunFx3,0, v:GetAbsOrigin())
				ParticleManager:SetParticleControl( SunFx3,1,Vector(400, 400, 0))
			end
			local SunFx4 = ParticleManager:CreateParticle("particles/econ/items/monkey_king/arcana/fire/mk_arcana_fire_spring_ring_radial.vpcf", PATTACH_CUSTOMORIGIN,nil )
			ParticleManager:SetParticleControl(SunFx4,0, sun:GetAbsOrigin()) 
			ParticleManager:SetParticleControl( SunFx4,1,Vector(400, 400, 0))
			sun:EmitSound("Ability.LightStrikeArray")
		end
		})
		Timers:CreateTimer(2.5,function()
			ParticleManager:DestroyParticle( SunFx2, false )
			ParticleManager:DestroyParticle( SunFx3, false )
			ParticleManager:DestroyParticle( SunFx4, false )
		end)
		target:EmitSound("Hero_EmberSpirit.FlameGuard.Cast")
		target:EmitSound("Hero_EmberSpirit.FlameGuard.Loop")
		target:EmitSound("Hero_Chen.HandOfGodHealHero")	
		--target:EmitSound("Ability.LightStrikeArray")
    elseif target:GetTeamNumber() == caster:GetTeamNumber() then
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_suns_embrace_ally",{})

		-- process team effect
		local healthDiff = target:GetMaxHealth() - target:GetHealth()
		--local targetMR = target:GetMagicalArmorValue()
		local targetActualMR = targetMR + (1-targetMR)*targetMR -- calculates actual MR of target after application of Sun's Embrace
		-- print(targetActualMR)
		local healAmount = healthDiff * 0.3 
		target:ApplyHeal(healAmount, caster)
	else
		-- process enemy effect
		-- DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)
		target:TriggerSpellReflect(keys.ability)
		if IsSpellBlocked(keys.target) then return end
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_suns_embrace_enemy",{})
		if caster.IsSunlightAcquired then
			keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_suns_embrace_sunlight_nerf",{})
		end
	end

	target:EmitSound("Hero_EmberSpirit.FlameGuard.Cast")
	target:EmitSound("Hero_EmberSpirit.FlameGuard.Loop")
	target:EmitSound("Hero_Chen.HandOfGodHealHero")
end

function OnEmbraceTickAlly(keys)
	local caster = keys.caster
	local target = keys.target
	local targets = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
	for k,v in pairs(targets) do
		keys.ability:ApplyDataDrivenModifier(keys.caster, v, "modifier_suns_embrace_burn",{})
	end
	if caster.IsSunlightAcquired then
		local targets2 = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets2) do
			v:ApplyHeal(keys.Damage/32, caster)
		end        
	end
end

function OnEmbraceTickEnemy(keys)
	local caster = keys.caster
	local target = keys.target
	if caster.IsSunlightAcquired then
		DoDamage(caster, target, target:GetMaxHealth()/50 , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	end
	local targets = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
	for k,v in pairs(targets) do
		keys.ability:ApplyDataDrivenModifier(keys.caster, v, "modifier_suns_embrace_burn",{})
	end
	if caster.IsSunlightAcquired then
		local targets2 = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, keys.Radius - 200, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets2) do
			v:ApplyHeal(keys.Damage/32, caster)
		end        
	end
end

function OnEmbraceDamageTick(keys)
	local caster = keys.caster
	local target = keys.target
	DoDamage(caster, target, keys.Damage/32 , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function OnEmbraceEnd(keys)
	local caster = keys.caster
	local target = keys.target
	print("ended")
	StopSoundEvent("Hero_EmberSpirit.FlameGuard.Loop", caster)
end

function OnSupernovaStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	--[[if target:HasModifier("modifier_invigorating_ray_ally") or target:HasModifier("modifier_invigorating_ray_enemy") then
	else
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Must Cast Both Q and R on Same Target" } )
		keys.ability:EndCooldown()
		return
	end]]

	keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_supernova", {})
	caster.IsComboActive = true
	caster.SunTable = {}

	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName(keys.ability:GetAbilityName())
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(keys.ability:GetCooldown(1))
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_supernova_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})


	Timers:CreateTimer(4.0, function()
		if target:IsAlive() then
			local particle = ParticleManager:CreateParticle("particles/custom/gawain/gawain_combo.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
			ParticleManager:SetParticleControl(particle, 1, Vector(400, 400, 400))
			Timers:CreateTimer( 3.0, function()
				ParticleManager:DestroyParticle( particle, false )
				ParticleManager:ReleaseParticleIndex( particle )
			end)
			EmitGlobalSound("Hero_Wisp.Relocate")
		end
	end)
	Timers:CreateTimer(5.0, function()
		if target:IsAlive() then
			local particle = ParticleManager:CreateParticle("particles/custom/gawain/gawain_combo.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
			ParticleManager:SetParticleControl(particle, 1, Vector(550, 550, 550))
			Timers:CreateTimer( 3.0, function()
				ParticleManager:DestroyParticle( particle, false )
				ParticleManager:ReleaseParticleIndex( particle )
			end)
		end
	end)
	Timers:CreateTimer(6.0, function()
		if target:IsAlive() then
			local particle = ParticleManager:CreateParticle("particles/custom/gawain/gawain_combo.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
			ParticleManager:SetParticleControl(particle, 1, Vector(700, 700, 700))
			Timers:CreateTimer( 3.0, function()
				ParticleManager:DestroyParticle( particle, false )
				ParticleManager:ReleaseParticleIndex( particle )
			end)
		end
	end)
	Timers:CreateTimer(7.0, function()
		if target:IsAlive() then
			local particle = ParticleManager:CreateParticle("particles/custom/gawain/gawain_combo.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
			ParticleManager:SetParticleControl(particle, 1, Vector(850, 850, 850))
			Timers:CreateTimer( 3.0, function()
				ParticleManager:DestroyParticle( particle, false )
				ParticleManager:ReleaseParticleIndex( particle )
			end)
		end
	end) 
	Timers:CreateTimer(8.0, function()
		if target:IsAlive() then
			local particle = ParticleManager:CreateParticle("particles/custom/gawain/gawain_combo.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
			ParticleManager:SetParticleControl(particle, 1, Vector(1000, 1000, 1000))
			Timers:CreateTimer( 3.0, function()
				ParticleManager:DestroyParticle( particle, false )
				ParticleManager:ReleaseParticleIndex( particle )
			end)
		end
	end) 
	target:EmitSound("Hero_Enigma.Black_Hole")
	Timers:CreateTimer(8.0, function()
		StopSoundEvent("Hero_Enigma.Black_Hole", target)
	end)
	target:EmitSound("DOTA_Item.BlackKingBar.Activate")
end

function OnCollapsarStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local targetPoint = keys.target_points[1]
	--[[if target:HasModifier("modifier_invigorating_ray_ally") or target:HasModifier("modifier_invigorating_ray_enemy") then
	else
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Must Cast Both Q and R on Same Target" } )
		keys.ability:EndCooldown()
		return
	end]]
	local dummytarget = CreateUnitByName("dummy_unit", targetPoint, false, caster, caster, caster:GetTeamNumber())
	caster.blackhole = dummytarget
	dummytarget:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
	dummytarget:AddNewModifier(caster, caster, "modifier_kill", {duration = 5})
    dummytarget:SetAbsOrigin(dummytarget:GetAbsOrigin() - Vector(0,0,100))
	
	keys.ability:ApplyDataDrivenModifier(caster, dummytarget, "modifier_collapsar", {})
	caster.IsComboActive = true
	caster.SunTable = {}

	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName("gawain_supernova")
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(keys.ability:GetCooldown(1))
	local nova=caster:FindAbilityByName("gawain_supernova")
	nova:StartCooldown(170)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_supernova_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})

	Timers:CreateTimer(0.25,function()
		local blockhole = ParticleManager:CreateParticle("particles/custom/gawain/black/enigma_blackhole_ti5.vpcf",PATTACH_ABSORIGIN_FOLLOW, dummytarget)
		--local blockhole1 = ParticleManager:CreateParticle("particles/custom/gawain/gawain_artificial_sun.vpcf",PATTACH_ABSORIGIN_FOLLOW, dummytarget)
		ParticleManager:SetParticleControl(blockhole, 0, Vector(6000,6000, 0))
		ParticleManager:SetParticleControl(blockhole, 1, Vector(6000,6000, 0))
		--ParticleManager:SetParticleControl(blockhole1, 0, Vector(6000,6000, 0))
		--ParticleManager:SetParticleControl(blockhole1, 1, Vector(6000,6000, 0))
	end)
	Timers:CreateTimer(4.2,function()
		ParticleManager:DestroyParticle(blockhole,ture)
		ParticleManager:DestroyParticle(blockhole)
		--ParticleManager:DestroyParticle(blockhole1,false)
		--ParticleManager:DestroyParticle(blockhole1)
		--local suo =  ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_sunray_energy.vpcf",PATTACH_ABSORIGIN_FOLLOW, dummytarget)
	end)
	Timers:CreateTimer(3.0, function()
		local particle = ParticleManager:CreateParticle("particles/custom/gawain/gawain_combo.vpcf", PATTACH_ABSORIGIN_FOLLOW, dummytarget)
		ParticleManager:SetParticleControl(particle, 0, Vector(1000,1000, 150))
		ParticleManager:SetParticleControl(particle, 1, Vector(1000,1000, 150))
		Timers:CreateTimer( 3.0, function()
			ParticleManager:DestroyParticle( particle, false )
			ParticleManager:ReleaseParticleIndex( particle )
		end)
		EmitGlobalSound("Hero_Wisp.Relocate")
	end)
	--Timers:CreateTimer(5.0,function()
		--ParticleManager:DestroyParticle(suo,false)
		--ParticleManager:DestroyParticle(suo)
	--end)
	dummytarget:EmitSound("Hero_Enigma.Black_Hole")
	Timers:CreateTimer(5.0, function()
		StopSoundEvent("Hero_Enigma.Black_Hole", dummytarget)
	end)
	dummytarget:EmitSound("DOTA_Item.BlackKingBar.Activate")
end

function OnCollapsarTick(keys)
	local ability=keys.ability
	local caster = keys.caster
	local target = keys.target
	local targets = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, 700, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false) 
	for k,v in pairs(targets) do
		if v:GetUnitName() == "gawain_artificial_sun" then
			if v.IsAddedToTable ~= true then
				table.insert(caster.SunTable, v)
				v.IsAddedToTable = true
				v.IsAttached = true
				v.AttachTarget = target
			end
		end
	end
	local target2 = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, 600, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
	for k,v in pairs(target2) do
		DoDamage(caster, v, 25, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
		local diff = (caster.blackhole:GetAbsOrigin()-v:GetAbsOrigin()):Normalized()
		local unit = Physics:Unit(v)
		v:SetPhysicsFriction(0)
		local ABSBRange = diff*300
		v:SetPhysicsVelocity(ABSBRange)
		v:SetNavCollisionType(PHYSICS_NAV_BOUNCE)
		v:OnPreBounce(function(unit, normal) 
			unit:OnPreBounce(nil)
		    unit:SetBounceMultiplier(0)
		    unit:PreventDI(false)
			unit:SetPhysicsVelocity(Vector(0,0,0))
			FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
		end)
		Timers:CreateTimer(0.43,function()         --0.43 is soft
			v:OnPreBounce(nil)
			v:SetBounceMultiplier(0)
			v:PreventDI(false)
			v:SetPhysicsVelocity(Vector(0,0,0))
			FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
		end)
	end
	local target3 =  FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, 200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(target3) do
		DoDamage(caster, v, 125, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
		ability:ApplyDataDrivenModifier(caster, v, "modifier_collapsar_slow", {0.25})
	end 
end

function OnSupernovaTick(keys)
	local caster = keys.caster
	local target = keys.target

	local targets = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, 700, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false) 
	for k,v in pairs(targets) do
		if v:GetUnitName() == "gawain_artificial_sun" then
			if v.IsAddedToTable ~= true then
				table.insert(caster.SunTable, v)
				v.IsAddedToTable = true
				v.IsAttached = true
				v.AttachTarget = target
			end
		end
	end
end

function OnSupernovaEnd(keys)
	local caster = keys.caster
	local target = keys.target
	local sunCount = #caster.SunTable
	local dmg = keys.Damage
	caster.IsComboActive = false

	for i=1, sunCount do
		caster.SunTable[i]:ForceKill(true)
		if i-1 ~= 0 then
			dmg = dmg + keys.Damage * (0.66 ^ (i-1))
		end
	end

	local targets = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, 1000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
	for k,v in pairs(targets) do
		DoDamage(caster, v, dmg, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
		v:AddNewModifier(caster, caster, "modifier_stunned", {Duration = 2.0})
	end

	local lightFx1 = ParticleManager:CreateParticle("particles/custom/gawain/gawain_supernova_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( lightFx1, 0, target:GetAbsOrigin())
	local splashFx = ParticleManager:CreateParticle("particles/custom/screen_yellow_splash_gawain.vpcf", PATTACH_EYES_FOLLOW, caster)
	Timers:CreateTimer( 3.0, function()
		ParticleManager:DestroyParticle( lightFx1, false )
		ParticleManager:ReleaseParticleIndex( lightFx1 )
		ParticleManager:DestroyParticle( splashFx, false )
		ParticleManager:ReleaseParticleIndex( splashFx )
	end)
	EmitGlobalSound("Hero_Phoenix.SuperNova.Explode")
	StopSoundEvent("Hero_Enigma.Black_Hole", target)
end

function GenerateArtificialSun(caster, location)
	local ply = caster:GetPlayerOwner()
	local IsSunActive = true
	local radius = 555
	local artSun = CreateUnitByName("gawain_artificial_sun", location, true, nil, nil, caster:GetTeamNumber())
	caster:FindAbilityByName("gawain_solar_embodiment"):ApplyDataDrivenModifier(caster, artSun, "modifier_artificial_sun_aura", {})
	if caster.IsDawnAcquired then
		radius = 777
		artSun:AddNewModifier(caster, caster, "modifier_item_ward_true_sight", {true_sight_range = 333}) 
	end
	artSun:SetDayTimeVisionRange(radius)
	artSun:SetNightTimeVisionRange(radius)
	artSun:AddNewModifier(caster, caster, "modifier_kill", {duration = 15})
	artSun:SetAbsOrigin(artSun:GetAbsOrigin() + Vector(0,0, 500))


	if caster.IsDawnAcquired then
		artSun.IsAttached = true

		local targets = FindUnitsInRadius(caster:GetTeam(), location, nil, 555, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false) 
		--print("finding targets")
		if #targets == 0 then
			artSun.IsAttached = false
		else
			--print("found target " .. targets[1]:GetUnitName())
			artSun.AttachTarget = targets[1]
		end
	end

	Timers:CreateTimer(9, function()
		if IsValidEntity(artSun) and not artSun:IsNull() and artSun:IsAlive() and caster.IsComboActive ~= true then
			artSun:ForceKill(true)
		end
	end)
end

function OnSunPassiveThink(keys)
	local target = keys.target
	if target.IsAttached and target.AttachTarget ~= nil then
		target:SetAbsOrigin(target.AttachTarget:GetAbsOrigin() + Vector(0,0,500))
	end
end

function OnFairyDamageTaken(keys)
	local caster = keys.caster
	local ability = keys.ability
	local currentHealth = caster:GetHealth()

	if currentHealth == 0 and keys.ability:IsCooldownReady() and IsRevivePossible(caster) and keys.DamageTaken <= 4000 then
		caster:SetHealth(500 + caster:GetStrength() * 5)
		keys.ability:StartCooldown(60) 
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_gawain_blessing_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})
		local particle = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(particle, 3, caster:GetAbsOrigin())
		Timers:CreateTimer( 3.0, function()
			ParticleManager:DestroyParticle( particle, false )
			ParticleManager:ReleaseParticleIndex( particle )
		end)
		local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 250, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
		for k,v in pairs(targets) do
			DoDamage(caster,v, 350, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
		end
	end
end

function OnMeltdownStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 20000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false) 
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_meltdown_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})
	for k,v in pairs(targets) do
		if v:GetUnitName() == "gawain_artificial_sun" then
			keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_divine_meltdown", {})

			v:EmitSound("Hero_DoomBringer.ScorchedEarthAura")
			v:EmitSound("Hero_Warlock.RainOfChaos_buildup" )
			v.metldownFx = ParticleManager:CreateParticle("particles/custom/gawain/gawain_meltdown.vpcf", PATTACH_ABSORIGIN_FOLLOW, v )
			ParticleManager:SetParticleControl( v.metldownFx, 0, v:GetAbsOrigin())
			Timers:CreateTimer(5.0, function()
				if IsValidEntity(v) and v:IsAlive() then
					ParticleManager:DestroyParticle( v.metldownFx, false )
					ParticleManager:ReleaseParticleIndex( v.metldownFx )				
				end
				StopSoundOn("Hero_DoomBringer.ScorchedEarthAura", v)
			end)
			--print("found sun")
		end
	end
end

function OnMeltdownThink(keys)
	local caster = keys.caster
	local target = keys.target
	if target.MeltdownCounter == nil then 
		target.MeltdownCounter = 6
	else
		target.MeltdownCounter = target.MeltdownCounter - 0.375
	end
	print(target.MeltdownCounter)
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 600, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
	for k,v in pairs(targets) do
		DoDamage(caster, v, v:GetHealth() * target.MeltdownCounter/100, DAMAGE_TYPE_PURE, 0, keys.ability, false)
	end

end

function OnSunCleanup(keys)
	local caster = keys.caster
	local target = keys.target
	if target.metldownFx ~= nil then
		ParticleManager:DestroyParticle( target.metldownFx, false )
		ParticleManager:ReleaseParticleIndex( target.metldownFx )
		StopSoundOn("Hero_DoomBringer.ScorchedEarthAura", target)
	end
end

function GawainCheckCombo(caster, ability)
	if caster:GetStrength() >= 19.1 and caster:GetAgility() >= 19.1 and caster:GetIntellect() >= 19.1 then
		if ability == caster:FindAbilityByName("gawain_invigorating_ray") and caster:FindAbilityByName("gawain_suns_embrace"):IsCooldownReady() and caster:FindAbilityByName("gawain_supernova"):IsCooldownReady() then
			if caster.IsEclipseAcquired and caster:FindAbilityByName("gawain_supernova"):IsCooldownReady() then
				caster:SwapAbilities("gawain_suns_embrace", "gawain_collapsar", false, true) 
				Timers:CreateTimer({
					endTime = 3,
					callback = function()
					caster:SwapAbilities("gawain_suns_embrace", "gawain_collapsar", true, false) 
				end
				})
			else
				caster:SwapAbilities("gawain_suns_embrace", "gawain_supernova", false, true) 
				Timers:CreateTimer({
					endTime = 3,
					callback = function()
					caster:SwapAbilities("gawain_suns_embrace", "gawain_supernova", true, false) 
				end
				})
			end			
		end
	end
end


function OnDawnAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    hero.IsDawnAcquired = true
    hero:FindAbilityByName("gawain_solar_embodiment"):SetLevel(2)
    -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnFairyAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    hero.IsFairyAcquired = true

    hero:AddAbility("gawain_blessing_of_fairy")
    hero:FindAbilityByName("gawain_blessing_of_fairy"):SetLevel(1)
    hero:FindAbilityByName("gawain_blessing_of_fairy"):SetHidden(true)
    --hero:SwapAbilities(hero:GetAbilityByIndex(4):GetName(), "gawain_blessing_of_fairy", true, true)
    -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnMeltdownAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    hero.IsMeltdownAcquired = true
    hero:SwapAbilities(hero:GetAbilityByIndex(4):GetName(), "gawain_divine_meltdown", false, true)
    -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnSunlightAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()

    hero.IsSunlightAcquired = true
    caster:FindAbilityByName("gawain_attribute_eclipse"):StartCooldown(9999)
    -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnEclipseAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()

    hero.IsEclipseAcquired = true
	caster:FindAbilityByName("gawain_attribute_sunlight"):StartCooldown(9999)
	hero:SwapAbilities("gawain_invigorating_ray","gawain_invigorating_ray_eclipse", false,true)
    -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end


