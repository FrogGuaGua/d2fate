modifier_transfusion_self = class({})

function modifier_transfusion_self:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

if IsServer() then
	function modifier_transfusion_self:OnCreated()
		self.PI1 = FxCreator("particles/custom/vlad/vlad_tf_self.vpcf",PATTACH_ABSORIGIN_FOLLOW,self:GetCaster(),0,nil)
	end

	function modifier_transfusion_self:OnDestroy()
		FxDestroyer(self.PI1, false)
    if not self:GetParent():HasModifier("modifier_transfusion_bloodpower") then
			self:GetParent():ResetImpaleSwapTimer()
    end
	end
end

function modifier_transfusion_self:IsHidden()
  return false
end

function modifier_transfusion_self:IsDebuff()
  return false
end

function modifier_transfusion_self:RemoveOnDeath()
  return true
end
