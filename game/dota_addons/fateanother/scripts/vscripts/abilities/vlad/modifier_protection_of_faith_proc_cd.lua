modifier_protection_of_faith_proc_cd = class({})

function modifier_protection_of_faith_proc_cd:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_protection_of_faith_proc_cd:IsHidden()
  return false
end

function modifier_protection_of_faith_proc_cd:IsDebuff()
  return true
end

function modifier_protection_of_faith_proc_cd:RemoveOnDeath()
  return false
end
