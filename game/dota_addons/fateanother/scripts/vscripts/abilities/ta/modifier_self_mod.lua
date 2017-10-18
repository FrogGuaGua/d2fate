modifier_self_mod = class({})
if IsServer() then
    function modifier_self_mod:OnCreated(args)
        self.fHeal = args.heal / args.Duration
        self.fAgi = args.agi
        self:StartIntervalThink(1.0)
    end

    function modifier_self_mod:DeclareFunctions()
        local funcs = {
            MODIFIER_PROPERTY_STATS_AGILITY_BONUS
        }

        return funcs
    end

    function modifier_self_mod:GetModifierBonusStats_Agility()
        return self.fAgi
    end


    function modifier_self_mod:OnIntervalThink()
        local hParent = self:GetParent()
        hParent:ApplyHeal(self.fHeal, hParent)
    end
end

function modifier_self_mod:GetEffectName()
    return "particles/units/heroes/hero_enigma/enigma_ambient_body.vpcf"
end

function modifier_self_mod:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end