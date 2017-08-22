ATTR_HEARTSEEKER_AD_RATIO = 2
ATTR_HEARTSEEKER_COMBO_AD_RATIO = 2

function OnPFAStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:RemoveModifierByName("modifier_lancer_protection_from_arrows")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_lancer_protection_from_arrows_active", {duration=3})
	caster:EmitSound("DOTA_Item.Buckler.Activate")
	StartAnimation(caster, {duration=1, activity=ACT_DOTA_CAST_ABILITY_1, rate=0.45})
	Timers:CreateTimer(3.0, function()
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_lancer_protection_from_arrows", {})
	end)

end

function OnPFAThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	ProjectileManager:ProjectileDodge(caster)
end

function OnBattleContinuationStart(keys)
	local caster = keys.caster
	local ability = keys.ability
end

function LancerOnTakeDamage(keys)
	local caster = keys.caster
	local ability = keys.ability
	local currentHealth = caster:GetHealth()
	local ply = caster:GetPlayerOwner()

	local lowend = 300
	local highend = 1000
	local cd = 60
	local health = 1
	if caster.IsBCImproved == true then
		lowend = 200
		highend = 1200
		cd = 30
		health = 500
	end
	if currentHealth == 0 and keys.ability:IsCooldownReady() and keys.DamageTaken <= highend and keys.DamageTaken >= lowend and IsRevivePossible(caster) then
		caster:SetHealth(health)
		keys.ability:StartCooldown(cd) 
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_battle_continuation_cooldown", {duration = cd})
		local reviveFx = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(reviveFx, 3, caster:GetAbsOrigin())

		Timers:CreateTimer( 3.0, function()
			ParticleManager:DestroyParticle( reviveFx, false )
		end)
	end
end

function RuneMagicOpen(keys)
	local caster = keys.caster
	local a1 = caster:GetAbilityByIndex(0)
	local a2 = caster:GetAbilityByIndex(1)
	local a3 = caster:GetAbilityByIndex(2)
	local a4 = caster:GetAbilityByIndex(3)
	local a5 = caster:GetAbilityByIndex(4)
	local a6 = caster:GetAbilityByIndex(5)
	caster:SwapAbilities("lancer_5th_rune_of_disengage", a1:GetName(), true, false) 
	caster:SwapAbilities("lancer_5th_rune_of_replenishment", a2:GetName(), true, false) 
	if a3:GetName() == "lancer_5th_wesen_gae_bolg" then
		caster:SwapAbilities("lancer_5th_rune_of_trap", a3:GetName(), true, false) 
	else
		caster:SwapAbilities("lancer_5th_rune_of_trap", a3:GetName(), true, false)
	end 
	caster:SwapAbilities("lancer_5th_rune_of_flame", a4:GetName(), true, false) 
	caster:SwapAbilities("lancer_5th_close_spellbook", a5:GetName(), true, false) 
	caster:SwapAbilities("lancer_5th_rune_of_conversion", a6:GetName(), true, false)
	keys.ability:ToggleAbility()
end

function RuneLevelUp(keys)
	local caster = keys.caster
	
	local hAbility = nil
	local tAbilities = {
		"lancer_5th_rune_of_disengage",
		"lancer_5th_rune_of_replenishment",
		"lancer_5th_rune_of_trap",
		"lancer_5th_rune_of_flame",
		"lancer_5th_rune_of_conversion",
	}
	
	for k, v in pairs(tAbilities) do
		hAbility = caster:FindAbilityByName(v)
		hAbility:SetLevel(keys.ability:GetLevel())
		hAbility:EndCooldown()
	end
end

