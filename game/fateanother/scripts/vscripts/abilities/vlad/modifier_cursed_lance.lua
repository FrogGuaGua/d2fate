modifier_cursed_lance = class({})
--REMEMBER TO MOVE STUFF IN DODAMAGE UTIL.LUA

if not IsServer() then
	return
end


function cl_wrapper(modifier)
	function modifier:GetAttributes()
	  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
	end

	function modifier:DeclareFunctions()
		local funcs = {
			MODIFIER_EVENT_ON_TAKEDAMAGE
	  }
	  return funcs
	end

	function modifier:VFX0_Counter(parent)
		local dmg_counter = math.floor(((self.CL_MAX_SHIELD - (self.CL_SHIELDLEFT or 0))/self.CL_MAX_SHIELD)*(self.CL_MAX_DMG))
		print("PAINTER VALUES ARE : "..dmg_counter.."    "..self.CL_SHIELDLEFT.."     ".. self.CL_MAX_SHIELD.."     ".. self.CL_MAX_DMG)
		local digit = 0
		if dmg_counter > 999 then
			digit = 4
		elseif dmg_counter > 99 then
			digit = 3
		elseif dmg_counter > 9 then
			digit = 2
		else
			digit = 1
			if dmg_counter == 0 then
				dmg_counter = 5200 --hacky and clean way (i guess?) to draw 0 ONCE without making code spaghetti ---- dont use dmg_counter for anything else if this is enabled
			end
		end
		FxDestroyer(self.PI0, true)
		self.PI0 = ParticleManager:CreateParticleForPlayer( "particles/custom/vlad/vlad_cl_popup.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, parent, parent:GetPlayerOwner() )
		ParticleManager:SetParticleControlEnt( self.PI0, 0, parent,  PATTACH_CUSTOMORIGIN_FOLLOW, nil, parent:GetAbsOrigin(), false )
		ParticleManager:SetParticleControl( self.PI0, 1, Vector( 0, dmg_counter, 0 ) )  -- 0,counter,0
		ParticleManager:SetParticleControl( self.PI0, 2, Vector( 10, digit, 0 ) ) --duration, count of digits to draw, 0
		ParticleManager:SetParticleControl( self.PI0, 3, Vector( 252, 75, 75 ) )--color
		ParticleManager:SetParticleControl( self.PI0, 4, Vector( 30,0,0) ) --size/radius, 0 ,0
	end
	function modifier:VFX1_Shield(parent)
		self.PI1 = FxCreator("particles/custom/vlad/vlad_cl_shield.vpcf",PATTACH_ABSORIGIN_FOLLOW,parent,0,nil)
		self.PI2 = FxCreator("particles/custom/vlad/vlad_cl_shield2.vpcf",PATTACH_ABSORIGIN_FOLLOW,parent,0,nil)
	end
	function modifier:VFX2_PreExplosion(parent)
		self.PI3 = FxCreator("particles/custom/vlad/vlad_cl_preexplosion.vpcf",PATTACH_ABSORIGIN_FOLLOW,parent,0,nil)
		ParticleManager:SetParticleControlEnt( self.PI3, 1, parent,  PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), false )
	end
	function modifier:VFX3_Explosion(parent)
		self.PI4 = FxCreator("particles/custom/vlad/vlad_cl_explosion.vpcf",PATTACH_ABSORIGIN_FOLLOW,parent,0,nil)
		ParticleManager:SetParticleControlEnt( self.PI4, 1, parent,  PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), false )
		ParticleManager:SetParticleControlEnt( self.PI4, 3, parent,  PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), false )
	end
	function modifier:VFX4_AOEIndicator(parent)
		self.PI5 = ParticleManager:CreateParticleForTeam( "particles/custom/vlad/vlad_cl_indicator.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent, parent:GetTeamNumber())
		ParticleManager:SetParticleControlEnt( self.PI5, 0, parent,  PATTACH_ABSORIGIN_FOLLOW, nil, parent:GetAbsOrigin(), false )
		ParticleManager:SetParticleControl( self.PI5, 1, Vector( self:GetAbility():GetSpecialValueFor("aoe")+50, 0, 0 ) )
	end
	function modifier:VFX5_ExpiringIndicator()
		if self.PI6 == nil and  self:GetRemainingTime() < 3  and self.CL_MAX_SHIELD ~= self.CL_SHIELDLEFT then --self.CL_SHIELDLEFT ~= self.CL_MAX_SHIELD and
			local parent = self:GetParent()
			self.PI6 = FxCreator("particles/custom/vlad/vlad_cl_expiring.vpcf",PATTACH_POINT_FOLLOW,parent,3,"attach_hitloc")
			Timers:CreateTimer(function()
				if not self:IsNull() then
					self.timer_tick = self.timer_tick+1
					local cp_adjust = (9+self.timer_tick-self:GetRemainingTime())/7
					local cp_vector = Vector(cp_adjust, cp_adjust/1.1, 1 )
					ParticleManager:SetParticleControl( self.PI6, 4,  cp_vector)
					return 0.1
				else
					return nil
				end
			end)
		end
	end

	function modifier:OnDestroy()
		--print("no explosion, destroy all particles")
		self:StartIntervalThink(-1)
		FxDestroyer(self.PI0, true)
		FxDestroyer(self.PI1, false)
		FxDestroyer(self.PI2, false)
		FxDestroyer(self.PI5, true)
		FxDestroyer(self.PI6, false)
		Timers:CreateTimer(1, function()
			FxDestroyer(self.PI3, false)
			FxDestroyer(self.PI4, false)
		end)
		local caster = self:GetCaster()
		if caster.InstantSwapTimer then
			Timers:RemoveTimer(caster.InstantSwapTimer)
			caster.InstantSwapTimer = nil
			caster:SwapAbilities("vlad_cursed_lance", "vlad_instant_curse", true, false)
		end
	end

	function modifier:UpdateModVars(shield,dmg)
		local ability = self:GetAbility()
		self.CL_MAX_DMG = dmg or ability:GetSpecialValueFor("max_dmg")
		self.CL_MAX_SHIELD = shield or ability:GetSpecialValueFor("max_shield")
		self.__cl_prev_amount = 7052 --its needed to put smh in this var after all
	end

	function modifier:OnCreated()
		local parent = self:GetParent()
		self:UpdateModVars()
		self:ApplyAttrBonuses(parent) --attribute stuff
		self.timer_tick = 0
		self.CL_SHIELDLEFT = self.CL_MAX_SHIELD
		self:StartIntervalThink(0.1)
		self:VFX1_Shield(parent)
		parent:EmitSound("hero_bloodseeker.rupture.cast")
	end
	function modifier:OnRefresh()
		self:OnDestroy()
		self:OnCreated()
	end

	function modifier:ApplyAttrBonuses(parent)
		local parent = self:GetParent()
		local dmg_base = self.CL_MAX_DMG
		local shield_base = self.CL_MAX_SHIELD
		--apply bonus for global bleeds
		if parent.InstantCurseAcquired then
			local bleedcounter = parent:GetGlobalBleeds()
			local master2 = parent.MasterUnit2
			local attribute_ability = master2:FindAbilityByName("vlad_attribute_instant_curse")
			self.CL_MAX_DMG = self.CL_MAX_DMG+(bleedcounter*attribute_ability:GetSpecialValueFor("cl_bonus_dmg_per_stack"))
			self.CL_MAX_SHIELD = self.CL_MAX_SHIELD+(bleedcounter*attribute_ability:GetSpecialValueFor("cl_bonus_shield_per_stack"))
		end
		print("after instant curse :                  ", self.CL_MAX_SHIELD,"     ", self.CL_MAX_DMG)
		--apply bonus for bloodpower stacks
		if parent.BloodletterAcquired then
			if not parent:HasModifier("modifier_transfusion_self") then
				parent:ResetImpaleSwapTimer()
				local modifier = parent:FindModifierByName("modifier_transfusion_bloodpower")
		 		local bloodpower = modifier and modifier:GetStackCount() or 0
		 		local bloodpowerduration = modifier and modifier:GetRemainingTime() or 0
				local attribute_ability = parent.MasterUnit2:FindAbilityByName("vlad_attribute_bloodletter")
				local bonus_dmg_per_bloodpower = attribute_ability:GetSpecialValueFor("cl_bonus_dmg_per_stack")
				local bonus_shield_per_bloodpower = attribute_ability:GetSpecialValueFor("cl_bonus_shield_per_stack")
				local bloodpowercap = attribute_ability:GetSpecialValueFor("bloodpower_cap")
				self.CL_MAX_DMG = self.CL_MAX_DMG+ math.min(self.CL_MAX_DMG*bloodpower*bonus_dmg_per_bloodpower, self.CL_MAX_DMG*bloodpowercap*bonus_dmg_per_bloodpower)
				self.CL_MAX_SHIELD = self.CL_MAX_SHIELD+ math.min(self.CL_MAX_SHIELD*bloodpower*bonus_shield_per_bloodpower, self.CL_MAX_SHIELD*bloodpowercap*bonus_shield_per_bloodpower)
				if bloodpower > 30 then 
					parent:RemoveModifierByName("modifier_transfusion_bloodpower")
					parent:AddNewModifier(parent, self, "modifier_transfusion_bloodpower", {duration = bloodpowerduration})
					parent:SetModifierStackCount("modifier_transfusion_bloodpower", caster, bloodpower - bloodpowercap)
				else parent:RemoveModifierByName("modifier_transfusion_bloodpower")
				end
			end
		end
		--cap bonuses
		--self.CL_MAX_DMG = math.min(self.CL_MAX_DMG, dmg_base + bonus_cap)
		--self.CL_MAX_SHIELD = math.min(self.CL_MAX_SHIELD, shield_base + bonus_cap)
	end

	--shieldstuff
	function modifier:OnTakeDamage(keys)
		local parent = self:GetParent()
		local ability = self:GetAbility()
		if keys.unit == parent and self.CL_SHIELDLEFT ~= 0 then -- and parent:IsAlive() then -- cant be used here or shield wont save you when blow is higher than current hp
			local hp_current = parent:GetHealth()
			local damage = keys.damage
			self.CL_SHIELDLEFT = self.CL_SHIELDLEFT - damage
			if self.CL_SHIELDLEFT  <= 0 then
				if not (hp_current + self.CL_SHIELDLEFT <= 0) then
					if not parent.InstantCurseAcquired then
						parent:RemoveModifierByName("modifier_cursed_lance")
					end
					parent:SetHealth(hp_current + self.CL_SHIELDLEFT + damage)
					self.CL_SHIELDLEFT = 0
				end
			else
				parent:SetHealth(hp_current + damage)
			end
		end
	end

	--explosion
	function modifier:OnRemoved()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local aoe = ability:GetSpecialValueFor("aoe")
		local dmg = ((self.CL_MAX_SHIELD - math.max(self.CL_SHIELDLEFT or 0,0))/self.CL_MAX_SHIELD)*(self.CL_MAX_DMG)
		if dmg > 0 then
			self:VFX2_PreExplosion(parent)
			Timers:CreateTimer(0.3, function()
				self:VFX3_Explosion(parent)
				parent:EmitSound("Hero_Abaddon.AphoticShield.Destroy")
				parent:EmitSound("Hero_Abaddon.AphoticShield.Destroy")
				Timers:CreateTimer(0.15, function()
					local targets = FindUnitsInRadius(parent:GetTeam(), parent:GetOrigin(), nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
					for k,v in pairs(targets) do
				  	DoDamage(parent, v, dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
					end
				end)
			end)
		end
	end
	--counter and other particles
	function modifier:OnIntervalThink()
		if self.__cl_prev_amount ~= self.CL_SHIELDLEFT  then
			local parent = self:GetParent()
			self:VFX0_Counter(parent)
			self.__cl_prev_amount = self.CL_SHIELDLEFT
			if self.PI5 == nil and self.CL_SHIELDLEFT == 0 then --if shield is depleted
				FxDestroyer(self.PI2,false) --destroy half of shield
				self:VFX4_AOEIndicator(parent)
			end
		end
		self:VFX5_ExpiringIndicator()
	end

	function modifier:IsHidden()
	  return false
	end

	function modifier:IsDebuff()
	  return false
	end

	function modifier:RemoveOnDeath()
	  return true
	end
end

cl_wrapper(modifier_cursed_lance)

