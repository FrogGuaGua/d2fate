modifier_doublespear_dearg = class({})

function modifier_doublespear_dearg:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_doublespear_dearg:IsHidden()
	return false
end

function modifier_doublespear_dearg:IsDebuff()
	return false
end

function modifier_doublespear_dearg:RemoveOnDeath()
    return true
end

function modifier_doublespear_dearg:GetTexture()
	return "custom/diarmuid_gae_dearg"
end