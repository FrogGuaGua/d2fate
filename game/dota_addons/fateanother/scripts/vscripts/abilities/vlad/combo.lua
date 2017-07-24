vlad_combo = class({})
--LinkLuaModifier("modifier_battle_continuation", "abilities/vlad/modifier_battle_continuation", LUA_MODIFIER_MOTION_NONE)

if not IsServer() then
  return
end

function vlad_combo:VFX1_SpikesField(caster)
	self.PI1 = FxCreator("particles/custom/vlad/vlad_combo_aoe.vpcf",PATTACH_ABSORIGIN,caster,0,nil)
	ParticleManager:SetParticleControlEnt( self.PI1,1 , caster,  PATTACH_ABSORIGIN, nil, caster:GetAbsOrigin(), false )
end

function vlad_combo:VFX2_OnTargetAssRavage(k,target)
	self.PI2[k] = FxCreator("particles/custom/vlad/vlad_combo_ontarget_stun.vpcf",PATTACH_ABSORIGIN,target,0,nil)
end

function vlad_combo:VFX3_OnTargetExecute(k,target)
	self.PI3[k] = FxCreator("particles/custom/vlad/vlad_combo_ontarget_execute.vpcf",PATTACH_ABSORIGIN_FOLLOW,target,0,nil)
	ParticleManager:SetParticleControlEnt( self.PI3[k], 1, target,  PATTACH_ABSORIGIN_FOLLOW, nil, target:GetAbsOrigin(), false )
	ParticleManager:SetParticleControlEnt( self.PI3[k], 5, target,  PATTACH_CENTER_FOLLOW, nil, target:GetAbsOrigin(), false )
end

function vlad_combo:OnSpellStart()
  local caster = self:GetCaster()
	local aoe = self:GetSpecialValueFor("aoe")
	local dmg = self:GetSpecialValueFor("dmg")
	local heal = self:GetSpecialValueFor("heal")
	local penalty = self:GetSpecialValueFor("penalty")
	local stun = self:GetSpecialValueFor("stun")

	if caster.ComboTimer then
		Timers:RemoveTimer(caster.ComboTimer)
		caster.ComboTimer = nil
		caster:SwapAbilities("vlad_ceremonial_purge", "vlad_combo", true, false)
	end

	self.PI2 = {}
	self.PI3 = {}
	giveUnitDataDrivenModifier(caster, caster, "silenced", penalty)
	EmitGlobalSound("Vlad.Combo")
	Timers:CreateTimer(0.15, function()
		self:VFX1_SpikesField(caster)
		local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
			giveUnitDataDrivenModifier(caster, v, "stunned", stun)
			self:VFX2_OnTargetAssRavage(k,v)
			ApplyAirborneOnly(v, 2000, 0.2, 1500)
			caster:EmitSound("Hero_PhantomAssassin.Attack")
			Timers:CreateTimer(0.1,function()
				caster:EmitSound("Hero_NyxAssassin.SpikedCarapace")
			end)
    end
		Timers:CreateTimer(2.5, function()
			if #targets ~= 0 then
				caster:EmitSound("Hero_PhantomAssassin.CoupDeGrace")
			end
			caster:EmitSound("Hero_OgreMagi.Bloodlust.Cast")
			caster:EmitSound("Hero_Lycan.Attack")
			Timers:CreateTimer(0.1,function()
				caster:EmitSound("Hero_NyxAssassin.SpikedCarapace")
			end)
			FxDestroyer(self.PI1, false)
			for k,v in pairs(targets) do
				caster:Heal(heal,caster)
				self:VFX3_OnTargetExecute(k,v)
				v:SetAbsOrigin(GetGroundPosition(v:GetAbsOrigin(),v))
				DoDamage(caster, v, 100, DAMAGE_TYPE_MAGICAL, 0, self, false)
			end
		end)
		Timers:CreateTimer(3,function()
			for k,v in pairs(targets) do
			end
			FxDestroyer(self.PI2, false)
			FxDestroyer(self.PI3, false)
		end)
	end)
end
function vlad_combo:GetAbilityTextureName()
  return "custom/vlad_combo"
end
