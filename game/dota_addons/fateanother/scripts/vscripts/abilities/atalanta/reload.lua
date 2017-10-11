atalanta_reload = class({})

function atalanta_reload:GetChannelTime()
  return self:GetSpecialValueFor("channel_duration")
end

if IsClient() then
  return 
end

function atalanta_reload:OnSpellStart()
  local hCaster = self:GetCaster()
  self.fTimerCurrent = 0.0
  self.hModifier = hCaster:FindModifierByName("modifier_priestess_of_the_hunt")  
  self.iMaxArrows = self.hModifier:GetMaxStackCount()
  self.fTimerInterval = self:GetChannelTime() / self.iMaxArrows
end
  
function atalanta_reload:OnChannelThink(fInterval)
	self.fTimerCurrent = self.fTimerCurrent + fInterval
	if self.fTimerCurrent >= self.fTimerInterval then
		self.fTimerCurrent = self.fTimerCurrent - self.fTimerInterval
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
end
