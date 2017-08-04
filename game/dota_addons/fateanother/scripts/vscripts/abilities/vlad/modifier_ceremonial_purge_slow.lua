modifier_ceremonial_purge_slow = class({})

function modifier_ceremonial_purge_slow:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    --MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
  }
  return funcs
end

function modifier_ceremonial_purge_slow:GetModifierMoveSpeedBonus_Percentage()
  return self:GetStackCount()*self:GetAbility():GetSpecialValueFor("slow_per_stack")
end

if IsServer() then
  function modifier_ceremonial_purge_slow:OnCreated()
    local parent = self:GetParent()
  	local ability = self:GetAbility()
  	local modbleed = parent:FindModifierByName("modifier_bleed") or nil
  	if modbleed ~= nil then
    	local count = modbleed:GetStackCount()
      self:SetStackCount(count)
      parent:EmitSound("Hero_LifeStealer.OpenWounds.Cast")
      local PI1 = FxCreator("particles/units/heroes/hero_life_stealer/life_stealer_open_wounds.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent, 0, nil)
      Timers:CreateTimer((ability:GetSpecialValueFor("stun_outer"))*2, function() -- start slow fading after double duration of stun
        if not self:IsNull() then
          self:StartIntervalThink(1)
          FxDestroyer(PI1, false)
        end
      end)
    else
      self:Destroy()
    end
  end

  function modifier_ceremonial_purge_slow:OnIntervalThink()
    local count = self:GetStackCount()
    if count > 10 then
      self:SetStackCount(math.max(math.floor(count/2),6))
    elseif count > 5 then
      self:SetStackCount(count-3)
    else
      self:DecrementStackCount()
    end
    if self:GetStackCount() <= 0 then
      self:Destroy()
    end
  end

  function modifier_ceremonial_purge_slow:OnRefresh()
    self:OnDestroy()
    self:OnCreated()
  end
  function modifier_ceremonial_purge_slow:OnDestroy()
    self:StartIntervalThink(-1)
  end
end

function modifier_ceremonial_purge_slow:IsHidden()
  return false
end

function modifier_ceremonial_purge_slow:IsDebuff()
  return true
end

function modifier_ceremonial_purge_slow:RemoveOnDeath()
  return true
end
