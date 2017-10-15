modifier_casting_phoebus = class({})

function modifier_casting_phoebus:GetAttributes() 
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_casting_phoebus:IsHidden()
    return true
end

function modifier_casting_phoebus:IsDebuff()
    return false
end

function modifier_casting_phoebus:RemoveOnDeath()
    return false
end