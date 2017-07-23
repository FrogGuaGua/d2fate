vlad_passive_rending = class({})
LinkLuaModifier("modifier_rending", "abilities/vlad/modifier_rending", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bleed", "abilities/vlad/modifier_bleed", LUA_MODIFIER_MOTION_NONE)

if not IsServer() then
	return
end

function vlad_passive_rending:OnUpgrade()
	local caster = self:GetCaster()
  local ability = self
	if IsServer() and not caster.AddBleedStack then
		function caster:AddBleedStack(...)
			ability:AddStack(...)
		end
	end
	if IsServer() and not caster.GetGlobalBleeds then
		function caster:GetGlobalBleeds(...)
			return ability:BleedSeek(...)
		end
	end
end

function vlad_passive_rending:BleedSeek()
	local caster = self:GetCaster()
	local bleedcounter = 0
	LoopOverPlayers(function(player, playerID, playerHero)
    if playerHero:GetTeamNumber() ~= caster:GetTeamNumber() then
			local modbleed = playerHero:FindModifierByName("modifier_bleed") or nil
			if modbleed ~= nil then
				bleedcounter = bleedcounter + modbleed:GetStackCount()
			end
    end
  end)
	return bleedcounter
end

function vlad_passive_rending:AddStack(target,count,isMelee)
	if target:IsRealHero() then 
		local caster = self:GetCaster()
	  local modifier = target:FindModifierByName("modifier_bleed")
	  local currentStack = modifier and modifier:GetStackCount() or 0
		if isMelee == true and caster:HasModifier("modifier_rebellious_intent") then
			count = count*2
		end
	  target:RemoveModifierByName("modifier_bleed")
	  target:AddNewModifier(caster, self, "modifier_bleed", {duration = self:GetSpecialValueFor("duration")})
	  target:SetModifierStackCount("modifier_bleed", self, currentStack + count)
	end
end

function vlad_passive_rending:GetIntrinsicModifierName()
  return "modifier_rending"
end
