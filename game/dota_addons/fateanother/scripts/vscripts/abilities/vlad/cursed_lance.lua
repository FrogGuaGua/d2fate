vlad_cursed_lance = class({})
LinkLuaModifier("modifier_cursed_lance", "abilities/vlad/modifier_cursed_lance", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_cursed_lance_bp", "abilities/vlad/modifier_cursed_lance_bp", LUA_MODIFIER_MOTION_NONE)
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
--bonuses from bloodpower to max_shield and max_dmg are carried over in flat form to new shield values after upgrade while shield is present
--after upgrade shield_max to shieldleft ratio stays 1-1, while shield_dmg to shieldleft ratio is slightly reduced
function vlad_cursed_lance:OnUpgrade()
	if self:GetCaster():HasModifier("modifier_cursed_lance") then
    local oldmaxshield = self.modifier.CL_MAX_SHIELD
    --print("oldmaxshieldreal ", oldmaxshield, "max lvl ", self:GetLevelSpecialValueFor("max_shield",self:GetLevel()-2))
    local bonus_shield = oldmaxshield - self:GetLevelSpecialValueFor("max_shield",self:GetLevel()-2)
		local newmaxshield = self:GetLevelSpecialValueFor("max_shield",self:GetLevel()-1) + bonus_shield
    --print("newmaxshieldreal ", newmaxshield)
    local percentage = self.modifier.CL_SHIELDLEFT/oldmaxshield
		self.modifier.CL_SHIELDLEFT = newmaxshield*percentage

    local oldmaxdmg = self.modifier.CL_MAX_DMG
    --print("oldmaxdmgreal ", oldmaxdmg, "max real ", self:GetLevelSpecialValueFor("max_dmg",self:GetLevel()-2))
    local bonus_dmg = oldmaxdmg - self:GetLevelSpecialValueFor("max_dmg",self:GetLevel()-2)
    local newmaxdmg = self:GetLevelSpecialValueFor("max_dmg",self:GetLevel()-1) + bonus_dmg
    --print("newmaxdmgreal ", newmaxdmg)
    self.modifier:UpdateModVars(newmaxshield,newmaxdmg)
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

  if caster:HasModifier("modifier_transfusion_bloodpower") and caster.InstantCurseAcquired then
    self.modifier = caster:AddNewModifier(caster, self, "modifier_cursed_lance_bp",{duration = duration})
  else
    self.modifier = caster:AddNewModifier(caster, self, "modifier_cursed_lance",{duration = duration})
  end

	self:ComboCheck(caster)
	self:InstantCurseSwap(caster,duration)
end

function vlad_cursed_lance:GetCastAnimation()
  return ACT_DOTA_CAST_ABILITY_3
end

function vlad_cursed_lance:GetAbilityTextureName()
  return "custom/vlad_cursed_lance"
end
