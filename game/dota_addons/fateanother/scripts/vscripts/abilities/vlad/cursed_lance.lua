vlad_cursed_lance = class({})
LinkLuaModifier("modifier_cursed_lance", "abilities/vlad/modifier_cursed_lance", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_e_used", "abilities/vlad/modifier_e_used", LUA_MODIFIER_MOTION_NONE)

if not IsServer() then
  return
end
--combo timer ability swap
function vlad_cursed_lance:ComboCheck(caster)
	if caster:GetStrength() >= 19.1
    and caster:GetAgility() >= 19.1
    and caster:GetIntellect() >= 19.1
    and caster:HasModifier("modifier_q_used")
		and caster:HasModifier("modifier_e_used")
    and caster:FindAbilityByName("vlad_combo"):IsCooldownReady()
  then
    local modifier = caster:FindModifierByName("modifier_q_used")
		local timeLeft = modifier:GetRemainingTime()
    if not caster.ComboTimer then
      caster:SwapAbilities("vlad_ceremonial_purge", "vlad_combo", false, true)
      caster.ComboTimer = Timers:CreateTimer(timeLeft, function()
        caster.ComboTimer = nil
        caster:SwapAbilities("vlad_ceremonial_purge", "vlad_combo", true, false)
      end)
    else
      Timers:RemoveTimer(caster.ComboTimer)
      caster.ComboTimer = Timers:CreateTimer(timeLeft, function()
        caster.ComboTimer = nil
        caster:SwapAbilities("vlad_ceremonial_purge", "vlad_combo", true, false)
      end)
    end
  end
end

--instant curse ability swap
function vlad_cursed_lance:InstantCurseSwap(caster,duration)
  if caster.InstantCurseAcquired then
  	if not caster.InstantSwapTimer then
  		caster:FindAbilityByName("vlad_instant_curse"):StartCooldown(0.75) --QOL upgrade to allow mashing shield lul
      caster:SwapAbilities("vlad_cursed_lance", "vlad_instant_curse", false, true)
      caster.InstantSwapTimer = Timers:CreateTimer(duration, function()
        caster.InstantSwapTimer = nil
        caster:SwapAbilities("vlad_cursed_lance", "vlad_instant_curse", true, false)
  		end)
    else
      Timers:RemoveTimer(caster.InstantSwapTimer)
        caster.InstantSwapTimer = Timers:CreateTimer(duration, function()
        caster.InstantSwapTimer = nil
        caster:SwapAbilities("vlad_cursed_lance", "vlad_instant_curse", true, false)
      end)
    end
  end
end

--resyncs shieldleft after lvlup while shield is active, so that dmg doesnt go into negatives
function vlad_cursed_lance:OnUpgrade()
	if self:GetCaster():HasModifier("modifier_cursed_lance") then
    local oldmaxshield = self:GetLevelSpecialValueFor("max_shield",self:GetLevel()-2)
		local newmaxshield = self:GetLevelSpecialValueFor("max_shield",self:GetLevel()-1)
		local percentage = self.modifier.CL_SHIELDLEFT/oldmaxshield
		self.modifier.CL_SHIELDLEFT = newmaxshield*percentage
		self.modifier:UpdateModVars()
  end
end

function vlad_cursed_lance:OnSpellStart()
  local caster = self:GetCaster()
  local duration = self:GetSpecialValueFor("duration")
  local hp_cost = self:GetSpecialValueFor("hp_cost")

	local hp_current = caster:GetHealth()
	local hp_max = caster:GetMaxHealth()
	hp_current = hp_current - (hp_max * hp_cost)

	if hp_current > 1 then
		caster:SetHealth(hp_current)
	else
		caster:SetHealth(1)
	end

	if caster:HasModifier( "modifier_q_used" ) then
	   caster:AddNewModifier(caster, self, "modifier_e_used",{duration = 5})
	end

  self.modifier = caster:AddNewModifier(caster, self, "modifier_cursed_lance",{duration = duration})

	self:ComboCheck(caster)
	self:InstantCurseSwap(caster,duration)
end

function vlad_cursed_lance:GetCastAnimation()
  return ACT_DOTA_CAST_ABILITY_3
end

function vlad_cursed_lance:GetTexture()
  return "custom/vlad_cursed_lance"
end
