---@class jeanne_attribute_improve_saint : CDOTA_Ability_Lua
jeanne_attribute_improve_saint = {}
LinkLuaModifier("modifier_improve_saint", "abilities/jeanne/improve_saint", LUA_MODIFIER_MOTION_NONE)

function jeanne_attribute_improve_saint:OnSpellStart()
    local caster = self:GetCaster()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    hero:AddAttributeModifier(hero, self, "modifier_improve_saint", {})
end


---@class modifier_improve_saint : CDOTA_Modifier_Lua
modifier_improve_saint = {}
modifier_improve_saint.IsHidden = function(self) return false end
modifier_improve_saint.RemoveOnDeath = function(self) return false end

function modifier_improve_saint:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_improve_saint:IsAura()
    return true
end

function modifier_improve_saint:GetModifierAura()
    return "modifier_jeanne_saint_debuff"
end

function modifier_improve_saint:IsAuraActiveOnDeath()
    return false
end

function modifier_improve_saint:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("range")
end

function modifier_improve_saint:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_improve_saint:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_improve_saint:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_improve_saint:GetAuraDuration()
    return 0.5
end