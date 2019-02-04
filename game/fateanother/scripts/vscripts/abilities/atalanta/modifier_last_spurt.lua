modifier_last_spurt = class({})

function modifier_last_spurt:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
 
    return funcs
end

function modifier_last_spurt:GetModifierMoveSpeedBonus_Percentage() 
    local ability = self:GetAbility()
    local stacks = self:GetStackCount()
    local base = ability:GetSpecialValueFor("base_ms")

    return base + stacks * ability:GetSpecialValueFor("ms_per_unit")
end
 
function modifier_last_spurt:GetAttributes() 
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_last_spurt:IsHidden()
    return false
end

function modifier_last_spurt:IsDebuff()
    return false
end

function modifier_last_spurt:RemoveOnDeath()
    return true
end

function modifier_last_spurt:GetEffectName()
    return "particles/units/heroes/hero_windrunner/windrunner_windrun.vpcf"
end
function modifier_last_spurt:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_last_spurt:GetTexture()
    return "custom/atalanta_last_spurt"
end