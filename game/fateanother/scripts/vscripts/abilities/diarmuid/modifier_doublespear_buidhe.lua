modifier_doublespear_buidhe = class({})

function modifier_doublespear_buidhe:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_doublespear_buidhe:IsHidden()
	return false
end

function modifier_doublespear_buidhe:IsDebuff()
	return false
end

function modifier_doublespear_buidhe:RemoveOnDeath()
    return true
end

function modifier_doublespear_buidhe:GetTexture()
	return "custom/diarmuid_gae_buidhe"
end