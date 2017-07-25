vlad_instant_curse = class({})

if not IsServer() then
  return
end

function vlad_instant_curse:OnSpellStart()
  local caster = self:GetCaster()
  if caster.InstantSwapTimer then
  	caster:RemoveModifierByName("modifier_cursed_lance")
    caster:RemoveModifierByName("modifier_cursed_lance_bp")
  end
end

function vlad_instant_curse:GetCastAnimation()
  return nil
end

function vlad_instant_curse:GetAbilityTextureName()
  return "shadow_demon_disruption"
end
