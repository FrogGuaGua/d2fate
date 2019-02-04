vlad_attribute_innocent_monster = class({})
LinkLuaModifier("modifier_innocent_monster", "abilities/vlad/modifier_innocent_monster", LUA_MODIFIER_MOTION_NONE)
vlad_attribute_protection_of_faith = class({})
LinkLuaModifier("modifier_protection_of_faith", "abilities/vlad/modifier_protection_of_faith", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_protection_of_faith_proc", "abilities/vlad/modifier_protection_of_faith_proc", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_protection_of_faith_proc_cd", "abilities/vlad/modifier_protection_of_faith_proc_cd", LUA_MODIFIER_MOTION_NONE)
vlad_attribute_improved_impaling = class({})
LinkLuaModifier("modifier_improved_impaling", "abilities/vlad/modifier_improved_impaling", LUA_MODIFIER_MOTION_NONE)
vlad_attribute_instant_curse = class({})
vlad_attribute_bloodletter = class({})

function vlad_attribute_innocent_monster:GetAbilityTextureName()
  return "custom/vlad_innocent_monster"
end
function vlad_attribute_protection_of_faith:GetAbilityTextureName()
  return "custom/vlad_protection_of_faith"
end
function vlad_attribute_improved_impaling:GetAbilityTextureName()
  return "custom/vlad_improved_impaling"
end
function vlad_attribute_instant_curse:GetAbilityTextureName()
  return "shadow_demon_disruption"
end
function vlad_attribute_bloodletter:GetAbilityTextureName()
  return "custom/vlad_transfusion2"
end

function WrapAttributes(ability, attributeName, callback)
  function ability:OnSpellStart()
    local caster = self:GetCaster()
    local player = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()

    hero[attributeName] = true
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - self:GetManaCost(1))

    if callback then
      callback(self, hero)
    end
  end
end

WrapAttributes(vlad_attribute_innocent_monster, "InnocentMonsterAcquired", function(ability, hero)
  hero:AddNewModifier(hero, ability, "modifier_innocent_monster", {})
end)
WrapAttributes(vlad_attribute_protection_of_faith, "ProtectionOfFaithAcquired", function(ability, hero)
  hero:AddNewModifier(hero, ability, "modifier_protection_of_faith", {})
end)
WrapAttributes(vlad_attribute_improved_impaling, "ImprovedImpalingAcquired", function(ability, hero)
  hero:AddNewModifier(hero, ability, "modifier_improved_impaling", {})
end)
WrapAttributes(vlad_attribute_instant_curse, "InstantCurseAcquired")
WrapAttributes(vlad_attribute_bloodletter, "BloodletterAcquired")
