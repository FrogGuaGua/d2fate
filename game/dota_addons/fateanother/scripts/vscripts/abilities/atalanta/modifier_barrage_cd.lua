modifier_barrage_cd = class({})

function modifier_barrage_cd:GetAttributes() 
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_barrage_cd:IsHidden()
    return false
end

function modifier_barrage_cd:IsDebuff()
    return true
end

function modifier_barrage_cd:RemoveOnDeath()
    return false
end

function modifier_barrage_cd:GetTexture()
    return "custom/atalanta_bow_of_heaven"
end