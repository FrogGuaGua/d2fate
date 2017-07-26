if not Attributes then
    Attributes = class({})
	LinkLuaModifier("modifier_attributes_hp", "modifiers/modifier_attributes_hp", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_attributes_mp", "modifiers/modifier_attributes_mp", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_attributes_hp_regen", "modifiers/modifier_attributes_hp_regen", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_attributes_mp_regen", "modifiers/modifier_attributes_mp_regen", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_attributes_as", "modifiers/modifier_attributes_as", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_attributes_ms", "modifiers/modifier_attributes_ms", LUA_MODIFIER_MOTION_NONE)
end

function Attributes:Init()
    local v = LoadKeyValues("scripts/npc/attributes.txt")

    -- Default Dota Values
    local DEFAULT_HP_PER_STR = 20
    local DEFAULT_HP_REGEN_PER_STR = 0.06
    local DEFAULT_MANA_PER_INT = 11
    local DEFAULT_MANA_REGEN_PER_INT = 0.04
    local DEFAULT_ARMOR_PER_AGI = 0.14
    local DEFAULT_ATKSPD_PER_AGI = 1
    Attributes.hp_per_str_fate = v.HP_PER_STR
    Attributes.hp_adjustment = v.HP_PER_STR - DEFAULT_HP_PER_STR
    Attributes.hp_regen_adjustment = v.HP_REGEN_PER_STR - DEFAULT_HP_REGEN_PER_STR
    Attributes.mana_adjustment = v.MANA_PER_INT - DEFAULT_MANA_PER_INT
    Attributes.mana_regen_adjustment = v.MANA_REGEN_PER_INT - DEFAULT_MANA_REGEN_PER_INT
    Attributes.armor_adjustment = v.ARMOR_PER_AGI - DEFAULT_ARMOR_PER_AGI
    Attributes.attackspeed_adjustment = v.ATKSPD_PER_AGI - DEFAULT_ATKSPD_PER_AGI
    Attributes.ms_adjustment = v.MS_PER_AGI

    Attributes.additional_movespeed_adjustment = v.MS_PER_STAT
    Attributes.additional_armor_adjustment = v.ARMOR_PER_STAT
    Attributes.additional_mana_regen_adjustment = v.MPREG_PER_STAT
    Attributes.additional_hp_regen_adjustment = v.HPREG_PER_STAT

    Attributes.applier = CreateItem("item_stat_modifier", nil, nil)
end

function Attributes:ModifyIllusionAttackSpeed(illusion, original)
    if not illusion:HasModifier("modifier_attackspeed_bonus_constant") then
        Attributes.applier:ApplyDataDrivenModifier(illusion, illusion, "modifier_attackspeed_bonus_constant", {})
    end

    local attackspeed_stacks = math.abs(illusion:GetAgility() * Attributes.attackspeed_adjustment)
    illusion:SetModifierStackCount("modifier_attackspeed_bonus_constant", Attributes.applier, attackspeed_stacks)

    illusion:SetBaseDamageMin(original:GetBaseDamageMin() - illusion:GetAgility())
    illusion:SetBaseDamageMax(original:GetBaseDamageMax() - illusion:GetAgility())

end
function Attributes:ModifyBonuses(hero)

    print("Modifying Stats Bonus of hero "..hero:GetUnitName())

    --hero:AddNewModifier(hero, nil, "modifier_movespeed_cap", {})
    hero.STRgained = 0
    hero.AGIgained = 0
    hero.INTgained = 0
    hero.DMGgained = 0
    hero.ARMORgained = 0
    hero.ExtraARMORgained = 0
    hero.HPREGgained = 0
    hero.MPREGgained = 0
    hero.MSgained = 0
    hero.BaseArmor = hero:GetPhysicalArmorBaseValue()
    hero.BaseMS = hero:GetBaseMoveSpeed()

	hero.HP_PER_STR = Attributes.hp_per_str_fate

	hero.hp_adjustment = Attributes.hp_adjustment
	hero.hp_regen_adjustment = Attributes.hp_regen_adjustment
	hero.mana_adjustment = Attributes.mana_adjustment
	hero.mana_regen_adjustment = Attributes.mana_regen_adjustment
	hero.armor_adjustment = Attributes.armor_adjustment
	hero.attackspeed_adjustment = Attributes.attackspeed_adjustment
	hero.ms_adjustment = Attributes.ms_adjustment

	hero.additional_movespeed_adjustment = Attributes.additional_movespeed_adjustment
	hero.additional_armor_adjustment = Attributes.additional_armor_adjustment
	hero.additional_mana_regen_adjustment = Attributes.additional_mana_regen_adjustment
	hero.additional_hp_regen_adjustment = Attributes.additional_hp_regen_adjustment


	hero:AddNewModifier(hero,nil,"modifier_attributes_hp",{})
	hero:AddNewModifier(hero,nil,"modifier_attributes_mp",{})
	hero:AddNewModifier(hero,nil,"modifier_attributes_hp_regen",{})
	hero:AddNewModifier(hero,nil,"modifier_attributes_mp_regen",{})
	hero:AddNewModifier(hero,nil,"modifier_attributes_as",{})
	hero:AddNewModifier(hero,nil,"modifier_attributes_ms",{})



    Timers:CreateTimer(function()

        if not IsValidEntity(hero) then
            return
        end

        -- Initialize value tracking
        if not hero.custom_stats then
            hero.custom_stats = true
            hero.strength = 0
            hero.agility = 0
            hero.intellect = 0
        end

        -- Get player attribute values
        local strength = hero:GetStrength()
        local agility = hero:GetAgility()
        local intellect = hero:GetIntellect()

        -- Base Armor Bonus
        local armor = hero.BaseArmor + agility * Attributes.armor_adjustment + hero.ARMORgained * Attributes.additional_armor_adjustment + hero.ExtraARMORgained
        hero:SetPhysicalArmorBaseValue(armor)
        
        -- Update the stored values for next timer cycle
        hero.strength = strength
        hero.agility = agility
        hero.intellect = intellect
        hero:CalculateStatBonus()
        return 0.1
    end)
end

if not Attributes.applier then Attributes:Init() end
