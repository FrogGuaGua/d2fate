modifier_barrage_slow = class({})

function modifier_barrage_slow:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
 
    return funcs
end

function modifier_barrage_slow:GetModifierMoveSpeedBonus_Percentage()
    return -50
end

function modifier_barrage_slow:IsDebuff()
    return true
end

function modifier_barrage_slow:RemoveOnDeath()
    return true
end

function modifier_barrage_slow:GetTexture()
    return "custom/atalanta_phoebus_catastrophe"
end