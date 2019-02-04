modifier_sting_shot = class({})

function modifier_sting_shot:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}
	return state
end
function modifier_sting_shot:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
	return funcs
end
function modifier_sting_shot:GetEffectName()
	return "particles/generic_gameplay/generic_sleep.vpcf"
end
function  modifier_sting_shot:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

if IsServer() then
	function modifier_sting_shot:OnTakeDamage(args)
		local hParent = self:GetParent()
		if args.unit == hParent then
			self:Destroy()
		end
	end
end

function modifier_sting_shot:IsHidden()
  return false
end

function modifier_sting_shot:IsDebuff()
  return true
end

function modifier_sting_shot:RemoveOnDeath()
  return true
end
