modifier_tauropolos_slow = class({})

function modifier_tauropolos_slow:OnCreated(args)
	self.fSlow = args.fSlow
end

function modifier_tauropolos_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function modifier_tauropolos_slow:GetModifierMoveSpeedBonus_Percentage()
	if IsClient() then
		return CustomNetTables:GetTableValue("sync","atalanta_tauropolos").fSlow
	else
  	return self.fSlow
	end
end

function modifier_tauropolos_slow:IsHidden()
  return false
end

function modifier_tauropolos_slow:IsDebuff()
  return true
end

function modifier_tauropolos_slow:RemoveOnDeath()
  return true
end
