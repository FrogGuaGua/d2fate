modifier_phoebus_catastrophe_cooldown = class({})

function modifier_phoebus_catastrophe_cooldown:GetAttributes() 
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_phoebus_catastrophe_cooldown:IsHidden()
    return false
end

function modifier_phoebus_catastrophe_cooldown:IsDebuff()
    return true
end

function modifier_phoebus_catastrophe_cooldown:RemoveOnDeath()
    return false
end

function modifier_phoebus_catastrophe_cooldown:GetTexture()
    return "custom/atalanta_phoebus_catastrophe"
end