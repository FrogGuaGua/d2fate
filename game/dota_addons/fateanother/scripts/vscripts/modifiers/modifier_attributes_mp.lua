modifier_attributes_mp = class({})


function modifier_attributes_mp:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_attributes_mp:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_MANA_BONUS,
  }
  return funcs
end


function modifier_attributes_mp:GetModifierManaBonus()
--math.abs(intellect * Attributes.mana_adjustment)
  if IsServer() then
    local parent = self:GetParent()
    self:SetStackCount(math.abs(parent:GetIntellect()*parent.mana_adjustment))
  end
  return self:GetStackCount()
end


function modifier_attributes_mp:IsHidden()
  return true
end

function modifier_attributes_mp:IsDebuff()
  return false
end

function modifier_attributes_mp:RemoveOnDeath()
  return false
end
