lancer_5th_soaring_spear = class({})
require("lancer_ability")

function lancer_5th_soaring_spear:GetCastRange(vLocation,hTarget)
  return self:GetSpecialValueFor("range")
end
function lancer_5th_soaring_spear:GetAOERadius()
  return self:GetSpecialValueFor("radius")
end
function lancer_5th_soaring_spear:GetCastPoint()
  return self:GetSpecialValueFor("cast_delay")
end

if IsClient() then
  return 
end

function lancer_5th_soaring_spear:OnAbilityPhaseStart()
  GBAttachEffect({caster = self:GetCaster(), ability = self})
  return true
end
function lancer_5th_soaring_spear:OnUpgrade()
  self.IsResetable = false
end

function lancer_5th_soaring_spear:OnSpellStart()
  local hCaster = self:GetCaster()
  local hTarget = self:GetCursorTarget()
  local tProjectile = {
      Target = hTarget,
      Source = hCaster,
      Ability = self,
      EffectName = "particles/custom/lancer/soaring/spear.vpcf",
      iMoveSpeed = 1900,
      vSourceLoc = (hCaster:GetAbsOrigin()+Vector(0,0,300)),
      bDodgeable = false,
      bIsAttack = false,
      flExpireTime = GameRules:GetGameTime() + 10,
  }
  EmitGlobalSound("Lancer.GaeBolg")
  giveUnitDataDrivenModifier(hCaster, hCaster, "jump_pause", 0.8)
  Timers:CreateTimer(0.8, function()
    giveUnitDataDrivenModifier(hCaster, hCaster, "jump_pause_postdelay", 0.15)
  end)
  Timers:CreateTimer(0.95, function()
    giveUnitDataDrivenModifier(hCaster, hCaster, "jump_pause_postlock", 0.2)
  end)
  StartAnimation(hCaster, {duration=1, activity=ACT_DOTA_CAST_ABILITY_4, rate=1})
  Timers:CreateTimer(0.45, function()
    ProjectileManager:CreateTrackingProjectile(tProjectile)  
  end)  
  local ascendCount = 0
  local descendCount = 0
  Timers:CreateTimer(0,function()
    if ascendCount == 15 then return end
    hCaster:SetAbsOrigin(Vector(hCaster:GetAbsOrigin().x,hCaster:GetAbsOrigin().y,hCaster:GetAbsOrigin().z+50))
    ascendCount = ascendCount + 1;
    return 0.033
  end)

  Timers:CreateTimer(0.3, function()
    if descendCount == 15 then return end
    hCaster:SetAbsOrigin(Vector(hCaster:GetAbsOrigin().x,hCaster:GetAbsOrigin().y,hCaster:GetAbsOrigin().z-50))
    descendCount = descendCount + 1;
    return 0.033
  end)
end
function lancer_5th_soaring_spear:GetTotalDamage()
  local hCaster = self:GetCaster()
  local iRLvl = hCaster:FindAbilityByName("lancer_5th_gae_bolg_jump"):GetLevel()
  local iELvl = hCaster:FindAbilityByName("lancer_5th_gae_bolg"):GetLevel()
  local fBonusFromR = self:GetSpecialValueFor("damage_bonus_from_r") * iRLvl
  local fBonusFromE = self:GetSpecialValueFor("damage_bonus_from_e") * iELvl
  local fDamage = self:GetSpecialValueFor("damage_base") + fBonusFromE + fBonusFromR
  
  local hRuneAbility = hCaster:FindAbilityByName("lancer_5th_rune_of_flame")
  local fRuneHPDamagePct = hRuneAbility:GetLevelSpecialValueFor("ability_bonus_damage", hRuneAbility:GetLevel()-1)/100
  if hCaster.IsGaeBolgImproved then
    fRuneHPDamagePct = fRuneHPDamagePct * 2
  end
  return fDamage,fRuneHPDamagePct
end

function lancer_5th_soaring_spear:OnProjectileHit_ExtraData(hTarget, vLocation, tData)
  if hTarget == nil then
    return
  end
  local hCaster = self:GetCaster()
  local fDamage,fRuneHPDamagePct = self:GetTotalDamage()
  local fRadius = self:GetSpecialValueFor("radius")
  local fStun = self:GetSpecialValueFor("stun_duration")

  PlayNormalGBEffect(hTarget)
  hTarget:EmitSound("Hero_Lion.Impale")

  local tTargets = FindUnitsInRadius(hCaster:GetTeam(), hTarget:GetAbsOrigin(), nil, fRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
  for k,v in pairs(tTargets) do
     DoDamage(hCaster, v, fDamage + v:GetHealth()*fRuneHPDamagePct, DAMAGE_TYPE_MAGICAL, 0, self, false)
     v:AddNewModifier(hCaster, v, "modifier_stunned", {Duration = fStun})
  end
end