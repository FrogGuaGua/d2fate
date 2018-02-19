modifier_hecatic_graea_anim = class({})

function modifier_hecatic_graea_anim:IsHidden()
	return true 
end

function modifier_hecatic_graea_anim:DeclareFunctions()
	return { MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
			 MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE }
end

function modifier_hecatic_graea_anim:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_4
end

function modifier_hecatic_graea_anim:GetOverrideAnimationRate()
	return 1.0
end