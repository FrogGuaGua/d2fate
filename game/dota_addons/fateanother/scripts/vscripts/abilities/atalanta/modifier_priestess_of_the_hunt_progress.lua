modifier_priestess_of_the_hunt_progress = class({})

function modifier_priestess_of_the_hunt_progress:GetAttributes() 
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_priestess_of_the_hunt_progress:IsHidden()
    return true
end

function modifier_priestess_of_the_hunt_progress:IsDebuff()
    return false
end

function modifier_priestess_of_the_hunt_progress:RemoveOnDeath()
    return false
end
