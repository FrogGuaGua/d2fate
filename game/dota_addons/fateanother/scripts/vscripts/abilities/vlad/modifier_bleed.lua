modifier_bleed = class({})

function modifier_bleed:DeclareFunctions()
  local funcs = {
  MODIFIER_EVENT_ON_RESPAWN
  }
  return funcs
end

if IsServer() then
  function modifier_bleed:OnCreated()
    self.redraw = false
    self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("interval"))
    local parent = self:GetParent()
    local caster = self:GetCaster()

    --  this stuff is to fix a counter to be redrawing without deleting previous(dirty copying) when enemy bleeding leaves and then enters the vision of vlad
    Timers:CreateTimer(function()
      if not self:IsNull() then
        if not caster:CanEntityBeSeenByMyTeam(parent) then
          self.redraw = true
        elseif caster:CanEntityBeSeenByMyTeam(parent) and self.redraw then
          self:OnStackCountChanged()
          self.redraw = false
        end
        return 0.05
      else
        return nil
      end
    end)
  end


  function modifier_bleed:OnStackCountChanged(iStackCount)
    local parent = self:GetParent()
    local caster = self:GetCaster()
    local counter = self:GetStackCount()
    local digit = 0
    if counter > 99 then
      digit = 3
    elseif counter > 9 then
      digit = 2
    else
      digit = 1
    end

    self.PI0 = FxDestroyer(self.PI0, true)

    self.PI0 = ParticleManager:CreateParticleForPlayer( "particles/custom/vlad/vlad_cl_popup.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent, caster:GetPlayerOwner() )
    ParticleManager:SetParticleControlEnt( self.PI0, 0, parent,  PATTACH_ABSORIGIN_FOLLOW, nil, parent:GetAbsOrigin(), false )
    ParticleManager:SetParticleControl( self.PI0, 1, Vector( 0, counter, 0 ) ) -- 0,counter,0
    ParticleManager:SetParticleControl( self.PI0, 2, Vector( 30, digit, 0 ) ) --duration, count of digits to draw, 0
    ParticleManager:SetParticleControl( self.PI0, 3, Vector( 252, 75, 75 ) ) --color
    ParticleManager:SetParticleControl( self.PI0, 4, Vector( 23,0,0) ) --size/radius, 0 ,0
  end

  function modifier_bleed:OnIntervalThink()
    local ability = self:GetAbility()
    local dmg = ability:GetSpecialValueFor("dmg")*self:GetStackCount()
    DoDamage(self:GetCaster(), self:GetParent(), dmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
  end

  function modifier_bleed:OnDestroy()
    self:StartIntervalThink(-1)
    self.PI0 = FxDestroyer(self.PI0, true)
  end
  function modifier_bleed:OnRespawn()
    self:Destroy()
  end
end

function modifier_bleed:IsHidden()
  return false
end

function modifier_bleed:IsDebuff()
  return true
end

function modifier_bleed:RemoveOnDeath()
  return true
end

function modifier_bleed:GetTexture()
  return "custom/vlad_transfusion2"
end
