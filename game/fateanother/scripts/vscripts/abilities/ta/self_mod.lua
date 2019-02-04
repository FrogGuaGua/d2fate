true_assassin_self_modification = class({})
LinkLuaModifier("modifier_ta_agi", "abilities/ta/modifier_ta_agi", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_self_mod", "abilities/ta/modifier_self_mod", LUA_MODIFIER_MOTION_NONE)
require('ta_ability')

function true_assassin_self_modification:GetIntrinsicModifierName()
    return "modifier_ta_agi"
end

function true_assassin_self_modification:OnSpellStart()
    local hCaster = self:GetCaster()
    local fHeal = self:GetSpecialValueFor("heal")
    local fHealOverTime = self:GetSpecialValueFor("heal_ot")
    local fDuration = self:GetSpecialValueFor("duration")
    local fAgi = hCaster:FindModifierByName("modifier_ta_agi").fAgi

    hCaster:EmitSound("Hero_LifeStealer.OpenWounds.Cast")
    local pc = ParticleManager:CreateParticle("particles/units/heroes/hero_bane/bane_fiendsgrip_ground_rubble.vpcf", PATTACH_ABSORIGIN_FOLLOW, hCaster)
    ParticleManager:SetParticleControl(pc, 1, hCaster:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(pc)

    hCaster:ApplyHeal(fHeal, hCaster)
    hCaster:AddNewModifier(hCaster, self, "modifier_self_mod", { Duration = fDuration, heal = fHealOverTime, agi = fAgi })
    TACheckCombo(hCaster, self)
end