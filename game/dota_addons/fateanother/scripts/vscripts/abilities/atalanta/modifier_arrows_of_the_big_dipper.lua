modifier_arrows_of_the_big_dipper = class({})

function modifier_arrows_of_the_big_dipper:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_RESPAWN,
    }
 
    return funcs
end

function modifier_arrows_of_the_big_dipper:OnRespawn() 
    self:SetStackCount(0)
end

function modifier_arrows_of_the_big_dipper:GetAttributes() 
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_arrows_of_the_big_dipper:IsHidden()
    return false
end

function modifier_arrows_of_the_big_dipper:IsDebuff()
    return false
end

function modifier_arrows_of_the_big_dipper:RemoveOnDeath()
    return false
end

function modifier_arrows_of_the_big_dipper:GetTexture()
    return "custom/atalanta_arrows_of_the_big_dipper"
end
