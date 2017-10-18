modifier_atalanta_trap = class({})

function modifier_atalanta_trap:CheckState()
	local state = {
		[MODIFIER_STATE_INVISIBLE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
	}
	return state
end

function modifier_atalanta_trap:IsHidden()
  return true
end

function modifier_atalanta_trap:IsDebuff()
  return false
end

function modifier_atalanta_trap:RemoveOnDeath()
  return true
end
