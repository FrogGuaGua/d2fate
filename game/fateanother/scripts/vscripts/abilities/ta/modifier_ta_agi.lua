modifier_ta_agi = class({})

function modifier_ta_agi:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_HERO_KILLED,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    }

    return funcs
end

function modifier_ta_agi:OnHeroKilled(args)
    local hParent = self:GetParent()
    if args.unit.HasOwnerAbandoned and args.unit:HasOwnerAbandoned() then return end

    if args.attacker == hParent then
        self:IncrementStackCount()
    end
end

function modifier_ta_agi:GetModifierBonusStats_Agility()
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("agi_increase")
end

function modifier_ta_agi:IsPermanent()
    return true
end