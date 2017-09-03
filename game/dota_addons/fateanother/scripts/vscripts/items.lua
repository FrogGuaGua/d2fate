cdummy = nil
itemKV = LoadKeyValues("scripts/npc/npc_items_custom.txt")


function ParseCombinationKV()
	for k,v in pairs(itemKV) do
		if string.match(k, "recipe") then
			for k2, v2 in pairs(v) do
				if k2 == "ItemRequirements" then
					for k3, v3 in pairs(v2) do

						print("Item Name : " .. k)
						comp1, comp2 = string.match(v3, "([^;]+);([^;]+)")
						if k == "item_recipe_healing_scroll" then
							comp1 = "item_mana_essence"
							comp2 = "item_recipe_healing_scroll"
						elseif k == "item_recipe_a_plus_scroll" then
							comp1 = "item_a_scroll"
							comp2 = "item_recipe_a_plus_scroll"
						end
						print(comp1 .. " " .. comp2)
					end
				end
			end
		end
	end
end


function OnManaEssenceAcquired(keys)
end

function OnBaseEntered(trigger)
	local hero = trigger.activator
	hero.IsInBase = true
	SendErrorMessage(hero:GetPlayerOwnerID(), "#Entered_Base")
	--print("Base entered")
end

function OnBaseLeft(trigger)
	local hero = trigger.activator
        if not hero then
            return
        end
	hero.IsInBase = false
	SendErrorMessage(hero:GetPlayerOwnerID(), "#Left_Base")
end

function OnTrioBaseEnter(hero, team)
	if hero:GetUnitName() == "npc_dota_hero_wisp" then return end
	hero.IsInBase = true
	if hero:GetTeam() == team then
		giveUnitDataDrivenModifier(hero, hero, "spawn_invulnerable", 999)
	end
	SendErrorMessage(hero:GetPlayerOwnerID(), "#Entered_Base")
end

function OnTrioBaseLeft(hero, team)
	if not hero then return end
	hero.IsInBase = false
	hero:RemoveModifierByName("spawn_invulnerable")
	if hero:GetTeam() == team then
		giveUnitDataDrivenModifier(hero, hero, "spawn_invulnerable", 3)
	end
	SendErrorMessage(hero:GetPlayerOwnerID(), "#Left_Base")
end

function OnTrioBase1Entered(trigger)
	local hero = trigger.activator
	OnTrioBaseEnter(hero, DOTA_TEAM_GOODGUYS)
end

function OnTrioBase1Left(trigger)
	local hero = trigger.activator
	OnTrioBaseLeft(hero, DOTA_TEAM_GOODGUYS)
end

function OnTrioBase2Entered(trigger)
	local hero = trigger.activator
	OnTrioBaseEnter(hero, DOTA_TEAM_BADGUYS)
end

function OnTrioBase2Left(trigger)
	local hero = trigger.activator
	OnTrioBaseLeft(hero, DOTA_TEAM_BADGUYS)
end

function OnTrioBase3Entered(trigger)
	local hero = trigger.activator
	OnTrioBaseEnter(hero, DOTA_TEAM_CUSTOM_1)
end

function OnTrioBase3Left(trigger)
	local hero = trigger.activator
	OnTrioBaseLeft(hero, DOTA_TEAM_CUSTOM_1)
end

function OnTrioBase4Entered(trigger)
	local hero = trigger.activator
	OnTrioBaseEnter(hero, DOTA_TEAM_CUSTOM_2)
end

function OnTrioBase4Left(trigger)
	local hero = trigger.activator
	OnTrioBaseLeft(hero, DOTA_TEAM_CUSTOM_2)
end

function OnFFABaseEntered(trigger)
	local hero = trigger.activator
	hero.IsInBase = true
	SendErrorMessage(hero:GetPlayerOwnerID(), "#Entered_Base")
end

function OnFFABaseLeft(trigger)
	local hero = trigger.activator
	if not hero then return end
	hero.IsInBase = false
	SendErrorMessage(hero:GetPlayerOwnerID(), "#Left_Base")
end

