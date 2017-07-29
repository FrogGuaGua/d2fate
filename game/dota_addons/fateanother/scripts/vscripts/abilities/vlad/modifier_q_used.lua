modifier_q_used = class({})

function modifier_q_used:IsHidden()
  return true
end

function modifier_q_used:IsDebuff()
  return false
end

function modifier_q_used:RemoveOnDeath()
  return true
end
