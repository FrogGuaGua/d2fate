atalanta_tauropolos_new = class({})

if IsClient() then
  return 
end

function atalanta_tauropolos_new:OnSpellStart()
  local hCaster = self:GetCaster()
  local vTarget = self:GetCursorPosition()
  local vOrigin = hCaster:GetAbsOrigin()
  local vFacing = ForwardVForPointGround(vOrigin,vTarget)
  hCaster:UseArrow(2)
  
  local tProjectile = {
      EffectName = "particles/custom/atalanta/sting/shot.vpcf",
      Ability = self,
      vSpawnOrigin = vOrigin,
      vVelocity = vFacing * 3000,
      fDistance = 2500,
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