modifier_protection_of_faith = class({})

function modifier_protection_of_faith:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_protection_of_faith:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_TAKEDAMAGE,
    MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
  }
  return funcs
end

function modifier_protection_of_faith:GetModifierMoveSpeedBonus_Constant()
  return self:GetAbility():GetSpecialValueFor("bonus_ms")
end

if IsServer() then
  function modifier_protection_of_faith:OnTakeDamage(keys)
    local parent = self:GetParent()
    local ability = self:GetAbility()
    if keys.unit == parent
      and parent:IsAlive()
      and parent:FindAbilityByName("vlad_protection_of_faith_cd"):IsCooldownReady()
      and parent:GetHealth() <= ability:GetSpecialValueFor("pof_condition")
    then
      local cd = ability:GetSpecialValueFor("pof_cd")
      parent:FindAbilityByName("vlad_protection_of_faith_cd"):StartCooldown(cd)
  		parent:AddNewModifier(parent,ability,"modifier_protection_of_faith_proc",{duration = ability:GetSpecialValueFor("pof_duration")})
      parent:AddNewModifier(parent,ability,"modifier_protection_of_faith_proc_cd",{duration = cd} )
      parent:EmitSound("DOTA_Item.BlackKingBar.Activate")
      local PI1 = ParticleManager:CreateParticle("particles/items_fx/black_king_bar_avatar.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
      Timers:CreateTimer(2.25, function()
        FxDestroyer(PI1, false)
      end)
  	end
  end
end

function modifier_protection_of_faith:IsHidden()
  return true
end

function modifier_protection_of_faith:IsDebuff()
  return false
end

function modifier_protection_of_faith:RemoveOnDeath()
  return false
end
