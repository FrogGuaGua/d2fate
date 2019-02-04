modifier_bow_proc = class({})

function modifier_bow_proc:GetAttributes() 
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_bow_proc:IsHidden()
    return false
end

function modifier_bow_proc:IsDebuff()
    return false
end

function modifier_bow_proc:RemoveOnDeath()
    return false
end

function modifier_bow_proc:GetTexture()
    return "custom/atalanta_bow_of_heaven"
end