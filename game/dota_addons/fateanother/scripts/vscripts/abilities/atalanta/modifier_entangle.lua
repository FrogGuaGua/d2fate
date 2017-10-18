modifier_entangle = class({})

function modifier_entangle:GetAttributes() 
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_entangle:IsHidden()
    return false
end

function modifier_entangle:IsDebuff()
    return true
end

function modifier_entangle:RemoveOnDeath()
    return true
end