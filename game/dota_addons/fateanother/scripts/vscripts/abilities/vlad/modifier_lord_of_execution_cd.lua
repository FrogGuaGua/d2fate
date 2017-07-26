modifier_lord_of_execution_cd = class({})

function modifier_lord_of_execution_cd:GetAttributes() 
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_lord_of_execution_cd:IsHidden()
  return false
end

function modifier_lord_of_execution_cd:IsDebuff()
  return true
end

function modifier_lord_of_execution_cd:RemoveOnDeath()
  return false
end