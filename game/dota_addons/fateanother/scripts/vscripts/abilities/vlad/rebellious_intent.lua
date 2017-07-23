vlad_rebellious_intent = class({})
LinkLuaModifier("modifier_rebellious_intent", "abilities/vlad/modifier_rebellious_intent", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_q_used", "abilities/vlad/modifier_q_used", LUA_MODIFIER_MOTION_NONE)

if not IsServer() then
  return
end

function vlad_rebellious_intent:OnToggle()
  local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_q_used",{duration = 5}) -- both toggle and untoggle count toward combo

	if not self:GetToggleState() and caster:HasModifier("modifier_rebellious_intent") then
		caster:EmitSound("Hero_PhantomLancer.Concord.Impact")
		caster:RemoveModifierByName("modifier_rebellious_intent")
	else
    caster:EmitSound("Hero_PhantomLancer.Concord.Layer")
		caster:AddNewModifier(caster, self, "modifier_rebellious_intent",{})
	end
end

function vlad_rebellious_intent:ResetToggleOnRespawn()
  return true
end
function vlad_rebellious_intent:GetCastAnimation()
  return nil
end
function vlad_rebellious_intent:GetTexture()
  return "shadow_demon_demonic_purge"
end
