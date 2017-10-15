modifier_cobweb_slow = class({})

function modifier_cobweb_slow:OnCreated(args)
	self.fSlow = args.fSlow
end

function modifier_cobweb_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function modifier_cobweb_slow:GetModifierMoveSpeedBonus_Percentage()
	if IsClient() then
		return CustomNetTables:GetTableValue("sync","atalanta_web").fSlow
	else
  	return self.fSlow
	end
end

function modifier_cobweb_slow:IsHidden()
  return false
end

function modifier_cobweb_slow:IsDebuff()
  return true
end

function modifier_cobweb_slow:RemoveOnDeath()
  return true
end
