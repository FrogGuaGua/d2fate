modifier_attributes_mp_regen = class({})


function modifier_attributes_mp_regen:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_attributes_mp_regen:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
  }
  return funcs
end


function modifier_attributes_mp_regen:GetModifierConstantManaRegen()
--math.abs(intellect * Attributes.mana_regen_adjustment * 100)
  if IsServer() then
    local parent = self:GetParent()
    self:SetStackCount(math.abs(parent:GetIntellect()*parent.mana_regen_adjustment*100))
  end
  return self:GetStackCount()/100
end


function modifier_attributes_mp_regen:IsHidden()
  return true
end

function modifier_attributes_mp_regen:IsDebuff()
  return false
end

function modifier_attributes_mp_regen:RemoveOnDeath()
  return false
end
