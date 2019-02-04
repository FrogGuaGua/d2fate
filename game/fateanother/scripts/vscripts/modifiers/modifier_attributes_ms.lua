modifier_attributes_ms = class({})


function modifier_attributes_ms:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_attributes_ms:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
  }
  return funcs
end


function modifier_attributes_ms:GetModifierMoveSpeedOverride()
--hero.BaseMS + agility * Attributes.ms_adjustment + hero.MSgained * Attributes.additional_movespeed_adjustment
  if IsServer() then
    local parent = self:GetParent()
    self:SetStackCount(parent.BaseMS + parent:GetAgility()*parent.ms_adjustment + parent.MSgained * parent.additional_movespeed_adjustment)
  end
  return self:GetStackCount()
end


function modifier_attributes_ms:IsHidden()
  return true
end

function modifier_attributes_ms:IsDebuff()
  return false
end

function modifier_attributes_ms:RemoveOnDeath()
  return false
end
