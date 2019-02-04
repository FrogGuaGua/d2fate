modifier_battle_continuation_heal = class({})

function modifier_battle_continuation_heal:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

if IsServer() then
	function modifier_battle_continuation_heal:OnIntervalThink()
		local parent = self:GetParent()
    if parent:IsAlive() then
  		local bc_heal = parent.MasterUnit2:FindAbilityByName("vlad_attribute_protection_of_faith"):GetSpecialValueFor("bc_heal")
  		parent:ApplyHeal(bc_heal,parent)
    end
	end

	function modifier_battle_continuation_heal:OnCreated()
		local parent = self:GetParent()
		self.PI1 = FxCreator("particles/custom/vlad/vlad_bc_heal.vpcf", PATTACH_CENTER_FOLLOW, parent,2,nil)
		self:StartIntervalThink(1)
	end

	function modifier_battle_continuation_heal:OnDestroy()
		self:StartIntervalThink(-1)
		FxDestroyer(self.PI1, false)
	end
end

function modifier_battle_continuation_heal:IsHidden()
  return false
end

function modifier_battle_continuation_heal:IsDebuff()
  return false
end

function modifier_battle_continuation_heal:RemoveOnDeath()
  return true
end
