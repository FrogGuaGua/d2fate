modifier_golden_apple_cooldown = class({})

function modifier_golden_apple_cooldown:GetAttributes() 
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_golden_apple_cooldown:IsHidden()
    return false
end

function modifier_golden_apple_cooldown:IsDebuff()
    return true
end

function modifier_golden_apple_cooldown:RemoveOnDeath()
    return false
end

function modifier_golden_apple_cooldown:GetTexture()
    return "custom/atalanta_golden_apple"
end