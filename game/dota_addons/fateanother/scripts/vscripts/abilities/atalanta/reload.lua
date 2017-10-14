atalanta_reload = class({})

function atalanta_reload:GetChannelTime()
  return self:GetSpecialValueFor("channel_duration")
end

if IsClient() then
  return 
end

function atalanta_reload:OnSpellStart()
  local hCaster = self:GetCaster()
  self.fTickCounter = 0.0
  self.hModifier = hCaster:FindModifierByName("modifier_priestess_of_the_hunt")  
  self.iMaxArrows = self.hModifier:GetMaxStackCount()
  self.fTimerInterval = self:GetChannelTime() / self.iMaxArrows
  StartAnimation(hCaster, {duration=3, activity=ACT_DOTA_CAST_ABILITY_3, rate=0.3})
  hCaster:CloseTraps(self)
end
  
function atalanta_reload:OnChannelThink(fInterval)
	self.fTickCounter = self.fTickCounter + fInterval
	if self.fTickCounter >= self.fTimerInterval then
		self.fTickCounter = self.fTickCounter - self.fTimerInterval
    if self.hModifier:GetStackCount() < self.iMaxArrows then
      self:GetCaster():AddArrows(1)
      if self.hModifier:GetStackCount() == self.iMaxArrows then
        self:EndChannel(true)
      end
	  end
  end
end

function atalanta_reload:OnChannelFinish(bInterrupted)
  local hCaster = self:GetCaster()
  if not bInterrupted and self.hModifier:GetStackCount() < self.iMaxArrows then
    hCaster:AddArrows(1)
  end
  hCaster:CapArrows()
  EndAnimation(hCaster)
end

function atalanta_reload:GetCastAnimation()
  return nil
end