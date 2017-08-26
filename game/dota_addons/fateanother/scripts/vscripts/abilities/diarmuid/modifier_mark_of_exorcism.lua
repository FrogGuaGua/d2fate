modifier_mark_of_exorcism = class({})


function modifier_mark_of_exorcism:IsHidden()
	return false
end

function modifier_mark_of_exorcism:IsDebuff()
	return true
end

function modifier_mark_of_exorcism:RemoveOnDeath()
	return true
end

function modifier_mark_of_exorcism:GetTexture()
	return "custom/diarmuid_gae_dearg"
end

function modifier_mark_of_exorcism:GetEffectName()
	return "particles/custom/diarmuid/diarmuid_mark_of_exorcism.vpcf"
end

function modifier_mark_of_exorcism:GetEffectaAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end