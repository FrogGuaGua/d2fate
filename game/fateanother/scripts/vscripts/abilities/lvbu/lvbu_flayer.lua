lvbu_flayer = class({})
LinkLuaModifier("modifier_flayer", "abilities/lvbu/lvbu_flayer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_flayer_improve", "abilities/lvbu/lvbu_flayer", LUA_MODIFIER_MOTION_NONE)

function lvbu_flayer:GetIntrinsicModifierName()
    return "modifier_flayer_improve"
end

function lvbu_flayer:AddStack(target)
    local caster = self:GetCaster()
    local modifier = target:FindModifierByName("modifier_flayer")
    local currentStack = modifier and modifier:GetStackCount() or 0
    target:RemoveModifierByName("modifier_flayer")
    target:AddNewModifier(caster, self, "modifier_flayer", {
        duration = self:GetSpecialValueFor("duration")
    })
    target:SetModifierStackCount("modifier_flayer", self, currentStack+1)
end


--class modifier_flayer_improve
modifier_flayer_improve = class({})
    function modifier_flayer_improve:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_ATTACK_LANDED
        }
    end
    function modifier_flayer_improve:OnAttackLanded(args)
        if args.attacker == self:GetParent() and ( not self:GetParent():IsIllusion() ) then
            local target = args.target
            local ability = self:GetParent():FindAbilityByName("lvbu_flayer")
            ability:AddStack(target)
        end
    end
--class modifier_flayer
modifier_flayer = class({})
    function modifier_flayer:OnCreated(args)
        self:StartIntervalThink(0.1)
    end

    function modifier_flayer:OnIntervalThink()
        local count = self:GetStackCount()
        self.phy_reduce = (-2) * count
        self.mr_reduce = (-1) * count
    end

    function modifier_flayer:DeclareFunctions()
        return {
            MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
            MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
        }
    end
    
    function modifier_flayer:GetModifierPhysicalArmorBonus()
        return self.phy_reduce
    end

    function modifier_flayer:GetModifierMagicalResistanceBonus()
        return self.mr_reduce
    end
    
    function modifier_flayer:OnDestory()
        UTIL_Remove( self:GetParent() )
    end





