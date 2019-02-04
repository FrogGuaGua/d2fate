modifier_celestial_arrow = class({})

function modifier_celestial_arrow:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
 
    return funcs
end

function modifier_celestial_arrow:GetModifierPreAttack_BonusDamage() 
    local ability = self:GetAbility()
    return ability:GetSpecialValueFor("bonus_damage")
end
 
function modifier_celestial_arrow:GetAttributes() 
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_celestial_arrow:IsHidden()
    return true
end

function modifier_celestial_arrow:IsDebuff()
    return false
end

function modifier_celestial_arrow:RemoveOnDeath()
    return false
end