function TransferItem(keys)
	local item = keys.ability
	local caster = keys.caster
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	local stash_item = hero:GetItemInSlot(keys.Slot+8) -- This looks for slot 6/7/8/9/10/11(Stash)

	--PrintTable(stash_item)
	-- If item is found, remove it from stash and add it to hero
	if stash_item ~= nil then
		---[[If hero has empty inventory slot, move item to hero
		local hero_item
		for i=0, 5 do
			hero_item = hero:GetItemInSlot(i)
			if hero_item == nil then
				break
			elseif i==5 then 
				return
			end
		end
		local itemName = stash_item:GetName()
		local charges = stash_item:GetCurrentCharges()
		local newItem = CreateItem(itemName, nil, nil)
		newItem:SetCurrentCharges(charges)
		stash_item:RemoveSelf()
		--Timers:CreateTimer( 0.033, function()

		hero:AddItem(newItem)
		CheckItemCombination(hero)
	
		SaveStashState(hero)
	else
		SendErrorMessage(hero:GetPlayerOwnerID(), "#No_Items_Found")
	end

end

function RefundItem(caster, item)
	local charges = item:GetCurrentCharges()
	if charges == 0 then
		-- if the item has zero charges, it is removed from
		-- the inventory, therefore we have to recreate the item
		local itemName = item:GetAbilityName()
		item = CreateItem(itemName, caster, nil)
		item:SetCurrentCharges(1)
		caster:AddItem(item)
	else
		item:SetCurrentCharges(charges + 1)
	end
	item:EndCooldown()
end

function PotInstantHeal(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasModifier("jump_pause_nosilence") then
		RefundItem(caster, ability)
		return
	end
	caster:ApplyHeal(500, caster)
	caster:GiveMana(300)

	local healFx = ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_purification_g.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(healFx, 1, caster:GetAbsOrigin()) -- target effect location

	-- Destroy particle
	Timers:CreateTimer(2.0, function()
		ParticleManager:DestroyParticle(healFx, false)
	end)
end

function TPScroll(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasModifier("jump_pause_nosilence") or caster:HasModifier("modifier_story_for_someones_sake") then
		RefundItem(caster, ability)
		caster:Stop()
		return
	end
	local targetPoint = keys.target_points[1]
	--print(caster:GetAbsOrigin().y .. " and " .. caster:GetAbsOrigin().x)
	if caster:GetAbsOrigin().y < -2000 or targetPoint.y < -2000 then
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Invalid_Location")
		RefundItem(caster, ability)
		caster:Stop()
		return
	end

	caster.TPLoc = nil
	local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, 10000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_OTHER, 0, FIND_CLOSEST, false)
	if targets[1] == nil or targets[1]:GetAbsOrigin().y < -2000 then
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Invalid_Location")
		RefundItem(caster, ability)
		caster:Stop()
		return
	else
		caster.TPLoc = targets[1]:GetAbsOrigin()
		local pfx = ParticleManager:CreateParticle( "particles/units/heroes/hero_wisp/wisp_relocate_teleport.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl(pfx, 0, caster:GetAbsOrigin())


		local pfx2 = ParticleManager:CreateParticle( "particles/units/heroes/hero_wisp/wisp_relocate_teleport.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl(pfx2, 0, caster.TPLoc)

		caster:EmitSound("Hero_Wisp.Relocate")
		EmitSoundOnLocationWithCaster(caster.TPLoc, "Hero_Wisp.Relocate", targets[1])

		-- Destroy particle
		Timers:CreateTimer(2.0, function()
			ParticleManager:DestroyParticle(pfx, false)
			ParticleManager:DestroyParticle(pfx2, false)
		end)
	end

end

function TPSuccess(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasModifier("jump_pause_nosilence") then
		RefundItem(caster, ability)
		return
	end
	caster:EmitSound("Hero_Wisp.Return")
	caster:SetAbsOrigin(caster.TPLoc)
	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
end

function MassTPSuccess(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasModifier("jump_pause_nosilence") then
		RefundItem(caster, ability)
		return
	end
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 1000
            , DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
	if caster.TPLoc == nil then
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Must Have Ward Nearby Targeted Location" } )
		caster:AddItem(CreateItem("item_teleport_scroll" , caster, nil))
	else
		caster:EmitSound("Hero_Wisp.Return")
		for k,v in pairs(targets) do
			v:SetAbsOrigin(caster.TPLoc)
			FindClearSpaceForUnit(v, v:GetAbsOrigin(), true)
		end
	end
end

function TPFail(keys)
end

function WardFam(keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = keys.caster:GetPlayerOwner():GetAssignedHero()
	if caster:HasModifier("jump_pause_nosilence") then
		RefundItem(caster, ability)
		return
	end
	hero.ServStat:useWard()
	local targetPoint = keys.target_points[1]
	caster.ward = CreateUnitByName("ward_familiar", targetPoint, true, caster, caster, caster:GetTeamNumber())
	caster.ward:AddNewModifier(caster, caster, "modifier_invisible", {})
	caster.ward:AddNewModifier(caster, caster, "modifier_item_ward_true_sight", {true_sight_range = keys.Radius, duration = keys.Duration})
    caster.ward:AddNewModifier(caster, caster, "modifier_kill", {duration = keys.Duration})
    giveUnitDataDrivenModifier(caster.ward, caster.ward, "modifier_ward_dmg_reduce", {duration = keys.Duration})
    EmitSoundOnLocationForAllies(targetPoint,"DOTA_Item.ObserverWard.Activate",caster)
end

function WardOnTakeDamage(keys)
	if keys.unit.dmgcooldown ~= true then
		keys.unit.dmgcooldown = true
		print("Took Dmg")
		local dmgtable = {
	        attacker = keys.attacker,
	        victim = keys.unit,
	        damage = 2,
	        damage_type = DAMAGE_TYPE_PURE,
	    }
	    print(dmgtable.attacker:GetName(), dmgtable.victim:GetName(), dmgtable.damage)
	    ApplyDamage(dmgtable)
	    Timers:CreateTimer(0.05, function()
			keys.unit.dmgcooldown = false
		end)
	end
end

function OnWardDeath(keys)
	local caster = keys.caster

end

function ScoutFam(keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = keys.caster:GetPlayerOwner():GetAssignedHero()
	if caster:HasModifier("jump_pause_nosilence") then
		RefundItem(caster, ability)
		return
	end
	local pid = caster:GetPlayerID()
	hero.ServStat:useFamiliar()
	local scout = CreateUnitByName("scout_familiar", caster:GetAbsOrigin(), true, caster, caster, caster:GetTeamNumber())
	scout:SetControllableByPlayer(pid, true)
	keys.ability:ApplyDataDrivenModifier(caster, scout, "modifier_banished", {})
	LevelAllAbility(scout)
   	scout:AddNewModifier(caster, nil, "modifier_kill", {duration = 40})
end

function BecomeWard(keys)
	local caster = keys.caster
	local origin = caster:GetAbsOrigin()

	local hero = caster:GetPlayerOwner():GetAssignedHero()
	local transform = CreateUnitByName("ward_familiar", caster:GetAbsOrigin(), true, hero, hero, caster:GetTeamNumber())
	local wardPos = transform:GetAbsOrigin()

	if GridNav:IsBlocked(wardPos)
		or not GridNav:IsTraversable(wardPos)
		or wardPos.y < -2000
	then
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Invalid_Location")
		hero:ModifyGold(1200, true , 0)
		transform:RemoveSelf()
		return
	end
	hero.ServStat:useWard()
	hero.ServStat:trueWorth(1200)

	transform:AddNewModifier(hero, hero, "modifier_invisible", {})
	transform:AddNewModifier(hero, hero, "modifier_item_ward_true_sight", {true_sight_range = 1250, duration = 60})
	transform:AddNewModifier(hero, hero, "modifier_kill", {duration = 60})
	giveUnitDataDrivenModifier(transform, transform, "modifier_ward_dmg_reduce", {duration = 60})
	caster:EmitSound("DOTA_Item.ObserverWard.Activate")
	Timers:CreateTimer({
		endTime = 0.1,
		callback = function()
		caster:RemoveSelf()
		return
	end
	})
end

function SpiritLink(keys)
	--print("Spirit Link Used")
	local caster = keys.caster
	local ability = keys.ability
	local hero = keys.caster:GetPlayerOwner():GetAssignedHero()
	if caster:HasModifier("jump_pause_nosilence") then
		RefundItem(caster, ability)
		return
	end

	local targets = keys.target_entities
	hero.ServStat:useLink()
	--local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 1000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false)
	local linkTargets = {}
	caster:EmitSound("Hero_Warlock.FatalBonds" )
	-- set up table for link
	for i=1,#targets do
		if targets[i]:GetUnitName() ~= "pseudo_illusion" then
			linkTargets[i] = targets[i]
			--print("Added hero to link table : " .. targets[i]:GetName())
			RemoveHeroFromLinkTables(targets[i])

			-- particle
	    	local pulseFx = ParticleManager:CreateParticle( "particles/units/heroes/hero_warlock/warlock_fatal_bonds_pulse.vpcf", PATTACH_CUSTOMORIGIN, caster )
		    ParticleManager:SetParticleControl( pulseFx, 0, caster:GetAbsOrigin() + Vector(0,0,100))
		    ParticleManager:SetParticleControl( pulseFx, 1, targets[i]:GetAbsOrigin() + Vector(0,0,100))
		end
	end

	-- add list of linked targets to hero table
	for i=1,#targets do
		targets[i].linkTable = linkTargets
		--print("Table Contents " .. i .. " : " .. targets[i]:GetName())
		keys.ability:ApplyDataDrivenModifier(caster, targets[i], "modifier_share_damage", {})
	end
end

function OnLinkDestroyed(keys)
	local caster = keys.caster
	local target = keys.target
end

function GemOfResonance(keys)
	-- body
end


function Blink(keys)
	local caster = keys.caster
	local ability = keys.ability
	local casterPos = caster:GetAbsOrigin()
	local targetPoint = keys.target_points[1]
	local newTargetPoint = nil

	if IsLocked(caster) or caster:HasModifier("jump_pause_nosilence") or caster:HasModifier("modifier_story_for_someones_sake") then
		keys.ability:EndCooldown()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Blink")
		return
	end

	if caster:HasModifier("modifier_aestus_domus_aurea_lock") then
		local target = 0
		local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 1200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
		for i=1, #targets do
			target = targets[i]
			if target:GetName() == "npc_dota_hero_lina" then
				break
			end
		end
		if not IsFacingUnit(caster, target, 90) then
			keys.ability:EndCooldown()
			SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Blink")
			return
		end
	end


	if GridNav:IsBlocked(targetPoint) or not GridNav:IsTraversable(targetPoint) then
		keys.ability:EndCooldown()
		if ability:GetName() == "caster_5th_dimensional_jump" then
			caster:GiveMana(150) -- 150 being mana cost of Dimensional Jump
		end
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Travel")
		return
	end


	-- particle
	local particle = ParticleManager:CreateParticle("particles/items_fx/blink_dagger_start.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(particle, 0, casterPos)
	caster:EmitSound("Hero_Antimage.Blink_out")
	local particle2 = ParticleManager:CreateParticle("particles/items_fx/blink_dagger_end.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(particle2, 0, targetPoint)

	-- blink
	local diff = targetPoint - caster:GetAbsOrigin()
	if diff:Length() <= 1000 then
		caster:SetAbsOrigin(targetPoint)
		ProjectileManager:ProjectileDodge(caster)
		--ParticleManager:SetParticleControl(particle2, 0, targetPoint)
		EmitSoundOnLocationWithCaster(targetPoint, "Hero_Antimage.Blink_in", caster)
	else
		newTargetPoint = caster:GetAbsOrigin() + diff:Normalized() * 1000
		local i = 1
		while GridNav:IsBlocked(newTargetPoint) or not GridNav:IsTraversable(newTargetPoint) or i == 100 do
			i = i+1
			newTargetPoint = caster:GetAbsOrigin() + diff:Normalized() * (1000 - i*10)
		end

		caster:SetAbsOrigin(newTargetPoint)
		ProjectileManager:ProjectileDodge(caster)
		ParticleManager:SetParticleControl(particle2, 0, caster:GetAbsOrigin())
		EmitSoundOnLocationWithCaster(newTargetPoint, "Hero_Antimage.Blink_in", caster)
	end

	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)

	Timers:CreateTimer(2.0, function()
		ParticleManager:DestroyParticle(particle, false)
		ParticleManager:DestroyParticle(particle2, false)
	end)
end

function StashBlink(keys)
	local caster = keys.caster
	local casterinitloc = caster:GetAbsOrigin()
	local targetPoint = keys.target_points[1]
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	caster:SetAbsOrigin(hero:GetAbsOrigin())
	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)

	Timers:CreateTimer(8.0, function()
		caster:SetAbsOrigin(casterinitloc)
		return
	end)

	caster:EmitSound("DOTA_Item.BlinkDagger.Activate")
	local particle2 = ParticleManager:CreateParticle("particles/items_fx/blink_dagger_end.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle2, 1, caster:GetAbsOrigin()) -- target effect location
	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
end

function ManaEssence(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasModifier("jump_pause_nosilence") then
		RefundItem(caster, ability)
		return
	end
	ability:ApplyDataDrivenModifier(caster, caster, "item_pot_regen", {})
	caster:EmitSound("DOTA_Item.ClarityPotion.Activate")
end

function BerserkScroll(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasModifier("jump_pause_nosilence") then
		RefundItem(caster, ability)
		return
	end
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_berserk_scroll", {})
	caster:EmitSound("DOTA_Item.MaskOfMadness.Activate")
end

function SpeedGem(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasModifier("jump_pause_nosilence") or caster:HasModifier("modifier_story_for_someones_sake") then
		RefundItem(caster, ability)
		return
	end
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_speed_gem", {})
	caster:EmitSound("DOTA_Item.PhaseBoots.Activate")
end

function CScroll(keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = keys.caster:GetPlayerOwner():GetAssignedHero()
	if caster:HasModifier("jump_pause_nosilence") then
		RefundItem(caster, ability)
		return
	end
	local pid = caster:GetPlayerID()
	cdummy = CreateUnitByName("dummy_unit", caster:GetAbsOrigin(), true, caster, caster, caster:GetTeamNumber())
	cdummy:AddNewModifier(caster, caster, "modifier_kill", {duration = 10})
	local dummy_passive = cdummy:FindAbilityByName("dummy_unit_passive")
	dummy_passive:SetLevel(1)
	local fire = cdummy:FindAbilityByName("dummy_c_scroll")
	fire:SetLevel(1)
	if fire:IsFullyCastable() then
		cdummy:CastAbilityOnTarget(keys.target, fire, pid)
	end
	hero.ServStat:useC()
	caster:RemoveItem(keys.ability)

	--[[Timers:CreateTimer(5.0, function()
		if IsValidEntity(cdummy) and not cdummy:IsNull() then
			cdummy:RemoveSelf()
		end
	end)]]

end

function CScrollHit(keys)
	local caster = keys.caster
	local target = keys.target

	if IsSpellBlocked(keys.target) then return end
	DoDamage(keys.caster:GetPlayerOwner():GetAssignedHero(), keys.target, 100, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	keys.target:EmitSound("Hero_EmberSpirit.FireRemnant.Explode")
	if not keys.target:IsMagicImmune() then
		keys.target:AddNewModifier(keys.caster:GetPlayerOwner():GetAssignedHero(), keys.target, "modifier_stunned", {Duration = 1.0})
	end
end

function CScrollEnd(keys)
	local caster = keys.caster
	local target = keys.target
	if IsValidEntity(caster) and not caster:IsNull() then
		caster:RemoveSelf()
	end
end

function BScroll(keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = keys.caster:GetPlayerOwner():GetAssignedHero()

	if caster:HasModifier("jump_pause_nosilence") then
		RefundItem(caster, ability)
		return
	end

	hero.ServStat:useB()
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_b_scroll", {})
	caster.BShieldAmount = keys.ShieldAmount
	caster:EmitSound("DOTA_Item.ArcaneBoots.Activate")

end

function AScroll(keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = keys.caster:GetPlayerOwner():GetAssignedHero()

	if caster:HasModifier("jump_pause_nosilence") then
		RefundItem(caster, ability)
		return
	end

	hero.ServStat:useA()
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_a_scroll", {})
	caster:EmitSound("Hero_Oracle.FatesEdict.Cast")
end


function SScroll(keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = keys.caster:GetPlayerOwner():GetAssignedHero()
	if caster:HasModifier("jump_pause_nosilence") then
		RefundItem(caster, ability)
		return
	end
	local target = keys.target
	hero.ServStat:useS()
	if IsSpellBlocked(keys.target) then return end

	DoDamage(caster, target, 400, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	ApplyPurge(target)

	ability:ApplyDataDrivenModifier(caster, target, "modifier_purge", {})
	if not IsImmuneToSlow(target) then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_slow_tier1", {})
		ability:ApplyDataDrivenModifier(caster, target, "modifier_slow_tier2", {})
	end

	local boltFx = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
	ParticleManager:SetParticleControl(boltFx, 1, Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z+((target:GetBoundingMaxs().z - target:GetBoundingMins().z)/2)))

	local lightningBoltFx = ParticleManager:CreateParticle("particles/units/heroes/hero_leshrac/leshrac_lightning_bolt.vpcf", PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(lightningBoltFx,0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(lightningBoltFx,1, target:GetAbsOrigin())

	Timers:CreateTimer(2.0, function()
		ParticleManager:DestroyParticle(boltFx, false)
		ParticleManager:DestroyParticle(lightningBoltFx, false)
	end)

	target:EmitSound("Hero_Zuus.GodsWrath.Target")
end

function EXScroll(keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = keys.caster:GetPlayerOwner():GetAssignedHero()
	if caster:HasModifier("jump_pause_nosilence") then
		RefundItem(caster, ability)
		return
	end
	hero.ServStat:useEX()
	local target = keys.target
	if IsSpellBlocked(keys.target) then return end
	local lightning = {
		attacker = caster,
		victim = target,
		damage = 600,
		damage_type = DAMAGE_TYPE_MAGICAL,
		damage_flags = 0,
		ability = ability
	}
	DoDamage(caster, target, 600, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	ApplyPurge(target)

	ability:ApplyDataDrivenModifier(caster, target, "modifier_purge", {})
	if not IsImmuneToSlow(target) then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_slow_tier1", {})
		ability:ApplyDataDrivenModifier(caster, target, "modifier_slow_tier2", {})
	end

	local boltFx = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
	--local lightningBoltFx = ParticleManager:CreateParticle("particles/units/heroes/hero_leshrac/leshrac_lightning_bolt.vpcf", PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(boltFx, 1, Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z+((target:GetBoundingMaxs().z - target:GetBoundingMins().z)/2)))

	local forkCount = 0
	local dist = target:GetAbsOrigin() - caster:GetAbsOrigin()
	local targets = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin() + dist:Normalized() * 150, nil, 600
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false)
	for k,v in pairs(targets) do
		if forkCount == 4 then return end
		if v ~= target then
	        DoDamage(caster, v, 600, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	        local bolt = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
	        ParticleManager:SetParticleControl(bolt, 1, Vector(v:GetAbsOrigin().x,v:GetAbsOrigin().y,v:GetAbsOrigin().z+((v:GetBoundingMaxs().z - v:GetBoundingMins().z)/2)))
	        Timers:CreateTimer(2.0, function()
				ParticleManager:DestroyParticle(bolt, false)
			end)

			--ParticleManager:SetParticleControl(lightningBoltFx,0, caster:GetAbsOrigin())
			--ParticleManager:SetParticleControl(lightningBoltFx,1, v:GetAbsOrigin())
	        forkCount = forkCount + 1
    	end
    end

   	Timers:CreateTimer(2.0, function()
		ParticleManager:DestroyParticle(boltFx, false)
		--ParticleManager:DestroyParticle(lightningBoltFx, false)
	end)
	target:EmitSound("Hero_Zuus.GodsWrath.Target")
end



function HealingScroll(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasModifier("jump_pause_nosilence") then
		RefundItem(caster, ability)
		return
	end

	local healFx = ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_purification_g.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)

	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 600
            , DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
		if v:GetName() ~= "npc_dota_ward_base" then
			ParticleManager:SetParticleControl(healFx, 1, v:GetAbsOrigin()) -- target effect location
    	    v:ApplyHeal(500, caster)
       		ability :ApplyDataDrivenModifier(caster, v, "modifier_healing_scroll", {})
       	end
    end

   	Timers:CreateTimer(2.0, function()
		ParticleManager:DestroyParticle(healFx, false)
	end)
end

function AntiMagic(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasModifier("jump_pause_nosilence") then
		RefundItem(caster, ability)
		return
	end
	caster:EmitSound("DOTA_Item.BlackKingBar.Activate")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_magic_immunity", {})

end

function Replenish(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasModifier("jump_pause_nosilence")
		or caster:GetHealth() == caster:GetMaxHealth() and caster:GetMana() == caster:GetMaxMana()
	then
		RefundItem(caster, ability)
		return
	end

	caster:SetHealth(caster:GetMaxHealth())
	caster:SetMana(caster:GetMaxMana())
	ability:ApplyDataDrivenModifier(caster, caster, "shard_of_replenishment_armor_buff", {})

	caster:EmitSound("DOTA_Item.Mekansm.Activate")
	local mekFx = ParticleManager:CreateParticle("particles/items2_fx/mekanism.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)

   	Timers:CreateTimer(2.0, function()
		ParticleManager:DestroyParticle(mekFx, false)
	end)
end

function ItemLocker(hHero, iStartSlot, iEndSlot)
	if hHero.bIsInventoryLocked then
		local tLockedOrder = hHero.tLockedInventoryOrder
		local tCurrentOrder = {}		
		local tCommons = {}
		local tLeftovers = {}
		local tCharges = {}
		local iSS = iStartSlot
		local iES = iEndSlot

		--save current order of items and their charges
		for i=iSS, iES do
			if hHero:GetItemInSlot(i) ~= nil then 
				local hItem = hHero:GetItemInSlot(i)
				tCurrentOrder[i] = hItem:GetName()
				tCharges[i] = hItem:GetCurrentCharges()
			else
				tCurrentOrder[i] = nil
				tCharges[i] = nil
			end
		end
		--put common elements of tables: item lock list, currentorder into common exit table 
		for i=iSS, iES do
			local bItemFound = false
			for j=iSS, iES do
				if tLockedOrder[j] == tCurrentOrder[i] and tLockedOrder[j] ~= nil then
					tCommons[j] = tCurrentOrder[i]
					bItemFound = true
					--if item is found check if player has more than one of same name and throw them into separate table
					for k=i+1, iES do 
						if tCurrentOrder[k] == tCurrentOrder[i] then
							tLeftovers[k] = tCurrentOrder[i]
						end
					end
					break
				end
			end
			--filter items that arent locked into leftovers, along with their original slot number
			if not bItemFound and tCurrentOrder[i] ~= nil then
				tLeftovers[i] = tCurrentOrder[i]
			end
		end
																		---[[
																		print("\n----lockedorder----")
																		for k,v in pairs(tLockedOrder) do			
																			print(k,v)
																		end
																		print("\n----currentorder----")
																		for k,v in pairs(tCurrentOrder) do			
																			print(k,v)
																		end
																		print("\n----charges----")
																		for k,v in pairs(tCharges) do			
																			print(k,v)
																		end			
																		print("\n-----commons-----")
																		for k,v in pairs(tCommons) do			
																			print(k,v)
																		end
																		print("\n----leftovers----")
																		for k,v in pairs(tLeftovers) do			
																			print(k,v)
																		end
		--]]place some of leftovers in original slots (if possible) and remove the key
		for k,v in pairs(tLeftovers) do
			if tCommons[k] == nil then
				tCommons[k] = v
				tLeftovers[k] = nil
			end
		end		
																		---[[
																		print("\n----commons AFTER----")
																		for k,v in pairs(tCommons) do			
																			print(k,v)
																		end
																		print("\n---leftovers AFTER---")
																		for k,v in pairs(tLeftovers) do			
																			print(k,v)
																		end											
		--]]rest of leftovers is placed in first available slots
		for k,v in pairs(tLeftovers) do
			for i=iSS, iES do			
				if tCommons[i] == nil then
					tCommons[i] = v 
					break
				end
			end
		end	
		 --slots that supposed are to be empty have to be filled with dummies for items to go into right slots
		for i=iSS, iES do
			if tCommons[i] == nil then
				tCommons[i] = "item_dummy_item_unusable"
			end
		end
																		---[[
																		print("\n----COMMONS FINAL----")
																		for k,v in pairs(tCommons) do			
																			print(k,v)
																		end
		--]]remove all items, its important to do it before adding a single item, because some items autocombine (shards) and in some cases they might get deleted depending on item order
		for i=iSS, iES do 
			hHero:RemoveItem(hHero:GetItemInSlot(i))
		end
		--recreate inventory
		for i=iSS, iES do 
			local iCharges 
			--find correct ammount of charges based on original order table
			for j=iSS, iES do
				if tCommons[i] == "item_dummy_item_unusable" then
					iCharges = -1
					break
				end
				if tCommons[i] == tCurrentOrder[j] then
					iCharges = tCharges[j]
					tCurrentOrder[j] = nil --clear key so that you find next entry on next run in case of having double of an item and they might be diff charges
					break
				end
			end
			local sName = tCommons[i]
			local hNewItem = CreateItem(sName, nil, nil)
			hNewItem:SetCurrentCharges(iCharges)
			hHero:AddItem(hNewItem)
		end
		--clear dummy items
		for i=iSS, iES do
			local hItem = hHero:GetItemInSlot(i)
			if hItem ~= nil and hItem:GetName() == "item_dummy_item_unusable" then
				hHero:RemoveItem(hItem)
			end
		end				
	end
end
