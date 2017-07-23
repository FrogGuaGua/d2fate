modifier_e_used = class({})

function modifier_e_used:IsHidden()
  return true
end

function modifier_e_used:IsDebuff()
  return false
end

function modifier_e_used:RemoveOnDeath()
  return true
end
