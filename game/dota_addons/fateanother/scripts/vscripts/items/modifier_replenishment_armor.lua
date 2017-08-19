modifier_replenishment_armor = class({})


function modifier_replenishment_armor:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
	return funcs
end

function modifier_replenishment_armor:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("armorbonus")
end


function modifier_replenishment_armor:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_replenishment_armor:GetEffectName()
	return "particles/neutral_fx/ogre_magi_frost_armor.vpcf"
end
function modifier_replenishment_armor:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_replenishment_armor:GetTexture()
	return "custom/shard_of_replenishment"
end
