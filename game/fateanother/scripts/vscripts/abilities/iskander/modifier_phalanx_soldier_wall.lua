modifier_phalanx_soldier_wall = class({})

function modifier_phalanx_soldier_wall:IsDebuff()
	return true
end

function modifier_phalanx_soldier_wall:CheckState()
	local state = {
	[MODIFIER_STATE_INVULNERABLE] = true,
	[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
	[MODIFIER_STATE_NO_HEALTH_BAR] = true,
	[MODIFIER_STATE_UNSELECTABLE] = true,
	[MODIFIER_STATE_STUNNED] = true,
	}
 
	return state
end

--[[function modifier_phalanx_soldier_wall:CheckState()
	local state = {
	[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
	}
 
	return state
end

function modifier_phalanx_soldier_wall:CheckState()
	local state = {
	[MODIFIER_STATE_NO_HEALTH_BAR] = true,
	}
 
	return state
end

function modifier_phalanx_soldier_wall:CheckState()
	local state = {
	[MODIFIER_STATE_STUNNED] = true,
	}
 
	return state
end]]