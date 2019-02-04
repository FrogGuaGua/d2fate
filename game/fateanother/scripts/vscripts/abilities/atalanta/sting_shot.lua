atalanta_sting_shot = class({})
LinkLuaModifier("modifier_sting_shot", "abilities/atalanta/modifier_sting_shot", LUA_MODIFIER_MOTION_NONE)

function atalanta_sting_shot:GetCastRange(vLocation,hTarget)
  return self:GetSpecialValueFor("range")
end
function atalanta_sting_shot:GetCastPoint()
  return self:GetSpecialValueFor("cast_point")
end

if IsClient() then
  return 
end

function atalanta_sting_shot:CreateShockRing(vFacing)
  local caster = self:GetCaster()
  local dummy = CreateUnitByName("visible_dummy_unit", caster:GetOrigin(), false, caster, caster, caster:GetTeamNumber())
  dummy:FindAbilityByName("dummy_visible_unit_passive"):SetLevel(1)
  dummy:SetDayTimeVisionRange(0)
  dummy:SetNightTimeVisionRange(0)
  dummy:SetOrigin(caster:GetOrigin())

  dummy:SetForwardVector(vFacing or caster:GetForwardVector())

  local casterFX = ParticleManager:CreateParticle("particles/custom/atalanta/sting/ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, dummy)
  ParticleManager:SetParticleControlEnt(casterFX, 1, dummy, PATTACH_ABSORIGIN_FOLLOW, nil, caster:GetOrigin(), false)
  ParticleManager:ReleaseParticleIndex(casterFX)

  Timers:CreateTimer(3, function()
    dummy:RemoveSelf()
  end)
end
function atalanta_sting_shot:CastFilterResultLocation(location)
  local caster = self:GetCaster()

  if caster:HasArrow() then
    return UF_SUCCESS
  end

  return UF_FAIL_CUSTOM
end

function atalanta_sting_shot:GetCustomCastErrorLocation(location)
  return "Not enough arrows..."
end
function atalanta_sting_shot:OnSpellStart()
  local hCaster = self:GetCaster()
  local vTarget = self:GetCursorPosition()
  local vOrigin = hCaster:GetAbsOrigin()
  local vFacing = ForwardVForPointGround(hCaster,vTarget)
  local fSleepDuration = self:GetSpecialValueFor("sleep_duration")
  self:CreateShockRing(vFacing)
  hCaster:UseArrow(1)
  hCaster:EmitSound("Ability.Powershot.Alt")
  hCaster:CloseTraps(self)
  self.bArrowHit = false

  local tProjectile = {
    EffectName = "particles/custom/atalanta/sting/shot.vpcf",
    Ability = self,
    vSpawnOrigin = vOrigin,
    vVelocity = vFacing * 3000,
    fDistance = self:GetCastRange(),
    fStartRadius = 100,
    fEndRadius = 100,
    Source = hCaster,
    bHasFrontalCone = false,
    bReplaceExisting = false,
    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    bProvidesVision = false,
    ExtraData = {fSleepDuration = fSleepDuration}
  }
  self.iProjectile = ProjectileManager:CreateLinearProjectile(tProjectile)
end

function atalanta_sting_shot:OnProjectileHit_ExtraData(hTarget, vLocation, tData)
  if hTarget == nil then
    return
  end
  local hCaster = self:GetCaster()
  if hTarget:IsRealHero() and not self.bArrowHit then
    hTarget:AddNewModifier(hCaster,self,"modifier_sting_shot",{Duration = tData.fSleepDuration})
    Timers:CreateTimer(0.033,function()
      ProjectileManager:DestroyLinearProjectile(self.iProjectile)
    end)  
  end
end