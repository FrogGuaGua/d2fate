vlad_kazikli_bey = class({})
--LinkLuaModifier("modifier_kazikli_bey", "abilities/vlad/modifier_kazikli_bey", LUA_MODIFIER_MOTION_NONE)
--remember to merge util lua ApplyAirborne and new ApplyAirborneOnly

if not IsServer() then
  return
end

function vlad_kazikli_bey:VFX1_SmallSpikesHold(caster)
	self.PI4 = FxCreator("particles/custom/vlad/vlad_kb_hold.vpcf", PATTACH_ABSORIGIN, caster,0,nil)
	self.PI5 = FxCreator("particles/custom/vlad/vlad_kb_hold_swirl.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster,0,nil)
	ParticleManager:SetParticleControlEnt(self.PI5, 5, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false)
	ParticleManager:SetParticleControlEnt(self.PI5, 2, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false)
	ParticleManager:SetParticleControlEnt(self.PI5, 7, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false)

	Timers:CreateTimer(2.8, function()
		FxDestroyer(self.PI4, false)
		FxDestroyer(self.PI5, false)
  end)
end

function vlad_kazikli_bey:VFX2_LastSpikes(caster)
	---[[using dummy stops bloodrite splash doing random shit so it will stay for now
	local dummy = CreateUnitByName("visible_dummy_unit", caster:GetOrigin(), false, caster, caster, caster:GetTeamNumber())
  dummy:FindAbilityByName("dummy_visible_unit_passive"):SetLevel(1)
  dummy:SetDayTimeVisionRange(0)
  dummy:SetNightTimeVisionRange(0)
  dummy:SetAbsOrigin(caster:GetAbsOrigin())--]]
	local PI1 = FxCreator("particles/custom/vlad/vlad_kb_spikesend.vpcf", PATTACH_ABSORIGIN, dummy,0,nil)

	Timers:CreateTimer(2, function()
		FxDestroyer(PI1, false)
    dummy:RemoveSelf()
  end)
end

function vlad_kazikli_bey:VFX3_BeforeOnTargetImpale(caster,k,target)
	self.PI1[k] = FxCreator("particles/custom/vlad/vlad_kb_ontarget_prespike.vpcf", PATTACH_ABSORIGIN, target,0,nil)
	ParticleManager:SetParticleControlEnt(self.PI1[k], 3, caster, PATTACH_POINT_FOLLOW	, "attach_hitloc", caster:GetAbsOrigin(),false)
end

function vlad_kazikli_bey:VFX4_OnTargetImpale(k,target)
	self.PI2[k] = FxCreator("particles/custom/vlad/vlad_kb_ontarget.vpcf", PATTACH_ABSORIGIN, target, 0, nil)
  ParticleManager:SetParticleControl(self.PI2[k],4, Vector(3.7, 0, 0))
	self.PI3[k] = FxCreator("particles/custom/vlad/vlad_impale_bleed.vpcf", PATTACH_ABSORIGIN_FOLLOW, target, 0, nil)
	ParticleManager:SetParticleControlEnt(self.PI3[k], 1, target, PATTACH_ABSORIGIN_FOLLOW	, nil, target:GetAbsOrigin(), false)
end

function vlad_kazikli_bey:ApplyAttrBaseBonuses(caster,dmg_spikes,dmg_lastspike)
	--improve dmg by base attr bonuses
	if caster.ImprovedImpalingAcquired then
		local attribute_ability = caster.MasterUnit2:FindAbilityByName("vlad_attribute_improved_impaling")
		dmg_spikes = dmg_spikes + attribute_ability:GetSpecialValueFor("kb_bonus_spikes_dmg")
		dmg_lastspike = dmg_lastspike + attribute_ability:GetSpecialValueFor("kb_bonus_lastspike_dmg")
	end
	return dmg_spikes, dmg_lastspike
end

function vlad_kazikli_bey:ApplyAttrExtraDmg(caster,dmg_lastspike,bloodpower)
	--improve dmg by bonus based on bleeds count present on all heroes
	print("ApplyAttrBonusDmg lastspike is: ",dmg_lastspike)
	local bonus_cap = caster.AttrBonusCap
  local dmg_lastspike_base = dmg_lastspike
	if caster.ImprovedImpalingAcquired then
		local attribute_ability = caster.MasterUnit2:FindAbilityByName("vlad_attribute_improved_impaling")
		local bleedcounter = caster:GetGlobalBleeds()
		dmg_lastspike = dmg_lastspike + (bleedcounter * attribute_ability:GetSpecialValueFor("kb_bonus_dmg_per_stack"))
	end
  print("ApplyAttrBonusDmg POST IMPALING lastspike is: ",dmg_lastspike)
	--improve dmg by percentile value based on bloodpower stacks used
	if caster.BloodletterAcquired then
		local attribute_ability = caster.MasterUnit2:FindAbilityByName("vlad_attribute_bloodletter")
		dmg_lastspike = dmg_lastspike + (dmg_lastspike * bloodpower * attribute_ability:GetSpecialValueFor("kb_bonus_dmg_per_stack"))
	end
	--cap bonus dmg from bleeds and bloodpower
	dmg_lastspike = math.min(dmg_lastspike, dmg_lastspike_base + bonus_cap)
	print("ApplyAttrBonusDmg POST BLOODLETTER lastspike is: ",dmg_lastspike)
	return dmg_lastspike
end

function vlad_kazikli_bey:OnSpellStart()
	local caster = self:GetCaster()
	local aoe_spikes = self:GetSpecialValueFor("aoe_spikes")
	local aoe_lastspike = self:GetSpecialValueFor("aoe_lastspike")
	local dmg_spikes = self:GetSpecialValueFor("dmg_spikes")
	local dmg_lastspike = self:GetSpecialValueFor("dmg_lastspike")
	local stun = self:GetSpecialValueFor("stun")
	local activation = self:GetSpecialValueFor("activation")
	local endcast_pause = self:GetSpecialValueFor("endcast_pause")
	local hitcounter = 1
  local bloodpower = 0
  --caster:AddNewModifier(caster,self,"modifier_kazikli_bey",{duration = 4})


	--check how many bloodpower stacks vlad has at start of cast and save number
  if not caster:HasModifier("modifier_transfusion_self") then
  	local modifier = caster:FindModifierByName("modifier_transfusion_bloodpower")
   	bloodpower = modifier and modifier:GetStackCount() or 0
    caster:ResetImpaleSwapTimer()
    caster:RemoveModifierByName("modifier_transfusion_bloodpower")
  end

	dmg_spikes, dmg_lastspike = self:ApplyAttrBaseBonuses(caster,dmg_spikes,dmg_lastspike)
	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 2.66 + endcast_pause) -- 2.66 is ideal time if there is to be no endcast pause, for current values of activation and interval
	StartAnimation(caster, {duration=2.5, activity=ACT_DOTA_CAST_ABILITY_4, rate=1.05})
	self:VFX1_SmallSpikesHold(caster)
  EmitGlobalSound("Vlad.Laugh")

	Timers:CreateTimer(activation,function()
		if caster:IsAlive() then
			--FX stuff
			if (hitcounter % 2) == 0 then
				caster:EmitSound("Hero_Lycan.Attack")
			else
				caster:EmitSound("Hero_NyxAssassin.SpikedCarapace")
			end

			if hitcounter == 2 then
				caster:EmitSound("Ability.SandKing_Epicenter.spell")
			elseif hitcounter == 4 then
				StartAnimation(caster, {duration=2.5, activity=ACT_DOTA_CAST_ABILITY_2, rate=0.8})
			elseif hitcounter == 8 then
				EmitGlobalSound("Vlad.KB")
			elseif hitcounter == 9 then
				self.PI1 = {}
				local targets2 = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, aoe_lastspike, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
				for k,v in pairs(targets2) do
					self:VFX3_BeforeOnTargetImpale(caster,k,v)
				end
			end

			--last strike
			if hitcounter == 11 then
				self.PI2 = {}
				self.PI3 = {}
				self:VFX2_LastSpikes(caster)
        caster:EmitSound("Hero_OgreMagi.Bloodlust.Cast")
				ScreenShake(caster:GetOrigin(), 7, 1.0, 2, 1500, 0, true)
				dmg_lastspike = self:ApplyAttrExtraDmg(caster,dmg_lastspike,bloodpower) --last spike bonuses from bleeds and bloodpower are calculated right before it hits

				local lasthitTargets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, aoe_lastspike, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
				for k,v in pairs(lasthitTargets) do
          if v:GetName() ~= "npc_dota_ward_base" then
            DoDamage(caster, v, dmg_lastspike, DAMAGE_TYPE_MAGICAL, 0, self, false)
  					caster:AddBleedStack(v, false)
  					giveUnitDataDrivenModifier(caster, v, "stunned", stun)
  					giveUnitDataDrivenModifier(caster, v, "revoked", stun)
  					ApplyAirborneOnly(v, 2000, stun)
  					self:VFX4_OnTargetImpale(k,v)
          end
				end

				if #lasthitTargets ~= 0 then
					caster:EmitSound("Hero_PhantomAssassin.CoupDeGrace")
				end

        if caster.ImprovedImpalingAcquired then
          local heal_per_target = caster.MasterUnit2:FindAbilityByName("vlad_attribute_improved_impaling"):GetSpecialValueFor("kb_spike_heal_per_target")
          caster:ApplyHeal(heal_per_target * #lasthitTargets, caster)
        end
				--remove ontarget VFX
				Timers:CreateTimer(1.5, function()
					FxDestroyer(self.PI1, false)
					FxDestroyer(self.PI2, false)
					FxDestroyer(self.PI3, false)
			  end)
			--small spikes
			else
				local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, aoe_spikes, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
				for k,v in pairs(targets) do
          if caster.ImprovedImpalingAcquired and (hitcounter % 2) == 0 then
            caster:AddBleedStack(v,false,1)
          end
					DoDamage(caster, v, dmg_spikes, DAMAGE_TYPE_MAGICAL, 0, self, false)
					giveUnitDataDrivenModifier(caster, v, "stunned", 0.4)
					giveUnitDataDrivenModifier(caster, v, "revoked", 0.4)
				end
				hitcounter = hitcounter + 1
				return 0.2
			end
		else
			FxDestroyer(self.PI4, true)
			FxDestroyer(self.PI5, true)
			return nil
		end
	end)
end

function vlad_kazikli_bey:GetAbilityTextureName()
  return "custom/vlad_kazikli_bey"
end
