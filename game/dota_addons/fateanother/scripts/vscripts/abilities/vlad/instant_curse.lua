vlad_instant_curse = class({})

if not IsServer() then
  return
end

function vlad_instant_curse:OnSpellStart()
  local caster = self:GetCaster()
  if caster.InstantSwapTimer then
  	caster:RemoveModifierByName("modifier_cursed_lance")
  	Timers:RemoveTimer(caster.InstantSwapTimer)
    caster.InstantSwapTimer = nil
    caster:SwapAbilities("vlad_cursed_lance", "vlad_instant_curse", true, false)
  end
end

function vlad_instant_curse:GetCastAnimation()
  return nil
end

function vlad_instant_curse:GetTexture()
  return "shadow_demon_disruption"
end