function RuneMagicUsed(keys)
	local caster = keys.caster
	local a1 = caster:GetAbilityByIndex(0)
	local a2 = caster:GetAbilityByIndex(1)
	local a3 = caster:GetAbilityByIndex(2)
	local a4 = caster:GetAbilityByIndex(3)
	local a5 = caster:GetAbilityByIndex(4)
	local a6 = caster:GetAbilityByIndex(5)
	caster:FindAbilityByName("lancer_5th_rune_of_disengage"):StartCooldown(20)
	caster:FindAbilityByName("lancer_5th_rune_of_replenishment"):StartCooldown(20)
	caster:FindAbilityByName("lancer_5th_rune_of_trap"):StartCooldown(20)
	caster:FindAbilityByName("lancer_5th_rune_of_flame"):StartCooldown(20)
	caster:FindAbilityByName("lancer_5th_rune_of_conversion"):StartCooldown(20)
	caster:SwapAbilities(a1:GetName(), "lancer_5th_rune_magic", true, true) 
	caster:SwapAbilities(a2:GetName(), "lancer_5th_relentless_spear", true, true) 
	caster:SwapAbilities(a3:GetName(), "lancer_5th_gae_bolg", true, true) 
	caster:SwapAbilities(a4:GetName(), "lancer_5th_battle_continuation", true, true) 
	caster:SwapAbilities(a5:GetName(), "fate_empty1", true, true) 
	caster:SwapAbilities(a6:GetName(), "lancer_5th_gae_bolg_jump", true, true) 
	caster:FindAbilityByName("lancer_5th_rune_magic"):StartCooldown(20)
end

function RuneMagicClose(keys)
	local caster = keys.caster
	local a1 = caster:GetAbilityByIndex(0)
	local a2 = caster:GetAbilityByIndex(1)
	local a3 = caster:GetAbilityByIndex(2)
	local a4 = caster:GetAbilityByIndex(3)
	local a5 = caster:GetAbilityByIndex(4)
	local a6 = caster:GetAbilityByIndex(5)
	caster:SwapAbilities(a1:GetName(), "lancer_5th_rune_magic", false, true) 
	caster:SwapAbilities(a2:GetName(), "lancer_5th_relentless_spear", false, true) 
	caster:SwapAbilities(a3:GetName(), "lancer_5th_gae_bolg", false, true) 
	caster:SwapAbilities(a4:GetName(), "lancer_5th_battle_continuation", false, true) 
	if caster.IsPFAAcquired then
		caster:SwapAbilities(a5:GetName(), "lancer_5th_protection_from_arrows", false, true) 
	else
		caster:SwapAbilities(a5:GetName(), "fate_empty1", false, true) 
	end
	caster:SwapAbilities(a6:GetName(), "lancer_5th_gae_bolg_jump", false, true) 
	keys.ability:ToggleAbility()
	--caster:GetAbilityByIndex(0):EndCooldown() 

end

function Disengage(keys)
	local caster = keys.caster
	local backward = caster:GetForwardVector() * keys.Distance
	local newLoc = caster:GetAbsOrigin() - backward
	local diff = newLoc - caster:GetAbsOrigin()

	HardCleanse(caster)
	local i = 1
	while GridNav:IsBlocked(newLoc) or not GridNav:IsTraversable(newLoc) or i == 100 do
		i = i+1
		newLoc = caster:GetAbsOrigin() + diff:Normalized() * (keys.Distance - i*10)
	end
	Timers:CreateTimer(0.033, function() 
		caster:SetAbsOrigin(newLoc)
		ProjectileManager:ProjectileDodge(caster) 
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
	end)
end

function Trap(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local stunDuration = keys.StunDuration
	local trapDuration = 0
	local radius = keys.Radius

	local lancertrap = CreateUnitByName("lancer_trap", targetPoint, true, caster, caster, caster:GetTeamNumber())
	Timers:CreateTimer(1.0, function()
		LevelAllAbility(lancertrap)
		return
	end)


	local targets = nil
	
    Timers:CreateTimer(function()
    	if not lancertrap:IsAlive() then return end
        targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) -- find enemies in radius

        -- if enemy is found, spring the trap
        for k,v in pairs(targets) do
        	if v ~= nil then
				SpringTrap(lancertrap, caster, stunDuration, targetPoint, radius) -- activate trap
				return
			end
		end

        trapDuration = trapDuration + 1;
        if trapDuration == 450 then
        	trapDuration =0 
        	lancertrap:ForceKill(true)
        	return 
        end
      	return 0.1
    end
    )
