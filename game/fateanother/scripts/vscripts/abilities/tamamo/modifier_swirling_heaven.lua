---@class modifier_swirling_heaven_enemy : CDOTA_Modifier_Lua
modifier_swirling_heaven_enemy = {}

function modifier_swirling_heaven_enemy:GetEffectName()
    return "particles/units/heroes/hero_beastmaster/beastmaster_wildaxe_debuff.vpcf"
end

if IsServer() then
    function modifier_swirling_heaven_enemy:OnCreated(args)
        self.tick = 0.5
        self.damage = self:GetAbility():GetSpecialValueFor("damage_per_stack") * self.tick
        self:StartIntervalThink(self.tick )
        self:OnRefresh(args)
    end

    function modifier_swirling_heaven_enemy:OnRefresh(args)
        local ability = self:GetAbility()
        local stack_count = self:GetStackCount()+1
        local parent = self:GetParent()
        self.damage = ability:GetSpecialValueFor("damage_per_stack") * stack_count * self.tick
        parent:AddNewModifier(self:GetCaster(), ability, "modifier_swirling_heaven_silence", { duration = ability:GetSpecialValueFor("cc_duration") })
        parent:EmitSound("Tamamo.SwirlingHeaven.Enemy")
        if stack_count == self:GetCaster():FindAbilityByName("tamamo_armed_up"):GetSpecialValueFor("stack_explode_count") then
            parent:AddNewModifier(self:GetCaster(), ability, "modifier_swirling_heaven_hex", { duration = ability:GetSpecialValueFor("hex_duration") })
            parent:EmitSound("Tamamo.SwirlingHeaven.Hex")
            self:Destroy()
        end
    end

    function modifier_swirling_heaven_enemy:OnIntervalThink()
        DoDamage(self:GetCaster(), self:GetParent(), self.damage, DAMAGE_TYPE_MAGICAL, 0, self:GetAbility(), false)
    end
end

LinkLuaModifier("modifier_swirling_heaven_silence", "abilities/tamamo/modifier_swirling_heaven", LUA_MODIFIER_MOTION_NONE)
---@class modifier_swirling_heaven_silence : CDOTA_Modifier_Lua
modifier_swirling_heaven_silence = {}

function modifier_swirling_heaven_silence:CheckState()
    return {
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_DISARMED] = true
    }
end

LinkLuaModifier("modifier_swirling_heaven_hex", "abilities/tamamo/modifier_swirling_heaven", LUA_MODIFIER_MOTION_NONE)
---@class modifier_swirling_heaven_hex : CDOTA_Modifier_Lua
modifier_swirling_heaven_hex = {}

function modifier_swirling_heaven_hex:CheckState()
    return {
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_MUTED] = true,
        [MODIFIER_STATE_HEXED] = true,
        [MODIFIER_STATE_SILENCED] = true
    }
end

function modifier_swirling_heaven_hex:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE
    }
end

function modifier_swirling_heaven_hex:GetModifierMoveSpeed_Absolute()
    return 140
end

function modifier_swirling_heaven_hex:GetModifierModelChange()
    return "models/items/hex/sheep_hex/sheep_hex.vmdl"
end

---@class modifier_swirling_heaven_ally : CDOTA_Modifier_Lua
modifier_swirling_heaven_ally = {}

if IsServer() then
    function modifier_swirling_heaven_ally:OnCreated(args)
        self:GetParent():EmitSound("Tamamo.SwirlingHeaven.Ally")
    end
end

function modifier_swirling_heaven_ally:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_EVASION_CONSTANT
    }
end

function modifier_swirling_heaven_ally:GetModifierMoveSpeedBonus_Constant()
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("ms_per_stack")
end

function modifier_swirling_heaven_ally:GetModifierEvasion_Constant()
    return self:GetAbility():GetSpecialValueFor("evasion")
end

function modifier_swirling_heaven_ally:GetEffectName()
    return "particles/units/heroes/hero_windrunner/windrunner_windrun.vpcf"
end

function modifier_swirling_heaven_ally:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end