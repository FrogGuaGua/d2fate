modifier_traps_gcd = class({})

function modifier_traps_gcd:GetAttributes() 
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_traps_gcd:IsHidden()
    return false
end

function modifier_traps_gcd:IsDebuff()
    return false
end

function modifier_traps_gcd:RemoveOnDeath()
    return false
end

function modifier_traps_gcd:GetTexture()
    return "custom/atalanta_traps"
end