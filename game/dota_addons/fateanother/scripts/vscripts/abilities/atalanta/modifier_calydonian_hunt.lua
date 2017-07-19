modifier_calydonian_hunt = class({})

function modifier_calydonian_hunt:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
 
    return funcs
end

function modifier_calydonian_hunt:GetModifierPhysicalArmorBonus() 
    local ability = self:GetAbility()
    local armor_reduction = ability:GetSpecialValueFor("armor_reduction_per_stack")

    return -armor_reduction * self:GetStackCount()
end
 
function modifier_calydonian_hunt:IsDebuff()
    return true
end

function modifier_calydonian_hunt:RemoveOnDeath()
    return true
end

function modifier_calydonian_hunt:GetTexture()
    return "custom/atalanta_calydonian_hunt"
end