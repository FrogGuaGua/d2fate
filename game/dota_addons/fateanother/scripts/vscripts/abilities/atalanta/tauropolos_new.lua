atalanta_tauropolos_new = class({})
LinkLuaModifier("modifier_bow_proc", "abilities/atalanta/modifier_bow_proc", LUA_MODIFIER_MOTION_NONE)

function atalanta_tauropolos_new:GetCastRange(vLocation,hTarget)
  local fRange = self:GetSpecialValueFor("range")
  local hCaster = self:GetCaster()
  if hCaster:HasModifier("modifier_bow_of_heaven") then
    fRange = fRange + CustomNetTables:GetTableValue("sync","atalanta_bow_of_heaven").fExtraRange
  end
  return fRange
end

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

function atalanta_tauropolos_new:OnUpgrade()
  local hCaster = self:GetCaster()
  local hAbility = self
  if not hCaster.EndBowOfHeaven then
    function hCaster:EndBowOfHeaven(...)
      hAbility:EndBowOfHeaven(...)      
    end
  end
end
function atalanta_tauropolos_new:OnAbilityPhaseStart()
  local hCaster = self:GetCaster()
  StartAnimation(hCaster, {duration=1.5, activity=ACT_DOTA_CAST_ABILITY_1, rate=0.7})
  hCaster:EmitSound("Atalanta.RPull")
  self.iPICharging =  ParticleManager:CreateParticle("particles/custom/atalanta/r/r_charging.vpcf", PATTACH_ABSORIGIN_FOLLOW, hCaster)
  ParticleManager:SetParticleControlEnt(self.iPICharging, 3, hCaster, PATTACH_ABSORIGIN_FOLLOW, nil, hCaster:GetAbsOrigin(), false)
  return true
end
function atalanta_tauropolos_new:OnAbilityPhaseInterrupted()
  local hCaster = self:GetCaster()
  hCaster:StopSound("Atalanta.RPull")
  EndAnimation(hCaster)
  FxDestroyer(self.iPICharging,false)
end
function atalanta_tauropolos_new:CreateShockRing(vFacing)
  local caster = self:GetCaster()
  local dummy = CreateUnitByName("visible_dummy_unit", caster:GetOrigin(), false, caster, caster, caster:GetTeamNumber())
  dummy:FindAbilityByName("dummy_visible_unit_passive"):SetLevel(1)
  dummy:SetDayTimeVisionRange(0)
  dummy:SetNightTimeVisionRange(0)
  dummy:SetOrigin(caster:GetOrigin())

  dummy:SetForwardVector(vFacing or caster:GetForwardVector())

  local casterFX = ParticleManager:CreateParticle("particles/custom/atalanta/r/ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, dummy)
  ParticleManager:SetParticleControlEnt(casterFX, 1, dummy, PATTACH_ABSORIGIN_FOLLOW, nil, caster:GetOrigin(), false)
  ParticleManager:ReleaseParticleIndex(casterFX)

  Timers:CreateTimer(3, function()
    dummy:RemoveSelf()
  end)
end
function atalanta_tauropolos_new:OnSpellStart()
  local hCaster = self:GetCaster()
  local vTarget = self:GetCursorPosition()
  local vOrigin = hCaster:GetAbsOrigin()
  local vFacing = ForwardVForPointGround(vOrigin,vTarget)
  local fDamage = 100
  local fRange = self:GetCastRange()
  self.bArrowHit = false
  --hCaster:UseArrow(2)
  self:CreateShockRing(vFacing)
  FxDestroyer(self.iPICharging,false)

  EmitGlobalSound("Atalanta.RLaunch")
  if hCaster.BowOfHeavenAcquired then
    local fAgiScaling = CustomNetTables:GetTableValue("sync","atalanta_bow_of_heaven").fAgiScaling
    fDamage = fDamage + hCaster:GetAgility()*fAgiScaling
  end   
  
  local tProjectile = {
    EffectName = "particles/custom/atalanta/r/r_projectile.vpcf",
    Ability = self,
    vSpawnOrigin = vOrigin,
    vVelocity = vFacing * 2500,
    fDistance = fRange,
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
  local iMaxStacks = hCaster:FindAbilityByName("atalanta_calydonian_hunt"):GetSpecialValueFor("max_stacks")
  local sParticle = "particles/custom/atalanta/r/r_impact.vpcf"
  local tTargets = FindUnitsInRadius(hCaster:GetTeam(), hTarget:GetAbsOrigin(), nil, fRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)  
  if hTarget:HasModifier("modifier_calydonian_hunt") then
    fRadius = fRadius * 1.5
    fDamageSplashPercentage = fDamageSplashPercentage * 1.5
    sParticle = "particles/custom/atalanta/r/r_calydonian_impact.vpcf"
    for k,v in pairs(tTargets) do
      hCaster:AddHuntStack(v, iMaxStacks)
    end
  end
  AddFOWViewer(hCaster:GetTeamNumber(), hTarget:GetAbsOrigin(), fRadius, fVisionDuration, false)
  local PI = ParticleManager:CreateParticle(sParticle, PATTACH_ABSORIGIN, hTarget)
  for k,v in pairs(tTargets) do
    if v ~= hTarget then
      DoDamage(hCaster, v, tData.fDamage*fDamageSplashPercentage, DAMAGE_TYPE_MAGICAL, 0, self, false)
    end
  end
  if hCaster.BowOfHeavenAcquired and hCaster:FindAbilityByName("atalanta_phoebus_catastrophe_barrage"):IsCooldownReady() then
    hCaster.vRImpactLoc = hTarget:GetAbsOrigin()
    hCaster:AddNewModifier(hCaster, self, "modifier_bow_proc", {Duration = 5})

    local fMaxDistFromR = CustomNetTables:GetTableValue("sync","atalanta_bow_of_heaven").fMaxDist
    hCaster.iPIBowMarker = ParticleManager:CreateParticleForPlayer("particles/custom/atalanta/atalanta_tauropolos_marker.vpcf", PATTACH_WORLDORIGIN, hCaster, hCaster:GetPlayerOwner())
    ParticleManager:SetParticleControl( hCaster.iPIBowMarker, 0, hTarget:GetAbsOrigin())
    ParticleManager:SetParticleControl( hCaster.iPIBowMarker, 1, Vector(fMaxDistFromR,0,0))

    hCaster:SwapAbilities(hCaster:GetAbilityByIndex(5):GetName(),"atalanta_phoebus_catastrophe_barrage",false,true)
    hCaster.bIsBowOfHeavenActive = true
    hCaster.BowOfHeavenTimer = Timers:CreateTimer(5,function()
      self:EndBowOfHeaven()
      return nil
    end)
  end
end
function atalanta_tauropolos_new:EndBowOfHeaven()
  local hCaster = self:GetCaster()
  FxDestroyer(hCaster.iPIBowMarker,false)
  hCaster:SwapAbilities("atalanta_tauropolos_new","atalanta_phoebus_catastrophe_barrage",true,false)
  hCaster.bIsBowOfHeavenActive = false
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