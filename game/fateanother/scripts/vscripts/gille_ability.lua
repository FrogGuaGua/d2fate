function OnMadnessStart(keys)
	local caster = keys.caster
	caster.MadnessStackCount = 0

	if not caster:HasModifier("modifier_madness_stack") then
		caster:FindAbilityByName("gille_spellbook_of_prelati"):ApplyDataDrivenModifier(caster, caster, "modifier_madness_stack", {})
	end
	if not caster:HasModifier("modifier_madness_progress") then
		caster:FindAbilityByName("gille_spellbook_of_prelati"):ApplyDataDrivenModifier(caster, caster, "modifier_madness_progress", {})
	end
	caster:SetModifierStackCount("modifier_madness_stack", caster,0) 
	caster.MadnessProgress = 0
	AdjustMadnessStack(caster, 1)
	UpdateMadnessProgress(caster)
end

function OnMadnessThink(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()

	local progress = ( 5 + caster:GetIntellect() * 0.35 + (caster:FindModifierByName("modifier_attr_manaregen"):GetStackCount() * 1.5) or 0 ) *0.05
	local maxMadness = 200
	if caster.IsMentalPolluted then
		progress = progress + 0.25
		maxMadness = maxMadness + 100
	end

	if caster:GetModifierStackCount("modifier_madness_stack", caster) >= maxMadness then
		caster.MadnessProgress = 0
		AdjustMadnessStack(caster, caster.MadnessProgress)
	else
		caster.MadnessProgress = progress
		AdjustMadnessStack(caster, caster.MadnessProgress)
	end
	UpdateMadnessProgress(caster)
end

function AdjustMadnessStack(caster, adjustValue)
	local ply = caster:GetPlayerOwner()
	local maxMadness = 200
	if caster.IsMentalPolluted then maxMadness = 300 end
	caster.MadnessStackCount = caster.MadnessStackCount + adjustValue


	if caster.MadnessStackCount > maxMadness then
		caster.MadnessStackCount = maxMadness
	end

	if caster.MadnessStackCount < 0 then
		caster.MadnessStackCount = 0
	end
	caster:RemoveModifierByName("modifier_madness_stack")
	caster:FindAbilityByName("gille_spellbook_of_prelati"):ApplyDataDrivenModifier(caster, caster, "modifier_madness_stack", {})
	caster:SetModifierStackCount("modifier_madness_stack", caster, caster.MadnessStackCount) 
	caster:SetMana(caster.MadnessStackCount)
end

function UpdateMadnessProgress(caster)
	local progress = caster.MadnessProgress * 100
	caster:SetModifierStackCount("modifier_madness_progress", caster, progress)
end

function OnSelfishStart(keys)
	local caster = keys.caster
	--[[if caster.MadnessStackCount ~= 0 then
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_selfish_debuff_aura", {}) 
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_selfish_self_invul", {}) 
		caster:EmitSound("Hero_Warlock.ShadowWord")
		Timers:CreateTimer(function()
			if caster.MadnessStackCount == 0 then 
				caster:StopSound("Hero_Warlock.ShadowWord")
				caster:RemoveModifierByName("modifier_selfish_debuff_aura") 
				caster:RemoveModifierByName("modifier_selfish_self_invul") 
			return end
			AdjustMadnessStack(caster,-1)
			return 0.2
		end)
	end]]
	local duration = 3
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_selfish_debuff_aura", {duration = duration})
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_selfish_self_invul", {duration = duration})
	caster:EmitSound("Hero_Warlock.ShadowWord")
	AdjustMadnessStack(caster, -75)
	Timers:CreateTimer(duration, function() caster:StopSound("Hero_Warlock.ShadowWord") end)
end

function CleanupGilleSummon(keys)
	local caster = keys.caster
	if IsValidEntity(caster.GiganticHorror) then
		caster.GiganticHorror:ForceKill(true)
	end
end

function OnThrowCorpseStart(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local targetPoint = keys.target_points[1]
	local frontward = caster:GetForwardVector()

	if caster.MadnessStackCount == 0 then
		keys.ability:EndCooldown()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Not_Enough_Madness")
		return
	end
	
	if caster.IsMentalPolluted then
		keys.ability:EndCooldown()
		keys.ability:StartCooldown(0.1)
	end
	AdjustMadnessStack(caster, -10)

	local corpse = CreateUnitByName("gille_corpse", targetPoint, true, nil, nil, caster:GetTeamNumber())
	corpse:EmitSound("Hero_Nevermore.Shadowraze")
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf", PATTACH_CUSTOMORIGIN, corpse)
	ParticleManager:SetParticleControl(particle, 0, corpse:GetAbsOrigin()) 
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( particle, false )
		ParticleManager:ReleaseParticleIndex( particle )
	end)
	corpse:ForceKill(true)
end

function OnSummonDemonStart(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local targetPoint = keys.target_points[1]
	local number = keys.Number
	local targets = Entities:FindAllByNameWithin("npc_dota_creature", targetPoint, keys.Radius)
	if caster.IsAbyssalConnection2Acquired then
		keys.Health = keys.Health * 1.3
	end

	-- check if corpse is present
	local unit = nil
	for i=1, #targets do
		if not targets[i]:IsAlive() then 
			print("found dead unit")
			unit = targets[i]
			break
		end
	end
	if not unit then
		number = keys.NumberNoCorpse
	else
		unit:RemoveSelf()
	end

	EmitSoundOnLocationWithCaster(targetPoint, "Hero_Nevermore.Shadowraze", caster)
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(particle, 0, targetPoint) 

	for i=1,number do
		local tentacle = CreateUnitByName("gille_oceanic_demon", targetPoint, true, nil, nil, caster:GetTeamNumber())
		if caster.IsAbyssalConnection2Acquired then
			giveUnitDataDrivenModifier(caster, tentacle, "gille_attack_speed_boost", 999.0)
		end
		tentacle:SetControllableByPlayer(caster:GetPlayerID(), true)
		tentacle:SetOwner(caster)
		tentacle:SetMaxHealth(keys.Health)
		tentacle:SetBaseMaxHealth(keys.Health)
		tentacle:SetHealth(keys.Health)
		tentacle:AddNewModifier(caster, nil, "modifier_kill", {duration = 40.0})
		--tentacle:AddNewModifier(caster, nil, "modifier_kill", {duration = 30.0})
		FindClearSpaceForUnit(tentacle, tentacle:GetAbsOrigin(), true)
	end
end

function OnDemonSuicideStart(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_kill")
	caster:AddNewModifier(caster, nil, "modifier_kill", {duration = 3.0})
end
function OnTormentStart(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local duration = keys.StunDuration

	local ManaCost = 40
	AdjustMadnessStack(caster, -ManaCost)
	

    local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
		keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_torment", {}) 
		v:AddNewModifier(v, v, "modifier_stunned", {Duration = duration})
		v.AccumulatedDamage = 0
	end

	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_witchdoctor/witchdoctor_maledict_aoe.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, targetPoint) 
	ParticleManager:SetParticleControl(particle, 1, Vector(keys.Radius,0,0)) 
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( particle, false )
		ParticleManager:ReleaseParticleIndex( particle )
	end)

	EmitSoundOnLocationWithCaster(targetPoint, "ZC.Torment", caster)	
end

function OnOceanicThink(keys)
	local caster = keys.caster
	local target = keys.target
	local damage = keys.Damage
	DoDamage(caster, target, 10, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function OnTormentThink(keys)
	local caster = keys.caster
	local target = keys.target
	local damage = keys.Damage
	DoDamage(caster, target, damage/8, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function OnGilleComboThink(keys)
	local caster = keys.caster
	local target = keys.target
	local damage = target:GetMaxHealth()*keys.DPS/100
	DoDamage(caster, target, damage, DAMAGE_TYPE_PURE, 0, keys.ability, false)
	--print("dealing damage")
end

function OnTormentTakeDamage(keys)
	local victim = keys.unit
	damageTaken = keys.DamageTaken
	victim.AccumulatedDamage = victim.AccumulatedDamage + damageTaken
	print(victim.AccumulatedDamage)
end

function OnTormentEnd(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local victim = keys.target
	local multiplier = 10
	if caster.IsBlackMagicImproved then multiplier = 15 end
	local damage = victim.AccumulatedDamage/100 * 3 * multiplier
	print(damage)
	DoDamage(caster, victim, damage , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function OnECStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local targetPoint = keys.target_points[1]

	--[[
	-- check if combo can be cast
	local combotargets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, 800, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(combotargets) do
		if v:GetUnitName() == "gille_gigantic_horror" and caster:GetStrength() >= 20 and caster:GetAgility() >= 20 and caster:GetIntellect() >= 20 and caster:FindAbilityByName("gille_larret_de_mort"):IsCooldownReady() then
			OnGilleComboStart(keys)
			return
		end
	end]]

	-- store the madness cost
	-- do initial explosion
	AdjustMadnessStack(caster, -40)
	ECExplode(keys, targetPoint, false)

	-- find corpse generated by Caster and explode them
	local corpseTargets = Entities:FindAllByNameWithin("npc_dota_creature", targetPoint, keys.Radius)
	local maxCorpses = ability:GetSpecialValueFor("max_corpses")
	maxCorpses = vlua.select(caster.IsBlackMagicImproved, maxCorpses + 1, maxCorpses)
	for i = 1, maxCorpses do
		local unit = corpseTargets[i]
		if unit and unit:GetUnitName() == "gille_corpse" then
			ECExplode(keys, unit:GetAbsOrigin(), true)
			unit:RemoveSelf()
		end
	end

	-- find jellyfishes AND tentacles and prepare them for secondary impact
	local allytargets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(allytargets) do
		if v:GetUnitName() == "gille_oceanic_demon" or v:GetUnitName() == "gille_tentacle_of_destruction" then
			keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_exquisite_cadaver_demon", {}) 
		end
	end
end

function ECExplode(keys, origin, bIsCorpse)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local damage = keys.Damage
	if bIsCorpse then damage = damage/4 end

    local targets = FindUnitsInRadius(caster:GetTeam(), origin, nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
		DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
		if caster.IsBlackMagicImproved then
			local damageCounter = 0
			Timers:CreateTimer(function()
				if not IsValidEntity(v) or not v:IsAlive() or damageCounter > 20 then return end
				DoDamage(caster, v, 20, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
				damageCounter = damageCounter + 1
				return 0.2
			end)
		end
	end
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_fire_spirit_ground.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, origin) 
	ParticleManager:SetParticleControl(particle, 1, Vector(keys.Radius,keys.Radius,keys.Radius)) 
	ParticleManager:SetParticleControl(particle, 3, Vector(keys.Radius,keys.Radius,keys.Radius)) 
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( particle, false )
		ParticleManager:ReleaseParticleIndex( particle )
	end)

	local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_shadow_demon/shadow_demon_soul_catcher.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle2, 1, origin) 
	ParticleManager:SetParticleControl(particle2, 2, origin) 
	ParticleManager:SetParticleControl(particle2, 3, origin) 
	ParticleManager:SetParticleControl(particle2, 4, origin) 
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( particle2, false )
		ParticleManager:ReleaseParticleIndex( particle2 )
	end)

	caster:EmitSound("Hero_ShadowDemon.Soul_Catcher.Cast")
end

function OnECDemonExplode(keys) --Now Tentacles explode too.
	local demon = keys.target
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local damage = keys.Damage/100 * 25
	local targets = FindUnitsInRadius(caster:GetTeam(), demon:GetAbsOrigin(), nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	print(damage)

	for k,v in pairs(targets) do
		DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
		if caster.IsBlackMagicImproved then
			local damageCounter = 0
			Timers:CreateTimer(function()
				if not IsValidEntity(v) or not v:IsAlive() or damageCounter > 20 then return end
				DoDamage(caster, v, 20, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
				damageCounter = damageCounter + 1
				return 0.2
			end)
		end
	end

	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_fire_spirit_ground.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, demon:GetAbsOrigin()) 
	ParticleManager:SetParticleControl(particle, 1, Vector(keys.Radius,keys.Radius,keys.Radius)) 
	ParticleManager:SetParticleControl(particle, 3, Vector(keys.Radius,keys.Radius,keys.Radius)) 
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( particle, false )
		ParticleManager:ReleaseParticleIndex( particle )
	end)

	local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_shadow_demon/shadow_demon_soul_catcher.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle2, 1, demon:GetAbsOrigin()) 
	ParticleManager:SetParticleControl(particle2, 2, demon:GetAbsOrigin()) 
	ParticleManager:SetParticleControl(particle2, 3, demon:GetAbsOrigin()) 
	ParticleManager:SetParticleControl(particle2, 4, demon:GetAbsOrigin()) 
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( particle2, false )
		ParticleManager:ReleaseParticleIndex( particle2 )
	end)

	demon:EmitSound("Hero_ShadowDemon.Soul_Catcher.Cast")
	demon:ForceKill(true)
end

function OnContractStart(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local targetPoint = keys.target_points[1]
	local delay = keys.Delay
	if caster.IsAbyssalConnection1Acquired then
		keys.Radius = keys.Radius + 200
		keys.Damage = keys.Damage + 200
	end
	if caster.IsAbyssalConnection2Acquired then
		keys.Health = keys.Health * 1.3
	end

	if caster:HasModifier("modifier_gigantic_horror_penalty_timer") or caster.IsAbyssalContractInProgress then
		keys.ability:EndCooldown()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Summon")
		return
	end
	caster.IsAbyssalContractInProgress = true
	Timers:CreateTimer(delay, function()
		caster.IsAbyssalContractInProgress = false
	end)
	
	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 1.0)
	--GilleCheckCombo(caster, keys.ability)

	AdjustMadnessStack(caster, -140)

    local visiondummy = CreateUnitByName("sight_dummy_unit", targetPoint, false, keys.caster, keys.caster, keys.caster:GetTeamNumber())
    visiondummy:SetDayTimeVisionRange(1000)
    visiondummy:SetNightTimeVisionRange(1000)
    visiondummy:AddNewModifier(caster, nil, "modifier_kill", {duration = 3.1})
    visiondummy:EmitSound("Hero_Warlock.Upheaval")
    local unseen = visiondummy:FindAbilityByName("dummy_unit_passive")
    unseen:SetLevel(1)

	local contractFx = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_upheaval.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(contractFx, 0, targetPoint)
	ParticleManager:SetParticleControl(contractFx, 1, Vector(keys.Radius + 200,0,0))
	Timers:CreateTimer(2.0, function()
		ParticleManager:DestroyParticle(contractFx, false)
		ParticleManager:ReleaseParticleIndex(contractFx)
	end)

	local contractFx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_death_glyph.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(contractFx2, 0, targetPoint)
	Timers:CreateTimer( 5.0, function()
		ParticleManager:DestroyParticle( contractFx2, false )
		ParticleManager:ReleaseParticleIndex( contractFx2 )
	end)

	contractFx4 = 0
	Timers:CreateTimer(1.0, function()
		contractFx4 = ParticleManager:CreateParticle("particles/units/heroes/hero_enigma/enigma_midnight_pulse.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(contractFx4, 0, targetPoint)
		ParticleManager:SetParticleControl(contractFx4, 1, Vector(keys.Radius + 200, 0, 0))
		Timers:CreateTimer(2.0, function()
			ParticleManager:DestroyParticle(contractFx4, false)
			ParticleManager:ReleaseParticleIndex(contractFx4)
		end)
	end)
	

	Timers:CreateTimer(3.0, function()
		if caster:IsAlive() then
			if IsValidEntity(caster.GiganticHorror) and caster.GiganticHorror:IsAlive() then
				caster.GiganticHorror:ForceKill(true)
			end
				-- Summon Gigantic Horror
				local tentacle = CreateUnitByName("gille_gigantic_horror", targetPoint, true, nil, nil, caster:GetTeamNumber())
				if caster.IsAbyssalConnection2Acquired then
					giveUnitDataDrivenModifier(caster, tentacle, "gille_attack_speed_boost", 999.0)
				end
				if caster.IsAbyssalConnection1Acquired then
					local cont = CreateItem("item_gille_contaminate" , nil, nil)
					tentacle:AddItem(cont)
					tentacle:AddItem(CreateItem("item_gille_integrate" , nil, nil))
					cont:SetLevel(keys.ability:GetLevel())
				end
				if caster.IsAbyssalConnection2Acquired then
					tentacle:AddItem(CreateItem("item_gille_otherworldly_portal" , nil, nil))
				end
				tentacle:SetControllableByPlayer(caster:GetPlayerID(), true)
				tentacle:SetOwner(caster)
				caster.GiganticHorror = tentacle
				tentacle.Gille = caster
				FindClearSpaceForUnit(tentacle, tentacle:GetAbsOrigin(), true)

				local skillLevel = 1 + (caster:GetLevel() - 1)/3
				if skillLevel > 8 then skillLevel = 8 end
				-- Level abilities
				tentacle:FindAbilityByName("gille_tentacle_of_destruction"):SetLevel(skillLevel)
				tentacle:FindAbilityByName("gille_subterranean_skewer"):SetLevel(skillLevel) 
				tentacle:FindAbilityByName("gille_gigantic_horror_passive"):SetLevel(skillLevel)  
				tentacle:FindAbilityByName("gille_larret_de_mort"):SetHidden(false) 
				tentacle:FindAbilityByName("gille_larret_de_mort"):SetLevel(1) 

				tentacle:SetMaxHealth(keys.Health)
				tentacle:SetBaseMaxHealth(keys.Health)
				tentacle:SetHealth(keys.Health)
				tentacle:SetBaseDamageMax(50 + keys.ability:GetLevel() * 50) 
				tentacle:SetBaseDamageMin(50 + keys.ability:GetLevel() * 50) 
				tentacle:AddNewModifier(caster, nil, "modifier_kill", {duration = 90.0})
				EmitGlobalSound("ZC.Ravage")

				tentacle:SetDeathXP(skillLevel * 50 + 100)
			    local playerData = {
                    transport = tentacle:entindex()
                }
                CustomGameEventManager:Send_ServerToPlayer( caster:GetPlayerOwner(), "player_summoned_transport", playerData )
			-- Damage enemies
			local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			for k,v in pairs(targets) do
				DoDamage(caster, v, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
				ApplyAirborne(caster, v, 0.3)
			end

			local contractFx3 = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_rain_of_chaos_start.vpcf", PATTACH_CUSTOMORIGIN, visiondummy)
			ParticleManager:SetParticleControl(contractFx3, 0, targetPoint)
			ParticleManager:SetParticleControl(contractFx3, 1, Vector(keys.Radius + 500, 0, 0))
			ParticleManager:SetParticleControl(contractFx3, 2, Vector(keys.Radius + 500, 0, 0))
			Timers:CreateTimer( 3.0, function()
				ParticleManager:DestroyParticle( contractFx3, false )
				ParticleManager:ReleaseParticleIndex( contractFx3 )
			end)
			
			EmitGlobalSound("ZC.Ravage")
			StopSoundEvent("Hero_Warlock.Upheaval", visiondummy)


			CreateRavageParticle(visiondummy, visiondummy:GetAbsOrigin(), 300)
			CreateRavageParticle(visiondummy, visiondummy:GetAbsOrigin(), 650)
			CreateRavageParticle(visiondummy, visiondummy:GetAbsOrigin(), 1000)
			-- Remove particle
		end
	end)
end

function CreateRavageParticle(handle, center, multiplier)
	for i=1, math.floor(multiplier/60) do
		local x = math.cos(i) * multiplier
		local y = math.sin(i) * multiplier
		local tentacleFx = ParticleManager:CreateParticle("particles/units/heroes/hero_tidehunter/tidehunter_spell_ravage_hit.vpcf", PATTACH_CUSTOMORIGIN, handle)
		ParticleManager:SetParticleControl(tentacleFx, 0, Vector(center.x + x, center.y + y, 100))
		ParticleManager:SetParticleControl(tentacleFx, 2, Vector(center.x + x, center.y + y, 100))
	end
end

function OnHorrorTakeDamage(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner() 
	local hero = ply:GetAssignedHero()
	local damageTaken = keys.DamageTaken
	local threshold = keys.Threshold
	local multiplier = 0.3
	if hero.IsAbyssalConnection1Acquired then
		multiplier = 0.1
	end
	if damageTaken > threshold then 
		DoDamage(keys.attacker, caster, damageTaken * multiplier, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	end 
end

function OnHorrorDeath(keys)
	local caster = keys.caster
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	keys.ability:ApplyDataDrivenModifier(caster, hero, "modifier_gigantic_horror_penalty_timer", {}) 
end


function OnTentacleSummon(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner() 
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	local targetPoint = keys.target_points[1]
	if hero.IsAbyssalConnection2Acquired then
		keys.Health = keys.Health * 1.3
	end
	for i=0,2 do
		local tentacle = CreateUnitByName("gille_tentacle_of_destruction", targetPoint, true, nil, nil, caster:GetTeamNumber())
		if hero.IsAbyssalConnection2Acquired then
			giveUnitDataDrivenModifier(caster, tentacle, "gille_attack_speed_boost", 999.0)
		end
		tentacle:SetControllableByPlayer(hero:GetPlayerID(), true)
		tentacle:SetOwner(hero)
		tentacle:SetMaxHealth(keys.Health) 
		tentacle:SetBaseMaxHealth(keys.Health)
		tentacle:SetHealth(keys.Health)
		tentacle:SetBaseDamageMin(keys.Damage)
		tentacle:SetBaseDamageMax(keys.Damage)
		tentacle:FindAbilityByName("gille_tentacle_of_destruction_passive"):SetLevel(keys.ability:GetLevel())
		tentacle:AddNewModifier(caster, nil, "modifier_kill", {duration = 60.0})
		FindClearSpaceForUnit(tentacle, tentacle:GetAbsOrigin(), true)

		if i==1 then
			tentacle:EmitSound("Hero_Nevermore.Shadowraze")
			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf", PATTACH_CUSTOMORIGIN, tentacle)
			ParticleManager:SetParticleControl(particle, 0, tentacle:GetAbsOrigin()) 
		end
	end
end

function OnTentacleAttackLanded(keys)
	local target = keys.target
	local damage = target:GetMaxHealth() * keys.Damage/100
	DoDamage(keys.attacker, target, damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function OnTentacleHookStart(keys)
	---@type CDOTA_BaseNPC_Hero
	local caster = keys.caster
	local targetPoint = keys.target_points[1]

	local kv = {caster = caster}
	local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, 200, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
	if targets[1] then
		kv.target = targets[1]
		OnTentacleHookHit(kv)
	end
end

function OnTentacleHookHit(keys)
	local caster = keys.caster
	local target = keys.target
	if target:GetUnitName() == "gille_gigantic_horror" or caster.IsHookHit then return end
	caster.IsHookHit = true
	target:EmitSound("Hero_Pudge.AttackHookImpact")
	local diff = (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D() 
	target:AddNewModifier(target, target, "modifier_stunned", {Duration = 0.75})
	local pullTarget = Physics:Unit(target)
	local pullVector = (caster:GetAbsOrigin() - target:GetAbsOrigin()):Normalized() * diff * 2
	target:PreventDI()
	target:SetPhysicsFriction(0)
	target:SetPhysicsVelocity(Vector(pullVector.x, pullVector.y, 2000))
	target:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	target:FollowNavMesh(false)
	target:SetAutoUnstuck(false)

	Timers:CreateTimer({
		endTime = 0.25,
		callback = function()
		target:SetPhysicsVelocity(Vector(pullVector.x, pullVector.y, -2000))
	end
	})

  	Timers:CreateTimer(0.5, function()
		target:PreventDI(false)
		target:SetPhysicsVelocity(Vector(0,0,0))
		target:OnPhysicsFrame(nil)
		target:SetAutoUnstuck(true)
		FindClearSpaceForUnit(target, target:GetAbsOrigin(), true)

	end)
  	Timers:CreateTimer(1.0, function()
		caster.IsHookHit = false
	end)
end

function OnTentacleWrapStart(keys)
	local caster = keys.caster
	local target = keys.target
	local fxCounter = 0
	Timers:CreateTimer(function()
		if fxCounter > 2 then return end 
		local tentacleFx = ParticleManager:CreateParticle("particles/units/heroes/hero_tidehunter/tidehunter_spell_ravage_hit_wrap.vpcf", PATTACH_CUSTOMORIGIN, target)
		ParticleManager:SetParticleControl(tentacleFx, 0, target:GetAbsOrigin() + Vector(0,0,100))
		ParticleManager:SetParticleControl(tentacleFx, 2, target:GetAbsOrigin() + Vector(0,0,100))
		Timers:CreateTimer( 3.0, function()
			ParticleManager:DestroyParticle( tentacleFx, false )
			ParticleManager:ReleaseParticleIndex( tentacleFx )
		end)
		fxCounter = fxCounter + 0.5
		return 0.5
	end)
end

function OnSubSkewerStart(keys)
	local caster = keys.caster
	local casterLoc = caster:GetAbsOrigin()
	local targetPoint = keys.target_points[1]
	local diff = (targetPoint - casterLoc):Normalized()
	local frontward = caster:GetForwardVector()
	local skewer = 
	{
		Ability = keys.ability,
        EffectName = "",
        iMoveSpeed = 3000,
        vSpawnOrigin = casterLoc - frontward*100,
        fDistance = 1000 + 100,
        fStartRadius = 200,
        fEndRadius = 200,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 2.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * 3000
	}
	--local projectile = ProjectileManager:CreateLinearProjectile(skewer)
	Timers:CreateTimer(1.0, function()
		local projectile = ProjectileManager:CreateLinearProjectile(skewer)
		caster:EmitSound("Hero_Lion.Impale")
		print("generated projectile")
	end)

	local tentacleCounter1 = 0
	Timers:CreateTimer(1.0, function()
		if tentacleCounter1 > 10 then return end
		print("tentacles")
		local tentacleFx = ParticleManager:CreateParticle("particles/units/heroes/hero_tidehunter/tidehunter_spell_ravage_hit.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(tentacleFx, 0, casterLoc + diff * 110 * tentacleCounter1)
		Timers:CreateTimer( 3.0, function()
			ParticleManager:DestroyParticle( tentacleFx, false )
			ParticleManager:ReleaseParticleIndex( tentacleFx )
		end)
		tentacleCounter1 = tentacleCounter1 + 1
		return 0.033
	end)
end

function OnSubSkewerHit(keys)
	local target = keys.target
	local caster = keys.caster
	print("hit something")
	ApplyAirborne(caster, target, keys.StunDuration)
	DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)

end

function OnContaminateStart(keys)
	local caster = keys.caster
	local totalDamage = 500 + 100 * PlayerResource:GetSelectedHeroEntity(caster:GetPlayerOwnerID()):FindAbilityByName("gille_abyssal_contract"):GetLevel()
    local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
		DoDamage(caster, v, totalDamage/2, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
		keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_contaminate", {}) 
	end

	local tentacleFx = ParticleManager:CreateParticle("particles/units/heroes/hero_pugna/pugna_netherblast.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(tentacleFx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(tentacleFx, 1, Vector(keys.Radius+200,0,0))
	Timers:CreateTimer( 3.0, function()
		ParticleManager:DestroyParticle( tentacleFx, false )
		ParticleManager:ReleaseParticleIndex( tentacleFx )
	end)
end

function OnContaminateThink(keys)
	local caster = keys.caster
	local target = keys.target
	local ult = PlayerResource:GetSelectedHeroEntity(caster:GetPlayerOwnerID()):FindAbilityByName("gille_abyssal_contract")
	local damage = (500 + 100 * ult:GetLevel()) / 40
	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function OnIntegrateStart(keys)
	local caster = keys.caster
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	local healthpercent = caster:GetHealthPercent() / 100
	local IntMaxhealth = caster:GetMaxHealth()+keys.Health
	local IntCurrenthealth = caster:GetHealth()+keys.Health * healthpercent
	local DeIntMaxhealth = caster:GetMaxHealth()-keys.Health
	local DeIntCurrenthealth = caster:GetHealth()-keys.Health * healthpercent

	Timers:CreateTimer(0.5, function()
		if caster:IsAlive() then
			if hero.IsIntegrated then
				if GridNav:IsBlocked(caster:GetAbsOrigin()) or not GridNav:IsTraversable(caster:GetAbsOrigin()) then
					keys.ability:EndCooldown()
					SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Unmount")
					return			
				else
					hero:RemoveModifierByName("modifier_integrate_gille")
					caster:RemoveModifierByName("modifier_integrate")
					caster:SetMaxHealth(DeIntMaxhealth)
					caster:SetHealth(DeIntCurrenthealth)
					hero.IsIntegrated = false
					caster.AttemptingIntegrate = false
					SendMountStatus(hero)
				end
			elseif (caster:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D() < 400 and not hero:HasModifier("stunned") and not hero:HasModifier("modifier_stunned") then 
				hero.IsIntegrated = true
				keys.ability:ApplyDataDrivenModifier(caster, hero, "modifier_integrate_gille", {})
				keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_integrate", {})  
				caster:SetMaxHealth(IntMaxhealth)
				caster:SetHealth(IntCurrenthealth)
				caster:EmitSound("ZC.Tentacle1")
				--caster:EmitSound("ZC.Laugh")
				SendMountStatus(hero)
				return 
			end
			--[[
			else
				caster.AttemptingIntegrate = true
				ExecuteOrderFromTable({ UnitIndex = caster:GetEntityIndex(), 
										OrderType = DOTA_UNIT_ORDER_MOVE_TO_TARGET, 
										TargetIndex = hero:GetEntityIndex(), 
										Position = hero:GetAbsOrigin(), 
										Queue = false
									}) 

				ExecuteOrderFromTable({ UnitIndex = hero:GetEntityIndex(), 
										OrderType = DOTA_UNIT_ORDER_MOVE_TO_TARGET, 
										TargetIndex = caster:GetEntityIndex(), 
										Position = caster:GetAbsOrigin(), 
										Queue = false
									}) 
				Timers:CreateTimer("integrate_checker", {
					endTime = 0.0,
					callback = function()
					if (caster:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D() < 300 and caster.AttemptingIntegrate then 
						caster.IsIntegrated = true
						caster.AttemptingIntegrate = false
						keys.ability:ApplyDataDrivenModifier(caster, hero, "modifier_integrate_gille", {})
						keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_integrate", {})  
						caster:EmitSound("ZC.Tentacle1")
						caster:EmitSound("ZC.Laugh")
						return 
					end
					return 0.1
				end})
			end]]
		end
	end)
end

function OnIntegrateDeath(keys)
	local caster = keys.caster
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsIntegrated = false
	hero:RemoveModifierByName("modifier_integrate_gille")
	SendMountStatus(hero)
end

function OnIntegrateCanceled(keys)
	local caster = keys.caster
	if caster.AttemptingIntegrate then 
		caster.AttemptingIntegrate = false
		Timers:RemoveTimer("integrate_checker")
	end
end

function IntegrateFollow(keys)
	local caster = keys.caster
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	if IsValidEntity(caster) then
		hero:SetAbsOrigin(caster:GetAbsOrigin() + Vector(0,0,500))
	end
end

function OnHorrorTeleport(keys)
	local caster = keys.caster
	local hero = PlayerResource:GetSelectedHeroEntity(caster:GetPlayerOwnerID())
	local targetPoint = keys.target_points[1]
	local delay = keys.Delay
	if (targetPoint - hero:GetAbsOrigin()):Length2D() > 1000 then 
		keys.ability:EndCooldown()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Tentacle_Out_Of_Radius")
		return
	elseif hero.IsIntegrated then
		keys.ability:EndCooldown()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Use_While_Integrated")
		return
	elseif IsInSameRealm(caster:GetAbsOrigin(),hero:GetAbsOrigin()) == false then
		keys.ability:EndCooldown()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Teleport_Across_Realms")
		return			
	else
		EmitSoundOnLocationWithCaster(targetPoint, "Hero_Enigma.Demonic_Conversion", caster)
		local darkZoneFx = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_seer/dark_seer_vacuum.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(darkZoneFx, 0, targetPoint)
		ParticleManager:SetParticleControl(darkZoneFx, 1, Vector(500,0,0))
		ParticleManager:SetParticleControl(darkZoneFx, 2, Vector(500,0,0))
		Timers:CreateTimer(delay, function()
			--ParticleManager:DestroyParticle( darkZoneFx, false )
			--ParticleManager:ReleaseParticleIndex( darkZoneFx )
			if caster:IsAlive() and hero:IsAlive() then
				caster:SetAbsOrigin(targetPoint)
			end
		end)
	end
end

function OnGilleComboStart(keys)
	local tentacle = keys.caster
	local caster = tentacle.Gille
	local ability = caster:FindAbilityByName("gille_larret_de_mort")
	local radius = 1000
	if caster:GetStrength() >= 19.1 and caster:GetAgility() >= 19.1 and caster:GetIntellect() >= 19.1 and caster:FindAbilityByName("gille_larret_de_mort"):IsCooldownReady() then
	else 
		tentacle:FindAbilityByName("gille_larret_de_mort"):EndCooldown()
		return 
	end

	caster:FindAbilityByName("gille_larret_de_mort"):StartCooldown(210)
	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName("gille_larret_de_mort")
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(210)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_larret_de_mort_cooldown", {duration = 210})

	-- knockup enemies
	local targets = FindUnitsInRadius(caster:GetTeam(), tentacle:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
		ApplyAirborne(caster, v, keys.KnockupDuration)
	end

	-- remove integrate status
	if caster.IsIntegrated then
		caster:RemoveModifierByName("modifier_integrate_gille")
		tentacle:RemoveModifierByName("modifier_integrate")
		caster.IsIntegrated = false
		tentacle.AttemptingIntegrate = false
		SendMountStatus(caster)
	end


	ability:ApplyDataDrivenModifier(caster, tentacle, "modifier_gigantic_horror_freeze", {})
	CreateRavageParticle(tentacle, tentacle:GetAbsOrigin(), 300)
	CreateRavageParticle(tentacle, tentacle:GetAbsOrigin(), 650)
	CreateRavageParticle(tentacle, tentacle:GetAbsOrigin(), 1000)
	EmitGlobalSound("ZC.Ravage")
	EmitGlobalSound("ZC.Laugh")

	local contractFx = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_upheaval.vpcf", PATTACH_CUSTOMORIGIN, visiondummy)
	ParticleManager:SetParticleControl(contractFx, 0, tentacle:GetAbsOrigin())
	ParticleManager:SetParticleControl(contractFx, 1, Vector(radius + 200,0,0))
	Timers:CreateTimer( 3, function()
		ParticleManager:DestroyParticle( contractFx, false )
		ParticleManager:ReleaseParticleIndex( contractFx )
	end)

	Timers:CreateTimer(1, function()
        local currentdamage = keys.Damage/100 * tentacle:GetHealth()
		local targets = FindUnitsInRadius(caster:GetTeam(), tentacle:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
			DoDamage(caster, v, currentdamage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			ability:ApplyDataDrivenModifier(caster, v, "modifier_gille_combo", {})
			v:EmitSound("hero_bloodseeker.rupture")
		end
		Timers:CreateTimer(0.5, function()
			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_supernova_reborn_shockwave.vpcf", PATTACH_CUSTOMORIGIN, tentacle)
			ParticleManager:SetParticleControl(particle, 0, tentacle:GetAbsOrigin())
			ParticleManager:SetParticleControl(particle, 1, Vector(radius+200,0,0))  
			ParticleManager:DestroyParticle(contractFx, false)
			ParticleManager:ReleaseParticleIndex(contractFx)
			Timers:CreateTimer( 3.0, function()
				ParticleManager:DestroyParticle( particle, false )
				ParticleManager:ReleaseParticleIndex( particle )
			end)
		end)
		
		tentacle:EmitSound("Hero_ObsidianDestroyer.SanityEclipse.Cast")
		local splashFx = ParticleManager:CreateParticle("particles/custom/screen_scarlet_splash.vpcf", PATTACH_EYES_FOLLOW, tentacle)
		Timers:CreateTimer( 3.0, function()
			ParticleManager:DestroyParticle( splashFx, false )
			ParticleManager:ReleaseParticleIndex( splashFx )
		end)
		tentacle:EmitSound("Hero_ShadowDemon.DemonicPurge.Impact")
		tentacle:ForceKill(true)
	end)

end


function GilleCheckCombo(caster, ability)
	if caster:GetStrength() >= 20 and caster:GetAgility() >= 20 and caster:GetIntellect() >= 20 and ability:GetAbilityName() == "gille_exquisite_cadaver" then
		caster.IsComboReady = true
		--[[if ability == caster:FindAbilityByName("gille_abyssal_contract") and caster:FindAbilityByName("gille_larret_de_mort"):IsCooldownReady() then
			caster.IsComboReady = true 
			print("ready to combo")
			Timers:CreateTimer({
				endTime = 5,
				callback = function()
				caster.IsComboReady = false
			end
			})
		end]]
	end
end

function OnEyeForArtAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    hero.IsEyeForArtAcquired = true
       -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnBlackMagicImproved(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    hero.IsBlackMagicImproved = true
       -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnMentalPollutionAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    hero.IsMentalPolluted = true
       -- Set master 1's mana 
	local master = hero.MasterUnit
	hero:FindAbilityByName("gille_spellbook_of_prelati"):SetLevel(2)
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnAbyssConnectionAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    hero.IsAbyssalConnection1Acquired = true
       -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnAbyssConnection2Acquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    hero.IsAbyssalConnection2Acquired = true
       -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end


function RemoveAllPoisons(keys) -- so people don't respawn with poison DoT debuff modifiers
	local caster = keys.caster
    LoopOverHeroes(function(hero)
    	hero:RemoveModifierByName("modifier_contaminate")
    	hero:RemoveModifierByName("modifier_gille_combo")
    end)
end
