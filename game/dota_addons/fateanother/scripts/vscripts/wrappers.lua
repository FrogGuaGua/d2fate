Wrappers = {}

function Wrappers.WrapUnit(hUnit)
	-- Heals
	function hUnit:ApplyHeal(fAmount, hSource, ...)
		local fHeal = fAmount
		local fMaxHealth = hUnit:GetMaxHealth()
		local fCurrentHealth = hUnit:GetHealth()
			
		if fCurrentHealth == fMaxHealth then
			fHeal = 0
		elseif fCurrentHealth + fAmount > fMaxHealth then
			fHeal = fMaxHealth - fCurrentHealth
		end
		
		local tModifiers = hUnit:FindAllModifiers()
		
		for k, v in pairs(tModifiers) do
			if v.OnHeal then
				v:OnHeal(fAmount, fHeal, hSource)
			end
			
			if v.DisableHeal then
				if v:DisableHeal() then return end
			end
		end
		
		hUnit:Heal(fAmount, hSource)
	end
	
	-- Execution
	function hUnit:Execute(hAbility, hKiller, tParams)
		local tParams = tParams or {}
		local bExecution = tParams.bExecution or false
		local tModifiers = hUnit:FindAllModifiers()
	
		for k, v in pairs(tModifiers) do
			if v.OnKill then
				v:OnKill(hAbility, hKiller)
			end
			
			if bExecution then
				if v.BlockExecute then
					if v:BlockExecute() then return end
				end
			end
		end
		
		hUnit:Kill(hAbility, hKiller)
	end
end



--Charged Beam common stuff
function Wrappers.ChargedBeam(ability)
	-----Charge calc
	function ability:__Formula( start_charge, end_charge, total_gain)
		local bonus_start = self:GetSpecialValueFor(start_charge)
		local bonus_end = self:GetSpecialValueFor(end_charge)
		local diff = bonus_end - bonus_start
		local bonus_per_charge = self:GetSpecialValueFor(total_gain) / diff
		local bonus_end_capped = bonus_end

		if self.channel_charge < bonus_end_capped then
			bonus_end_capped = self.channel_charge
		end

		return math.max(bonus_end_capped - bonus_start,0) * bonus_per_charge
	end

	function ability:ChargeGetPartial(add_start, add_end, total_gain, add_multi)
		if add_multi then
			local add_multi = self:GetSpecialValueFor(add_multi)
			return self:__Formula( add_start, add_end, total_gain) * add_multi
		else
			return self:__Formula(add_start, add_end, total_gain)
		end
	end

	function ability:ChargeGetTotal(stat, start_charge, end_charge, total_gain, add1_start, add1_end, add1_multi)--, add2_start, add2_end, add2_multi, add3_start, add3_end, add3_multi)
		local bonus_base_total = self:ChargeGetPartial(start_charge, end_charge, total_gain)
		local add_bonus = 0
		
		if add1_start then
			add_bonus = add_bonus + self:ChargeGetPartial(add1_start, add1_end, total_gain, add1_multi)
		end

		return self:GetSpecialValueFor(stat) + bonus_base_total + add_bonus
	end
	
	-----spell stuff
	function ability:OnSpellStart()
		local caster = self:GetCaster()
		self.cc_timer = 0
		self.cc_interval = 0.1
		self.channel_charge = 0
		caster:SwapAbilities(self:GetName(), self:GetName().."_activate", false, true)
		self:AfterOnSpellSt()
	end
		
	function ability:OnChannelThink(flInterval)
		self.cc_timer = self.cc_timer + flInterval
		if self.cc_timer >= self.cc_interval then
			self.cc_timer = self.cc_timer - self.cc_interval
			self.channel_charge = self.channel_charge + 1      
			self:AfterThinkChargeIncr()
		end
	end

	function ability:OnChannelFinish(bInterrupted)
		local caster = self:GetCaster()
		UnfreezeAnimation(caster)
		caster:SwapAbilities(self:GetName(), self:GetName().."_activate", true, false)
		
		if caster:IsAlive() and not (GameRules:GetGameTime()-self:GetChannelStartTime() < self:GetSpecialValueFor("activation")) then --GameRules:GetGameTime()-self:GetChannelStartTime() < 2
			self:AfterChannelFin_Success()
		else
			self:EndCooldown()
			self:StartCooldown(10)
			caster:SetMana(caster:GetMana()+(self:GetManaCost(self:GetLevel())/2))
			self:AfterChannelFin_Fail()
		end
	end
		
	function ability:LaunchBeam(effect)
		local caster = self:GetCaster()
		local speed = self:GetBeamSpeed()
		local range = self:GetBeamRange()
		local radius = self:GetBeamRadius()
		local end_radius = self:GetBeamEndRadius()
		range = range - end_radius -- Dun: We need this to take end radius of projectile into account
		local casterLoc = caster:GetAbsOrigin()
		local target_point = self:GetCursorPosition()
		local direction = caster:GetForwardVector() --(target_point - caster:GetAbsOrigin()):Normalized() --direction.z = 0
		local damage_total = self:GetBeamDamage()

		local beam =
		{
			Ability = self,
			EffectName = effect,
			vSpawnOrigin = casterLoc + direction * self:GetSpecialValueFor("displacement"),
			fDistance = range,
			fStartRadius = radius,
			fEndRadius = end_radius,
			Source = caster,
			--bGroundLock = true,
			bHasFrontalCone = true,
			bReplaceExisting = false,
			bProvidesVision = true,
			iVisionRadius = radius,
			bFlyingVision = true,
			iVisionTeamNumber = caster:GetTeamNumber(),
			GroundBehavior = PROJECTILES_NOTHING,
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			--fExpireTime = GameRules:GetGameTime() + 5.0,
			bDeleteOnHit = false,
			vVelocity = speed*direction, 
			ExtraData = {
										--charge = self.channel_charge,
										damage = damage_total
									}
		}  
			
		self.beam_projectile = ProjectileManager:CreateLinearProjectile(beam)
		return beam
	end
end	