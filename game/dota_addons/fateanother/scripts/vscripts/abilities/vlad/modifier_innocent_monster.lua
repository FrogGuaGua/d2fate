modifier_innocent_monster = class({})

function modifier_innocent_monster:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_innocent_monster:DeclareFunctions()
  local funcs = {
  MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
  MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
  MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
  MODIFIER_EVENT_ON_ATTACK_LANDED
  }
  return funcs
end

function modifier_innocent_monster:GetModifierMagicalResistanceBonus()
  return self:GetAbility():GetSpecialValueFor("bonus_mres")
end

function modifier_innocent_monster:GetModifierAttackSpeedBonus_Constant()
  local hp_percentage = self:GetParent():GetHealthPercent()
  local bonus_as_per_1 = self:GetAbility():GetSpecialValueFor("bonus_as_per_1")
  return (100-hp_percentage)*bonus_as_per_1
end

function modifier_innocent_monster:GetModifierConstantHealthRegen()
  local hp_percentage = self:GetParent():GetHealthPercent()
  local bonus_hp_regen_per_1 = self:GetAbility():GetSpecialValueFor("bonus_hp_regen_per_1")
  return (100-hp_percentage)*bonus_hp_regen_per_1
end

if IsServer() then
  function modifier_innocent_monster:OnAttackLanded(keys)
    local parent = self:GetParent()
	  local ability = self:GetAbility()
  	local target = keys.target
    local damage = keys.damage
    local damage_splash = damage*ability:GetSpecialValueFor("splash_percentage")
    local splash_aoe = ability:GetSpecialValueFor("splash_aoe")
    local lifesteal = ability:GetSpecialValueFor("lifesteal")

	  if target == parent:GetAttackTarget() and parent:IsAlive() then
      local PI1 = FxCreator("particles/custom/vlad/vlad_im_splash_blood.vpcf",PATTACH_ABSORIGIN,target,0,nil)
      local targets_splash = FindUnitsInRadius(parent:GetTeamNumber(), target:GetAbsOrigin(), nil, splash_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	    parent:AddBleedStack(target,true)
      parent:ApplyHeal(damage*lifesteal,parent)
      Timers:CreateTimer(1,function()
        FxDestroyer(PI1, false)
      end)
      for k,v in pairs(targets_splash) do
        if v ~= target and v:IsRealHero() then
          parent:ApplyHeal(damage_splash*lifesteal,parent)
          DoDamage(parent, v, damage_splash, DAMAGE_TYPE_MAGICAL, 0, ability, false)
          parent:AddBleedStack(v,true)
        end
      end
    end
  end
end


function modifier_innocent_monster:IsHidden()
  return false
end

function modifier_innocent_monster:IsDebuff()
  return false
end

function modifier_innocent_monster:RemoveOnDeath()
  return false
end
