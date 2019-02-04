modifier_transfusion_target = class({})

function modifier_transfusion_target:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_transfusion_target:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
  }
  return funcs
end

function modifier_transfusion_target:GetModifierMoveSpeedBonus_Percentage()
  return self:GetStackCount()*self:GetAbility():GetSpecialValueFor("slow_per_stack")
end

if IsServer() then
  function modifier_transfusion_target:OnCreated()
    local parent = self:GetParent()
  	local ability = self:GetAbility()
  	local modbleed = parent:FindModifierByName("modifier_bleed") or nil
  	if modbleed ~= nil then
    	local count = modbleed:GetStackCount()
      self:SetStackCount(count)
    else
      self:Destroy()
    end
  end

  function modifier_transfusion_target:OnRefresh()
    self:OnCreated()
  end
end

function modifier_transfusion_target:IsHidden()
  return false
end

function modifier_transfusion_target:IsDebuff()
  return true
end

function modifier_transfusion_target:RemoveOnDeath()
  return true
end
