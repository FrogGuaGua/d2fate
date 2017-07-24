vlad_battle_continuation = class({})
LinkLuaModifier("modifier_battle_continuation", "abilities/vlad/modifier_battle_continuation", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_battle_continuation_heal", "abilities/vlad/modifier_battle_continuation_heal", LUA_MODIFIER_MOTION_NONE)

if not IsServer() then
  return
end

function vlad_battle_continuation:VFX1_Cast(caster)
	local PI1 = FxCreator("particles/custom/vlad/vlad_bc_cast.vpcf", PATTACH_CENTER_FOLLOW, caster,0, nil)
  ParticleManager:SetParticleControlEnt(PI1, 2, caster, PATTACH_CENTER_FOLLOW, nil, caster:GetAbsOrigin(), false)
  ParticleManager:SetParticleControlEnt(PI1, 3, caster, PATTACH_ABSORIGIN_FOLLOW, nil, caster:GetAbsOrigin(), false)
	Timers:CreateTimer(2, function()
    FxDestroyer(PI1, false)
  end)
end

function vlad_battle_continuation:CastFilterResult()
  local caster = self:GetCaster()
  local hp_condition = self:GetSpecialValueFor("hp_condition")
  if caster.ProtectionOfFaithAcquired then
    hp_condition = caster.MasterUnit2:FindAbilityByName("vlad_attribute_protection_of_faith"):GetSpecialValueFor("bc_hp_condition")
  end
  if caster:GetHealthPercent() >= hp_condition then
    return UF_FAIL_CUSTOM
  end
  return UF_SUCCESS
end

function vlad_battle_continuation:GetCustomCastError()
  return "Condition not met."
end

function vlad_battle_continuation:OnSpellStart()
  local caster = self:GetCaster()
  local duration = self:GetSpecialValueFor("duration")

  if caster.ProtectionOfFaithAcquired then
    local bc_heal_duration = caster.MasterUnit2:FindAbilityByName("vlad_attribute_protection_of_faith"):GetSpecialValueFor("bc_heal_duration")
    caster:AddNewModifier(caster,self,"modifier_battle_continuation_heal",{duration = bc_heal_duration+0.1})
  end

  self:VFX1_Cast(caster)
  caster:AddNewModifier(caster, self, "modifier_battle_continuation",{duration = duration})
  caster:EmitSound("Hero_LifeStealer.Rage")
end

function vlad_battle_continuation:GetAbilityTextureName()
  return "custom/vlad_battle_continuation"
end
