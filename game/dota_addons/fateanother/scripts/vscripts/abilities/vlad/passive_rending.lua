vlad_passive_rending = class({})
LinkLuaModifier("modifier_rending", "abilities/vlad/modifier_rending", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bleed", "abilities/vlad/modifier_bleed", LUA_MODIFIER_MOTION_NONE)

if not IsServer() then
	return
end

function vlad_passive_rending:OnUpgrade()
	local caster = self:GetCaster()
  local ability = self
	Timers:CreateTimer(5, function()
 		caster.AttrBonusCap = caster.MasterUnit2:FindAbilityByName("vlad_attribute_bloodletter"):GetSpecialValueFor("bonus_cap")
	end)
	if not caster.AddBleedStack then
		function caster:AddBleedStack(...)
			ability:AddStack(...)
		end
	end
	if not caster.GetGlobalBleeds then
		function caster:GetGlobalBleeds(...)
			return ability:BleedSeek(...)
		end
	end
end

function vlad_passive_rending:BleedSeek()
	local caster = self:GetCaster()
	local bleedcounter = 0
	LoopOverPlayers(function(player, playerID, playerHero)
    if playerHero:GetTeamNumber() ~= caster:GetTeamNumber() then
			local modbleed = playerHero:FindModifierByName("modifier_bleed") or nil
			if modbleed ~= nil then
				bleedcounter = bleedcounter + modbleed:GetStackCount()
			end
    end
  end)
	return bleedcounter
end

function vlad_passive_rending:AddStack(target,isMelee,count)
	--3rd arg is not needed, may be used to override default value
	if target:IsRealHero() then 
		local caster = self:GetCaster()
		local _count
		if isMelee then
			_count = self:GetSpecialValueFor("stacks_onhit_melee")
			if caster:HasModifier("modifier_rebellious_intent") then
				_count = _count * 2
				if count then
					count = count * 2
				end
			end
		else			
			_count = self:GetSpecialValueFor("stacks_onhit_abilities")
		end
			
		local bleed_duration = self:GetSpecialValueFor("duration")
	  local modifier = target:FindModifierByName("modifier_bleed")
	  local currentStack = modifier and modifier:GetStackCount() or 0
	  --target:RemoveModifierByName("modifier_bleed")
	  if not modifier then 
			local mod = target:AddNewModifier(caster, self, "modifier_bleed", {duration = bleed_duration})
		else
			modifier:SetDuration(bleed_duration, true)
		end
	  target:SetModifierStackCount("modifier_bleed", self, currentStack + (count or _count) )
	end
end

function vlad_passive_rending:GetIntrinsicModifierName()
  return "modifier_rending"
end
