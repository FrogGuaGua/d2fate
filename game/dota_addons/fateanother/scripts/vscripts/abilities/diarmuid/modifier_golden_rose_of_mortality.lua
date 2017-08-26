modifier_golden_rose_of_mortality = class({})

function modifier_golden_rose_of_mortality:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_golden_rose_of_mortality:DeclareFunctions()
	local funcs = {
	MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	return funcs
end

function modifier_golden_rose_of_mortality:OnAttackLanded(keys)
	local parent = self:GetParent()
	local Master2 = parent.MasterUnit2
	local target = keys.target
	local ability = Master2:FindAbilityByName("diarmuid_attribute_golden_rose_of_mortality")
	local GoldenRose = ability:GetSpecialValueFor("2nd_attack_damage")
	local Damage = target:GetMaxHealth() * GoldenRose / 100

	if parent:HasModifier("modifier_double_spearsmanship") or parent:HasModifier("modifier_rampant_warrior") then
		if parent.nBaseAttackCount == nil then 
			parent.nBaseAttackCount = 0
		end

		if parent.nBaseAttackCount == 1 then
			DoDamage(parent, target, Damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			parent.nBaseAttackCount = 0
		else
			parent.nBaseAttackCount = parent.nBaseAttackCount + 1
		end
	end
end


function modifier_golden_rose_of_mortality:IsHidden()
	return true
end

function modifier_golden_rose_of_mortality:IsDebuff()
	return false
end

function modifier_golden_rose_of_mortality:RemoveOnDeath()
	return false
end