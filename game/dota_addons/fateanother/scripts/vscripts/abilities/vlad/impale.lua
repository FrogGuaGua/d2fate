vlad_impale = class({})

if not IsServer() then
  return
end
function vlad_impale:VFX1_SpikesIndicator(target,radius)
  self.PI1 = FxCreator("particles/custom/vlad/vlad_ip_prespike.vpcf", PATTACH_ABSORIGIN, target,0,nil)
  ParticleManager:SetParticleControlEnt(self.PI1, 3, target, PATTACH_CUSTOMORIGIN_FOLLOW	, nil, target:GetAbsOrigin(),false)
  ParticleManager:SetParticleControl(self.PI1,4,Vector(radius, 0, 0))
end
function vlad_impale:VFX2_OnTargetBleed(k,target)
  self.PI2[k] = FxCreator("particles/custom/vlad/vlad_impale_bleed.vpcf", PATTACH_ABSORIGIN_FOLLOW, target, 0, nil)
  ParticleManager:SetParticleControlEnt(self.PI2[k], 1, target, PATTACH_ABSORIGIN_FOLLOW	, nil, target:GetAbsOrigin(), false)
end
function vlad_impale:VFX3_Spikes(target,radius)
  self.PI3 = FxCreator("particles/custom/vlad/vlad_ip_spikes.vpcf", PATTACH_ABSORIGIN, target, 0, nil)
  ParticleManager:SetParticleControl(self.PI3,4,Vector(radius, 0, 0))
  --ParticleManager:SetParticleControlEnt(self.PI2, 1, target, PATTACH_ABSORIGIN	, nil, target:GetAbsOrigin(), false)
end

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

function vlad_impale:OnSpellStart()
  local caster = self:GetCaster()
  caster:RemoveModifierByName("modifier_transfusion_self")
  self:ResetImpaleSwapTimer()

  local modifier = caster:FindModifierByName("modifier_transfusion_bloodpower")
 	local bloodpower = modifier and modifier:GetStackCount() or 0
  caster:RemoveModifierByName("modifier_transfusion_bloodpower")

  local stun = math.max(1, math.min(1 + bloodpower * 0.1, 2))
  local damage = 200
  local radius = math.max(150, math.min(150 + bloodpower * 5, 250))
  print(stun, "   ", radius)
  local point = caster:GetCursorPosition()

  local dummy = CreateUnitByName("visible_dummy_unit", caster:GetOrigin(), false, caster, caster, caster:GetTeamNumber())
  dummy:FindAbilityByName("dummy_visible_unit_passive"):SetLevel(1)
  dummy:SetDayTimeVisionRange(0)
  dummy:SetNightTimeVisionRange(0)
  dummy:SetAbsOrigin(point)
  self:VFX1_SpikesIndicator(dummy,radius)

  Timers:CreateTimer(0.5, function()
    dummy:EmitSound("Hero_Leshrac.Split_Earth")
    self.PI2={}
    self:VFX3_Spikes(dummy,radius)
    local targets = FindUnitsInRadius(caster:GetTeamNumber(), dummy:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
    for k,v in pairs(targets) do
      self:VFX2_OnTargetBleed(k,v)
      DoDamage(caster, v, 1, DAMAGE_TYPE_MAGICAL, 0, self, false)
      caster:AddBleedStack(v, 5,false)
      giveUnitDataDrivenModifier(caster, v, "stunned", stun)
      --ApplyAirborne(caster, v, stun)
    end
    if #targets ~= 0 then
      dummy:EmitSound("Hero_PhantomAssassin.CoupDeGrace")
    end
  end)

  Timers:CreateTimer(3, function()
    FxDestroyer(self.PI1, false)
    FxDestroyer(self.PI2,false)
    dummy:RemoveSelf()
  end)
end


function vlad_impale:GetCastAnimation()
  return nil
end

function vlad_impale:GetTexture()
  return "shadow_demon_disruption"
end
