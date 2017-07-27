modifier_qgg_oracle = class({})

function modifier_qgg_oracle:OnCreated()
	self.tDamageInstances = {}
	self.fHeal = 0
	self.hParent = self:GetParent()
	self.flag = false
	self:StartIntervalThink(0.01)
end

function modifier_qgg_oracle:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}
	
	return funcs
end

function modifier_qgg_oracle:GetEffectName()
	return "particles/units/heroes/hero_oracle/oracle_false_promise.vpcf"
end

function modifier_qgg_oracle:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_qgg_oracle:OnHeal(fAmount, fHeal, hSource)
	self.fHeal = self.fHeal + fAmount
end

function modifier_qgg_oracle:OnKill(hAbility, hKiller)
	self:Destroy()
end

function modifier_qgg_oracle:DisableHeal()
	return true
end

if IsServer() then
	-- Thanks to DoctorGester (http://dg-lab.com/me) for this piece of code.
	function modifier_qgg_oracle:GetModifierConstantHealthRegen()
		if self.flag then return 0 end
		self.flag = true
		local regen = self:GetParent():GetHealthRegen()
		self.fRegen = regen
		self.flag = false
		return -regen
	end
	
	function modifier_qgg_oracle:OnIntervalThink()
		if self.fRegen then
			self.fHeal = self.fHeal + self.fRegen * 0.01
		end
	end
	
	function modifier_qgg_oracle:OnDestroy()
		local hParent = self:GetParent()
		local hAbility = self:GetAbility()
		local fHeal = self.fHeal
		
		for k, v in pairs(self.tDamageInstances) do
			local fDamage = v.fDamage
			
			local hSource = nil
			if not v.hAbility then
				hSource = hAbility
			else
				hSource = v.hAbility
			end
			
			if fHeal == 0 then
				DoDamage(v.hAttacker, hParent, fDamage, v.eDamageType, 1 + 2 + 8, hSource, false)
			end
			
			if fHeal > 0 then
				fHeal = fHeal - v.fDamage
				
				if fHeal < 0 then
					fDamage = math.abs(fHeal)
					fHeal = 0
					DoDamage(v.hAttacker, hParent, fDamage, v.eDamageType, 1 + 2 + 8, hSource, false)
				end
			end
		end
		hParent:ApplyHeal(fHeal, hAbility)
	end
end