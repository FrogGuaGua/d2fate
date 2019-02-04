modifier_qgg_oracle_aura = class({})

function modifier_qgg_oracle_aura:IsAura()
	return true
end

function modifier_qgg_oracle_aura:IsHidden()
	return true
end

function modifier_qgg_oracle_aura:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_qgg_oracle_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_qgg_oracle_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_qgg_oracle_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL
end

function modifier_qgg_oracle_aura:GetAuraEntityReject(hEntity)
    if hEntity:GetUnitName() == "ward_familiar" or hEntity == self:GetParent() then return true end
    return false
end

function modifier_qgg_oracle_aura:GetModifierAura()
	return "modifier_qgg_oracle"
end