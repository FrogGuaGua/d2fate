modifier_replenishment_heal = class({})


function modifier_replenishment_heal:OnCreated()
	self:StartIntervalThink( 0.1 )
end

if IsServer() then
	function modifier_replenishment_heal:OnIntervalThink()
		local parent = self:GetParent()
   	 	if parent:IsAlive() then
			local HPRegen = self:GetAbility():GetSpecialValueFor("hpregen") / 10
			local ManaRegen = self:GetAbility():GetSpecialValueFor("manaregen") / 10
			parent:ApplyHeal(HPRegen,parent)
			parent:GiveMana(ManaRegen)
		end
	end
end

function modifier_replenishment_heal:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_replenishment_heal:GetEffectName()
	return "particles/units/heroes/hero_abaddon/abaddon_borrowed_time.vpcf"
end

function modifier_replenishment_heal:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_replenishment_heal:GetTexture()
	return "custom/shard_of_replenishment"
end
