atalanta_tauropolos = class({})
LinkLuaModifier("modifier_tauropolos", "abilities/atalanta/modifier_tauropolos", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_r_used", "abilities/atalanta/modifier_r_used", LUA_MODIFIER_MOTION_NONE)

function atalanta_tauropolos:OnSpellStart()
    local caster = self:GetCaster()

    caster:EmitSound("Hero_LegionCommander.PressTheAttack")

    caster:AddNewModifier(caster, self, "modifier_tauropolos", {
        duration = self:GetSpecialValueFor("duration")
    })

    caster:CapArrows()
    caster:AddArrows(self:GetSpecialValueFor("bonus_arrows"))

    caster:AddNewModifier(caster, self, "modifier_r_used", {
        duration = 6
    })
    if caster.GoldenAppleAcquired and caster:FindAbilityByName("atalanta_golden_apple"):IsCooldownReady() then
        caster:SwapAbilities("atalanta_tauropolos", "atalanta_golden_apple", false, true)
        Timers:CreateTimer(self:GetSpecialValueFor("attribute_swap_duration"), function()
            caster:SwapAbilities("atalanta_golden_apple", "atalanta_tauropolos", false, true)
        end)
    end
end

function atalanta_tauropolos:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_3
end

function atalanta_tauropolos:GetAbilityTextureName()
    return "custom/atalanta_tauropolos"
end