sword_martial = class({})

function sword_martial:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function sword_martial:GetModifierPreAttack_CriticalStrike()
    return 150
end

function sword_martial:GetModifierAttackSpeedBonus_Constant()
    return self:GetCaster():GetAgility() * 3 + 75
end

function sword_martial:OnAttackLanded(args)
    if args.attacker == self:GetParent() and (not self:GetParent():IsIllusion()) then
        local caster = self:GetCaster()
        DoDamage(
            caster,
            args.target,
            caster:GetAgility() * 3,
            DAMAGE_TYPE_MAGICAL,
            0,
            caster:FindAbilityByName("nero_acquire_martial_arts"),
            false
        )
        caster:SetAbsOrigin(args.target:GetAbsOrigin() - RandomVector(100))
        FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
        caster:SetForwardVector((args.target:GetAbsOrigin() -caster:GetAbsOrigin() ):Normalized())
        
    end
end

function sword_martial:OnDestory()
    UTIL_Remove(self:GetParent())
end

function sword_martial:GetTexture()
    return "custom/nero_imperial_privilege"
end

