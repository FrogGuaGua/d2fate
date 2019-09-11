modifier_gordius_wheel = class({})
--LinkLuaModifier("modifier_gordius_wheel", "abilities/iskander/modifier_gordius_wheel", LUA_MODIFIER_MOTION_NONE)


function modifier_gordius_wheel:GetIntrinsicModifierName()
    return "modifier_gordius_wheel"
end


function modifier_gordius_wheel:OnCreated(args)
end

function modifier_gordius_wheel:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
    }
end

function modifier_gordius_wheel:GetModifierTurnRate_Percentage()
    return -350
end


function modifier_gordius_wheel:GetModifierMoveSpeed_Absolute()
    local speed = self:GetCaster():GetIntellect() * 7  + 550
    return speed
end


function modifier_gordius_wheel:OnDestroy()
    local caster = self:GetCaster()

	if caster:HasModifier("modifier_army_of_the_king_death_checker") then
		caster:SwapAbilities("fate_empty3", caster:GetAbilityByIndex(5):GetName(), true, false) 
    else
        if caster:FindAbilityByName("iskander_strategy_forward"):IsHidden() then
           caster:SwapAbilities(caster:GetAbilityByIndex(5):GetName(), "iskander_army_of_the_king", false, true) 
        end
	end

	caster.OriginalModel = "models/iskander/iskander.vmdl"
    caster:SetModel("models/iskander/iskander.vmdl")
    caster:SetOriginalModel("models/iskander/iskander.vmdl")
    caster:SetModelScale(1.0)
end

