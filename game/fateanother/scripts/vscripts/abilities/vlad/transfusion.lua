vlad_transfusion = class({})
LinkLuaModifier("modifier_transfusion_target", "abilities/vlad/modifier_transfusion_target", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_transfusion_self", "abilities/vlad/modifier_transfusion_self", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_transfusion_bloodpower", "abilities/vlad/modifier_transfusion_bloodpower", LUA_MODIFIER_MOTION_NONE)

if IsClient() then  
  function vlad_transfusion:GetCastRange( vLocation, hTarget)
    return self:GetSpecialValueFor("aoe")
  end  
  
  return
end

function vlad_transfusion:VFX1_SuckOnAndLiveLongBitch(caster,k,target)
  self.PI1[k] = FxCreator("particles/custom/vlad/vlad_tf_ontarget_drain.vpcf",PATTACH_CENTER_FOLLOW,target,0,nil)
  ParticleManager:SetParticleControlEnt( self.PI1[k], 2, caster,  PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false )
end

function vlad_transfusion:AddBloodpowerStack(target,count)
	if target.BloodletterAcquired then
	  local modifier = target:FindModifierByName("modifier_transfusion_bloodpower")
	  local currentStack = modifier and modifier:GetStackCount() or 0
	  target:RemoveModifierByName("modifier_transfusion_bloodpower")
	  target:AddNewModifier(target, self, "modifier_transfusion_bloodpower", {duration = self:GetSpecialValueFor("bloodpower_duration")})
	  target:SetModifierStackCount("modifier_transfusion_bloodpower", self, currentStack + count)
	end
end

--instant curse ability swap
function vlad_transfusion:ImpaleSwap(caster)
  if caster.BloodletterAcquired then
    local duration = self:GetSpecialValueFor("bloodpower_duration")
  	if not caster.ImpaleSwapTimer then
  		caster:FindAbilityByName("vlad_transfusion"):StartCooldown(0.75)
      caster:SwapAbilities("vlad_transfusion", "vlad_impale", false, true)
      caster.ImpaleSwapTimer = Timers:CreateTimer(duration, function()
        caster.ImpaleSwapTimer = nil
        caster:SwapAbilities("vlad_transfusion", "vlad_impale", true, false)
  		end)
    else
      Timers:RemoveTimer(caster.ImpaleSwapTimer)
        caster.ImpaleSwapTimer = Timers:CreateTimer(duration, function()
        caster.ImpaleSwapTimer = nil
        caster:SwapAbilities("vlad_transfusion", "vlad_impale", true, false)
      end)
    end
  end
end

function vlad_transfusion:OnSpellStart()
  local caster = self:GetCaster()
	local aoe = self:GetSpecialValueFor("aoe")
	local interval = self:GetSpecialValueFor("interval")
	local dmg = self:GetSpecialValueFor("dmg")
	local heal = self:GetSpecialValueFor("heal")
	local slow_duration = self:GetSpecialValueFor("slow_duration")
	local dmg_bonus = self:GetSpecialValueFor("dmg_bonus")
	local duration = self:GetSpecialValueFor("duration")
	local Wlevel = caster:FindAbilityByName("vlad_ceremonial_purge"):GetLevel()
	local dmg = dmg + (dmg_bonus*Wlevel)
  local heal = heal +(dmg_bonus*Wlevel)

  if caster.BloodletterAcquired then
    local transfusionbonus = caster.MasterUnit2:FindAbilityByName("vlad_attribute_bloodletter"):GetSpecialValueFor("transfusionbonus")
    dmg = dmg + transfusionbonus
    heal = heal + transfusionbonus
  end

	caster:AddNewModifier(caster, self, "modifier_transfusion_self",{duration = duration})
	caster:EmitSound("Hero_OgreMagi.Bloodlust.Target.FP")
	caster:EmitSound("Hero_DeathProphet.SpiritSiphon.Cast")
  self:ImpaleSwap(caster)

	Timers:CreateTimer(function()
    if caster:IsAlive() then
  		local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
  		FxDestroyer(self.PI1,false)
  		self.PI1 = {}
  		for k,v in pairs(targets) do
  			if v:HasModifier("modifier_bleed") then
  				local modbleed = v:FindModifierByName("modifier_bleed")
  				local count = modbleed:GetStackCount()
  				if count > 0 then
            caster:ApplyHeal(heal, caster)
            DoDamage(caster, v, dmg, DAMAGE_TYPE_MAGICAL, 0, self, false)
  					modbleed:SetStackCount(count - 1)
  					count = modbleed:GetStackCount()
            self:AddBloodpowerStack(caster,1)
            self:VFX1_SuckOnAndLiveLongBitch(caster,k,v)
  				end
  				if count < 1 then
  					v:RemoveModifierByName("modifier_bleed")
          else
            v:AddNewModifier(caster, self, "modifier_transfusion_target",{duration = slow_duration})
  				end
  			end
  		end
  		if caster:HasModifier("modifier_transfusion_self") then
  			return interval
  		else
  			FxDestroyer(self.PI1,false)
  			return nil
      end
		end
  end)
end

function vlad_transfusion:GetAbilityTextureName()
  return "custom/vlad_transfusion"
end
function vlad_transfusion:GetCastAnimation()
  return ACT_DOTA_CAST_ABILITY_3
end
