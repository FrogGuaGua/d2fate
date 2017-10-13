atalanta_tauropolos_new = class({})

if IsClient() then
  return 
end
function atalanta_tauropolos_new:CastFilterResultLocation(location)
  local hCaster = self:GetCaster()

  if hCaster:GetArrowCount() >= 2 then
    return UF_SUCCESS
  end

  return UF_FAIL_CUSTOM
end
function atalanta_tauropolos_new:GetCustomCastErrorLocation(location)
  return "Not enough arrows..."
end

function atalanta_tauropolos_new:OnAbilityPhaseStart()
  local hCaster = self:GetCaster()
  StartAnimation(hCaster, {duration=1.5, activity=ACT_DOTA_CAST_ABILITY_1, rate=0.7})
  hCaster:EmitSound("Atalanta.RPull")
  return true
end
function atalanta_tauropolos_new:OnAbilityPhaseInterrupted()
  local hCaster = self:GetCaster()
  hCaster:StopSound("Atalanta.RPull")
  EndAnimation(hCaster)
end

function atalanta_tauropolos_new:OnSpellStart()
  local hCaster = self:GetCaster()
  local vTarget = self:GetCursorPosition()
  local vOrigin = hCaster:GetAbsOrigin()
  local vFacing = ForwardVForPointGround(vOrigin,vTarget)
  local fDamage = 100
  self.bArrowHit = false
  --hCaster:UseArrow(2)
  EmitGlobalSound("Atalanta.RLaunch")
  local tProjectile = {
    EffectName = "particles/custom/atalanta/r/r_projectile.vpcf",
    Ability = self,
    vSpawnOrigin = vOrigin,
    vVelocity = vFacing * 3000,
    fDistance = 3000,
    fStartRadius = 125,
    fEndRadius = 125,
    Source = hCaster,
    bHasFrontalCone = false,
    bReplaceExisting = false,
    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    bProvidesVision = false,
    --iVisionRadius = 500,
    --bFlyingVision = true,
    --iVisionTeamNumber = hCaster:GetTeamNumber(),
    ExtraData = {fDamage = fDamage}
  }
  self.iProjectile = ProjectileManager:CreateLinearProjectile(tProjectile)  
end
function atalanta_tauropolos_new:Explosion(hTarget,tData)
  local hCaster = self:GetCaster()
  local fRadius = 500
  local fVisionDuration = 2
  local fDamageSplashPercentage = 50/100
  local iStacks = hCaster:FindAbilityByName("atalanta_calydonian_hunt"):GetSpecialValueFor("max_stacks")/2
  local sParticle = "particles/custom/atalanta/r/r_impact.vpcf"
  if hTarget:HasModifier("modifier_calydonian_hunt") then
    fRadius = fRadius * 1.5
    fDamageSplashPercentage = fDamageSplashPercentage * 1.5
    sParticle = "particles/custom/atalanta/r/r_calydonian_impact.vpcf"
    iStacks = iStacks * 2
  end
  local tTargets = FindUnitsInRadius(hCaster:GetTeam(), hTarget:GetAbsOrigin(), nil, fRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)  
  local hVisionDummy = SpawnVisionDummy(hCaster, hTarget:GetAbsOrigin(), fRadius, fVisionDuration, false)
  local PI = ParticleManager:CreateParticle(sParticle, PATTACH_ABSORIGIN, hTarget)
  for k,v in pairs(tTargets) do
    hCaster:AddHuntStack(v, iStacks)
    if v ~= hTarget then
      DoDamage(hCaster, hTarget, tData.fDamage*fDamageSplashPercentage, DAMAGE_TYPE_MAGICAL, 0, self, false)
    end
  end
end
function atalanta_tauropolos_new:OnProjectileHit_ExtraData(hTarget, vLocation, tData)
  if hTarget == nil then
    return
  end
  local hCaster = self:GetCaster()
  if hTarget:IsRealHero() and not self.bArrowHit then
    self.bArrowHit = true
    self:Explosion(hTarget, tData)
    DoDamage(hCaster, hTarget, tData.fDamage, DAMAGE_TYPE_MAGICAL, 0, self, false)
    hTarget:EmitSound("Atalanta.RImpact")
    hTarget:EmitSound("Atalanta.RImpact2")
    Timers:CreateTimer(0.033,function()
      ProjectileManager:DestroyLinearProjectile(self.iProjectile)
    end)
  end
end