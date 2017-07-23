modifier_rending = class({})

function modifier_rending:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_rending:DeclareFunctions()
  local funcs = {
	MODIFIER_EVENT_ON_ATTACK_LANDED,
  }
  return funcs
end

function modifier_rending:OnAttackLanded(keys)
  local caster = self:GetCaster()
	local ability = self:GetAbility()
	local target = keys.target
  if target == caster:GetAttackTarget() and not caster.InnocentMonsterAcquired then
     ability:AddStack(target,1,true)
  end
end

function modifier_rending:IsHidden()
  return true
end

function modifier_rending:IsDebuff()
  return false
end

function modifier_rending:RemoveOnDeath()
  return false
end
