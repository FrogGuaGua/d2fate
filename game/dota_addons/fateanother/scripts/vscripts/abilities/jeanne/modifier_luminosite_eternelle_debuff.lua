---@class modifier_luminosite_eternelle_debuff : CDOTA_Modifier_Lua
modifier_luminosite_eternelle_debuff = class({})

---@class modifier_luminosite_eternelle_debuff_aura : CDOTA_Modifier_Lua
modifier_luminosite_eternelle_debuff_aura = class({})

if IsServer() then
    function modifier_luminosite_eternelle_debuff:DeclareFunctions()
        return {
            MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
        }
    end

    function modifier_luminosite_eternelle_debuff:GetModifierIncomingDamage_Percentage()
        local pct = self:GetCaster():FindModifierByName("modifier_jeanne_saint"):GetSaintPct()
        local max = self:GetAbility():GetSpecialValueFor("damage_amp")
        return max * (1 - pct)
    end

    function modifier_luminosite_eternelle_debuff_aura:IsAura()
        return true
    end

    function modifier_luminosite_eternelle_debuff_aura:GetModifierAura()
        return "modifier_luminosite_eternelle_debuff"
    end

    function modifier_luminosite_eternelle_debuff_aura:GetAuraRadius()
        return self:GetAbility():GetSpecialValueFor("range")
    end

    function modifier_luminosite_eternelle_debuff_aura:GetAuraSearchType()
        return DOTA_UNIT_TARGET_ALL
    end

    function modifier_luminosite_eternelle_debuff_aura:GetAuraSearchFlags()
        return DOTA_UNIT_TARGET_FLAG_NONE
    end

    function modifier_luminosite_eternelle_debuff_aura:GetAuraSearchTeam()
        return DOTA_UNIT_TARGET_TEAM_ENEMY
    end

    function modifier_luminosite_eternelle_debuff_aura:GetAuraDuration()
        return 0.5
    end
end