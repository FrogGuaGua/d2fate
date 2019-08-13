modifier_rebellious_intent = class({})

function modifier_rebellious_intent:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_rebellious_intent:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    MODIFIER_EVENT_ON_RESPAWN,
  }
  return funcs
end
function modifier_rebellious_intent:GetModifierBonusStats_Strength()
  return self:GetStackCount()*self:GetAbility():GetSpecialValueFor("str_per_stack")
end
function modifier_rebellious_intent:GetModifierMoveSpeedBonus_Percentage()
  return self:GetStackCount()*self:GetAbility():GetSpecialValueFor("self_slow_per_stack")
end
function modifier_rebellious_intent:GetModifierPhysicalArmorBonus()
  return self:GetStackCount()*self:GetAbility():GetSpecialValueFor("armor_per_stack")
end
function modifier_rebellious_intent:GetModifierMagicalResistanceBonus()
  return self:GetStackCount()*self:GetAbility():GetSpecialValueFor("mres_per_stack")
end

if IsServer() then
  function modifier_rebellious_intent:OnCreated()
    local parent = self:GetParent()
    self.HP_PER_STR_FATE = parent.HP_PER_STR
    local ability = self:GetAbility()
    local total_count_of_ticks = ability:GetSpecialValueFor("stacks_total")
    self.PI1 = FxCreator("particles/custom/vlad/vlad_ri_active.vpcf",PATTACH_ABSORIGIN_FOLLOW,parent,0,nil)

    --gain stacks of stat bonuses every interval tick
    self.current_tick = 0
    Timers:CreateTimer(function()
      if not self:IsNull() and parent:IsAlive() then
        if self.current_tick < total_count_of_ticks then
          self:IncrementStackCount()
          parent:CalculateStatBonus()
          self.current_tick = self.current_tick + 1
          return ability:GetSpecialValueFor("stacks_interval")
        else
          self:StartIntervalThink(ability:GetSpecialValueFor("drain_interval")) --drain starts after reaching max stacks
          return nil
        end
      end
    end)
  end

  --increase current HP by the amount maximum	HP was increased for gained STR
  function modifier_rebellious_intent:OnStackCountChanged(iStackCount)
    local ability = self:GetAbility()
    local parent = self:GetParent()
    if parent:IsAlive() and self.HP_PER_STR_FATE then
      local current_hp = parent:GetHealth()
      local max_hp = parent:GetMaxHealth()
      local str_per_stack = ability:GetSpecialValueFor("str_per_stack")
      local difference_to_heal = ((current_hp + self.HP_PER_STR_FATE*str_per_stack) / (max_hp + self.HP_PER_STR_FATE*str_per_stack)) * max_hp - current_hp
      parent:ApplyHeal(difference_to_heal,parent)
    end
  end

  --remove current hp gained per every STR stack already gained
  function modifier_rebellious_intent:OnRemoved()
    local parent = self:GetParent()
    if parent:IsAlive() and self.HP_PER_STR_FATE then 
      local ability = self:GetAbility()
      local str_per_stack = ability:GetSpecialValueFor("str_per_stack")
      for i=1, self:GetStackCount(), 1 do
        local current_hp = parent:GetHealth()
        local max_hp = parent:GetMaxHealth()
        local difference_to_subtract = ((current_hp + self.HP_PER_STR_FATE*str_per_stack) / (max_hp + self.HP_PER_STR_FATE*str_per_stack)) * max_hp - current_hp
        local new_hp = current_hp - difference_to_subtract
        if new_hp < 1 then
          new_hp = 1
        end
        parent:SetHealth(new_hp)
      end
    end
  end

  --drains current HP by percentile of max HP while active, after reached max stacks
  function modifier_rebellious_intent:OnIntervalThink()
    local parent = self:GetParent()
    if parent:IsAlive() then
      local ability = self:GetAbility()
      local drain_per_sec = ability:GetSpecialValueFor("drain_per_sec")
      local drain_interval = ability:GetSpecialValueFor("drain_interval")
      local new_hp = parent:GetHealth() - (drain_per_sec * parent:GetMaxHealth() * drain_interval)

    	if new_hp < 1 then
    		new_hp = 1
    	end
      parent:SetHealth(new_hp)
    end
  end

  function modifier_rebellious_intent:OnDestroy()
    self:StartIntervalThink(-1)
    FxDestroyer(self.PI1, false)
  end
  function modifier_rebellious_intent:OnRespawn()
    self:Destroy()
  end
end

function modifier_rebellious_intent:IsHidden()
  return false
end

function modifier_rebellious_intent:IsDebuff()
  return false
end

function modifier_rebellious_intent:RemoveOnDeath()
  return true
end
