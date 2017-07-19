modifier_r_used = class({})

function modifier_r_used:IsHidden()
    return true
end

function modifier_r_used:IsDebuff()
    return false
end

function modifier_r_used:RemoveOnDeath()
    return true
end
