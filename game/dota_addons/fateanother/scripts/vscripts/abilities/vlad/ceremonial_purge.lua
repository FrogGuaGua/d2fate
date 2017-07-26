vlad_ceremonial_purge = class({})
LinkLuaModifier("modifier_ceremonial_purge_slow", "abilities/vlad/modifier_ceremonial_purge_slow", LUA_MODIFIER_MOTION_NONE)

if not IsServer() then
  return
end

function vlad_ceremonial_purge:VFX1_Slash(caster)
	local PI1 = FxCreator("particles/custom/vlad/vlad_cp_spin.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster, 2, nil)
	ParticleManager:SetParticleControlEnt(PI1, 1, caster, PATTACH_POINT_FOLLOW	, "attach_lance_max", caster:GetAbsOrigin(),false)
	ParticleManager:SetParticleControlEnt(PI1, 3, caster, PATTACH_POINT_FOLLOW	, "attach_lance_max-1", caster:GetAbsOrigin(),false)
	ParticleManager:SetParticleControlEnt(PI1, 8, caster, PATTACH_POINT_FOLLOW	, "attach_lance_tip-1", caster:GetAbsOrigin(),false)

	Timers:CreateTimer(4, function()
	 	FxDestroyer(PI1, false)
	end)
end

function vlad_ceremonial_purge:GetManaCost(iLevel)
	local caster = self:GetCaster()
	local condition_free_mana = self:GetSpecialValueFor("condition_free_mana")
	if caster.ImprovedImpalingAcquired then
		local attr_ability = caster.MasterUnit2:FindAbilityByName("vlad_attribute_improved_impaling")
		condition_free_mana = attr_ability:GetSpecialValueFor("cp_conditional")
	end
  if caster:GetHealthPercent() <= condition_free_mana then
    return 0
  else
    return self:GetSpecialValueFor("mana_cost")
  end
end

function vlad_ceremonial_purge:GetDamage(caster)
	local dmg_inner = self:GetSpecialValueFor("dmg_inner")
	local dmg_outer = self:GetSpecialValueFor("dmg_outer")
	local dmg_inner_base = dmg_inner
	local dmg_outer_base = dmg_outer
	local bonus_dmg = self:GetSpecialValueFor("bonus_dmg")
	local bonus_cap = caster.AttrBonusCap
	local attr_bonus = 0

	--improve dmg by base bonuses and add bonus for total bleeds
	if caster.ImprovedImpalingAcquired then
		local attr_ability = caster.MasterUnit2:FindAbilityByName("vlad_attribute_improved_impaling")
		local ceremonial_dmg_bonus = attr_ability:GetSpecialValueFor("cp_dmg_bonus")
		dmg_outer = dmg_outer + ceremonial_dmg_bonus
		dmg_inner = dmg_inner + ceremonial_dmg_bonus
		dmg_inner_base = dmg_inner -- base bonus from attr doesnt count toward bonus dmg cap
		dmg_outer_base = dmg_outer
		local bleedcounter = caster:GetGlobalBleeds()
		attr_bonus = bleedcounter * attr_ability:GetSpecialValueFor("cp_bonus_dmg_per_stack")
		dmg_inner = dmg_inner + attr_bonus
		dmg_outer = dmg_outer + attr_bonus
	end

	--improve dmg by percentile value based on bloodpower stacks if buff is present and remove the buff
	print("before  ",dmg_inner, "   ", dmg_outer)
	if caster.BloodletterAcquired then
    if not caster:HasModifier("modifier_transfusion_self") then
			caster:ResetImpaleSwapTimer()
			local modifier = caster:FindModifierByName("modifier_transfusion_bloodpower")
			local bloodpower = modifier and modifier:GetStackCount() or 0
			local attribute_ability = caster.MasterUnit2:FindAbilityByName("vlad_attribute_bloodletter")
			local bonus_dmg_per_bloodpower = attribute_ability:GetSpecialValueFor("cp_bonus_dmg_per_stack")
			dmg_inner = dmg_inner + (dmg_inner * bloodpower * bonus_dmg_per_bloodpower)
			dmg_outer = dmg_outer + (dmg_outer * bloodpower * bonus_dmg_per_bloodpower)
			caster:RemoveModifierByName("modifier_transfusion_bloodpower")
  	end
	end
	print("after  ",dmg_inner, "   ", dmg_outer)
	--cap dmg bonus from sources: global bleeds, bloodpower
	dmg_inner = math.min(dmg_inner, dmg_inner_base + bonus_cap)
	dmg_outer = math.min(dmg_outer, dmg_outer_base + bonus_cap)
	--print("aftercap  ",dmg_inner, "   ", dmg_outer)
	return dmg_inner, dmg_outer
end


function vlad_ceremonial_purge:OnSpellStart()
  local caster = self:GetCaster()
	local aoe_inner = self:GetSpecialValueFor("aoe_inner")
	local aoe_outer = self:GetSpecialValueFor("aoe_outer")
	local stun_inner = self:GetSpecialValueFor("stun_inner")
	local stun_outer = self:GetSpecialValueFor("stun_outer")
	local slow_duration = self:GetSpecialValueFor("slow_duration")
	local dmg_inner, dmg_outer = self:GetDamage(caster)
	local hp_cost = self:GetSpecialValueFor("hp_cost")
	local hp_max = caster:GetMaxHealth()
	local hp_current = caster:GetHealth() - (hp_max * hp_cost)
	if hp_current > 1 then
		caster:SetHealth(hp_current)
	else
		caster:SetHealth(1)
	end
	
	StartAnimation(caster, {duration=1, activity=ACT_DOTA_CAST_ABILITY_1, rate=1.5})
	self:VFX1_Slash(caster)

  caster:EmitSound("Hero_Axe.CounterHelix_Blood_Chaser")
	--caster:EmitSound("Hero_Axe.CounterHelix")
	caster:EmitSound("Hero_Magnataur.ReversePolarity.Anim")

  giveUnitDataDrivenModifier(caster, caster, "drag_pause",0.5)
	Timers:CreateTimer(0.30, function()
		local targets_outer = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, aoe_outer, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
		--[[ alternate way to pick which targets are in which aoe if some issues
		local targets_inner = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, aoe_inner, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
		for k,v in pairs(targets_outer) do
			if targets_inner[k] == v then
			(...)
		--]]
		for k,v in pairs(targets_outer) do
			local distance = (v:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
      --print(distance)
			v:EmitSound("Hero_NyxAssassin.SpikedCarapace")

			if distance < aoe_inner then
				DoDamage(caster, v, dmg_inner, DAMAGE_TYPE_MAGICAL, 0, self, false)
        giveUnitDataDrivenModifier(caster, v, "stunned", stun_inner)
			else
				DoDamage(caster, v, 1, DAMAGE_TYPE_MAGICAL, 0, self, false)
        v:AddNewModifier(caster,self,"modifier_ceremonial_purge_slow",{duration = slow_duration})
        giveUnitDataDrivenModifier(caster, v, "stunned", stun_outer)
				caster:AddBleedStack(v,false)
			end
		end
	end)
end

function vlad_ceremonial_purge:GetCastAnimation()
  return nil
end

function vlad_ceremonial_purge:GetTexture()
  return "custom/vlad_ceremonial_purge"
end