end

function SpringTrap(trap, caster, stunduration, targetpoint, radius)
	trap:RemoveAbility("lancer_trap_passive") 
	Timers:CreateTimer({
		endTime = 1,
		callback = function()
		if trap:IsAlive() then
			trap:EmitSound("Hero_TemplarAssassin.Trap.Explode")
			local targets = FindUnitsInRadius(caster:GetTeam(), targetpoint, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			for k,v in pairs(targets) do
				v:AddNewModifier(caster, v, "modifier_stunned", {Duration = stunduration})
			end
			trap:ForceKill(true) 
			trap:AddEffects(EF_NODRAW)

			local fxDummy = CreateUnitByName("dummy_unit", trap:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
			fxDummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)

			local trapFX = ParticleManager:CreateParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_trap_explode.vpcf", PATTACH_ABSORIGIN_FOLLOW, fxDummy)
			ParticleManager:SetParticleControl(trapFX, 0, fxDummy:GetAbsOrigin())

			Timers:CreateTimer(5, function()
				ParticleManager:DestroyParticle(trapFX, false )
				fxDummy:RemoveSelf()
			end)
		end
	end
	})
end

function Conversion(keys)
	local caster = keys.caster
	local currentHealth = caster:GetHealth()
	local currentMana = caster:GetMana()
	local healthLost = currentHealth * keys.Percentage / 100
	local finalHealth = currentHealth - healthLost

	if finalHealth > 1 then 
		caster:SetHealth(currentHealth - healthLost) 
	else
		caster:SetHealth(1)
	end
	caster:SetMana(currentMana + healthLost)

    local pcMana = ParticleManager:CreateParticle("particles/items2_fx/shadow_amulet_activate_end_flash.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:ReleaseParticleIndex(pcMana)
end

function OnIncinerateHit(keys)
	local caster = keys.caster
	local target = keys.target

	if caster:GetAttackTarget():GetName() == "npc_dota_ward_base" then
		print("Attacking Ward")
		return
	end

	local currentStack = target:GetModifierStackCount("modifier_lancer_incinerate", keys.ability)

	if currentStack == 0 and target:HasModifier("modifier_lancer_incinerate") then currentStack = 1 end
	target:RemoveModifierByName("modifier_lancer_incinerate") 
	keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_lancer_incinerate", {}) 
	target:SetModifierStackCount("modifier_lancer_incinerate", keys.ability, currentStack + 1)

	DoDamage(caster, target, keys.ExtraDamage*currentStack, DAMAGE_TYPE_PURE, 0, keys.ability, false)
end

function OnRAStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_aspd_increase", {duration = ability:GetCooldown(ability:GetLevel())})
	LancerCheckCombo(caster, ability)
end

function GBAttachEffect(keys)
	local caster = keys.caster
	local GBCastFx = ParticleManager:CreateParticle("particles/units/heroes/hero_chaos_knight/chaos_knight_reality_rift.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(GBCastFx, 1, caster:GetAbsOrigin()) -- target effect location
	ParticleManager:SetParticleControl(GBCastFx, 2, caster:GetAbsOrigin()) -- circle effect location
	Timers:CreateTimer( 3.0, function()
		ParticleManager:DestroyParticle( GBCastFx, false )
	end)

	if keys.ability == caster:FindAbilityByName("lancer_5th_gae_bolg") then
		caster:EmitSound("Lancer.GaeBolg")
	elseif keys.ability == caster:FindAbilityByName("lancelot_gae_bolg") then 
		caster:EmitSound("Lancelot.Growl_Local" )
	end

end


function OnGBTargetHit(keys)
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker

	local caster = keys.caster
	local casterName = caster:GetName()
	local target = keys.target
	local ability = keys.ability
	local ply = caster:GetPlayerOwner()
	if caster.IsHeartSeekerAcquired == true then keys.HBThreshold = keys.HBThreshold + caster:GetAttackDamage()*ATTR_HEARTSEEKER_AD_RATIO end

	-- Check if caster is lancer(not lancelot)
	if casterName == "npc_dota_hero_phantom_lancer" then
		local runeAbil = caster:FindAbilityByName("lancer_5th_rune_of_flame")
		local healthDamagePct = runeAbil:GetLevelSpecialValueFor("ability_bonus_damage", runeAbil:GetLevel()-1)
		if caster.IsGaeBolgImproved == true then
		healthDamagePct = healthDamagePct * 2
		end
		keys.Damage = keys.Damage + target:GetHealth()*healthDamagePct/100
	else
		StartAnimation(caster, {duration=0.3, activity=ACT_DOTA_CAST_ABILITY_1, rate=3})
	end

	giveUnitDataDrivenModifier(caster, target, "can_be_executed", 0.033)
	DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	target:AddNewModifier(caster, target, "modifier_stunned", {Duration = 1.0})
	if target:GetHealth() < keys.HBThreshold then
		PlayHeartBreakEffect(ability, caster, target)
	end  -- check for HB

	-- if Gae Bolg is improved, do 3 second dot over time
	--[[if caster.IsGaeBolgImproved == true then 
		local dotCount = 0
		Timers:CreateTimer(function() 
			if dotCount == 3 then return end
			DoDamage(caster, target, target:GetMaxHealth()/30, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
			dotCount = dotCount + 1
			return 1.0 
		end)
	end]]

	--[[
	-- if Heart Seeker attribute is acquired, check for HB condition every 0.3 seconds
	if caster.IsHeartSeekerAcquired == true then
		local dotCount = 0
		Timers:CreateTimer(function() 
			if dotCount == 10 then return end
			if target:GetHealth() < keys.HBThreshold then 
				if target:GetHealth() ~= 0 then 
					PlayHeartBreakEffect(target)

				end 
				target:Kill(keys.ability, caster) 
			end 
			dotCount = dotCount + 1
			return 0.3
		end)
	end]]
	if ability:GetAbilityName() == "lancer_5th_gae_bolg" then
		StartAnimation(caster, {duration=0.3, activity=ACT_DOTA_ATTACK, rate=3})
	end
	-- Add dagon particle
	local dagon_particle = ParticleManager:CreateParticle("particles/items_fx/dagon.vpcf",  PATTACH_ABSORIGIN_FOLLOW, keys.caster)
	ParticleManager:SetParticleControlEnt(dagon_particle, 1, keys.target, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.target:GetAbsOrigin(), false)
	local particle_effect_intensity = 600
	ParticleManager:SetParticleControl(dagon_particle, 2, Vector(particle_effect_intensity))
	target:EmitSound("Hero_Lion.Impale")
	PlayNormalGBEffect(target)
	-- Blood splat
	local splat = ParticleManager:CreateParticle("particles/generic_gameplay/screen_blood_splatter.vpcf", PATTACH_EYES_FOLLOW, target)

	Timers:CreateTimer( 3.0, function()
		ParticleManager:DestroyParticle( dagon_particle, false )
		ParticleManager:DestroyParticle( splat, false )
	end)
end

function PlayHeartBreakEffect(ability, killer, target)
	if target:HasModifier("modifier_avalon") then return end
	local culling_kill_particle = ParticleManager:CreateParticle("particles/custom/lancer/lancer_culling_blade_kill.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 2, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 4, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 8, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(culling_kill_particle)

	local hb = ParticleManager:CreateParticle("particles/custom/lancer/lancer_heart_break_txt.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl( hb, 0, target:GetAbsOrigin())

	Timers:CreateTimer( 3.0, function()
		ParticleManager:DestroyParticle( culling_kill_particle, false )
		ParticleManager:DestroyParticle( hb, false )
	end)
	target:Execute(ability, killer, { bExecution = true })
end

function PlayNormalGBEffect(target)
	local culling_kill_particle = ParticleManager:CreateParticle("particles/custom/lancer/lancer_culling_blade_kill.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 2, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 4, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 8, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(culling_kill_particle)
	
	Timers:CreateTimer( 3.0, function()
		ParticleManager:DestroyParticle( culling_kill_particle, false )
	end)
end 

function OnGBComboHit(keys)
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ply = caster:GetPlayerOwner()
	local HBThreshold = target:GetMaxHealth() * keys.HBThreshold / 100
	local silenceDuration = keys.SilenceDuration


	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName(keys.ability:GetAbilityName())
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(keys.ability:GetCooldown(1))
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_wesen_gae_bolg_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})

	if caster.IsHeartSeekerAcquired == true then HBThreshold = HBThreshold + caster:GetAttackDamage()*ATTR_HEARTSEEKER_COMBO_AD_RATIO end

	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 3.0)
	giveUnitDataDrivenModifier(caster, target, "silenced", silenceDuration)
	StartAnimation(caster, {duration=1.2, activity=ACT_DOTA_CAST_ABILITY_1, rate=0.5})
	Timers:CreateTimer(1.6, function()
		StartAnimation(caster, {duration=3, activity=ACT_DOTA_RUN, rate=3})
	end)
	caster:EmitSound("Lancer.Heartbreak")
	target:EmitSound("Lancer.Heartbreak")
	caster:FindAbilityByName("lancer_5th_gae_bolg"):StartCooldown(27.0)
	if target:IsAlive() then
	  	Timers:CreateTimer(1.8, function() 
			if (caster:GetAbsOrigin().y < -2000 and target:GetAbsOrigin().y > -2000) or (caster:GetAbsOrigin().y > -2000 and target:GetAbsOrigin().y < -2000) then 
				StopSoundEvent("Lancer.Heartbreak", caster)
				StopSoundEvent("Lancer.Heartbreak", target)
				return 
			end
		    local lancer = Physics:Unit(caster)

		    keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_wesen_gae_bolg_pierce_anim", {})

		    caster:OnHibernate(function(unit)
		    	caster:SetPhysicsVelocity((keys.target:GetAbsOrigin() - keys.caster:GetAbsOrigin()):Normalized() * 3000)
		    	caster:PreventDI()
		    	caster:SetPhysicsFriction(0)
		    	caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
		    	caster:FollowNavMesh(false)	
		    	caster:SetAutoUnstuck(false)
		    	caster:OnPhysicsFrame(function(unit)
					local diff = target:GetAbsOrigin() - caster:GetAbsOrigin()
					local dir = diff:Normalized()
					unit:SetPhysicsVelocity(dir * 3000)

					Timers:CreateTimer(0.15, function()
						if diff:Length()>100 and (caster:GetAbsOrigin().y < -2000 and target:GetAbsOrigin().y > -2000) or (caster:GetAbsOrigin().y > -2000 and target:GetAbsOrigin().y < -2000) == false then
							caster:SetAbsOrigin(target:GetAbsOrigin() - target:GetForwardVector():Normalized()*100)
							FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
						end
					end)

					if diff:Length() < 100 then
				  		caster:RemoveModifierByName("pause_sealdisabled")
						unit:PreventDI(false)
						unit:SetPhysicsVelocity(Vector(0,0,0))
						unit:OnPhysicsFrame(nil)
						unit:OnHibernate(nil)
						unit:SetAutoUnstuck(true)
			        	FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)

				        if caster:IsAlive() then 
				        	local RedScreenFx = ParticleManager:CreateParticle("particles/custom/screen_red_splash.vpcf", PATTACH_EYES_FOLLOW, caster)
				        	Timers:CreateTimer( 3.0, function()
								ParticleManager:DestroyParticle( RedScreenFx, false )
							end)
			        		target:EmitSound("Hero_Lion.Impale")
			        		StartAnimation(caster, {duration=0.3, activity=ACT_DOTA_ATTACK2, rate=2})
							local runeAbil = caster:FindAbilityByName("lancer_5th_rune_of_flame")
							local healthDamagePct = runeAbil:GetLevelSpecialValueFor("ability_bonus_damage", runeAbil:GetLevel()-1)
							if caster.IsGaeBolgImproved == true then
							healthDamagePct = healthDamagePct * 2
							end

							giveUnitDataDrivenModifier(caster, target, "can_be_executed", 0.033)
				    		DoDamage(caster, target, keys.Damage + target:GetHealth() * healthDamagePct/100, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
							target:AddNewModifier(caster, target, "modifier_stunned", {Duration = 1.0})

							PlayNormalGBEffect(target)
							if target:GetHealth() < HBThreshold then 
								PlayHeartBreakEffect(ability, caster, target)
							end
						end
					end
				end)
		    end)


			return
		end)
	end
end

function OnGBAOEStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local targetPoint = keys.target_points[1]
	local radius = keys.Radius
	local projectileSpeed = 1900
	local ply = caster:GetPlayerOwner()
	local ascendCount = 0
	local descendCount = 0
	if (caster:GetAbsOrigin() - targetPoint):Length2D() > 2500 then 
		caster:SetMana(caster:GetMana()+keys.ability:GetManaCost(keys.ability:GetLevel()-1)) 
		keys.ability:EndCooldown() 
		return
	end
	
	EmitGlobalSound("Lancer.GaeBolg")
	giveUnitDataDrivenModifier(caster, caster, "jump_pause", 0.8)
	Timers:CreateTimer(0.8, function()
		giveUnitDataDrivenModifier(caster, caster, "jump_pause_postdelay", 0.15)
	end)
	Timers:CreateTimer(0.95, function()
		giveUnitDataDrivenModifier(caster, caster, "jump_pause_postlock", 0.2)
	end)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_gae_jump_throw_anim", {}) 

	Timers:CreateTimer('gb_throw', {
		endTime = 0.45,
		callback = function()
		local projectileOrigin = caster:GetAbsOrigin() + Vector(0,0,300)
		local projectile = CreateUnitByName("dummy_unit", projectileOrigin, false, caster, caster, caster:GetTeamNumber())
		projectile:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
		projectile:SetAbsOrigin(projectileOrigin)

		local particle_name = "particles/custom/lancer/lancer_gae_bolg_projectile.vpcf"
		local throw_particle = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, projectile)
		ParticleManager:SetParticleControl(throw_particle, 1, (targetPoint - projectileOrigin):Normalized() * projectileSpeed)

		local travelTime = (targetPoint - projectileOrigin):Length() / projectileSpeed
		Timers:CreateTimer(travelTime, function()
			ParticleManager:DestroyParticle(throw_particle, false)
			OnGBAOEHit(keys, projectile)
		end)
	end
	})

	Timers:CreateTimer('gb_ascend', {
		endTime = 0,
		callback = function()
	   	if ascendCount == 15 then return end
		caster:SetAbsOrigin(Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z+50))
		ascendCount = ascendCount + 1;
		return 0.033
	end
	})

	Timers:CreateTimer("gb_descend", {
	    endTime = 0.3,
	    callback = function()
	    	if descendCount == 15 then return end
			caster:SetAbsOrigin(Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z-50))
			descendCount = descendCount + 1;
	      	return 0.033
	    end
	})
end

function OnGBAOEHit(keys, projectile)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local radius = keys.ability:GetSpecialValueFor("radius")
	local damage = keys.ability:GetSpecialValueFor("damage")
	local ply = caster:GetPlayerOwner()
	if caster.IsGaeBolgImproved == true then damage = damage + 250 end
	local runeAbil = caster:FindAbilityByName("lancer_5th_rune_of_flame")
	local healthDamagePct = runeAbil:GetLevelSpecialValueFor("ability_bonus_damage", runeAbil:GetLevel()-1)
	if caster.IsGaeBolgImproved == true then
		healthDamagePct = healthDamagePct * 2
	end
	
	local modifierKnockback =
	{
		center_x = targetPoint.x,
		center_y = targetPoint.y,
		center_z = targetPoint.z,
		duration = 0.25,
		knockback_duration = 0.25,
		knockback_distance = 0,
		knockback_height = 150,
	}

	Timers:CreateTimer(0.15, function()
		local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, radius
	            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
	        DoDamage(caster, v, damage + v:GetHealth() * healthDamagePct/100, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	        v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 0.1})
	        v:AddNewModifier(v, nil, "modifier_knockback", modifierKnockback )
	    end
	    projectile:SetAbsOrigin(targetPoint)
	    local fire = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_rainofchaos_start_breakout_fallback_mid.vpcf", PATTACH_ABSORIGIN, projectile)
		local crack = ParticleManager:CreateParticle("particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp_cracks.vpcf", PATTACH_ABSORIGIN, projectile)
		local explodeFx1 = ParticleManager:CreateParticle("particles/custom/lancer/lancer_gae_bolg_hit.vpcf", PATTACH_ABSORIGIN, projectile )
		ParticleManager:SetParticleControl( fire, 0, projectile:GetAbsOrigin())
		ParticleManager:SetParticleControl( crack, 0, projectile:GetAbsOrigin())
		ParticleManager:SetParticleControl( explodeFx1, 0, projectile:GetAbsOrigin())
		ScreenShake(caster:GetOrigin(), 7, 1.0, 2, 2000, 0, true)
		caster:EmitSound("Misc.Crash")
	    Timers:CreateTimer( 3.0, function()
			ParticleManager:DestroyParticle( crack, false )
			ParticleManager:DestroyParticle( fire, false )
			ParticleManager:DestroyParticle( explodeFx1, false )
		end)
	end)

