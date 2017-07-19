modifier_calydonian_hunt_root = class({})

function modifier_calydonian_hunt_root:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
    }
 
    return funcs
end

function modifier_calydonian_hunt_root:GetModifierProvidesFOWVision()
    return 1
end

function modifier_calydonian_hunt_root:IsDebuff()
    return true
end

function modifier_calydonian_hunt_root:RemoveOnDeath()
    return true
end

function modifier_calydonian_hunt_root:GetTexture()
    return "custom/atalanta_calydonian_hunt"
end