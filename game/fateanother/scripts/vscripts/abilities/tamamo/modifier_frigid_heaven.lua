---@class modifier_frigid_heaven_enemy: CDOTA_Modifier_Lua
modifier_frigid_heaven_enemy = {}

function modifier_frigid_heaven_enemy:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_frigid_heaven_enemy:GetModifierMoveSpeedBonus_Percentage()
    return -(self:GetStackCount() * self:GetAbility():GetSpecialValueFor("slow_pct"))
end

function modifier_frigid_heaven_enemy:GetEffectName()
    return "particles/units/heroes/hero_ancient_apparition/ancient_apparition_ice_blast_debuff.vpcf"
end

function modifier_frigid_heaven_enemy:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

if IsServer() then
    function modifier_frigid_heaven_enemy:OnCreated(args)
        local parent = self:GetParent()
        parent:EmitSound("Tamamo.FrigidHeaven.Enemy")
        self.last_position = parent:GetAbsOrigin()
        self.damage_per_tick = self:GetAbility():GetSpecialValueFor("dot") * 0.5
        self:StartIntervalThink(0.5)
    end

    function modifier_frigid_heaven_enemy:OnRefresh(args)
        local parent = self:GetParent()
        parent:EmitSound("Tamamo.FrigidHeaven.Enemy")
        if self:GetStackCount() == self:GetCaster():FindAbilityByName("tamamo_armed_up"):GetSpecialValueFor("stack_explode_count")-1 then
            parent:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_frigid_heaven_freeze", { duration = self:GetAbility():GetSpecialValueFor("freeze_duration") })
            parent:EmitSound("Tamamo.FrigidHeaven.Freeze")
        end
    end

    function modifier_frigid_heaven_enemy:OnIntervalThink()
        local parent = self:GetParent()
        local moved = (self.last_position - parent:GetAbsOrigin()):Length2D()
        if moved <= 150 then
            DoDamage(self:GetCaster(), parent, self.damage_per_tick, DAMAGE_TYPE_MAGICAL, 0, self:GetAbility(), false)
        end
        self.last_position = parent:GetAbsOrigin()
    end
end

LinkLuaModifier("modifier_frigid_heaven_freeze", "abilities/tamamo/modifier_frigid_heaven", LUA_MODIFIER_MOTION_NONE)
---@class modifier_frigid_heaven_freeze : CDOTA_Modifier_Lua
modifier_frigid_heaven_freeze = {}

function modifier_frigid_heaven_freeze:CheckState()
    return { [MODIFIER_STATE_ROOTED] = true }
end

function modifier_frigid_heaven_freeze:GetEffectName()
    return "particles/units/heroes/hero_ancient_apparition/ancient_apparition_cold_feet_frozen.vpcf"
end

if IsServer() then
    function modifier_frigid_heaven_freeze:OnDestroy()
        local modifier = self:GetParent():FindModifierByName("modifier_frigid_heaven_enemy")
        if modifier then modifier:Destroy() end
    end
end

---@class modifier_frigid_heaven_ally: CDOTA_Modifier_Lua
modifier_frigid_heaven_ally = {}

function modifier_frigid_heaven_ally:DeclareFunctions()
    return { MODIFIER_EVENT_ON_ATTACK_LANDED }
end

function modifier_frigid_heaven_ally:GetEffectName()
    return "particles/units/heroes/hero_ancient_apparition/ancient_apparition_chilling_touch_buff.vpcf"
end

function modifier_frigid_heaven_ally:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

if IsServer() then
    function modifier_frigid_heaven_ally:OnCreated(args)
        self:GetParent():EmitSound("Tamamo.FrigidHeaven.Ally")
    end

    function modifier_frigid_heaven_ally:OnAttackLanded(args)
        if args.attacker == self:GetParent() then
            args.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_frigid_heaven_debuff", { duration = 2 })
        end
    end
end

LinkLuaModifier("modifier_frigid_heaven_debuff", "abilities/tamamo/modifier_frigid_heaven", LUA_MODIFIER_MOTION_NONE)
---@class modifier_frigid_heaven_debuff : CDOTA_Modifier_Lua
modifier_frigid_heaven_debuff = {}

function modifier_frigid_heaven_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
end

function modifier_frigid_heaven_debuff:GetModifierMoveSpeedBonus_Percentage()
    return -(self:GetAbility():GetSpecialValueFor("ms_slow_pct"))
end

function modifier_frigid_heaven_debuff:GetModifierAttackSpeedBonus_Constant()
    return -(self:GetAbility():GetSpecialValueFor("as_slow"))
end

function modifier_frigid_heaven_debuff:GetEffectName()
    return "particles/units/heroes/hero_lich/lich_slowed_cold.vpcf"
end

function modifier_frigid_heaven_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end