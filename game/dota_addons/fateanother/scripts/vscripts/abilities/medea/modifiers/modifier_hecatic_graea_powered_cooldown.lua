modifier_hecatic_graea_powered_cooldown = class({})

function modifier_hecatic_graea_powered_cooldown:IsHidden()
	return false 
end

function modifier_hecatic_graea_powered_cooldown:RemoveOnDeath()
	return false
end

function modifier_hecatic_graea_powered_cooldown:IsDebuff()
	return true 
end

function modifier_hecatic_graea_powered_cooldown:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end