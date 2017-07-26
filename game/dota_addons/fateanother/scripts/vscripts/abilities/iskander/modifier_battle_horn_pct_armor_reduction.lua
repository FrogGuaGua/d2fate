modifier_battle_horn_pct_armor_reduction = class({})

function modifier_battle_horn_pct_armor_reduction:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
 
    return funcs
end

function modifier_battle_horn_pct_armor_reduction:GetModifierPhysicalArmorBonus() 
    local ability = self:GetAbility()
    local pct_armor_reduction = ability:GetSpecialValueFor("pct_armor_reduction")
    local parent_armor = self:GetParent():GetPhysicalArmorBaseValue()

    return pct_armor_reduction / 100 * parent_armor
end
 
function modifier_battle_horn_pct_armor_reduction:IsDebuff()
    return true
end

function modifier_battle_horn_pct_armor_reduction:RemoveOnDeath()
    return true
end

function modifier_battle_horn_pct_armor_reduction:GetTexture()
    return "legion_commander_press_the_attack"
end