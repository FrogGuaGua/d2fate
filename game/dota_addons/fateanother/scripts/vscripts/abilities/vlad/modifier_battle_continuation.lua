modifier_battle_continuation = class({})

if IsServer() then
	function modifier_battle_continuation:OnCreated()
		local parent = self:GetParent()
		self.PI1 = FxCreator("particles/custom/vlad/vlad_bc_buff.vpcf",PATTACH_ABSORIGIN_FOLLOW,parent,0,nil)
		ParticleManager:SetParticleControlEnt(self.PI1, 2, parent, PATTACH_ABSORIGIN_FOLLOW, nil, parent:GetAbsOrigin(), false)--]]
	end

	function modifier_battle_continuation:OnDestroy()
		FxDestroyer(self.PI1, false)
	end
end

function modifier_battle_continuation:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_battle_continuation:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
	}
	return state
end

function modifier_battle_continuation:IsHidden()
  return false
end

function modifier_battle_continuation:IsDebuff()
  return false
end

function modifier_battle_continuation:RemoveOnDeath()
  return true
end
