--- Initializes stats (str agi int etc) for a hero.
---@param hero CDOTA_BaseNPC_Hero
function init_attributes(hero)
    if not hero:IsRealHero() then return end
    hero:AddNewModifier(hero, nil, "modifier_attr_main", {})
    hero:AddNewModifier(hero, nil, "modifier_attr_hpregen", {})
    hero:AddNewModifier(hero, nil, "modifier_attr_manaregen", {})
    hero:AddNewModifier(hero, nil, "modifier_attr_armor", {})
end

--local STR_HP_MODIFIER = 4.5       -- str heroes get this subtracted per point of strength, others get it added.
local AGI_AS_IMPROVE = 1  -- agi heroes get -0.25 atk speed per point of agi.
local AGI_MS_IMPROVE = 1
local AGI_MS_PCT_REDUCE = -0.05
local INT_BONUS_MANA = 1        -- non-int heroes get +3 mana per point of int.
local INT_BONUS_MANA_REGEN = 0.25
local STR_HP_REDUCE = -2
local STR_HEALTH_REGEN_IMPROVE = 0.15 -- str improve hp regen
local STR_MR_REDUCE = -0.1

LinkLuaModifier("modifier_attr_main", "attributes", LUA_MODIFIER_MOTION_NONE)
---@class modifier_attr_main : CDOTA_Modifier_Lua
modifier_attr_main = {}

modifier_attr_main.IsHidden = function(self) return true end
modifier_attr_main.RemoveOnDeath = function(self) return false end

--if IsServer() then
    function modifier_attr_main:OnCreated(args)
        self.str_hp_reduce = STR_HP_REDUCE
        self.str_mr_reduce = STR_MR_REDUCE
        self.str_hp_regen_improve = STR_HEALTH_REGEN_IMPROVE
        self.agi_as_improve = AGI_AS_IMPROVE
        self.agi_ms_improve = AGI_MS_IMPROVE
        self.agi_ms_pct_reduce = AGI_MS_PCT_REDUCE
        self.int_mana_reduce = INT_BONUS_MANA
        self.int_mana_regen_improve = INT_BONUS_MANA_REGEN
        --local primary_attribute = self:GetParent():GetPrimaryAttribute()
        --if primary_attribute == DOTA_ATTRIBUTE_STRENGTH then
            --self.bonus_hp = -self.bonus_hp
        --elseif primary_attribute == DOTA_ATTRIBUTE_AGILITY then
            --self.as_reduction = AGI_AS_REDUCTION
            --self.bonus_hp = -self.hpblance
        --elseif primary_attribute == DOTA_ATTRIBUTE_INTELLECT then
            --self.bonus_mana = 0
            --self.bonus_hp = -self.hpblance
        --end
    end

    function modifier_attr_main:DeclareFunctions()
        return {
            MODIFIER_PROPERTY_HEALTH_BONUS,
            MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
            MODIFIER_PROPERTY_MANA_BONUS,
            MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
            MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
            MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
            MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
            MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
        }
    end

    function modifier_attr_main:GetModifierHealthBonus()
        return self.str_hp_reduce * self:GetParent():GetStrength()
    end

    function modifier_attr_main:GetModifierConstantHealthRegen()
        return self.str_hp_regen_improve * self:GetParent():GetStrength()
    end

    function modifier_attr_main:GetModifierMagicalResistanceBonus()
        return self.str_mr_reduce * self:GetParent():GetStrength()
    end

    function modifier_attr_main:GetModifierAttackSpeedBonus_Constant()
        return self.agi_as_improve * self:GetParent():GetAgility()
    end
    
    function modifier_attr_main:GetModifierMoveSpeedBonus_Percentage()
        return self.agi_ms_pct_reduce * self:GetParent():GetAgility()
    end

    function modifier_attr_main:GetModifierMoveSpeedBonus_Constant()
        return self.agi_ms_improve * self:GetParent():GetAgility()
    end
    
    function modifier_attr_main:GetModifierConstantManaRegen()
        return self.int_mana_regen_improve * self:GetParent():GetIntellect()
    end

    function modifier_attr_main:GetModifierManaBonus()
        return self.int_mana_reduce * self:GetParent():GetIntellect()
    end
--end

LinkLuaModifier("modifier_attr_hpregen", "attributes", LUA_MODIFIER_MOTION_NONE)
---@class modifier_attr_hpregen : CDOTA_Modifier_Lua
modifier_attr_hpregen = {}

modifier_attr_hpregen.IsHidden = function(self) return true end
modifier_attr_hpregen.RemoveOnDeath = function(self) return false end

function modifier_attr_hpregen:DeclareFunctions()
    return { MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT }
end

function modifier_attr_hpregen:GetModifierConstantHealthRegen()
    return 4 * self:GetStackCount()
end


LinkLuaModifier("modifier_attr_manaregen", "attributes", LUA_MODIFIER_MOTION_NONE)
---@class modifier_attr_manaregen : CDOTA_Modifier_Lua
modifier_attr_manaregen = {}

modifier_attr_manaregen.IsHidden = function(self) return true end
modifier_attr_manaregen.RemoveOnDeath = function(self) return false end

function modifier_attr_manaregen:DeclareFunctions()
    return { MODIFIER_PROPERTY_MANA_REGEN_CONSTANT }
end

function modifier_attr_manaregen:GetModifierConstantManaRegen()
    return 1.5 * self:GetStackCount()
end

LinkLuaModifier("modifier_attr_armor", "attributes", LUA_MODIFIER_MOTION_NONE)
---@class modifier_attr_armor : CDOTA_Modifier_Lua
modifier_attr_armor = {}

modifier_attr_armor.IsHidden = function(self) return true end
modifier_attr_armor.RemoveOnDeath = function(self) return false end

function modifier_attr_armor:DeclareFunctions()
    return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
end

function modifier_attr_armor:GetModifierPhysicalArmorBonus()
    return 1.5 * self:GetStackCount()
end