end

function LancerCheckCombo(caster, ability)
	if caster:GetStrength() >= 19.1 and caster:GetAgility() >= 19.1 and caster:GetIntellect() >= 19.1 then
		if ability == caster:FindAbilityByName("lancer_5th_relentless_spear") and caster:FindAbilityByName("lancer_5th_gae_bolg"):IsCooldownReady() and caster:FindAbilityByName("lancer_5th_wesen_gae_bolg"):IsCooldownReady()  then
                        if not caster:FindAbilityByName("lancer_5th_wesen_gae_bolg"):IsHidden() then return end
			caster:SwapAbilities("lancer_5th_gae_bolg", "lancer_5th_wesen_gae_bolg", false, true) 
			Timers:CreateTimer({
				endTime = 3,
				callback = function()
				if caster:GetAbilityByIndex(2):GetName() == "lancer_5th_wesen_gae_bolg" then 
					caster:SwapAbilities("lancer_5th_gae_bolg", "lancer_5th_wesen_gae_bolg", true, false) 
				end
			end
			})
		end
	end
end

function OnImrpoveBCAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsBCImproved = true
	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnImrpoveGaeBolgAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsGaeBolgImproved = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnPFAAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero:FindAbilityByName("lancer_5th_protection_from_arrows"):SetLevel(1) 
	hero:SwapAbilities("fate_empty1" , "lancer_5th_protection_from_arrows", false, true)
	hero.IsPFAAcquired = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnHeartseekerAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsHeartSeekerAcquired = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end
