modifier_ta_agi = class({})

function modifier_ta_agi:OnCreated(args)
    self.fAgi = 0
end

function modifier_ta_agi:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_HERO_KILLED,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    }

    return funcs
end

function modifier_ta_agi:OnHeroKilled(args)
    local hParent = self:GetParent()
    local hAbility = self:GetAbility()

    if args.attacker == hParent then
        self.fAgi = self.fAgi + hAbility:GetSpecialValueFor("agi_increase")
        self:IncrementStackCount()
    end
end

function modifier_ta_agi:GetModifierBonusStats_Agility()
    return self.fAgi
end

function modifier_ta_agi:IsPermanent()
    return true
end