vlad_impale = class({})

function vlad_impale:GetAOERadius()
  local radius_min = self:GetSpecialValueFor("radius_min")
  local radius_gain = self:GetSpecialValueFor("radius_gain")
  local radius_max = self:GetSpecialValueFor("radius_max")
  local bloodpower = CustomNetTables:GetTableValue("sync","vlad_bloodpower_count").count
  return math.max(radius_min, math.min(radius_min + bloodpower * radius_gain, radius_max))
end 

if IsClient() then
  return 
end

function vlad_impale:VFX1_SpikesIndicator(caster,radius,point)
  self.PI1 = ParticleManager:CreateParticle("particles/custom/vlad/vlad_ip_prespike.vpcf", PATTACH_CUSTOMORIGIN, caster)
  ParticleManager:SetParticleControl(self.PI1,0,point)
  ParticleManager:SetParticleControl(self.PI1,3,point)
  ParticleManager:SetParticleControl(self.PI1,4,Vector(radius, 0, 0))
end
function vlad_impale:VFX2_OnTargetImpale(k,target)
  self.PI2[k] = FxCreator("particles/custom/vlad/vlad_impale_bleed.vpcf", PATTACH_ABSORIGIN_FOLLOW, target, 0, nil)
  ParticleManager:SetParticleControlEnt(self.PI2[k], 1, target, PATTACH_ABSORIGIN_FOLLOW	, nil, target:GetAbsOrigin(), false)
  
  self.PI3[k] = FxCreator("particles/custom/vlad/vlad_kb_ontarget.vpcf", PATTACH_ABSORIGIN, target, 0, nil)
  ParticleManager:SetParticleControl(self.PI3[k],4, Vector(2.7, 0, 0))
end
--[[actually on a second thought this particle triggers me so much i would rather reuse R ontarget stuff
function vlad_impale:VFX3_Spikes(caster,radius,point)
  self.PI4 = ParticleManager:CreateParticle("particles/custom/vlad/vlad_ip_spikes.vpcf", PATTACH_CUSTOMORIGIN, caster)
  ParticleManager:SetParticleControl(self.PI4,0,point + Vector(0,0,100))
  ParticleManager:SetParticleControl(self.PI4,4,Vector(radius, 0, 0))
end--]]

function vlad_impale:OnUpgrade()
	local caster = self:GetCaster()
  local ability = self
	if not caster.ResetImpaleSwapTimer then
		function caster:ResetImpaleSwapTimer(...)
			ability:ResetImpaleSwapTimer(...)
		end
	end
end

function vlad_impale:ResetImpaleSwapTimer()
  local caster = self:GetCaster()
  if caster.ImpaleSwapTimer then
    Timers:RemoveTimer(caster.ImpaleSwapTimer)
    caster.ImpaleSwapTimer = nil
    caster:SwapAbilities("vlad_transfusion", "vlad_impale", true, false)
  end
end

function vlad_impale:GetCastRange(vLocation,hTarget)
  return self:GetSpecialValueFor("range")
end

function vlad_impale:OnSpellStart()
  local caster = self:GetCaster()
  local stun_min = self:GetSpecialValueFor("stun_min")
  local stun_gain = self:GetSpecialValueFor("stun_gain")
  local stun_max = self:GetSpecialValueFor("stun_max")
  local damage = self:GetSpecialValueFor("damage")
  local delay = self:GetSpecialValueFor("delay")
  local point = caster:GetCursorPosition()
    
  caster:RemoveModifierByName("modifier_transfusion_self")
  self:ResetImpaleSwapTimer()

  local modifier = caster:FindModifierByName("modifier_transfusion_bloodpower")
 	local bloodpower = modifier and modifier:GetStackCount() or 0
  caster:RemoveModifierByName("modifier_transfusion_bloodpower")

  local stun = math.max(stun_min, math.min(stun_min + bloodpower * stun_gain, stun_max))
  local radius = self:GetAOERadius()
  --print(stun, "   ", radius)
    
  self:VFX1_SpikesIndicator(caster,radius,point)

  Timers:CreateTimer(delay, function()
    self.PI2={}
    self.PI3={}
    --self:VFX3_Spikes(caster,radius,point)
    local targets = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
    for k,v in pairs(targets) do
      self:VFX2_OnTargetImpale(k,v)
      DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, self, false)
      caster:AddBleedStack(v, false)
      giveUnitDataDrivenModifier(caster, v, "stunned", stun)
    end
    if #targets ~= 0 then
      targets[1]:EmitSound("Hero_PhantomAssassin.CoupDeGrace")
      targets[1]:EmitSound("Hero_Leshrac.Split_Earth")
    end
  end)

  Timers:CreateTimer(3, function()
    FxDestroyer(self.PI1, false)
    FxDestroyer(self.PI2,false)
    FxDestroyer(self.PI3,false)
    --FxDestroyer(self.PI4,false)
  end)
end

function vlad_impale:GetCastAnimation()
  return ACT_DOTA_CAST_ABILITY_3
end

function vlad_impale:GetAbilityTextureName()
  return "custom/vlad_impale"
end
