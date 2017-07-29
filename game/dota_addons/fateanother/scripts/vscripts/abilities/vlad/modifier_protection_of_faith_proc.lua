modifier_protection_of_faith_proc = class({})

function modifier_protection_of_faith_proc:CheckState()
	local state = {
    [MODIFIER_STATE_MAGIC_IMMUNE] = true,
	}
	return state
end

function modifier_protection_of_faith_proc:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_protection_of_faith_proc:IsHidden()
  return false
end

function modifier_protection_of_faith_proc:IsDebuff()
  return false
end

function modifier_protection_of_faith_proc:RemoveOnDeath()
  return true
end
