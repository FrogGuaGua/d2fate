---@class jeanne_saint : CDOTA_Ability_Lua
jeanne_saint = class({})
LinkLuaModifier("modifier_jeanne_saint", "abilities/jeanne/saint", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jeanne_saint_debuff", "abilities/jeanne/saint", LUA_MODIFIER_MOTION_NONE)
-- no other place to put these two...
LinkLuaModifier("modifier_luminosite_eternelle_debuff", "abilities/jeanne/modifier_luminosite_eternelle_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_luminosite_eternelle_debuff_aura", "abilities/jeanne/modifier_luminosite_eternelle_debuff", LUA_MODIFIER_MOTION_NONE)

function jeanne_saint:GetIntrinsicModifierName()
    return "modifier_jeanne_saint"
end

---@class modifier_jeanne_saint : CDOTA_Modifier_Lua
modifier_jeanne_saint = class({})

if IsServer() then
    function modifier_jeanne_saint:OnCreated(args)
        self.reduction = 0
        self.amplification = 0
        self.pct = 0
        self:StartIntervalThink(0.25)
    end

    function modifier_jeanne_saint:OnIntervalThink()
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local currHP = parent:GetHealth()
        local maxHP = parent:GetMaxHealth()
        local d = maxHP * (ability:GetSpecialValueFor("health_threshold")/100)
        local maxReductionPct = ability:GetSpecialValueFor("reduction_max_pct")
        self.pct = (currHP - d)/(maxHP - d)
        self.reduction = vlua.select(currHP > d, -(maxReductionPct + self.pct * (-maxReductionPct)), -maxReductionPct)

        if parent:HasModifier("modifier_improve_saint") then
            local maxAmpPct = parent:FindModifierByName("modifier_improve_saint"):GetAbility():GetSpecialValueFor("amp_pct")
            self.amplification = vlua.select(currHP > d, (maxAmpPct + self.pct * (-maxAmpPct)), maxAmpPct)
        end
    end

    function modifier_jeanne_saint:DeclareFunctions()
        return {
            MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
            MODIFIER_EVENT_ON_RESPAWN
        }
    end

    function modifier_jeanne_saint:GetModifierIncomingDamage_Percentage()
        return self.reduction
    end

    function modifier_jeanne_saint:GetSaintPct()
        return self.pct
    end
end

---@class modifier_jeanne_saint_debuff : CDOTA_Modifier_Lua
modifier_jeanne_saint_debuff = class({})
modifier_jeanne_saint_debuff.IsDebuff = function(self) return true end

if IsServer() then
   function modifier_jeanne_saint_debuff:DeclareFunctions()
       return {
           MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
       }
   end

    function modifier_jeanne_saint_debuff:GetModifierIncomingDamage_Percentage()
        return self:GetCaster():FindModifierByName("modifier_jeanne_saint").amplification or 0
    end
end