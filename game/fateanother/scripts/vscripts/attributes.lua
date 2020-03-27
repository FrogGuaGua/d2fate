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

if IsServer() then
    function modifier_attr_main:OnCreated(args)
        self.str_hp_reduce = STR_HP_REDUCE
        self.str_mr_reduce = STR_MR_REDUCE
        self.str_hp_regen_improve = STR_HEALTH_REGEN_IMPROVE
        self.agi_as_improve = AGI_AS_IMPROVE
        self.agi_ms_improve = AGI_MS_IMPROVE
        self.agi_ms_pct_reduce = AGI_MS_PCT_REDUCE
        self.int_mana_reduce = INT_BONUS_MANA
        self.int_mana_regen_improve = INT_BONUS_MANA_REGEN
        -- sight overview
        local caster = self:GetParent()
        local sightdummy = CreateUnitByName("sight_dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
        sightdummy:SetDayTimeVisionRange(800)
        sightdummy:SetNightTimeVisionRange(600)
        local sightdummypassive = sightdummy:FindAbilityByName("dummy_unit_passive")
        sightdummypassive:SetLevel(1)
        Timers:CreateTimer(function()
            if not IsValidEntity(sightdummy) then return end
            if caster:IsAlive() then
                sightdummy:SetAbsOrigin(caster:GetAbsOrigin())
            else
                sightdummy:SetAbsOrigin(caster.MasterUnit:GetAbsOrigin())
            end
            return 0.1
        end)
    end

    --function modifier_attr_main:OnHeroLevelUp(keys)
        --local player = self:GetParent():GetPlayerOwnerID()
        --local hero = player:GetAssignedHero()
        --local level = hero:GetLevel()
        --hero.ServStat:getLvl(hero)
        --if level == 17 or level == 19 or level == 21 or level == 22 or level == 23 or level == 24 then
        --    hero:SetAbilityPoints(hero:GetAbilityPoints()+1)
        --end
    --
        --print("asd")
        --hero.MasterUnit:SetMana(hero.MasterUnit:GetMana() + 4)
        --hero.MasterUnit2:SetMana(hero.MasterUnit2:GetMana() + 4)
        --Notifications:Top(player, "<font color='#58ACFA'>" .. FindName(hero:GetName()) .. "</font> has gained a level. Master has received <font color='#58ACFA'>3 mana.</font>", 5, nil, {color="rgb(255,255,255)", ["font-size"]="20px"})
    
       -- Notifications:Top(player, {text= "<font color='#58ACFA'>" .. FindName(hero:GetName()) .. "</font> has gained a level. Master has received <font color='#58ACFA'>3 mana.</font>", duration=5, style={color="rgb(255,255,255)", ["font-size"]="20px"}, continue=true})
       -- if level == 24 then
         --   Notifications:Top(player, {text= "<font color='#58ACFA'>" .. FindName(hero:GetName()) .. "</font> has ascended to max level! Your Master's max health has been increased by 2.", duration=8, style={color="rgb(255,140,0)", ["font-size"]="35px"}, continue=true})
        --    Notifications:Top(player, {text= "Exalted by your ascension, Holy Grail's Blessing from now on will award 3 more mana.", duration=8, style={color="rgb(255,140,0)", ["font-size"]="35px"}, continue=true})
    --
         --   hero.MasterUnit:SetMaxHealth(hero.MasterUnit:GetMaxHealth()+2)
        --    hero.MasterUnit2:SetMaxHealth(hero.MasterUnit:GetMaxHealth())
       -- end
       -- MinimapEvent( hero:GetTeamNumber(), hero, hero.MasterUnit:GetAbsOrigin().x, hero.MasterUnit2:GetAbsOrigin().y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 2 )
    --end




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
        return self.str_hp_reduce * math.floor(self:GetParent():GetStrength())   
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
        if self:GetParent():GetName() == "npc_dota_hero_shadow_shaman" then
            if self:GetParent().IsMentalPolluted  then
                return self:GetParent():GetIntellect() * (-12) + 111
            else
                return self:GetParent():GetIntellect() * (-12)  +11
            end
        else
            return self.int_mana_reduce * self:GetParent():GetIntellect()
        end
    end
end

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


