modifier_bow_of_heaven = class({})

function modifier_bow_of_heaven:GetAttributes() 
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_bow_of_heaven:IsHidden()
    return true
end

function modifier_bow_of_heaven:IsDebuff()
    return false
end

function modifier_bow_of_heaven:RemoveOnDeath()
    return false
end