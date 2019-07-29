modifier_celestial_arrow_onhit = class({})

function modifier_celestial_arrow_onhit:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_CASTTIME_PERCENTAGE,
    MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
  }

  return funcs
end
function modifier_celestial_arrow_onhit:OnCreated()
  self.kval = self:GetAbility():GetSpecialValueFor("agility_per_stack")
end
function modifier_celestial_arrow_onhit:GetModifierPercentageCasttime() 
  return self:GetStackCount() * self.kval
end
function modifier_celestial_arrow_onhit:GetModifierBonusStats_Agility()
  return self:GetStackCount() * self.kval
end
function modifier_celestial_arrow_onhit:GetAttributes() 
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_celestial_arrow_onhit:IsHidden()
  return false
end

function modifier_celestial_arrow_onhit:IsDebuff()
  return false
end

function modifier_celestial_arrow_onhit:RemoveOnDeath()
  return false
end