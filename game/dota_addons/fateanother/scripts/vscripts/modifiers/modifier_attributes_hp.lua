modifier_attributes_hp = class({})


function modifier_attributes_hp:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_attributes_hp:DeclareFunctions()
  local funcs = {
  MODIFIER_PROPERTY_HEALTH_BONUS,
  }
  return funcs
end

function modifier_attributes_hp:GetModifierHealthBonus()
--strength * Attributes.hp_adjustment
  if IsServer() then
    local parent = self:GetParent()
    self:SetStackCount(parent:GetStrength()*parent.hp_adjustment)
  end
  return self:GetStackCount()
end


function modifier_attributes_hp:IsHidden()
  return true
end

function modifier_attributes_hp:IsDebuff()
  return false
end

function modifier_attributes_hp:RemoveOnDeath()
  return false
end
