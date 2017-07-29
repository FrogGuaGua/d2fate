modifier_improved_impaling = class({})

function modifier_improved_impaling:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_improved_impaling:IsHidden()
  return true
end

function modifier_improved_impaling:IsDebuff()
  return false
end

function modifier_improved_impaling:RemoveOnDeath()
  return false
end
