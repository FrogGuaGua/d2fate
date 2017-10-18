modifier_celestial_arrow_onhit = class({})

function modifier_celestial_arrow_onhit:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_CASTTIME_PERCENTAGE,
    MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
  }

  return funcs
end
function modifier_celestial_arrow_onhit:OnCreated(args)
  self.fAgilityPerStack = args.fAgility
  self.fCastTimeReductionPerStack = args.fCastTimeReduction
end
function modifier_celestial_arrow_onhit:GetModifierPercentageCasttime() 
  return self:GetStackCount() * self.fCastTimeReductionPerStack
end
function modifier_celestial_arrow_onhit:GetModifierBonusStats_Agility()
  return self:GetStackCount() * self.fAgilityPerStack
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