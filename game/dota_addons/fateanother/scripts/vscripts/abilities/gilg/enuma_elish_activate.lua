gilgamesh_enuma_elish_activate = class({})

if not IsServer() then
  return
end

function gilgamesh_enuma_elish_activate:CastFilterResult()
  local caster = self:GetCaster()

  local ability = caster:FindAbilityByName("gilgamesh_enuma_elish")

  --print(GameRules:GetGameTime()-ability:GetChannelStartTime())
  if GameRules:GetGameTime()-ability:GetChannelStartTime() < ability:GetSpecialValueFor("activation") then
    return UF_FAIL_CUSTOM
  end
  return UF_SUCCESS
end

function gilgamesh_enuma_elish_activate:GetCustomCastError()
  return "Not Charged!"
end

function gilgamesh_enuma_elish_activate:OnSpellStart()

end

function gilgamesh_enuma_elish_activate:GetCastAnimation()
  return nil
end

function gilgamesh_enuma_elish_activate:GetAbilityTextureName()
  return "custom/gilgamesh_enuma_elish"
end
